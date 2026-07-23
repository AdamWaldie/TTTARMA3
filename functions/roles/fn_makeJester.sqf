//////////////////////////////////////////////////////////////////
// Waldo_fnc_makeJester
// Runs on the JESTER's own machine (remote-executed from assignRoles). The
// Fired event handler only triggers where the firing unit is local, so the
// "deals no damage" projectile-deletion must be added here, not on the
// server (which is why the old server-side Fired EH never fired). Add-only
// and guarded so it can't stack.
//////////////////////////////////////////////////////////////////

if (!local player) exitWith {};
if !(isNil { player getVariable "Waldo_jesterFiredEH" }) exitWith {};

private _eh = player addEventHandler ["Fired", { deleteVehicle (_this select 6); }];
player setVariable ["Waldo_jesterFiredEH", _eh];

diag_log "[Waldo][client] makeJester: fire-block installed";
