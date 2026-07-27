//////////////////////////////////////////////////////////////////
// Waldo_fnc_roundLoop
// SERVER: the 1 Hz round loop. Triggers airdrops and checks win conditions.
// Blocks until the round ends.
//
// No longer formats/broadcasts a per-second HUD hint - the client-side top
// bar (Waldo_fnc_topBarTimer) computes and renders its own countdown locally
// from the timer state already published below, instead of the server
// remoteExec-ing a formatted string to every client every second.
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

private _start = missionNamespace getVariable ["Waldo_startTime", 180];

private _airdropWait = round ((random (missionNamespace getVariable ["airdropRandomTimer", 75])) + (missionNamespace getVariable ["airdropBaseTimer", 75]));
private _airdropTimer = 0;
private _timer = 0;

while { missionNamespace getVariable ["gameOn", false] } do {

	private _timelimit = missionNamespace getVariable ["timelimit", _start];

	// Dev/test: a frozen round keeps rendering the HUD but stops the clock,
	// airdrops and win checks so a system can be inspected mid-round. Always
	// false in a normal game, so live behaviour is unchanged.
	private _frozen = (missionNamespace getVariable ["TestingFlag", false])
		&& {missionNamespace getVariable ["Waldo_debugFreeze", false]};

	// --- Airdrop ---
	if (!_frozen && {missionNamespace getVariable ["airdrop", true]} && {_airdropTimer + 1 >= _airdropWait}) then {
		[] call Waldo_fnc_spawnAirdrop;
		_airdropWait = round ((random (missionNamespace getVariable ["airdropRandomTimer", 75])) + (missionNamespace getVariable ["airdropBaseTimer", 75]));
		_airdropTimer = 0;
	};

	// --- Win check ---
	private _ending = "";
	if (!_frozen) then { _ending = [_timer, _timelimit] call Waldo_fnc_checkWin; };
	if (_ending != "") exitWith { [_ending] call Waldo_fnc_endRound; };

	sleep 1;
	if (!_frozen) then {
		_timer = _timer + 1;
		_airdropTimer = _airdropTimer + 1;
	} else {
		// The client-side top bar computes its own elapsed time as
		// (time - Waldo_roundLiveAt), using the engine's own always-advancing
		// clock - bumping the reference point forward by the same second that
		// just passed keeps that computed value frozen in lockstep with
		// _timer above, instead of the on-screen countdown quietly ticking
		// down through a freeze that's supposed to pause everything.
		missionNamespace setVariable ["Waldo_roundLiveAt", (missionNamespace getVariable ["Waldo_roundLiveAt", time]) + 1, true];
	};
};
