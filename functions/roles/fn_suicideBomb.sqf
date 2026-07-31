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
		// DemoCharge_Remote_Ammo_Scripted, not Bo_Mk82 (a full 500lb aerial bomb) -
		// see fn_c4Charge.sqf, which shares this same blast. Must be the
		// "_Scripted" variant, and needs an explicit setDamage 1 below to go off -
		// plain DemoCharge_Remote_Ammo just sits armed waiting for a detonation
		// signal instead of exploding on creation like a bomb would.
		private _ied = createVehicle ["DemoCharge_Remote_Ammo_Scripted", getPos player, [], 0, "NONE"];
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
