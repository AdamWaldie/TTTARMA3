//////////////////////////////////////////////////////////////////
// Waldo_fnc_useActivationSlot
// CLIENT: fires the activation item currently bound to the given key slot
// (0 = Y, 1 = U, 2 = J). Slots only ever store a purchase id (see
// Waldo_fnc_buyItem / Waldo_fnc_assignActivationSlot), never the code block
// itself, so the record is looked up fresh from Waldo_purchases every time.
//
// On success (the item's _onAct returns true, i.e. consumed) the slot is
// cleared and the oldest backlogged item (if any) is promoted into it, so a
// spare activation item bought beyond the 3 slots is never left stranded -
// see Waldo_fnc_consumeActivationItem, which does that part.
//
// params: [_slotIdx]
//////////////////////////////////////////////////////////////////

params ["_slotIdx"];

private _slots = player getVariable ["Waldo_activationSlots", [-1, -1, -1]];
private _id = _slots select _slotIdx;
if (_id < 0) exitWith {};

private _purchases = player getVariable ["Waldo_purchases", []];
private _recIdx = _purchases findIf { (_x select 0) == _id };
if (_recIdx < 0) exitWith {};   // stale id - never call nil code

(_purchases select _recIdx) params ["", "", "", "", "_onAct"];
// _id/_slotIdx are passed through as this call's args - every existing
// _onAct block ignores them (SQF discards unused params, so this is
// backward compatible), but an item whose real "was it used" outcome only
// resolves LATER, after some async UI interaction rather than at the
// instant the key is pressed (see Waldo_fnc_disguiser/
// Waldo_fnc_disguiserActivate), needs them to self-consume via
// Waldo_fnc_consumeActivationItem once that later outcome actually happens.
private _ok = [_id, _slotIdx] call _onAct;

if (_ok isEqualType true && {_ok}) then {
	[_id, _slotIdx] call Waldo_fnc_consumeActivationItem;
};
