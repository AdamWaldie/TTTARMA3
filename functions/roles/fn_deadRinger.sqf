//////////////////////////////////////////////////////////////////
// Waldo_fnc_deadRinger
// CLIENT: traitor activation item (Y). Arms a 25s window: the next lethal hit
// you take in that time is faked instead of killing you (see
// Waldo_fnc_deadRingerTrigger, triggered from the HandleDamage guard installed
// once in Waldo_fnc_initClient). Whoever shot you sees you go down normally -
// they just don't know you're not actually dead.
//
// Returns true (consumed on arming; the trigger itself is separate).
//////////////////////////////////////////////////////////////////

if (player getVariable ["Waldo_deadRingerArmed", false]) exitWith { hint "Already armed."; false };

player setVariable ["Waldo_deadRingerArmed", true];
hint "Dead Ringer armed - a lethal hit in the next 25s will be faked.";

[] spawn {
	sleep 25;
	if (player getVariable ["Waldo_deadRingerArmed", false]) then {
		player setVariable ["Waldo_deadRingerArmed", false];
		hint "Dead Ringer expired.";
	};
};

true
