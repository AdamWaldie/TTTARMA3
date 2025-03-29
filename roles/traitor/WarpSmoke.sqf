player addEventHandler ["Fired", {
        params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
        if (_ammo == "SmokeShellRed") then {
            [_unit, _weapon, _muzzle, _mode, _ammo, _magazine, _projectile, _gunner] spawn {
                params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
                _flare = "ACE_G_Chemlight_HiRed" createVehicle getPos _projectile;
                triggerAmmo _projectile;
                _flare attachTo [_projectile];
                triggerAmmo _flare;
                sleep 2;
                playSound3D [getMissionPath "audio\portalIn.ogg", _unit];
                _unit setPos getPos _projectile;
                playSound3D [getMissionPath "audio\portalOut.ogg", _unit];
                sleep 0.5;
                deleteVehicle _flare;
            };
        };
    }
];
//player setVariable ["powerup","WarpSmoke",false];
waituntil {!isnull (finddisplay 46)};
(findDisplay 46) displayRemoveAllEventHandlers "KeyDown";
_shop = findDisplay 46 displayAddEventHandler ["KeyDown", {_this select 1 execVM "systems\shops.sqf"}];