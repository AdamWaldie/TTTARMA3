//////////////////////////////////////////////////////////////////
// Waldo_fnc_debugExec
// SERVER: runs a "server"-context registry entry on behalf of a client. The
// client sends only the entry's index (Waldo_debugDispatch), so no code crosses
// the network — the server re-reads the entry from its own identical registry
// and runs it with the calling unit as _this.
//
// Everything is gated on TestingFlag, so this is inert in a normal game even if
// somehow invoked, and it refuses to run anything not marked "server".
//
// params: [ _caller, _idx ]
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};
if !(missionNamespace getVariable ["TestingFlag", false]) exitWith {};

params ["_caller", "_idx"];
if (isNull _caller) exitWith {};
if (isNil "Waldo_debugRegistry") exitWith {};
if (_idx < 0 || {_idx >= count Waldo_debugRegistry}) exitWith {};

(Waldo_debugRegistry select _idx) params ["", "", "", "_ctx", "_code"];
if (_ctx != "server") exitWith {};

_caller call _code;
