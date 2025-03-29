closeDialog 1;
if (player getVariable "role" == "Traitor") then {
	_this execVM "roles\traitor\init.sqf";
};
if (player getVariable "role" == "Detective") then {
	_this execVM "roles\detective\init.sqf";
};