//////////////////////////////////////////////////////////////////
// Waldo_fnc_holster
// CLIENT: toggle holster / lower weapon (bound to L). Handy in TTT for
// looking non-threatening. Re-enables the previously used weapon when
// currently unarmed.
//////////////////////////////////////////////////////////////////

if (currentWeapon player == "") then {
	if (primaryWeapon player != "") then {
		player selectWeapon (primaryWeapon player);
	} else {
		if (handgunWeapon player != "") then {
			player selectWeapon (handgunWeapon player);
		};
	};
} else {
	player action ["SwitchWeapon", player, player, -1];
};
