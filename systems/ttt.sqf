////////////////////////////////////////////////////////////
// TTT ROUND SCRIPT
// Author: Waldo
// Purpose: Main flow logic for Trouble In Terrorist Town in Arma 3
// Note: This script controls arena setup,
//       role assignment, timers, environment, and round win logic.
// Secondary Note: Yes, this script was made in one afternoon, while intoxicated, and is.....alarming to follow. I apologise.
//
////////////////////////////////////////////////////////////

if (isServer) then {

	////////////////////////////////////////////////////////////
	// SECTION 1: Game Initialisation
	// Sets developer mode, flags, and prep variables
	////////////////////////////////////////////////////////////

	missionNamespace setVariable ["mapDone",false,true];
	missionNamespace setVariable ["gameOn",false,true];
	_temp = true;

	////////////////////////////////////////////////////////////
	// SECTION 2: Arena Selection
	// Picks a random town and finds a nearby suitable location
	// - Must not be over water
	// - Must have enough lootable buildings for the number of players
	// Result is stored in mapPos + mapRadius
	////////////////////////////////////////////////////////////

	_towns = nearestLocations [[0,0,0], ["NameVillage","NameCity","NameCityCapital"], 50000];
	_randomTown = selectRandom _towns;
	missionNamespace setVariable ["mapPos",getPos (nearestBuilding (locationPosition _randomTown)),true];

	while {_temp} do {
		_pos = [nil, ["water"]] call BIS_fnc_randomPos;
		_distance = 50 + ((count allUnits) * 7.5);

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
				missionNamespace setVariable ["mapPos",_pos,true];
				missionNamespace setVariable ["mapRadius",_distance,true];
				_temp = false;
			};
		};
	};

	////////////////////////////////////////////////////////////
	// SECTION 3: Environment Setup
	// Sets random time, overcast, rain and fog based on params
	////////////////////////////////////////////////////////////

	missionNamespace setVariable ["mapRadius",50 + ((count allUnits) * 7.5),true];

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

	////////////////////////////////////////////////////////////
	// SECTION 4: Loot Anchor Placement
	// Spawns a central object to anchor the loot system
	// Stores its world position and triggers loot population script
	////////////////////////////////////////////////////////////

	_center = "groundweaponholder" createVehicle (missionNamespace getVariable "mapPos");
	_center setPos (missionNamespace getVariable "mapPos");
	_pos = getPosWorld _center;
	_distance = missionNamespace getVariable "mapRadius";

	execVM "systems\loot.sqf";

	////////////////////////////////////////////////////////////
	// SECTION 5: Arena Construction (Elevation Scanning)
	// Determines terrain elevation difference and calculates
	// wall height required to contain players
	////////////////////////////////////////////////////////////

	_higher = false;
	_height = 0;

	while {!_higher} do {
		_higher = true;
		for "_x" from 0 to 100 do {
			_tempPos = missionNamespace getVariable "mapPos";
			_i = _x * 3.6;
			_low = "groundweaponholder" createVehicle (missionNamespace getVariable "mapPos");
			_low setPos [
				_distance*cos(_i) + (_tempPos select 0),
				_distance*sin(_i) + (_tempPos select 1),
				(_tempPos select 2)
			];
			_tempPos = getPosWorld _low;

			if (_tempPos select 2 > (_pos select 2) + _height * 9) then {
				_height = _height + 1;
				_higher = false;
			};

			deleteVehicle _low;
		};
	};

	////////////////////////////////////////////////////////////
	// SECTION 6: Dome Construction
	// Dynamically calculates required wall segments to prevent gaps
	// and builds vertical layers based on height scan
	////////////////////////////////////////////////////////////

	_height = _height + 6;
	_c = 0;

	// Calculate number of horizontal wall segments
	_wallWidth = 4; // Estimated physical width of Land_VR_Block_04_F
	_circumference = 2 * pi * _distance;
	_segmentCount = ceil (_circumference / _wallWidth);

	for "_x" from 0 to (_segmentCount - 1) do {
		_tempPos = missionNamespace getVariable "mapPos";
		_i = (_x / _segmentCount) * 360;

		// Probe surface elevation at this point
		_low = "groundweaponholder" createVehicle _tempPos;
		_low setPos [
			_distance * cos(_i) + (_tempPos select 0),
			_distance * sin(_i) + (_tempPos select 1),
			_tempPos select 2
		];
		_tempPos = getPosWorld _low;

		// Build vertical column of walls up to height
		for "_u" from 0 to _height do {
			if ((_tempPos select 2) - 9 < (_pos select 2) + (9 * _u) - 45) then {
				_wall = "Land_VR_Block_04_F" createVehicle [
					_distance * cos(_i) + (_pos select 0),
					_distance * sin(_i) + (_pos select 1),
					(_pos select 2)
				];
				_wall setPosWorld [
					_distance * cos(_i) + (_pos select 0),
					_distance * sin(_i) + (_pos select 1),
					(_pos select 2) + (9 * _u) - 45
				];
				_wall setDir -_i;
				_c = _c + 1;
			};
		};

		deleteVehicle _low;
	};

	diag_log ("Height: " + str(_height));
	diag_log ("Placed: " + str(_c) + " Walls");


	sleep 2.5;
	////////////////////////////////////////////////////////////
	// SECTION 7: Round Warmup Countdown
	// Displays a countdown for all players while roles are being selected
	// Uses remoteExec to broadcast a hint UI message to each player
	////////////////////////////////////////////////////////////

	for "_i" from 0 to roundWarmupLength - 1 do {
		{
			_text = "<t align='center' size='1.5'><t color='#ffbb00' shadow='1'>Selecting Roles:</t><br />" 
			        + str(-(_i - roundWarmupLength)) + "</t>";
			(parseText _text) remoteExec ["hint", _x];
		} forEach allUnits;

		missionNamespace setVariable ["mapDone", true, true];
		sleep 1;
	};

	////////////////////////////////////////////////////////////
	// SECTION 8: Round Setup
	// Assigns roles (Innocents, Traitors, Detectives, Jesters)
	// Applies loadouts, tracks lists, and handles role logic
	////////////////////////////////////////////////////////////

	_detectives = [];
	_jesters = [];

	// --- TRAITOR SELECTION ---
	// Random chance bounded by configured min and max
	_TraitorPercentageChance = random [
		TraitorPercentageChanceLowerBound,
		((TraitorPercentageChanceLowerBound + TraitorPercentageChanceHigherBound) / 2),
		TraitorPercentageChanceHigherBound
	];

	_traitorsAmount = round ((count allUnits) * _TraitorPercentageChance);
	if (_traitorsAmount <= 0) then {
		_traitorsAmount = 1;
	};

	_traitors = [];
	_searchTraitors = true;

	while {_searchTraitors} do {
		_traitor = selectRandom allUnits;
		if ((_traitors find _traitor) == -1) then {
			_traitors append [_traitor];

			if (count _traitors == _traitorsAmount) then {
				_searchTraitors = false;
			};
		};
	};

	missionNamespace setVariable ["TraitorList", _traitors, true];

	// --- ROLE ASSIGNMENT ---
	// Default everyone to Innocent
	// Assign Traitors with points
	{
		if (!isPlayer _x) then {
			_x setPos (missionNamespace getVariable "mapPos");
			sleep 0.25;
		};

		_x setVariable ["role", "Innocent", true];

		if ((_traitors find _x) != -1) then {
			_x setVariable ["role", "Traitor", true];
			_x setVariable ["points", 1, true];
		};
	} forEach allUnits;

	////////////////////////////////////////////////////////////
	// SECTION 9: Detective Assignment
	// One is selected if player count ≥ 5 and not a traitor
	// Assigns special loadout from config and re-applies inventory
	////////////////////////////////////////////////////////////

	private "_detective";
	if ((count allUnits) >= 5) then {
		_searchDetective = true;

		while {_searchDetective} do {
			_detective = selectRandom allPlayers;

			if ((_traitors find _detective) == -1) then {
				_uniformItems = uniformItems _detective;
				_vestItems = vestItems _detective;

				_detective forceAddUniform (detectiveLoadout select 0);
				_detective addVest (detectiveLoadout select 1);
				_detective addHeadgear (detectiveLoadout select 2);

				// Primary weapon loadout
				if ((detectiveLoadout select 3 select 0) != "") then {
					{ _detective removeMagazine _x } forEach primaryWeaponMagazine _detective;
					_detective removeWeaponGlobal (primaryWeapon _detective);
					_detective addWeaponGlobal (detectiveLoadout select 3 select 0);
					_detective addPrimaryWeaponItem (detectiveLoadout select 3 select 1);
					for "_i" from 1 to ((detectiveLoadout select 3 select 2) - 1) do {
						_detective addItem (detectiveLoadout select 3 select 1);
					};
				};

				// Sidearm
				if ((detectiveLoadout select 4 select 0) != "") then {
					{ _detective removeMagazine _x } forEach handgunMagazine _detective;
					_detective removeWeaponGlobal (handgunWeapon _detective);
					_detective addWeaponGlobal (detectiveLoadout select 4 select 0);
					_detective addHandgunItem (detectiveLoadout select 4 select 1);
					for "_i" from 1 to ((detectiveLoadout select 4 select 2) - 1) do {
						_detective addItem (detectiveLoadout select 4 select 1);
					};
				};

				// Finalize
				_detective setVariable ["role", "Detective", true];
				_detective setVariable ["points", 1, true];

				{ _detective addItemToUniform _x } forEach _uniformItems;
				{ _detective addItemToVest _x } forEach _vestItems;

				_searchDetective = false;
				_detectives append [_detective];
			};
		};

		["There Is A Detective This Round"] remoteExec ["systemChat", -2];
	};

	missionNamespace setVariable ["DetectiveList", _detectives, true];

	////////////////////////////////////////////////////////////
	// SECTION 10: Jester Assignment
	// Chance-based role added if enough players and enabled
	// Only one may exist, cannot be a traitor
	////////////////////////////////////////////////////////////

	if (JesterEnabled) then {
		_JesterChanceNumber = round(random [0,50,100]);

		if (_JesterChanceNumber <= (JesterPercentagechance)) then {
			private "_Jester";

			if ((count allUnits) >= 5) then {
				_searchJester = true;

				while {_searchJester} do {
					_Jester = selectRandom allPlayers;

					if ((_traitors find _Jester) == -1 && (_detectives find _Jester) == -1) then {
						_Jester setVariable ["role", "Jester", true];
						// Jester cannot shoot
						_Jester addEventHandler ["Fired", { deletevehicle (_this select 6) }];
						_searchJester = false;
						_jesters append [_Jester];
					};
				};

				["There Is A Jester This Round"] remoteExec ["systemChat", -2];
				missionNamespace setVariable ["JesterList", _jesters, true];
			};
		};
	};

	sleep 0.1;

	////////////////////////////////////////////////////////////
	// SECTION 11: Round Activation
	// Flags the round as live and sets core round timers
	// Includes:
	// - Civilian time limit
	// - Traitor overtime limit
	// - Airdrop spawn timers
	////////////////////////////////////////////////////////////

	missionNamespace setVariable ["gameOn", true, true];

	// Time = base + per player
	_starttime = (round(count allUnits * roundPlayerLength) + roundBaseLength);
	missionNamespace setVariable ["timelimit", _starttime + roundTraitorLength, true];

	_gameOn = true;

	// Airdrop
	_paradropWait = round(random(airdropRandomTimer) + airdropBaseTimer);
	_paradropTimer = 0;

	// Timer state
	_timelimit = missionNamespace getVariable "timelimit";
	_timer = 0;

	////////////////////////////////////////////////////////////
	// SECTION 12: Main Game Loop
	// Executes once per second while round is active
	// Includes:
	// - Timer formatting
	// - HUD hints per player
	// - Airdrop events
	// - Win condition checks
	////////////////////////////////////////////////////////////

	while {_gameOn} do {

		////////////////////////////////////////////////////////////
		// Subsection: Round Timer Formatting
		// Calculates civil timer and traitor overtime countdown
		////////////////////////////////////////////////////////////

		_civilint = -(_timer - _starttime);
		_civiltimer = str(floor(_civilint / 60)) + ":" + str(_civilint % 60);
		_traitortimer = str(floor(-(_timer - _timelimit) / 60)) + ":" + str(-(_timer - _timelimit) % 60);

		// Pad single-digit seconds with leading 0
		if (_civilint % 60 <= 9) then {
			_timerarray = _civiltimer splitString ":";
			_civiltimer = (_timerarray select 0) + ":0" + (_timerarray select 1);
		};

		if (-(_timer - _timelimit) % 60 <= 9) then {
			_timerarray = _traitortimer splitString ":";
			_traitortimer = (_timerarray select 0) + ":0" + (_timerarray select 1);
		};

		// Show "Overtime" label
		if (_timer > _starttime) then {
			_civiltimer = "Overtime";
		};

		////////////////////////////////////////////////////////////
		// Subsection: HUD Rendering (Role & Timer Hint)
		// Displays different hint per player based on role
		////////////////////////////////////////////////////////////

		{
			_role = (_x getVariable "role");
			_color = "#20ba18"; // Default (Innocent) green

			if (_role == "Traitor") then { _color = "#d11b1b"; };
			if (_role == "Detective") then { _color = "#326ba8"; };

			_text = "<t align='center' size='1.5'><t color='#ffbb00' shadow='1'>Round Timer:</t><br />" + _civiltimer + "</t>";

			if (_role == "Detective") then {
				_text = _text + "<br /><br /><t align='center' size='0.8'><t shadow='1'>Press 'B' to open BuyMenu</t>";
			};

			if ((_traitors find _x) != -1) then {
				_text = "<t align='center' size='1.5'><t color='#ffbb00' shadow='1'>Round Timer:</t><br />"
				       + _traitortimer + " (" + _civiltimer + ")</t><br /><br /><t align='center' size='0.8'><t shadow='1'>Press 'B' to open BuyMenu</t>";
			};

			(parseText _text) remoteExec ["hintsilent", _x];
		} forEach allPlayers;

		////////////////////////////////////////////////////////////
		// Subsection: Airdrop Trigger
		// Executes airdrop script when timer hits threshold
		////////////////////////////////////////////////////////////

		if (_paradropTimer + 1 == _paradropWait && airdrop) then {
			[] execVM "systems\paradrop.sqf";
			_paradropWait = round(random(airdropRandomTimer) + airdropBaseTimer);
			_paradropTimer = 0; 
		};

		////////////////////////////////////////////////////////////
		// Subsection: Round Win Conditions
		// - Jester: Dies cleanly (if configured)
		// - Innocents: All traitors dead
		// - Traitors: All others dead (except Jester)
		// - Timer expiry
		////////////////////////////////////////////////////////////

		// --- Jester Win Check ---
		_JesterWin = false;
		{
			if (!alive _x) then {
				if (missionNamespace getVariable "JESTERCLEANKILL") then {
					_JesterWin = true;
				};
			};
		} forEach _jesters;

		// --- Innocents Win If All Traitors Dead ---
		_innoWin = true;
		{
			if (alive _x) then {
				_innoWin = false;
			};
		} forEach _traitors;

		// --- Traitors Win If All Others Dead ---
		_traitorWin = true;
		{
			if (alive _x && (_traitors find _x) == -1) then {
				_traitorWin = false;
			};
		} forEach allPlayers;

		////////////////////////////////////////////////////////////
		// Subsection: Win Triggers
		// Ends mission with correct ending depending on condition
		////////////////////////////////////////////////////////////

		if (_traitorWin && !TestingFlag) exitWith {
			"END2" call BIS_fnc_endMissionServer; // Traitors win
			_gameOn = false;
		};

		if (_innoWin) exitWith {
			"END1" call BIS_fnc_endMissionServer; // Innocents win
			_gameOn = false;
		};

		if (_timer == _timelimit) exitWith {
			"END3" call BIS_fnc_endMissionServer; // Time up
			_gameOn = false;
		};

		if (_JesterWin) exitWith {
			"END4" call BIS_fnc_endMissionServer; // Jester wins
			_gameOn = false;
		};

		////////////////////////////////////////////////////////////
		// Subsection: Loop Step
		// Increments round timer and airdrop timer
		////////////////////////////////////////////////////////////

		sleep 1;
		_timer = _timer + 1;
		_paradropTimer = _paradropTimer + 1;
		_timelimit = missionNamespace getVariable "timelimit";
	};

};
