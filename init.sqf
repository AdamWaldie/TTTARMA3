//////////////////////////////////////////////////////////////////
// Trouble In Armaville — mission entry point
// All logic lives in the Waldo_fnc_* library (see functions/ and
// the CfgFunctions block in description.ext). This file only wires
// the engine's init hook to that library.
//////////////////////////////////////////////////////////////////

if (isServer) then {
	// config.sqf holds OPTIONAL dynamic-arsenal tuning (compiled before it runs).
	call compile preprocessFileLineNumbers "config.sqf";

	// Read params + build the dynamic arsenal synchronously, then flag ready.
	// paramsArray (not []) as _this - Waldo_fnc_loadParams reads every lobby
	// setting via `param [index, default]`, which reads from _this, not some
	// engine-magic lobby lookup. Passing [] here meant every param call had
	// nothing to read and silently fell back to its hardcoded default,
	// regardless of what was actually selected in the lobby's Parameters tab -
	// this is why Testing Mode (and every other lobby setting) never took
	// effect no matter what was chosen.
	paramsArray call Waldo_fnc_loadParams;

	// Orchestrate the round (scheduled: contains waits/sleeps).
	[] spawn Waldo_fnc_initServer;
};
