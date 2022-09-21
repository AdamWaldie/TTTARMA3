_target = cursorTarget;
if(!alive _target) then {
	if(player distance _target < 2) then {
		(findDisplay 46) displayRemoveAllEventHandlers "KeyDown";
		hint "Hiding Body...";
		sleep 2;
		hint "";
		hideBody _target;
	};
};