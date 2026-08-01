//////////////////////////////////////////////////////////////////
// Waldo_fnc_consumeActivationItem
// CLIENT: clears an activation item's assigned key slot and promotes the
// oldest backlogged item (if any) into it - the same bookkeeping
// Waldo_fnc_useActivationSlot does inline when an item's _onAct returns true
// synchronously. Factored out here so an item whose real "was it used"
// outcome only resolves LATER, after some async UI interaction rather than
// at the instant the key is pressed (see Waldo_fnc_disguiser/
// Waldo_fnc_disguiserActivate), can consume itself the same way once that
// later outcome actually happens, instead of the key press itself.
//
// Doesn't touch Waldo_purchases - that list is a per-round purchase HISTORY
// (see Waldo_shopRenderPurchased's "[used]" tag), not an inventory, and the
// original inline version never removed entries from it either.
//
// params: [_purchId, _slotIdx]
//////////////////////////////////////////////////////////////////

params ["_purchId", "_slotIdx"];

private _slots = player getVariable ["Waldo_activationSlots", [-1, -1, -1]];
if (_slotIdx < 0 || {_slotIdx >= count _slots} || {(_slots select _slotIdx) != _purchId}) exitWith {};

private _backlog = player getVariable ["Waldo_activationBacklog", []];
private _next = -1;
if (count _backlog > 0) then { _next = _backlog deleteAt 0; };
_slots set [_slotIdx, _next];
player setVariable ["Waldo_activationSlots", _slots];
player setVariable ["Waldo_activationBacklog", _backlog];
