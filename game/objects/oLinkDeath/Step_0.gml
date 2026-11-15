if(StartFade){
	
	FadeToBlack_Alpha += 0.035;
	
	if(FadeToBlack_Alpha >= 1){
		FadeToBlack_Alpha = 0;
		StartFade = false;
		ShowRed = true;
		alarm[1] = 1;
		audio_play_sound(Sound_LinkDying, 1, false);
	}
		
}

if(Falling){
	if(oLink.image_index >= 1.75){
		oLink.image_index = 2;
		oLink.image_speed = 0;
		Falling = false;
		alarm[2] = 60;
	}
}

if(FadeToGameOver){
	
	FadeToBlack_Alpha += 0.035;
	
	if(FadeToBlack_Alpha >= 1){
		FadeToBlack_Alpha = 1;
		FadeToGameOver = false;
		ShowRed = false;
		
		if(Inventory_ItemExists(ItemClass.Pendant, Pendant.Revival) && !Curse_Check(CurseEffects.PendantsNoWork)){
			alarm[5] = 40;
		}else{
			GameOver = true;
			GameOverSeq = layer_sequence_create("System", oCamera.X, oCamera.Y, seqGameOver);
			layer_sequence_play(GameOverSeq);
			alarm[11] = 98;
			global.StatsToAdd[Stat.Deaths]++;
		}
	}
	
	
}

if(GameOver){

	if(layer_sequence_is_finished(GameOverSeq)){
		layer_sequence_pause(GameOverSeq);
		GameOver = false;
		ShowMenu = true;
		alarm[3] = 8;
		audio_play_sound(Music_Fairy_Main, 1, true, 0.5);
	}
	
}

if(ShowMenu && !Quit){

	if(input_check_pressed("down")){
		Selector_Index = (Selector_Index + 1) mod 3;
		audio_play_sound(Sound_Text, 1, false);
	}
	if(input_check_pressed("up")){
		Selector_Index--;
		if(Selector_Index < 0) Selector_Index = 2;
		audio_play_sound(Sound_Text, 1, false);
	}

	if(input_check_pressed("menu_input") && alarm[4] == -1){
		audio_stop_all();
		audio_play_sound(Sound_TextDone, 1, false);
		alarm[3] = -1;
		alarm[4] = 45;
		Quit = true;
	}
}

if(PendantAni && PendantAni_V != 0){
	PendantAni_Y += PendantAni_V;
	if(PendantAni_Y <= PendantAni_YEnd){
		PendantAni_Y = PendantAni_YEnd;
		PendantAni_V = 0;
		alarm[6] = 60;
	}
}

if(ReviveLink){
	
	oLink.StarColorIndex = (oLink.StarColorIndex + 1) mod array_length(oLink.StarColors);
	oLink.StarLightIndex = (oLink.StarLightIndex + 0.5) mod array_length(oLink.StarLightColors);
	
}

if(FadeToWhite){
	
	FadeToWhite_Alpha += 0.008;
	
	if(FadeToWhite_Alpha >= 1){
		FadeToWhite_Alpha = 1;
		FadeToWhite = false;
		with(oLink){
			UpdateState(LinkState.Idle);
			Invincible = true;
			LinkHealth = global.Inventory.ItemData[ItemClass.HeartPiece].Amount;
		}
		FadeToGame = true;
	}	
}

if(FadeToGame){
	
	FadeToWhite_Alpha -= 0.008;
	
	if(FadeToWhite_Alpha <= 0){
		FadeToWhite_Alpha = 0;
		with(oLink){
			UpdateState(LinkState.Standing);
			LinkEnableFlashing();
			oLink.image_speed = 1;
		}
		Music_Play(LastSongIndex, 10);
		if(instance_exists(oIntro)){
			global.RainSound = audio_play_sound(Sound_Rain, 1, true, 0.3);
		}
		global.Paused = false;
		instance_destroy(self);
	}	
}
