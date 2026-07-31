//////////////////////////////////////////////////////////////////
// Waldo_fnc_spawnDecoyCorpse
// SERVER: spawns a fake corpse to sell a Traitor's Dead Ringer as a real death.
// Wears the REAL player's exact loadout (uniform/vest/backpack/headgear/
// weapons/items, via _loadout - see getUnitLoadout in Waldo_fnc_deadRingerTrigger)
// when one is given, so a body found at the drop site is visually identical to
// the player who was just standing there - falls back to a random pick from
// the spawn-loadout pool only if no loadout is passed (kept for any future
// caller that doesn't have a specific player to clone). Tagged role
// "Innocent" (so any Identify/DNA info gathered from it is misleading), and
// given the same "Identify Body" action as a real corpse. Deletes itself
// after a while so it doesn't linger forever once the scene has moved on.
//
// params: [_pos, _dir, _loadout]
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};
params ["_pos", ["_dir", 0], ["_loadout", []]];

private _grp = createGroup [civilian, true];
_grp createUnit ["C_man_1", _pos, [], 0, "NONE"];
private _decoy = (units _grp) select 0;
if (isNull _decoy) exitWith { diag_log "[Waldo][server] spawnDecoyCorpse: spawn failed"; };

if (count _loadout > 0) then {
	_decoy setUnitLoadout _loadout;
} else {
	private _uni  = missionNamespace getVariable ["uniformsConfig", []];
	private _vest = missionNamespace getVariable ["vestsConfig", []];
	if (count _uni  > 0) then { _decoy forceAddUniform (selectRandom _uni); };
	if (count _vest > 0) then { _decoy addVest (selectRandom _vest); };
};

_decoy setDir _dir;
_decoy setVariable ["role", "Innocent", true];       // misdirection - never the truth
_decoy setVariable ["Waldo_deathTime", time, true];
_decoy setVariable ["Waldo_identified", false, true];
_decoy setDamage 1;   // instantly a corpse

// Same two-tier reveal as a real body (see Waldo_fnc_identifyBody): hideOnUse
// false + gated on Waldo_roleRevealed, so a non-Detective finding it first can't
// consume the action before a Detective gets to it.
[_decoy, [
	"<t color='#ffd23f'>Identify Body</t>",
	// _target/_caller are only auto-bound inside the CONDITION string, not
	// the statement - see the identical fix (and the real reason) in
	// Waldo_fnc_onKilled.
	{
		params ["_target", "_caller"];
		[_target, _caller] remoteExec ["Waldo_fnc_identifyBody", 2];
	},
	nil, 4, true, false, "",
	"!(_target getVariable ['Waldo_roleRevealed', false])",
	2.5
]] remoteExec ["addAction", 0, _decoy];

[_decoy] spawn { params ["_d"]; sleep 60; if (!isNull _d) then { deleteVehicle _d }; };
