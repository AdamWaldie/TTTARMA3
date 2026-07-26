//////////////////////////////////////////////////////////////////
// Waldo_fnc_debugMenu
// CLIENT: renders the dev/test console from the extensible registry
// (Waldo_debugRegistry, built in Waldo_fnc_debugInit). Opened with the '\' key,
// but ONLY when "Enable Testing Mode" (TestingFlag) is on, so a normal game
// never sees it.
//
// This file contains NO action logic — it only lays the registry out as a
// scrollable, category-grouped button grid and dispatches clicks by index. Add
// tools by registering them (see Waldo_fnc_debugInit), never by editing here.
//////////////////////////////////////////////////////////////////

if (!hasInterface) exitWith {};
if !(missionNamespace getVariable ["TestingFlag", false]) exitWith {};
disableSerialization;

// Toggle: a second '\' press closes the open panel.
if !(isNull (uiNamespace getVariable ["WaldoDebug", displayNull])) exitWith {
	closeDialog 1;
};

if (isNil "Waldo_debugRegistry") exitWith { systemChat "[Waldo][debug] registry not initialised"; };

// --- Order the registry indices by category (Waldo_debugCatOrder first). ---
private _order = missionNamespace getVariable ["Waldo_debugCatOrder", []];
private _cats = [];       // categories in render order
private _byCat = [];      // parallel: array of indices per category

{
	private _cat = _x select 0;
	private _slot = _cats find _cat;
	if (_slot < 0) then { _cats pushBack _cat; _byCat pushBack []; _slot = (count _cats) - 1; };
	(_byCat select _slot) pushBack _forEachIndex;
} forEach Waldo_debugRegistry;

// Sort categories: those named in _order first (in that order), rest appended.
private _sortedCats = [];
private _sortedIdx  = [];
{
	private _slot = _cats find _x;
	if (_slot >= 0) then { _sortedCats pushBack _x; _sortedIdx pushBack (_byCat select _slot); };
} forEach _order;
{
	if !(_x in _sortedCats) then {
		_sortedCats pushBack _x;
		_sortedIdx pushBack (_byCat select _forEachIndex);
	};
} forEach _cats;

createDialog "WaldoDebug";
waitUntil { !isNull (uiNamespace getVariable ["WaldoDebug", displayNull]) };
private _display = uiNamespace getVariable "WaldoDebug";

(_display displayCtrl 3100) ctrlSetText format ["Dev / Test Menu  -  %1 tools", count Waldo_debugRegistry];

// --- Build the grid: a full-width header per category, then its buttons 2-wide. ---
private _group = _display displayCtrl 3102;
private _bw   = 0.205 * safezoneW;
private _bh   = 0.05  * safezoneH;
private _gapX = 0.008 * safezoneW;
private _gapY = 0.008 * safezoneH;
private _fullW = (2 * _bw) + _gapX;

private _row = 0;
private _ctrlId = 3200;

{
	private _cat = _x;
	private _indices = _sortedIdx select _forEachIndex;

	// Category header (full width, not clickable).
	private _hdr = _display ctrlCreate ["RscText", _ctrlId, _group];
	_ctrlId = _ctrlId + 1;
	_hdr ctrlSetPosition [0, _row * (_bh + _gapY), _fullW, _bh];
	_hdr ctrlSetText (if (_cat == "") then { "-" } else { "== " + _cat + " ==" });
	_hdr ctrlSetTextColor [1, 0.73, 0, 1];
	_hdr ctrlSetBackgroundColor [0.14, 0.14, 0.14, 1];
	_hdr ctrlCommit 0;
	_row = _row + 1;

	// Buttons for this category.
	private _col = 0;
	{
		private _entry = Waldo_debugRegistry select _x;
		private _btn = _display ctrlCreate ["RscButton", _ctrlId, _group];
		_ctrlId = _ctrlId + 1;
		_btn ctrlSetPosition [_col * (_bw + _gapX), _row * (_bh + _gapY), _bw, _bh];
		_btn ctrlSetText (_entry select 1);
		_btn ctrlSetTooltip (_entry select 2);
		_btn setVariable ["idx", _x];
		_btn ctrlAddEventHandler ["ButtonClick", {
			params ["_ctrl"];
			[_ctrl getVariable "idx"] call Waldo_debugDispatch;
			call Waldo_debugStatus;
		}];
		_btn ctrlCommit 0;
		_col = _col + 1;
		if (_col >= 2) then { _col = 0; _row = _row + 1; };
	} forEach _indices;

	if (_col > 0) then { _row = _row + 1; };   // finish a half-filled row
} forEach _sortedCats;

call Waldo_debugStatus;
