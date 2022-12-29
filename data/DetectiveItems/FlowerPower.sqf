         
player addEventHandler ["Fired", 
{ 
    _bullet = _this select 6; 
    _dir = _this select 0; 
    _velocity = velocity _bullet; 
    [_bullet, _velocity, _dir] spawn  
        { 
            _newPos = getPos (_this select 0); 
            _newBullet = createVehicle ["FlowerBouquet_02_F", _newPos, [], 0, "NONE"]; 
            _newBullet setVelocity (_this select 1);                
        }; 
}
]; 

//player setVariable ["powerup","bodyArmour",false];
waituntil {!isnull (finddisplay 46)};
(findDisplay 46) displayRemoveAllEventHandlers "KeyDown";
_shop = findDisplay 46 displayAddEventHandler ["KeyDown", {_this select 1 execVM "shops.sqf"}];