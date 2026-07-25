//////////////////////////////////////////////////////////////////
// Waldo_fnc_spawnAirdrop
// SERVER: drops a parachuted supply crate at a random spot in the arena.
// Returns immediately; the smoke/detach timeline runs in its own thread so
// it never blocks the round loop.
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};
if (isNil "airdropLoadouts") exitWith {
	diag_log "[Waldo][server] spawnAirdrop: airdropLoadouts not defined";
};

setWind [0, 0, true];

private _loadouts = airdropLoadouts;
private _limit = missionNamespace getVariable ["airdropLoadoutsAmount", 1];
private _center = missionNamespace getVariable ["mapPos", [0,0,0]];
private _distance = (missionNamespace getVariable ["mapRadius", 50]) * 0.9;

private _dropPos = [
	(_center select 0) - (_distance / 2) + random _distance,
	(_center select 1) - (_distance / 2) + random _distance,
	250
];

private _parachute = createVehicle ["B_Parachute_02_F", _dropPos, [], 0, "FLY"];
private _crate = createVehicle ["B_supplyCrate_F", position _parachute, [], 0, "NONE"];
clearItemCargoGlobal _crate;
clearMagazineCargoGlobal _crate;
clearWeaponCargoGlobal _crate;
clearBackpackCargoGlobal _crate;

for "_i" from 1 to _limit do {
	private _loadout = selectRandom _loadouts;
	if ((_loadout select 0) == "weapon") then {
		_crate addWeaponCargoGlobal [(_loadout select 1), 1];
		for "_j" from 0 to (count (_loadout select 2) - 1) step 2 do {
			_crate addMagazineCargoGlobal [(_loadout select 2 select _j), (_loadout select 2 select (_j + 1))];
		};
		{ _crate addItemCargoGlobal [_x, 1]; } forEach (_loadout select 3);
	};
};

_crate attachTo [_parachute, [0, 0, 1]];
_crate allowDamage false;

[_parachute, _crate] spawn {
	params ["_parachute", "_crate"];
	sleep 10;
	private _smoke = "SmokeShellOrange" createVehicle [0, 0, 0];
	_smoke attachTo [_crate, [0, 0, 0]];
	sleep 50;
	detach _crate;
	deleteVehicle _parachute;
};
