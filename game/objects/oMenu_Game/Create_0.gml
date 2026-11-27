Time_PauseStart();
TimePlayed = Time_Str(Time_PlayingTotal());


QuitTo = 0;
Quitting = false;
QuitDelay = 30;


depth = -1000;

Alpha = 0;
AlphaSpeed = 0.18;

Open = true;
Close = false;

FrameW = 128;
FrameH = 154;
FrameX = oCamera.X + ((CAM_W - FrameW) / 2);
FrameY = oCamera.Y + ((CAM_H - FrameH) / 2);
FrameCentre = FrameX + (FrameW / 2);

PlayTimeY = FrameY + FrameH - 25;

SelectorPos = 0;
Menu_HoldFrames = 0;
Menu_LastBlip = 0;

#region Menu pages
// Same page/row system as the title menu (see Menu_Create / Menu_Item in __Menu). Positions here are relative to FrameY.
// Extra page settings used by this menu: Centered (labels centred, no values) and TitleY (where the page title is drawn).

Menu_Create(GameMenuPage.Main, "", [
	Menu_Item("Resume Game", GameMenu_Close),
	Menu_Item("New Game", GameMenu_AskQuit, { QuitTo: 0, Prompt: "New Game?" }),
	GameMenu_Link("Options", GameMenuPage.Options),
	Menu_Item("Quit to Title", GameMenu_AskQuit, { QuitTo: 1, Prompt: "Quit to Title?" }),
	Menu_Item("Quit to Desktop", GameMenu_AskQuit, { QuitTo: 2, Prompt: "Quit to Desktop?" })
], { TileW: 16, Top: 24, YSpace: 20, Centered: true, OnBack: GameMenu_Close });

var _BackToMain = function(_Sound){ GameMenu_Open(GameMenuPage.Main, _Sound); };

// Options apply live; Save writes them (volumes to game_options.ini, the rest to the user file), Back puts them back
Menu_Create(GameMenuPage.Options, "Options", [
	Menu_BackItem(),
	Menu_SaveItem(),
	Menu_GlobalSlider("Music", "MusicVol", 0, 1, User_UpdateMusicSFX),
	Menu_GlobalSlider("Sound", "SFXVol", 0, 1, User_UpdateMusicSFX, true),
	Menu_Toggle("HUD", Menu_GetPref, Menu_SetPref, { Pref: Pref.HUD }),
	Menu_Toggle("CRT Effect", Menu_GetPref, Menu_SetPref, { Pref: Pref.CRT }),
	Menu_Toggle("Item Msgs", Menu_GetPref, Menu_SetPref, { Pref: Pref.ItemMsg }),
	GameMenu_Link("{s}Cheats", GameMenuPage.Cheats)
], {
	TileW: 16, Top: 28, TitleY: 8, YSpace: 18, VisibleRows: 5, OnBack: _BackToMain,
	OnSave: function(){ User_Save(); Settings_SaveIni(); }
});

///// Cheats
// Populate the exact same list and groups as the title menu's Cheats page.
// Save also applies newly enabled cheats to this play session.
var _BackToCheats = function(_Sound){ GameMenu_Open(GameMenuPage.Cheats, _Sound); };
var _CheatPage = array_concat([Menu_BackItem(), Menu_CheatSaveItem()], Menu_CheatRows());
var _CheatGroups = Menu_CheatGroups();
for(var i = 0; i < array_length(_CheatGroups); i++){
	var _Group = _CheatGroups[i];
	var _GroupPage = Menu_NewPageIndex();
	Menu_Create(_GroupPage, _Group, array_concat([Menu_BackItem(), Menu_CheatSaveItem()], Menu_CheatRows(_Group)), {
		TileW: 26, Top: 28, TitleY: 8, YSpace: 19, VisibleRows: 5, OnBack: _BackToCheats, OnSave: GameMenu_SaveCheats
	});
	array_push(_CheatPage, GameMenu_Link((i == 0 ? "{s}" : "") + _Group, _GroupPage));
}
Menu_Create(GameMenuPage.Cheats, "Cheats", _CheatPage, {
	TileW: 26, Top: 28, TitleY: 8, YSpace: 19, VisibleRows: 5, OnSave: GameMenu_SaveCheats,
	OnBack: function(_Sound){ GameMenu_Open(GameMenuPage.Options, _Sound); }
});

// "Enable Cheats?" confirmation. OK saves the cheat page it came from; Cancel/Back returns to it with the changes still unsaved.
CheatWarning_ReturnPage = GameMenuPage.Cheats;
Menu_OpenCheatWarning = function(){
	CheatWarning_ReturnPage = Menu_ActiveIndex;
	GameMenu_Open(GameMenuPage.CheatWarning, Sound_Boss_Hit);
};
Menu_CloseCheatWarning = function(_Confirm){
	GameMenu_Open(CheatWarning_ReturnPage, _Confirm ? noone : Sound_Throw);
	SelectorPos = 1;	// back on the Save row
	if(_Confirm) Menu_Save();
};
Menu_Create(GameMenuPage.CheatWarning, "Enable Cheats?", Menu_CheatWarningRows(), {
	TileW: 24, Top: 94, TitleY: 10, YSpace: 16, Centered: true, Message: CHEAT_WARNING_MSG, MessageY: 28,
	OnBack: function(){ Menu_CloseCheatWarning(false); }
});

Menu_Create(GameMenuPage.Quit, "", [
	Menu_BackItem("Cancel"),
	Menu_Item("OK", GameMenu_Quit)
], { TileW: 16, Top: 48, TitleY: 24, YSpace: 20, Centered: true, OnBack: _BackToMain });

Menu_ActiveIndex = GameMenuPage.Main;

#endregion

global.Paused = true;

if(audio_is_playing(oLink.LowHealthSound)) audio_pause_sound(oLink.LowHealthSound);

audio_play_sound(Sound_Pickup, 1, false);

Music_Fade(0.25, 6);