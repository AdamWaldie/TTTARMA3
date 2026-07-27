//////////////////////////////////////////////////////////////////
// Waldo_fnc_topBarTimer
// CLIENT: drives the top bar's round-timer text (idc 3603 in the TTTHud
// title resource). Started exactly ONCE per client session, from
// fn_initClient.sqf, immediately after that file's own `waitUntil { gameOn }`
// - by the time this runs, the round is genuinely live and
// Waldo_startTime/timelimit are already broadcast, so no extra readiness
// gating is needed here. Unlike fn_initHud.sqf (which re-runs on every
// respawn/role change), this function's caller only ever runs once, so no
// duplicate-start guard is needed either.
//
// Computes the countdown locally every second from state the server already
// publishes (Waldo_startTime, timelimit, Waldo_roundLiveAt, gameOn) instead
// of the old approach (Waldo_fnc_roundLoop remoteExec-ing a formatted
// hintSilent string to every client every second) - one less per-second
// broadcast, and each client trusts its own local `time` (kept in sync with
// the server automatically by the engine) rather than a string that could
// arrive late under network jitter.
//
// Exits cleanly the moment gameOn goes false - the round is over (about to
// restart the whole mission, per this ruleset), nothing left to count down.
//////////////////////////////////////////////////////////////////

if (!hasInterface) exitWith {};

waitUntil { !isNull (uiNamespace getVariable ["TTTHud", displayNull]) };
private _display = uiNamespace getVariable "TTTHud";
private _timerCtrl = _display displayCtrl 3603;

private _fmt = {
	params ["_s"];
	private _clamped = 0 max _s;
	private _m = floor (_clamped / 60);
	private _sec = floor (_clamped % 60);
	format ["%1:%2", _m, [str _sec, "0" + str _sec] select (_sec < 10)]
};

// Measure and position once against a representative string - every value
// this ever displays is the same handful of fixed-width characters (digits,
// a colon, optional " (M:SS)"), so its rendered height never meaningfully
// changes between ticks. Re-measuring every second would just be redundant
// work, and risks visible sub-pixel jitter for zero benefit.
_timerCtrl ctrlSetText "0:00";
private _boxX = (safezoneX + (0.5 * safezoneW)) - (0.15 * safezoneW);
private _boxY = safezoneY + (0.015 * safezoneH);
private _boxW = 0.30 * safezoneW;
private _boxH = 0.062 * safezoneH;
private _textH = ctrlTextHeight _timerCtrl;
_timerCtrl ctrlSetPosition [_boxX, _boxY + ((_boxH - _textH) / 2), _boxW, _textH];
_timerCtrl ctrlCommit 0;

while { missionNamespace getVariable ["gameOn", false] } do {
	private _start     = missionNamespace getVariable ["Waldo_startTime", 180];
	private _timelimit = missionNamespace getVariable ["timelimit", _start];
	private _liveAt    = missionNamespace getVariable ["Waldo_roundLiveAt", time];
	private _elapsed   = time - _liveAt;

	private _civRemaining = _start - _elapsed;
	private _text = if (_civRemaining <= 0) then { "OVERTIME" } else { [_civRemaining] call _fmt };

	// The traitor deadline (timelimit) runs longer than the civilian clock and
	// grows on every death (Waldo_fnc_onKilled) - only traitors are told it,
	// same distinction the old server-side hint made.
	if ((player getVariable ["role", ""]) == "Traitor") then {
		private _traitorRemaining = _timelimit - _elapsed;
		_text = _text + format [" (%1)", [_traitorRemaining] call _fmt];
	};

	_timerCtrl ctrlSetText _text;
	sleep 1;
};
