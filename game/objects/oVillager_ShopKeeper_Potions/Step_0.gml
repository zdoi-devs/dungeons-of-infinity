event_inherited();

if(DB_Init_GrandChild){
    
	if (ItemHolding != -1 && global.Speedrun && Inventory_ItemExists(ItemClass.Mushroom)){
		global.Paused = true;
		with(oLink){					
			var inst = instance_create_layer(x, y, "ObjsHigher_Upper", ObjIndexFromItemClass(other.ItemHolding));
			HoldUpItem(inst);
		}
		Inventory_DeleteItemClass(ItemClass.Mushroom);
		ItemHolding = -1;
		ResponseIndex = 1;
		DialogueSkipOnce = true;
	}
	
	if(ResponseIndex == -1){
		ResponseIndex = Inventory_ItemExists(ItemClass.Mushroom) ? 0 : -1;
	}
	
	DB_Init_GrandChild = false;
	
	DB_Started_GrandChild = true;
	
	exit;
	
}


if(DB_Started_GrandChild){
	
	if(!instance_exists(global.DB_Inst)){
		
		DB_Started_GrandChild = false;
		
		switch(ResponseIndex){
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
				Inventory_DeleteItemClass(ItemClass.Mushroom);
				ItemHolding = -1;
				ResponseIndex = 1;
				break
				
			case 3:
				ResponseIndex = -1;
				break;
			
		}
		
	}
	

}



