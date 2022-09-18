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