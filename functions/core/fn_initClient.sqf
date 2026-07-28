//////////////////////////////////////////////////////////////////
// Waldo_fnc_initClient
// CLIENT: per-player setup. Gated on Waldo_configReady and uses nil-safe
// reads throughout so it can never abort part-way (the old init threw on
// nil mapDone/gameOn during JIP/fast restarts, which is why "scripts failed
// to kick in" on repeat). Emits [Waldo][client] phase markers.
//////////////////////////////////////////////////////////////////

if (!hasInterface) exitWith {};   // dedicated server / headless: nothing to do

// Damage off from the very first executable line, before anything else runs.
// The player unit already exists in the world by the time this script starts
// (wherever mission.sqm happened to place them, possibly in water, possibly
// overlapping another unit, on a terrain those coordinates were never
// checked against), and the holding-position relocation below still has two
// waitUntils to clear before it can move them. Without this, that whole gap
// is a window where a bad spawn point can actually hurt or kill someone
// before the mission gets a chance to move them anywhere.
player allowDamage false;

private _logPhase = {
	params ["_phase"];
	diag_log ("[Waldo][client] phase: " + _phase);
	if (missionNamespace getVariable ["TestingFlag", false]) then { systemChat ("[Waldo] " + _phase); };
};

waitUntil { !isNull player };

// Wait for the server to publish config (modpack + params) before reading it.
waitUntil { missionNamespace getVariable ["Waldo_configReady", false] };
["config-ready"] call _logPhase;

// Move off whatever mission.sqm happened to place us at - only ever valid on
// the one terrain a mission was saved on - onto a runtime-picked safe spot
// (Waldo_fnc_selectHoldingPos), so the same mission works on Altis, Tanoa,
// Stratis, Livonia, or anywhere else. findEmptyPosition scatters each client
// around it so up to 128 players don't clip into each other or the terrain
// while they wait for the real arena.
waitUntil { !((missionNamespace getVariable ["Waldo_holdingPos", []]) isEqualTo []) };
private _hold = missionNamespace getVariable ["Waldo_holdingPos", [0,0,0]];
private _holdSafe = _hold findEmptyPosition [0, 40];
if (_holdSafe isEqualTo []) then { _holdSafe = _hold; };
player setPos _holdSafe;
["holding-pos"] call _logPhase;

// If a round is already live when we arrive (JIP), we don't belong in it.
if (missionNamespace getVariable ["gameOn", false]) then { player setDammage 1; };

// --- Spawn loadout ---
player setVariable ["tested", false, true];
player setVariable ["player", player, true];
// local: 3 keyed activation slots (Y/U/J) + an overflow backlog for anything
// bought beyond 3 activation items at once (see Waldo_fnc_buyItem /
// Waldo_fnc_useActivationSlot / Waldo_fnc_assignActivationSlot).
player setVariable ["Waldo_activationSlots", [-1, -1, -1]];
player setVariable ["Waldo_activationBacklog", []];
player setVariable ["Waldo_purchaseSeq", 0];   // next unique Waldo_purchases id

[] call Waldo_fnc_applySpawnLoadout;
player allowDamage false;

waitUntil { !isNull player && time > 0 };

// --- Pregame: wait until the arena is built ---
[] call Waldo_fnc_pregameScreen;
["arena-ready"] call _logPhase;

// Warmup "Selecting Roles" bar (same top-bar casing/position as the round
// timer): mapDone is already true by the time Waldo_fnc_pregameScreen
// returns, which is exactly the window the server's own warmup loop
// (Waldo_fnc_initServer) is running in - no extra readiness gating needed.
[] spawn Waldo_fnc_warmupBar;

// Intro music. Deliberately triggered HERE rather than right after spawn: an
// elapsed-time heuristic (however generous) can never fully guarantee the
// client isn't still on a loading screen, which is why this was intermittent
// rather than reliably broken - time > 0 (or even time > 3) can already be
// true well before the audio engine is necessarily ready. Waldo_fnc_pregameScreen
// just spent however long the arena took to build actively looping a hint
// refresh every 0.25s on THIS client - by the time it returns, this client
// has provably been running SQF and updating the screen the whole time, not
// stuck loading. Skipped if the round already went live (a JIP mid-round
// shouldn't restart the intro); logged either way so a silent failure shows
// up in the .rpt instead of being another guess.
//
// _musicStarted is recorded (see the fadeMusic call near the end of this
// script) so the fade-out below can be skipped entirely for a JIP client
// that never started the music in the first place.
//
// 0 fadeMusic 1 first: fadeMusic sets an engine-level "scripted volume"
// multiplier (final volume = client's own Music slider * this), and it is
// NOT track-specific or reset by playMusic - it just stays wherever the
// LAST fadeMusic call left it. This mission restarts a fresh round (and
// calls playMusic again) many times in the same server session, and
// fn_initClient.sqf's own fade-out at round-live (`6 fadeMusic 0;`, near
// the end of this script) leaves that multiplier at 0 - silently muting
// every playMusic call for the rest of the server's life (this round's MVP
// replay, Waldo_fnc_mvpCelebrate, and every later round's intro alike) with
// zero indication anywhere that it happened, since playMusic itself still
// resolves and logs cleanly. Resetting to 1 (instantly, duration 0) right
// before playing is what actually guarantees this is audible.
private _musicStarted = false;
if !(missionNamespace getVariable ["gameOn", false]) then {
	0 fadeMusic 1;
	playMusic ["TTTIntroMusic", 20];
	_musicStarted = true;
	diag_log "[Waldo][client] intro music: playMusic issued";
} else {
	diag_log "[Waldo][client] intro music: skipped, round already live (JIP)";
};

// Obscure nametags (ACE)
ACE_NO_RECOGNIZE = true; publicVariable "ACE_NO_RECOGNIZE";

// Role-reveal 3D icons
[] call Waldo_fnc_drawRoleIcons;

// --- Teleport into the arena ---
private _center = missionNamespace getVariable ["mapPos", [0,0,0]];
private _radius = missionNamespace getVariable ["mapRadius", 50];
private _dist = _radius * 0.9;
player setPos _center;
private _pos = [
	(_center select 0) - (_dist / 2) + random _dist,
	(_center select 1) - (_dist / 2) + random _dist,
	0
];
private _dir = _pos getDir _center;
private _empty = _pos findEmptyPosition [0, 25];
if !(_empty isEqualTo []) then { _pos = _empty; };
player setPos _pos;
player setDir _dir;
player allowDamage false;
["teleported"] call _logPhase;

// Keep the player inside the arena (single managed loop)
[_pos, _dir, _radius, _center] call Waldo_fnc_confineToArena;

// Title screen
[] call Waldo_fnc_titleSequence;

// --- Install the buy-menu / activation / holster key handler ONCE ---
// Add-only; we never displayRemoveAllEventHandlers (that thrash used to
// break the B key). B = buy menu, Y/U/J = use activation item slot 1/2/3,
// L = holster.
[] spawn {
	waitUntil { !isNull (findDisplay 46) };
	private _disp = findDisplay 46;
	if (isNil { _disp getVariable "Waldo_keyEH" }) then {
		// KeyDown fires repeatedly (OS key-repeat) for as long as a key stays
		// physically down, not once per press - without this guard, holding T
		// spams dozens of pings and holding any other bound key re-fires its
		// action every repeat tick. Track which of our bound keys are currently
		// held and ignore repeats until KeyUp clears them.
		_disp setVariable ["Waldo_heldKeys", []];
		private _eh = _disp displayAddEventHandler ["KeyDown", {
			params ["_d", "_key"];
			private _held = _d getVariable ["Waldo_heldKeys", []];
			if (_key in _held) exitWith { false };
			_held pushBack _key;
			_d setVariable ["Waldo_heldKeys", _held];
			private _handled = false;
			switch (_key) do {
				case 48: {   // B - open buy menu
					private _role = player getVariable ["role", "Innocent"];
					if (_role in ["Traitor", "Detective"]) then {
						// openBuyMenu waitUntils on its dialog existing after createDialog -
						// same reasoning as the debug menu below: never rely on that check
						// happening to pass on its very first tick when called unscheduled.
						[_role] spawn Waldo_fnc_openBuyMenu;
						_handled = true;
					};
				};
				case 21: {   // Y - use the activation item bound to slot 1
					[0] call Waldo_fnc_useActivationSlot;
					_handled = true;
				};
				case 22: {   // U - use the activation item bound to slot 2
					[1] call Waldo_fnc_useActivationSlot;
					_handled = true;
				};
				case 36: {   // J - use the activation item bound to slot 3
					[2] call Waldo_fnc_useActivationSlot;
					_handled = true;
				};
				case 38: {   // L - holster / lower weapon
					[] call Waldo_fnc_holster;
					_handled = true;
				};
				case 37: {   // K - toggle the in-round scoreboard
					// Same createDialog + waitUntil pattern as the buy/debug menus -
					// spawned for the same reason, not called.
					[] spawn Waldo_fnc_scoreboard;
					_handled = true;
				};
				case 20: {   // T - hold to open the ping picker (traitors only); release fires it
					if ((player getVariable ["role", ""]) == "Traitor") then {
						// pingWheelOpen waitUntils on its overlay existing the first time it's
						// created - needs a scheduled context, same reason debugMenu does above.
						[] spawn Waldo_fnc_pingWheelOpen;
						_handled = true;
					};
				};
				case 26: {   // [ - open the dev/test menu (only under Testing Mode)
					// Was bound to \ (DIK 43); moved here because \ has a history of
					// colliding with a default Arma keybind and never reliably reaching
					// this handler at all, unlike every other key bound in this switch.
					if (missionNamespace getVariable ["TestingFlag", false]) then {
						// debugMenu waitUntils on the dialog existing after createDialog -
						// waitUntil needs a scheduled environment same as sleep does, and
						// this KeyDown handler is unscheduled, so `call` threw here every
						// time (the actual reason the menu never opened).
						[] spawn Waldo_fnc_debugMenu;
					} else {
						// Silent no-op otherwise looks identical to a broken key - tell the
						// player WHY nothing happened instead of leaving them guessing.
						hint "Testing Mode is off for this session - enable it in the lobby's Parameters tab.";
					};
					_handled = true;
				};
				case 27: {   // right-bracket key - instant role cycle (Testing Mode only)
					if (missionNamespace getVariable ["TestingFlag", false]) then {
						call Waldo_debugCycleRole;
					} else {
						hint "Testing Mode is off for this session - enable it in the lobby's Parameters tab.";
					};
					_handled = true;
				};
			};
			_handled
		}];
		private _ehUp = _disp displayAddEventHandler ["KeyUp", {
			params ["_d", "_key"];
			private _held = _d getVariable ["Waldo_heldKeys", []];
			_d setVariable ["Waldo_heldKeys", _held - [_key]];
			if (_key == 20) then { [] call Waldo_fnc_pingWheelClose; };   // T released - fire the highlighted ping
			false
		}];
		_disp setVariable ["Waldo_keyEH", _eh];
		_disp setVariable ["Waldo_keyEHUp", _ehUp];
	};
};

// --- Wait for the round to go live ---
waitUntil { missionNamespace getVariable ["gameOn", false] };

player allowDamage true;

// HUD (role badge + live credits). This is the moment a player's role is
// actually revealed to them - the intro music should die right here, not on
// some fixed delay afterward, so fade it out gently as the badge appears
// instead of leaving it running under the round proper.
if (_musicStarted) then {
	6 fadeMusic 0;
};

[] call Waldo_fnc_initHud;
["round-live"] call _logPhase;

// Top bar round-timer loop: started exactly once here (never from
// fn_initHud.sqf, which re-runs on every respawn/role change) - gameOn is
// already confirmed true by the waitUntil above, so Waldo_startTime/timelimit
// are already broadcast too; no extra readiness gating needed.
[] spawn Waldo_fnc_topBarTimer;

// --- Kill handling (server-authoritative logic lives in Waldo_fnc_onKilled) ---
player addMPEventHandler ["MPKilled", {
	params ["_unit"];
	_this call Waldo_fnc_onKilled;
	// Nothing clears a hint/hintSilent on death - a scanner readout, "Reviving...",
	// "Charge armed", whatever happened to be up at the moment of death, was
	// otherwise left on screen bleeding into the Spectator view with no way to
	// dismiss it.
	if (_unit == player) then { hint ""; hintSilent ""; };
}];

// Dead Ringer guard: while armed (Waldo_fnc_deadRinger sets Waldo_deadRingerArmed),
// a hit that would be fatal is capped instead of killing, and
// Waldo_fnc_deadRingerTrigger sells the fake death. Installed once per client.
player addEventHandler ["HandleDamage", {
	params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator"];
	// Track the last real (non-null, non-self) damager independent of the Dead Ringer
	// check below - ACE bleed-out/DoT damage ticks can hit this handler with a null
	// _instigator, and by the time the terminal MPKilled event fires its own
	// killer/instigator can likewise resolve to null or to the victim themselves, even
	// though a real player caused the damage that led to death. Waldo_fnc_onKilled falls
	// back to this when MPKilled's own attribution comes up empty.
	if (!isNull _instigator && {_instigator != _unit}) then {
		_unit setVariable ["Waldo_lastDamager", _instigator, true];
	};
	if ((_unit getVariable ["Waldo_deadRingerArmed", false]) && {((damage _unit) + _damage) >= 1}) then {
		[_unit] call Waldo_fnc_deadRingerTrigger;
		0.9
	} else {
		_damage
	}
}];

// ACE unconscious -> death (this TTT ruleset has no downed/incapacitated state
// - going unconscious always means dead), EXCEPT for the Jester (source-less
// setDamage would wipe the "who killed me" attribution the Jester win depends
// on) and a unit currently faking its death via Dead Ringer.
//
// TWO redundant triggers, because a single CBA event handler was unreliable:
//   1. The old handler ignored _state entirely, so it fired identically
//      whether a unit went UNCONSCIOUS or RECOVERED - it could re-kill someone
//      the instant they woke back up. Now gated on _state (only the "went
//      unconscious" edge) and restricted to the unit's OWN machine
//      (_unit == player) - calling setDamage locally on the affected player's
//      machine is more reliable than every client reacting to the same
//      broadcast event and racing to remote-kill the same unit.
//   2. A local watchdog backstop using the ENGINE's own lifeState (not an
//      ACE-internal variable name, which risks not matching ACE's actual
//      implementation) - catches a unit stuck INCAPACITATED if the event is
//      ever missed, or doesn't fire at all under a given ACE medical setting.
[] spawn {
	// CBA (and therefore ACE) is no longer treated as a hard requirement -
	// this hook is purely additive on top of the lifeState watchdog below,
	// which already catches the same case without either mod loaded.
	if (!isNil "CBA_fnc_addEventHandler") then {
		["ace_unconscious", {
			params ["_unit", "_state"];
			private _protected = ((_unit getVariable ["role", ""]) == "Jester") || (_unit getVariable ["Waldo_deadRingerTriggered", false]);
			if (_state && {_unit == player} && {!_protected}) then { player setDamage 1; };
		}] call CBA_fnc_addEventHandler;
	};

	while { true } do {
		private _protected = ((player getVariable ["role", ""]) == "Jester") || (player getVariable ["Waldo_deadRingerTriggered", false]);
		if (alive player && {lifeState player == "INCAPACITATED"} && {!_protected}) then { player setDamage 1; };
		sleep 2;
	};
};
