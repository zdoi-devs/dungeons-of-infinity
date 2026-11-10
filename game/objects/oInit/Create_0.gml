global.Font_Blue = font_add_sprite(sFont_Blue, ord(" "), true, 0);
global.Font_Small = font_add_sprite_ext(sFont_Small, " .,!?':;-+*=<>()[]\\/_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", true, 1);
global.FontNumbers = font_add_sprite_ext(sHUD_Numbers, "0123456789", false, 0);

var _Date = date_current_datetime();
var _DateDay = date_get_day(_Date);
var _DateMonth = date_get_month(_Date);

global.Xmas = (_DateMonth == 12 && _DateDay == 25);

// Whether the current run/main menu has cheats on.
global.CheatsEnabled = false;

LinkSprites_Load();

ini_open("options.ini");

Borderless = ini_read_real("Screen", "Borderless", false);
global.Fullscreen = ini_read_real("Screen", "Fullscreen", 1) == 1 ? true : false;
global.MusicVol = ini_read_real("Audio", "MusicVol", 0.7);
global.SFXVol = ini_read_real("Audio", "SFXVol", 1.0);

global.Gamepad_AnalogueThreshold = ini_read_real("Controls", "AnalogueThreshold", 0.4);

global.Gore = ini_read_real("Preferences", "Gore", 1) == 1 ? true : false;
global.Speedrun = ini_read_real("Preferences", "Speedrun", 0) == 1 ? true : false;
global.GlobalLighting = ini_read_real("Preferences", "Lighting", 1) == 1 ? true : false;
global.AltTabPause = ini_read_real("Preferences", "AltTabPause", 1) == 1 ? true : false;
global.SaveVersionCheck = ini_read_real("Preferences", "SaveVersionCheck", 1) == 1 ? true : false;
global.StairPause = ini_read_real("Preferences", "StairPause", 1) == 1 ? true : false;
global.CanSkipTitle = ini_read_real("Preferences", "CanSkipTitle", 1) == 1 ? true : false;

ini_close();

Draw = false;
Init = false;

if(Borderless){
	window_set_fullscreen(false);
	alarm[0] = 10;
}else{
	//init right away if no need to set up borderless
	Draw = true;
	alarm[2] = 3;
}

audio_group_load(audiogroup_Music);
audio_group_load(audiogroup_SFX);




