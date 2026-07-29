//////////////////////////////////////////////////////////////////
// Waldo_fnc_placeC4
// CLIENT: traitor activation item (Y/U/J, whichever it's bound to). Drops a timed explosive charge at your
// feet. The charge is spawned server-side (Waldo_fnc_c4Charge) so it exists for
// everyone; anyone but the planter can defuse it within 3m before it blows.
//
// Returns true (always consumed once placed).
//////////////////////////////////////////////////////////////////

if (!alive player) exitWith { false };

[player, getPosATL player] remoteExec ["Waldo_fnc_c4Charge", 2];
["C4 CHARGE", "Armed - 15 seconds.", "WARNING", 3, "BOTTOM_LEFT", "C4", "TRAITOR"] call Waldo_fnc_ShowUiNotification;
true
