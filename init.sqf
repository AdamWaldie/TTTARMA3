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
	[] call Waldo_fnc_loadParams;

	// Orchestrate the round (scheduled: contains waits/sleeps).
	[] spawn Waldo_fnc_initServer;
};
