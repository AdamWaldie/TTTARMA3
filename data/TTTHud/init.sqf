disableSerialization;

0 cutRsc ["TTTHud","PLAIN"];
waitUntil {!isNull (uiNameSpace getVariable "TTTHud")};
_display = uiNameSpace getVariable "TTTHud";
_role = player getVariable "role";
_color = [0.12549,0.72941,0.09412,1];
if(_role == "Traitor") then {
	_color = [0.75,0.21,0.21,1];
};
if(_role == "Detective") then {
	_color = [0.01,0.45,1,1];
};
_setColor = _display displayCtrl 1000;
_setColor ctrlSetTextColor _color;
_setText = _display displayCtrl 1001;
_setText ctrlSetTextColor _color;
_setText ctrlSetStructuredText parseText(_role select [0,1]);