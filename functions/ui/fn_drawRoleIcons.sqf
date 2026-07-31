//////////////////////////////////////////////////////////////////
// Waldo_fnc_drawRoleIcons
// CLIENT: installs ONE managed Draw3D handler that reveals roles per the
// viewer's own role:
//   - everyone sees the Detective,
//   - Traitors see other Traitors and the Jester in-world (also named
//     outright in the round-start card - Waldo_fnc_assignRoles - so they
//     have a way to avoid the credit penalty for killing them, see
//     Waldo_fnc_onKilled),
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
// No line-of-sight/occlusion gate - a tag is visible through walls/terrain
// rather than risk randomly not showing when it's supposed to (see the
// comment inline below for what that used to chase).
//////////////////////////////////////////////////////////////////

// Replace any previous handler (guards against stacking).
private _old = missionNamespace getVariable ["Waldo_iconsEH", -1];
if (_old >= 0) then { removeMissionEventHandler ["Draw3D", _old]; };

private _eh = addMissionEventHandler ["Draw3D", {

	// Draw a role tag above _pos; short label past 25m, size scaled to
	// roughly counter perspective shrink so it stays legible out to ~150m
	// instead of shrinking to a speck (capped so it doesn't balloon at
	// extreme range). Legibility redesign: drawIcon3D's own built-in
	// "shadow" (2 = outline) was already maxed out and still washed out
	// against a bright sky/pale terrain/snow - the same washed-out-glyph
	// problem already diagnosed and fixed for the radar countdown text. A
	// second, larger, near-black copy of the same glyph drawn first (same
	// world position - drawIcon3D always billboards to face the camera, so
	// both layers land pixel-centred on the same screen point with no manual
	// offset needed) gives a real outline no engine shadow setting can, and
	// PuristaBold (this HUD's own "must-read-fast" font, same as the role
	// letter badge) reads faster at a glance than the Medium weight did.
	// Base size raised too (0.045 -> 0.06) - the old floor was already too
	// small even at close range, not just far away.
	private _drawTag = {
		params ["_pos", "_color", "_word", "_dist"];
		private _far = _dist > 25;
		private _label = [_word, _word select [0, 1]] select _far;   // full word / first letter
		private _size = (0.06 + (_dist * 0.0022)) min 0.18;
		drawIcon3D ["", [0.03, 0.03, 0.03, (_color select 3)], _pos, 1, 0, 0, _label, 0, _size * 1.18, "PuristaBold", "center"];
		drawIcon3D ["", _color, _pos, 1, 0, 0, _label, 2, _size, "PuristaBold", "center"];
	};

	private _myRole = player getVariable ["role", "Innocent"];
	// Dead/spectating: sees everyone, but ONLY when the lobby's "Spectators
	// See All Roles" param is on (off by default - a dead player broadcasting
	// every living role to anyone they talk to, or simply narrating what
	// they see, otherwise leaks exactly the information the round is built
	// around). With it off, a dead viewer falls through to the SAME per-role
	// rules as a living player - _myRole still reads their own role
	// (setVariable persists through death), so a Traitor who dies still sees
	// their fellow Traitors/the Jester in spectator, and everyone still
	// always sees the Detective, same as before they died.
	private _viewerOut = !alive player && {missionNamespace getVariable ["Waldo_spectatorsSeeAllRoles", false]};

	{
		private _eyePos = getPosATL _x;
		_eyePos set [2, (_eyePos select 2) + 2];
		private _dist = player distance _x;

		// No line-of-sight gate. This used to require an unobstructed
		// checkVisibility raycast, which chased three different false
		// negatives across live testing - lighting (fixed: FIRE LOD not
		// VIEW), range flakiness, and incidental geometry (a leaf, a fence
		// rail) blocking a sightline a player could plainly see past. A tag
		// that's SUPPOSED to be showing but randomly isn't is a worse bug
		// than a tag that's technically visible through a wall - reliability
		// wins here, so the check is gone rather than patched a fourth time.
		if (_x != player) then {
			private _xRole = _x getVariable ["role", "Innocent"];

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
