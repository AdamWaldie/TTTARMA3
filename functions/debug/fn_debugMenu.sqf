//////////////////////////////////////////////////////////////////
// Waldo_fnc_debugMenu
// CLIENT: the in-game dev / test console. Opened with the '\' key, but ONLY
// when "Enable Testing Mode" (TestingFlag) is on, so a normal game never sees
// it. Data-driven like the shop: every tool is one row in _actions, so adding
// a new test action needs no UI edits.
//
// Row format:  [ _label, _tooltip, _code ]
//   _code is CODE  -> a clickable button; the code runs locally on click.
//   _code is ""    -> a full-width, non-clickable section header.
//
// Client-local work (godmode, heal, teleport, credits, shops, reveal) runs
// straight from the button. Anything that must stay server-authoritative
// (role changes, dummies, airdrops, win conditions, karma) is delegated to
// Waldo_fnc_debugAction via remoteExec so the round's lists and win checks
// remain valid.
//////////////////////////////////////////////////////////////////

if (!hasInterface) exitWith {};
if !(missionNamespace getVariable ["TestingFlag", false]) exitWith {};
disableSerialization;

// If it's already open, treat the key as a toggle and close it.
if !(isNull (uiNamespace getVariable ["WaldoDebug", displayNull])) exitWith {
	closeDialog 1;
};

// --- Status readout (top of the panel). Re-run after every action. ---
Waldo_fnc_debugStatus = {
	private _disp = uiNamespace getVariable ["WaldoDebug", displayNull];
	if (isNull _disp) exitWith {};
	private _role   = player getVariable ["role", "Innocent"];
	private _god    = player getVariable ["Waldo_debugGod", false];
	private _reveal = !isNil "Waldo_debugRevealEH";
	private _gameOn = missionNamespace getVariable ["gameOn", false];
	private _txt = format [
		"<t color='#ffbb00'>Role: </t>%1     <t color='#ffbb00'>Credits: </t>%2<br/>"
		+ "<t color='#ffbb00'>Godmode: </t>%3     <t color='#ffbb00'>Reveal: </t>%4     <t color='#ffbb00'>Round live: </t>%5<br/>"
		+ "<t color='#ffbb00'>Players: </t>%6     T:%7  D:%8  J:%9",
		_role, player getVariable ["points", 0],
		["off", "ON"] select _god,
		["off", "ON"] select _reveal,
		["no", "YES"] select _gameOn,
		count allPlayers,
		count (missionNamespace getVariable ["TraitorList", []]),
		count (missionNamespace getVariable ["DetectiveList", []]),
		count (missionNamespace getVariable ["JesterList", []])
	];
	(_disp displayCtrl 3101) ctrlSetStructuredText parseText _txt;
};

// --- Action catalog ---
private _actions = [
	["== ROLES (this round) ==", "", ""],
	["Become Innocent",  "Switch your role to Innocent",  { [player, "becomeRole", "Innocent"]  remoteExec ["Waldo_fnc_debugAction", 2]; }],
	["Become Traitor",   "Switch your role to Traitor",   { [player, "becomeRole", "Traitor"]   remoteExec ["Waldo_fnc_debugAction", 2]; }],
	["Become Detective", "Switch role + apply detective loadout", { [player, "becomeRole", "Detective"] remoteExec ["Waldo_fnc_debugAction", 2]; }],
	["Become Jester",    "Switch to Jester (bullets deal no damage)", { [player, "becomeRole", "Jester"] remoteExec ["Waldo_fnc_debugAction", 2]; }],

	["== CREDITS & SHOPS ==", "", ""],
	["+5 Credits",         "Add 5 shop credits",   { player setVariable ["points", (player getVariable ["points", 0]) + 5, true]; }],
	["+100 Credits",       "Add 100 shop credits", { player setVariable ["points", (player getVariable ["points", 0]) + 100, true]; }],
	["Open Traitor Shop",  "Inspect / buy-test the Traitor shop",   { closeDialog 1; ["Traitor"]   call Waldo_fnc_openBuyMenu; }],
	["Open Detective Shop","Inspect / buy-test the Detective shop", { closeDialog 1; ["Detective"] call Waldo_fnc_openBuyMenu; }],

	["== TEST DUMMIES ==", "", ""],
	["Spawn Innocent Dummy", "A shootable dummy in front of you (routes deaths through the kill handler)", { [player, "dummy", "Innocent"] remoteExec ["Waldo_fnc_debugAction", 2]; }],
	["Spawn Traitor Dummy",  "Kill it to test detective kill-credit",  { [player, "dummy", "Traitor"]  remoteExec ["Waldo_fnc_debugAction", 2]; }],
	["Spawn Jester Dummy",   "Kill it (as non-traitor) to test the Jester win", { [player, "dummy", "Jester"] remoteExec ["Waldo_fnc_debugAction", 2]; }],

	["== SYSTEMS ==", "", ""],
	["Spawn Airdrop Now", "Force a supply airdrop immediately",       { [player, "airdrop"]     remoteExec ["Waldo_fnc_debugAction", 2]; }],
	["Skip Warmup",       "End the role-selection warmup early",      { [player, "skipWarmup"]  remoteExec ["Waldo_fnc_debugAction", 2]; }],
	["Reset My Karma",    "Set your karma back to 100",               { [player, "resetKarma"]  remoteExec ["Waldo_fnc_debugAction", 2]; }],
	["Tank My Karma",     "Set your karma to 0 (test next-round penalty)", { [player, "lowKarma"] remoteExec ["Waldo_fnc_debugAction", 2]; }],

	["== WIN CONDITIONS ==", "", ""],
	["End: Innocents Win", "Force ending END1", { [player, "end", "END1"] remoteExec ["Waldo_fnc_debugAction", 2]; }],
	["End: Traitors Win",  "Force ending END2", { [player, "end", "END2"] remoteExec ["Waldo_fnc_debugAction", 2]; }],
	["End: Time Up",       "Force ending END3", { [player, "end", "END3"] remoteExec ["Waldo_fnc_debugAction", 2]; }],
	["End: Jester Wins",   "Force ending END4", { [player, "end", "END4"] remoteExec ["Waldo_fnc_debugAction", 2]; }],

	["== PLAYER ==", "", ""],
	["Toggle Godmode",       "Enable / disable damage immunity", {
		private _g = !(player getVariable ["Waldo_debugGod", false]);
		player setVariable ["Waldo_debugGod", _g];
		player allowDamage (!_g);
	}],
	["Heal Self",            "Restore full health", { player setDamage 0; }],
	["Teleport to Center",   "Jump to the arena centre", { player setPos (missionNamespace getVariable ["mapPos", getPosATL player]); }],
	["Toggle Reveal Roles",  "Show every unit's role in 3D (dev overlay)", {
		if (isNil "Waldo_debugRevealEH") then {
			Waldo_debugRevealEH = addMissionEventHandler ["Draw3D", {
				{
					private _p = getPosATL _x;
					_p set [2, (_p select 2) + 2];
					private _r = _x getVariable ["role", "Innocent"];
					drawIcon3D ["", ([_r] call Waldo_roleColor), _p, 1, 0, 0, _r, 2, 0.04, "PuristaMedium", "center"];
				} forEach (allUnits + allDeadMen);
			}];
		} else {
			removeMissionEventHandler ["Draw3D", Waldo_debugRevealEH];
			Waldo_debugRevealEH = nil;
		};
	}],

	["== ==", "", ""],
	["Close Menu", "Close this panel (or press \\)", { closeDialog 1; }]
];

createDialog "WaldoDebug";
waitUntil { !isNull (uiNamespace getVariable ["WaldoDebug", displayNull]) };
private _display = uiNamespace getVariable "WaldoDebug";

(_display displayCtrl 3100) ctrlSetText "Dev / Test Menu";

// --- Build the button grid (2 columns; headers span the full width). ---
private _group = _display displayCtrl 3102;
private _bw   = 0.205 * safezoneW;
private _bh   = 0.05  * safezoneH;
private _gapX = 0.008 * safezoneW;
private _gapY = 0.008 * safezoneH;
private _fullW = (2 * _bw) + _gapX;

private _row = 0;
private _col = 0;
private _idc = 3200;

{
	_x params ["_label", "_tip", "_code"];

	if (_code isEqualType "") then {
		// Section header: force onto a fresh row, full width, not clickable.
		if (_col != 0) then { _row = _row + 1; _col = 0; };
		private _hdr = _display ctrlCreate ["RscText", _idc, _group];
		_hdr ctrlSetPosition [0, _row * (_bh + _gapY), _fullW, _bh];
		_hdr ctrlSetText _label;
		_hdr ctrlSetTextColor [1, 0.73, 0, 1];
		_hdr ctrlSetBackgroundColor [0.14, 0.14, 0.14, 1];
		_hdr ctrlCommit 0;
		_row = _row + 1; _col = 0;
	} else {
		private _btn = _display ctrlCreate ["RscButton", _idc, _group];
		_btn ctrlSetPosition [_col * (_bw + _gapX), _row * (_bh + _gapY), _bw, _bh];
		_btn ctrlSetText _label;
		_btn ctrlSetTooltip _tip;
		_btn setVariable ["code", _code];
		_btn ctrlAddEventHandler ["ButtonClick", {
			params ["_ctrl"];
			call (_ctrl getVariable "code");
			call Waldo_fnc_debugStatus;
		}];
		_btn ctrlCommit 0;
		_col = _col + 1;
		if (_col >= 2) then { _col = 0; _row = _row + 1; };
	};

	_idc = _idc + 1;
} forEach _actions;

call Waldo_fnc_debugStatus;
