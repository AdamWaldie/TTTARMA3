if (_this == 11 || _this == 5) then {
	player action ["SWITCHWEAPON",player,player,-1];
		waitUntil {currentWeapon player == "" or {primaryWeapon player == "" && handgunWeapon player == ""}};
};