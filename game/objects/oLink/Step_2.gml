
//only load new dungeon here since the activate_all needs to wait until the Step event is done to process

if(InitNewDungeon){
	Time_PauseStart();
	
	if(Dungeon_IsSaveLevel(global.Level.Index + 1) && !global.SaveLevel){
		global.SaveLevel = true;
		Dungeon_InitSaveLevel(global.Level.Index);
	}else{
		array_push(global.CurrentSplits, Time_PlayingTotal())
		global.SaveLevel = false;
		Dungeon_InitLevel(++global.Level.Index);		
	}
	
	if(global.Level.StartDir == UP)
		sprite_index = global.LinkSpr_Descending_Bottom2;
	else
		sprite_index = global.LinkSpr_Descending_Top2;
				
	with(oDoor){
		
		if(!Entrance) continue;
		
		var _LinkPosY = y + (global.Level.StartDir == UP ? 15 : 23);
		other.y = _LinkPosY;
		
		//manually draw the Down2 tiles since otherwise it can only draw the next frame using the oDoor updating code, so it flashes for a frame if done that way
		var TMID = (FloorLevel == UPPER ? global.TMID_Decor_Upper : global.TMID_Decor_Lower);
		switch(Location){
			case "Top":
				//Sides
				DrawTileBlock(TMID, x, y + 8, 70, LevelTilesY, 1, 2);
				DrawTileBlock(TMID, x + 24, y + 8, 71, LevelTilesY, 1, 2);
				
				DrawTileBlock(TMID, x + 8, y + 8, 58, LevelTilesY + 2, 2, 2);
				break;
				
			case "Bottom":
				
				var _TilesY = (global.Level.Index == DungeonLevel.Aghanim2 ? LevelTilesY_Aghanim2 : LevelTilesY);
				
				//Sides
				DrawTileBlock(TMID, x, y, 72, _TilesY + 2, 1, 2);
				DrawTileBlock(TMID, x + 24, y, 73, _TilesY + 2, 1, 2);				
				
				DrawTileBlock(TMID, x + 8, y, 60, _TilesY + 4, 2, 2);
				break;

		}
		
		
		
	}

	if(DescendingPhase == 2){
		alarm[9] = 4; //play sound delayed as it's not in sync
	}
	
	Time_PauseEnd();
	
	InitNewDungeon = false;
	
}

if(State == LinkState.Warping && !global.MosaicDo){
	Warp_Engage = false
	UpdateState(LinkState.Standing);
}

AghanimTakingItems = Aghanim_TakingItems();
if(AghanimTakingItems && Cape){
	instance_destroy(oCape);	
}

//Lighting

Lighting = (global.Level.Rooms[global.CurrentRoomIndex].TemplateName == "Arcade" || (global.Level.Index == DungeonLevel.Start && global.ChallengeOptions[ChallengeOption.Darkness] < ChallengeOption_Darkness.AllDark) || global.Level.Rooms[global.CurrentRoomIndex].Heat || global.Inventory.ItemData[ItemClass.Lamp].Index == -1);

if( (Lighting && !global.Level.Rooms[global.CurrentRoomIndex].Heat) || global.Inventory.ItemData[ItemClass.Lamp].Index == -1){
	Lighting_UpdateLinkLight(, 0.0, [0.0, 0.0, 0.0]);
	exit;
}
	
Lighting_UpdateLinkLight([x, y - 6]);

LampFlickerDist += (LampFlickerDir * 0.005);

if(LampFlickerDir == 1 && LampFlickerDist >= LampMaxFlickerLen){
	LampFlickerDist = LampMaxFlickerLen;
	LampFlickerDir *= -1;
	LampMaxFlickerLen = random_range(0.01, LampFlickerMaxLen);
}else if(LampFlickerDir == -1 && LampFlickerDist <= 0){
	LampFlickerDist = 0;
	LampFlickerDir *= -1;
}

var LinkLampStrength = LampStrength[global.Inventory.ItemData[ItemClass.Lamp].Index + 1] + LampFlickerDist;


var DoorFadeFactor = 1;

var FadeFactor1, FadeFactor2;
if(InDoorPassage != 0){ 

	var FadeSpeed = 28; //Higher = slower

	switch(PassageOrientation){		
		
		case TOP_BOTTOM:
			FadeFactor1 = clamp(1 - ((DoorPassage[3] - y + 15) / FadeSpeed), 0, 1);
			FadeFactor2 = clamp(1 - ((y - DoorPassage[1] - 5) / FadeSpeed), 0, 1);
			break;
			
		case LEFT_RIGHT:
			FadeFactor1 = clamp(1 - ((DoorPassage[2] + 7 - x) / FadeSpeed), 0, 1);
			FadeFactor2 = clamp(1 - ((x - DoorPassage[0] + 7) / FadeSpeed), 0, 1);
			
			break;
			
	}
	
	DoorFadeFactor = (FadeFactor1 + FadeFactor2);
	

	//Keep Link's light at the edges of the Door Mask so it shrinks and expands at the entrances without moving with Link as he moves through the passage
	
	var _LightX = x;
	var _LightY = y;
	
	switch(PassageOrientation){
		case TOP_BOTTOM:
			var DistToBottom = abs(y - 6 - DoorPassage[3]);
			var DistToTop = abs(y - 6 - DoorPassage[1]);
			if(DistToBottom < DistToTop){
				_LightY = DoorPassage[3] + 10;
			}else{
				_LightY = DoorPassage[1] - 8;
			}
			break;

		case LEFT_RIGHT:
			var DistToRight = abs(x - DoorPassage[2]);
			var DistToLeft = abs(x - DoorPassage[0]);
			if(DistToRight < DistToLeft){
				_LightX = DoorPassage[2] + 10;
				_LightY = y - 6;
			}else{
				_LightX = DoorPassage[0] - 8;
				_LightY = y - 6;
			}
			break;
	}
	
	Lighting_UpdateLinkLight([_LightX, _LightY]);
	
	LinkLampStrength *= DoorFadeFactor;


	if(BounceBack){
		vx = 0;
		vy = 0;
	}

}

	
var MinFade = (InDoorPassage != 0 || global.Inventory.ItemData[ItemClass.Lamp].Index == -1 ? 0.0 : 0.4 - (global.Inventory.ItemData[ItemClass.Lamp].Index * 0.075) )

if(State == LinkState.Star){
	LinkLampStrength = LampStrength[3];
	var _StarLightIndex = floor(StarLightIndex);
	var _r = StarLightColors[_StarLightIndex][0];
	var _g = StarLightColors[_StarLightIndex][1];
	var _b = StarLightColors[_StarLightIndex][2];
	if(_r < 0) _r = 1.0;
	if(_g < 0) _g = 1.0;
	if(_b < 0) _b = 1.0;
	LampLightR = clamp(_r * DoorFadeFactor, MinFade, _r);
	LampLightG = clamp(_g * DoorFadeFactor, MinFade, _g);
	LampLightB = clamp(_b * DoorFadeFactor, MinFade, _b);
	
}else{
	if(global.Level.Rooms[global.CurrentRoomIndex].Heat){
		LampLightR = clamp(LampLightMaxR * DoorFadeFactor * 1.25, MinFade, LampLightMaxR * 1.25);
		LampLightG = clamp((LampLightMaxG / 2) * DoorFadeFactor, MinFade, (LampLightMaxG / 2));
		LampLightB = clamp((LampLightMaxB / 2)  * DoorFadeFactor, MinFade, (LampLightMaxB / 2));		
	}else{
		LampLightR = clamp(LampLightMaxR * DoorFadeFactor, MinFade, LampLightMaxR);
		LampLightG = clamp(LampLightMaxG * DoorFadeFactor, MinFade, LampLightMaxG);
		LampLightB = clamp(LampLightMaxB * DoorFadeFactor, MinFade, LampLightMaxB);				
	}
}

if(House_Leaving || Castle_Entering) LinkLampStrength = 0;

Lighting_UpdateLinkLight(,LinkLampStrength, [LampLightR, LampLightG, LampLightB]);
