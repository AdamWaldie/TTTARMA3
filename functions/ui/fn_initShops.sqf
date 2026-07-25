//////////////////////////////////////////////////////////////////
// Waldo_fnc_initShops  (preInit = 1, runs on every machine)
// Defines shared helpers and the data-driven shop catalogs. Adding a shop
// item is now a single array entry here - no .hpp IDCs or switch cases.
//
// Catalog item format:
//   [ _name, _cost, _type, _onBuy, _onActivate, _tooltip ]
//     _type       : "passive" | "weapon" | "activation"
//     _onBuy      : code run immediately on purchase
//     _onActivate : code run when the player presses Y (activation items).
//                   Must return TRUE when it should be consumed, FALSE to
//                   stay in the queue (e.g. no valid target).
//
// Weapon classnames are read from missionNamespace at click time so the
// same catalog works for every equipment modpack.
//////////////////////////////////////////////////////////////////

// Role -> RGBA colour (shared by HUD, icons, menus).
Waldo_roleColor = {
	params ["_role"];
	switch (_role) do {
		case "Traitor":   { [0.75, 0.21, 0.21, 1] };
		case "Detective": { [0.01, 0.45, 1, 1] };
		case "Jester":    { [0.4, 0, 0.5, 1] };
		default           { [0.12549, 0.72941, 0.09412, 1] };
	};
};

// --- Traitor shop ---
Waldo_traitorShop = [
	["Suicide Bomb", 1, "activation",
		{},
		{ [] call Waldo_fnc_suicideBomb; true },
		"Detonate yourself (press Y)"],

	["Radar", 1, "passive",
		{ [] call Waldo_fnc_traitorRadar; },
		{},
		"Pulses everyone's position for 30s, then refreshes"],

	["Rocket Launcher", 1, "weapon",
		{
			player addWeaponGlobal (missionNamespace getVariable ["TraitorLauncher", "launch_NLAW_F"]);
			player addSecondaryWeaponItem (missionNamespace getVariable ["TraitorLauncherMag", "NLAW_F"]);
		},
		{},
		"A single-use rocket launcher"],

	["Stamina", 1, "passive",
		{ player enableStamina false; },
		{},
		"Never run out of stamina"],

	["Teleport Grenades", 1, "weapon",
		{ player addMagazine ["SmokeShellRed", 2]; [] call Waldo_fnc_warpSmoke; },
		{},
		"Throw red smoke to teleport to it (vanilla throw only)"],

	["Long Rifle", 1, "weapon",
		{
			player addWeaponGlobal (missionNamespace getVariable ["TraitorRifle", "srifle_LRR_F"]);
			player addPrimaryWeaponItem (missionNamespace getVariable ["TraitorRifleOptics", "optic_LRPS"]);
			player addMagazines [(missionNamespace getVariable ["TraitorRifleMag", "7Rnd_408_Mag"]), 3];
		},
		{},
		"A powerful long-range rifle"],

	["Defibrillator", 2, "activation",
		{},
		{ [] call Waldo_fnc_revive },
		"Aim at a body and press Y to revive them as a Traitor"],

	["Silenced Pistol", 1, "weapon",
		{
			player addWeaponGlobal (missionNamespace getVariable ["ShopPistol", "hgun_P07_F"]);
			private _s = missionNamespace getVariable ["ShopPistolSuppressor", ""];
			if (_s != "") then { player addHandgunItem _s; };
			player addMagazines [(missionNamespace getVariable ["ShopPistolMag", "16Rnd_9x21_Mag"]), 3];
		},
		{},
		"A suppressed sidearm - quiet kills leave no gunshot to give you away"],

	["Frag Grenades", 1, "weapon",
		{ player addMagazines ["HandGrenade", 2]; },
		{},
		"Two fragmentation grenades"],

	["Body Armor", 2, "passive",
		{ player addVest "V_PlateCarrier2_rgr"; },
		{},
		"A heavy plate carrier - soak an extra hit or two"],

	["Body Remover", 1, "activation",
		{},
		{ [] call Waldo_fnc_removeBody },
		"Aim at a corpse and press Y to destroy it, denying the Detective a body to test"],

	["Night Vision", 1, "weapon",
		{ player addWeapon "NVGoggles"; },
		{},
		"Night-vision goggles - own the dark rounds"]
];

// --- Detective shop ---
Waldo_detectiveShop = [
	["Portable Tester", 1, "activation",
		{},
		{ [] call Waldo_fnc_tester },
		"Aim at a player or body within 3m and press Y to reveal their role"],

	["Radar", 1, "passive",
		{ [] call Waldo_fnc_detectiveRadar; },
		{},
		"Pulses all positions for 45s, then refreshes"],

	["Smoke Grenades", 1, "weapon",
		{ player addMagazine ["SmokeShell", 2]; },
		{},
		"Two smoke grenades"],

	["Stamina", 1, "passive",
		{ player enableStamina false; },
		{},
		"Never run out of stamina"],

	["Flower Power", 1, "weapon",
		{ [] call Waldo_fnc_flowerPower; },
		{},
		"Your bullets turn into flowers (novelty)"],

	["Health Station", 1, "weapon",
		{ [] call Waldo_fnc_healthStation; },
		{},
		"Deploy a station that heals nearby players"],

	["Defibrillator", 2, "activation",
		{},
		{ [] call Waldo_fnc_revive },
		"Aim at a body and press Y to bring them back"],

	["Frag Grenades", 1, "weapon",
		{ player addMagazines ["HandGrenade", 2]; },
		{},
		"Two fragmentation grenades"],

	["Body Armor", 2, "passive",
		{ player addVest "V_PlateCarrier2_rgr"; },
		{},
		"A heavy plate carrier - stay standing long enough to catch the traitor"],

	["Medical Kit", 1, "weapon",
		{ player addItem "Medikit"; player addItem "FirstAidKit"; },
		{},
		"A medikit + first aid kit to patch yourself up"],

	["Binoculars", 1, "weapon",
		{ player addWeapon "Binocular"; },
		{},
		"Binoculars for watching suspects from range"],

	["Night Vision", 1, "weapon",
		{ player addWeapon "NVGoggles"; },
		{},
		"Night-vision goggles - keep watch in the dark"]
];

diag_log "[Waldo] initShops: catalogs ready";
