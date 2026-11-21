
switch(State){
	case NPCState_OldLady.Sleeping:
		if(Wake_Init){
			alarm[0] = AniDelay;
			State = NPCState_OldLady.Waking;
		}
		break;
		
	case NPCState_OldLady.Waking:
		break;
		
	case NPCState_OldLady.Awake:
		break;
	
	case NPCState_OldLady.Letter:	
	case NPCState_OldLady.Reward:	
	case NPCState_OldLady.Farewell:

		
}

if(TurningGrey && !global.Paused){
	TurningGreyAlpha += 0.0022;
	if(TurningGreyAlpha > 1) TurningGreyAlpha = 1;
}

if(DB_Init){
	
	if !global.Speedrun{
		global.DB_Inst = instance_create_layer(0,0, "System", oDialogueBox);
	
		switch(State){
			case NPCState_OldLady.Awake: global.DB_Inst.Script = DB_Script_Awake; break;
			case NPCState_OldLady.Letter: global.DB_Inst.Script = DB_Script_Letter; break;
			case NPCState_OldLady.Farewell: global.DB_Inst.Script = DB_Script_Farewell; break;
		}
		DB_Started = true;
	}
	else{
		if (Inventory_ItemExists(ItemClass.Letter)){
			image_index = 1;
			DeliveredLetter = true;	
			Inventory_DeleteItemClass(ItemClass.Letter);
			var inst = ItemSpawn(ItemClass.Rupee, oLink.x, oLink.y, ItemFrom.LargeTreasure, ItemSpawnType.None, UPPER);	
			HoldUpItem(inst, ItemFrom.LargeTreasure);
		}
	}
	DB_Init = false;

}

if(DB_Started){
	
	
	if(!instance_exists(global.DB_Inst)){
		
		switch(State){
			case NPCState_OldLady.Awake:
				
				image_index = 1;
				if(global.DB_ExitCode == 1){
					
					DeliveredLetter = true;
					
					Inventory_DeleteItemClass(ItemClass.Letter);
					var inst = ItemSpawn(ItemClass.Rupee, oLink.x, oLink.y, ItemFrom.LargeTreasure, ItemSpawnType.None, UPPER);
				
					HoldUpItem(inst, ItemFrom.LargeTreasure);	
					
					alarm[1] = 90;
					alarm[2] = 200;
					
				}else{
					alarm[2] = 30;
					Wake_Init = false;
					Wake_HeadFrame = 0;
					State = NPCState_OldLady.Sleeping;
				}
				break;
			
			case NPCState_OldLady.Letter:
				alarm[3] = 60;
				global.Paused = true;
				with(oLink){
					UpdateState(LinkState.Idle);
					Facing = LEFT;
					UpdateSprites();
				}
				break;
			
			case NPCState_OldLady.Farewell:
				
				break;
		}
	
		DB_Started = false;
		
	}
}