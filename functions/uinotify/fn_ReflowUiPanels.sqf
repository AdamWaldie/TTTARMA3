/* Repositions all active generic cards into bounded, non-overlapping stacks. */
if (!hasInterface) exitWith {false};
private _registry = uiNamespace getVariable ["Waldo_UiPanelRegistry", []];
private _gap = safeZoneH * 0.008;
{
    private _placement = _x;
    private _entries = _registry select {(_x param [3, "TOP"]) isEqualTo _placement};
    private _cursor = switch (_placement) do {
        // Pulled up further than the WMP default (0.187) - the role crest
        // (TTTHud.hpp, all 9 crest styles) lives bottom-right, and the tallest
        // any of them reaches above the very bottom edge is Style 8's drop
        // shadow at ~0.233 of safezoneH; the seven redesigned styles all stay
        // under 0.18 (their own comment block documents the budget every one
        // of their rects was checked against).
        // Nothing in this mission currently uses BOTTOM_RIGHT for anything,
        // but reserving clearance past that here means it stays true if that
        // ever changes, instead of only being true by coincidence.
        case "BOTTOM_RIGHT": {safeZoneY + safeZoneH - (safeZoneH * 0.32)};
        case "BOTTOM_LEFT": {safeZoneY + safeZoneH - (safeZoneH * 0.05)};
        // TroubleInArmaville-specific: TTTHud.hpp already owns the top-centre
        // of the screen - the round timer (idc 3600-3603, always visible,
        // 0.015-0.077 of safezoneH) and the keybind row directly under it
        // (idc 3610-3613, visible ~8s after every redraw, 0.083-0.158). A
        // generic "TOP" card starting at the WMP default (0.045) would sit
        // right on top of both. 0.166 clears them - and not coincidentally,
        // that's exactly where the old topBarAnnounce banner (idc 3619-3621,
        // airdrop's announcement before this migration) used to sit, so
        // anything shown here lands in the same slot the team already
        // recognises as "this mission's own announcement banner." TOP_RIGHT
        // keeps the WMP default - nothing else in this HUD occupies the top
        // right corner.
        case "TOP": {safeZoneY + (safeZoneH * 0.166)};
        default {safeZoneY + (safeZoneH * 0.045)};
    };
    if (_placement isEqualTo "CENTER") then {
        private _total = _gap * (((count _entries) - 1) max 0);
        {_total = _total + (_x param [5, 0]);} forEach _entries;
        _cursor = safeZoneY + ((safeZoneH - _total) / 2);
    };
    {
        _x params ["_channel", "_controls", "_token", "_slot", "_panelW", "_panelH", "_padX", "_padY", "_accentH", "_contentH"];
        private _panelX = switch (_slot) do {
            case "TOP_RIGHT";
            case "BOTTOM_RIGHT": {safeZoneX + safeZoneW - _panelW - (safeZoneW * 0.025)};
            case "BOTTOM_LEFT": {safeZoneX + (safeZoneW * 0.025)};
            default {safeZoneX + ((safeZoneW - _panelW) / 2)};
        };
        private _panelY = _cursor;
        if (_slot in ["BOTTOM_LEFT", "BOTTOM_RIGHT"]) then {
            _panelY = _cursor - _panelH;
            _cursor = _panelY - _gap;
        } else {
            _cursor = _panelY + _panelH + _gap;
        };
        _controls params ["_shadow", "_frame", "_accent", "_content"];
        // Same small offset/oversize the rest of this HUD's shadow layers use
        // (see e.g. roleCreditsShadow in TTTHud.hpp).
        private _shadowPad = _gap * 0.5;
        _shadow ctrlSetPosition [_panelX - _shadowPad, _panelY - _shadowPad, _panelW + (2 * _shadowPad), _panelH + (2 * _shadowPad)];
        _frame ctrlSetPosition [_panelX, _panelY, _panelW, _panelH];
        _accent ctrlSetPosition [_panelX, _panelY, _panelW, _accentH];
        _content ctrlSetPosition [_panelX + _padX, _panelY + _padY + _accentH, _panelW - (2 * _padX), _contentH - _accentH];
        {_x ctrlCommit 0;} forEach _controls;
    } forEach _entries;
} forEach ["TOP", "TOP_RIGHT", "CENTER", "BOTTOM_LEFT", "BOTTOM_RIGHT"];
true
