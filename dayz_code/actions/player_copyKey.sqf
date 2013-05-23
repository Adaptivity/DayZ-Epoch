private["_item","_config","_onLadder","_create","_isOk","_config2","_consume"];

if(TradeInprogress) exitWith { cutText ["Copy key already in progress." , "PLAIN DOWN"]; };
TradeInprogress = true;

_item = 	_this;
_config =	configFile >> "cfgWeapons" >> _item;

_onLadder =		(getNumber (configFile >> "CfgMovesMaleSdr" >> "States" >> (animationState player) >> "onLadder")) == 1;
if (_onLadder) exitWith {TradeInprogress = false; cutText [(localize "str_player_21") , "PLAIN DOWN"]};

_text = getText (_config >> "displayName");
_haskey = _this in weapons player;
if (!_haskey) exitWith {TradeInprogress = false; cutText [format[(localize "str_player_30"),_text] , "PLAIN DOWN"]};

_hastoolweapon = "ItemKeyKit" in weapons player;
if (!_hastoolweapon) exitWith {TradeInprogress = false; cutText ["Need Keymakers kit to make a copy of a key." , "PLAIN DOWN"]};

_isNear = {inflamed _x} count (position player nearObjects 2);
if(_isNear == 0) exitWith {TradeInprogress = false; cutText ["Key crafting needs a fire within 2 meters." , "PLAIN DOWN"]};

call gear_ui_init;

// require one tin bar per key
_hasTinBar = 	"ItemTinBar" in _magazinesPlayer;
if(!_hasTinBar) exitWith {TradeInprogress = false; cutText ["Key crafting requires a 1oz Tin Bar." , "PLAIN DOWN"]};

player playActionNow "Medic";

[player,"repair",0,false] call dayz_zombieSpeak;
[player,50,true,(getPosATL player)] spawn player_alertZombies;
			
r_interrupt = false;
_animState = animationState player;
r_doLoop = true;
_started = false;
_finished = false;
	
while {r_doLoop} do {
	_animState = animationState player;
	_isMedic = ["medic",_animState] call fnc_inString;
	if (_isMedic) then {
		_started = true;
	};
	if (_started and !_isMedic) then {
		r_doLoop = false;
		_finished = true;
	};
	if (r_interrupt) then {
		r_doLoop = false;
	};
	sleep 0.1;
};
r_doLoop = false;

_num_removed = ([player,"ItemTinBar"] call BIS_fnc_invRemove);

if(_finished and _num_removed == 1) then {
	// output key to backpack if space
	_create = _item;
	_qty = 1;
	_box = unitBackpack player;
	_box addWeaponCargoGlobal [_create,_qty];
	cutText ["Copied key has been added to your backpack." , "PLAIN DOWN"];
} else {
	cutText ["Canceled Key Crafting." , "PLAIN DOWN"];
};
TradeInprogress = false;
