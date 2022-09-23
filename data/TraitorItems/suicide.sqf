_player = player;
[[_player, "suicide"], "Say3dMP", true] spawn BIS_fnc_MP;
(findDisplay 46) displayRemoveAllEventHandlers "KeyDown";
sleep 2;
if(alive player) then {
	_ied = createVehicle ["Bo_Mk82", getPos player, [], 0, "NONE"];
	_ied setPos getPos player;
	player setDamage 1;
};
