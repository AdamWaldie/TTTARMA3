//////////////////////////////////////////////////////////////////
// Waldo_fnc_applyKarma
// SERVER: applies carry-over karma at the start of a round, then decays it.
//
// Karma is stored per player UID in profileNamespace (the only store that
// survives the per-round mission restart). Killing a teammate (RDM) lowers
// it in Waldo_fnc_onKilled. Here we:
//   - punish low-karma players (start with no credits + public warning),
//   - DECAY everyone back toward neutral so punishment is never permanent
//     (this is the fix for "bugs out on repeat" caused by the old flag that
//      was written every round but never reset),
//   - PRUNE stored karma for UIDs no longer present so the profile can't
//     grow without bound.
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

private _lowThreshold = 50;   // below this: no starting credits + warning
private _decay = 10;          // karma regained each round
private _maxKarma = 100;

{
	private _uid = getPlayerUID _x;
	if (_uid != "") then {
		private _key = "Waldo_karma_" + _uid;
		private _k = profileNamespace getVariable [_key, _maxKarma];

		if (_k < _lowThreshold) then {
			_x setVariable ["points", 0, true];
			[format ["%1 has low karma and starts with no credits - play fair!", name _x]] remoteExec ["systemChat", 0];
		};

		// decay toward neutral
		profileNamespace setVariable [_key, (_k + _decay) min _maxKarma];
	};
} forEach allPlayers;

// Prune karma entries for UIDs that are not currently present.
private _presentUids = allPlayers apply { getPlayerUID _x };
{
	if ((_x select [0, 12]) == "Waldo_karma_") then {
		private _uid = _x select [12];
		if !(_uid in _presentUids) then { profileNamespace setVariable [_x, nil]; };
	};
} forEach (allVariables profileNamespace);

saveProfileNamespace;
