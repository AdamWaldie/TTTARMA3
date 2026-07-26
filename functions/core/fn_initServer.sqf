//////////////////////////////////////////////////////////////////
// Waldo_fnc_initServer
// SERVER: orchestrates a full round. Emits [Waldo][server] phase markers
// to the .rpt (and on-screen when TestingFlag) so a failing replay can be
// traced to the exact stall point.
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

// Phase logger — logs to .rpt and, under TestingFlag, broadcasts to chat.
Waldo_logPhase = {
	params ["_phase"];
	diag_log ("[Waldo][server] phase: " + _phase);
	if (missionNamespace getVariable ["TestingFlag", false]) then {
		(format ["[Waldo] %1", _phase]) remoteExec ["systemChat", 0];
	};
};

[] call Waldo_fnc_resetState;

// A fast, terrain-agnostic safe spot for clients to stand at while the real
// arena is built (which needs the full building/loot scoring pass and can
// take a few seconds). Runs before anything else here since it depends on
// nothing but the terrain being loaded.
[] call Waldo_fnc_selectHoldingPos;
["holding-pos-ready"] call Waldo_logPhase;

// --- Wait for config (modpack + params) ---
waitUntil { missionNamespace getVariable ["Waldo_configReady", false] };
["config-ready"] call Waldo_logPhase;

// --- Player-ready barrier ---
// Size-dependent setup (arena size, traitor count) must not run before
// players have loaded in. Wait until at least one alive player exists and the
// count has been stable for a few seconds, or a hard timeout so we can never
// hang forever.
private _t0 = time;
private _lastCount = -1;
private _stableSince = time;
while { true } do {
	private _n = { alive _x } count allPlayers;
	if (_n != _lastCount) then { _lastCount = _n; _stableSince = time; };
	if (_n > 0 && {(time - _stableSince) >= 3}) exitWith {};
	if ((time - _t0) > 60) exitWith {};
	sleep 1;
};
["players-ready count=" + str ({ alive _x } count allPlayers)] call Waldo_logPhase;

// --- Arena + environment ---
[] call Waldo_fnc_selectArena;
["arena-selected pos=" + str (missionNamespace getVariable "mapPos")] call Waldo_logPhase;

[] call Waldo_fnc_setupWeather;
[] call Waldo_fnc_populateLoot;
["loot-populated"] call Waldo_logPhase;

[] call Waldo_fnc_buildArena;
["arena-built"] call Waldo_logPhase;

// --- Warmup: let clients teleport in while roles are picked ---
missionNamespace setVariable ["mapDone", true, true];
private _warmup = missionNamespace getVariable ["roundWarmupLength", 20];
for "_i" from 0 to (_warmup - 1) do {
	// Dev/test menu can end the warmup early (the "Skip Warmup" test action).
	if (missionNamespace getVariable ["Waldo_debugSkipWarmup", false]) exitWith {};
	private _remaining = _warmup - _i;
	private _text = format [
		"<t align='center' size='1.5'><t color='#ffbb00' shadow='1'>Selecting Roles:</t><br />%1</t>",
		_remaining
	];
	{ (parseText _text) remoteExec ["hint", _x]; } forEach allPlayers;
	sleep 1;
};
["warmup-done"] call Waldo_logPhase;

// --- Roles ---
[] call Waldo_fnc_assignRoles;
["roles-assigned"] call Waldo_logPhase;

// --- Go live ---
[] call Waldo_fnc_startRound;
["round-live"] call Waldo_logPhase;

[] call Waldo_fnc_roundLoop;   // blocks until a win condition ends the round
["round-ended"] call Waldo_logPhase;
