_player = player;
switch (_this) do {
	case 48: {
		disableSerialization;
		createDialog "tMenu";
		waitUntil {!isNull (uiNameSpace getVariable "tMenu")};
		_display = uiNameSpace getVariable "tMenu";
		(_display displayCtrl 900) ctrlEnable false;
		(_display displayCtrl 901) ctrlSetText ("Credits: "+str(_player getVariable "points"));
		if((player getVariable "points") > 0) then {
			(_display displayCtrl 902) ctrlAddEventHandler [ "ButtonClick", {
				player setVariable ["powerup","suicide",true];
				player setVariable ["points",(player getVariable "points") - 1,true];
				closeDialog 1;
			}];
			(_display displayCtrl 903) ctrlAddEventHandler [ "ButtonClick", {
				player setVariable ["powerup","radar",true];
				player setVariable ["points",(player getVariable "points") - 1,true];
				player execVM "data\TraitorItems\radar.sqf";
				closeDialog 1;
			}];
			(_display displayCtrl 904) ctrlAddEventHandler [ "ButtonClick", {
				player setVariable ["powerup","launcher",true];
				player setVariable ["points",(player getVariable "points") - 1,true];
				player addWeaponGlobal (missionNamespace getVariable ["TraitorLauncher", "launch_NLAW_F"]);
				player addSecondaryWeaponItem (missionNamespace getVariable ["TraitorLauncherMag", "NLAW_F"]);
				closeDialog 1;
			}];
			(_display displayCtrl 905) ctrlAddEventHandler [ "ButtonClick", {
				player setVariable ["powerup","stamina",true];
				player setVariable ["points",(player getVariable "points") - 1,true];
				player enableStamina false;
				closeDialog 1;
			}];
			(_display displayCtrl 906) ctrlAddEventHandler [ "ButtonClick", {
				player setVariable ["powerup","WarpSmoke",true];
				player addMagazine ["SmokeShellRed", 2];
				player execVM "data\TraitorItems\WarpSmoke.sqf";
				player setVariable ["points",(player getVariable "points") - 1,true];
				closeDialog 1;
			}];
			(_display displayCtrl 907) ctrlAddEventHandler [ "ButtonClick", {
				player setVariable ["powerup","rifleloadout",true];
				player addWeaponGlobal (missionNamespace getVariable ["TraitorRifle", "srifle_LRR_F"]);
				player addPrimaryWeaponItem (missionNamespace getVariable ["traitorRifleOptics", "optic_LRPS"]);
				player addMagazines [(missionNamespace getVariable ["traitorRifleMagazine", "7Rnd_408_Mag"]),3];
				player setVariable ["points",(player getVariable "points") - 1,true];
				closeDialog 1;
			}];
		} else {
			(_display displayCtrl 902) ctrlEnable false;
			(_display displayCtrl 903) ctrlEnable false;
			(_display displayCtrl 904) ctrlEnable false;
			(_display displayCtrl 905) ctrlEnable false;
			(_display displayCtrl 906) ctrlEnable false;
			(_display displayCtrl 907) ctrlEnable false;
		};
	};
	case 21: {
		if(_player getVariable "powerup" == "suicide") then {
			player execVM "data\TraitorItems\suicide.sqf";
		};
	};
};