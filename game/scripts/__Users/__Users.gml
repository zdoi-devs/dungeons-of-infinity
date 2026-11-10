enum Stat{
	GamesPlayed,
	GamesWon,
	Deaths,
	Monsters,
	Rupees,
	Treasures,
	BestTime,
	Unused //leave space for future stats
}
global.StatCount = 8;

enum Pref{
	SFX,
	Music,
	HUD,
	CRT,	
	ItemMsg,
	Unused1, //leave space for future prefs
	Unused2,
	Unused3
}
global.PrefCount = 8;

global.MaxUsers = 5;
global.UserIndex = 0;


global.StatsToAdd = array_create(global.StatCount);

function User_Create() constructor {
	
	Name = "";
	
	Prefs = User_DefaultPref();
	
	Stats = array_create(global.StatCount);

	Cheats = {};
	Init_Cheats_Struct(self);

	SaveData = -1;

	DungeonSeq = array_create(DungeonClasses - 1);
	DungeonSeqIndex = array_create(DungeonClasses - 1);

	InputProfile_Gamepad = input_profile_export("gamepad",,false);	
	InputProfile_Keyboard = input_profile_export("keyboard",,false);
	
	UsedFortuneTellerReadings = [];
	UsedCatacombGraveHeadings = [];
	
}

function User_VerifyIntegrity(){
	
	//preferences may change with updates. This function checks to see if there's fields missing then updates them
	
	var _ErrorCode = 0;
	
	var User = global.Users[global.UserIndex];
		
	if(!variable_struct_exists(User, "Name")) variable_struct_set(User, "Name", "");
	
	if(!input_profile_verify(global.Users[global.UserIndex].InputProfile_Keyboard, "keyboard")){
		global.Users[global.UserIndex].InputProfile_Keyboard = input_profile_export("keyboard",,false);
		_ErrorCode = 1;
	}
	if(!input_profile_verify(global.Users[global.UserIndex].InputProfile_Gamepad, "gamepad")){
		global.Users[global.UserIndex].InputProfile_Gamepad = input_profile_export("gamepad",,false);
		_ErrorCode = 2;
	}
	
	if(variable_struct_exists(User, "Prefs")){
		var _Prefs = array_length(User.Prefs);
		if(_Prefs < global.PrefCount){
			for(var i = 0; i < global.PrefCount - _Prefs; i++){
				array_push(User.Prefs, false);
			}
		}		
	}else{
		variable_struct_set(User, "Prefs", User_DefaultPref());
	}
			
	if(variable_struct_exists(User, "Stats")){
		var _Stats = array_length(User.Stats);
		if(_Stats < global.StatCount){
			for(var i = 0; i < global.StatCount - _Stats; i++){
				array_push(User.Stats, 0);
			}
		}
	}else{
		variable_struct_set(User, "Stats", array_create(global.StatCount));
	}
	
	if(variable_struct_exists(User, "SaveData")){
		
		if(is_struct(User.SaveData)){
			
			if(!variable_struct_exists(User.SaveData, "Level")) variable_struct_set(User.SaveData, "Level", 0);
		
			if(!variable_struct_exists(User.SaveData, "LinkCharacterIndex")) variable_struct_set(User.SaveData, "LinkCharacterIndex", 0);
		
			if(!variable_struct_exists(User.SaveData, "ItemData")) variable_struct_set(User.SaveData, "ItemData", 0);
			
			if(!variable_struct_exists(User.SaveData, "Inventory")) variable_struct_set(User.SaveData, "Inventory", 0);

			if(!variable_struct_exists(User.SaveData, "ChallengeOptions")) variable_struct_set(User.SaveData, "ChallengeOptions", 0);
			if(!variable_struct_exists(User.SaveData, "Challenges")) variable_struct_set(User.SaveData, "Challenges", 0);
		
			if(!variable_struct_exists(User.SaveData, "Cursed")) variable_struct_set(User.SaveData, "Cursed", false);
			if(!variable_struct_exists(User.SaveData, "CurseEffect")) variable_struct_set(User.SaveData, "CurseEffect", 0);
			if(!variable_struct_exists(User.SaveData, "CurseEffectStr")) variable_struct_set(User.SaveData, "CurseEffectStr", "");
			if(!variable_struct_exists(User.SaveData, "CurseTask")) variable_struct_set(User.SaveData, "CurseTask", 0);
			if(!variable_struct_exists(User.SaveData, "CurseTaskStr")) variable_struct_set(User.SaveData, "CurseTaskStr", "");
			if(!variable_struct_exists(User.SaveData, "CurseTaskItem")) variable_struct_set(User.SaveData, "CurseTaskItem", -1);
			if(!variable_struct_exists(User.SaveData, "CurseTaskCount")) variable_struct_set(User.SaveData, "CurseTaskCount", 0);
			if(!variable_struct_exists(User.SaveData, "CurseLastEffect")) variable_struct_set(User.SaveData, "CurseLastEffect", 0);
			if(!variable_struct_exists(User.SaveData, "CurseLastTask")) variable_struct_set(User.SaveData, "CurseLastTask", 0);
			if(!variable_struct_exists(User.SaveData, "CurseLastTaskItem")) variable_struct_set(User.SaveData, "CurseLastTaskItem", 0);
			if(!variable_struct_exists(User.SaveData, "CurseHealthDrainAlarm")) variable_struct_set(User.SaveData, "CurseHealthDrainAlarm", -1);
		
			if(!variable_struct_exists(User.SaveData, "BossesDefeated")) variable_struct_set(User.SaveData, "BossesDefeated", 0);
		
			if(!variable_struct_exists(User.SaveData, "TimePlayed")) variable_struct_set(User.SaveData, "TimePlayed", 0);
			
			if(!variable_struct_exists(User.SaveData, "Swordless")) variable_struct_set(User.SaveData, "Swordless", 0);
			
			if(!variable_struct_exists(User.SaveData, "BonusItem")) variable_struct_set(User.SaveData, "BonusItem", 0);
			
			if(!variable_struct_exists(User.SaveData, "GameVersion")) variable_struct_set(User.SaveData, "GameVersion", "");
			
		}
		
	}else{
		variable_struct_set(User, "SaveData", -1);
	}
	
	if(!variable_struct_exists(User, "DungeonSeq")) variable_struct_set(User, "DungeonSeq", array_create(DungeonClasses - 1));
	if(!variable_struct_exists(User, "DungeonSeqIndex")) variable_struct_set(User, "DungeonSeqIndex", array_create(DungeonClasses - 1));
	
	if(!variable_struct_exists(User, "InputProfile_Gamepad")) variable_struct_set(User, "InputProfile_Gamepad", input_profile_export("gamepad",,false));
	if(!variable_struct_exists(User, "InputProfile_Keyboard")) variable_struct_set(User, "InputProfile_Keyboard", input_profile_export("keyboard",,false));
	
	if(!variable_struct_exists(User, "UsedFortuneTellerReadings")) variable_struct_set(User, "UsedFortuneTellerReadings", []);
	if(!variable_struct_exists(User, "UsedCatacombGraveHeadings")) variable_struct_set(User, "UsedCatacombGraveHeadings", []);
	
	
	// Cheats initialization
	Init_Cheats_Struct(User);
	
	User_Save();
	
	return _ErrorCode
	
}

function User_SaveDataStruct() constructor{
	
	Level = 0;
	
	LinkCharacterIndex = 0;
	
	ItemData = 0;
	
	Inventory = 0;
	
	ChallengeOptions = 0;
	self.Challenges = 0; //"self." needed: name clashes with enum Challenges
	
	Cursed = false;
	CurseEffect = 0;
	CurseEffectStr = "";
	CurseTask = 0;
	CurseTaskStr = "";
	CurseTaskItem = -1;
	CurseTaskCount = 0;
	CurseLastEffect = -1;
	CurseLastTask = -1;
	CurseLastTaskItem = -1;
	CurseHealthDrainAlarm = -1;
	
	BossesDefeated = 0;
	
	TimePlayed = 0;
	
	Swordless = false;
	
	BonusItem = StartingGear.None;
	
	GameVersion = "";
	
}

function User_SaveGame(){
	
	if(global.Users[global.UserIndex].SaveData != -1){
		delete global.Users[global.UserIndex].SaveData;
	}
	
	global.Users[global.UserIndex].SaveData = new User_SaveDataStruct();
	
	global.Users[global.UserIndex].SaveData.Level = global.Level.Index;
	
	global.Users[global.UserIndex].SaveData.LinkCharacterIndex = global.LinkCharacterIndex;
	
	global.Users[global.UserIndex].SaveData.ItemData = StructCopy(global.ItemData);
	
	global.Users[global.UserIndex].SaveData.Inventory = StructCopy(global.Inventory);

	global.Users[global.UserIndex].SaveData.ChallengeOptions = StructCopy(global.ChallengeOptions);
	global.Users[global.UserIndex].SaveData.Challenges = StructCopy(global.Challenges);
	
	global.Users[global.UserIndex].SaveData.Cursed = global.Cursed;
	global.Users[global.UserIndex].SaveData.CurseEffect = global.CurseEffect;
	global.Users[global.UserIndex].SaveData.CurseEffectStr = global.CurseEffectStr;
	global.Users[global.UserIndex].SaveData.CurseTask = global.CurseTask;
	global.Users[global.UserIndex].SaveData.CurseTaskStr = global.CurseTaskStr;
	global.Users[global.UserIndex].SaveData.CurseTaskItem = global.CurseTaskItem;
	global.Users[global.UserIndex].SaveData.CurseTaskCount = global.CurseTaskCount;
	global.Users[global.UserIndex].SaveData.CurseLastEffect = global.CurseLastEffect;
	global.Users[global.UserIndex].SaveData.CurseLastTask = global.CurseLastTask;
	global.Users[global.UserIndex].SaveData.CurseLastTaskItem = global.CurseLastTaskItem;
	global.Users[global.UserIndex].SaveData.CurseHealthDrainAlarm = oLink.alarm[3];
	
	global.Users[global.UserIndex].SaveData.BossesDefeated = oHUD.BossesDefeated;
	
	global.Users[global.UserIndex].SaveData.TimePlayed = Time_PlayingTotal();
	
	global.Users[global.UserIndex].SaveData.Swordless = global.Swordless;
	
	global.Users[global.UserIndex].SaveData.BonusItem = global.StartingGear;
	
	global.Users[global.UserIndex].SaveData.GameVersion = VERSION;
	
	User_UpdateStats();
	
	User_Save();


}

function User_LoadGame(){
	
	global.ContinueLevel = global.Users[global.UserIndex].SaveData.Level;
	
	global.LinkCharacterIndex = global.Users[global.UserIndex].SaveData.LinkCharacterIndex;
	with(oLink) Link_LoadCharacterIndex();
	
	global.ItemData = StructCopy(global.Users[global.UserIndex].SaveData.ItemData);
	
	global.Inventory = StructCopy(global.Users[global.UserIndex].SaveData.Inventory);
	
	global.StartingGear = global.Users[global.UserIndex].SaveData.BonusItem;
	
	if(global.Inventory.ItemData[ItemClass.ArrowQuiver].Owns[0]) global.ItemData[ItemClass.Arrows].Type = ItemType.Pickup;
	
	global.ChallengeOptions = StructCopy(global.Users[global.UserIndex].SaveData.ChallengeOptions);
	global.Challenges = StructCopy(global.Users[global.UserIndex].SaveData.Challenges);
	
	global.Cursed = global.Users[global.UserIndex].SaveData.Cursed;
	global.CurseEffect = global.Users[global.UserIndex].SaveData.CurseEffect;
	global.CurseEffectStr = global.Users[global.UserIndex].SaveData.CurseEffectStr;
	global.CurseTask = global.Users[global.UserIndex].SaveData.CurseTask;
	global.CurseTaskStr = global.Users[global.UserIndex].SaveData.CurseTaskStr;
	global.CurseTaskItem = global.Users[global.UserIndex].SaveData.CurseTaskItem;
	global.CurseTaskCount = global.Users[global.UserIndex].SaveData.CurseTaskCount;
	global.CurseLastEffect = global.Users[global.UserIndex].SaveData.CurseLastEffect;
	global.CurseLastTask = global.Users[global.UserIndex].SaveData.CurseLastTask;
	global.CurseLastTaskItem = global.Users[global.UserIndex].SaveData.CurseLastTaskItem;
	if(Curse_Check(CurseEffects.HealthDrain)) oLink.alarm[3] = global.Users[global.UserIndex].SaveData.CurseHealthDrainAlarm;
	
	oHUD.BossesDefeated = global.Users[global.UserIndex].SaveData.BossesDefeated;
	
	global.Time_PlayingTotalSaved = global.Users[global.UserIndex].SaveData.TimePlayed;
	
	global.Swordless = global.Users[global.UserIndex].SaveData.Swordless;	
	
	Link_UpdateAttackDefence();
	
	// Apply cheats, if applicable, regardless if we're starting a new game or not
	Init_Gameplay_Cheats();
	Inventory_Update();
	
}

function User_DelSaveData(){

	delete global.Users[global.UserIndex].SaveData;
	global.Users[global.UserIndex].SaveData = -1;
	
}

function DungeonSeq_Randomize(_DungeonClass){
	
	var _SeqArray = global.Users[global.UserIndex].DungeonSeq[_DungeonClass];
		
	var _SeqSize = array_length(_SeqArray);
	
	var A_Size_L = ceil(_SeqSize / 2); //length of the left side of the array to shuffle
	var A_Size_R = _SeqSize - A_Size_L; //length of the right side of the array to shuffle
	var CentreW = floor(_SeqSize / 12) * 2; //centre shuffle width, make it an even number
	var CentreSideW = ceil(CentreW / 2);

	array_shuffle_ext(_SeqArray, 0, A_Size_L); //shuffle the left side
		
	array_shuffle_ext(_SeqArray, A_Size_L, A_Size_R); //shuffle the right side

	array_shuffle_ext(_SeqArray, A_Size_L - CentreSideW, CentreW); //shuffle the centre
	
	User_Save();
	
}

function DungeonSeq_Init(_UserIndex){

	for(var _DungeonClass = 0; _DungeonClass < DungeonClasses - 1; _DungeonClass++){
		var _Dungeons = array_length(global.Templates_Dungeon[_DungeonClass][0]);
		global.Users[_UserIndex].DungeonSeq[_DungeonClass] = array_create_sequence_shuffled(0, _Dungeons - 1);
		global.Users[_UserIndex].DungeonSeqIndex[_DungeonClass] = 0;
	}	
	
}

function User_DefaultPref(){
	return [true, true, true, false, true, false, false, false]
}

function User_Save(){
	
	var Buffer = EncodeDataToBuffer(global.Users);
	
	if(file_exists("Users_Temp")){
		file_delete("Users_Temp");
	}
	
	if(file_exists(USERSFILE)){
		
		file_copy(USERSFILE, "Users_Temp");
	
		var _FileSaved = xzip_write("Users_Temp", Buffer, XZIPFILE_USERS);
		
		if(_FileSaved){
			file_delete(USERSFILE);
			file_rename("Users_Temp", USERSFILE);
		}else{
			file_delete("Users_Temp");
		}
		
	}
	
	buffer_delete(Buffer);
	
}

function User_UpdateStats(){
	
	var _UserStats = global.Users[global.UserIndex].Stats;
	
	_UserStats[Stat.GamesPlayed] += global.StatsToAdd[Stat.GamesPlayed];
	_UserStats[Stat.GamesWon] += global.StatsToAdd[Stat.GamesWon];
	_UserStats[Stat.Deaths] += global.StatsToAdd[Stat.Deaths];
	_UserStats[Stat.Monsters] += global.StatsToAdd[Stat.Monsters];
	_UserStats[Stat.Rupees] += global.StatsToAdd[Stat.Rupees];
	_UserStats[Stat.Treasures] += global.StatsToAdd[Stat.Treasures];
	
	if(global.Time_PlayingTotalEnd != 0){
		if(_UserStats[Stat.BestTime] == 0 || global.Time_PlayingTotalEnd < _UserStats[Stat.BestTime]){
			_UserStats[Stat.BestTime] = global.Time_PlayingTotalEnd;
		}
	}
	
	global.StatsToAdd = 0; global.StatsToAdd = array_create(global.StatCount); 
	
}

function User_SaveStats(){
	
	User_UpdateStats();

	User_Save();
	
}

function User_SaveControls(){

	global.Users[global.UserIndex].InputProfile_Gamepad = input_profile_export("gamepad",,false);
	global.Users[global.UserIndex].InputProfile_Keyboard = input_profile_export("keyboard",,false);	
	
	User_Save();
	
}

function User_Delete(){	
	array_delete(global.Users, global.UserIndex, 1);
	array_insert(global.Users, global.UserIndex, new User_Create());
	User_Save();
}

// Volume sliders replaced the old Music/SFX on/off prefs (Pref.SFX / Pref.Music); a volume of 0 is muted
function User_UpdateMusicSFX(){
	
	audio_group_set_gain(audiogroup_Music, global.MusicVol, 0);
	audio_group_set_gain(audiogroup_SFX, global.SFXVol, 0);

}

//writes the settings to options.ini (saved in the appdata folder, not next to the exe)
function Settings_SaveIni(){
	try{
		ini_open("options.ini");
		ini_write_real("Screen", "Fullscreen", global.Fullscreen ? 1 : 0);
		ini_write_real("Audio", "MusicVol", round(global.MusicVol * 100) / 100);
		ini_write_real("Audio", "SFXVol", round(global.SFXVol * 100) / 100);
		ini_write_real("Preferences", "Gore", global.Gore ? 1 : 0);
		ini_write_real("Preferences", "Lighting", global.GlobalLighting ? 1 : 0);
		ini_write_real("Preferences", "Speedrun", global.Speedrun ? 1 : 0);
		ini_write_real("Preferences", "AltTabPause", global.AltTabPause ? 1 : 0);
		ini_write_real("Preferences", "StairPause", global.StairPause ? 1 : 0);
		ini_write_real("Preferences", "SaveVersionCheck", global.SaveVersionCheck ? 1 : 0);
		ini_write_real("Preferences", "CanSkipTitle", global.CanSkipTitle ? 1 : 0);
		ini_write_real("Controls", "AnalogueThreshold", round(global.Gamepad_AnalogueThreshold * 100) / 100);
		ini_close();
	}catch(_e){
		show_debug_message("Settings_SaveIni failed: " + string(_e.message));
	}
}
