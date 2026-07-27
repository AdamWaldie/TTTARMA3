//////////////////////////////////////////////////////////////////
// Waldo_fnc_assignActivationSlot
// CLIENT: moves an owned, not-yet-used activation item into the given key
// slot (0 = Y, 1 = U, 2 = J) from the buy menu's Purchased panel. Whatever
// already occupies that slot is bumped to the backlog rather than discarded -
// it stays fully usable, it just needs reassigning to a free/other slot.
//
// params: [_id, _slotIdx]
//////////////////////////////////////////////////////////////////

params ["_id", "_slotIdx"];

private _slots = player getVariable ["Waldo_activationSlots", [-1, -1, -1]];
if ((_slots select _slotIdx) == _id) exitWith {};   // already there

private _backlog = player getVariable ["Waldo_activationBacklog", []];

// Pull _id out of wherever it currently lives (another slot, or the backlog)
// before placing it, so it can never end up assigned to two slots at once.
private _fromSlot = _slots findIf { _x == _id };
if (_fromSlot >= 0) then { _slots set [_fromSlot, -1]; };
_backlog = _backlog - [_id];

// Bump whatever already occupies the destination slot back to the backlog.
private _bumped = _slots select _slotIdx;
if (_bumped >= 0) then { _backlog pushBack _bumped; };

_slots set [_slotIdx, _id];

player setVariable ["Waldo_activationSlots", _slots];
player setVariable ["Waldo_activationBacklog", _backlog];
