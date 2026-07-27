//////////////////////////////////////////////////////////////////
// Waldo_fnc_applySpawnLoadout
// CLIENT: gives the local player a random uniform/vest/headgear from the
// lobby's configured pools (60% headgear chance), and strips any ACRE2/TFAR
// radio the unit spawned with. Shared by the initial spawn (Waldo_fnc_initClient)
// and a mid-round revive (onPlayerRespawn.sqf) - a freshly respawned unit is
// otherwise bare. Backpacks are deliberately NOT handed out here - they're
// ground loot (Waldo_fnc_populateLoot), found, not free.
//////////////////////////////////////////////////////////////////

private _uniforms  = missionNamespace getVariable ["uniformsConfig", []];
private _headgears = missionNamespace getVariable ["headgearsConfig", []];
private _vests     = missionNamespace getVariable ["vestsConfig", []];

if (count _uniforms > 0) then { player forceAddUniform (selectRandom _uniforms); };
if (count _vests > 0)    then { player addVest (selectRandom _vests); };
if (count _headgears > 0 && {floor (random 10) < 6}) then { player addHeadgear (selectRandom _headgears); };

// Strip any ACRE2/TFAR radio the unit spawned with - mission.sqm placement
// and both mods' own "auto radio" loadout systems hand these out on their
// own, regardless of what this function just gave out. TTT's coordination is
// Traitor-only silent pings (Waldo_fnc_traitorPing), not open voice comms, so
// a real long-range radio undermines that.
//
// Detected generically instead of a hardcoded classname list (ACRE2 alone
// has 5+ base radios, TFAR a couple dozen faction/role variants, and either
// mod adding a new one would silently slip past a fixed list): any CfgWeapons
// item whose simulation is the engine's own "ItemRadio" (the same property
// vanilla, ACRE2, and TFAR radios all declare, since that's what makes an
// item occupy the radio slot/menu at all) AND whose config traces back to an
// ACRE/TFAR addon (configSourceAddonList) gets removed. Leaves plain vanilla
// ItemRadio alone (it isn't sourced from either addon) and is a total no-op
// with neither mod loaded.
{
	private _itemClass = _x;
	private _cfg = configFile >> "CfgWeapons" >> _itemClass;
	if ((getText (_cfg >> "simulation")) == "ItemRadio") then {
		private _fromCommsMod = { ((toLower _x) find "acre" > -1) || ((toLower _x) find "tfar" > -1) } count (configSourceAddonList _cfg) > 0;
		if (_fromCommsMod) then { player removeItem _itemClass; };
	};
} forEach (items player);
