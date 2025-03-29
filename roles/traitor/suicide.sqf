_player = player;
playSound3D [getMissionPath "audio\suicide.ogg", player];
(findDisplay 46) displayRemoveAllEventHandlers "KeyDown";
sleep 2;
if(alive player) then {
	_ied = createVehicle ["Bo_Mk82", getPos player, [], 0, "NONE"];
	_ied setPos getPos player;
	player setDamage 1;
};
