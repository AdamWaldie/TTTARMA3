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
//   uniformsConfig / headgearsConfig / vestsConfig /
//     backpacksConfig                                    (spawn loadout)
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
private _fragMinIndirectHit = missionNamespace getVariable ["Waldo_arsenalFragMinIndirectHit", 6];  // >= this -> "Frag Grenades" candidate

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
private _vestCargo = {   // a vest's cargo capacity, 0 if it carries nothing at all
	params ["_vest"];
	private _container = getText (configFile >> "CfgWeapons" >> _vest >> "ItemInfo" >> "containerClass");
	if (_container == "") exitWith { 0 };
	getNumber (configFile >> "CfgVehicles" >> _container >> "maximumLoad")
};
private _vestArmor = {   // a vest's total ballistic protection, 0 if it protects nothing at all
	// There is no single flat "how armoured is this vest" number - real
	// protection is a PER-HITPOINT bonus (Neck/Arms/Chest/Diaphragm/Abdomen/
	// Body/...) nested under ItemInfo >> HitpointsProtectionInfo. Summing
	// every hitpoint's own armor value gives a genuine, comparable "total
	// protection" score across vests.
	params ["_vest"];
	private _hpi = configFile >> "CfgWeapons" >> _vest >> "ItemInfo" >> "HitpointsProtectionInfo";
	if !(isClass _hpi) exitWith { 0 };
	private _total = 0;
	{ _total = _total + (getNumber (_x >> "armor")); } forEach ("true" configClasses _hpi);
	_total
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
				case (_cls isKindOf ["Launcher", _root]): {
					// Exclude anything that needs a lock before it'll fire at all
					// (Titan AT/AA, Igla, Strela, PCML, and modded equivalents), not
					// just AA-classed ones - this used to only check airLock (can
					// this lock onto AIR targets), which is 0 for a GROUND-locking
					// guided AT launcher too, so Titan AT and its kind kept slipping
					// through: they're not "AA", but they still need a lock, in a
					// mode with no lock-on trainer/tone setup for a player who just
					// bought "Rocket Launcher" expecting to point and fire.
					// canLock is the actual master flag for "needs a lock at all"
					// (0 = no lock capability, disposables like NLAW/RPG-42 leave it
					// unset) - airLock/groundLock only say WHICH targets a
					// lock-capable weapon can lock onto.
					private _mag0 = _mags select 0;
					private _ammo0 = getText (configFile >> "CfgMagazines" >> _mag0 >> "ammo");
					private _needsLock = (getNumber (configFile >> "CfgAmmo" >> _ammo0 >> "canLock")) != 0;
					if (!_needsLock) then { _launchers pushBack _cls; };
				};
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

// Backpacks live under CfgVehicles (inheriting Bag_Base), not CfgWeapons like
// every other wearable above, so they need their own scan.
private _backpacks = [];
{
	private _cls = configName _x;
	if (getNumber (_x >> "scope") == 2 && {_cls isKindOf ["Bag_Base", configFile >> "CfgVehicles"]}) then {
		_backpacks pushBack _cls;
	};
} forEach ("true" configClasses (configFile >> "CfgVehicles"));

// ---- publish: ground loot (driven by the Loot Power lobby setting) ----
//   0 Low: SMG / pistol-calibre only   1 Balanced: low, + standard if sparse
//   2 Anything: low + standard rifles
private _lootPri = +_low;
switch (missionNamespace getVariable ["Waldo_lootPower", 1]) do {
	case 0: { /* low only */ };
	case 2: { _lootPri = _lootPri + _std; };
	default { if (count _lootPri < 3) then { _lootPri = _lootPri + _std; }; };
};
if (_lootPri isEqualTo []) then { _lootPri = _std; };                    // Low with no SMGs found -> rifles
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
	// Prefer a pistol that actually HAS a muzzle-compatible suppressor - a
	// pistol picked purely at random can easily land on one with no muzzle
	// slot at all (several vanilla/mod pistols have none), which silently
	// hands out an unsuppressed "Silenced Pistol" (Waldo_fnc_buyItem only
	// attaches one if ShopPistolSuppressor isn't "").
	private _suppressed = _pistols select { !((getArray (configFile >> "CfgWeapons" >> _x >> "WeaponSlotsInfo" >> "MuzzleSlot" >> "compatibleItems")) isEqualTo []) };
	private _pool = if (_suppressed isEqualTo []) then { _pistols } else { _suppressed };
	private _p = selectRandom _pool;
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
// Body Armor: the highest-armour vest that still carries SOMETHING - picking
// purely by armour can land on a heavy plate-carrier variant with zero cargo
// space, which defeats half the point of a wearable upgrade. Only falls back
// to an armour-only pick if literally nothing in the discovered pool has any
// cargo at all.
private _armorVest = "V_PlateCarrier2_rgr";
if !(_vests isEqualTo []) then {
	private _bestA = -1;
	{
		if (([_x] call _vestCargo) > 0) then {
			private _a = [_x] call _vestArmor;
			if (_a > _bestA) then { _bestA = _a; _armorVest = _x; };
		};
	} forEach _vests;
	if (_bestA < 0) then {
		{
			private _a = [_x] call _vestArmor;
			if (_a > _bestA) then { _bestA = _a; _armorVest = _x; };
		} forEach _vests;
	};
};
missionNamespace setVariable ["ShopArmorVest", _armorVest, true];

// Frag grenade: first explosive throwable found on the "Throw" weapon's muzzles.
// (exitWith inside a forEach only ends that one iteration, not the loop, so the
// "stop at the first match" guard has to be an explicit _frag == "" check -
// otherwise a later muzzle with its own match would silently overwrite it.)
//
// Threshold was 15 - but vanilla HandGrenade's OWN ammo (HandGrenade_Ammo)
// has indirectHit = 8, so that threshold excluded the exact reference item
// this is meant to identify. In a plain vanilla game this went unnoticed
// (nothing ever matched, so it silently fell through to the "HandGrenade"
// fallback below anyway), but with any mod loaded that adds a throwable
// clearing 15, THAT got picked instead of vanilla HandGrenade - not
// necessarily a real hand-thrown frag, and not necessarily working the same
// way once thrown. 6 safely clears vanilla HandGrenade's real value.
private _frag = "";
{
	if (_frag == "") then {
		private _tMags = getArray (configFile >> "CfgWeapons" >> "Throw" >> _x >> "magazines");
		private _i = _tMags findIf {
			private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
			(getNumber (configFile >> "CfgAmmo" >> _ammo >> "explosive") > 0) && {getNumber (configFile >> "CfgAmmo" >> _ammo >> "indirectHit") >= _fragMinIndirectHit}
		};
		if (_i >= 0) then { _frag = _tMags select _i; };
	};
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
if (_uniforms  isEqualTo []) then { _uniforms  = ["U_BG_Guerilla2_1", "U_C_Poloshirt_blue", "U_C_Commoner1_1"]; };
if (_headgear  isEqualTo []) then { _headgear  = ["H_Cap_oli", "H_Booniehat_khk", "H_Bandanna_gry"]; };
if (_vests     isEqualTo []) then { _vests     = ["V_Rangemaster_belt"]; };
if (_backpacks isEqualTo []) then { _backpacks = ["B_AssaultPack_mcamo"]; };

// Prefer uniforms/vests that actually carry SOMETHING (same reasoning as
// Body Armor above, _vestCargo works the same way for either slot) - picked
// purely at random from every discovered TYPE_UNIFORM/TYPE_VEST, this pool
// includes plenty of decorative/civilian pieces with zero cargo space. A
// Traitor or Detective who spawns wearing nothing but two zero-cargo pieces
// has nowhere for a shop purchase to go - credits spent, nothing delivered,
// with no error or warning anywhere. Only falls back to the full pool if
// literally nothing discovered has any cargo at all.
private _uniformsWithCargo = _uniforms select { ([_x] call _vestCargo) > 0 };
if (_uniformsWithCargo isEqualTo []) then { _uniformsWithCargo = _uniforms; };
private _vestsWithCargo = _vests select { ([_x] call _vestCargo) > 0 };
if (_vestsWithCargo isEqualTo []) then { _vestsWithCargo = _vests; };

private _uniPool = [_uniformsWithCargo, 12] call _cap;
private _headPool = [_headgear, 12] call _cap;
private _vestPool = [_vestsWithCargo, 8] call _cap;
private _packPool = [_backpacks, 12] call _cap;
missionNamespace setVariable ["uniformsConfig",  _uniPool,  true];
missionNamespace setVariable ["headgearsConfig", _headPool, true];
missionNamespace setVariable ["vestsConfig",     _vestPool, true];
missionNamespace setVariable ["backpacksConfig", _packPool, true];

// ---- publish: detective loadout (distinct look + a standard primary) ----
private _detUni  = if !(_uniPool  isEqualTo []) then { selectRandom _uniPool }  else { "U_B_GEN_Soldier_F" };
private _detVest = if !(_vestPool isEqualTo []) then { selectRandom _vestPool } else { "V_TacVest_blk_POLICE" };
private _detHead = if !(_headPool isEqualTo []) then { selectRandom _headPool } else { "H_Beret_02" };
private _detPri  = if !(_std isEqualTo []) then { selectRandom _std } else { "arifle_MXM_Black_F" };
private _detMag  = [_detPri] call _magOf;
if (_detMag == "") then { _detMag = "30Rnd_65x39_caseless_black_mag"; };
missionNamespace setVariable ["detectiveConfig", [_detUni, _detVest, _detHead, [_detPri, _detMag, 3], ["", "", 0]], true];

diag_log format [
	"[Waldo][server] buildArsenal: done in %1ms - low=%2 std=%3 snipers=%4 lmg=%5 pistols=%6 launchers=%7 | uni=%8 head=%9 vest=%10 pack=%11 optBlacklist=%12",
	round ((diag_tickTime - _t0) * 1000),
	count _low, count _std, count _snipers, count _lmgs, count _pistols, count _launchers,
	count _uniforms, count _headgear, count _vests, count _backpacks, count _blacklist
];
