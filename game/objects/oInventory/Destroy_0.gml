ds_grid_destroy(DBScript_Info);
ds_grid_destroy(MenuItemGrid);
global.InventoryInst = noone;
global.Paused = false;

//in case bags were in the middle of opening and closing while inventory was closing, set the position variables to what it would have ended up as
for(var _BagIndex = 0; _BagIndex < Inventory_Bags; _BagIndex++){
	
	var _Bag = global.Inventory.Bags[_BagIndex];
	
	switch(_Bag.Status){
		
		case InventoryBagStatus.Opening:
			_Bag.Status = InventoryBagStatus.Open;
			_Bag.Position = 1;
			break;
			
		case InventoryBagStatus.Closing:
			_Bag.Status = InventoryBagStatus.Closed;
			_Bag.Position = 0;			
			break;		
		
	}
}


with(oLink){
	if(State != LinkState.PickUp) UpdateState(LinkState.Standing);
}

