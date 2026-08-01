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
// Every branch below gives the CALLER some private feedback, even when
// there's nothing new to broadcast - this used to be a genuine silent no-op
// for a repeat non-Detective call (the single most likely thing a tester
// actually does: click it, see the body's still there un-Detective'd, click
// it again), which read exactly like "this action does nothing" even though
// the FIRST call had worked correctly.
//
// The everyone-facing "BODY FOUND"/"BODY IDENTIFIED" cards go through
// Waldo_fnc_ShowUiNotificationAll (per-player targeted remoteExec), not a
// plain remoteExec [..., -2] broadcast - confirmed live that the latter
// simply never delivered this function to ANY client on this mission's
// actual hosting setup, first call or not, no matter how long you waited.
//
// params: [_body, _finder]
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};
params ["_body", "_finder"];
if (isNull _body) exitWith {};

private _who = [name _finder, "Someone"] select (isNull _finder);
private _finderIsDetective = !isNull _finder && {(_finder getVariable ["role", ""]) == "Detective"};
private _alreadyRevealed = _body getVariable ["Waldo_roleRevealed", false];
private _alreadyFound = _body getVariable ["Waldo_identified", false];

// Rich, hard-to-miss cards (Waldo_fnc_ShowUiNotification) instead of a plain
// systemChat line - a systemChat announcement sits in the small chat log
// corner and is trivial to miss mid-firefight, which is most of why this
// used to read as "doesn't do anything" for whoever called it in.
if (_alreadyRevealed) then {
	// Nothing left to learn - the action's own condition should already be
	// hiding it for everyone by this point (Waldo_roleRevealed flips it
	// false), so reaching this is a rare race (a click landing right as that
	// updates). Private card either way, not broadcast - everyone already
	// got the original reveal.
	if (!isNull _finder) then {
		[
			"ALREADY IDENTIFIED", format ["%1's role is already confirmed - nothing new here.", name _body],
			"INFO", 4, "TOP_RIGHT", "IDENTIFY", "INVESTIGATION"
		] remoteExec ["Waldo_fnc_ShowUiNotification", _finder];
	};
} else {
	_body setVariable ["Waldo_identified", true, true];
	if (_finderIsDetective) then {
		_body setVariable ["Waldo_roleRevealed", true, true];
		private _role = _body getVariable ["role", "Innocent"];
		[
			"BODY IDENTIFIED", format ["%1 identified %2's body - they were a %3.", _who, name _body, _role],
			"SUCCESS", 10, "TOP_RIGHT", "IDENTIFY", "INVESTIGATION"
		] call Waldo_fnc_ShowUiNotificationAll;
	} else {
		if (_alreadyFound) then {
			// Repeat non-Detective call - explains WHY the action is still
			// there (by design, so a Detective can still use it) instead of
			// leaving the caller to conclude nothing happened.
			if (!isNull _finder) then {
				[
					"ALREADY FOUND", format ["%1's body has already been reported. A Detective still needs to identify them for a role reveal.", name _body],
					"INFO", 5, "TOP_RIGHT", "IDENTIFY", "INVESTIGATION"
				] remoteExec ["Waldo_fnc_ShowUiNotification", _finder];
			};
		} else {
			[
				"BODY FOUND", format ["%1 found %2's body.", _who, name _body],
				"INFO", 8, "TOP_RIGHT", "IDENTIFY", "INVESTIGATION"
			] call Waldo_fnc_ShowUiNotificationAll;
		};
	};
};

diag_log format ["[Waldo][server] identifyBody: %1 -> %2 (detective=%3, alreadyFound=%4, alreadyRevealed=%5)", _who, name _body, _finderIsDetective, _alreadyFound, _alreadyRevealed];
