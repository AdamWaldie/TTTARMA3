//////////////////////////////////////////////////////////////////
// Waldo_fnc_drawRoleIcons
// CLIENT: installs ONE managed Draw3D handler that reveals roles per the
// viewer's own role:
//   - everyone sees the Detective,
//   - Traitors see other Traitors and the Jester,
//   - the Jester sees the Traitors,
//   - Detectives additionally see the role of nearby corpses and of anyone
//     they have "tested".
// Labels shrink to a single letter past 25m. The handler id is stored so a
// second call replaces rather than stacks it.
//////////////////////////////////////////////////////////////////

// Replace any previous handler (guards against stacking).
private _old = missionNamespace getVariable ["Waldo_iconsEH", -1];
if (_old >= 0) then { removeMissionEventHandler ["Draw3D", _old]; };

private _eh = addMissionEventHandler ["Draw3D", {

	// Draw a role tag above _pos; short label + smaller when far.
	private _drawTag = {
		params ["_pos", "_color", "_word", "_far"];
		drawIcon3D [
			"", _color, _pos, 1, 0, 0,
			[_word, _word select [0, 1]] select _far,   // full word / first letter
			2,
			[0.05, 0.04] select _far,                   // size near / far
			"PuristaMedium", "center"
		];
	};

	private _myRole = player getVariable ["role", "Innocent"];

	{
		private _eyePos = getPosATL _x;
		_eyePos set [2, (_eyePos select 2) + 2];
		private _visible = [objNull, "VIEW"] checkVisibility [eyePos player, eyePos _x];

		if (_visible != 0 && {_x != player}) then {
			private _xRole = _x getVariable ["role", "Innocent"];
			private _far = (player distance _x) > 25;

			// Everyone sees the Detective.
			if (_xRole == "Detective") then {
				[_eyePos, [0.01, 0.45, 1, 1], "Detective", _far] call _drawTag;
			};
			// Traitors see other Traitors; the Jester also sees Traitors.
			if (_xRole == "Traitor" && {_myRole == "Traitor" || _myRole == "Jester"}) then {
				[_eyePos, [0.75, 0.21, 0.21, 1], "Traitor", _far] call _drawTag;
			};
			// Traitors see the Jester.
			if (_xRole == "Jester" && {_myRole == "Traitor"}) then {
				[_eyePos, [0.4, 0, 0.5, 1], "Jester", _far] call _drawTag;
			};
		};
	} forEach allUnits;

	// Detective-only reveals.
	if (_myRole == "Detective") then {
		// Nearby corpses.
		{
			private _eyePos = getPosATL _x;
			_eyePos set [2, (_eyePos select 2) + 2];
			if ((player distance _x) < 6) then {
				private _role = _x getVariable ["role", "Innocent"];
				drawIcon3D ["", ([_role] call Waldo_roleColor), _eyePos, 1, 0, 0,
					_role, 2, 0.05, "PuristaMedium", "center"];
			};
		} forEach allDeadMen;

		// Anyone the detective has tested stays revealed.
		{
			if (_x getVariable ["tested", false]) then {
				private _eyePos = getPosATL _x;
				_eyePos set [2, (_eyePos select 2) + 2];
				private _role = _x getVariable ["role", "Innocent"];
				private _far = (player distance _x) > 25;
				[_eyePos, ([_role] call Waldo_roleColor), _role, _far] call _drawTag;
			};
		} forEach (allUnits + allDeadMen);
	};

}];

missionNamespace setVariable ["Waldo_iconsEH", _eh];
