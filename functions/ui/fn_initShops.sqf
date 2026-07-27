//////////////////////////////////////////////////////////////////
// Waldo_fnc_initShops  (preInit = 1, runs on every machine)
// Defines shared helpers and the data-driven shop catalogs. Adding a shop
// item is now a single array entry here - no .hpp IDCs or switch cases.
//
// Catalog item format:
//   [ _name, _cost, _type, _onBuy, _onActivate, _tooltip ]
//     _type       : "passive" | "weapon" | "activation"
//     _onBuy      : code run immediately on purchase
//     _onActivate : code run when the player presses whichever of Y/U/J this
//                   item is assigned to (activation items - see
//                   Waldo_fnc_useActivationSlot / Waldo_fnc_assignActivationSlot).
//                   Must return TRUE when it should be consumed, FALSE to stay
//                   assigned (e.g. no valid target).
//
// Weapon/gear classnames are read from missionNamespace at click time (they are
// published by the dynamic arsenal, Waldo_fnc_buildArsenal), so the same catalog
// works on any mod loadout.
//////////////////////////////////////////////////////////////////

// Renders the "Purchased" panel (idc 1107 group) inside the given shop
// display, from the player's per-round purchase log (Waldo_purchases: array of
// [id, name, tip, type, onAct]). Shared by Waldo_fnc_openBuyMenu (on open) and
// Waldo_fnc_buyItem (on each buy) so every purchase shows what it does / how
// to use it without leaving the shop.
//
// Every call fully rebuilds the panel's runtime controls rather than patching
// them in place - the entry count and each activation item's key assignment
// can both change between calls, and this list stays short enough (bounded by
// what a round's credits can afford) that a full rebuild is simpler and safer
// than tracking per-row diffs. Previously created controls are tracked by idc
// (via a display variable) so they can be torn down before rebuilding.
Waldo_shopRenderPurchased = {
	params ["_display"];
	private _group = _display displayCtrl 1107;

	{ private _c = _display displayCtrl _x; if (!isNull _c) then { ctrlDelete _c }; }
		forEach (_display getVariable ["Waldo_purchRowIds", []]);
	private _newIds = [];

	private _purchases = player getVariable ["Waldo_purchases", []];
	private _slots      = player getVariable ["Waldo_activationSlots", [-1, -1, -1]];
	private _backlog     = player getVariable ["Waldo_activationBacklog", []];
	private _keyLabels   = ["Y", "U", "J"];

	private _rowW    = 0.18 * safezoneW;
	private _lineH   = 0.030 * safezoneH;
	private _gapV    = 0.010 * safezoneH;
	private _btnW    = 0.034 * safezoneW;
	private _btnH    = 0.020 * safezoneH;
	private _btnGap  = 0.006 * safezoneW;
	private _idBase  = 2100;
	private _y = 0;

	if (count _purchases == 0) then {
		private _lbl = _display ctrlCreate ["RscStructuredText", _idBase, _group];
		_lbl ctrlSetPosition [0, 0, _rowW, _lineH * 2];
		_lbl ctrlSetStructuredText parseText "<t size='0.9' color='#9EA290'>Nothing purchased yet.</t>";
		_lbl ctrlCommit 0;
		_newIds pushBack _idBase;
	} else {
		{
			_x params ["_id", "_name", "_tip", "_type", ""];
			private _i = _forEachIndex;
			// Each row claims a block of 5 ids: 1 label + 3 slot buttons (+1 spare).
			private _idc = _idBase + (_i * 5) + 1;

			private _slotIdx = _slots findIf { _x == _id };
			private _isActivation = _type == "activation";
			private _used = _isActivation && {_slotIdx < 0} && {!(_id in _backlog)};
			private _statusTxt = "";
			if (_isActivation) then {
				_statusTxt = if (_slotIdx >= 0) then {
					format [" <t color='#F2BE55'>[%1]</t>", _keyLabels select _slotIdx]
				} else {
					if (_used) then { " <t color='#6a6f61'>[used]</t>" } else { " <t color='#E4514B'>[unassigned]</t>" }
				};
			};

			private _lbl = _display ctrlCreate ["RscStructuredText", _idc, _group];
			_lbl ctrlSetPosition [0, _y, _rowW, _lineH * 2];
			_lbl ctrlSetStructuredText parseText format [
				"<t size='1.0' color='#F2BE55'>%1</t>%2<br/><t size='0.85' color='#9EA290'>%3</t>",
				_name, _statusTxt, _tip
			];
			_lbl ctrlCommit 0;
			_newIds pushBack _idc;
			_y = _y + (_lineH * 2);

			if (_isActivation && {!_used}) then {
				{
					private _slot = _x;
					private _btnIdc = _idc + 1 + _slot;
					private _btn = _display ctrlCreate ["RscButton", _btnIdc, _group];
					_btn ctrlSetPosition [_slot * (_btnW + _btnGap), _y, _btnW, _btnH];
					_btn ctrlSetText (_keyLabels select _slot);
					_btn ctrlSetFontHeight (0.7 * _btnH);
					if (_slotIdx == _slot) then {
						_btn ctrlSetBackgroundColor [0.86, 0.68, 0.33, 1];
						_btn ctrlSetTextColor [0.1, 0.1, 0.08, 1];
					} else {
						_btn ctrlSetBackgroundColor [0.06, 0.065, 0.055, 0.92];
						_btn ctrlSetTextColor [0.75, 0.73, 0.68, 1];
					};
					_btn setVariable ["purchId", _id];
					_btn setVariable ["slotIdx", _slot];
					_btn ctrlAddEventHandler ["ButtonClick", {
						params ["_ctrl"];
						[(_ctrl getVariable "purchId"), (_ctrl getVariable "slotIdx")] call Waldo_fnc_assignActivationSlot;
						[ctrlParent _ctrl] call Waldo_shopRenderPurchased;
					}];
					_btn ctrlCommit 0;
					_newIds pushBack _btnIdc;
				} forEach [0, 1, 2];
				_y = _y + _btnH + _gapV;
			} else {
				_y = _y + _gapV;
			};
		} forEach _purchases;
	};

	_display setVariable ["Waldo_purchRowIds", _newIds];
};

// Per-role keybind list, shared by the top bar's horizontal row
// (Waldo_fnc_initHud) and the scoreboard's right-side panel
// (Waldo_fnc_scoreboard) - one source of truth so the two never drift out of
// sync. Returns [key, label] pairs rather than pre-formatted strings so each
// caller can join/colour them however its own layout needs (horizontal vs
// stacked). Dev-only binds are appended only when Testing Mode is actually on.
Waldo_keyHintsFor = {
	params ["_role"];
	private _hints = [["L", "Holster"], ["K", "Scoreboard"]];
	if (_role in ["Traitor", "Detective"]) then {
		_hints pushBack ["B", "Buy Menu"];
		_hints pushBack ["Y U J", "Use Item"];
	};
	if (_role == "Traitor") then {
		_hints pushBack ["T (hold)", "Ping"];
	};
	if (missionNamespace getVariable ["TestingFlag", false]) then {
		_hints pushBack ["[", "Dev Menu"];
		_hints pushBack ["]", "Cycle Role"];
	};
	_hints
};

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
		"Detonate yourself (press your assigned key)"],

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
		"Aim at a body and press your assigned key to revive them as a Traitor"],

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
		{ player addMagazines [(missionNamespace getVariable ["ShopFrag", "HandGrenade"]), 2]; },
		{},
		"Two fragmentation grenades"],

	["Body Armor", 2, "passive",
		{ player addVest (missionNamespace getVariable ["ShopArmorVest", "V_PlateCarrier2_rgr"]); },
		{},
		"A heavy plate carrier - soak an extra hit or two"],

	["Body Remover", 1, "activation",
		{},
		{ [] call Waldo_fnc_removeBody },
		"Aim at a corpse and press your assigned key to destroy it, denying the Detective a body to test"],

	["C4 Charge", 2, "activation",
		{},
		{ [] call Waldo_fnc_placeC4 },
		"Drop a timed explosive at your feet - it blows in 15s unless someone defuses it"],

	["Night Vision", 1, "weapon",
		{ player addWeapon (missionNamespace getVariable ["ShopNVG", "NVGoggles"]); },
		{},
		"Night-vision goggles - own the dark rounds"],

	["Dead Ringer", 3, "activation",
		{},
		{ [] call Waldo_fnc_deadRinger },
		"Arms a 25s window: your next lethal hit is faked - you ragdoll like a kill and a decoy body appears, but you're not really dead"],

	["False Flag", 2, "passive",
		{ player setVariable ["Waldo_falseFlag", true, true]; hint "False Flag armed - your next kill will frame someone else."; },
		{},
		"Your next kill leaves an innocent bystander's DNA at the scene instead of yours"]
];

// --- Detective shop ---
Waldo_detectiveShop = [
	["Portable Tester", 1, "activation",
		{},
		{ [] call Waldo_fnc_tester },
		"Aim at a player or body within 3m and press your assigned key to reveal their role"],

	["DNA Scanner", 2, "activation",
		{},
		{ [] call Waldo_fnc_dnaScanner },
		"Aim at a body and press your assigned key to sample the killer's DNA, then track them down"],

	["Enhanced Scanner", 3, "passive",
		{ player setVariable ["Waldo_enhancedScanner", true, true]; },
		{},
		"Upgrades the DNA Scanner: longer/steadier tracking, half the contamination risk, and reveals time-of-death + weapon"],

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
		"Aim at a body and press your assigned key to bring them back"],

	["Frag Grenades", 1, "weapon",
		{ player addMagazines [(missionNamespace getVariable ["ShopFrag", "HandGrenade"]), 2]; },
		{},
		"Two fragmentation grenades"],

	["Body Armor", 2, "passive",
		{ player addVest (missionNamespace getVariable ["ShopArmorVest", "V_PlateCarrier2_rgr"]); },
		{},
		"A heavy plate carrier - stay standing long enough to catch the traitor"],

	["Medical Kit", 1, "weapon",
		{ player addItem "Medikit"; player addItem "FirstAidKit"; },
		{},
		"A medikit + first aid kit to patch yourself up"],

	["Binoculars", 1, "weapon",
		{ player addWeapon (missionNamespace getVariable ["ShopBinocular", "Binocular"]); },
		{},
		"Binoculars for watching suspects from range"],

	["Night Vision", 1, "weapon",
		{ player addWeapon (missionNamespace getVariable ["ShopNVG", "NVGoggles"]); },
		{},
		"Night-vision goggles - keep watch in the dark"]
];

diag_log "[Waldo] initShops: catalogs ready";
