//////////////////////////////////////////////////////////////////
// Waldo_fnc_onKilled
// SERVER-authoritative kill handler (invoked from an MPKilled EH that
// fires on every machine; only the server acts). Handles:
//   - extending the round timer per death
//   - awarding shop credits (detectives for traitor kills, vice versa)
//   - Jester clean-kill detection (non-Traitor killed the Jester)
//   - karma: lowering the culprit's karma for killing a teammate (RDM)
//
// params (from MPKilled): [_unit, _killer, _instigator, _useEffects]
//////////////////////////////////////////////////////////////////

params ["_unit", "_killer", "_instigator", "_useEffects"];
if (!isServer) exitWith {};

private _traitors = missionNamespace getVariable ["TraitorList", []];
private _detectives = missionNamespace getVariable ["DetectiveList", []];

// Extend the round for every death.
private _dead = missionNamespace getVariable ["roundDeadLength", 30];
missionNamespace setVariable ["timelimit", (missionNamespace getVariable ["timelimit", 0]) + _dead, true];

private _victimRole = _unit getVariable ["role", "Innocent"];

// Resolve the real culprit (instigator preferred; fall back to killer).
private _culprit = _instigator;
if (isNull _culprit) then { _culprit = _killer; };

// Final fallback: the last unit that actually damaged the victim, tracked locally via
// HandleDamage on the victim's own machine (Waldo_lastDamager, set in fn_initClient.sqf).
// Covers ACE bleed-out/DoT deaths, where the terminal MPKilled event's own
// killer/instigator can resolve to null or to the victim themselves even though a real
// player's shot is what actually put them down.
if (isNull _culprit || {_culprit == _unit}) then {
	private _lastDamager = _unit getVariable ["Waldo_lastDamager", objNull];
	if (!isNull _lastDamager && {_lastDamager != _unit}) then { _culprit = _lastDamager; };
};
private _culpritRole = if (isNull _culprit) then { "" } else { _culprit getVariable ["role", ""] };

// --- Forensic state on the body (for the DNA scanner + Identify Body) ---
_unit setVariable ["Waldo_deathTime", time, true];
_unit setVariable ["Waldo_deathWeapon", (if (isNull _culprit) then { "" } else { currentWeapon _culprit }), true];
_unit setVariable ["Waldo_identified", false, true];
_unit setVariable ["Waldo_roleRevealed", false, true];

if (!isNull _culprit && {_culprit != _unit}) then {
	// Count the kill toward the culprit's in-round tally (scoreboard / MVP).
	if (isPlayer _culprit) then {
		_culprit setVariable ["Waldo_roundKills", (_culprit getVariable ["Waldo_roundKills", 0]) + 1, true];
	};

	// DNA left at the scene. A traitor's armed "False Flag" frames a random
	// living innocent instead (and is consumed); otherwise it's the real culprit.
	// This used to have zero observable effect for a tester who didn't
	// personally go DNA-scan the corpse afterward - the frame itself worked,
	// there was just no confirmation anywhere that it had, which read as
	// "doesn't seem to work." A private notification card to the culprit
	// (Waldo_fnc_ShowUiNotification) closes that gap. Also excludes Detectives
	// from the frame pool now, matching the shop tooltip's actual wording
	// ("an innocent bystander") - it used to only exclude other Traitors, so
	// it could occasionally frame a Detective.
	private _dnaOn = _culprit;
	if (_culprit getVariable ["Waldo_falseFlag", false]) then {
		private _frames = allPlayers select { alive _x && {!(_x in _traitors)} && {!(_x in _detectives)} && {_x != _culprit} };
		if (count _frames > 0) then {
			_dnaOn = selectRandom _frames;
			[
				"FALSE FLAG TRIGGERED", format ["%1's DNA was left at the scene instead of yours.", name _dnaOn],
				"SUCCESS", 8, "TOP_RIGHT", "FALSEFLAG", "TRAITOR"
			] remoteExec ["Waldo_fnc_ShowUiNotification", _culprit];
		} else {
			[
				"FALSE FLAG FAILED", "No one else was around to frame - your own DNA was left at the scene.",
				"WARNING", 8, "TOP_RIGHT", "FALSEFLAG", "TRAITOR"
			] remoteExec ["Waldo_fnc_ShowUiNotification", _culprit];
		};
		_culprit setVariable ["Waldo_falseFlag", false, true];
	};
	_unit setVariable ["Waldo_killerDNA", _dnaOn, true];
	_unit setVariable ["Waldo_killerDNATime", time, true];
	[_unit, _dnaOn] call Waldo_fnc_dnaContaminate;

	// Also leave DNA on the gear the victim drops, so a killer who flees the body
	// still leaves a second trace nearby (tag the death weapon-holders shortly
	// after the engine spawns them).
	[_unit, _dnaOn] spawn {
		params ["_body", "_dnaOn"];
		sleep 1;
		{
			_x setVariable ["Waldo_killerDNA", _dnaOn, true];
			_x setVariable ["Waldo_killerDNATime", time, true];
			[_x, _dnaOn] call Waldo_fnc_dnaContaminate;
		} forEach (nearestObjects [_body, ["WeaponHolderSimulated", "GroundWeaponHolder"], 4]);
	};
};

// "Identify Body" scroll action on the corpse - calling it in confirms the death
// to everyone (and, if a Detective calls it, the victim's role). hideOnUse is
// FALSE and the condition checks Waldo_roleRevealed (not Waldo_identified): a
// non-Detective finding the body first must NOT consume/hide the action, or a
// Detective arriving later could never get the role reveal. It only actually
// disappears once a Detective has identified it. Added on every machine
// (JIP-safe).
[_unit, [
	"<t color='#ffd23f'>Identify Body</t>",
	// addAction's own _this is [_target, _caller, _actionId, _arguments], NOT
	// just the caller - passing it through as the second element made
	// Waldo_fnc_identifyBody's _finder that whole 4-element array instead of
	// the caller unit, breaking the "who identified this" attribution
	// entirely. _target/_caller are already the right values as magic
	// variables here; no need to touch _this at all.
	{ [_target, _caller] remoteExec ["Waldo_fnc_identifyBody", 2]; },
	nil, 4, true, false, "",
	"!(_target getVariable ['Waldo_roleRevealed', false])",
	2.5
]] remoteExec ["addAction", 0, _unit];

private _guilty = true;   // did the culprit kill someone they shouldn't have?

// Credit awards (amount per kill is the lobby "Kill Reward Credits" setting;
// detectives are paid for traitor kills and traitors for detective kills).
private _reward = missionNamespace getVariable ["Waldo_killReward", 1];
if (_victimRole == "Traitor") then {
	_guilty = false;
	if (_reward > 0) then { { _x setVariable ["points", (_x getVariable ["points", 0]) + _reward, true]; } forEach _detectives; };
};
if (_victimRole == "Detective") then {
	if (_reward > 0) then { { _x setVariable ["points", (_x getVariable ["points", 0]) + _reward, true]; } forEach _traitors; };
};

// Jester clean kill: a non-Traitor player (and not self / environment) killed the Jester.
// isPlayer is required - a non-player culprit (a vehicle, an explosive/environment prop
// with no "role" variable) has _culpritRole default to "" via getVariable's safe default,
// and "" != "Traitor" was trivially true, incorrectly flagging a clean kill for any
// non-player-attributed Jester death (e.g. an unattributed explosion).
if (_victimRole == "Jester" && {!isNull _culprit} && {_culprit != _unit} && {isPlayer _culprit} && {_culpritRole != "Traitor"}) then {
	missionNamespace setVariable ["JESTERCLEANKILL", true, true];
};

// Killing as a Traitor is never "guilty".
if (_culpritRole == "Traitor") then { _guilty = false; };

// Karma: a non-Traitor killed a teammate (innocent/detective/jester) -> RDM.
if ((missionNamespace getVariable ["KarmaEnabled", true]) && {_guilty} && {!isNull _culprit} && {_culprit != _unit} && {isPlayer _culprit}) then {
	private _uid = getPlayerUID _culprit;
	if (_uid != "") then {
		private _key = "Waldo_karma_" + _uid;
		private _k = profileNamespace getVariable [_key, 100];
		profileNamespace setVariable [_key, (_k - 30) max 0];
		saveProfileNamespace;
		diag_log format ["[Waldo][server] karma: %1 RDM'd -> karma %2", name _culprit, (_k - 30) max 0];
	};
};
