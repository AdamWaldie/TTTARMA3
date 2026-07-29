//////////////////////////////////////////////////////////////////
// Waldo_fnc_deadRingerTrigger
// CLIENT: fires when an armed Dead Ringer takes any hit at all (see the
// HandleDamage guard in Waldo_fnc_initClient, which zeroes the actual damage
// - you weren't really there for it). Sells the fake death: spawns a decoy
// corpse where you were just standing, tagged as an Innocent so anyone who
// investigates "the body" is misled about your real role, then teleports
// the real you somewhere else in the arena that's out of every other
// player's line of sight - onlookers see a body drop and the shooter gone,
// not a ragdoll they can walk up and finish off.
//
// params: [_unit]
//////////////////////////////////////////////////////////////////

params ["_unit"];
if (_unit getVariable ["Waldo_deadRingerTriggered", false]) exitWith {};   // guard re-entry
_unit setVariable ["Waldo_deadRingerTriggered", true];
_unit setVariable ["Waldo_deadRingerArmed", false];

private _dropPos = getPosATL _unit;
// getUnitLoadout, not a random uniform/vest pick - the decoy has to be
// visually identical to the real player (weapons, backpack, headgear,
// everything), not just "dressed like someone."
[_dropPos, getDir _unit, getUnitLoadout _unit] remoteExec ["Waldo_fnc_spawnDecoyCorpse", 2];

// Hunt for a spot inside the arena that no OTHER living player currently has
// eyes on. Falls back to the drop position (better than nothing) if 40
// attempts can't find one - a crowded arena won't always have a fully blind
// spot, and this should never hang waiting for one.
private _center = missionNamespace getVariable ["mapPos", _dropPos];
private _radius = missionNamespace getVariable ["mapRadius", 100];
private _others = (allPlayers - [_unit]) select { alive _x };
private _safePos = _dropPos;
private _tries = 0;
private _found = false;
while { !_found && {_tries < 40} } do {
	_tries = _tries + 1;
	private _cand = _center getPos [random _radius, random 360];
	private _empty = _cand findEmptyPosition [0, 20];
	if !(_empty isEqualTo []) then {
		private _eyePos = _empty vectorAdd [0, 0, 1];
		private _spotted = { ([objNull, "VIEW"] checkVisibility [eyePos _x, _eyePos]) > 0 } count _others;
		if (_spotted == 0) then { _safePos = _empty; _found = true; };
	};
};

_unit setPosATL _safePos;
["DEAD RINGER", "Playing dead...", "WARNING", 0, "BOTTOM_LEFT", "DEADRINGER", "TRAITOR"] call Waldo_fnc_ShowUiNotification;

[_unit] spawn {
	params ["_unit"];
	sleep 20;
	if (alive _unit) then {
		_unit setVariable ["Waldo_deadRingerTriggered", false];
		["DEAD RINGER", "You're back up.", "SUCCESS", 4, "BOTTOM_LEFT", "DEADRINGER", "TRAITOR"] call Waldo_fnc_ShowUiNotification;
	};
};
