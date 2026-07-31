//////////////////////////////////////////////////////////////////
// Waldo_fnc_suicideBomb
// CLIENT: activation item (Y/U/J, whichever it's bound to). Plays a warning, then detonates a bomb at
// the player's position after a short delay. Returns true (always consumed).
//////////////////////////////////////////////////////////////////

if (!alive player) exitWith { true };

playSound3D [getMissionPath "audio\suicide.ogg", player];

// Y is handled unscheduled (called directly from the KeyDown handler), so the
// delay has to live in its own scheduled thread - sleep is illegal here otherwise.
[] spawn {
	sleep 2;

	if (alive player) then {
		// Back to Bo_Mk82 - see fn_c4Charge.sqf, which shares this same
		// blast and has the full reasoning (explicitly confirmed wanting
		// the original full 500lb blast back, not a medium option).
		private _ied = createVehicle ["Bo_Mk82", getPos player, [], 0, "NONE"];
		_ied setPos (getPos player);
		// setShotParents is server/HC-only in MP and would silently be ignored if
		// called here on the bomber's own client - remoteExec it to the server so
		// anyone this blast kills correctly attributes to the bomber (karma, DNA,
		// round-kill credit), same as fn_c4Charge.sqf's own charge.
		[_ied, [player, player]] remoteExec ["setShotParents", 2];
		_ied setDamage 1;
		player setDamage 1;
	};
};

true
