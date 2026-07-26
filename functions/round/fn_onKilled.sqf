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

// Leave the killer's DNA on the body for the detective's DNA scanner, and count
// this kill toward the culprit's in-round tally for the scoreboard.
if (!isNull _culprit && {_culprit != _unit}) then {
	_unit setVariable ["Waldo_killerDNA", _culprit, true];
	_unit setVariable ["Waldo_killerDNATime", time, true];
	if (isPlayer _culprit) then {
		_culprit setVariable ["Waldo_roundKills", (_culprit getVariable ["Waldo_roundKills", 0]) + 1, true];
	};
};

// "Identify Body" scroll action on the corpse - calling it in announces the
// victim's role to everyone (the core TTT deduction feedback). Added on every
// machine (JIP-safe); the condition hides it once the body has been called in.
_unit setVariable ["Waldo_identified", false, true];
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
