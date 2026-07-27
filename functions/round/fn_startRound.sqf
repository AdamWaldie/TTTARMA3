//////////////////////////////////////////////////////////////////
// Waldo_fnc_startRound
// SERVER: computes round timers and flips the round live.
//   Waldo_startTime   = base + (players * perPlayer)  -> the civilian clock
//   timelimit         = Waldo_startTime + traitorBonus -> the hard deadline
//   Waldo_roundLiveAt = the `time` this round actually went live -> lets every
//                       client compute its own countdown locally (Waldo_fnc_topBarTimer)
//                       as (Waldo_startTime - (time - Waldo_roundLiveAt)), instead of
//                       the server remoteExec-ing a formatted string every second.
//                       `time` is the engine's own synchronised mission clock,
//                       already consistent across server and clients.
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

private _count = ([] call Waldo_fnc_effectivePlayerCount) max 1;
private _base = missionNamespace getVariable ["roundBaseLength", 180];
private _perPlayer = missionNamespace getVariable ["roundPlayerLength", 30];
private _traitorBonus = missionNamespace getVariable ["roundTraitorLength", 45];

private _start = (round (_count * _perPlayer)) + _base;
missionNamespace setVariable ["Waldo_startTime", _start, true];
missionNamespace setVariable ["timelimit", _start + _traitorBonus, true];
missionNamespace setVariable ["Waldo_roundLiveAt", time, true];
missionNamespace setVariable ["gameOn", true, true];
