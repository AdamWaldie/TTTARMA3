//////////////////////////////////////////////////////////////////
// Waldo_fnc_deleteBody
// SERVER: deletes the given corpse. Split out of Waldo_fnc_removeBody so the
// actual deleteVehicle is a remoteExec'd MISSION FUNCTION instead of a raw
// engine command string - remoteExec'ing bare commands like "deleteVehicle"
// falls under CfgRemoteExec's stricter Commands whitelist (this mission never
// defines a CfgRemoteExec class), whereas CfgFunctions-declared functions like
// this one are remote-executable by default. A listen-server host masks the
// difference because the host's own client already has full local authority;
// only a true dedicated server actually enforces it, which is why Body
// Remover only ever failed there.
//
// params: [_body]
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};
params ["_body"];
if (isNull _body) exitWith {};

deleteVehicle _body;
