if(DB_Init){
	
	global.DB_Inst = instance_create_layer(0,0, "System", oDialogueBox);

	global.DB_Inst.Script = DB_Script;

	DB_Init = false;
	DB_Started = true;
	
	LinkDir = point_direction(x, y, oLink.x, oLink.y - 12);
	SparkleVX = lengthdir_x(SparkleV, LinkDir);
	SparkleVY = lengthdir_y(SparkleV, LinkDir);
}

if(DB_Started){
	if(!instance_exists(global.DB_Inst)){
		
		with(oLink)	UpdateState(LinkState.Idle);		
		audio_play_sound(Sound_FairySprinkle, 1, true);
		alarm[0] = 1;
		AddStart = true;
		SparkleDelay = 2;
		DB_Started = false;
	}
	exit;
	
}

if(!AddStart) exit;

SparkleX += SparkleVX;
SparkleY += SparkleVY;

if( (SparkleVX > 0 && SparkleX >= oLink.x) || (SparkleVX < 0 && SparkleX <= oLink.x) ){
	SparkleX = oLink.x;
	SparkleVX = 0;
}

if( (SparkleVY > 0 && SparkleY >= oLink.y - 12) || (SparkleVY < 0 && SparkleY <= oLink.y - 12) ){
	SparkleY = oLink.y - 12;
	SparkleVY = 0;
}

if(SparkleVX == 0 && SparkleVY == 0 && !Add){
	HealthAdd(ChallengeMax_Hearts, false);
	Add = true;	
}

if(!End && Add){
	if(oHUD.AddHealth <= 0){
		alarm[1] = DestroyDelay;
		alarm[2] = FlashDelay;
		End = true;
	}
}

if(WaitForSoundEnd){
	if(audio_sound_get_gain(Sound_FairySprinkle) <= 0){
		audio_stop_sound(Sound_FairySprinkle);
		audio_sound_gain(Sound_FairySprinkle, 1, 0);
		with(oLink)	UpdateState(LinkState.Standing);
		//if the fairy exists in the map items list, then delete it
		var i = ds_list_find_index(global.LargeMapItems, id);
		if(i != -1) ds_list_delete(global.LargeMapItems, i);
		//change music for room
		global.Level.Rooms[global.CurrentRoomIndex].RoomSongIndex = global.Music_LevelSongIndex[global.Level.Index];
		instance_destroy(id);	
	}
}
