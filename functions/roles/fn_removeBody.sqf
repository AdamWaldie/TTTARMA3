//////////////////////////////////////////////////////////////////
// Waldo_fnc_removeBody
// CLIENT: activation item (Y). Aim at a dead body within 4m and press Y to
// dispose of it, destroying the evidence so a Detective can no longer test the
// corpse. Deletion is done on the server (bodies are not always local).
//
// Returns true when a body was removed (consuming the item), false otherwise so
// the item stays queued for another try.
//////////////////////////////////////////////////////////////////

private _target = cursorTarget;

if (isNull _target || {!(_target isKindOf "CAManBase")} || {alive _target}) exitWith {
	hint "Aim at a body.";
	false
};

if ((player distance _target) > 4) exitWith {
	hint "Move closer to the body.";
	false
};

hint "Disposing of the body...";

// Y is handled unscheduled (called directly from the KeyDown handler), so the
// delay has to live in its own scheduled thread - sleep is illegal here otherwise.
[_target] spawn {
	params ["_target"];
	sleep 2;

	if (isNull _target) exitWith { hint "" };   // someone else got there first

	_target remoteExec ["deleteVehicle", 2];
	hint "Body removed.";
};

true
