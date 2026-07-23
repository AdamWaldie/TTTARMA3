//////////////////////////////////////////////////////////////////
// Waldo_fnc_buildArena
// SERVER: scans perimeter elevation and builds a circular containment
// wall ("dome"). Both loops are now bounded so steep/awkward terrain can
// never wedge the build (which used to leave mapDone unset -> every client
// stuck on "Setting Up The Arena").
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

private _pos0 = missionNamespace getVariable ["mapPos", [0,0,0]];
private _distance = missionNamespace getVariable ["mapRadius", 50];

// Anchor at centre to get a stable world Z.
private _centerObj = "groundweaponholder" createVehicle _pos0;
_centerObj setPos _pos0;
private _pos = getPosWorld _centerObj;
deleteVehicle _centerObj;

// --- Elevation scan (bounded) ---
private _height = 0;
private _higher = false;
private _scanIters = 0;
while { !_higher && _scanIters < 60 } do {
	_scanIters = _scanIters + 1;
	_higher = true;
	for "_i" from 0 to 100 do {
		private _a = _i * 3.6;
		private _low = "groundweaponholder" createVehicle _pos0;
		_low setPos [
			_distance * cos(_a) + (_pos0 select 0),
			_distance * sin(_a) + (_pos0 select 1),
			(_pos0 select 2)
		];
		private _wp = getPosWorld _low;
		if ((_wp select 2) > (_pos select 2) + _height * 9) then {
			_height = _height + 1;
			_higher = false;
		};
		deleteVehicle _low;
	};
};
_height = _height + 6;

// --- Dome construction ---
private _wallWidth = 4;                              // approx width of Land_VR_Block_04_F
private _circumference = 2 * pi * _distance;
private _segmentCount = ceil (_circumference / _wallWidth);
private _placed = 0;

for "_s" from 0 to (_segmentCount - 1) do {
	private _a = (_s / _segmentCount) * 360;
	private _low = "groundweaponholder" createVehicle _pos0;
	_low setPos [
		_distance * cos(_a) + (_pos0 select 0),
		_distance * sin(_a) + (_pos0 select 1),
		_pos0 select 2
	];
	private _wp = getPosWorld _low;

	for "_u" from 0 to _height do {
		if ((_wp select 2) - 9 < (_pos select 2) + (9 * _u) - 45) then {
			private _wall = "Land_VR_Block_04_F" createVehicle [
				_distance * cos(_a) + (_pos select 0),
				_distance * sin(_a) + (_pos select 1),
				(_pos select 2)
			];
			_wall setPosWorld [
				_distance * cos(_a) + (_pos select 0),
				_distance * sin(_a) + (_pos select 1),
				(_pos select 2) + (9 * _u) - 45
			];
			_wall setDir -_a;
			_placed = _placed + 1;
		};
	};

	deleteVehicle _low;
};

diag_log format ["[Waldo][server] buildArena: height=%1 walls=%2", _height, _placed];
