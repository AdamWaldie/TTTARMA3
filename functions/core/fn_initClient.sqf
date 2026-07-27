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
player setVariable ["activationQueue", []];   // local: holds bought activation items

[] call Waldo_fnc_applySpawnLoadout;
player allowDamage false;

waitUntil { !isNull player && time > 0 };

// Intro music. Started in a guarded thread so it is not swallowed while the
// client is still on the loading screen (the cause of it not playing for
// everyone): wait until the main game display exists, then play - unless the
// round already went live (a JIP mid-round shouldn't restart the intro).
[] spawn {
	waitUntil { !isNull (findDisplay 46) && {time > 0} };
	sleep 0.5;
	if !(missionNamespace getVariable ["gameOn", false]) then {
		playMusic ["TTTIntroMusic", 20];
	};
};

// --- Pregame: wait until the arena is built ---
[] call Waldo_fnc_pregameScreen;
["arena-ready"] call _logPhase;

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
removeBackpack player;
["teleported"] call _logPhase;

// Keep the player inside the arena (single managed loop)
[_pos, _dir, _radius, _center] call Waldo_fnc_confineToArena;

// Title screen
[] call Waldo_fnc_titleSequence;

// --- Install the buy-menu / activation / holster key handler ONCE ---
// Add-only; we never displayRemoveAllEventHandlers (that thrash used to
// break the B key). B = buy menu, Y = use activation item, L = holster.
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
						[_role] call Waldo_fnc_openBuyMenu;
						_handled = true;
					};
				};
				case 21: {   // Y - use most-recent activation item (LIFO)
					private _q = player getVariable ["activationQueue", []];
					if (count _q > 0) then {
						private _item = _q select (count _q - 1);
						private _ok = call (_item select 1);
						if (_ok isEqualType true && {_ok}) then {
							_q deleteAt (count _q - 1);
							player setVariable ["activationQueue", _q];
						};
						_handled = true;
					};
				};
				case 38: {   // L - holster / lower weapon
					[] call Waldo_fnc_holster;
					_handled = true;
				};
				case 37: {   // K - toggle the in-round scoreboard
					[] call Waldo_fnc_scoreboard;
					_handled = true;
				};
				case 20: {   // T - traitor coordination ping (traitors only)
					if ((player getVariable ["role", ""]) == "Traitor") then {
						[] call Waldo_fnc_traitorPing;
						_handled = true;
					};
				};
				case 43: {   // \ - open the dev/test menu (only under Testing Mode)
					if (missionNamespace getVariable ["TestingFlag", false]) then {
						[] call Waldo_fnc_debugMenu;
						_handled = true;
					};
				};
				case 27: {   // right-bracket key - instant role cycle (Testing Mode only)
					if (missionNamespace getVariable ["TestingFlag", false]) then {
						call Waldo_debugCycleRole;
						_handled = true;
					};
				};
			};
			_handled
		}];
		private _ehUp = _disp displayAddEventHandler ["KeyUp", {
			params ["_d", "_key"];
			private _held = _d getVariable ["Waldo_heldKeys", []];
			_d setVariable ["Waldo_heldKeys", _held - [_key]];
			false
		}];
		_disp setVariable ["Waldo_keyEH", _eh];
		_disp setVariable ["Waldo_keyEHUp", _ehUp];
	};
};

// --- Wait for the round to go live ---
waitUntil { missionNamespace getVariable ["gameOn", false] };
10 fadeMusic 0;

removeBackpack player;
player allowDamage true;

// HUD (role badge + live credits)
[] call Waldo_fnc_initHud;
["round-live"] call _logPhase;

// --- Kill handling (server-authoritative logic lives in Waldo_fnc_onKilled) ---
player addMPEventHandler ["MPKilled", {
	_this call Waldo_fnc_onKilled;
}];

// Dead Ringer guard: while armed (Waldo_fnc_deadRinger sets Waldo_deadRingerArmed),
// a hit that would be fatal is capped instead of killing, and
// Waldo_fnc_deadRingerTrigger sells the fake death. Installed once per client.
player addEventHandler ["HandleDamage", {
	params ["_unit", "_selection", "_damage"];
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
	["ace_unconscious", {
		params ["_unit", "_state"];
		private _protected = ((_unit getVariable ["role", ""]) == "Jester") || (_unit getVariable ["Waldo_deadRingerTriggered", false]);
		if (_state && {_unit == player} && {!_protected}) then { player setDamage 1; };
	}] call CBA_fnc_addEventHandler;

	while { true } do {
		private _protected = ((player getVariable ["role", ""]) == "Jester") || (player getVariable ["Waldo_deadRingerTriggered", false]);
		if (alive player && {lifeState player == "INCAPACITATED"} && {!_protected}) then { player setDamage 1; };
		sleep 2;
	};
};
