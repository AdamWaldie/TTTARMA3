//////////////////////////////////////////////////////////////////
// Waldo_fnc_applySpawnLoadout
// CLIENT: gives the local player a random uniform/vest/headgear from the
// lobby's configured pools (60% headgear chance), and strips any radio
// (vanilla, ACRE2, or TFAR) the unit spawned with. Shared by the initial
// spawn (Waldo_fnc_initClient) and a mid-round revive (onPlayerRespawn.sqf) -
// a freshly respawned unit is otherwise bare. Backpacks are deliberately NOT
// handed out here - they're ground loot (Waldo_fnc_populateLoot), found, not
// free.
//////////////////////////////////////////////////////////////////

private _uniforms  = missionNamespace getVariable ["uniformsConfig", []];
private _headgears = missionNamespace getVariable ["headgearsConfig", []];
private _vests     = missionNamespace getVariable ["vestsConfig", []];

if (count _uniforms > 0) then { player forceAddUniform (selectRandom _uniforms); };
if (count _vests > 0)    then { player addVest (selectRandom _vests); };
if (count _headgears > 0 && {floor (random 10) < 6}) then { player addHeadgear (selectRandom _headgears); };

// Strip any radio the unit spawned with - vanilla ItemRadio, ACRE2, or TFAR
// alike. mission.sqm placement and both comms mods' own "auto radio" loadout
// systems hand these out regardless of what this function just gave out, and
// TTT's coordination is Traitor-only silent pings (Waldo_fnc_traitorPing),
// not open voice comms.
//
// Two checks, not a hardcoded classname list, because ACRE2 and TFAR do this
// completely differently (confirmed by reading both mods' own source, not
// guessed):
//   - TFAR's radios (TFAR_anprc152, TFAR_anprc148jem, TFAR_anprc154,
//     TFAR_rf7800str, TFAR_fadak, TFAR_microdagr, TFAR_pnr1000a, and their
//     airborne/manpack variants - addons/handhelds/*/CfgWeapons.hpp in the
//     TFAR repo) all inherit DIRECTLY from vanilla ItemRadio. isKindOf
//     catches every one of those, and plain vanilla ItemRadio itself, in one
//     shot.
//   - ACRE2's radios (ACRE_PRC343/148/152/77/117F, ACRE_SEM52SL, ACRE_SEM70,
//     ACRE_BF888S - docs/wiki/class-names.md in the ACRE2 repo) do NOT
//     inherit from ItemRadio at all - ACRE2's own config hides/replaces
//     vanilla ItemRadio instead of extending it (addons/main/CfgWeapons.hpp),
//     so isKindOf would miss every one of them. ACRE2 identifies its own
//     radios via a dedicated config property instead (acre_isRadio = 1;),
//     which is exactly what ACRE2's own acre_sys_radio_fnc_isBaseClassRadio
//     checks - reused here rather than hardcoding all 8 classnames so this
//     stays correct if ACRE2 ever ships another radio model.
{
	private _itemClass = _x;
	private _cfg = configFile >> "CfgWeapons" >> _itemClass;
	private _isRadio = ((getNumber (_cfg >> "acre_isRadio")) == 1)
		|| (_itemClass isKindOf ["ItemRadio", configFile >> "CfgWeapons"]);
	if (_isRadio) then { player removeItem _itemClass; };
} forEach (items player);
