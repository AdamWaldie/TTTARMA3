//////////////////////////////////////////////////////////////////
// Waldo_fnc_identifyBody
// SERVER: called when a player identifies ("calls in") a corpse via its scroll
// action. Announces to everyone who died and what role they were - the core TTT
// deduction feedback (innocents learn the victim's allegiance). Idempotent: a
// body is only ever called in once.
//
// params: [_body, _finder]
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};
params ["_body", "_finder"];
if (isNull _body) exitWith {};
if (_body getVariable ["Waldo_identified", false]) exitWith {};

_body setVariable ["Waldo_identified", true, true];

private _role = _body getVariable ["role", "Innocent"];
private _who  = [name _finder, "Someone"] select (isNull _finder);

[format ["%1 found %2's body - they were a %3.", _who, name _body, _role]] remoteExec ["systemChat", 0];
diag_log format ["[Waldo][server] identifyBody: %1 -> %2 (%3)", _who, name _body, _role];
