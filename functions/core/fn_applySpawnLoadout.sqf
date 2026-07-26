//////////////////////////////////////////////////////////////////
// Waldo_fnc_applySpawnLoadout
// CLIENT: gives the local player a random uniform/vest/headgear from the
// lobby's configured pools (60% headgear chance). Shared by the initial
// spawn (Waldo_fnc_initClient) and a mid-round revive (onPlayerRespawn.sqf) -
// a freshly respawned unit is otherwise bare.
//////////////////////////////////////////////////////////////////

private _uniforms  = missionNamespace getVariable ["uniformsConfig", []];
private _headgears = missionNamespace getVariable ["headgearsConfig", []];
private _vests     = missionNamespace getVariable ["vestsConfig", []];

if (count _uniforms > 0) then { player forceAddUniform (selectRandom _uniforms); };
if (count _vests > 0)    then { player addVest (selectRandom _vests); };
removeBackpack player;
if (count _headgears > 0 && {floor (random 10) < 6}) then { player addHeadgear (selectRandom _headgears); };
