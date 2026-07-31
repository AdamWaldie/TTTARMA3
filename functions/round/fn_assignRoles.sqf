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
	_x setVariable ["Waldo_roundKills", 0, true];   // in-round scoreboard tally
	_x setVariable ["Waldo_purchases", [], true];   // shop "Purchased" panel log
	// Every player is placed in their own solo group in mission.sqm, so this
	// only ever renames that one player's group - the vanilla spectator
	// screen's unit list is grouped by group name, and the default engine
	// naming ("Alpha 1-1", "Alpha 1-2", ...) tells a spectator nothing about
	// who's who. Named after the player instead, so the list itself reads
	// as names.
	(group _x) setGroupIdGlobal [name _x];
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
// Apply the lobby Minimum / Maximum Traitors clamps (max 0 = unlimited). If a
// host sets Max below Min (a contradictory config), Min wins - it's the
// stronger guarantee (a round needs its floor met more than its ceiling).
private _minT = missionNamespace getVariable ["Waldo_minTraitors", 1];
private _maxT = missionNamespace getVariable ["Waldo_maxTraitors", 0];
_traitorCount = _traitorCount max _minT;
if (_maxT > 0) then { _traitorCount = _traitorCount min (_maxT max _minT); };
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
		[
			"DETECTIVE", "There is a Detective this round.", "INFO", 6, "TOP_RIGHT", "ROLEANNOUNCE_DET", "ROUND"
		] remoteExec ["Waldo_fnc_ShowUiNotification", -2];
	};
};
missionNamespace setVariable ["DetectiveList", _detectives, true];

// --- Jester (optional; >= 5 players; not Traitor/Detective) ---
// The Jester's player-count floor is intentionally independent of the
// Detective's (DetectiveMinPlayers) - they used to just be two separately
// hardcoded 5s that happened to match, so changing one lobby setting must not
// silently change the other's gating.
// The old chance check compared a 0..100 roll to a 0..1 fraction, so the
// Jester almost never appeared. Compare against the fraction directly.
private _jesters = [];
if ((missionNamespace getVariable ["JesterEnabled", true]) && {_count >= 5}) then {
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
			[
				"JESTER", "There is a Jester this round.", "INFO", 6, "TOP_RIGHT", "ROLEANNOUNCE_JESTER", "ROUND"
			] remoteExec ["Waldo_fnc_ShowUiNotification", -2];
		};
	};
};
missionNamespace setVariable ["JesterList", _jesters, true];

// --- Tell each Traitor who their teammates (and the Jester) are ---
// TraitorList/JesterList were only ever broadcast as data - nothing ever
// actually told a Traitor player any of this, despite it being the whole
// documented point of being on a team (and of "Traitors are told who the
// Jester is"). One private card per Traitor, teammates excluded from their
// own list.
{
	private _teammates = (_traitors - [_x]) apply { name _x };
	private _msg = if (count _teammates > 0) then {
		format ["Fellow Traitors: %1", _teammates joinString ", "]
	} else {
		"You are the only Traitor this round."
	};
	if (count _jesters > 0) then {
		_msg = _msg + format ["<br/>The Jester is %1.", name (_jesters select 0)];
	};
	[
		"TRAITOR TEAM", _msg, "INFO", 15, "TOP_RIGHT", "TRAITORTEAM", "TRAITOR"
	] remoteExec ["Waldo_fnc_ShowUiNotification", _x];
} forEach _traitors;

// --- Karma: apply carry-over penalties now that starting points are set ---
if (missionNamespace getVariable ["KarmaEnabled", true]) then { [] call Waldo_fnc_applyKarma; };

diag_log format ["[Waldo][server] assignRoles: players=%1 traitors=%2 detectives=%3 jesters=%4",
	_count, count _traitors, count _detectives, count _jesters];
