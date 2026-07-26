//////////////////////////////////////////////////////////////////
// Waldo_fnc_buyItem
// CLIENT: handles one purchase - checks credits, deducts, runs the buy effect,
// and (for activation items) queues the activation for the Y key.
//
// The shop is left OPEN after a purchase so the player can keep browsing; the
// header credits and each card's affordability are refreshed live, and the
// footer confirms the buy. Activation items are stored in a LIFO queue so buying
// a passive item after an activation item never wipes the pending activation.
//
// params: [_role, _index]
//////////////////////////////////////////////////////////////////

params ["_role", "_index"];
disableSerialization;

private _catalog = if (_role == "Traitor") then { Waldo_traitorShop } else { Waldo_detectiveShop };
if (_index < 0 || _index >= count _catalog) exitWith {};

private _item = _catalog select _index;
_item params ["_name", "_cost", "_type", "_onBuy", "_onAct", "_tip"];

private _pts  = player getVariable ["points", 0];
private _disp = uiNamespace getVariable ["WaldoShop", displayNull];

if (_pts < _cost) exitWith {
	if (isNull _disp) then {
		hint "[X] Not enough credits.";
	} else {
		(_disp displayCtrl 1103) ctrlSetStructuredText parseText (format [
			"<t size='1.15' color='#E4514B'>[X] NOT ENOUGH CREDITS</t><br/><t size='0.95' color='#F2EFE3'>%1 costs %2 - you have %3.</t>",
			_name, _cost, _pts
		]);
	};
};

private _new = _pts - _cost;
player setVariable ["points", _new, true];

// Immediate purchase effect.
call _onBuy;

// Queue activation items for the Y key.
if (_type == "activation") then {
	private _q = player getVariable ["activationQueue", []];
	_q pushBack [_name, _onAct];
	player setVariable ["activationQueue", _q];
};

// Log the purchase (name + how-to-use tip) for the shop's "Purchased" panel.
private _purchases = player getVariable ["Waldo_purchases", []];
_purchases pushBack [_name, _tip];
player setVariable ["Waldo_purchases", _purchases];

if (isNull _disp) exitWith {
	if (_type == "activation") then { hint format ["%1 ready - press Y to use.", _name]; };
};

[_disp] call Waldo_shopRenderPurchased;

// --- Refresh the open shop: credits, card affordability, and a confirmation. ---
(_disp displayCtrl 1101) ctrlSetText (format ["%1 CREDITS", _new]);

private _color = [_role] call Waldo_roleColor;
{
	_x params ["", "_c"];
	private _btn = _disp displayCtrl (2000 + _forEachIndex);
	if (!isNull _btn) then {
		if (_new >= _c) then {
			_btn ctrlSetBackgroundColor [_color select 0, _color select 1, _color select 2, 0.85];
			_btn ctrlSetTextColor [0.95, 0.93, 0.86, 1];
		} else {
			_btn ctrlSetBackgroundColor [0.06, 0.065, 0.055, 0.92];
			_btn ctrlSetTextColor [0.75, 0.42, 0.4, 1];
		};
	};
} forEach _catalog;

private _extra = if (_type == "activation") then { " - press Y to use" } else { "" };
(_disp displayCtrl 1103) ctrlSetStructuredText parseText (format [
	"<t size='1.2' color='#6FCB74'>[OK] PURCHASED: %1</t><t size='0.95' color='#9EA290'>%2</t><br/><t size='0.95' color='#9EA290'>%3 credits remaining.</t>",
	_name, _extra, _new
]);
