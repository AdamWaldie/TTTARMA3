//////////////////////////////////////////////////////////////////
// Waldo_fnc_buildArena
// SERVER: builds a circular containment wall ("dome") around the arena.
//
// Gap-free at any radius: the wall block's real width/height are measured at
// runtime (boundingBoxReal); horizontal segments are spaced by width with an
// overlap factor and each block is turned to FACE THE CENTRE so its width
// runs tangentially (the old fixed 4m estimate + fixed rotation left gaps as
// the radius grew). Each column is stacked from its own local ground up to a
// common height above the tallest perimeter point, so terrain rises can't
// open holes either. All loops are bounded.
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

private _pos0 = missionNamespace getVariable ["mapPos", [0,0,0]];
private _distance = missionNamespace getVariable ["mapRadius", 50];

// Centre world position (stable Z reference).
private _centerObj = "groundweaponholder" createVehicle _pos0;
_centerObj setPos _pos0;
private _base = getPosWorld _centerObj;
deleteVehicle _centerObj;

// Measure the wall block's real dimensions.
private _sample = "Land_VR_Block_04_F" createVehicle [0, 0, 0];
private _bb = boundingBoxReal _sample;
private _ww = (_bb select 1 select 0) - (_bb select 0 select 0);   // width (X)
private _wh = (_bb select 1 select 2) - (_bb select 0 select 2);   // height (Z)
deleteVehicle _sample;
if (_ww < 0.5) then { _ww = 4; };
if (_wh < 0.5) then { _wh = 9; };

// --- Perimeter elevation scan: biggest rise above centre ---
private _maxDelta = 0;
for "_i" from 0 to 179 do {
	private _a = _i * 2;
	private _probe = "groundweaponholder" createVehicle [
		_distance * cos(_a) + (_base select 0),
		_distance * sin(_a) + (_base select 1),
		0
	];
	private _d = (getPosWorld _probe select 2) - (_base select 2);
	if (_d > _maxDelta) then { _maxDelta = _d; };
	deleteVehicle _probe;
};

// Layers so every column clears the tallest point plus a fixed extra wall height.
private _extra = 6;
private _layers = (ceil ((_maxDelta + (_extra * _wh)) / _wh)) + 1;

// --- Horizontal segments with overlap ---
private _overlap = 0.9;
private _segments = ceil ((2 * pi * _distance) / (_ww * _overlap));
private _placed = 0;

for "_s" from 0 to (_segments - 1) do {
	private _a = (_s / _segments) * 360;
	private _wx = _distance * cos(_a) + (_base select 0);
	private _wy = _distance * sin(_a) + (_base select 1);

	// local ground Z at this perimeter point
	private _probe = "groundweaponholder" createVehicle [_wx, _wy, 0];
	private _gz = getPosWorld _probe select 2;
	deleteVehicle _probe;

	private _dir = [_wx, _wy] getDir _base;   // face centre -> width runs tangentially

	for "_u" from 0 to (_layers - 1) do {
		private _wall = "Land_VR_Block_04_F" createVehicle [0, 0, 0];
		_wall setDir _dir;
		_wall setPosWorld [_wx, _wy, _gz + (_u * _wh) - (_wh / 2)];   // start half-buried, no bottom gap
		_placed = _placed + 1;
	};
};

diag_log format ["[Waldo][server] buildArena: blockW=%1 blockH=%2 layers=%3 segments=%4 walls=%5",
	_ww, _wh, _layers, _segments, _placed];
