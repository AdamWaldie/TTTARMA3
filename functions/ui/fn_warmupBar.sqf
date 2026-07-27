//////////////////////////////////////////////////////////////////
// Waldo_fnc_warmupBar
// CLIENT: shows "Selecting Roles: N" in the same centre-top position/casing
// as the round timer (TTTWarmup, a separate titleRsc from TTTHud - role isn't
// assigned yet at this point, so there's nothing for TTTHud itself to show).
// Computes the countdown locally from Waldo_warmupEndAt (the server `time`
// warmup ends at, broadcast once) instead of the old per-second remoteExec'd
// hint, same reasoning as Waldo_fnc_topBarTimer.
//
// Exits the moment any of: the countdown reaches 0, the debug "Skip Warmup"
// flag flips true (Waldo_debugSkipWarmup, broadcast globally by the dev
// menu), or gameOn goes true - whichever the loop notices first. TTTHud's
// own titleRsc call (Waldo_fnc_initHud, at round-live) evicts this display
// the normal way once the round actually starts, so no explicit close/hide
// is needed here even if this loop exits a little before that happens.
//////////////////////////////////////////////////////////////////

if (!hasInterface) exitWith {};

waitUntil { !isNull (uiNamespace getVariable ["TTTWarmup", displayNull]) || {missionNamespace getVariable ["gameOn", false]} };
if (missionNamespace getVariable ["gameOn", false]) exitWith {};   // already live by the time this got here - nothing to show

private _display = uiNamespace getVariable "TTTWarmup";
private _textCtrl = _display displayCtrl 3630;

private _boxX = (safezoneX + (0.5 * safezoneW)) - (0.18 * safezoneW);
private _boxY = safezoneY + (0.015 * safezoneH);
private _boxW = 0.36 * safezoneW;
private _boxH = 0.062 * safezoneH;

_textCtrl ctrlSetText "Selecting Roles: 0";
private _textH = ctrlTextHeight _textCtrl;
_textCtrl ctrlSetPosition [_boxX, _boxY + ((_boxH - _textH) / 2), _boxW, _textH];
_textCtrl ctrlCommit 0;

while { !(missionNamespace getVariable ["gameOn", false]) } do {
	if (missionNamespace getVariable ["Waldo_debugSkipWarmup", false]) exitWith {};
	private _endAt = missionNamespace getVariable ["Waldo_warmupEndAt", time];
	private _remaining = ceil (0 max (_endAt - time));
	_textCtrl ctrlSetText format ["Selecting Roles: %1", _remaining];
	if (_remaining <= 0) exitWith {};   // warmup's over - TTTHud takes over at round-live
	sleep 0.25;
};
