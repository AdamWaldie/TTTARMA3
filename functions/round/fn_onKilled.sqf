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

private _guilty = true;   // did the culprit kill someone they shouldn't have?

// Credit awards.
if (_victimRole == "Traitor") then {
	_guilty = false;
	{ _x setVariable ["points", (_x getVariable ["points", 0]) + 1, true]; } forEach _detectives;
};
if (_victimRole == "Detective") then {
	{ _x setVariable ["points", (_x getVariable ["points", 0]) + 1, true]; } forEach _traitors;
};

// Jester clean kill: a non-Traitor (and not self / environment) killed the Jester.
if (_victimRole == "Jester" && {!isNull _culprit} && {_culprit != _unit} && {_culpritRole != "Traitor"}) then {
	missionNamespace setVariable ["JESTERCLEANKILL", true, true];
};

// Killing as a Traitor is never "guilty".
if (_culpritRole == "Traitor") then { _guilty = false; };

// Karma: a non-Traitor killed a teammate (innocent/detective/jester) -> RDM.
if (_guilty && {!isNull _culprit} && {_culprit != _unit} && {isPlayer _culprit}) then {
	private _uid = getPlayerUID _culprit;
	if (_uid != "") then {
		private _key = "Waldo_karma_" + _uid;
		private _k = profileNamespace getVariable [_key, 100];
		profileNamespace setVariable [_key, (_k - 30) max 0];
		saveProfileNamespace;
		diag_log format ["[Waldo][server] karma: %1 RDM'd -> karma %2", name _culprit, (_k - 30) max 0];
	};
};
