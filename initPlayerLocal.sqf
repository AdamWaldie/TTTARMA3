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
	_text = "<t align='center' size='1.0'><t color='#d11b1b' shadow='1'>Setting up the playarea!</t>";
	hintSilent (parseText _text);
	sleep 0.25;
};

//ARENA READY 

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

//Sleep until game START
while {!(missionNamespace getVariable "gameOn")} do {
	sleep 0.25;
};

//ROUND STARTED

removeBackpack player;
player allowDamage true;

//player execVM "data\TTTHud\init.sqf";

//ROUND Handle EV 
player addMPEventHandler ["MPKilled", {
	params ["_unit", "_killer", "_instigator", "_useEffects"];
	missionNamespace setVariable ["timelimit",(missionNamespace getVariable "timelimit")+(missionNamespace getVariable "roundDeadLength"),true];
	_guilty = true;
	if ((_unit getVariable "role") == "Traitor") then {
		_guilty = false;
	};
	if ((_instigator getVariable "role") == "Traitor") then {
		_guilty = false;
	};
	if (_guilty && _unit != _instigator) then {
		_uid = getPlayerUID _instigator;
		_string = "player_"+str(_uid)+"_punish";
		profileNamespace setVariable [_string,true];
	};
}];