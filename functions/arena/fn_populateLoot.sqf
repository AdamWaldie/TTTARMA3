//////////////////////////////////////////////////////////////////
// Waldo_fnc_populateLoot
// SERVER: scatters weapons + ammo into building interiors across the arena.
// The old magazine picker used `while {!_ammo}` which could spin forever on
// a weapon whose magazines all exceed lootMaxBullets; here we iterate the
// magazine list once and simply skip a weapon with no valid magazine.
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

private _pos = missionNamespace getVariable ["mapPos", [0,0,0]];
private _distance = missionNamespace getVariable ["mapRadius", 50];
private _maxBullets = missionNamespace getVariable ["lootMaxBullets", 50];

private _pri = if (isNil "lootPriWeapons") then { [] } else { lootPriWeapons };
private _sec = if (isNil "lootSecWeapons") then { [] } else { lootSecWeapons };
private _blacklist = if (isNil "lootAttachments") then { [] } else { lootAttachments };
private _weapons = _pri + _sec + _sec;   // weight secondaries as in the original

if (_weapons isEqualTo []) exitWith {
	diag_log "[Waldo][server] populateLoot: no loot weapons configured";
};

{
	private _building = _x;
	private _lootPos = [_building] call BIS_fnc_buildingPositions;
	if (count _lootPos > 0) then {

		// pick a handful of distinct interior positions
		private _actual = [];
		for "_y" from 0 to (floor(random 4) + 1) do {
			private _p = selectRandom _lootPos;
			if !(_p in _actual) then { _actual pushBack _p; };
		};

		{
			private _holder = "groundweaponholder" createVehicle _x;
			_holder setPos _x;

			private _weapon = selectRandom _weapons;

			// choose a magazine within the ammo cap (findIf: first match, no infinite loop)
			private _mags = (getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines")) call BIS_fnc_arrayShuffle;
			private _chosenMag = "";
			private _mi = _mags findIf {
				private _cnt = getNumber (configFile >> "CfgMagazines" >> _x >> "count");
				private _nm = getText (configFile >> "CfgMagazines" >> _x >> "displayName");
				_cnt <= _maxBullets && {!(["blank", _nm] call BIS_fnc_inString)}
			};
			if (_mi > -1) then { _chosenMag = _mags select _mi; };

			if (_chosenMag != "") then {
				_holder addWeaponCargoGlobal [_weapon, 1];
				_holder addMagazineCargoGlobal [_chosenMag, floor(random 3) + 1];

				// optional attachment
				private _slot = selectRandom ["MuzzleSlot", "CowsSlot", "PointerSlot", "UnderBarrelSlot"];
				private _compat = getArray (configFile >> "CfgWeapons" >> _weapon >> "WeaponSlotsInfo" >> _slot >> "compatibleItems");
				if (count _compat > 0 && {random 10 < 8}) then {
					private _att = selectRandom _compat;
					if !(_att in _blacklist) then { _holder addItemCargoGlobal [_att, 1]; };
				};
			};

			{ _x addCuratorEditableObjects [[_holder], true]; } forEach allCurators;
		} forEach _actual;
	};
} forEach (nearestTerrainObjects [_pos, ["Building", "House"], _distance]);
