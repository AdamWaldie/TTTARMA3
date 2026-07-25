//////////////////////////////////////////////////////////////////
// Waldo_fnc_startRound
// SERVER: computes round timers and flips the round live.
//   Waldo_startTime = base + (players * perPlayer)  -> the civilian clock
//   timelimit       = Waldo_startTime + traitorBonus -> the hard deadline
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

private _count = (count allPlayers) max 1;
private _base = missionNamespace getVariable ["roundBaseLength", 180];
private _perPlayer = missionNamespace getVariable ["roundPlayerLength", 30];
private _traitorBonus = missionNamespace getVariable ["roundTraitorLength", 45];

private _start = (round (_count * _perPlayer)) + _base;
missionNamespace setVariable ["Waldo_startTime", _start, true];
missionNamespace setVariable ["timelimit", _start + _traitorBonus, true];
missionNamespace setVariable ["gameOn", true, true];
