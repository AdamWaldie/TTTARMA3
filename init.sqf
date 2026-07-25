//////////////////////////////////////////////////////////////////
// Trouble In Armaville — mission entry point
// All logic lives in the Waldo_fnc_* library (see functions/ and
// the CfgFunctions block in description.ext). This file only wires
// the engine's init hook to that library.
//////////////////////////////////////////////////////////////////

if (isServer) then {
	// config.sqf is the user-facing knob (which equipment modpack to use).
	call compile preprocessFileLineNumbers "config.sqf";

	// Load params + modpack synchronously, then flag Waldo_configReady.
	[] call Waldo_fnc_loadParams;

	// Orchestrate the round (scheduled: contains waits/sleeps).
	[] spawn Waldo_fnc_initServer;
};
