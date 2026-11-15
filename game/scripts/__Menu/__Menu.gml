enum MenuIndex{
	NameSelect,
	NewGame,
	ContinueGame,
	NewGame_Start,
	Options,
	NewUser,
	User,
	UserDelete,
	Stats,
	Cheats,
	Character,
	Gear,
	Challenges,
	Controls,
	Controls_Gamepad,
	Controls_Keyboard,
	Settings,
	CheatWarning,

	FirstGenerated	// Pages built from data at runtime, from Menu_NewPageIndex
}

// Pages of the in-game pause menu (oMenu_Game)
enum GameMenuPage{
	Main,
	Options,
	Cheats,
	CheatWarning,
	Quit
}

#macro CHEAT_WARNING_MSG "Cheats make some feats impossible.\n\nThe run stays marked as cheated, even if they are turned off again."


global.NewUserChrMap = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9","-",".",",","!","@","#","$"," "," "," "," "," "," "," "," "," "];
global.LetterGridSpacingW = 13;
global.LetterGridSpacingH = 18;
global.LetterGridColumns = 13;
global.LetterGridRows = 6;
global.MenuFont = font_add_sprite(sFont_Green, ord(" "), true, 0);
global.MenuFontProp = font_add_sprite(sFont_Green_Unprop, ord(" "), false, 0);
global.MenuFont_Innactive = font_add_sprite(sFont_Grey, ord(" "), true, 0);
global.MenuFont_Innactive2 = font_add_sprite(sFont_Black, ord(" "), true, 0);

function Menu_StartGame(){
	audio_stop_all();
	audio_play_sound(Sound_TextDone, 1, false);
	Load_PersonalBest()
	room_goto(Room_Dungeon);

}

function Menu_ContinueGame(){
	audio_stop_all();
	audio_play_sound(Sound_TextDone, 1, false);
	global.SaveLevel = true;
	global.Continue = true;
	room_goto(Room_Dungeon);

}


function Win_Main_Activate(_MenuIndex, _ResetSelector = true, _Sound = Sound_TextDone){

	MenuWin_Main_Active = true;
	MenuWin_Main_MenuIndex = _MenuIndex;

	MenuWin_Main_X_End = MenuWin_Main_X_Default;

	MenuWin_Main_Shift = true;
	MenuWin_Main_Shift_Dir = 1;

	MenuWin_Options_Active = false;

	Menu_Active = false;
	Menu_ActiveIndex = _MenuIndex;

	MenuWinInst_Main.sprite_index = sMenuWin;
	MenuWinInst_Title1.sprite_index = sMenuWin;
	MenuWinInst_Options.visible = false;
	MenuWinInst_Title2.visible = false;

	if(_ResetSelector){
		Selector_Index_Main = 0;
		Menu_Scroll[_MenuIndex] = 0;
	}

	audio_play_sound(_Sound, 1, false);

}

function Win_Main_SetX(_x){
	MenuWinInst_Main.x = _x;
	MenuWinInst_Title1.x = _x;
}


function Win_Options_Activate(_MenuIndex, _Sound = Sound_TextDone){

	Menu_ActiveIndex = _MenuIndex;

	MenuWin_Options_MenuIndex = _MenuIndex;
	MenuWin_Options_Active = true;

	var ScrW = camera_get_view_width(view_camera[0]);

	MenuWinInst_Options.W = Menu_TileW[_MenuIndex] * 8;

	MenuWin_Main_X_End = (ScrW - (MenuWinInst_Main.W + MenuWinInst_Options.W + 8)) / 2;

	MenuWinInst_Options.x = MenuWin_Main_X_End + MenuWinInst_Main.W + 8;

	MenuWinInst_Title2.W = MenuWinInst_Options.W;
	MenuWinInst_Title2.x = MenuWinInst_Options.x;

	MenuWinInst_Main.sprite_index = sMenuWin_Innactive;
	MenuWinInst_Title1.sprite_index = sMenuWin_Innactive;
	MenuWinInst_Options.visible = false;
	MenuWinInst_Title2.visible = false;

	MenuWin_Main_Active = false;
	MenuWin_Main_Shift = true;
	MenuWin_Main_Shift_Dir = MenuWin_Main_X_End >= MenuWinInst_Main.x ? 1 : -1;

	Menu_Active = false;

	Selector_Index_Options = 0;
	Menu_Scroll[_MenuIndex] = 0;
	Menu_HoldFrames = 0;

	audio_play_sound(_Sound, 1, false);

}

// Swaps the options window to another page without sliding the windows again (e.g. Start Game -> Character).
function Win_Options_Swap(_MenuIndex, _Sound = Sound_TextDone){
	Menu_ActiveIndex = _MenuIndex;
	MenuWin_Options_MenuIndex = _MenuIndex;
	Selector_Index_Options = 0;
	Menu_Scroll[_MenuIndex] = 0;
	Menu_HoldFrames = 0;
	audio_play_sound(_Sound, 1, false);
}

// The main page for the current user: "Continue" if they have a save, "New Game" otherwise.
function Menu_UserHome(){
	return global.Users[global.UserIndex].SaveData == -1 ? MenuIndex.NewGame : MenuIndex.ContinueGame;
}


#region Generic menu pages
/*
	A menu page lists row structs that are passed to Menu_Create.
	Each row is dynamically generated; A page's size is simply how many rows it was given.

	Row callbacks are rebound to oMenu and are always called with the row struct as their first argument,
	so any extra fields given to a row (e.g. { Key: "Inf_Health" }) can be used as that row's data.

	Pages with value rows (toggles/sliders) are editable. Changes apply live so they can be previewed,
	but the values are remembered when the page is opened through a link row. Back puts them back the way
	they were (the Back row reads "Discard" while there are unsaved changes), and only Save keeps them.
*/

#macro MENU_TOP_Y 70				// y of the first row of a title menu page
#macro MENU_VISIBLE_ROWS 7			// rows that fit in a window at 16px spacing; longer pages scroll
#macro MENU_SLIDER_W 40
#macro MENU_SLIDER_STEP 0.01
#macro MENU_SLIDER_REPEAT_DELAY 18	// frames left/right must be held before a slider starts repeating
#macro MENU_SLIDER_REPEAT_RATE 2	// frames between repeats after that

function Menu_Bind(_Fn){
	return is_callable(_Fn) ? method(self, _Fn) : _Fn;
}

/// @param {String} _Label		Row text. A "{s}" prefix adds 8px of extra space above the row.
/// @param {Function} _OnSelect	Called as _OnSelect(row) when the row is confirmed.
/// @param {Struct} _Fields		Extra fields copied onto the row. Recognised ones:
///								OnDraw(row, winX, y)	extra drawing next to the row
///								Title(row)				options window title while the row is selected
function Menu_Item(_Label, _OnSelect = undefined, _Fields = undefined){
	var _Gap = string_copy(_Label, 1, 3) == "{s}";
	var _Item = {
		Label: _Gap ? string_delete(_Label, 1, 3) : _Label,
		Gap: _Gap,
		OnSelect: Menu_Bind(_OnSelect),
		OnDraw: undefined,
		Title: undefined,
		IsBack: false,
		Get: undefined,
		Set: undefined,
		Slider: false,
		Min: 0,
		Max: 1,
		Blip: false
	};
	if(_Fields != undefined){
		var _Names = variable_struct_get_names(_Fields);
		for(var i = 0; i < array_length(_Names); i++){
			_Item[$ _Names[i]] = _Fields[$ _Names[i]];
		}
		_Item.OnDraw = Menu_Bind(_Item.OnDraw);
		_Item.Title = Menu_Bind(_Item.Title);
		if(variable_struct_exists(_Item, "OnSet")) _Item.OnSet = Menu_Bind(_Item.OnSet);
	}
	return _Item;
}

// An On/Off row. _Get(row) returns the current bool, _Set(value, row) stores a new one. Left/right or confirm flips it.
function Menu_Toggle(_Label, _Get, _Set, _Fields = undefined){
	var _Item = Menu_Item(_Label, undefined, _Fields);
	_Item.Get = Menu_Bind(_Get);
	_Item.Set = Menu_Bind(_Set);
	return _Item;
}

// A percentage slider between _Min and _Max. Holding left/right repeats. _Blip plays a (throttled) tick while sliding.
function Menu_Slider(_Label, _Get, _Set, _Min = 0, _Max = 1, _Blip = false, _Fields = undefined){
	var _Item = Menu_Toggle(_Label, _Get, _Set, _Fields);
	_Item.Slider = true;
	_Item.Min = _Min;
	_Item.Max = _Max;
	_Item.Blip = _Blip;
	return _Item;
}

// Toggle/slider rows bound straight to a global variable by name. _OnSet() runs after each change.
function Menu_GlobalToggle(_Label, _Global, _OnSet = undefined){
	return Menu_Toggle(_Label, Menu_GetGlobal, Menu_SetGlobal, { Global: _Global, OnSet: _OnSet });
}
function Menu_GlobalSlider(_Label, _Global, _Min = 0, _Max = 1, _OnSet = undefined, _Blip = false){
	return Menu_Slider(_Label, Menu_GetGlobal, Menu_SetGlobal, _Min, _Max, _Blip, { Global: _Global, OnSet: _OnSet });
}
function Menu_GetGlobal(_Row){
	return variable_global_get(_Row.Global);
}
function Menu_SetGlobal(_Value, _Row){
	variable_global_set(_Row.Global, _Value);
	if(_Row.OnSet != undefined) _Row.OnSet(_Row);
}

// Rows that open another page in the main (left) window, beside it in the options (right) window,
// or in place of the page currently in the options window.
// Opening a page through any of these is what starts its edit session, via Menu_TakeSnapshot
function Menu_LinkMain(_Label, _MenuIndex, _Fields = {}){
	_Fields.Target = _MenuIndex;
	return Menu_Item(_Label, function(_Row){
		Win_Main_Activate(_Row.Target);
		Menu_TakeSnapshot(_Row.Target);
	}, _Fields);
}
function Menu_LinkSide(_Label, _MenuIndex, _Sound = Sound_TextDone, _Fields = {}){
	_Fields.Target = _MenuIndex;
	_Fields.Sound = _Sound;
	return Menu_Item(_Label, function(_Row){
		Win_Options_Activate(_Row.Target, _Row.Sound);
		Menu_TakeSnapshot(_Row.Target);
	}, _Fields);
}
function Menu_LinkSwap(_Label, _MenuIndex, _Fields = {}){
	_Fields.Target = _MenuIndex;
	return Menu_Item(_Label, function(_Row){
		Win_Options_Swap(_Row.Target);
		Menu_TakeSnapshot(_Row.Target);
	}, _Fields);
}

// Leaves the page, discarding unsaved changes on editable pages
function Menu_BackItem(_Label = "Back"){
	return Menu_Item(_Label, Menu_Back, { IsBack: true });
}

// Keeps the page's changes (runs the page's OnSave) and leaves it
function Menu_SaveItem(_Label = "Save"){
	return Menu_Item(_Label, Menu_Save);
}

/// @param {Real} _MenuIndex
/// @param {String} _Title
/// @param {Array} _Items	Rows built with Menu_Item and friends. Pages drawn by hand (name entry, stats...) pass [].
/// @param {Struct} _Config	Optional page settings:
///  TileW (20)					options window width, in 8px tiles
///  Selector (true)			draw the selector arrow / allow moving it
///  YSpace (16)				pixels between rows
///  VisibleRows (all)			rows shown at once; the rest scroll
///  Font, TextOffsetY			row label font and y offset
///  Parent						main-window page that Back returns to (selector kept)
///  OnBack(sound)				called on Back/Save instead, when there is no Parent; sound is the one to play
///  OnSave()					called by the Save row to write the page's values to disk
///  Top (MENU_TOP_Y)			y of the first row
///  Anything else is kept in Menu_Config for the menu object's own use (e.g. the pause menu's Centered/TitleY)
function Menu_Create(_MenuIndex, _Title, _Items, _Config = {}){

	var _Count = array_length(_Items);

	Menu[_MenuIndex] = _Items;
	Menu_Count[_MenuIndex] = _Count;
	Menu_Title[_MenuIndex] = _Title;
	Menu_TileW[_MenuIndex] = _Config[$ "TileW"] ?? 20;
	Menu_Selector[_MenuIndex] = _Config[$ "Selector"] ?? true;
	Menu_VisibleRows[_MenuIndex] = min(_Config[$ "VisibleRows"] ?? _Count, _Count);
	Menu_Font[_MenuIndex] = _Config[$ "Font"] ?? global.MenuFont;
	Menu_TextOffsetY[_MenuIndex] = _Config[$ "TextOffsetY"] ?? 0;
	Menu_Parent[_MenuIndex] = _Config[$ "Parent"];
	Menu_OnBack[_MenuIndex] = Menu_Bind(_Config[$ "OnBack"]);
	Menu_OnSave[_MenuIndex] = Menu_Bind(_Config[$ "OnSave"]);
	Menu_Snapshot[_MenuIndex] = undefined;
	Menu_Scroll[_MenuIndex] = 0;
	Menu_Config[_MenuIndex] = _Config;

	// Unscrolled row positions; Menu_RowY applies the scroll
	var _YSpace = _Config[$ "YSpace"] ?? 16;
	var _Y = _Config[$ "Top"] ?? MENU_TOP_Y;
	Menu_Y[_MenuIndex] = array_create(_Count);
	for(var i = 0; i < _Count; i++){
		if(i > 0) _Y += _YSpace + (_Items[i].Gap ? 8 : 0);
		Menu_Y[_MenuIndex][i] = _Y;
	}

}

// A free page index for pages that don't have a MenuIndex entry
function Menu_NewPageIndex(){
	var _Used = variable_instance_exists(id, "Menu") ? array_length(Menu) : 0;
	return max(_Used, MenuIndex.FirstGenerated);
}

function Menu_RowY(_MenuIndex, _Row){
	return Menu_Y[_MenuIndex][_Row] - (Menu_Y[_MenuIndex][Menu_Scroll[_MenuIndex]] - Menu_Y[_MenuIndex][0]);
}

function Menu_IsRowVisible(_MenuIndex, _Row){
	var _Scroll = Menu_Scroll[_MenuIndex];
	return _Row >= _Scroll && _Row < _Scroll + Menu_VisibleRows[_MenuIndex];
}

// Row struct under the selector of the active page, or undefined for pages without rows
function Menu_SelectedRow(){
	if(Menu_Count[Menu_ActiveIndex] == 0) return undefined;
	return Menu[Menu_ActiveIndex][MenuWin_Main_Active ? Selector_Index_Main : Selector_Index_Options];
}

// Moves a page's selector by _Dir (wrapping), scrolls to keep it visible, and returns the new index
function Menu_MoveSelector(_MenuIndex, _Index, _Dir){
	var _Count = Menu_Count[_MenuIndex];
	_Index = (_Index + _Dir + _Count) mod _Count;

	var _Visible = Menu_VisibleRows[_MenuIndex];
	var _Scroll = Menu_Scroll[_MenuIndex];
	if(_Index < _Scroll) _Scroll = _Index;
	if(_Index >= _Scroll + _Visible) _Scroll = _Index - _Visible + 1;
	Menu_Scroll[_MenuIndex] = clamp(_Scroll, 0, _Count - _Visible);

	audio_play_sound(Sound_Text, 1, false);
	return _Index;
}

function Menu_RowHasValue(_Row){
	return _Row.Get != undefined;
}

function Menu_RowValueText(_Row){
	var _Value = _Row.Get(_Row);
	if(_Row.Slider) return string(round(_Value * 100)) + "%";
	return _Value ? "On" : "Off";
}

// Slider fill, 0 to 1
function Menu_RowFraction(_Row){
	return clamp((_Row.Get(_Row) - _Row.Min) / (_Row.Max - _Row.Min), 0, 1);
}

// Confirm on a row: run its action, or flip it if it's a toggle
function Menu_RowSelect(_Row){
	if(_Row.OnSelect != undefined) _Row.OnSelect(_Row);
	else if(Menu_RowHasValue(_Row) && !_Row.Slider) Menu_RowChange(_Row, 1);
}

// Left/right on a value row: toggles flip, sliders step
function Menu_RowChange(_Row, _Dir){
	if(!_Row.Slider){
		_Row.Set(!_Row.Get(_Row), _Row);
		audio_play_sound(Sound_Text, 1, false);
		return;
	}

	var _Old = _Row.Get(_Row);
	var _New = clamp(round((_Old + (_Dir * MENU_SLIDER_STEP)) * 100) / 100, _Row.Min, _Row.Max);
	if(_New == _Old) return;

	_Row.Set(_New, _Row);
	if(_Row.Blip && current_time - Menu_LastBlip > 150){
		audio_play_sound(Sound_Text, 1, false);
		Menu_LastBlip = current_time;
	}
}

// Handles left/right being held on a value row. Called every frame the row is selected.
function Menu_RowHold(_Row){
	var _Dir = (input_check("menu_right") ? 1 : 0) - (input_check("menu_left") ? 1 : 0);
	if(_Dir == 0){
		Menu_HoldFrames = 0;
		return;
	}

	var _Repeat = _Row.Slider && Menu_HoldFrames > MENU_SLIDER_REPEAT_DELAY && (Menu_HoldFrames mod MENU_SLIDER_REPEAT_RATE == 0);
	if(Menu_HoldFrames == 0 || _Repeat) Menu_RowChange(_Row, _Dir);
	Menu_HoldFrames++;
}

// Remembers the current values of a page's value rows, so Back can put them back
function Menu_TakeSnapshot(_MenuIndex){
	var _Values = array_create(Menu_Count[_MenuIndex], undefined);
	for(var i = 0; i < Menu_Count[_MenuIndex]; i++){
		var _Row = Menu[_MenuIndex][i];
		if(Menu_RowHasValue(_Row)) _Values[i] = _Row.Get(_Row);
	}
	Menu_Snapshot[_MenuIndex] = _Values;
}

function Menu_HasChanges(_MenuIndex){
	var _Snapshot = Menu_Snapshot[_MenuIndex];
	if(_Snapshot == undefined) return false;
	for(var i = 0; i < Menu_Count[_MenuIndex]; i++){
		var _Row = Menu[_MenuIndex][i];
		if(Menu_RowHasValue(_Row) && _Row.Get(_Row) != _Snapshot[i]) return true;
	}
	return false;
}

// Puts back value rows that changed since the snapshot (through Set, so side effects like volume re-apply)
function Menu_RestoreSnapshot(_MenuIndex){
	var _Snapshot = Menu_Snapshot[_MenuIndex];
	if(_Snapshot == undefined) return;
	for(var i = 0; i < Menu_Count[_MenuIndex]; i++){
		var _Row = Menu[_MenuIndex][i];
		if(Menu_RowHasValue(_Row) && _Row.Get(_Row) != _Snapshot[i]) _Row.Set(_Snapshot[i], _Row);
	}
}

// Leaves the active page, discarding unsaved changes
function Menu_Back(){
	Menu_RestoreSnapshot(Menu_ActiveIndex);
	Menu_Leave();
}

// Saves the active page and every page it was opened from (e.g. pause menu Options > Cheats saves both),
// makes the saved values their new baseline, then leaves the active page
function Menu_Save(){
	for(var i = 0; i < array_length(Menu_Snapshot); i++){
		if(Menu_Snapshot[i] == undefined && i != Menu_ActiveIndex) continue;
		if(Menu_OnSave[i] != undefined) Menu_OnSave[i]();
		if(Menu_Snapshot[i] != undefined) Menu_TakeSnapshot(i);
	}
	Menu_Leave(Sound_ItemGet);
}

// Goes to the active page's Parent, or runs its OnBack
// _Sound is what plays as the page closes (Back and Save sound different)
function Menu_Leave(_Sound = Sound_Throw){
	var _MenuIndex = Menu_ActiveIndex;
	Menu_Snapshot[_MenuIndex] = undefined;
	if(Menu_Parent[_MenuIndex] != undefined) Win_Main_Activate(Menu_Parent[_MenuIndex], false, _Sound);
	else if(Menu_OnBack[_MenuIndex] != undefined) Menu_OnBack[_MenuIndex](_Sound);
}

// Back rows read "Discard" while their page has unsaved changes
function Menu_RowLabel(_Row, _HasChanges){
	return (_Row.IsBack && _HasChanges) ? "Discard" : _Row.Label;
}

// Draws a row's value right-aligned at _Right. Sliders also get a bar between the value and the label's end
// (_LabelRight), up to MENU_SLIDER_W wide, so they shrink to fit narrow windows like the pause menu.
function Menu_DrawRowValue(_Row, _LabelRight, _Right, _Y){
	draw_set_halign(fa_right);
	draw_text(_Right, _Y, Menu_RowValueText(_Row));
	draw_set_halign(fa_left);
	
	if(!_Row.Slider) return;
	var _BarRight = _Right - string_width("100%") - 6;
	var _BarW = min(MENU_SLIDER_W, _BarRight - _LabelRight - 6);
	if(_BarW < 8) return;
	var _BX = _BarRight - _BarW;
	var _BY = _Y + 6;
	var _Fill = round(_BarW * Menu_RowFraction(_Row));
	draw_set_color(c_dkgray);
	draw_rectangle(_BX, _BY, _BX + _BarW, _BY + 3, false);
	draw_set_color(c_white);
	draw_rectangle(_BX, _BY, _BX + _Fill, _BY + 3, false);
	draw_rectangle(_BX + _Fill - 1, _BY - 2, _BX + _Fill + 1, _BY + 5, false);
}

// Up/down arrows at _X when a page has rows scrolled out of view: one pointing up above _TopY, one pointing down below _BottomY
function Menu_DrawScrollArrows(_MenuIndex, _X, _TopY, _BottomY){
	var _Scroll = Menu_Scroll[_MenuIndex];
	draw_set_color(c_white);
	if(_Scroll > 0) draw_triangle(_X - 4, _TopY - 4, _X + 4, _TopY - 4, _X, _TopY - 10, false);
	if(_Scroll + Menu_VisibleRows[_MenuIndex] < Menu_Count[_MenuIndex]) draw_triangle(_X - 4, _BottomY, _X + 4, _BottomY, _X, _BottomY + 6, false);
}

#endregion

#region Page-specific row callbacks

function Menu_SelectUser(_Row){
	global.UserIndex = _Row.User;

	if(global.Users[global.UserIndex].Name == ""){
		Win_Options_Activate(MenuIndex.NewUser);
		LetterGrid_Init();
		return;
	}

	var _Sound = Sound_TextDone;
	switch(User_VerifyIntegrity()){
		case 1:
			ErrorMsgInst = MsgBox("Keyboard profile error, resetting to default controls.",,,,80);
			_Sound = Sound_Error;
			break;
		case 2:
			ErrorMsgInst = MsgBox("Gamepad profile error, resetting to default controls.",,,,80);
			_Sound = Sound_Error;
			break;
	}
	// On the title screen, cheats count as on when this user has any saved
	global.CheatsEnabled = Cheats_Enabled(false);
	Win_Main_Activate(Menu_UserHome(),, _Sound);
	Menu_Title[MenuIndex.ContinueGame] = global.Users[global.UserIndex].Name;
	Menu_Title[MenuIndex.NewGame] = global.Users[global.UserIndex].Name;
	input_profile_import(global.Users[global.UserIndex].InputProfile_Gamepad, "gamepad");
	input_profile_import(global.Users[global.UserIndex].InputProfile_Keyboard, "keyboard");
	Bindings_GetIcons(Input_Index.Gamepad);
	Bindings_GetIcons(Input_Index.Keyboard);
}

function Menu_DrawUserName(_Row, _WinX, _Y){
	draw_text(_WinX + 43, _Y, global.Users[_Row.User].Name);
}

function Menu_TryContinue(){
	if(!global.SaveVersionCheck || global.Users[global.UserIndex].SaveData.GameVersion == VERSION){
		Menu_ContinueGame();
	}else{
		ErrorMsgInst = MsgBox("Save file version error!\\Use the game version the save\\was created with.",,Sound_Error,,80);
	}
}

function Menu_DrawCharacterPreview(_Row, _WinX, _Y){
	draw_sprite(global.CharacterSprites, global.LinkCharacterIndex, _WinX + 94, _Y - 6);
}

function Menu_DrawGearPreview(_Row, _WinX, _Y){
	var _Gear = global.GearInfo[global.StartingGear];
	Menu_DrawGear(global.StartingGear, _WinX + 102, _Y + 17 + _Gear.OffsetY);
}

// Gear icon, plus the amount it gives for stackable gear
function Menu_DrawGear(_GearIndex, _X, _Y){
	var _Gear = global.GearInfo[_GearIndex];
	draw_sprite(_Gear.Sprite, _Gear.Image, _X, _Y);

	var _Amount = undefined;
	var _AmountX = 0;
	switch(_GearIndex){
		case StartingGear.Rupees:	_Amount = StartingGear_Rupees; _AmountX = -1; break;
		case StartingGear.Rod:		_Amount = global.MaxRodCharge[Rod.Stone]; break;
		case StartingGear.Orbs:		_Amount = StartingGear_Orbs; _AmountX = 3; break;
	}
	if(_Amount == undefined) return;

	draw_set_font(global.Font_ItemValues);
	draw_text(_X + _AmountX, _Y - 6, string(_Amount));
	draw_set_font(global.MenuFont);
}

function Menu_DrawGearRow(_Row, _WinX, _Y){
	var _Gear = global.GearInfo[_Row.Gear];
	Menu_DrawGear(_Row.Gear, _WinX + 123 + _Gear.OffsetX, _Y + 17 + _Gear.OffsetY);
}

function Menu_PickGear(_Row){
	global.StartingGear = _Row.Gear;
	Win_Options_Swap(MenuIndex.NewGame_Start);
}

function Menu_AnyChallengeActive(){
	for(var i = 0; i < array_length(global.ChallengeOptions); i++){
		if(global.ChallengeOptions[i] > 0) return true;
	}
	for(var i = 0; i < array_length(global.Challenges); i++){
		if(global.Challenges[i]) return true;
	}
	return false;
}

function Menu_DrawChallengeSkull(_Row, _WinX, _Y){
	if(Menu_AnyChallengeActive()) draw_sprite(sLargeMap_Boss, 0, _WinX + 95, _Y + 1);
}

function Menu_CycleChallengeOption(_Row){
	var _Levels = array_length(global.ChallengeOptionInfo[_Row.Option].Titles);
	global.ChallengeOptions[_Row.Option] = (global.ChallengeOptions[_Row.Option] + 1) mod _Levels;
	audio_play_sound(Sound_TextDone, 1, false);
}

function Menu_ChallengeOptionTitle(_Row){
	return global.ChallengeOptionInfo[_Row.Option].Titles[global.ChallengeOptions[_Row.Option]];
}

// Bar showing the challenge level; most bars shrink as the challenge gets harder, the rest grow
function Menu_DrawChallengeOption(_Row, _WinX, _Y){
	var _Option = _Row.Option;
	var _Level = global.ChallengeOptions[_Option];
	var _X = _WinX + 103.5;
	_Y += 3;

	switch(_Option){
		case ChallengeOption.MaxRupees:
			draw_sprite_stretched(sChallengeOptions, _Option, _X + 0.5, _Y, 8 * (4 - _Level), 8);
			break;
		case ChallengeOption.ShopPrices:
			draw_sprite_stretched(sChallengeOptions, _Option, _X + 0.5, _Y, 8 * (_Level + 1), 8);
			break;
		case ChallengeOption.Darkness:
			if(_Level == ChallengeOption_Darkness.NoLights) draw_sprite(sChallengeOptions, 9, _X, _Y);
			else draw_sprite_stretched(sChallengeOptions, _Option, _X, _Y, 8 * (4 - _Level), 8);
			break;
		case ChallengeOption.StartingHearts:
		case ChallengeOption.HeartsMax:
		case ChallengeOption.Defense:
		case ChallengeOption.Inventory:
			draw_sprite_stretched(sChallengeOptions, _Option, _X, _Y, 8 * (4 - _Level), 8);
			break;
		default:
			draw_sprite_stretched(sChallengeOptions, _Option, _X, _Y, 8 * (_Level + 1), 8);
			break;
	}
}

function Menu_ToggleChallenge(_Row){
	global.Challenges[_Row.Challenge] = !global.Challenges[_Row.Challenge];
	audio_play_sound(Sound_TextDone, 1, false);
}

function Menu_ChallengeTitle(_Row){
	return global.ChallengeInfo[_Row.Challenge].Title;
}

function Menu_DrawChallengeCheckbox(_Row, _WinX, _Y){
	var _On = global.Challenges[_Row.Challenge];
	draw_sprite(_On ? sCheckbox : sCheckBox_Innactive, _On ? 1 : 0, _WinX + 103, _Y + 2);
}

function Menu_RemapControls(_Row){
	// Feather disable once GM2064
	instance_create_layer(-100, -100, "Menu", oInputRemap, {InputIndex : _Row.Input});
}

function Menu_ResetControls(_Row){
	input_profile_reset_bindings(_Row.Input == Input_Index.Gamepad ? "gamepad" : "keyboard");
	User_SaveControls();
	Bindings_GetIcons(_Row.Input);
	audio_play_sound(Sound_Throw, 1, false);
}

// Group names used in global.CheatList, in the order they first appear
function Menu_CheatGroups(){
	var _Groups = [];
	for(var i = 0; i < array_length(global.CheatList); i++){
		var _Group = global.CheatList[i][$ "Group"];
		if(_Group != undefined && !array_contains(_Groups, _Group)) array_push(_Groups, _Group);
	}
	return _Groups;
}

// Toggle rows for every cheat in global.CheatList whose Group matches (undefined = the main Cheats page)
function Menu_CheatRows(_Group = undefined){
	var _Rows = [];
	for(var i = 0; i < array_length(global.CheatList); i++){
		var _Cheat = global.CheatList[i];
		if(_Cheat[$ "Group"] != _Group) continue;
		array_push(_Rows, Menu_Toggle(_Cheat.Label, Menu_GetCheat, Menu_SetCheat, { Key: _Cheat.Key }));
	}
	return _Rows;
}

// Cheat rows read/write the current user's Cheats struct; _Row.Key is the cheat's name in it
function Menu_GetCheat(_Row){
	return global.Users[global.UserIndex].Cheats[$ _Row.Key] == true;
}
function Menu_SetCheat(_Value, _Row){
	global.Users[global.UserIndex].Cheats[$ _Row.Key] = _Value;
}

// Save row for cheat pages. If saving would turn cheats on while they're off, the "Enable Cheats?" page asks first.
// Each menu object defines Menu_OpenCheatWarning() / Menu_CloseCheatWarning(confirm) for its own window layout.
function Menu_CheatSaveItem(){
	return Menu_Item("Save", Menu_TrySaveCheats);
}
function Menu_TrySaveCheats(){
	if(!global.CheatsEnabled && Cheats_Enabled(false)) Menu_OpenCheatWarning();
	else Menu_Save();
}

// Rows of the "Enable Cheats?" page; Back (or Cancel) returns to the cheat page with its changes still unsaved
function Menu_CheatWarningRows(){
	return [
		Menu_BackItem("Cancel"),
		Menu_Item("OK", function(){ Menu_CloseCheatWarning(true); })
	];
}

// Wrapped warning text for pages that set a Message in their config
function Menu_DrawMessage(_Msg, _X, _Y, _W, _Centered = false){
	draw_set_font(global.Font_Small);
	draw_set_halign(_Centered ? fa_center : fa_left);
	draw_text_ext(_X, _Y, string_upper(_Msg), 9, _W);
	draw_set_halign(fa_left);
}

#endregion



#region Pause menu (oMenu_Game)

/// @description Opens a pause menu page, resets its selector and scroll position, resizes and centers the frame to match the page's width, and plays the opening sound.
/// @param {Real} _Page Index of the pause menu page to open.
/// @param {Asset.GMSound} [_Sound] Sound to play when opening the page. Defaults to Sound_TextDone.
function GameMenu_Open(_Page, _Sound = Sound_TextDone){
	Menu_ActiveIndex = _Page;
	SelectorPos = 0;
	Menu_Scroll[_Page] = 0;
	Menu_HoldFrames = 0;
	FrameW = Menu_TileW[_Page] * 8;
	FrameX = oCamera.X + ((CAM_W - FrameW) / 2);
	FrameCentre = FrameX + (FrameW / 2);
	if(_Sound != noone) audio_play_sound(_Sound, 1, false);
}

/// @description Creates a menu row that opens another pause menu page and starts its edit session by taking a snapshot of the page's values.
/// @param {String} _Label Text displayed on the menu row.
/// @param {Real} _Page Index of the pause menu page to open.
/// @param {Struct} [_Fields] Optional additional row fields, including custom properties used by the row callback.
/// @returns {Struct} The menu row created by Menu_Item.
function GameMenu_Link(_Label, _Page, _Fields = {}){
	_Fields.Target = _Page;
	return Menu_Item(_Label, function(_Row){
		GameMenu_Open(_Row.Target);
		Menu_TakeSnapshot(_Row.Target);
	}, _Fields);
}

/// @description Closes the pause menu, begins fading the music, and plays the closing sound.
function GameMenu_Close(){
	Close = true;
	Music_Fade(1, 6);
	audio_play_sound(Sound_Throw, 1, false);
}

/// @description Opens the quit confirmation page using the destination and prompt specified by the selected menu row.
/// @param {Struct} _Row Menu row containing the QuitTo destination and Prompt text.
function GameMenu_AskQuit(_Row){
	// QuitTo is passed on to oQuit; Prompt is shown above Cancel/OK.
	QuitTo = _Row.QuitTo;
	Menu_Title[GameMenuPage.Quit] = _Row.Prompt;
	GameMenu_Open(GameMenuPage.Quit);
}

/// @description Stops all music and audio, plays the confirmation sound, and schedules the game to quit after QuitDelay frames.
function GameMenu_Quit(){
	Music_Stop();
	audio_stop_all();
	audio_play_sound(Sound_TextDone, 1, false);
	Quitting = true;
	alarm[0] = QuitDelay;
}

/// @description Returns the current user's value for the preference referenced by the menu row.
/// @param {Struct} _Row Menu row containing the Pref key.
function Menu_GetPref(_Row){
	return global.Users[global.UserIndex].Prefs[_Row.Pref];
}

/// @description Updates the current user's value for the preference referenced by the menu row.
/// @param {*} _Value New value to assign to the preference.
/// @param {Struct} _Row Menu row containing the Pref key.
function Menu_SetPref(_Value, _Row){
	global.Users[global.UserIndex].Prefs[_Row.Pref] = _Value;
}

/// @description Saves the current user data, applies enabled gameplay cheats to the current game, and updates the inventory to reflect any changes.
function GameMenu_SaveCheats(){
	User_Save();
	Init_Gameplay_Cheats();
	Inventory_Update();
	global.CheatsEnabled = Cheats_Enabled(true);
}

#endregion



function LetterGrid_Init(){
	LetterGridX = MenuWinInst_Options.x + 14;
	LetterGridY = MenuWinInst_Options.y + 20;
	NameEntryCross_GridX = 0;
	NameEntryCross_GridY = 0;
	NameEntryCross_X = LetterGrid_GetX(NameEntryCross_GridX);
	NameEntryCross_Y = LetterGrid_GetY(NameEntryCross_GridY);
	NameEntryCross_MoveEndX = NameEntryCross_X;
	NameEntryCross_MoveEndY = NameEntryCross_Y;
	NameEntry_Name = "";
}

function LetterGrid_GetX(_GridX){
	return LetterGridX + (_GridX * global.LetterGridSpacingW);
}
function LetterGrid_GetY(_GridY){
	return LetterGridY + (_GridY * global.LetterGridSpacingH);
}
function LetterGrid_GetGridX(_X){
	return floor((_X - LetterGridX) / global.LetterGridSpacingW);
}
function LetterGrid_GetGridY(_Y){
	return floor((_Y - LetterGridY) / global.LetterGridSpacingH);
}
function LetterGrid_DrawCrossHair_H(){
	draw_set_alpha(0.5);
	for(var _x = MenuWinInst_Options.x + 6; _x < MenuWinInst_Options.x + MenuWinInst_Options.W - 6; _x++){
		draw_sprite(sPixel, 0, _x, NameEntryCross_Y + 8);
	}
	draw_set_alpha(1);
}
function LetterGrid_DrawCrossHair_V(){
	draw_set_alpha(0.5);
	for(var _y = MenuWinInst_Options.y + 6; _y < MenuWinInst_Options.y + MenuWinInst_Options.H - 6; _y++){
		draw_sprite(sPixel, 0, NameEntryCross_X + 3, _y);
	}
	draw_set_alpha(1);
}

function LetterGrid_GetLetter(){
	return global.NewUserChrMap[(NameEntryCross_GridY * global.LetterGridColumns) + NameEntryCross_GridX];

}
