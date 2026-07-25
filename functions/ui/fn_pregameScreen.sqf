//////////////////////////////////////////////////////////////////
// Waldo_fnc_pregameScreen
// CLIENT: shows the "setting up the arena" hint until the server signals
// mapDone. Nil-safe so it can never spin on an unset variable.
//////////////////////////////////////////////////////////////////

while { !(missionNamespace getVariable ["mapDone", false]) } do {
	hintSilent parseText "<t align='center' size='1.0'><t color='#d11b1b' shadow='1'>Setting Up The Arena, Hold Tight!</t>";
	sleep 0.25;
};
hintSilent "";
