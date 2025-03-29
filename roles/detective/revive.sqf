_target = cursorTarget;
if(!alive _target && !isNil {_target getVariable "player"}) then {
	if(player distance _target < 2) then {
		(findDisplay 46) displayRemoveAllEventHandlers "KeyDown";
		hint "Attempting Revive...";
		sleep 2;
		hint "";
		[0] remoteExec ["setPlayerRespawnTime", (_target getVariable "player")];
		sleep 1;
		[2400] remoteExec ["setPlayerRespawnTime", (_target getVariable "player")];
	};
};
waituntil {!isnull (finddisplay 46)};
(findDisplay 46) displayRemoveAllEventHandlers "KeyDown";
_shop = findDisplay 46 displayAddEventHandler ["KeyDown", {_this select 1 execVM "systems\shops.sqf"}];