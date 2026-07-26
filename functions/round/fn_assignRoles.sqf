//////////////////////////////////////////////////////////////////
// Waldo_fnc_assignRoles
// SERVER: assigns roles for the round.
//
// TTT roles:
//   Innocent  - majority, no powers, wins when all Traitors are dead.
//   Traitor   - hidden minority, know each other, have a credit shop,
//               win by killing everyone who is not a Traitor.
//   Detective - a publicly-known Innocent with investigation tools + shop.
//   Jester    - deals no damage and cannot win normally; "wins" if a
//               NON-Traitor kills them. Traitors are told who they are.
//
// Selection uses shuffled candidate lists (pick once) instead of the old
// retry loops, which could spin forever when no valid candidate existed.
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

private _players = allPlayers;
private _realCount = count _players;
// Size-dependent maths (traitor count, starting credits, thresholds) scale to
// the effective count, which Testing Mode can override to simulate a big lobby
// solo. Actual role assignment is still clamped to the real players present.
private _count = ([] call Waldo_fnc_effectivePlayerCount) max _realCount;

// --- Reset per-round role state / player vars ---
missionNamespace setVariable ["JESTERCLEANKILL", false, true];
{
	_x setVariable ["role", "Innocent", true];
	_x setVariable ["points", 0, true];
	_x setVariable ["tested", false, true];
} forEach _players;

if (_realCount == 0) exitWith {
	diag_log "[Waldo][server] assignRoles: no players";
};

// Traitors & Detectives start with credits that scale with lobby size
// (configurable base, +1 per 8 players). Stored so other systems can reference it.
private _startCredits = (missionNamespace getVariable ["Waldo_startCreditsBase", 1]) + floor (_count / 8);
missionNamespace setVariable ["Waldo_startCredits", _startCredits, true];

// --- Traitors ---
private _lower = missionNamespace getVariable ["TraitorPercentageChanceLowerBound", 0.25];
private _upper = missionNamespace getVariable ["TraitorPercentageChanceHigherBound", 0.45];
private _chance = random [_lower, (_lower + _upper) / 2, _upper];
private _traitorCount = (round (_count * _chance)) max 1;
// Apply the lobby Minimum / Maximum Traitors clamps (max 0 = unlimited)...
_traitorCount = _traitorCount max (missionNamespace getVariable ["Waldo_minTraitors", 1]);
private _maxT = missionNamespace getVariable ["Waldo_maxTraitors", 0];
if (_maxT > 0) then { _traitorCount = _traitorCount min _maxT; };
// ...but never more traitors than there are real players to assign them to.
_traitorCount = _traitorCount min _realCount;

private _pool = (+_players) call BIS_fnc_arrayShuffle;
private _traitors = [];
for "_i" from 0 to (_traitorCount - 1) do {
	if (_i < count _pool) then { _traitors pushBack (_pool select _i); };
};
{
	_x setVariable ["role", "Traitor", true];
	_x setVariable ["points", _startCredits, true];
} forEach _traitors;
missionNamespace setVariable ["TraitorList", _traitors, true];

// Record whether a non-Traitor side existed at all this round. checkWin gates
// the Traitors-win ending on this, so an all-Traitor lobby can never insta-win
// and a lone tester never ends themselves. Uses REAL players (sim players added
// later from the dev menu set this true themselves).
missionNamespace setVariable ["Waldo_hadNonTraitors", (_realCount - (count _traitors)) > 0, true];

// --- Detective (lobby-toggleable; needs the min-players count, not a Traitor) ---
private _detMin = missionNamespace getVariable ["DetectiveMinPlayers", 5];
private _detectives = [];
if ((missionNamespace getVariable ["DetectiveEnabled", true]) && {_count >= _detMin}) then {
	private _candidates = _players select { !(_x in _traitors) };
	if (count _candidates > 0) then {
		private _det = selectRandom _candidates;
		// Loadout must be applied where the detective is local.
		[_det] remoteExec ["Waldo_fnc_applyDetectiveLoadout", _det];
		_det setVariable ["role", "Detective", true];
		_det setVariable ["points", _startCredits, true];
		_detectives pushBack _det;
		["There Is A Detective This Round"] remoteExec ["systemChat", -2];
	};
};
missionNamespace setVariable ["DetectiveList", _detectives, true];

// --- Jester (optional; >= 5 players; not Traitor/Detective) ---
// The old chance check compared a 0..100 roll to a 0..1 fraction, so the
// Jester almost never appeared. Compare against the fraction directly.
private _jesters = [];
if ((missionNamespace getVariable ["JesterEnabled", false]) && {_count >= _detMin}) then {
	// "Jester: Always Appears" skips the chance roll.
	private _jchance = missionNamespace getVariable ["JesterPercentagechance", 0.3];
	private _jRoll = (missionNamespace getVariable ["JesterAlways", false]) || {random 1 <= _jchance};
	if (_jRoll) then {
		private _candidates = _players select { !(_x in _traitors) && !(_x in _detectives) };
		if (count _candidates > 0) then {
			private _jester = selectRandom _candidates;
			_jester setVariable ["role", "Jester", true];
			// Jester deals no damage. The Fired EH only triggers where the unit
			// is local, so install it on the Jester's own machine.
			[] remoteExec ["Waldo_fnc_makeJester", _jester];
			_jesters pushBack _jester;
			["There Is A Jester This Round"] remoteExec ["systemChat", -2];
		};
	};
};
missionNamespace setVariable ["JesterList", _jesters, true];

// --- Karma: apply carry-over penalties now that starting points are set ---
if (missionNamespace getVariable ["KarmaEnabled", true]) then { [] call Waldo_fnc_applyKarma; };

diag_log format ["[Waldo][server] assignRoles: players=%1 traitors=%2 detectives=%3 jesters=%4",
	_count, count _traitors, count _detectives, count _jesters];
