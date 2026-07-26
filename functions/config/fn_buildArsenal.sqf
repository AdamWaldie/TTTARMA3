//////////////////////////////////////////////////////////////////
// Waldo_fnc_buildArsenal
// SERVER: the SOLE equipment source - fully dynamic, intent-aware discovery.
// There are no per-modpack preset files. This scans the LOADED configs ONCE and
// classifies everything available (weapons, ammo/magazines, gear, clothing) by
// intent, then publishes the globals the mission consumes:
//
//   lootPriWeapons / lootSecWeapons / lootAttachments   (Waldo_fnc_populateLoot)
//   airdropLoadouts                                      (Waldo_fnc_spawnAirdrop)
//   TraitorRifle / *Mag / *Optics, TraitorLauncher/*Mag  (traitor shop weapons)
//   ShopPistol/*Mag/*Suppressor                          (shop silenced sidearm)
//   ShopArmorVest / ShopFrag / ShopNVG / ShopBinocular   (shop gear)
//   uniformsConfig / headgearsConfig / vestsConfig       (spawn loadout)
//   detectiveConfig                                      (detective loadout)
//
// Intent buckets:
//   - Ground LOOT uses LOW-POWERED primaries (SMGs / small-calibre) + sidearms,
//     which suits TTT's close-quarters play; it falls back to standard rifles
//     only if too few low-powered weapons exist ("low powered, or similar").
//   - AIRDROPS (the reward) use the stronger primaries / snipers / LMGs.
//   - The traitor shop's "Long Rifle" resolves to the highest-damage sniper
//     found, and "Rocket Launcher" to any launcher.
//   - Overpowered optics (thermal) are auto-blacklisted from loot.
//
// Every bucket has a built-in VANILLA classname fallback, so an empty category
// (e.g. a total-conversion with no pistols) can never leave anything unset or
// break a round. Power thresholds can be tuned from config.sqf (see below).
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

private _t0 = diag_tickTime;
diag_log "[Waldo][server] buildArsenal: begin";

// Power thresholds (default-magazine ammo `hit`). Tuned for vanilla calibres;
// override in config.sqf (set before loadParams runs) if a modpack's damage
// values sit differently.
private _lowMaxHit    = missionNamespace getVariable ["Waldo_arsenalLowMaxHit",    8];    // <= this -> low-powered primary -> loot
private _sniperMinHit = missionNamespace getVariable ["Waldo_arsenalSniperMinHit", 12];   // >= this (+ small mag) -> sniper -> shop
private _lmgMinRounds = missionNamespace getVariable ["Waldo_arsenalLmgMinRounds", 100];  // mags this large -> LMG -> airdrop

// ---- helpers ----
private _magOf = {
	params ["_w"];
	(getArray (configFile >> "CfgWeapons" >> _w >> "magazines")) param [0, ""]
};
private _opticOf = {
	params ["_w"];
	private _c = getArray (configFile >> "CfgWeapons" >> _w >> "WeaponSlotsInfo" >> "CowsSlot" >> "compatibleItems");
	if (_c isEqualTo []) then { "" } else { selectRandom _c }
};
private _cap = {   // shuffle + trim to a sane size
	params ["_arr", "_n"];
	private _a = +_arr call BIS_fnc_arrayShuffle;
	if (count _a > _n) then { _a resize _n };
	_a
};

// ---- single pass over CfgWeapons: classify weapons, clothing and optics ----
private _pistols   = [];
private _launchers = [];
private _low       = [];   // low-powered primaries (loot)
private _std       = [];   // standard assault rifles (airdrop / detective)
private _snipers   = [];   // [class, hit] pairs
private _lmgs      = [];
private _uniforms  = [];
private _vests     = [];
private _headgear  = [];
private _nvgs      = [];    // night-vision goggles (shop gear)
private _binos     = [];    // plain binoculars (shop gear)
private _blacklist = [];    // overpowered optics excluded from loot

{
	private _cfg = _x;
	if (getNumber (_cfg >> "scope") == 2) then {
		private _cls  = configName _cfg;
		private _mags = getArray (_cfg >> "magazines");

		if (count _mags > 0) then {
			// --- magazine-bearing: a weapon. Classify by config inheritance
			// (mod-portable: mods inherit from these base classes), lazily. ---
			private _root = configFile >> "CfgWeapons";
			switch (true) do {
				case (_cls isKindOf ["Pistol", _root]):   { _pistols   pushBack _cls; };
				case (_cls isKindOf ["Launcher", _root]): { _launchers pushBack _cls; };
				case (_cls isKindOf ["Rifle", _root]): {          // rifle-family primary
					private _mag  = _mags select 0;
					private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
					private _hit  = getNumber (configFile >> "CfgAmmo" >> _ammo >> "hit");
					private _mc   = getNumber (configFile >> "CfgMagazines" >> _mag >> "count");
					switch (true) do {
						case (_mc >= _lmgMinRounds):                    { _lmgs    pushBack _cls; };
						case (_hit >= _sniperMinHit && {_mc <= 10}):    { _snipers pushBack [_cls, _hit]; };
						case (_hit <= _lowMaxHit):                      { _low     pushBack _cls; };
						default                                         { _std     pushBack _cls; };
					};
				};
				default { /* mag-bearing but not a standard weapon: ignore */ };
			};
		} else {
			// --- no magazines: a wearable / attachment / optic / binocular ---
			if (_cls isKindOf ["Binocular", configFile >> "CfgWeapons"]) then {
				// Plain binoculars only (rangefinders/designators carry a battery
				// magazine, so they went through the weapon branch and were ignored).
				_binos pushBack _cls;
			} else {
				switch (getNumber (_cfg >> "ItemInfo" >> "type")) do {
					case 801: { _uniforms pushBack _cls; };   // TYPE_UNIFORM
					case 701: { _vests    pushBack _cls; };   // TYPE_VEST
					case 605: { _headgear pushBack _cls; };   // TYPE_HEADGEAR
					case 617: { _nvgs     pushBack _cls; };   // TYPE_NVG
					case 201: {                               // TYPE_OPTICS -> blacklist thermals
						if (isClass (_cfg >> "ItemInfo" >> "OpticsModes")) then {
							private _thermal = false;
							{
								if ("ti" in ((getArray (_x >> "visionMode")) apply { toLower _x })) then { _thermal = true; };
							} forEach ("true" configClasses (_cfg >> "ItemInfo" >> "OpticsModes"));
							if (_thermal) then { _blacklist pushBack _cls; };
						};
					};
				};
			};
		};
	};
} forEach ("true" configClasses (configFile >> "CfgWeapons"));

// ---- publish: ground loot (low-powered, with a fallback to standard) ----
private _lootPri = _low;
if (count _lootPri < 3) then { _lootPri = _lootPri + _std; };            // "low powered, or similar"
if (_lootPri isEqualTo []) then { _lootPri = ["SMG_02_F", "arifle_TRG20_F", "SMG_05_F"]; };
missionNamespace setVariable ["lootPriWeapons", ([_lootPri, 16] call _cap), true];

private _lootSec = _pistols;
if (_lootSec isEqualTo []) then { _lootSec = ["hgun_P07_F", "hgun_Rook40_F", "hgun_ACPC2_F"]; };
missionNamespace setVariable ["lootSecWeapons", ([_lootSec, 12] call _cap), true];

if (_blacklist isEqualTo []) then { _blacklist = ["optic_tws", "optic_tws_mg", "optic_nightstalker"]; };
missionNamespace setVariable ["lootAttachments", _blacklist, true];

// ---- publish: traitor shop sniper (highest-damage) ----
private _sniper = "srifle_LRR_F";
private _sniperMag = "7Rnd_408_Mag";
private _sniperOptic = "optic_LRPS";
if !(_snipers isEqualTo []) then {
	private _best = _snipers select 0;
	{ if ((_x select 1) > (_best select 1)) then { _best = _x; }; } forEach _snipers;
	private _w = _best select 0;
	private _m = [_w] call _magOf;
	if (_m != "") then {
		_sniper = _w;
		_sniperMag = _m;
		private _o = [_w] call _opticOf;
		if (_o != "") then { _sniperOptic = _o; };
	};
};
missionNamespace setVariable ["TraitorRifle", _sniper, true];
missionNamespace setVariable ["TraitorRifleMag", _sniperMag, true];
missionNamespace setVariable ["TraitorRifleOptics", _sniperOptic, true];

// ---- publish: traitor shop launcher ----
private _launcher = "launch_NLAW_F";
private _launcherMag = "NLAW_F";
if !(_launchers isEqualTo []) then {
	private _w = selectRandom _launchers;
	private _m = [_w] call _magOf;
	if (_m != "") then { _launcher = _w; _launcherMag = _m; };
};
missionNamespace setVariable ["TraitorLauncher", _launcher, true];
missionNamespace setVariable ["TraitorLauncherMag", _launcherMag, true];

// ---- publish: a silenced sidearm for the shop (discovered pistol + suppressor) ----
private _sp = "hgun_P07_F";
private _spMag = "16Rnd_9x21_Mag";
private _spSup = "muzzle_snds_L";
if !(_pistols isEqualTo []) then {
	private _p = selectRandom _pistols;
	private _m = [_p] call _magOf;
	if (_m != "") then {
		_sp = _p;
		_spMag = _m;
		private _muz = getArray (configFile >> "CfgWeapons" >> _p >> "WeaponSlotsInfo" >> "MuzzleSlot" >> "compatibleItems");
		_spSup = if (_muz isEqualTo []) then { "" } else { selectRandom _muz };
	};
};
missionNamespace setVariable ["ShopPistol", _sp, true];
missionNamespace setVariable ["ShopPistolMag", _spMag, true];
missionNamespace setVariable ["ShopPistolSuppressor", _spSup, true];

// ---- publish: shop gear (heavy vest, frag grenade, NVG, binocular) ----
// Body Armor: the highest-armour discovered vest.
private _armorVest = "V_PlateCarrier2_rgr";
if !(_vests isEqualTo []) then {
	private _bestA = -1;
	{
		private _a = getNumber (configFile >> "CfgWeapons" >> _x >> "ItemInfo" >> "armor");
		if (_a > _bestA) then { _bestA = _a; _armorVest = _x; };
	} forEach _vests;
};
missionNamespace setVariable ["ShopArmorVest", _armorVest, true];

// Frag grenade: first explosive throwable found on the "Throw" weapon's muzzles.
private _frag = "";
{
	private _muzzle = _x;
	private _tMags = getArray (configFile >> "CfgWeapons" >> "Throw" >> _muzzle >> "magazines");
	private _i = _tMags findIf {
		private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
		(getNumber (configFile >> "CfgAmmo" >> _ammo >> "explosive") > 0) && {getNumber (configFile >> "CfgAmmo" >> _ammo >> "indirectHit") >= 15}
	};
	if (_i >= 0) exitWith { _frag = _tMags select _i; };
} forEach (getArray (configFile >> "CfgWeapons" >> "Throw" >> "muzzles"));
if (_frag == "") then { _frag = "HandGrenade"; };
missionNamespace setVariable ["ShopFrag", _frag, true];

// Night vision + binoculars: discovered, with vanilla fallbacks.
missionNamespace setVariable ["ShopNVG",       (if (_nvgs  isEqualTo []) then { "NVGoggles" } else { selectRandom _nvgs }),  true];
missionNamespace setVariable ["ShopBinocular", (if (_binos isEqualTo []) then { "Binocular" } else { selectRandom _binos }), true];

// ---- publish: airdrops (the reward pool: snipers + LMGs + standard rifles) ----
private _airPool = (_snipers apply { _x select 0 }) + _lmgs + _std;
if (_airPool isEqualTo []) then { _airPool = ["arifle_MXM_Black_F", "srifle_EBR_F", "LMG_Mk200_F"]; };
private _airdrops = [];
{
	private _m = [_x] call _magOf;
	if (_m != "") then {
		private _att = [];
		private _o = [_x] call _opticOf;
		if (_o != "" && {!(_o in _blacklist)}) then { _att pushBack _o; };
		_airdrops pushBack ["weapon", _x, [_m, 5], _att];
	};
} forEach ([_airPool, 6] call _cap);
if (_airdrops isEqualTo []) then {
	_airdrops = [["weapon", "arifle_MXM_Black_F", ["30Rnd_65x39_caseless_black_mag", 5], []]];
};
missionNamespace setVariable ["airdropLoadouts", _airdrops, true];

// ---- publish: clothing (dressed on spawn) ----
if (_uniforms isEqualTo []) then { _uniforms = ["U_BG_Guerilla2_1", "U_C_Poloshirt_blue", "U_C_Commoner1_1"]; };
if (_headgear isEqualTo []) then { _headgear = ["H_Cap_oli", "H_Booniehat_khk", "H_Bandanna_gry"]; };
if (_vests    isEqualTo []) then { _vests    = ["V_Rangemaster_belt"]; };
private _uniPool = [_uniforms, 12] call _cap;
private _headPool = [_headgear, 12] call _cap;
private _vestPool = [_vests, 8] call _cap;
missionNamespace setVariable ["uniformsConfig",  _uniPool,  true];
missionNamespace setVariable ["headgearsConfig", _headPool, true];
missionNamespace setVariable ["vestsConfig",     _vestPool, true];

// ---- publish: detective loadout (distinct look + a standard primary) ----
private _detUni  = if !(_uniPool  isEqualTo []) then { selectRandom _uniPool }  else { "U_B_GEN_Soldier_F" };
private _detVest = if !(_vestPool isEqualTo []) then { selectRandom _vestPool } else { "V_TacVest_blk_POLICE" };
private _detHead = if !(_headPool isEqualTo []) then { selectRandom _headPool } else { "H_Beret_02" };
private _detPri  = if !(_std isEqualTo []) then { selectRandom _std } else { "arifle_MXM_Black_F" };
private _detMag  = [_detPri] call _magOf;
if (_detMag == "") then { _detMag = "30Rnd_65x39_caseless_black_mag"; };
missionNamespace setVariable ["detectiveConfig", [_detUni, _detVest, _detHead, [_detPri, _detMag, 3], ["", "", 0]], true];

diag_log format [
	"[Waldo][server] buildArsenal: done in %1ms - low=%2 std=%3 snipers=%4 lmg=%5 pistols=%6 launchers=%7 | uni=%8 head=%9 vest=%10 optBlacklist=%11",
	round ((diag_tickTime - _t0) * 1000),
	count _low, count _std, count _snipers, count _lmgs, count _pistols, count _launchers,
	count _uniforms, count _headgear, count _vests, count _blacklist
];
