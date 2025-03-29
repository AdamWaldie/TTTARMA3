_target = cursorTarget;
if(alive _target) then {
	if(player distance _target < 2) then {
		_target setVariable ["tested",true,true];
		(findDisplay 46) displayRemoveAllEventHandlers "KeyDown";
		hint "Testing...";
		sleep 2;
		hint "";
	};
};
player setVariable ["powerup","tester",false];
waituntil {!isnull (finddisplay 46)};
(findDisplay 46) displayRemoveAllEventHandlers "KeyDown";
_shop = findDisplay 46 displayAddEventHandler ["KeyDown", {_this select 1 execVM "systems\shops.sqf"}];