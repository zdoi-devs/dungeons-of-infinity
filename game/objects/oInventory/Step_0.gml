Link_PauseHitFlashingTimer();


if(global.Inventory.Bags[InventoryBag.Main].Status == InventoryBagStatus.Closing) exit;


var _ItemUsed, _ItemClass, _BagIndex, _SlotIndex;
if(!DB_Started && !instance_exists(global.DB_Inst)){

		
	if(MenuEnable){
		
		if(input_check_pressed("left")){
			MenuSelectionIndex--;
			if(MenuSelectionIndex < 0) MenuSelectionIndex = MenuItems - 1;
			while(!MenuItemGrid[# 1, MenuSelectionIndex]){
				MenuSelectionIndex--;
				if(MenuSelectionIndex < 0) MenuSelectionIndex = MenuItems - 1;
			}
			audio_play_sound(Sound_Text, 1, false);
		}else if(input_check_pressed("right")){
			MenuSelectionIndex = (MenuSelectionIndex + 1) mod MenuItems;
			while(!MenuItemGrid[# 1, MenuSelectionIndex]){
				MenuSelectionIndex = (MenuSelectionIndex + 1) mod MenuItems;
			}
			audio_play_sound(Sound_Text, 1, false);
		}else if(input_check_pressed("sword")){
			
			if(MenuItemGrid[# 1, MenuSelectionIndex]){
				
				_BagIndex = global.Inventory.SlotSelected[0];
				_SlotIndex = global.Inventory.SlotSelected[1];
				
				var _Bag = global.Inventory.Bags[_BagIndex];
				var _Slot = _Bag.Slots[_SlotIndex];
				
				_ItemClass = _Slot.ItemClass;
				var _ItemIndex = _Slot.ItemIndex;
			
				switch(MenuSelectionIndex){	
					
					case 0: //equip
						var _Target = Inventory_ResolveBombBag(_BagIndex, _SlotIndex);
						if(_Target[0] != -1){
							global.Inventory.SlotEquiped[0] = _Target[0];
							global.Inventory.SlotEquiped[1] = _Target[1];
							audio_play_sound(Sound_TextDone, 1, false);
						}else{
							audio_play_sound_stopall(Sound_Error);
						}
						break;
					
					case 1: //use
						if(Item_CanUse(_ItemClass, _ItemIndex)){
							_ItemUsed = Inventory_UseItem(Inventory_SelectedSlot, true);
							audio_play_sound(Sound_TextDone, 1, false);
						}else{
							_ItemUsed = false;
							audio_play_sound_stopall(Sound_Error);
						}
						break;
						
					case 2: //drop
						var _DropPos = Item_DropPos();
						var _DoppedItemInst = ItemDrop(_DropPos[0], _DropPos[1], _ItemClass, _ItemIndex, _Slot.Amount, ItemFrom.Inventory);
						_DoppedItemInst.Get_ShowDialogue = false;
						Inventory_DeleteSlot(Inventory_SelectedSlot);
						
						Inventory_Update();

						audio_play_sound(Sound_TextDone, 1, false);
						break;

					case 3: //info
						DB_Init = true;
						DB_Script = DBScript_Info;
						break;
				}
			}
			
			
			if(MenuSelectionIndex == 1){ //use item
				if(_ItemUsed){
					
					switch(_ItemClass){
						default:
							MenuEnable = false;
							break;
						
						case ItemClass.Bombs:
						case ItemClass.Orb:
						case ItemClass.Star:
						case ItemClass.Gem:
						case ItemClass.WishStone:
							global.Inventory.Bags[InventoryBag.Main].Status = InventoryBagStatus.Closing;
							exit;
							
						case ItemClass.Ring: //don't disable the menu if using a ring since you generally want to use it multiple times in a row
							break;
					}
					
					//also equip certain items
					switch(_ItemClass){
						case ItemClass.Cape:
							global.Inventory.SlotEquiped[0] = _BagIndex;
							global.Inventory.SlotEquiped[1] = _SlotIndex;
							global.Inventory.Bags[InventoryBag.Main].Status = InventoryBagStatus.Closing;
							exit;
					}					
					
				}
				
			}else{
				MenuEnable = false;
			}
			
		}else if(input_check_pressed("action")) MenuEnable = false;
	
	}else{
		
		var _BagIndexSelected = global.Inventory.SlotSelected[0];
		var _SlotIndexSelected = global.Inventory.SlotSelected[1];
		
		var _Bag = global.Inventory.Bags[_BagIndexSelected];
		var _Slot = _Bag.Slots[_SlotIndexSelected];
	
		var ItemClassSelected = _Slot.ItemClass;
		var ItemIndexSelected = _Slot.ItemIndex;

		
		if(input_check_pressed("up")){

			Inventory_SetSelector(UP);
			hover_debounce = true
			
		}else if(input_check_pressed("down")){

			Inventory_SetSelector(DOWN);
			hover_debounce = true
			
		}else if(input_check_pressed("left")){
				
			Inventory_SetSelector(LEFT);
			hover_debounce = true
			
		}else if(input_check_pressed("right")){
				
			Inventory_SetSelector(RIGHT);
			hover_debounce = true
			
		}else if(ItemClassSelected != -1){
			
			if(global.HoverEquip == true && hover_debounce == true && global.ItemData[ItemClassSelected].CanEquip){
				
				var _Target = Inventory_ResolveBombBag(_BagIndexSelected, _SlotIndexSelected);
				if(_Target[0] != -1){
					global.Inventory.SlotEquiped[0] = _Target[0];
					global.Inventory.SlotEquiped[1] = _Target[1];
					audio_play_sound(Sound_TextDone, 1, false);
				}
				hover_debounce = false
				
			}else if(input_check_pressed("item") && global.ItemData[ItemClassSelected].CanEquip){
				
				var _Target = Inventory_ResolveBombBag(_BagIndexSelected, _SlotIndexSelected);
				if(_Target[0] != -1){
					global.Inventory.SlotEquiped[0] = _Target[0];
					global.Inventory.SlotEquiped[1] = _Target[1];
					audio_play_sound(Sound_TextDone, 1, false);
				}

			}else if(input_check_pressed("sword")){
			
				//enable menu items based on conditions
				MenuItemGrid[# 1, 0] = global.ItemData[ItemClassSelected].CanEquip;
				
				MenuItemGrid[# 1, 1] = global.ItemData[ItemClassSelected].CanUse && Item_CanUse(ItemClassSelected, ItemIndexSelected);
				
				var _CanDrop = global.ItemData[ItemClassSelected].CanDrop && !oLink.InDoor_Facing;
				MenuItemGrid[# 1, 2] = _CanDrop || (ItemClassSelected == ItemClass.Sword && global.Level.Index == DungeonLevel.Start);				
				
				MenuSelectionIndex = 0;
				while(!MenuItemGrid[# 1, MenuSelectionIndex]){
					MenuSelectionIndex = (MenuSelectionIndex + 1) mod MenuItems;
				}
			
				MenuEnable = true;
					
				audio_play_sound(Sound_TextDone, 1, false);
				

			}
			
		}

		
	}
	
	
}


if(DB_Init){
	
	global.DB_Inst = instance_create_layer(0,0, "System", oDialogueBox);
	global.DB_Inst.depth = depth - 1;
	global.DB_Inst.Y = global.Inventory.DialogueBox_Y;
	
	global.DB_Inst.Script = DB_Script;
	DB_Init = false;
	DB_Started = true;

}

if(DB_Started){
	if(!instance_exists(global.DB_Inst)){
		
		DB_Started = false;
		
	}
}