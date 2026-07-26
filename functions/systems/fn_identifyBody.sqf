//////////////////////////////////////////////////////////////////
// Waldo_fnc_identifyBody
// SERVER: called when a player identifies ("calls in") a corpse via its scroll
// action. Confirming a DEATH is fine coming from anyone - it announces that a
// body was found. Revealing the victim's ROLE is a Detective-only finding (the
// actual deduction payload); anyone else just confirms the body without it.
//
// Gated on Waldo_roleRevealed (NOT Waldo_identified): a non-Detective finding
// the body first must not use up the action, or a Detective could never reveal
// the role afterward. So a non-Detective call only announces "found" (once -
// repeat calls after that are silent no-ops) and leaves the action available;
// only a Detective's call reveals the role and retires the action for good.
//
// params: [_body, _finder]
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};
params ["_body", "_finder"];
if (isNull _body) exitWith {};
if (_body getVariable ["Waldo_roleRevealed", false]) exitWith {};   // nothing more to learn

private _who = [name _finder, "Someone"] select (isNull _finder);
private _finderIsDetective = !isNull _finder && {(_finder getVariable ["role", ""]) == "Detective"};
private _alreadyFound = _body getVariable ["Waldo_identified", false];

_body setVariable ["Waldo_identified", true, true];

if (_finderIsDetective) then {
	_body setVariable ["Waldo_roleRevealed", true, true];
	private _role = _body getVariable ["role", "Innocent"];
	[format ["%1 identified %2's body - they were a %3.", _who, name _body, _role]] remoteExec ["systemChat", 0];
} else {
	if (!_alreadyFound) then {
		[format ["%1 found %2's body.", _who, name _body]] remoteExec ["systemChat", 0];
	};
};

diag_log format ["[Waldo][server] identifyBody: %1 -> %2 (detective=%3)", _who, name _body, _finderIsDetective];
