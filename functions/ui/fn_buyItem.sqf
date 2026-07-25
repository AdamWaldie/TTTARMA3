//////////////////////////////////////////////////////////////////
// Waldo_fnc_buyItem
// CLIENT: handles one purchase - checks credits, deducts, runs the buy
// effect, and (for activation items) queues the activation for the Y key.
//
// Activation items are stored in a LIFO queue instead of a single "powerup"
// slot, so buying a passive item after an activation item no longer wipes
// the activation (the old single-slot bug where Y stopped working).
//
// params: [_role, _index]
//////////////////////////////////////////////////////////////////

params ["_role", "_index"];

private _catalog = if (_role == "Traitor") then { Waldo_traitorShop } else { Waldo_detectiveShop };
if (_index < 0 || _index >= count _catalog) exitWith {};

private _item = _catalog select _index;
_item params ["_name", "_cost", "_type", "_onBuy", "_onAct", "_tip"];

private _pts = player getVariable ["points", 0];
if (_pts < _cost) exitWith { hint "Not enough credits."; };

player setVariable ["points", _pts - _cost, true];

// Immediate purchase effect.
call _onBuy;

// Queue activation items for the Y key.
if (_type == "activation") then {
	private _q = player getVariable ["activationQueue", []];
	_q pushBack [_name, _onAct];
	player setVariable ["activationQueue", _q];
	hint format ["%1 ready - press Y to use.", _name];
};

closeDialog 1;
