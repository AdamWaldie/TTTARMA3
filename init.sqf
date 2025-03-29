if(isServer) then {
	execVM "config.sqf";
	sleep 0.1;
	execVM "systems\ttt.sqf";
};

Say3dMP = {
	_speaker = _this select 0;
	_sound 	= _this select 1;
	//if (isDedicated) exitWith {};
	//if ((player distance _speaker) > 100) exitWith {}; //you probably don't need this, not sure
	_speaker say3d _sound;
};