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
// The charge carries the planter's DNA - a detective can scan it (before it
// blows, or during the window after it is defused) to track the traitor.
_charge setVariable ["Waldo_killerDNA",     _owner, true];
_charge setVariable ["Waldo_killerDNATime", time,   true];
_charge allowDamage false;
[_charge, _owner] call Waldo_fnc_dnaContaminate;

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
		// Leave the defused charge (with its DNA) around briefly for forensics.
		[_charge] spawn { params ["_c"]; sleep 30; if (!isNull _c) then { deleteVehicle _c }; };
	};

	private _p = getPosATL _charge;
	deleteVehicle _charge;
	// DemoCharge_Remote_Ammo_Scripted, not Bo_Mk82 (a full 500lb aerial bomb) -
	// this is a planted demolition charge, not an airstrike, and Bo_Mk82's stock
	// blast radius was leveling far more than the room it was placed in. Must be
	// the "_Scripted" variant and not plain DemoCharge_Remote_Ammo: the
	// non-scripted ammo is a real remote charge that just sits armed waiting for
	// a detonation signal, so createVehicle alone never makes it go off (unlike
	// a bomb, which detonates on its own contact fuze).
	private _bomb = createVehicle ["DemoCharge_Remote_Ammo_Scripted", _p, [], 0, "NONE"];   // same blast the suicide bomb uses
	// A createVehicle'd bomb has no shooter by default, so anyone it kills would
	// resolve to a null culprit in Waldo_fnc_onKilled - no karma penalty for
	// blowing up a teammate, no DNA on the corpse, no round-kill credit. Tag the
	// planter as both shooter and instigator so C4 kills attribute exactly like
	// a gunshot would.
	_bomb setShotParents [_owner, _owner];
	// The scripted charge only detonates when damaged - this is what actually
	// triggers the blast.
	_bomb setDamage 1;
};
