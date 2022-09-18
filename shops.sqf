closeDialog 1;
if (player getVariable "role" == "Traitor") then {
	_this execVM "data\TraitorItems\init.sqf";
};
if (player getVariable "role" == "Detective") then {
	_this execVM "data\DetectiveItems\init.sqf";
};