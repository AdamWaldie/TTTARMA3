//////////////////////////////////////////////////////////////////
// Waldo_fnc_registerActivationSlot
// CLIENT: assigns an already-logged activation purchase (by id) to the first
// free of the 3 key slots (Y/U/J), or the backlog if all 3 are already taken.
// Shared by Waldo_fnc_buyItem (a real purchase) and the debug menu's "Give
// All X Items" actions (a free grant) so both paths keep activation items
// usable through the same slot machinery instead of the debug grant silently
// doing nothing for them (all activation items' _onBuy is an empty {} by
// design - the real effect lives in _onAct, which only ever ran through this
// assignment).
//
// params: [_id]
// returns: the key label ("Y"/"U"/"J") it landed on, or "" if backlogged.
//////////////////////////////////////////////////////////////////

params ["_id"];

private _keyLabels = ["Y", "U", "J"];
private _slots = player getVariable ["Waldo_activationSlots", [-1, -1, -1]];
private _free = _slots findIf { _x < 0 };

if (_free < 0) exitWith {
	private _backlog = player getVariable ["Waldo_activationBacklog", []];
	_backlog pushBack _id;
	player setVariable ["Waldo_activationBacklog", _backlog];
	""
};

_slots set [_free, _id];
player setVariable ["Waldo_activationSlots", _slots];
_keyLabels select _free
