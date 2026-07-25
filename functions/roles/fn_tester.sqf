//////////////////////////////////////////////////////////////////
// Waldo_fnc_tester
// CLIENT: detective activation item (Y). "Tests" the aimed-at person within
// 3m (alive or a corpse), permanently revealing their role to the detective
// via the icons handler. Returns true when a valid target was tested (so it
// is consumed), false otherwise so it stays queued for another try.
//////////////////////////////////////////////////////////////////

private _target = cursorTarget;

if (isNull _target || {!(_target isKindOf "CAManBase")}) exitWith {
	hint "No valid target.";
	false
};

if ((player distance _target) > 3) exitWith {
	hint "Move closer to test.";
	false
};

_target setVariable ["tested", true, true];
hint "Testing...";
sleep 2;
hint "";
true
