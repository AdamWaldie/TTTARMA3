//////////////////////////////////////////////////////////////////
// Waldo_fnc_debugAction
// SERVER: executes the server-authoritative half of the dev / test menu.
// Called via remoteExec from Waldo_fnc_debugMenu. Everything here is gated on
// TestingFlag, so it is inert in a normal game even if somehow invoked.
//
// params: [ _caller, _action, _arg ]
//   "becomeRole" _arg = "Innocent"|"Traitor"|"Detective"|"Jester"
//   "dummy"      _arg = role string for the spawned test dummy
//   "airdrop"                          - force a supply drop now
//   "skipWarmup"                       - end the role-selection warmup early
//   "resetKarma" / "lowKarma"          - set the caller's stored karma
//   "end"        _arg = "END1".."END4" - force a round ending
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};
if !(missionNamespace getVariable ["TestingFlag", false]) exitWith {};

params ["_caller", "_action", ["_arg", ""]];
if (isNull _caller) exitWith {};

switch (_action) do {

	// --- Change the caller's role, keeping the authoritative lists consistent ---
	case "becomeRole": {
		private _role = _arg;

		// Drop the caller out of every role list first so we never double-list.
		{
			private _list = (missionNamespace getVariable [_x, []]) - [_caller];
			missionNamespace setVariable [_x, _list, true];
		} forEach ["TraitorList", "DetectiveList", "JesterList"];

		_caller setVariable ["role", _role, true];
		_caller setVariable ["tested", false, true];

		switch (_role) do {
			case "Traitor": {
				private _l = missionNamespace getVariable ["TraitorList", []];
				_l pushBackUnique _caller;
				missionNamespace setVariable ["TraitorList", _l, true];
				_caller setVariable ["points", (_caller getVariable ["points", 0]) max 1, true];
			};
			case "Detective": {
				private _l = missionNamespace getVariable ["DetectiveList", []];
				_l pushBackUnique _caller;
				missionNamespace setVariable ["DetectiveList", _l, true];
				_caller setVariable ["points", (_caller getVariable ["points", 0]) max 1, true];
				[_caller] remoteExec ["Waldo_fnc_applyDetectiveLoadout", _caller];
			};
			case "Jester": {
				private _l = missionNamespace getVariable ["JesterList", []];
				_l pushBackUnique _caller;
				missionNamespace setVariable ["JesterList", _l, true];
				[] remoteExec ["Waldo_fnc_makeJester", _caller];
			};
			default { /* Innocent: belongs to no list */ };
		};

		// Refresh the caller's HUD badge + role-reveal icons for the new role.
		[] remoteExec ["Waldo_fnc_initHud", _caller];
		[] remoteExec ["Waldo_fnc_drawRoleIcons", _caller];
		[format ["[Waldo][debug] you are now %1", _role]] remoteExec ["systemChat", _caller];
		diag_log format ["[Waldo][server] debug: %1 -> role %2", name _caller, _role];
	};

	// --- Spawn a captive, unmoving dummy in front of the caller ---
	case "dummy": {
		private _role = _arg;
		private _pos  = _caller getPos [5, getDir _caller];
		private _grp  = createGroup [civilian, true];
		_grp createUnit ["C_man_1", _pos, [], 0, "NONE"];
		private _unit = (units _grp) select 0;
		if (isNull _unit) exitWith {
			diag_log "[Waldo][server] debug: dummy spawn failed";
		};

		_unit setDir ((getDir _caller) + 180);
		_unit setCaptive true;
		_unit disableAI "ALL";
		_unit allowDamage true;
		_unit setVariable ["role", _role, true];
		_unit setVariable ["tested", false, true];

		// Route the dummy's death through the normal kill handler so kill-credit,
		// Jester-clean-kill and karma logic can all be exercised in a solo test.
		_unit addMPEventHandler ["MPKilled", { _this call Waldo_fnc_onKilled }];

		[format ["[Waldo][debug] spawned %1 dummy", _role]] remoteExec ["systemChat", _caller];
		diag_log format ["[Waldo][server] debug: spawned %1 dummy for %2", _role, name _caller];
	};

	// --- Force a supply airdrop now ---
	case "airdrop": {
		[] call Waldo_fnc_spawnAirdrop;
	};

	// --- End the warmup loop early (read by Waldo_fnc_initServer) ---
	case "skipWarmup": {
		missionNamespace setVariable ["Waldo_debugSkipWarmup", true, true];
		["[Waldo][debug] warmup skip requested"] remoteExec ["systemChat", _caller];
	};

	// --- Karma helpers (stored per-UID in profileNamespace) ---
	case "resetKarma": {
		private _uid = getPlayerUID _caller;
		if (_uid != "") then {
			profileNamespace setVariable ["Waldo_karma_" + _uid, 100];
			saveProfileNamespace;
			["[Waldo][debug] karma reset to 100"] remoteExec ["systemChat", _caller];
		};
	};
	case "lowKarma": {
		private _uid = getPlayerUID _caller;
		if (_uid != "") then {
			profileNamespace setVariable ["Waldo_karma_" + _uid, 0];
			saveProfileNamespace;
			["[Waldo][debug] karma set to 0 (penalty applies next round)"] remoteExec ["systemChat", _caller];
		};
	};

	// --- Force a round ending (shows the matching debrief) ---
	case "end": {
		if (_arg in ["END1", "END2", "END3", "END4"]) then {
			[_arg] call Waldo_fnc_endRound;
		};
	};

	default {
		diag_log format ["[Waldo][server] debug: unknown action '%1'", _action];
	};
};
