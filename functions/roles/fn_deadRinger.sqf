//////////////////////////////////////////////////////////////////
// Waldo_fnc_deadRinger
// CLIENT: traitor activation item (Y/U/J, whichever it's bound to). Arms a
// 25s window: the next hit you take in that time - any hit, not just a
// lethal one, see the HandleDamage guard installed once in
// Waldo_fnc_initClient - is faked instead of dealing damage
// (Waldo_fnc_deadRingerTrigger). Whoever shot you sees you go down normally -
// they just don't know you're not actually dead.
//
// Returns true (consumed on arming; the trigger itself is separate).
//////////////////////////////////////////////////////////////////

if (player getVariable ["Waldo_deadRingerArmed", false]) exitWith {
	["DEAD RINGER", "Already armed.", "WARNING", 3, "BOTTOM_LEFT", "DEADRINGER", "TRAITOR"] call Waldo_fnc_ShowUiNotification;
	false
};

player setVariable ["Waldo_deadRingerArmed", true];
["DEAD RINGER", "Armed - any hit in the next 25s will be faked.", "SUCCESS", 4, "BOTTOM_LEFT", "DEADRINGER", "TRAITOR"] call Waldo_fnc_ShowUiNotification;

[] spawn {
	sleep 25;
	if (player getVariable ["Waldo_deadRingerArmed", false]) then {
		player setVariable ["Waldo_deadRingerArmed", false];
		["DEAD RINGER", "Expired.", "INFO", 3, "BOTTOM_LEFT", "DEADRINGER", "TRAITOR"] call Waldo_fnc_ShowUiNotification;
	};
};

true
