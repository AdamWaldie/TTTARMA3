//////////////////////////////////////////////////////////////////
// Waldo_fnc_tester
// CLIENT: detective activation item (Y/U/J, whichever it's bound to). "Tests" the aimed-at person within
// 3m (alive or a corpse), permanently revealing their role to the detective
// via the icons handler. Returns true when a valid target was tested (so it
// is consumed), false otherwise so it stays assigned for another try.
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

_target setVariable ["tested", true, true];
["PORTABLE TESTER", "Testing...", "INFO", 2, "BOTTOM_LEFT", "TESTER", "TESTER"] call Waldo_fnc_ShowUiNotification;

true
