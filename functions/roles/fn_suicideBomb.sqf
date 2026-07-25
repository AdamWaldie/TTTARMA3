//////////////////////////////////////////////////////////////////
// Waldo_fnc_suicideBomb
// CLIENT: activation item (Y). Plays a warning, then detonates a bomb at
// the player's position after a short delay. Returns true (always consumed).
//////////////////////////////////////////////////////////////////

if (!alive player) exitWith { true };

playSound3D [getMissionPath "audio\suicide.ogg", player];
sleep 2;

if (alive player) then {
	private _ied = createVehicle ["Bo_Mk82", getPos player, [], 0, "NONE"];
	_ied setPos (getPos player);
	player setDamage 1;
};

true
