_target = cursorTarget;
if(!alive _target && !isNil {_target getVariable "player"}) then {
	if(player distance _target < 2) then {
		(findDisplay 46) displayRemoveAllEventHandlers "KeyDown";
		hint "Attempting Revive...";
		sleep 2;
		hint "";
		_revivedPlayer = _target getVariable "player";
		[0] remoteExec ["setPlayerRespawnTime", (_target getVariable "player")];
		sleep 1;
		[2400] remoteExec ["setPlayerRespawnTime", (_target getVariable "player")];
		_tList = missionNamespace getVariable "TraitorList";
		_tList append [_revivedPlayer];
		_revivedPlayer setVariable ["role","Tratior",true];
		missionNamespace setVariable ["TraitorList", _tList,true];
		["data\TTTHud\init.sqf"] remoteExec ["execVM ",_revivedPlayer];
	};
};