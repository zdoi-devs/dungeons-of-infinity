event_inherited();

if(DB_Init_GrandChild){
	
	if(ItemHolding != -1 && global.Speedrun && global.Inventory.ItemData[ItemClass.Book].Owns[0]){
		DB_Init_GrandChild = false;
		global.Paused = true;
			with(oLink){
				Inventory_DeleteItemClass(ItemClass.Book);
				var inst = instance_create_layer(x, y, "ObjsHigher_Upper", ObjIndexFromItemClass(other.ItemHolding));
				HoldUpItem(inst);
			}
		ItemHolding = noone;
		ResponseIndex = 1;
		DialogueSkipOnce = true;
		exit;
	}
	
	if(ResponseIndex == -1){
		ResponseIndex = global.Inventory.ItemData[ItemClass.Book].Owns[0] ? 0 : -1;
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
				global.Paused = true;
				with(oLink){
					Inventory_DeleteItemClass(ItemClass.Book);
					var inst = instance_create_layer(x, y, "ObjsHigher_Upper", ObjIndexFromItemClass(other.ItemHolding));
					HoldUpItem(inst);
				}
				ItemHolding = noone;
				ResponseIndex = 1;
				break;

			
		}
		
	}
	

}



