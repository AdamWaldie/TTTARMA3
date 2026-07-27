//////////////////////////////////////////////////////////////////
// onPlayerRespawn.sqf
// CLIENT: engine-called automatically whenever the local player's unit
// respawns. In this ruleset only Waldo_fnc_revive forces an early respawn
// mid-round (setPlayerRespawnTime 0) - a normal death sits in Spectator for
// the long default respawnDelay and never reaches here before the round
// ends, so this is a no-op unless Waldo_revivePending is set on _oldUnit.
//
// A truly dead unit can never be revived in place (respawn always creates a
// brand-new unit object), so anything Waldo_fnc_revive did to the OLD unit
// is invisible to it. This hook re-homes that state onto _newUnit:
// role/points/kills/purchases carried over, list membership (TraitorList
// etc.) relinked server-side, the per-life event handlers Waldo_fnc_initClient
// bound to the old unit object reinstalled (they don't follow the "player"
// command across a respawn the way commands like lifeState do), a basic
// loadout, and an HUD refresh.
//
// params: [_newUnit, _oldUnit, _respawn, _respawnDelay]
//////////////////////////////////////////////////////////////////

params ["_newUnit", "_oldUnit", "_respawn", "_respawnDelay"];
if (!hasInterface || {_newUnit != player}) exitWith {};

private _pending = _oldUnit getVariable ["Waldo_revivePending", false];
if (!_pending) exitWith {};   // a normal (non-revived) respawn - nothing to do

private _asTraitor = _oldUnit getVariable ["Waldo_reviveAsTraitor", false];
private _role = if (_asTraitor) then { "Traitor" } else { _oldUnit getVariable ["role", "Innocent"] };

// --- Carry per-life state from the corpse to the new unit ---
_newUnit setVariable ["player", _newUnit, true];
_newUnit setVariable ["role", _role, true];
_newUnit setVariable ["points", (_oldUnit getVariable ["points", 0]), true];
_newUnit setVariable ["Waldo_roundKills", (_oldUnit getVariable ["Waldo_roundKills", 0]), true];
_newUnit setVariable ["Waldo_purchases", (_oldUnit getVariable ["Waldo_purchases", []])];
_newUnit setVariable ["tested", (_oldUnit getVariable ["tested", false]), true];
_newUnit setVariable ["Waldo_activationSlots", (_oldUnit getVariable ["Waldo_activationSlots", [-1, -1, -1]])];
_newUnit setVariable ["Waldo_activationBacklog", (_oldUnit getVariable ["Waldo_activationBacklog", []])];
_newUnit setVariable ["Waldo_purchaseSeq", (_oldUnit getVariable ["Waldo_purchaseSeq", 0])];

// Authoritative list membership (TraitorList/DetectiveList/JesterList) and the
// forced-Traitor conversion must be relinked server-side.
[_newUnit, _oldUnit, _asTraitor] remoteExec ["Waldo_fnc_reviveRelink", 2];

// Re-home the per-life handlers Waldo_fnc_initClient bound to the OLD unit
// object - addMPEventHandler/addEventHandler attach to that specific object,
// not to whatever "player" currently resolves to, so they don't carry across
// a respawn on their own.
_newUnit addMPEventHandler ["MPKilled", { _this call Waldo_fnc_onKilled; }];
_newUnit addEventHandler ["HandleDamage", {
	params ["_unit", "_selection", "_damage"];
	if ((_unit getVariable ["Waldo_deadRingerArmed", false]) && {((damage _unit) + _damage) >= 1}) then {
		[_unit] call Waldo_fnc_deadRingerTrigger;
		0.9
	} else {
		_damage
	}
}];

// The Jester's "deals no damage" fire-block is likewise unit-bound.
if (_role == "Jester") then { [] call Waldo_fnc_makeJester; };

// A freshly respawned unit is otherwise bare.
[] call Waldo_fnc_applySpawnLoadout;
_newUnit allowDamage true;

// HUD (role may have changed, e.g. the Traitor Defibrillator).
[] call Waldo_fnc_initHud;

_oldUnit setVariable ["Waldo_revivePending", false, true];
_oldUnit setVariable ["Waldo_reviveAsTraitor", false, true];

diag_log format ["[Waldo][client] onPlayerRespawn: %1 revived as %2", name _newUnit, _role];
