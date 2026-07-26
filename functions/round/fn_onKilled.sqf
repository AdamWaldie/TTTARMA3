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
	private _dnaOn = _culprit;
	if (_culprit getVariable ["Waldo_falseFlag", false]) then {
		private _frames = allPlayers select { alive _x && {!(_x in _traitors)} && {_x != _culprit} };
		if (count _frames > 0) then { _dnaOn = selectRandom _frames; };
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
// to everyone (and, if a Detective calls it, the victim's role). Added on every
// machine (JIP-safe); the condition hides it once the body has been called in.
[_unit, [
	"<t color='#ffd23f'>Identify Body</t>",
	{ [_target, _this] remoteExec ["Waldo_fnc_identifyBody", 2]; },
	nil, 4, true, true, "",
	"!(_target getVariable ['Waldo_identified', false])",
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

// Jester clean kill: a non-Traitor (and not self / environment) killed the Jester.
if (_victimRole == "Jester" && {!isNull _culprit} && {_culprit != _unit} && {_culpritRole != "Traitor"}) then {
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
