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
		// Sh_82_HE (an 82mm mortar HE shell) - see fn_c4Charge.sqf, which
		// shares this same blast and has the full reasoning for why it's
		// neither Bo_Mk82 (way too big) nor the satchel-tier
		// DemoCharge_Remote_Ammo_Scripted (confirmed too small even after
		// already switching away from the bomb once). setDamage 1 below
		// detonates it directly, same as any standard shell/bomb ammo.
		private _ied = createVehicle ["Sh_82_HE", getPos player, [], 0, "NONE"];
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
