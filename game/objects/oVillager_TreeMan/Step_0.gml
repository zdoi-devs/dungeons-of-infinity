event_inherited();

if(TransformInit && oLink.State = LinkState.Idle){
	alarm[2] = 40;
	TransformInit = false;
}

if(TransformFlash){
	TransformFlash_Color = (TransformFlash_Color + 1) mod 5;	
}

if(Transform){
	
	if(image_index >= image_number - 1){
		ObjSetImageSpeed(0);
		Transform = false;
		Transformed = true;
		alarm[5] = 45;
	}
	
}

if(DB_Init_GrandChild){
	
	if(global.Speedrun && Transformed && ItemHolding != -1 && Inventory_ItemExists(ItemClass.Powder)){
		DB_Init_GrandChild = false;
		global.Paused = true;
			with(oLink){					
				var inst = instance_create_layer(x, y, "ObjsHigher_Upper", ObjIndexFromItemClass(other.ItemHolding));
				HoldUpItem(inst);
			}
		Inventory_DeleteItemClass(ItemClass.Powder);
		ItemHolding = -1;
		ResponseIndex = 4;
		DialogueSkipOnce = true; 
		exit;
	}
	
	if(ResponseIndex == -1){
		ResponseIndex = Transformed ? 0 : -1;
	}
	
	if(ResponseIndex == 1 && !Inventory_ItemExists(ItemClass.Powder)) ResponseIndex = 5;
	
	if(ResponseIndex == 5 && Inventory_ItemExists(ItemClass.Powder)) ResponseIndex = 1;
	
	DB_Init_GrandChild = false;
	
	DB_Started_GrandChild = true;
	
	exit;
	
}


//if(DB_Started_GrandChild){
	
//	if(!instance_exists(global.DB_Inst)){
		
//		DB_Started_GrandChild = false;
		
//		switch(ResponseIndex){
//			case 0:
//				with(oLink){					
//					var inst = instance_create_layer(x, y, "ObjsHigher_Upper", ObjIndexFromItemClass(other.ItemHolding));
//					HoldUpItem(inst);
//				}
//				ItemHolding = -1;
//				ResponseIndex = 1;
//				break;
			
//		}
		
//	}
	

//}

if(DB_Started_GrandChild){
	
	if(!instance_exists(global.DB_Inst)){
		
		DB_Started_GrandChild = false;
		
		switch(ResponseIndex){
			case 0:
				NPC_SetResponse(1);
				break;
			
			case 1:
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
				Inventory_DeleteItemClass(ItemClass.Powder);
				ItemHolding = -1;
				ResponseIndex = 4;
				break
				
			case 3:
				ResponseIndex = 1;
				break;
			
			case 4:
				break;
		}
		
	}
	

}