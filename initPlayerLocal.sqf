sleep 1;

//Player Local Setup
if (missionNamespace getVariable "gameOn") then {
	player setDammage 1;
};

//Setup player for round
uniforms = missionNamespace getVariable "uniformsConfig";
headgears = missionNamespace getVariable "headgearsConfig";
vests = missionNamespace getVariable "vestsConfig";
_player = player;
_uid = getPlayerUID player; 
player setVariable ["tested",false,true];
player setVariable ["player",player,true];
_profilename = "player_"+str(_uid)+"_punish";
if (isNil {profileNamespace getVariable _profilename}) then
{
	profileNamespace setVariable [_profilename, false];
};
player forceAddUniform (selectRandom uniforms);
player addVest (selectRandom vests);
removeBackpack player;
if(floor (random(10)) < 6) then {
	player addHeadgear (selectRandom headgears);
};
player allowDamage false;

// Pregame UI
while {!(missionNamespace getVariable "mapDone")} do {
	_text = "<t align='center' size='1.0'><t color='#d11b1b' shadow='1'>Setting Up The Arena, Hold Tight!</t>";
	hintSilent (parseText _text); 
	sleep 0.25;
};

//ARENA READY 

//Obscure PEOPLE's Nametags
ACE_NO_RECOGNIZE = true; publicVariable "ACE_NO_RECOGNIZE";

// 3D Marker Draw
player execVM "icons.sqf";

// TP Player Into Arena
_center = missionNamespace getVariable "mapPos";
_distance = (missionNamespace getVariable "mapRadius") * 0.9;
player setPos _center;
_pos = [(_center select 0) - (_distance / 2) +random(_distance),(_center select 1) - (_distance / 2) +random(_distance),0];
_dir = _pos getDir _center;
_pos = _pos findEmptyPosition [0,25];
player setPos _pos;
player setDir _dir;
player allowDamage false;
removeBackpack player;


//TTT Title Screen
_missionTitle = getText (missionConfigFile >> "onLoadName");
_localeName = worldName;
_timeConfig = [dayTime, "ARRAY"] call BIS_fnc_timeToString; 
_time = (_timeConfig select 0) + (_timeConfig select 1) + ' hrs';
_date =  str (date select 2) + '/' + str (date select 1) + '/' + str (date select 0);
_missionTime = str (time/60);
_localePos = 'Grid ' + mapGridPosition player + ', ' + _localeName; 
_textColour = "'#770000'";
_text1 = str composeText ["<t align = 'center' shadow = '1' size = '1.0' font='PuristaBold' color=", _textColour, ">%1</t><br/>"];  
_text2 = "<t align = 'center' shadow = '1' size = '0.8' color='#808080'>%1</t><br/>";  
  
[  
    [  
        [_missionTitle, _text1],  
        [_localePos, _text2],
		[_date, "<t align = 'center' shadow = '1' size = '0.7' font='PuristaBold'>%1</t><br/>", 5],
		[_time, "<t align = 'center' shadow = '1' size = '0.6'>%1</t><br/>"]
    ]  
] spawn BIS_fnc_typeText;

//Sleep until game START
while {!(missionNamespace getVariable "gameOn")} do {
	sleep 0.25;
};

//ROUND STARTED

removeBackpack player;
player allowDamage true;

player execVM "data\TTTHud\init.sqf";

//ROUND Handle EV 
player addMPEventHandler ["MPKilled", {
	params ["_unit", "_killer", "_instigator", "_useEffects"];
	missionNamespace setVariable ["timelimit",(missionNamespace getVariable "timelimit")+(missionNamespace getVariable "roundDeadLength"),true];
	_guilty = true;
	if ((_unit getVariable "role") == "Traitor") then {
		_guilty = false;
		_detectives = missionNamespace getVariable "DetectiveList";
		{
			_x setVariable ["points",(_x getVariable "points") + 1,true];
		} forEach _detectives;
	};
	if ((_unit getVariable "role") == "Detective") then {
		_traitors = missionNamespace getVariable "TraitorList";
		{
			_x setVariable ["points",(_x getVariable "points") + 1,true];
		} forEach _traitors;
	};
	if ((_unit getVariable "role") == "Jester" && (_killer getVariable "role") == "Traitor") then {
		missionNamespace setVariable ["JESTERMURDEREDBYTRAITOR",true,true];

	};
	if ((_instigator getVariable "role") == "Traitor") then {
		_guilty = false;
	};
	if (_guilty && _unit != _instigator) then {
		_uid = getPlayerUID _instigator;
		_string = "player_"+str(_uid)+"_punish";
		profileNamespace setVariable [_string,true];
	};
	}
];


//ACE Uncon to Kill EV 
["ace_unconscious", {
params ["_unit", "_state"];
_unit setDamage 1;
}] call CBA_fnc_addEventHandler;