//////////////////////////////////////////////////////////////////
// Waldo_fnc_reviveRelink
// SERVER: called from onPlayerRespawn.sqf once a revived player's brand-new
// unit exists. A truly dead unit can never be revived in place - respawn
// always creates a new object - so the OLD unit (_oldUnit) may still be
// sitting in TraitorList/DetectiveList/JesterList, and any forEach over
// those lists (credit awards, win checks) would target an object that can
// never act again. This repoints list membership at _newUnit and applies
// the role (the Traitor Defibrillator forces Traitor; anything else keeps
// the victim's original role).
//
// params: [_newUnit, _oldUnit, _forceTraitor]
//////////////////////////////////////////////////////////////////

params ["_newUnit", "_oldUnit", "_forceTraitor"];
if (!isServer) exitWith {};
if (isNull _newUnit) exitWith {};

{
	private _list = missionNamespace getVariable [_x, []];
	if (_oldUnit in _list) then {
		_list = (_list - [_oldUnit]) + [_newUnit];
		missionNamespace setVariable [_x, _list, true];
	};
} forEach ["TraitorList", "DetectiveList", "JesterList"];

_newUnit setVariable ["role", (_oldUnit getVariable ["role", "Innocent"]), true];

if (_forceTraitor) then {
	_newUnit setVariable ["role", "Traitor", true];
	_newUnit setVariable ["points", (_newUnit getVariable ["points", 0]) max 1, true];
	private _traitors = missionNamespace getVariable ["TraitorList", []];
	_traitors pushBackUnique _newUnit;
	missionNamespace setVariable ["TraitorList", _traitors, true];
};

diag_log format ["[Waldo][server] reviveRelink: %1 is now a %2", name _newUnit, _newUnit getVariable ["role", "?"]];
