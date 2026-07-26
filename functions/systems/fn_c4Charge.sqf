//////////////////////////////////////////////////////////////////
// Waldo_fnc_c4Charge
// SERVER: spawns a traitor's timed explosive charge and runs its lifecycle.
// A visible object is placed; every machine gets a "Defuse" action on it (for
// anyone but the planter, within 3m). After the fuse it detonates unless it was
// defused first.
//
// params: [_owner, _pos]
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};
params ["_owner", "_pos"];

private _charge = createVehicle ["Land_Suitcase_F", _pos, [], 0, "CAN_COLLIDE"];
_charge setVariable ["Waldo_c4Owner",   _owner, true];
_charge setVariable ["Waldo_c4Defused", false,  true];
_charge allowDamage false;

// Defuse action, broadcast to everyone. Condition: the actor is not the planter
// and the charge is still armed. hideOnUse removes it after a successful defuse.
[_charge, [
	"<t color='#ff3333'>Defuse Charge</t>",
	{ (_this select 0) setVariable ["Waldo_c4Defused", true, true]; },
	nil, 6, true, true, "",
	"_this != (_target getVariable ['Waldo_c4Owner', objNull]) && {!(_target getVariable ['Waldo_c4Defused', false])}",
	3
]] remoteExec ["addAction", 0, _charge];

[_charge] spawn {
	params ["_charge"];
	private _boomAt = time + 15;
	while { time < _boomAt && {!isNull _charge} && {!(_charge getVariable ["Waldo_c4Defused", false])} } do {
		sleep 0.5;
	};
	if (isNull _charge) exitWith {};

	if (_charge getVariable ["Waldo_c4Defused", false]) exitWith {
		["A charge was defused."] remoteExec ["systemChat", 0];
		deleteVehicle _charge;
	};

	private _p = getPosATL _charge;
	deleteVehicle _charge;
	createVehicle ["Bo_Mk82", _p, [], 0, "NONE"];   // same blast the suicide bomb uses
};
