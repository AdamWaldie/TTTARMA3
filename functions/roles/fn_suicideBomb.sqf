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
		// Two stacked SatchelCharge_Remote_Ammo_Scripted - see fn_c4Charge.sqf,
		// which shares this same blast and has the full reasoning ("a
		// little more power than the satchel" without gambling on a fourth
		// unverified ammo class after Bo_Mk82/Sh_82_HE both failed).
		private _ied1 = createVehicle ["SatchelCharge_Remote_Ammo_Scripted", getPos player, [], 0, "NONE"];
		private _ied2 = createVehicle ["SatchelCharge_Remote_Ammo_Scripted", getPos player, [], 0, "NONE"];
		_ied1 setPos (getPos player);
		_ied2 setPos (getPos player);
		// setShotParents is server/HC-only in MP and would silently be ignored if
		// called here on the bomber's own client - remoteExec it to the server so
		// anyone this blast kills correctly attributes to the bomber (karma, DNA,
		// round-kill credit), same as fn_c4Charge.sqf's own charge.
		[_ied1, [player, player]] remoteExec ["setShotParents", 2];
		[_ied2, [player, player]] remoteExec ["setShotParents", 2];
		_ied1 setDamage 1;
		_ied2 setDamage 1;
		player setDamage 1;
	};
};

true
