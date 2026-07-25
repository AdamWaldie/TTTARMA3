//////////////////////////////////////////////////////////////////
// Waldo_fnc_revive
// CLIENT: activation item (Y). Aim at a dead PLAYER's body within 3m and
// press Y. A Detective restores the player with their original allegiance;
// a Traitor revives them onto the Traitor team ("Defibrillator").
//
// Returns true when a revive was performed (consuming the item), false
// otherwise so the item stays queued.
//////////////////////////////////////////////////////////////////

private _target = cursorTarget;

if (isNull _target || {!(_target isKindOf "CAManBase")} || {alive _target}) exitWith {
	hint "Aim at a body.";
	false
};
if (isNil { _target getVariable "player" }) exitWith {
	hint "That body cannot be revived.";
	false
};
if ((player distance _target) > 3) exitWith {
	hint "Move closer to the body.";
	false
};

private _revived = _target getVariable "player";
if (isNull _revived) exitWith { hint "Revive failed."; false };

hint "Reviving...";
sleep 3;
hint "";

// Let them respawn now, then restore the long wait for future deaths.
[0] remoteExec ["setPlayerRespawnTime", _revived];
sleep 0.5;
[2400] remoteExec ["setPlayerRespawnTime", _revived];

// Traitor defibrillator converts the revived player (server owns the list).
if ((player getVariable ["role", ""]) == "Traitor") then {
	[_revived] remoteExec ["Waldo_fnc_reviveAsTraitor", 2];
};

// Refresh the revived player's HUD to match their (possibly new) role.
[] remoteExec ["Waldo_fnc_initHud", _revived];

hint "Revive complete.";
true
