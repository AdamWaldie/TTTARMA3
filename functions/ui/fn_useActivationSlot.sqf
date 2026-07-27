//////////////////////////////////////////////////////////////////
// Waldo_fnc_useActivationSlot
// CLIENT: fires the activation item currently bound to the given key slot
// (0 = Y, 1 = U, 2 = J). Slots only ever store a purchase id (see
// Waldo_fnc_buyItem / Waldo_fnc_assignActivationSlot), never the code block
// itself, so the record is looked up fresh from Waldo_purchases every time.
//
// On success (the item's _onAct returns true, i.e. consumed) the slot is
// cleared and the oldest backlogged item (if any) is promoted into it, so a
// spare activation item bought beyond the 3 slots is never left stranded.
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
private _ok = call _onAct;

if (_ok isEqualType true && {_ok}) then {
	private _backlog = player getVariable ["Waldo_activationBacklog", []];
	private _next = -1;
	if (count _backlog > 0) then { _next = _backlog deleteAt 0; };
	_slots set [_slotIdx, _next];
	player setVariable ["Waldo_activationSlots", _slots];
	player setVariable ["Waldo_activationBacklog", _backlog];
};
