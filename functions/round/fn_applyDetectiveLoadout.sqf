//////////////////////////////////////////////////////////////////
// Waldo_fnc_applyDetectiveLoadout
// Runs on the DETECTIVE's own machine (remote-executed from assignRoles),
// because forceAddUniform/addVest/addHeadgear/etc. are local-effect commands
// and the loadout must exist where the unit is local. Reads the broadcast
// detectiveConfig (the modpack only defines the raw global on the server).
//
// detectiveConfig format:
//   ["Uniform","Vest","Headgear",
//    ["primaryWeapon","Magazine",Amount],
//    ["sideArm","Magazine",Amount]]   ("" = leave unchanged)
//
// params: [_unit]
//////////////////////////////////////////////////////////////////

params ["_det"];
if (isNull _det) exitWith {};

private _l = missionNamespace getVariable ["detectiveConfig", []];
if (_l isEqualTo []) exitWith {
	diag_log "[Waldo] applyDetectiveLoadout: detectiveConfig not available";
};

private _uniformItems = uniformItems _det;
private _vestItems = vestItems _det;

_det forceAddUniform (_l select 0);
_det addVest (_l select 1);
_det addHeadgear (_l select 2);

// Primary weapon
if ((_l select 3 select 0) != "") then {
	{ _det removeMagazine _x } forEach primaryWeaponMagazine _det;
	_det removeWeaponGlobal (primaryWeapon _det);
	_det addWeaponGlobal (_l select 3 select 0);
	_det addPrimaryWeaponItem (_l select 3 select 1);
	for "_i" from 1 to ((_l select 3 select 2) - 1) do { _det addItem (_l select 3 select 1); };
};

// Sidearm
if ((_l select 4 select 0) != "") then {
	{ _det removeMagazine _x } forEach handgunMagazine _det;
	_det removeWeaponGlobal (handgunWeapon _det);
	_det addWeaponGlobal (_l select 4 select 0);
	_det addHandgunItem (_l select 4 select 1);
	for "_i" from 1 to ((_l select 4 select 2) - 1) do { _det addItem (_l select 4 select 1); };
};

// Restore picked-up items
{ _det addItemToUniform _x } forEach _uniformItems;
{ _det addItemToVest _x } forEach _vestItems;
