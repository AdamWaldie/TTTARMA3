//////////////////////////////////////////////////////////////////
// Waldo_fnc_warpSmoke
// CLIENT: adds a managed Fired handler so throwing a red smoke ("Teleport
// Grenade") warps the player to where it lands, with portal SFX.
// (Requires ACE for the chemlight effect, as in the original.)
//////////////////////////////////////////////////////////////////

private _old = player getVariable ["Waldo_warpEH", -1];
if (_old >= 0) then { player removeEventHandler ["Fired", _old]; };

private _eh = player addEventHandler ["Fired", {
	params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
	if (_ammo == "SmokeShellRed") then {
		[_unit, _projectile] spawn {
			params ["_unit", "_projectile"];
			private _flare = "ACE_G_Chemlight_HiRed" createVehicle getPos _projectile;
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
}];
player setVariable ["Waldo_warpEH", _eh];
