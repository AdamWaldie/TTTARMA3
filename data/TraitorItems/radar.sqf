player setVariable ["radar",1];
addMissionEventHandler ["Draw3D", {
	_radar = (player getVariable "radar");
	{
		_eyePos = getPosATL _x;
		_role = (_x getVariable "role");
		_distance = player distance _x;
		_color = [0.12549,0.72941,0.09412,_radar];
		if(_role == "Traitor") then {
			_color = [0.75,0.21,0.21,_radar];
		};
		if(_role == "Detective") then {
			_color = [0.01,0.45,1,_radar];
		};
		drawIcon3D
		[
			"",//Path to image displayed near text
			_color,//color of the text using RGBA
			_eyePos,//position of the text _x referring to the player in 'allUnits'
			1,//Width
			0,//height from position, below
			0,//angle
			"〇",//text to be displayed
			2,//shadow on text, 0=none,1=shadow,2=outline
			0.10-(_distance / 2500),//text size
			"PuristaMedium",//text font
			"center"//align text left, right, or center
		];
	} forEach allUnits;
	player setVariable ["radar",(_radar - 0.004),true];
}];
while {true} do {
	sleep 30;
	player setVariable ["radar",1];
};