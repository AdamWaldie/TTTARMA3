//////////////////////////////////////////////////////////////////
// Waldo_fnc_initClient
// CLIENT: per-player setup. Gated on Waldo_configReady and uses nil-safe
// reads throughout so it can never abort part-way (the old init threw on
// nil mapDone/gameOn during JIP/fast restarts, which is why "scripts failed
// to kick in" on repeat). Emits [Waldo][client] phase markers.
//////////////////////////////////////////////////////////////////

if (!hasInterface) exitWith {};   // dedicated server / headless: nothing to do

private _logPhase = {
	params ["_phase"];
	diag_log ("[Waldo][client] phase: " + _phase);
	if (missionNamespace getVariable ["TestingFlag", false]) then { systemChat ("[Waldo] " + _phase); };
};

waitUntil { !isNull player };

// Wait for the server to publish config (modpack + params) before reading it.
waitUntil { missionNamespace getVariable ["Waldo_configReady", false] };
["config-ready"] call _logPhase;

// If a round is already live when we arrive (JIP), we don't belong in it.
if (missionNamespace getVariable ["gameOn", false]) then { player setDammage 1; };

// --- Spawn loadout ---
private _uniforms  = missionNamespace getVariable ["uniformsConfig", []];
private _headgears = missionNamespace getVariable ["headgearsConfig", []];
private _vests     = missionNamespace getVariable ["vestsConfig", []];

player setVariable ["tested", false, true];
player setVariable ["player", player, true];
player setVariable ["activationQueue", []];   // local: holds bought activation items

if (count _uniforms > 0) then { player forceAddUniform (selectRandom _uniforms); };
if (count _vests > 0)    then { player addVest (selectRandom _vests); };
removeBackpack player;
if (count _headgears > 0 && {floor (random 10) < 6}) then { player addHeadgear (selectRandom _headgears); };
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
		private _eh = _disp displayAddEventHandler ["KeyDown", {
			params ["_d", "_key"];
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
		_disp setVariable ["Waldo_keyEH", _eh];
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

// ACE unconscious -> death, EXCEPT for the Jester (source-less setDamage
// would wipe the "who killed me" attribution the Jester win depends on).
["ace_unconscious", {
	params ["_unit", "_state"];
	if ((_unit getVariable ["role", ""]) != "Jester") then { _unit setDamage 1; };
}] call CBA_fnc_addEventHandler;
