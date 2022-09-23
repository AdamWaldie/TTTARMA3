waituntil {!isnull (finddisplay 46)};
(findDisplay 46) displayRemoveAllEventHandlers "KeyDown";
_shop = findDisplay 46 displayAddEventHandler ["KeyDown", {_this select 1 execVM "shops.sqf"}];
//_holster = findDisplay 46 displayAddEventHandler ["KeyDown", {_this select 1 execVM "holster.sqf"}];

addMissionEventHandler ["Draw3D", {
	{
		_eyePos = getPosATL _x;
		_eyePos set [2, (_eyePos select 2) + 2];
		_visibility = [objNull, "VIEW"] checkVisibility [eyePos player, eyePos _x];
		_distance = player distance _x;
		if(_visibility != 0 ) then {
			if ((_x getVariable "role") == "Detective" && _x != player) then {
				if (_distance > 25) then {
					drawIcon3D
					[
						"",//Path to image displayed near text
						[0.01,0.45,1,1],//color of the text using RGBA
						_eyePos,//position of the text _x referring to the player in 'allUnits'
						1,//Width
						0,//height from position, below
						0,//angle
						"D",//text to be displayed
						2,//shadow on text, 0=none,1=shadow,2=outline
						0.04,//text size
						"PuristaMedium",//text font
						"center"//align text left, right, or center
					];
				} else {
					drawIcon3D
					[
						"",//Path to image displayed near text
						[0.01,0.45,1,1],//color of the text using RGBA
						_eyePos,//position of the text _x referring to the player in 'allUnits'
						1,//Width
						0,//height from position, below
						0,//angle
						"Detective",//text to be displayed
						2,//shadow on text, 0=none,1=shadow,2=outline
						0.05,//text size
						"PuristaMedium",//text font
						"center"//align text left, right, or center
					];
				};
			};
			if ((_x getVariable "role") == "Traitor" && (player getVariable "role") == "Traitor" && _x != player) then {
				if (_distance > 25) then {
					drawIcon3D
					[
						"",//Path to image displayed near text
						[0.75,0.21,0.21,1],//color of the text using RGBA
						_eyePos,//position of the text _x referring to the player in 'allUnits'
						1,//Width
						0,//height from position, below
						0,//angle
						"T",//text to be displayed
						2,//shadow on text, 0=none,1=shadow,2=outline
						0.04,//text size
						"PuristaMedium",//text font
						"center"//align text left, right, or center
					];
				} else {
					drawIcon3D
					[
						"",//Path to image displayed near text
						[0.75,0.21,0.21,1],//color of the text using RGBA
						_eyePos,//position of the text _x referring to the player in 'allUnits'
						1,//Width
						0,//height from position, below
						0,//angle
						"Traitor",//text to be displayed
						2,//shadow on text, 0=none,1=shadow,2=outline
						0.05,//text size
						"PuristaMedium",//text font
						"center"//align text left, right, or center
					];
				};
			};
			if ((_x getVariable "role") == "Traitor" && (player getVariable "role") == "Jester" && _x != player) then {
				if (_distance > 25) then {
					drawIcon3D
					[
						"",//Path to image displayed near text
						[0.4,0,0.5,1],//color of the text using RGBA
						_eyePos,//position of the text _x referring to the player in 'allUnits'
						1,//Width
						0,//height from position, below
						0,//angle
						"J",//text to be displayed
						2,//shadow on text, 0=none,1=shadow,2=outline
						0.04,//text size
						"PuristaMedium",//text font
						"center"//align text left, right, or center
					];
				} else {
					drawIcon3D
					[
						"",//Path to image displayed near text
						[0.4,0,0.5,1],//color of the text using RGBA
						_eyePos,//position of the text _x referring to the player in 'allUnits'
						1,//Width
						0,//height from position, below
						0,//angle
						"Jester",//text to be displayed
						2,//shadow on text, 0=none,1=shadow,2=outline
						0.05,//text size
						"PuristaMedium",//text font
						"center"//align text left, right, or center
					];
				};
			};
		};
	} forEach allUnits;
	if ((player getVariable "role") == "Detective") then {
		{
			_eyePos = getPosATL _x;
			_eyePos set [2, (_eyePos select 2) + 2];
			_role = (_x getVariable "role");
			_distance = player distance _x;
			_color = [0.12549,0.72941,0.09412,1];
			if(_role == "Traitor") then {
				_color = [0.75,0.21,0.21,1];
			};
			if(_role == "Detective") then {
				_color = [0.01,0.45,1,1];
			};
			if(_role == "Jester") then {
				_color = [0.4,0,0.5,1];
			};
			if(_distance < 5) then {
				drawIcon3D
				[
					"",//Path to image displayed near text
					_color,//color of the text using RGBA
					_eyePos,//position of the text _x referring to the player in 'allUnits'
					1,//Width
					0,//height from position, below
					0,//angle
					_role,//text to be displayed
					2,//shadow on text, 0=none,1=shadow,2=outline
					0.05,//text size
					"PuristaMedium",//text font
					"center"//align text left, right, or center
				];
			};
		} forEach allDeadMen;
	};
	if((player getVariable "role") == "Detective") then {
		{
			if (_x getVariable "tested") then {
				_eyePos = getPosATL _x;
				_eyePos set [2, (_eyePos select 2) + 2];
				_role = (_x getVariable "role");
				_distance = player distance _x;
				_color = [0.12549,0.72941,0.09412,1];
				if(_role == "Traitor") then {
					_color = [0.75,0.21,0.21,1];
				};
				if(_role == "Detective") then {
					_color = [0.01,0.45,1,1];
				};
				if(_role == "Jester") then {
				_color = [0.4,0,0.5,1];
				};
				if (_distance > 25) then {
					drawIcon3D
					[
						"",//Path to image displayed near text
						_color,//color of the text using RGBA
						_eyePos,//position of the text _x referring to the player in 'allUnits'
						1,//Width
						0,//height from position, below
						0,//angle
						_role select [0,1],//text to be displayed
						2,//shadow on text, 0=none,1=shadow,2=outline
						0.04,//text size
						"PuristaMedium",//text font
						"center"//align text left, right, or center
					];
				} else {
					drawIcon3D
					[
						"",//Path to image displayed near text
						_color,//color of the text using RGBA
						_eyePos,//position of the text _x referring to the player in 'allUnits'
						1,//Width
						0,//height from position, below
						0,//angle
						_role,//text to be displayed
						2,//shadow on text, 0=none,1=shadow,2=outline
						0.05,//text size
						"PuristaMedium",//text font
						"center"//align text left, right, or center
					];
				};
			};
		} forEach (allUnits + allDeadMen);
	};
}];