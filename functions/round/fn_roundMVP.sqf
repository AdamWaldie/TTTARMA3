//////////////////////////////////////////////////////////////////
// Waldo_fnc_roundMVP
// SERVER: finds the player with the most kills this round (Waldo_roundKills,
// tracked in Waldo_fnc_onKilled and reset each round in Waldo_fnc_assignRoles)
// and broadcasts a celebration to everyone (Waldo_fnc_mvpCelebrate) before the
// round actually ends, so it has time to play. Called from Waldo_fnc_endRound.
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

private _candidates = allPlayers select { (_x getVariable ["Waldo_roundKills", 0]) > 0 };
private _best = 0;
{
	private _k = _x getVariable ["Waldo_roundKills", 0];
	if (_k > _best) then { _best = _k; };
} forEach _candidates;
// Pick randomly among anyone tied for the top score, rather than always
// favouring whoever happens to come first in allPlayers' (arbitrary) order.
private _topScorers = _candidates select { (_x getVariable ["Waldo_roundKills", 0]) == _best };
private _mvp = if (count _topScorers > 0) then { selectRandom _topScorers } else { objNull };

private _name = if (isNull _mvp) then { "" } else { name _mvp };
private _role = if (isNull _mvp) then { "" } else { _mvp getVariable ["role", "Innocent"] };

[_name, _role, _best] remoteExec ["Waldo_fnc_mvpCelebrate", 0];
diag_log format ["[Waldo][server] roundMVP: %1", ([format ["%1 (%2 kills)", _name, _best], "no kills this round"] select (_name == ""))];

sleep 6;   // let the celebration play before the mission restarts
