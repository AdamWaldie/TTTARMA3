//////////////////////////////////////////////////////////////////
// Waldo_fnc_reviveAsTraitor
// SERVER: adds a revived player to the Traitor team (used by the Traitor
// "Defibrillator"). Runs on the server so the authoritative TraitorList that
// win checks read stays correct.
//
// params: [_unit]
//////////////////////////////////////////////////////////////////

params ["_unit"];
if (!isServer) exitWith {};
if (isNull _unit) exitWith {};

_unit setVariable ["role", "Traitor", true];
_unit setVariable ["points", (_unit getVariable ["points", 0]) max 1, true];

private _traitors = missionNamespace getVariable ["TraitorList", []];
_traitors pushBackUnique _unit;
missionNamespace setVariable ["TraitorList", _traitors, true];

diag_log format ["[Waldo][server] reviveAsTraitor: %1 is now a Traitor", name _unit];
