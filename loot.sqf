if (isServer) then {
	_pos = missionNamespace getVariable "mapPos";
	_distance = missionNamespace getVariable "mapRadius";
	_weapons = lootPriWeapons + lootSecWeapons + lootSecWeapons;
	_houseList = nearestTerrainObjects [_pos, ["Building","House"],_distance];
	{
		_lootPos = [_x] call BIS_fnc_buildingPositions;
		_actualPos = [];
		if (count _lootPos != 0) then {
			for "_y" from 0 to (random(4) + 1) do {
				_loot = selectRandom _lootPos;
				if((_actualPos find _loot) == -1) then {
					_actualPos = _actualPos + [_loot];
				};
			};
			if(count _actualPos != 0) then {
				{
					_loot = "groundweaponholder" createVehicle _x;
					_loot setPos _x;
					_weapon = selectRandom _weapons;
					_ammo = false;
					while {!_ammo} do {
						_magazines = getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines");
						_magazineClass = selectRandom(_magazines);
						if (lootMaxBullets >= (getNumber(configFile >> "CfgMagazines" >> _magazineClass >> "count")) && !(["blank",(getText(configFile >> "CfgMagazines" >> _magazineClass >> "displayName"))] call BIS_fnc_inString)) then {
							_loot addWeaponCargoGlobal [_weapon,1];
							_loot addMagazineCargoGlobal [_magazineClass, random(3)+1];
							_ammo = true;
						};
					};
					_type = (selectRandom ["MuzzleSlot","CowsSlot","PointerSlot","UnderBarrelSlot"]);
					_attachment = selectRandom (getArray (configFile >> "CfgWeapons" >> _weapon >> "WeaponSlotsInfo" >> _type >> "compatibleitems"));
					if(floor (random(10)) < 8 && !(isNil "_attachment")) then {
						if ((lootAttachments find _attachment) == -1) then {
							_loot addItemCargoGlobal [_attachment, 1];
						};
					};
					{
						_x addCuratorEditableObjects [[_loot],true];
					} forEach allCurators;
				} forEach _actualPos;
			};
		};
	} forEach _houseList;
};