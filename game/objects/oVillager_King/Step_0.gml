if(SleepDone) exit;

if(DB_Init_Child){

	DB_Init_Child = false;	
	
	DB_InitDone = true;
	
	exit;
	
}

//disable the tombstone sign while king is visible.
//Has to be done each frame since if Link exits and comes back, the sign will reactivate after room transition
if(Revealed){
	SignInst = collision_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom + 32, oSign, false, true);
	if(SignInst != noone) SignInst.Active = false;
}

if(Sleep){
	
	Alpha -= 0.005;	
	if(Alpha <= 0){
		SignInst = collision_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom + 32, oSign, false, true);
		if(SignInst != noone) SignInst.Active = true;	
		SleepDone = true;
		Lighting_UpdateLight_Visible(RoomIndex, LightIndex, false);
		exit;
	}

	var _LightRGB = Alpha * 0.8;
	Lighting_UpdateLight_RGB(RoomIndex, LightIndex, [_LightRGB, _LightRGB, _LightRGB]);
	
	exit;	
}
if(!AwakeInit && !Revealed){
	if(instance_exists(oMedallion)){
		AwakeInit = true;
	}
}

if(AwakeInit){
	if(!instance_exists(oMedallion)){
		if(	CollideTileBlock(global.TMID_Water_Lower, oLink.x, oLink.y, 44, VillageTilesY + 13, 2, 2) ||
			CollideTileBlock(global.TMID_Water_Lower, oLink.x - 8, oLink.y, 44, VillageTilesY + 13, 2, 2) ||
			CollideTileBlock(global.TMID_Water_Lower, oLink.x - 8, oLink.y + 8, 44, VillageTilesY + 13, 2, 2) ||
			CollideTileBlock(global.TMID_Water_Lower, oLink.x, oLink.y + 8, 44, VillageTilesY + 13, 2, 2) ||
			CollideTileBlock(global.TMID_Water_Lower, oLink.x + 8, oLink.y + 8, 44, VillageTilesY + 13, 2, 2) ||
			CollideTileBlock(global.TMID_Water_Lower, oLink.x + 8, oLink.y, 44, VillageTilesY + 13, 2, 2) ||
			CollideTileBlock(global.TMID_Water_Lower, oLink.x + 8, oLink.y - 8, 44, VillageTilesY + 13, 2, 2) ||
			CollideTileBlock(global.TMID_Water_Lower, oLink.x, oLink.y - 8, 44, VillageTilesY + 13, 2, 2) ||
			CollideTileBlock(global.TMID_Water_Lower, oLink.x - 8, oLink.y - 8, 44, VillageTilesY + 13, 2, 2)){
				Reveal = true;
				audio_play_sound(Sound_Warp, 1, false);
				global.Paused = true;
				with(oLink){
					UpdateState(LinkState.Idle);
					Facing = UP;
					sprite_index = global.LinkSpr_Stand_Up; 
				}
		}
		AwakeInit = false;
	}
}

if(Reveal){
	Alpha += 0.0075;	
	if(Alpha >= 0.55){
		Alpha = 0.55;
		Reveal = false;
		Revealed = true;
		alarm[2] = 45;
	}
	var _LightRGB = Alpha * 0.8;
	Lighting_UpdateLight_RGB(RoomIndex, LightIndex, [_LightRGB, _LightRGB, _LightRGB]);
}


if(!Revealed) exit;




HoverFrame = (HoverFrame + 4) mod 360;
HoverY = dsin(HoverFrame) * 3;


if(DB_Init_GrandChild){
	DB_Init_GrandChild = false;
	if (Inventory_ItemExists(ItemClass.Medallion) && global.Speedrun){
		global.Paused = true;
		with(oLink){					
			var inst = instance_create_layer(x, y, "ObjsHigher_Upper", ObjIndexFromItemClass(other.ItemHolding));
			HoldUpItem(inst);
			}
		Inventory_DeleteItemClass(ItemClass.Medallion);
		Sleep = true;
		DialogueIgnore = true;
		DialogueSkipOnce = true;
		exit
	}
	
	DB_Started_GrandChild = true;

		if(ResponseIndex == 0 && Inventory_ItemExists(ItemClass.Medallion) == -1){
			ResponseIndex = 4;
		}
				
	exit;
	
}


if(DB_Started_GrandChild){

	if(!instance_exists(global.DB_Inst)){
		
		DB_Started_GrandChild = false;
		
		switch(ResponseIndex){
			
			case -1:
				NPC_SetResponse(0);
				break;
				
			case 0:
				if(global.DB_ExitCode == 1){
					NPC_SetResponse(2);
				}else{
					NPC_SetResponse(3);					
				}				
				break;
				
			case 2:

				global.Paused = true;
				with(oLink){					
					var inst = instance_create_layer(x, y, "ObjsHigher_Upper", ObjIndexFromItemClass(other.ItemHolding));
					HoldUpItem(inst);
				}
				Inventory_DeleteItemClass(ItemClass.Medallion);
				Sleep = true;
				DialogueIgnore = true;
				//ItemHolding = -1;
				//ResponseIndex = 1;
				break
				
			case 3:
				ResponseIndex = 0;
				break;
			
			case 4:
				ResponseIndex = 0;
				break;				
			
		}
	}
		
}