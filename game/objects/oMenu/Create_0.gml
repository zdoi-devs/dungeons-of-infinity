

//var profile = ds_map_create();
//profile = input_profile_export("gamepad", 0, false, true);

//var player = ds_map_create();
//player = input_player_export(0, false, true);


//var system = ds_map_create();
//system = input_system_export(false, true);

//var p = input_profile_get();
//var b = input_binding_get("sword",,, "gamepad")

//var i = input_binding_get_icon(b);



MenuWin_Main_MenuIndex = MenuIndex.NameSelect;
MenuWin_Main_Active = true;
MenuWin_Main_X_Default = 144;
MenuWin_Main_X_End = 0;

MenuWin_Main_Shift = false;
MenuWin_Main_Shift_Dir = -1;
MenuWin_Main_Shift_V = 5;

MenuWin_Options_MenuIndex = MenuIndex.Options;
MenuWin_Options_Active = false;

ErrorMsgInst = noone;

var _CreateNewFile = false;
if(file_exists(USERSFILE)){
		
	var Buffer = xzip_read(USERSFILE, XZIPFILE_USERS);
	if(Buffer == -1){
		
		ErrorMsgInst = MsgBox("Error reading User file, creating new file.",,,,80);
		
		_CreateNewFile = true;
		
	}else{
		var JSONStr = buffer_read(Buffer, buffer_string);
		buffer_delete(Buffer);

		global.Users = json_parse(JSONStr);
	}
	
}else{
	
	_CreateNewFile = true;

}

if(_CreateNewFile){
	
	global.Users = array_create(0);

	repeat(global.MaxUsers){
		array_insert(global.Users, array_length(global.Users), new User_Create());
	}

	xzip_create(USERSFILE, XZIPFILE_USERS);
	
	HighScores = array_create(8);
	HighScores[ArcadeGame.Pitfall] = 5000;
	HighScores[ArcadeGame.Zerberk] = 3000;
	HighScores[ArcadeGame.SporkInvaders] = 100;
	var _Buffer = EncodeDataToBuffer(HighScores);
	xzip_write(USERSFILE, _Buffer, XZIPFILE_ARCADES);
	buffer_delete(_Buffer);
	
	User_Save();
	
}

global.LinkCharacterIndex = 0;

var SprW = 16;
var SprH = 24;	
var SprSurface = surface_create(SprW, SprH);
surface_set_target(SprSurface);

for(var _CharacterIndex = 0; _CharacterIndex < LinkCharacters; _CharacterIndex++){
	
	var SpriteSheet = global.LinkCharacterSpr[_CharacterIndex];
	draw_clear_alpha(c_black, 0.0);
	draw_sprite_part(SpriteSheet, 0,   48, 16,   16, 16,   0, 8);    //source body
	draw_sprite_part(SpriteSheet, 0,   16, 0,    16, 16,   0, 0);    //source head	
	if(_CharacterIndex == 0){
		global.CharacterSprites = sprite_create_from_surface(SprSurface, 0, 0, SprW, SprH, false, false, 0, 0);
	}else{
		sprite_add_from_surface(global.CharacterSprites, SprSurface, 0, 0, SprW, SprH, false, false);
	}

}

surface_reset_target();		
surface_free(SprSurface);


global.ChallengeOptions = array_create(array_length(global.ChallengeOptionInfo), 0);
global.Challenges = array_create(array_length(global.ChallengeInfo), false);

Selector_Index_Main = 0;
Selector_Index_Options = 0;
Menu_HoldFrames = 0;
Menu_LastBlip = 0;
Selector_Frame = 0;
alarm[0] = 8;

LetterGridX = 0;
LetterGridY = 0;

NameEntryCross_X = 0;
NameEntryCross_Y = 0;
NameEntryCross_GridX = 0;
NameEntryCross_GridY = 0;
NameEntryCross_Move = false;
NameEntryCross_MoveV = 2;
NameEntryCross_MoveDirX = 0;
NameEntryCross_MoveDirY = 0;
NameEntryCross_MoveEndX = 0;
NameEntryCross_MoveEndY = 0;
NameEntryCross_ReboundX = false;
NameEntryCross_ReboundY = false;

NameEntry_Name = "";
NameEntry_Rename = false;

Bindings_Remap = false;
Bindings_GetIcons(Input_Index.Gamepad);
Bindings_GetIcons(Input_Index.Keyboard);

	
#region Menu pages
// Each page lists its rows in display order; see Menu_Create / Menu_Item in __Menu for the available row types and page settings.

var _UserRows = [];
for(var i = 0; i < global.MaxUsers; i++){
	array_push(_UserRows, Menu_Item(string(i + 1) + ".", Menu_SelectUser, { User: i, OnDraw: Menu_DrawUserName }));
}
array_push(_UserRows, Menu_Item("{s}Exit", function(){ game_end(); }));
Menu_Create(MenuIndex.NameSelect, "Select User", _UserRows);

Menu_Create(MenuIndex.NewUser, "Register Your Name", [], { TileW: 24, Selector: false });

var _BackToUsers = function(){
	Win_Main_Activate(MenuIndex.NameSelect,, Sound_Throw);
	Selector_Index_Main = global.UserIndex;
};
Menu_Create(MenuIndex.NewGame, "", [
	Menu_LinkSide("New Game", MenuIndex.NewGame_Start),
	Menu_LinkMain("{s}Options", MenuIndex.Options),
	Menu_LinkSide("{s}Stats", MenuIndex.Stats),
	Menu_BackItem("{s}Back")
], { OnBack: _BackToUsers });
Menu_Create(MenuIndex.ContinueGame, "", [
	Menu_Item("Continue", Menu_TryContinue),
	Menu_LinkSide("{s}New Game", MenuIndex.NewGame_Start),
	Menu_LinkMain("{s}Options", MenuIndex.Options),
	Menu_LinkSide("{s}Stats", MenuIndex.Stats),
	Menu_BackItem("{s}Back")
], { OnBack: _BackToUsers });

var _BackToUserHome = function(){ Win_Main_Activate(Menu_UserHome(),, Sound_Throw); };
var _BackToStartGame = function(){ Win_Options_Swap(MenuIndex.NewGame_Start); };

Menu_Create(MenuIndex.NewGame_Start, "Start Game", [
	Menu_Item("Start", Menu_StartGame),
	Menu_LinkSwap("{s}Character", MenuIndex.Character, { OnDraw: Menu_DrawCharacterPreview }),
	Menu_LinkSwap("{s}Bonus Item", MenuIndex.Gear, { OnDraw: Menu_DrawGearPreview }),
	Menu_LinkSwap("{s}Challenges", MenuIndex.Challenges, { OnDraw: Menu_DrawChallengeSkull }),
	Menu_BackItem("{s}Back")
], { TileW: 18, OnBack: _BackToUserHome });

Menu_Create(MenuIndex.Character, "Select a Character", [], { TileW: 18, Selector: false, OnBack: _BackToStartGame });

var _GearRows = [];
for(var i = 0; i < array_length(global.GearInfo); i++){
	array_push(_GearRows, Menu_Item(global.GearInfo[i].Label, Menu_PickGear, { Gear: i, OnDraw: Menu_DrawGearRow }));
}
// Backing out also keeps the highlighted item, like confirming it
Menu_Create(MenuIndex.Gear, "Pick a Bonus Item", _GearRows, { TileW: 18, OnBack: function(){ Menu_PickGear(Menu_SelectedRow()); } });

var _ChallengeRows = [Menu_BackItem("BACK")];
for(var i = 0; i < array_length(global.ChallengeOptionInfo); i++){
	array_push(_ChallengeRows, Menu_Item(global.ChallengeOptionInfo[i].Label, Menu_CycleChallengeOption, { Option: i, Title: Menu_ChallengeOptionTitle, OnDraw: Menu_DrawChallengeOption }));
}
for(var i = 0; i < array_length(global.ChallengeInfo); i++){
	array_push(_ChallengeRows, Menu_Item(global.ChallengeInfo[i].Label, Menu_ToggleChallenge, { Challenge: i, Title: Menu_ChallengeTitle, OnDraw: Menu_DrawChallengeCheckbox }));
}
Menu_Create(MenuIndex.Challenges, "Enable Challenges", _ChallengeRows, {
	TileW: 18, YSpace: 10, Font: global.Font_Small, TextOffsetY: 4,
	OnBack: function(){ Win_Options_Swap(MenuIndex.NewGame_Start, Sound_Throw); }
});

Menu_Create(MenuIndex.Stats, "Stats", [], { TileW: 22, Selector: false, OnBack: _BackToUserHome });

Menu_Create(MenuIndex.Options, "Options", [
	Menu_BackItem(),
	Menu_LinkSide("{s}Settings", MenuIndex.Settings),
	Menu_LinkMain("{s}Controls", MenuIndex.Controls),
	Menu_LinkMain("{s}User", MenuIndex.User),
	Menu_LinkSide("{s}Cheats", MenuIndex.Cheats)
], { OnBack: _BackToUserHome });

// Cheats are toggles on the current user, listed from global.CheatList. Ungrouped cheats go on the Cheats page,
// followed by a link to each group's own sub-page, in the order the groups first appear in the list.
// Save writes them to the user file; Back puts them back the way they were.
var _SaveCheats = function(){
	User_Save();
	global.CheatsEnabled = Cheats_Enabled(false);
};
var _CheatPage = array_concat([Menu_BackItem(), Menu_CheatSaveItem()], Menu_CheatRows());
var _CheatGroups = Menu_CheatGroups();
for(var i = 0; i < array_length(_CheatGroups); i++){
	var _Group = _CheatGroups[i];
	var _GroupPage = Menu_NewPageIndex();
	Menu_Create(_GroupPage, _Group, array_concat([Menu_BackItem(), Menu_CheatSaveItem()], Menu_CheatRows(_Group)), {
		TileW: 32, VisibleRows: MENU_VISIBLE_ROWS, OnSave: _SaveCheats,
		OnBack: function(_Sound){ Win_Options_Swap(MenuIndex.Cheats, _Sound); }
	});
	array_push(_CheatPage, Menu_LinkSwap((i == 0 ? "{s}" : "") + _Group, _GroupPage));
}
Menu_Create(MenuIndex.Cheats, "Cheats", _CheatPage, {
	TileW: 25, VisibleRows: MENU_VISIBLE_ROWS, Parent: MenuIndex.Options, OnSave: _SaveCheats
});

// "Enable Cheats?" confirmation, shown in place of the cheat page being saved.
CheatWarning_ReturnPage = MenuIndex.Cheats;
Menu_OpenCheatWarning = function(){
	CheatWarning_ReturnPage = Menu_ActiveIndex;
	Win_Options_Swap(MenuIndex.CheatWarning, Sound_Boss_Hit);
};
Menu_CloseCheatWarning = function(_Confirm){
	var _Page = CheatWarning_ReturnPage;
	Menu_ActiveIndex = _Page;
	MenuWin_Options_MenuIndex = _Page;
	Selector_Index_Options = 1;	// back on the Save row
	Menu_HoldFrames = 0;
	if(_Confirm) Menu_Save();
	else audio_play_sound(Sound_Throw, 1, false);
};
Menu_Create(MenuIndex.CheatWarning, "Enable Cheats?", Menu_CheatWarningRows(), {
	Top: 140, Message: CHEAT_WARNING_MSG,
	OnBack: function(){ Menu_CloseCheatWarning(false); }
});

// Settings apply live so they can be previewed; Save writes them to options.ini, Back puts them back
Menu_Create(MenuIndex.Settings, "Settings", [
	Menu_BackItem(),
	Menu_SaveItem(),
	Menu_GlobalSlider("Music Volume", "MusicVol", 0, 1, User_UpdateMusicSFX),
	Menu_GlobalSlider("Sound Volume", "SFXVol", 0, 1, User_UpdateMusicSFX, true),
	Menu_GlobalToggle("Fullscreen", "Fullscreen", function(){ window_set_fullscreen(global.Fullscreen); }),
	Menu_GlobalToggle("Speedrunning Mode", "Speedrun"),
	Menu_GlobalToggle("Gore", "Gore"),
	Menu_GlobalToggle("Lighting", "GlobalLighting"),
	Menu_GlobalToggle("Alt-Tab Pause", "AltTabPause"),
	Menu_GlobalToggle("Stair Pause", "StairPause"),
	Menu_GlobalToggle("Save Version Check", "SaveVersionCheck"),
	Menu_GlobalToggle("Skip Intro", "CanSkipTitle"),
	Menu_GlobalSlider("Stick Sens.", "Gamepad_AnalogueThreshold", 0.05, 0.95)
], { TileW: 32, VisibleRows: MENU_VISIBLE_ROWS, Parent: MenuIndex.Options, OnSave: Settings_SaveIni });

Menu_Create(MenuIndex.Controls, "Controls", [
	Menu_BackItem(),
	Menu_LinkSide("{s}Gamepad", MenuIndex.Controls_Gamepad),
	Menu_LinkSide("{s}Keyboard", MenuIndex.Controls_Keyboard)
], { TileW: 30, Parent: MenuIndex.Options });

Menu_Create(MenuIndex.Controls_Gamepad, "Remap Gamepad", [
	Menu_BackItem(),
	Menu_Item("Remap", Menu_RemapControls, { Input: Input_Index.Gamepad }),
	Menu_Item("Default", Menu_ResetControls, { Input: Input_Index.Gamepad })
], { TileW: 25, Parent: MenuIndex.Controls });

Menu_Create(MenuIndex.Controls_Keyboard, "Remap Keyboard", [
	Menu_BackItem(),
	Menu_Item("Remap", Menu_RemapControls, { Input: Input_Index.Keyboard }),
	Menu_Item("Default", Menu_ResetControls, { Input: Input_Index.Keyboard })
], { TileW: 25, Parent: MenuIndex.Controls });

Menu_Create(MenuIndex.User, "User", [
	Menu_BackItem(),
	Menu_Item("{s}Rename", function(){
		NameEntry_Rename = true;
		Win_Options_Activate(MenuIndex.NewUser, Sound_Throw);
		LetterGrid_Init();
	}),
	Menu_LinkSide("{s}Delete", MenuIndex.UserDelete, Sound_Throw)
], { Parent: MenuIndex.Options });

Menu_Create(MenuIndex.UserDelete, "Delete?", [
	Menu_BackItem("No"),
	Menu_Item("Yes", function(){
		User_Delete();
		Win_Main_Activate(MenuIndex.NameSelect, true, Sound_KinstoneConnect);
	})
], { TileW: 10, Parent: MenuIndex.User });

#endregion

Win_Main_Activate(MenuWin_Main_MenuIndex);


depth = -100;

var MenuMusic = audio_play_sound(Music_Fairy_Main, 1, true);
audio_sound_gain(MenuMusic, 0.5, 0);