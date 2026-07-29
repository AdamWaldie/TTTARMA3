//////////////////////////////////////////////////////////////////
// Waldo_fnc_removeBody
// CLIENT: activation item (Y/U/J, whichever it's bound to). Aim at a dead body
// within 4m and press it to dispose of the body, destroying the evidence so a
// Detective can no longer test the corpse. Deletion is done on the server
// (bodies are not always local).
//
// Returns true when a body was removed (consuming the item), false otherwise so
// the item stays assigned for another try.
//////////////////////////////////////////////////////////////////

private _target = cursorTarget;

if (isNull _target || {!(_target isKindOf "CAManBase")} || {alive _target}) exitWith {
	["REMOVE BODY", "Aim at a body.", "WARNING", 3, "BOTTOM_LEFT", "REMOVEBODY", "REMOVE BODY"] call Waldo_fnc_ShowUiNotification;
	false
};

if ((player distance _target) > 4) exitWith {
	["REMOVE BODY", "Move closer to the body.", "WARNING", 3, "BOTTOM_LEFT", "REMOVEBODY", "REMOVE BODY"] call Waldo_fnc_ShowUiNotification;
	false
};

["REMOVE BODY", "Disposing of the body...", "INFO", 2, "BOTTOM_LEFT", "REMOVEBODY", "REMOVE BODY"] call Waldo_fnc_ShowUiNotification;

// Y is handled unscheduled (called directly from the KeyDown handler), so the
// delay has to live in its own scheduled thread - sleep is illegal here otherwise.
[_target] spawn {
	params ["_target"];
	sleep 2;

	if (isNull _target) exitWith {
		["REMOVEBODY"] call Waldo_fnc_DismissUiNotification;   // someone else got there first
	};

	_target remoteExec ["deleteVehicle", 2];
	["REMOVE BODY", "Body removed.", "SUCCESS", 3, "BOTTOM_LEFT", "REMOVEBODY", "REMOVE BODY"] call Waldo_fnc_ShowUiNotification;
};

true
