//////////////////////////////////////////////////////////////////
// Waldo_fnc_drawRoleIcons
// CLIENT: installs ONE managed Draw3D handler that reveals roles per the
// viewer's own role:
//   - everyone sees the Detective,
//   - Traitors see other Traitors and the Jester in-world (so they have a
//     way to avoid the credit penalty for killing them - see
//     Waldo_fnc_onKilled) - but are never handed the Jester's NAME up
//     front the way they are their own teammates' (see the round-start
//     card in Waldo_fnc_assignRoles); this is a see-it-yourself reveal,
//     not a metagame info dump,
//   - Detectives additionally see the role of nearby corpses and of anyone
//     they have "tested".
//   - a dead/spectating viewer is out of the round and sees every living
//     player's role, matching what the on-demand scoreboard (K) already
//     grants them (fn_scoreboard.sqf's _viewerOut) - this is the always-on
//     equivalent for the free spectator camera.
// Labels shrink to a single letter past 25m. Size scales up with distance
// (see _drawTag) - drawIcon3D's size is a world-space fraction, so a fixed
// value shrinks into unreadability with range just like any other object
// would; a near-flat near/far size pair used to make far tags read as
// smaller even though they need to be bigger to stay legible at all. The
// handler id is stored so a second call replaces rather than stacks it.
//////////////////////////////////////////////////////////////////

// Replace any previous handler (guards against stacking).
private _old = missionNamespace getVariable ["Waldo_iconsEH", -1];
if (_old >= 0) then { removeMissionEventHandler ["Draw3D", _old]; };

private _eh = addMissionEventHandler ["Draw3D", {

	// Draw a role tag above _pos; short label past 25m, size scaled to
	// roughly counter perspective shrink so it stays legible out to ~150m
	// instead of shrinking to a speck (capped so it doesn't balloon at
	// extreme range).
	private _drawTag = {
		params ["_pos", "_color", "_word", "_dist"];
		private _far = _dist > 25;
		drawIcon3D [
			"", _color, _pos, 1, 0, 0,
			[_word, _word select [0, 1]] select _far,   // full word / first letter
			2,
			(0.045 + (_dist * 0.0022)) min 0.16,
			"PuristaMedium", "center"
		];
	};

	private _myRole = player getVariable ["role", "Innocent"];
	// Dead/spectating: out of the round, sees everyone - same rule the
	// scoreboard already uses. checkVisibility is skipped for this viewer too,
	// since it's keyed off eyePos player, which for a dead/spectating player
	// is the corpse's eye position, not the free-roam spectator camera - it
	// would otherwise randomly hide tags behind the corpse's own LOS.
	private _viewerOut = !alive player;

	{
		private _eyePos = getPosATL _x;
		_eyePos set [2, (_eyePos select 2) + 2];
		// "FIRE" LOD, not "VIEW": VIEW factors in lighting (it's the same LOD
		// the engine's own AI-spotting/shadow checks use), so a tag would
		// blink out the moment its target stepped into a shadow or a dim
		// interior despite having a clear, unobstructed line to them. FIRE is
		// pure collision geometry - blocked only by an actual wall/object.
		private _visible = if (_viewerOut) then { 1 } else { [objNull, "FIRE"] checkVisibility [eyePos player, eyePos _x] };

		if (_visible != 0 && {_x != player}) then {
			private _xRole = _x getVariable ["role", "Innocent"];
			private _dist = player distance _x;

			if (_viewerOut) then {
				if (alive _x) then {
					[_eyePos, ([_xRole] call Waldo_roleColor), _xRole, _dist] call _drawTag;
				};
			} else {
				// Everyone sees the Detective.
				if (_xRole == "Detective") then {
					[_eyePos, ([_xRole] call Waldo_roleColor), "Detective", _dist] call _drawTag;
				};
				// Traitors see other Traitors.
				if (_xRole == "Traitor" && {_myRole == "Traitor"}) then {
					[_eyePos, ([_xRole] call Waldo_roleColor), "Traitor", _dist] call _drawTag;
				};
				// Traitors see the Jester too (in-world only, not by name).
				if (_xRole == "Jester" && {_myRole == "Traitor"}) then {
					[_eyePos, ([_xRole] call Waldo_roleColor), "Jester", _dist] call _drawTag;
				};
			};
		};
	} forEach allUnits;

	// Detective-only reveals.
	if (_myRole == "Detective") then {
		// Nearby corpses.
		{
			private _eyePos = getPosATL _x;
			_eyePos set [2, (_eyePos select 2) + 2];
			private _dist = player distance _x;
			if (_dist < 6) then {
				private _role = _x getVariable ["role", "Innocent"];
				[_eyePos, ([_role] call Waldo_roleColor), _role, _dist] call _drawTag;
			};
		} forEach allDeadMen;

		// Anyone the detective has tested stays revealed.
		{
			if (_x getVariable ["tested", false]) then {
				private _eyePos = getPosATL _x;
				_eyePos set [2, (_eyePos select 2) + 2];
				private _role = _x getVariable ["role", "Innocent"];
				private _dist = player distance _x;
				[_eyePos, ([_role] call Waldo_roleColor), _role, _dist] call _drawTag;
			};
		} forEach (allUnits + allDeadMen);
	};

}];

missionNamespace setVariable ["Waldo_iconsEH", _eh];
