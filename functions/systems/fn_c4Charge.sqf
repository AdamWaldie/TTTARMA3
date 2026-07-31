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

// Defuse action, broadcast to everyone. Condition matches Waldo_fnc_healthStation's
// own working pattern - "alive _this" only, nothing reading _target. This
// used to check "not the planter" and "not already defused" directly in
// the condition via _target getVariable [...], and the action never showed
// up at all (confirmed live, same failure as Waldo_fnc_fakeHealthStation's
// identical mistake - see the long comment there for why: _target is the
// crate itself, freshly createVehicle'd moments earlier in this very
// script, and a condition that throws resolving it is silently treated as
// false, not shown as an error). Both checks now live in the STATEMENT
// instead, which only ever runs after someone has already seen and clicked
// the action - hideOnUse still removes it after a successful defuse either
// way; this just stops a second, later click (or a planter's own click)
// from re-marking an already-defused charge.
[_charge, [
	"<t color='#ff3333'>Defuse Charge</t>",
	{
		params ["_target", "_caller"];
		if (_caller != (_target getVariable ["Waldo_c4Owner", objNull]) && {!(_target getVariable ["Waldo_c4Defused", false])}) then {
			_target setVariable ["Waldo_c4Defused", true, true];
		};
	},
	nil, 6, true, true, "",
	"alive _this",
	3
]] remoteExec ["addAction", 0, _charge];

[_charge, _owner] spawn {
	params ["_charge", "_owner"];
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
	// Sh_82_HE (an 82mm mortar HE shell), not Bo_Mk82 (a full 500lb aerial
	// bomb - levelled far more than the room this was placed in) and not
	// plain DemoCharge_Remote_Ammo_Scripted either (confirmed live: still
	// too small even at the room-clearing "satchel charge" tier this
	// mission's own placed charge already uses). Sh_82_HE is a genuine step
	// up in blast (~18m lethal radius vs. the satchel's ~5m) while staying
	// nowhere near an aerial bomb's footprint. Standard shell/bomb-type
	// ammo (unlike the DemoCharge_Remote family) detonates directly off
	// setDamage 1 below, same as Bo_Mk82 did - no "_Scripted" variant
	// needed or available for it.
	private _bomb = createVehicle ["Sh_82_HE", _p, [], 0, "NONE"];   // same blast the suicide bomb uses
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
