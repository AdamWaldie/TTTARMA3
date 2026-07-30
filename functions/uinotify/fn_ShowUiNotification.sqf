/*
 * Author: WaldoTheWarfighter
 * Draws a reusable, accessible WMP notification card on the local client.
 * Transient cards queue FIFO per channel and stack safely across channels.
 * Persistent cards replace the current owner of their channel.
 * Duration 0 keeps the card visible until it is replaced or cleared.
 *
 * Arguments:
 * 0: Title <STRING>
 * 1: Message <STRING or TEXT>
 * 2: State <STRING> INFO | SUCCESS | WARNING | ERROR (default INFO)
 * 3: Duration <NUMBER> seconds, 0 = persistent (default 8)
 * 4: Placement <STRING> TOP | TOP_RIGHT | CENTER | BOTTOM_LEFT | BOTTOM_RIGHT
 * 5: Channel <STRING> replacement/ownership key (default MISSION)
 * 6: Source label <STRING> (default WALDOS MISSION PACK)
 * 7: Policy <STRING> AUTO | FIFO | REPLACE (default AUTO)
 * 8: Priority <NUMBER> mission metadata for arbitration/reporting (default 0)
 * 9: Allow permitted local placement override <BOOL> (default false)
 *
 * Return: STRING token, or empty string if queued while no gameplay display exists.
 *
 * Example:
 * ["SUPPLY DELIVERED", "The forward crate is ready.", "SUCCESS", 8, "TOP", "LOGISTICS"]
 *     call Waldo_fnc_ShowUiNotification;
 */
if (!hasInterface) exitWith {""};

params [
    ["_title", "NOTICE", [""]],
    ["_message", ""],
    ["_state", "INFO", [""]],
    ["_duration", 8, [0]],
    ["_placement", "TOP", [""]],
    ["_channel", "MISSION", [""]],
    ["_source", "WALDOS MISSION PACK", [""]],
    ["_policy", "AUTO", [""]],
    ["_priority", 0, [0]],
    ["_allowLocalOverride", false, [true]],
    ["_fromQueue", false, [true]]
];

private _display = findDisplay 46;
if (isNull _display) exitWith {
    _this spawn {
        private _deadline = diag_tickTime + 20;
        waitUntil {uiSleep 0.1; !isNull (findDisplay 46) || {diag_tickTime >= _deadline}};
        if (!isNull (findDisplay 46)) then {_this call Waldo_fnc_ShowUiNotification;};
    };
    ""
};

_state = toUpper _state;
_channel = toUpper _channel;
_placement = [_channel, _placement, _allowLocalOverride] call Waldo_fnc_ResolveUiPanelPlacement;
_policy = toUpper _policy;
if (_policy isEqualTo "AUTO") then {_policy = if (_duration <= 0) then {"REPLACE"} else {"FIFO"};};
if !(_policy in ["FIFO", "REPLACE"]) then {_policy = "FIFO";};
private _semantic = switch (_state) do {
    case "SUCCESS": {["#6CE5A8", "[OK]"]};
    case "WARNING": {["#FFD166", "[!]"]};
    case "ERROR": {["#FF6161", "[X]"]};
    default {["#79C7FF", "[i]"]};
};
_semantic params ["_colour", "_symbol"];

private _registry = uiNamespace getVariable ["Waldo_UiPanelRegistry", []];
private _existingIndex = _registry findIf {(_x param [0, ""]) isEqualTo _channel};
if (_policy isEqualTo "FIFO" && {!_fromQueue} && {_existingIndex >= 0 || {({(_x param [3, ""]) isEqualTo _placement} count _registry) >= 3}}) exitWith {
    private _request = [_title, _message, _state, _duration, _placement, _channel, _source, _policy, _priority, _allowLocalOverride, false];
    private _queue = +(uiNamespace getVariable ["Waldo_UiPanelQueue", []]);
    private _identity = format ["%1|%2|%3|%4", _channel, _title, _message, _state];
    private _duplicate = _queue findIf {
        format ["%1|%2|%3|%4", toUpper (_x param [5, "MISSION"]), _x param [0, ""], _x param [1, ""], toUpper (_x param [2, "INFO"])] isEqualTo _identity
    };
    if (_duplicate < 0) then {_queue pushBack _request;};
    uiNamespace setVariable ["Waldo_UiPanelQueue", _queue];
    "QUEUED"
};
if (_existingIndex >= 0) then {
    private _old = _registry deleteAt _existingIndex;
    {if (!isNull _x) then {ctrlDelete _x;};} forEach (_old param [1, []]);
};

// TroubleInArmaville reskin: shadow + casing + HEADER BAND + accent-stripe
// is the exact material recipe every OTHER panel in this HUD is built from
// (WaldoShop's shopHeader/shopAccentBar, WaldoStylePicker's spHeader/
// spAccentBar, WaldoDebug) - a distinct near-black header band above the
// casing body, with the accent line marking the seam between them, not
// just a thin accent stripe pinned to the frame's own top edge with no
// header at all (the previous version here). Colours are this mission's
// own WALDO_* values (see ui/common.hpp) and its role palette
// (Waldo_roleColor in fn_initShops.sqf: Traitor red, Detective blue,
// Jester purple, Innocent green), not the WMP defaults - the INFO state
// deliberately isn't blue, so a card is never mistaken for a
// Detective-blue "info" state next to an actual Detective-blue role crest.
private _shadow = _display ctrlCreate ["RscText", -1];
private _frame = _display ctrlCreate ["RscText", -1];
private _header = _display ctrlCreate ["RscText", -1];
private _accent = _display ctrlCreate ["RscText", -1];
private _sourceText = _display ctrlCreate ["RscText", -1];
private _content = _display ctrlCreate ["RscStructuredText", -1];
_shadow ctrlSetBackgroundColor [0, 0, 0, 0.82];
_frame ctrlSetBackgroundColor [0.105, 0.11, 0.095, 0.96];
_header ctrlSetBackgroundColor [0.045, 0.05, 0.045, 0.99];   // WALDO_HEADERBG
_accent ctrlSetBackgroundColor (switch (_state) do {
    case "SUCCESS": {[0.435, 0.796, 0.455, 1]};   // matches the shop's existing "[OK] PURCHASED" green
    case "WARNING": {[0.85, 0.62, 0.20, 1]};      // WALDO_ACCENT gold
    case "ERROR":   {[0.894, 0.318, 0.294, 1]};   // matches the shop's existing "[X] NOT ENOUGH CREDITS" red
    default         {[0.62, 0.60, 0.53, 1]};      // muted neutral - deliberately NOT Detective blue
});
_sourceText ctrlSetBackgroundColor [0, 0, 0, 0];
_sourceText ctrlSetText toUpper _source;
_sourceText ctrlSetTextColor [0.62, 0.68, 0.78, 1];
_sourceText ctrlSetFont "PuristaMedium";
_sourceText ctrlSetFontHeight (safeZoneH * 0.014);
// Real vertical centring is done in Waldo_fnc_ReflowUiPanels once this
// control actually has a position/size - ST_VCENTER is documented
// elsewhere in this mission's own UI (ui/TTTHud.hpp, above roleText) as
// rendering fully blank when combined with anything else, so this avoids
// it the same way every other precisely-centred label in this HUD does.
_content ctrlSetBackgroundColor [0, 0, 0, 0];

private _messageText = if ((typeName _message) isEqualTo "TEXT") then {str _message} else {_message};
_content ctrlSetStructuredText parseText format [
    "<t align='left' font='PuristaBold' color='%1' size='1.12' shadow='1'>%2 %3</t><br/>" +
    "<t align='left' font='PuristaMedium' color='#F2EFE3' size='0.88'>%4</t>",
    _colour,
    _symbol,
    _title,
    _messageText
];

private _visibleW = safeZoneW;
private _visibleH = safeZoneH;
// Capped at the round timer bar's own width (0.36 * safezoneW, see
// topBarTimerBG in ui/TTTHud.hpp) or narrower - CENTER/default (used by
// "TOP" placements like the airdrop card) used to run out to 0.44-0.48W,
// nearly half the screen, dwarfing the bar it sits right underneath.
private _panelW = switch (_placement) do {
    case "BOTTOM_RIGHT": {_visibleW * 0.235};
    case "TOP_RIGHT": {_visibleW * 0.28};
    case "BOTTOM_LEFT": {_visibleW * 0.34};
    case "CENTER": {_visibleW * 0.30};
    default {_visibleW * 0.28};
};
private _padX = _visibleW * 0.010;
private _padY = _visibleH * 0.008;
private _maximumContentH = _visibleH * 0.22;
_content ctrlSetPosition [0, 0, _panelW - (2 * _padX), _maximumContentH];
_content ctrlCommit 0;
private _contentH = (((ctrlTextHeight _content) + (_visibleH * 0.006)) max (_visibleH * 0.07)) min _maximumContentH;
private _accentH = (_visibleH * 0.004) max 0.002;
// Header band height: just tall enough for the source label at a fixed,
// compact size - not measured like the body content, since it's always
// exactly one short uppercase line.
private _headerH = _visibleH * 0.026;
private _panelH = _headerH + _accentH + _contentH + (2 * _padY);
{_x ctrlShow true;} forEach [_shadow, _frame, _header, _accent, _sourceText, _content];

private _token = format ["%1_%2", diag_tickTime, random 1e9];
private _controls = [_shadow, _frame, _header, _accent, _sourceText, _content];
_registry pushBack [_channel, _controls, _token, _placement, _panelW, _panelH, _padX, _padY, _accentH, _contentH, _priority, diag_tickTime, _headerH];
uiNamespace setVariable ["Waldo_UiPanelRegistry", _registry];
[] call Waldo_fnc_ReflowUiPanels;

if (_duration > 0) then {
    [_channel, _token, _duration] spawn {
        params ["_channel", "_token", "_duration"];
        uiSleep (_duration max 1);
        private _registry = uiNamespace getVariable ["Waldo_UiPanelRegistry", []];
        private _index = _registry findIf {
            (_x param [0, ""]) isEqualTo _channel && {(_x param [2, ""]) isEqualTo _token}
        };
        if (_index >= 0) then {
            private _entry = _registry deleteAt _index;
            {if (!isNull _x) then {ctrlDelete _x;};} forEach (_entry param [1, []]);
            uiNamespace setVariable ["Waldo_UiPanelRegistry", _registry];
            [] call Waldo_fnc_ReflowUiPanels;
            [] call Waldo_fnc_DrainUiNotificationQueue;
        };
    };
};

_token
