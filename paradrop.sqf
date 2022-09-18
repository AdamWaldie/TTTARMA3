setWind [0, 0, true];
_loadouts = airdropLoadouts;
_loadoutsLimit = airdropLoadoutsAmount;

_center = missionNamespace getVariable "mapPos";
_distance = (missionNamespace getVariable "mapRadius") * 0.9;
_parachute = createVehicle ["B_Parachute_02_F", [(_center select 0) - (_distance / 2) +random(_distance),(_center select 1) - (_distance / 2) +random(_distance),250], [], 0, 'FLY'];
_crate = createVehicle ["B_supplyCrate_F", position _parachute, [], 0, 'NONE'];
clearItemCargoGlobal _crate;
clearMagazineCargoGlobal _crate;
clearWeaponCargoGlobal _crate;
clearBackpackCargoGlobal _crate;

for "_i" from 1 to _loadoutsLimit do {
	_loadout = selectRandom _loadouts;
	if((_loadout select 0) == "weapon") then {
		_crate addWeaponCargoGlobal [(_loadout select 1), 1];
		for "_i" from 0 to (count (_loadout select 2) - 1) step 2 do {
			_crate addMagazineCargoGlobal [(_loadout select 2 select _i), (_loadout select 2 select (_i+1))];
		};
		{
			_crate addItemCargoGlobal [_x, 1];
		} forEach (_loadout select 3);
	};
};
_crate attachTo [_parachute, [0, 0, 1]];
_crate allowdamage false;
sleep 10;
_smoke = "SmokeShellOrange" createVehicle [0,0,0];
_smoke attachTo [_crate, [0, 0, 0]];
sleep 50;
detach _crate;
deleteVehicle _parachute;