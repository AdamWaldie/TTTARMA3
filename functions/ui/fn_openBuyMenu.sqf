//////////////////////////////////////////////////////////////////
// Waldo_fnc_openBuyMenu
// CLIENT: opens the shared shop dialog and generates its item cards at runtime
// from the role's catalog (Waldo_traitorShop / Waldo_detectiveShop). One layout
// serves both shops; adding an item needs no UI edits.
//
// The panel has a role-tinted header (title + live credits), a scrollable grid
// of item cards coloured by affordability, and a description footer that updates
// as you hover a card. Clicking a card buys it (Waldo_fnc_buyItem).
//
// params: [_role]  ("Traitor" | "Detective")
//////////////////////////////////////////////////////////////////

params ["_role"];
disableSerialization;

private _catalog = if (_role == "Traitor") then { Waldo_traitorShop } else { Waldo_detectiveShop };
private _color = [_role] call Waldo_roleColor;

// Role colour as a #rrggbb string for the structured-text description footer.
private _hex = {
	params ["_c"];
	private _d = "0123456789abcdef";
	private _byte = { params ["_v"]; private _n = (round (_v * 255)) max 0 min 255; (_d select [floor (_n / 16), 1]) + (_d select [_n mod 16, 1]) };
	"#" + ([_c select 0] call _byte) + ([_c select 1] call _byte) + ([_c select 2] call _byte)
};
private _colorHex = [_color] call _hex;

private _typeLabel = {
	params ["_t"];
	switch (_t) do {
		case "weapon":     { "Weapon" };
		case "passive":    { "Passive" };
		case "activation": { "Activation - press Y to use" };
		default            { _t };
	};
};

createDialog "WaldoShop";
waitUntil { !isNull (uiNamespace getVariable ["WaldoShop", displayNull]) };
private _display = uiNamespace getVariable "WaldoShop";

// --- Header ---
(_display displayCtrl 1104) ctrlSetBackgroundColor [_color select 0, _color select 1, _color select 2, 0.9];
(_display displayCtrl 1100) ctrlSetText (format ["%1 Armory", _role]);

private _credits = player getVariable ["points", 0];
(_display displayCtrl 1101) ctrlSetText (format ["%1 credits", _credits]);

// --- Default footer hint ---
(_display displayCtrl 1103) ctrlSetStructuredText parseText (
	"<t size='1.0' color='#9a9a9a'>Hover an item for details. Click to buy. Press Esc to close.</t>"
);

// --- Item cards ---
private _group = _display displayCtrl 1102;
private _cols = 2;
private _bw   = 0.202 * safezoneW;
private _bh   = 0.072 * safezoneH;
private _gapX = 0.012 * safezoneW;
private _gapY = 0.012 * safezoneH;

{
	_x params ["_name", "_cost", "_type", "_onBuy", "_onAct", "_tip"];
	private _i  = _forEachIndex;
	private _cx = _i mod _cols;
	private _cy = floor (_i / _cols);
	private _afford = _credits >= _cost;

	private _btn = _display ctrlCreate ["RscButton", 2000 + _i, _group];
	_btn ctrlSetPosition [_cx * (_bw + _gapX), _cy * (_bh + _gapY), _bw, _bh];
	_btn ctrlSetText (format ["%1      %2 cr", _name, _cost]);
	_btn ctrlSetTooltip _tip;
	_btn ctrlSetFontHeight (0.85 * (_bh min (0.04 * safezoneH)));

	if (_afford) then {
		_btn ctrlSetBackgroundColor [_color select 0, _color select 1, _color select 2, 0.85];
		_btn ctrlSetTextColor [1, 1, 1, 1];
	} else {
		_btn ctrlSetBackgroundColor [0.14, 0.14, 0.15, 0.9];
		_btn ctrlSetTextColor [0.72, 0.4, 0.4, 1];
	};

	// Pre-format the hover description shown in the footer (idc 1103).
	private _afHex = ["#ffd23f", "#e06666"] select (!_afford);
	_btn setVariable ["descText", format [
		"<t size='1.3' color='%1'>%2</t>   <t size='1.1' color='%3'>%4 cr</t>   <t size='0.9' color='#9a9a9a'>%5</t><br/><br/><t size='1.05'>%6</t>",
		_colorHex, _name, _afHex, _cost, ([_type] call _typeLabel), _tip
	]];
	_btn setVariable ["role", _role];
	_btn setVariable ["itemIndex", _i];

	_btn ctrlAddEventHandler ["MouseEnter", {
		params ["_ctrl"];
		(ctrlParent _ctrl displayCtrl 1103) ctrlSetStructuredText parseText (_ctrl getVariable ["descText", ""]);
	}];
	_btn ctrlAddEventHandler ["ButtonClick", {
		params ["_ctrl"];
		[(_ctrl getVariable "role"), (_ctrl getVariable "itemIndex")] call Waldo_fnc_buyItem;
	}];
	_btn ctrlCommit 0;
} forEach _catalog;
