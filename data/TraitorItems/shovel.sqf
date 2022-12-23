_target = cursorTarget;
if(!alive _target) then {
	if(player distance _target < 2) then {
		(findDisplay 46) displayRemoveAllEventHandlers "KeyDown";
		hint "Hiding Body...";
		sleep 2;
		hint "";
		deleteVehicle _target;
	};
};
player setVariable ["powerup","shovel",false];
waituntil {!isnull (finddisplay 46)};
(findDisplay 46) displayRemoveAllEventHandlers "KeyDown";
_shop = findDisplay 46 displayAddEventHandler ["KeyDown", {_this select 1 execVM "shops.sqf"}];