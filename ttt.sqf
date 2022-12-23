if (isServer) then {
	// Establish game setup
	missionNamespace setVariable ["mapDone",false,true];
	missionNamespace setVariable ["gameOn",false,true];
	_developerMode = false;
	_temp = true;

	/*
	
	Arena & Game Config
	
	*/


	//Locate Random Arena based on map defined locales
	_towns = nearestLocations [[0,0,0], ["NameVillage","NameCity","NameCityCapital"], 50000];
	_randomTown = selectRandom _towns;
	missionNamespace setVariable ["mapPos",getPos (nearestBuilding (locationPosition _randomTown)),true];
	while {_temp} do {
		_pos = [nil, ["water"]] call BIS_fnc_randomPos;
		_distance = 50 + ((count allUnits) * 7.5);
		// Get Loot Positions for population
		if (count (nearestTerrainObjects [_pos, ["House"], _distance]) > 5 + (count allUnits)) then {
			_c = 0;
			{
				_lootPos = [_x] call BIS_fnc_buildingPositions;
				if (count _lootPos != 0) then {
					_c = _c + 1;
				};
			} forEach (nearestTerrainObjects [_pos, ["Building","House"], _distance]);
			if (_c >= (count allUnits)) then {
				_pos = _pos findEmptyPosition [0,15];
				//Assign Arena and radius for enclosure
				missionNamespace setVariable ["mapPos",_pos,true];
				missionNamespace setVariable ["mapRadius",_distance,true];
				_temp = false;
			};
		};
	};



	//Set scalable Arena based on players present
	missionNamespace setVariable ["mapRadius",50 + ((count allUnits) * 7.5),true];
	//Random Enviroment Setup
	setDate [2022, 9, 18, random(timeTo-timeFrom-1)+timeFrom, random(60)];
	setWind [0, 0, true];
	0 setOvercast random(1);
	if(floor (random(100)) < chanceRain && allowRain) then {
		_rain =  random(1);
		0 setOvercast _rain;
		0 setRain _rain;
	};
	if(floor (random(100)) < chanceFog && allowFog) then {
		_fog = random(0.75);
		0 setFog _fog;
	};
	forceWeatherChange;


	//Loot Population 
	_center = "groundweaponholder" createVehicle (missionNamespace getVariable "mapPos");
	_center setPos (missionNamespace getVariable "mapPos");
	_pos = getPosWorld _center;
	_distance = missionNamespace getVariable "mapRadius";
	execVM "loot.sqf";
	
	// Arena Construction
	_higher = false;
	_height = 0;
	while {!_higher} do {
		_higher = true;
		for "_x" from 0 to 100 do {
			_tempPos = missionNamespace getVariable "mapPos";
			_i = _x * 3.6;
			_low = "groundweaponholder" createVehicle (missionNamespace getVariable "mapPos");
			_low setPos [_distance*cos(_i) + (_tempPos select 0),_distance*sin(_i) + (_tempPos select 1),(_tempPos select 2)];
			_tempPos = getPosWorld _low;
			if (_tempPos select 2 > (_pos select 2) + _height * 9) then {
				_height = _height + 1;
				_higher = false;
			};
			deleteVehicle _low;
		};
	};
	// THE DOME
	_height = _height + 6;
	_c = 0;
	for "_x" from 0 to 100 do {
		_tempPos = missionNamespace getVariable "mapPos";
		_i = _x * 3.6;
		_low = "groundweaponholder" createVehicle (missionNamespace getVariable "mapPos");
		_low setPos [_distance*cos(_i) + (_tempPos select 0),_distance*sin(_i) + (_tempPos select 1),(_tempPos select 2)];
		_tempPos = getPosWorld _low;
		for "_u" from 0 to _height do {
			if ((_tempPos select 2) - 9 < (_pos select 2) + (9 * _u)-45) then {
				_wall = "Land_VR_Block_04_F" createVehicle [_distance*cos(_i) + (_pos select 0),_distance*sin(_i) + (_pos select 1),(_pos select 2)];
				_wall setPosWorld [_distance*cos(_i) + (_pos select 0),_distance*sin(_i) + (_pos select 1),(_pos select 2) + (9 * _u)-45];
				_wall setDir -_i;
				_c = _c + 1;
			};
		};
		deleteVehicle _low;
	};
	diag_log ("Height: " + str(_height));
	diag_log ("Placed: " + str(_c) + " Walls");
	sleep 2.5;


	//GUI for setup
	for "_i" from 0 to roundWarmupLength-1 do {
		{
			_text = "<t align='center' size='1.5'><t color='#ffbb00' shadow='1'>Selecting Roles:</t><br />"+str(-(_i-roundWarmupLength))+"</t>";
			(parseText _text) remoteExec ["hint", _x];
		} forEach allUnits;
		missionNamespace setVariable ["mapDone",true,true];
		sleep 1;
	};


	/*
	
	Round Setup
	
	*/
	
	_detectives = [];
	_jesters = [];

	//Traitor Chance Calc For round
	_TraitorPercentageChance = random [TraitorPercentageChanceLowerBound,((TraitorPercentageChanceLowerBound+TraitorPercentageChanceHigherBound)/2),TraitorPercentageChanceHigherBound];

	//Traitor CFG
	_traitorsAmount = round ((count allUnits) * _TraitorPercentageChance);
	if(_traitorsAmount <= 0) then {
		_traitorsAmount = 1;
	};
	_traitors = [];
	_searchTraitors = true;
	while {_searchTraitors} do {
		_traitor = selectRandom allUnits;
		if((_traitors find _traitor) == -1) then {
			_traitors append [_traitor];
			
			if (count _traitors == _traitorsAmount) then {
				_searchTraitors = false;
			};
		};
	};

	missionNamespace setvariable ["TraitorList",_traitors,true];

	//Innocents & Traitor Assignment
	{
		if(!isPlayer _x) then {
			_x setPos (missionNamespace getVariable "mapPos");
			sleep 0.25;
		};
		_x setVariable ["role","Innocent",true];
		if((_traitors find _x) != -1) then {
			_x setVariable ["role","Traitor",true];
			_x setVariable ["points",1,true];
		};
	} forEach allUnits;

	// Detective Assignment (> 5 players required)
	private "_detective";
	if((count allUnits) >= 5) then {
		_searchDetective = true;
		while {_searchDetective} do {
			_detective = selectRandom allPlayers;
			if((_traitors find _detective) == -1) then {
				_uniformItems = uniformItems _detective;
				_vestItems = vestItems _detective;
				_detective forceAddUniform (detectiveLoadout select 0);
				_detective addVest (detectiveLoadout select 1);
				_detective addHeadgear (detectiveLoadout select 2);
				if ((detectiveLoadout select 3 select 0) != "") then {
					{_detective removeMagazine _x} forEach primaryWeaponMagazine _detective;
					_detective removeWeaponGlobal (primaryWeapon _detective);
					_detective addWeaponGlobal (detectiveLoadout select 3 select 0);
					_detective addPrimaryWeaponItem (detectiveLoadout select 3 select 1);
					for "_i" from 1 to ((detectiveLoadout select 3 select 2)-1) do {_detective addItem (detectiveLoadout select 3 select 1);};
				};
				if ((detectiveLoadout select 4 select 0) != "") then {
					{_detective removeMagazine _x} forEach handgunMagazine _detective;
					_detective removeWeaponGlobal (handgunWeapon _detective);
					_detective addWeaponGlobal (detectiveLoadout select 4 select 0);
					_detective addHandgunItem (detectiveLoadout select 4 select 1);
					for "_i" from 1 to ((detectiveLoadout select 4 select 2)-1) do {_detective addItem (detectiveLoadout select 4 select 1);};
				};
				_detective setVariable ["role","Detective",true];
				_detective setVariable ["points",1,true];
				{
					_detective addItemToUniform _x;
				}forEach _uniformItems;
				{
					_detective addItemToVest _x;
				}forEach _vestItems;
				_searchDetective = false;
				_detectives append [_detective];
			};
		};
		["There Is A Detective This Round"] remoteExec ["systemChat",-2];
	};

	missionNamespace setvariable ["DetectiveList",_detectives,true];


	// Jester Assignment > 6 players + Jester Chance + Toggled On
	if (JesterEnabled) then {
		_JesterChanceNumber = round(random [0,50,100]);
		if (_JesterChanceNumber <= (100*JesterPercentagechance)) then {
			private "_Jester";
			if((count allUnits) >= 6) then {
				_searchJester = true;
				while {_searchJester} do {
					_Jester = selectRandom allPlayers;
					if((_traitors find _Jester) == -1) then {
						_Jester setVariable ["role","Jester",true];
						_Jester addEventHandler["Fired", {deletevehicle (_this select 6)}];
						_searchJester = false;
						_jesters append [_Jester];
					};
				};
				["There Is A Jester This Round"] remoteExec ["systemChat",-2];
				missionNamespace setvariable ["JesterList",_jesters,true];
			};
		};
	};

	sleep 0.1;

	/*

	ROUND LIVE

	*/

	missionNamespace setVariable ["gameOn",true,true];
	//Round timer Dynamic
	_starttime = (round(count allUnits * roundPlayerLength)+roundBaseLength);
	missionNamespace setVariable ["timelimit",_starttime + roundTraitorLength,true];
	_gameOn = true;
	//Paradrop timer
	_paradropWait = round(random(airdropRandomTimer)+airdropBaseTimer);
	_paradropTimer = 0;
	_timelimit = missionNamespace getVariable "timelimit";
	_timer = 0;


	//Main game Loop
	while {_gameOn} do {
		//Timer
		_civilint = -(_timer - _starttime);
		_civiltimer = str(floor(_civilint/60)) + ":" + str(_civilint%60);
		_traitortimer = str(floor(-(_timer - _timelimit)/60)) + ":" + str(-(_timer - _timelimit)%60);
		if(_civilint%60 <= 9) then {
			_timerarray = _civiltimer splitString ":";
			_civiltimer = (_timerarray select 0) + ":0" + (_timerarray select 1);
		};
		if(-(_timer - _timelimit)%60 <= 9) then {
			_timerarray = _traitortimer splitString ":";
			_traitortimer = (_timerarray select 0) + ":0" + (_timerarray select 1);
		};
		if(_timer > _starttime) then {
			_civiltimer = "Overtime";
		};
		//Role & Hint UI
		{
			_role = (_x getVariable "role");
			_color = '#20ba18';
			if(_role == "Traitor") then {
				_color = "#d11b1b";
			};
			if(_role == "Detective") then {
				_color = "#326ba8";
			};
			//_text = "<t align='center' size='1.5'><t color='"+_color+"' shadow='1'>Role:</t><br />"+_role+"</t><br /><br /><t align='center' size='1.5'><t color='#ffbb00' shadow='1'>Timer:</t><br />"+_civiltimer+"</t>";
			_text = "<t align='center' size='1.5'><t color='#ffbb00' shadow='1'>Round Timer:</t><br />"+_civiltimer+"</t>";
			if(_role == "Detective") then {
				_text = _text + "<br /><br /><t align='center' size='0.8'><t shadow='1'>Press 'B' to open BuyMenu</t>";
			};
			if((_traitors find _x) != -1) then {
				//_text = "<t align='center' size='1.5'><t color='"+_color+"' shadow='1'>Role:</t><br />"+_role+"</t><br /><br /><t align='center' size='1.5'><t color='#ffbb00' shadow='1'>Timer:</t><br />"+_traitortimer+" ("+_civiltimer+")</t><br /><br /><t align='center' size='0.8'><t shadow='1'>Press 'B' to open BuyMenu</t>";
				_text = "<t align='center' size='1.5'><t color='#ffbb00' shadow='1'>Round Timer:</t><br />"+_traitortimer+" ("+_civiltimer+")</t><br /><br /><t align='center' size='0.8'><t shadow='1'>Press 'B' to open BuyMenu</t>";
			};
			(parseText _text) remoteExec ["hintsilent", _x];
		} forEach allPlayers;

		//paradrop Loop
		if (_paradropTimer + 1 == _paradropWait && airdrop) then {
			[] execVM "paradrop.sqf";
			_paradropWait = round(random(airdropRandomTimer)+airdropBaseTimer);
			_paradropTimer = 0; 
		};

		//Round Win Conditions
		_JesterWin = false;
		{
			if(!alive _x) then {
				if (missionNamespace getVariable "JESTERCLEANKILL") then {
					_JesterWin = true;
				};
			};
		} forEach _jesters;
		_innoWin = true;
		{
			if(alive _x) then {
				_innoWin = false;
			};
		} forEach _traitors;
		_traitorWin = true;
		{
			if(alive _x && (_traitors find _x) == -1) then {
				_traitorWin = false;
			};
		} forEach allPlayers;
		if(_traitorWin && !_developerMode) exitWith {
			"END2" call BIS_fnc_endMissionServer;
			_gameOn = false;
		};
		if(_innoWin) exitWith {
			"END1" call BIS_fnc_endMissionServer;
			_gameOn = false;
		};
		if(_timer == _timelimit) exitWith {
			"END3" call BIS_fnc_endMissionServer;
			_gameOn = false;
		};
		if(_JesterWin) exitWith {
			"END4" call BIS_fnc_endMissionServer;
			_gameOn = false;
		};
		sleep 1;
		_timer = _timer + 1;
		_paradropTimer = _paradropTimer + 1;
		_timelimit = missionNamespace getVariable "timelimit";
	};
};