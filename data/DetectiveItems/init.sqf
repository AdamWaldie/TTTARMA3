_player = player;
switch (_this) do {
	case 48: {
		disableSerialization;
		createDialog "dMenu";
		waitUntil {!isNull (uiNameSpace getVariable "dMenu")};
		_display = uiNameSpace getVariable "dMenu";
		(_display displayCtrl 800) ctrlEnable false;
		//(_display displayCtrl 804) ctrlEnable false;
		(_display displayCtrl 801) ctrlSetText ("Points: "+str(_player getVariable "points"));
		if((player getVariable "points") > 0) then {
			(_display displayCtrl 802) ctrlAddEventHandler [ "ButtonClick", {
				player setVariable ["powerup","tester",true];
				player setVariable ["points",(player getVariable "points") - 1,true];
				closeDialog 1;
			}];
			(_display displayCtrl 803) ctrlAddEventHandler [ "ButtonClick", {
				player setVariable ["powerup","radar",true];
				player setVariable ["points",(player getVariable "points") - 1,true];
				player execVM "data\DetectiveItems\radar.sqf";
				closeDialog 1;
			}];
			(_display displayCtrl 804) ctrlAddEventHandler [ "ButtonClick", {
				player setVariable ["powerup","smoke",true];
				player addMagazine ["SmokeShell", 2];
				player setVariable ["points",(player getVariable "points") - 1,true];
				closeDialog 1;
			}];
			(_display displayCtrl 805) ctrlAddEventHandler [ "ButtonClick", {
				player setVariable ["powerup","stamina",true];
				player setVariable ["points",(player getVariable "points") - 1,true];
				player enableStamina false;
				closeDialog 1;
			}];
			(_display displayCtrl 806) ctrlAddEventHandler [ "ButtonClick", {
				execVM "data\DetectiveItems\armour.sqf";
				player setVariable ["powerup","bodyArmour",true];
				player setVariable ["points",(player getVariable "points") - 1,true];
				closeDialog 1;
			}];
		} else {
			(_display displayCtrl 802) ctrlEnable false;
			(_display displayCtrl 803) ctrlEnable false;
			(_display displayCtrl 804) ctrlEnable false;
			(_display displayCtrl 805) ctrlEnable false;
			(_display displayCtrl 806) ctrlEnable false;
		};
	};
	case 21: {
		if(_player getVariable "powerup" == "tester") then {
			player execVM "data\DetectiveItems\tester.sqf";
		};
		if(_player getVariable "powerup" == "defib") then {
			player execVM "data\DetectiveItems\revive.sqf";
		};
	};
};