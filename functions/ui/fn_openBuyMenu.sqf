//////////////////////////////////////////////////////////////////
// Waldo_fnc_openBuyMenu
// CLIENT: opens the shared shop dialog and generates its buttons at runtime
// from the role's catalog (Waldo_traitorShop / Waldo_detectiveShop). One
// layout serves both shops; adding an item needs no UI edits.
//
// params: [_role]  ("Traitor" | "Detective")
//////////////////////////////////////////////////////////////////

params ["_role"];
disableSerialization;

private _catalog = if (_role == "Traitor") then { Waldo_traitorShop } else { Waldo_detectiveShop };
private _color = [_role] call Waldo_roleColor;

createDialog "WaldoShop";
waitUntil { !isNull (uiNamespace getVariable ["WaldoShop", displayNull]) };
private _display = uiNamespace getVariable "WaldoShop";

// Header + credits
(_display displayCtrl 1100) ctrlSetText (format ["%1 Shop", _role]);
(_display displayCtrl 1100) ctrlSetTextColor _color;

private _credits = player getVariable ["points", 0];
(_display displayCtrl 1101) ctrlSetText (format ["Credits: %1", _credits]);
(_display displayCtrl 1101) ctrlSetTextColor _color;

// Generate the button grid inside the controls group (idc 1102).
private _group = _display displayCtrl 1102;
private _cols = 2;
private _bw = 0.09 * safezoneW;
private _bh = 0.075 * safezoneH;
private _gapX = 0.012 * safezoneW;
private _gapY = 0.014 * safezoneH;

{
	_x params ["_name", "_cost", "_type", "_onBuy", "_onAct", "_tip"];
	private _i = _forEachIndex;
	private _cx = _i mod _cols;
	private _cy = floor (_i / _cols);

	private _btn = _display ctrlCreate ["RscButton", 2000 + _i, _group];
	_btn ctrlSetPosition [_cx * (_bw + _gapX), _cy * (_bh + _gapY), _bw, _bh];
	_btn ctrlSetText (format ["%1  [%2 cr]", _name, _cost]);
	_btn ctrlSetTooltip _tip;
	_btn ctrlSetBackgroundColor _color;
	_btn ctrlEnable (_credits >= _cost);
	_btn setVariable ["role", _role];
	_btn setVariable ["itemIndex", _i];
	_btn ctrlAddEventHandler ["ButtonClick", {
		params ["_ctrl"];
		[(_ctrl getVariable "role"), (_ctrl getVariable "itemIndex")] call Waldo_fnc_buyItem;
	}];
	_btn ctrlCommit 0;
} forEach _catalog;
