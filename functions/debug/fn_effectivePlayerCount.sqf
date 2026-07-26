//////////////////////////////////////////////////////////////////
// Waldo_fnc_effectivePlayerCount
// Returns the player count that size-dependent systems (arena radius, traitor
// count, starting credits, round length) should scale to.
//
// Normally this is just the real player count. Under Testing Mode a developer
// can override it from the dev/test menu (Waldo_debugPlayerCount) to exercise
// lobby-size-dependent logic solo — e.g. "size the arena as if 24 players are
// here". The override is ignored entirely when Testing Mode is off or unset, so
// live games always use the real count.
//////////////////////////////////////////////////////////////////

if (
	(missionNamespace getVariable ["TestingFlag", false])
	&& {(missionNamespace getVariable ["Waldo_debugPlayerCount", 0]) > 0}
) exitWith {
	missionNamespace getVariable ["Waldo_debugPlayerCount", 0]
};

count allPlayers
