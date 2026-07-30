//////////////////////////////////////////////////////////////////
// Trouble In Armaville — mission entry point
// All logic lives in the Waldo_fnc_* library (see functions/ and
// the CfgFunctions block in description.ext). This file only wires
// the engine's init hook to that library.
//////////////////////////////////////////////////////////////////

// ACE's hearing module periodically calls fadeMusic itself to duck music
// under hearing damage/suppression, fighting any fadeMusic call this
// mission makes - fn_initClient.sqf's own round-live fade-out was
// confirmed (via .rpt) to be issued and return correctly, yet the intro
// music kept playing at full volume for the rest of the round whenever ACE
// was loaded. Opting out of ACE's own volume updates is what lets our
// fadeMusic calls actually take effect.
ace_hearing_disableVolumeUpdate = true;

// ACE nametags (floating name/role labels over other players when aimed
// at) directly break this mission's whole premise - a Traitor identified
// by a name label the instant someone looks their way isn't a mystery any
// more. ACE_NO_RECOGNIZE (fn_initClient.sqf) already opts out of ACE's
// separate "recognize by voice/face" system; this is the actual nametag
// display toggle, ace_nametags_showPlayerNames (source code:
// addons/nametags/initSettings.inc.sqf in acemod/ACE3) - a CBA LIST
// setting, 0 = Disabled. Forced via source "mission" with priority 1 (CBA
// resolves the highest-priority source's value as the effective one, per
// addons/settings/fnc_set.sqf) so it overrides whatever any individual
// player has set in their own ACE Options menu, not just this mission's
// own default. Guarded, not unconditional like ace_hearing_disableVolumeUpdate
// above - that's a plain variable ACE reads if present and no-ops on if
// it's not, but this is an actual function call, which would throw if CBA
// isn't loaded at all (CBA/ACE aren't a hard requirement in this mission,
// same reasoning as fn_initClient.sqf's own ACE-optional guards).
// ace_nametags_showVehicleCrewInfo is a SEPARATE checkbox setting, not a
// sub-option of showPlayerNames above - it independently shows crew names
// when looking at a vehicle even with the main nametag popup off, which
// leaks exactly the identity this mission needs to stay hidden (who's
// driving/gunning). Forced off the same way, for the same reason.
if (!isNil "CBA_settings_fnc_set") then {
	["ace_nametags_showPlayerNames", 0, 1, "mission"] call CBA_settings_fnc_set;
	["ace_nametags_showVehicleCrewInfo", false, 1, "mission"] call CBA_settings_fnc_set;
};

// Vanilla Arma's own nametags (the "Tags" difficulty flag) can't be forced
// off from mission script at all - difficultyEnabled is read-only in SQF,
// and there's no corresponding "set" command. That one has to be turned
// off server-side in the difficulty/preset config, not here. No known
// equivalent exists in ACRE2 (audio-only radio comms, no visual nametag
// feature of its own to disable).

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
