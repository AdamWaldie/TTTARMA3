//////////////////////////////////////////////////////////////////
// Waldo_fnc_tester
// CLIENT: detective activation item (Y/U/J, whichever it's bound to). "Tests"
// the aimed-at person within 3m (alive or a corpse), permanently revealing
// their role to the detective via the icons handler - after a 5s delay, not
// instantly. The target is notified the moment testing starts (a corpse has
// no screen to put this on, so only a living player gets it), with an extra
// warning if they're a Traitor that the test will expose them - the delay is
// the window that notification buys them to react (flee, silence the
// detective) before the reveal locks in.
//
// Returns true when a valid target was tested (so it is consumed), false
// otherwise so it stays assigned for another try.
//////////////////////////////////////////////////////////////////

private _target = cursorTarget;

if (isNull _target || {!(_target isKindOf "CAManBase")}) exitWith {
	["PORTABLE TESTER", "No valid target.", "WARNING", 3, "BOTTOM_LEFT", "TESTER", "TESTER"] call Waldo_fnc_ShowUiNotification;
	false
};

if ((player distance _target) > 3) exitWith {
	["PORTABLE TESTER", "Move closer to test.", "WARNING", 3, "BOTTOM_LEFT", "TESTER", "TESTER"] call Waldo_fnc_ShowUiNotification;
	false
};

["PORTABLE TESTER", "Testing...", "INFO", 2, "BOTTOM_LEFT", "TESTER", "TESTER"] call Waldo_fnc_ShowUiNotification;

if (isPlayer _target && {alive _target}) then {
	private _targetRole = _target getVariable ["role", "Innocent"];
	private _msg = "You are being tested with a Portable Tester.";
	private _state = "WARNING";
	if (_targetRole == "Traitor") then {
		_msg = _msg + " This will reveal you as a Traitor to the Detective.";
		_state = "ERROR";
	};
	[
		"BEING TESTED", _msg, _state, 6, "TOP_RIGHT", "TESTED", "TESTER"
	] remoteExec ["Waldo_fnc_ShowUiNotification", _target];
};

[_target] spawn {
	params ["_target"];
	sleep 5;
	_target setVariable ["tested", true, true];
	["PORTABLE TESTER", format ["Test complete - %1.", (_target getVariable ["role", "Innocent"])],
		"SUCCESS", 4, "BOTTOM_LEFT", "TESTER", "TESTER"] call Waldo_fnc_ShowUiNotification;
};

true
