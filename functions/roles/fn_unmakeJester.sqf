//////////////////////////////////////////////////////////////////
// Waldo_fnc_unmakeJester
// Runs on the (ex-)Jester's own machine. Removes the "deals no damage" Fired
// handler that Waldo_fnc_makeJester installs, so a unit that stops being the
// Jester — e.g. a developer switching roles on the fly — fires normally again.
// Safe to call when no handler is present (idempotent), and it clears the
// stored id so makeJester can cleanly re-arm later.
//////////////////////////////////////////////////////////////////

if (!local player) exitWith {};

private _eh = player getVariable ["Waldo_jesterFiredEH", -1];
if (_eh >= 0) then {
	player removeEventHandler ["Fired", _eh];
	player setVariable ["Waldo_jesterFiredEH", nil];
	diag_log "[Waldo][client] unmakeJester: fire-block removed";
};
