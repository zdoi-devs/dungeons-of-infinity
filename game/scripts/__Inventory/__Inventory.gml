#macro MAGICAMOUNT_MAX 64
#macro MAGICAMOUNT_QUARTER (MAGICAMOUNT_HALF / 2)
#macro MAGICAMOUNT_HALF (MAGICAMOUNT_MAX / 2)
#macro MAGICAMOUNT_BASEUNIT (MAGICAMOUNT_MAX / 16)

#macro MaxArrows 40
#macro MaxArrowsQuiver 80
#macro MaxBombs 8
#macro MaxBombsBag 16
#macro MaxKeys 9

global.StartingGear = StartingGear.None;
#macro StartingGear_Rupees 100
#macro StartingGear_Orbs 10
#macro StartingGear_Antidotes 1

#macro Inventory_EquipedItem global.Inventory.Bags[global.Inventory.SlotEquiped[0]].Slots[global.Inventory.SlotEquiped[1]]
#macro Inventory_EquipedSlot [global.Inventory.SlotEquiped[0], global.Inventory.SlotEquiped[1]]
#macro Inventory_SelectedSlot [global.Inventory.SlotSelected[0], global.Inventory.SlotSelected[1]]
#macro Inventory_ItemIsEquiped (global.Inventory.SlotEquiped[0] != -1 && global.Inventory.SlotEquiped[1] != -1)
#macro Inventory_NoItemIsEquiped (global.Inventory.SlotEquiped[0] == -1 || global.Inventory.SlotEquiped[1] == -1)


global.InventoryInst = noone;

enum InventoryBag{
	Gear,
	Food,
	Bombs,
	Pendants,
	Gems,
	Main
}

enum InventoryBagStatus{
	Closed,
	Opening,
	Open,
	Closing	
}

#macro Inventory_Bags 6
#macro Inventory_SlotW 22
#macro Inventory_DialogueBoxBuffer 16

enum InventoryFanStatus{
	None,
	Open,
	Close
}

global.InventoryDrawBagOrder = [InventoryBag.Food, InventoryBag.Pendants, InventoryBag.Bombs, InventoryBag.Gear, InventoryBag.Gems, InventoryBag.Main];

function Inventory_InitData(){


	global.Inventory = new Inventory_Init();
	
	var _MainX = round((CAM_W - global.Inventory.Bags[InventoryBag.Main].W) / 2);
	var _MainY = round((CAM_H - global.Inventory.Bags[InventoryBag.Main].H - DialogueBoxH - Inventory_DialogueBoxBuffer) / 2) + 16;
	
	Inventory_SetPosition(InventoryBag.Main,	_MainX,	_MainY,	_MainX, _MainY);
											
	Inventory_SetPosition(InventoryBag.Gear,	global.Inventory.Bags[InventoryBag.Main].X,
												global.Inventory.Bags[InventoryBag.Main].Y,
												global.Inventory.Bags[InventoryBag.Main].X - global.Inventory.Bags[InventoryBag.Gear].W, 
												global.Inventory.Bags[InventoryBag.Main].Y);
											
	Inventory_SetPosition(InventoryBag.Food,	global.Inventory.Bags[InventoryBag.Main].X,
												global.Inventory.Bags[InventoryBag.Main].Y,
												global.Inventory.Bags[InventoryBag.Main].X, 
												global.Inventory.Bags[InventoryBag.Main].Y - global.Inventory.Bags[InventoryBag.Pendants].H);
	
	var _BombX = global.Inventory.Bags[InventoryBag.Main].X + ((global.Inventory.Bags[InventoryBag.Main].W - global.Inventory.Bags[InventoryBag.Bombs].W) / 2);
	Inventory_SetPosition(InventoryBag.Bombs,	_BombX,
												global.Inventory.Bags[InventoryBag.Main].Y,
												_BombX,
												global.Inventory.Bags[InventoryBag.Main].Y - global.Inventory.Bags[InventoryBag.Bombs].H);
	
	var _PendantX = global.Inventory.Bags[InventoryBag.Main].X + global.Inventory.Bags[InventoryBag.Main].W - global.Inventory.Bags[InventoryBag.Pendants].W;
	Inventory_SetPosition(InventoryBag.Pendants,_PendantX,
												global.Inventory.Bags[InventoryBag.Main].Y,
												_PendantX,
												global.Inventory.Bags[InventoryBag.Main].Y - global.Inventory.Bags[InventoryBag.Pendants].H);

	Inventory_SetPosition(InventoryBag.Gems,	global.Inventory.Bags[InventoryBag.Main].X + global.Inventory.Bags[InventoryBag.Main].W - global.Inventory.Bags[InventoryBag.Gems].W,
												global.Inventory.Bags[InventoryBag.Main].Y,
												global.Inventory.Bags[InventoryBag.Main].X + global.Inventory.Bags[InventoryBag.Main].W,
												global.Inventory.Bags[InventoryBag.Main].Y);
	
	var _MainBag = global.Inventory.Bags[InventoryBag.Main];
	
	_MainBag.H += 10; //add space for menu
	
	//Set first row of main bag to ignore which will be skipped when finding an empty slot to store items
	for(var i = 0; i < _MainBag.Columns; i++){
		_MainBag.Slots[i].Ignore = true;
	}
	
	//Lock last row of main bag
	for(var i = 0; i < _MainBag.Columns * 2; i++){
		var _Slot = _MainBag.Slots[_MainBag.Columns + i];
		_Slot.Locked = true;
	}	
	
	global.Inventory.Bags[InventoryBag.Main].Owns = true;	
	global.Inventory.Bags[InventoryBag.Gear].Owns = true;
	
	global.Inventory.DialogueBox_Y = _MainBag.Y + _MainBag.H + Inventory_DialogueBoxBuffer - 8;

	global.Inventory.CurseBox_X = round((CAM_W - DialogueBoxW_Curse) / 2);
	global.Inventory.CurseBox_Y = global.Inventory.DialogueBox_Y + round((DialogueBoxH - DialogueBoxH_Curse) / 2);

	//For every slot, give it the next slot for all directions the selector can move
														//UP							DOWN						LEFT						RIGHT
	global.InventorySlotMap[InventoryBag.Gear][0] =		[[InventoryBag.Gear, 4],		[InventoryBag.Gear, 2],		[InventoryBag.Gear, 1],		[InventoryBag.Gear, 1]];
	global.InventorySlotMap[InventoryBag.Gear][1] =		[[InventoryBag.Gear, 5],		[InventoryBag.Gear, 3],		[InventoryBag.Gear, 0],		[InventoryBag.Main, 0]];
	global.InventorySlotMap[InventoryBag.Gear][2] =		[[InventoryBag.Gear, 0],		[InventoryBag.Gear, 4],		[InventoryBag.Gear, 3],		[InventoryBag.Gear, 3]];
	global.InventorySlotMap[InventoryBag.Gear][3] =		[[InventoryBag.Gear, 1],		[InventoryBag.Gear, 5],		[InventoryBag.Gear, 2],		[InventoryBag.Main, 5]];
	global.InventorySlotMap[InventoryBag.Gear][4] =		[[InventoryBag.Gear, 2],		[InventoryBag.Gear, 0],		[InventoryBag.Gear, 5],		[InventoryBag.Gear, 5]];
	global.InventorySlotMap[InventoryBag.Gear][5] =		[[InventoryBag.Gear, 3],		[InventoryBag.Gear, 1],		[InventoryBag.Gear, 4],		[InventoryBag.Main, 10]];

	global.InventorySlotMap[InventoryBag.Food][0] =		[[InventoryBag.Food, 0],		[InventoryBag.Main, 0],		[InventoryBag.Food, 2],		[InventoryBag.Food, 1]];
	global.InventorySlotMap[InventoryBag.Food][1] =		[[InventoryBag.Food, 1],		[InventoryBag.Main, 1],		[InventoryBag.Food, 0],		[InventoryBag.Food, 2]];
	global.InventorySlotMap[InventoryBag.Food][2] =		[[InventoryBag.Food, 2],		[InventoryBag.Main, 2],		[InventoryBag.Food, 1],		[InventoryBag.Food, 0]];

	global.InventorySlotMap[InventoryBag.Bombs][0] =	[[InventoryBag.Bombs, 0],		[InventoryBag.Main, 2],		[InventoryBag.Bombs, 0],	[InventoryBag.Bombs, 0]];

	global.InventorySlotMap[InventoryBag.Pendants][0] = [[InventoryBag.Pendants, 0],	[InventoryBag.Main, 2], [InventoryBag.Pendants, 2], [InventoryBag.Pendants, 1]];
	global.InventorySlotMap[InventoryBag.Pendants][1] = [[InventoryBag.Pendants, 1],	[InventoryBag.Main, 3], [InventoryBag.Pendants, 0], [InventoryBag.Pendants, 2]];
	global.InventorySlotMap[InventoryBag.Pendants][2] = [[InventoryBag.Pendants, 2],	[InventoryBag.Main, 4], [InventoryBag.Pendants, 1], [InventoryBag.Pendants, 0]];

	global.InventorySlotMap[InventoryBag.Gems][0] =		[[InventoryBag.Gems, 4],		[InventoryBag.Gems, 2],		[InventoryBag.Main, 4],		[InventoryBag.Gems, 1]];
	global.InventorySlotMap[InventoryBag.Gems][1] =		[[InventoryBag.Gems, 5],		[InventoryBag.Gems, 3],		[InventoryBag.Gems, 0],		[InventoryBag.Gems, 0]];
	global.InventorySlotMap[InventoryBag.Gems][2] =		[[InventoryBag.Gems, 0],		[InventoryBag.Gems, 4],		[InventoryBag.Main, 9],		[InventoryBag.Gems, 3]];
	global.InventorySlotMap[InventoryBag.Gems][3] =		[[InventoryBag.Gems, 1],		[InventoryBag.Gems, 5],		[InventoryBag.Gems, 2],		[InventoryBag.Gems, 2]];
	global.InventorySlotMap[InventoryBag.Gems][4] =		[[InventoryBag.Gems, 2],		[InventoryBag.Gems, 0],		[InventoryBag.Main, 14],	[InventoryBag.Gems, 5]];
	global.InventorySlotMap[InventoryBag.Gems][5] =		[[InventoryBag.Gems, 3],		[InventoryBag.Gems, 1],		[InventoryBag.Gems, 4],		[InventoryBag.Gems, 4]];

													//UP											//DOWN										  //LEFT										//RIGHT	
	global.InventorySlotMap[InventoryBag.Main][0] =	[[InventoryBag.Main,10, InventoryBag.Main, 10], [InventoryBag.Main, 5, InventoryBag.Main, 5], [InventoryBag.Gear, 1, InventoryBag.Main, 4], [InventoryBag.Main, 1, InventoryBag.Main, 1]];
	global.InventorySlotMap[InventoryBag.Main][1] =	[[InventoryBag.Food, 1, InventoryBag.Main, 11], [InventoryBag.Main, 6, InventoryBag.Main, 6], [InventoryBag.Main, 0, InventoryBag.Main, 0], [InventoryBag.Main, 2, InventoryBag.Main, 2]];
	global.InventorySlotMap[InventoryBag.Main][2] =	[[InventoryBag.Bombs,0, InventoryBag.Main, 12], [InventoryBag.Main, 7, InventoryBag.Main, 7], [InventoryBag.Main, 1, InventoryBag.Main, 1], [InventoryBag.Main, 3, InventoryBag.Main, 3]];
	global.InventorySlotMap[InventoryBag.Main][3] =	[[InventoryBag.Pendants,1, InventoryBag.Main, 13],[InventoryBag.Main, 8, InventoryBag.Main, 8], [InventoryBag.Main, 2, InventoryBag.Main, 2], [InventoryBag.Main, 4, InventoryBag.Main, 4]];
	global.InventorySlotMap[InventoryBag.Main][4] =	[[InventoryBag.Main,14, InventoryBag.Main, 14], [InventoryBag.Main, 9, InventoryBag.Main, 9], [InventoryBag.Main, 3, InventoryBag.Main, 3], [InventoryBag.Gems, 0, InventoryBag.Main, 0]];
	
	global.InventorySlotMap[InventoryBag.Main][5] =	[[InventoryBag.Main, 0],						[InventoryBag.Main,10],						  [InventoryBag.Main, 9],						[InventoryBag.Main, 6]];
	global.InventorySlotMap[InventoryBag.Main][6] =	[[InventoryBag.Main, 1],						[InventoryBag.Main,11],						  [InventoryBag.Main, 5],						[InventoryBag.Main, 7]];
	global.InventorySlotMap[InventoryBag.Main][7] =	[[InventoryBag.Main, 2],						[InventoryBag.Main,12],						  [InventoryBag.Main, 6],						[InventoryBag.Main, 8]];
	global.InventorySlotMap[InventoryBag.Main][8] =	[[InventoryBag.Main, 3],						[InventoryBag.Main,13],						  [InventoryBag.Main, 7],						[InventoryBag.Main, 9]];
	global.InventorySlotMap[InventoryBag.Main][9] =	[[InventoryBag.Main, 4],						[InventoryBag.Main,14],						  [InventoryBag.Main, 8],						[InventoryBag.Main, 5]];
	
	global.InventorySlotMap[InventoryBag.Main][10] =[[InventoryBag.Main, 5],						[InventoryBag.Main, 0],						  [InventoryBag.Main, 14],						[InventoryBag.Main, 11]];
	global.InventorySlotMap[InventoryBag.Main][11] =[[InventoryBag.Main, 6],						[InventoryBag.Main, 1],						  [InventoryBag.Main, 10],						[InventoryBag.Main, 12]];
	global.InventorySlotMap[InventoryBag.Main][12] =[[InventoryBag.Main, 7],						[InventoryBag.Main, 2],						  [InventoryBag.Main, 11],						[InventoryBag.Main, 13]];
	global.InventorySlotMap[InventoryBag.Main][13] =[[InventoryBag.Main, 8],						[InventoryBag.Main, 3],						  [InventoryBag.Main, 12],						[InventoryBag.Main, 14]];
	global.InventorySlotMap[InventoryBag.Main][14] =[[InventoryBag.Main, 9],						[InventoryBag.Main, 4],						  [InventoryBag.Main, 13],						[InventoryBag.Main, 10]];
}

function Inventory_Init() constructor{
	
	Bags = array_create(Inventory_Bags);
	
	Bags[InventoryBag.Gear] =		new Inventory_InitBag(3, 2);
	Bags[InventoryBag.Food] =		new Inventory_InitBag(1, 3);
	Bags[InventoryBag.Bombs] =		new Inventory_InitBag(1, 1);
	Bags[InventoryBag.Pendants] =	new Inventory_InitBag(1, 3);
	Bags[InventoryBag.Gems] =		new Inventory_InitBag(3, 2);
	Bags[InventoryBag.Main] =		new Inventory_InitBag(3, 5);

	DialogueBox_Y = 0;
	CurseBox_X = 0;
	CurseBox_Y = 0;
	
	ItemData = array_create(ItemClasses);
	
	for(var _ItemClass = 0; _ItemClass < ItemClasses; _ItemClass++){
		
		var _ItemType = global.ItemData[_ItemClass].Type;
		
		var _ObjIndex = ObjIndexFromItemClass(_ItemClass);
		var _Indexes = sprite_get_number(object_get_sprite(_ObjIndex));
		
		switch(_ItemType){
			
			case ItemType.Pickup:
				ItemData[_ItemClass] = {Amount : 0};
				break;
				
			case ItemType.Inv_Bool:
				ItemData[_ItemClass] = {Owns : array_create(_Indexes)};
				break;
			
			case ItemType.Inv_Upg:
				ItemData[_ItemClass] = {Owns : false, Index : -1, Index_Min : -1, Index_Max : _Indexes - 1};
				break;
			
			
			case ItemType.Inv_Stk:
				ItemData[_ItemClass] = {Amount : array_create(_Indexes)}
				break;
				
			case ItemType.Inv_Chrg:
				ItemData[_ItemClass] = {Owns : array_create(_Indexes)}
				break;
			
			
		}
	}

	SlotSelected[0] = InventoryBag.Main;
	SlotSelected[1] = Bags[InventoryBag.Main].Columns;
	
	SlotEquiped[0] = -1;
	SlotEquiped[1] = -1;
	
}

function Inventory_InitBag(_Rows, _Columns) constructor{

	X = 0;
	Y = 0;
	
	X1 = 0;
	Y1 = 0;
	X2 = 0;
	Y2 = 0;
	
	Rows = _Rows;
	Columns = _Columns;

	W = 12 + (Inventory_SlotW * Columns);
	H = 12 + (Inventory_SlotW * Rows);
	
	SlotCount = Rows * Columns;
	
	Slots = [];
	for(var i = 0; i < SlotCount; i++){
		array_push(Slots, new Inventory_InitBagSlot());
	}
	
	Owns = false;
	
	Status = InventoryBagStatus.Closed;
	Position = 0; //value between 0-1, where 0 is fully closed, 1 is fully opened
	
}

function Inventory_InitBagSlot() constructor{
	
	X = 0;
	Y = 0;
	self.ItemClass = -1; //"self." needed: name clashes with enum ItemClass
	ItemIndex = -1;
	Amount = 0;
	Enabled = true;  //false means cursor can't be moved on slot
	Locked = false;  //if true, can't access the menu or add items to slot
	Ignore = false;  //ignore when finding slot to put item into. Bags are ignored
	
}

function Inventory_SetPosition(_BagIndex, _X1, _Y1, _X2, _Y2){
	
	//(_X1, _Y1) = start position
	//(_X2, _Y2) = end position
	
	var _Bag = global.Inventory.Bags[_BagIndex];
	
	_Bag.X = _X1;
	_Bag.Y = _Y1;
	
	_Bag.X1 = _X1;
	_Bag.Y1 = _Y1;
	_Bag.X2 = _X2;
	_Bag.Y2 = _Y2;
	
	var _SlotsX = _Bag.X + 7;
	var _SlotsY = _Bag.Y + 7;
	
	for(var i = 0; i < _Bag.SlotCount; i++){
		_Bag.Slots[i].X = _SlotsX + ((i mod _Bag.Columns) * Inventory_SlotW);
		_Bag.Slots[i].Y = _SlotsY + ((i div _Bag.Columns) * Inventory_SlotW);
	}

}

function Inventory_DrawBags(){
	
	
	var _BagAlpha, _Bag;
	for(var B = 0; B < Inventory_Bags; B++){
		
		var _BagIndex = global.InventoryDrawBagOrder[B];
		
		_Bag = global.Inventory.Bags[_BagIndex];
		
		if(_Bag.Status == InventoryBagStatus.Closed) continue;
	
		
		switch(global.Inventory.Bags[InventoryBag.Main].Status){
			
			case InventoryBagStatus.Opening:
			case InventoryBagStatus.Closing:
				_BagAlpha = global.Inventory.Bags[InventoryBag.Main].Position;
				break;
			
			default:
				_BagAlpha = 1;
				break;
				
		}		
			
		PixelRender(false, false, true, sHUD_Window_Inventory_Pal, _BagIndex, false, [], , _BagAlpha);
		draw_sprite_stretched(sprite_index, 0, oCamera.X + _Bag.X, oCamera.Y + _Bag.Y, _Bag.W, _Bag.H);
		shader_reset();
			
		draw_set_alpha(_BagAlpha);
		//draw_set_alpha(1);
			
		switch(_BagIndex){
		
			case InventoryBag.Main:

				//main bag area
				for(var i = 0; i < global.Inventory.Bags[InventoryBag.Main].Columns; i++){
	
					var _Slot = global.Inventory.Bags[InventoryBag.Main].Slots[i];
	
					var _SlotX = oCamera.X + _Slot.X;
					var _SlotY = oCamera.Y + _Slot.Y;
	
					if(_Slot.Enabled){
						draw_sprite(sInventory_Slot, 0, _SlotX, _SlotY);	
					}else{
		
						var _PosX = _SlotX + 10;
						var _PosY = Y + 25;
		
						switch(i){
							case InventoryBag.Food:
							case InventoryBag.Bombs:
							case InventoryBag.Pendants:
							case InventoryBag.Gems:
								draw_sprite(sInventory_GreyedBag, 0, _PosX, _PosY);
								break;
						}
		
					}
						
					Inventory_DrawItem(_BagIndex, i);
	
				}
					
				//tunic
				draw_sprite(sHUD_Tunic, max(global.Inventory.ItemData[ItemClass.Tunic].Index, 0), oCamera.X + global.Inventory.Bags[InventoryBag.Main].Slots[0].X + 2, oCamera.Y + global.Inventory.Bags[InventoryBag.Main].Slots[0].Y + 4);
					
				//main rows
				for(var i = global.Inventory.Bags[InventoryBag.Main].Columns; i < global.Inventory.Bags[InventoryBag.Main].SlotCount; i++){
	
					var _Slot = global.Inventory.Bags[InventoryBag.Main].Slots[i];
	
					var _SlotX = oCamera.X + _Slot.X;
					var _SlotY = oCamera.Y + _Slot.Y;
	
					draw_sprite(_Slot.Locked ? sInventory_SlotLocked : sInventory_Slot, 0, _SlotX, _SlotY);
						
					Inventory_DrawItem(_BagIndex, i);
				}

				break;
			
			default:

				var _ObjOffsetX = (_Bag.X - _Bag.X1);
				var _ObjOffsetY = (_Bag.Y - _Bag.Y1);
					
				draw_set_alpha(_BagAlpha);
					
				for(var i = 0; i < _Bag.SlotCount; i++){	
					var _SlotX = oCamera.X + _Bag.Slots[i].X + _ObjOffsetX;
					var _SlotY = oCamera.Y + _Bag.Slots[i].Y + _ObjOffsetY;
					draw_sprite(sInventory_Slot, 0, _SlotX, _SlotY);
					Inventory_DrawItem(_BagIndex, i, _ObjOffsetX, _ObjOffsetY);
				}
	
				break;
		
		}
			
		//draw_set_alpha(1);
		
		//draw_text(oCamera.X + _Bag.X, oCamera.Y + _Bag.Y, string(_Bag.Status));
		
	}
	
	var _BagSelected = global.Inventory.SlotSelected[0];
	var _SlotSelected = global.Inventory.SlotSelected[1];

	var _SelectorBag = global.Inventory.Bags[_BagSelected];
	var _SlotOffsetX = (_SelectorBag.X - _SelectorBag.X1);
	var _SlotOffsetY = (_SelectorBag.Y - _SelectorBag.Y1);
		
	var _SlotPositionX = global.Inventory.Bags[_BagSelected].Slots[_SlotSelected].X + _SlotOffsetX;
	var _SlotPositionY = global.Inventory.Bags[_BagSelected].Slots[_SlotSelected].Y + _SlotOffsetY;
	
	draw_set_alpha(_Bag.Position);
	
	draw_sprite_stretched(sInventory_Selection, 0, oCamera.X + _SlotPositionX, oCamera.Y + _SlotPositionY, 20, 20);	

	draw_set_alpha(1);
	
	
	
}

function Inventory_SetSelector(_Dir){
	
	_Dir -= 1; //assuming using dir macros which start at 1, so subtract 1 since array for up is 0
	
	do{	
		
		var _BagIndexSelected = global.Inventory.SlotSelected[0];
		var _SlotIndexSelected = global.Inventory.SlotSelected[1];

	
		if(_BagIndexSelected == InventoryBag.Main && _SlotIndexSelected < global.Inventory.Bags[_BagIndexSelected].Columns){
		
			//on the main bag row, check if we own the bag, if so select array 0,1, otherwise select 2,3
		
			var _CheckBagIndexTrue =  global.InventorySlotMap[InventoryBag.Main][_SlotIndexSelected][_Dir][0];
			var _CheckSlotIndexTrue = global.InventorySlotMap[InventoryBag.Main][_SlotIndexSelected][_Dir][1];
			var _CheckBagIndexFalse =  global.InventorySlotMap[InventoryBag.Main][_SlotIndexSelected][_Dir][2];
			var _CheckSlotIndexFalse = global.InventorySlotMap[InventoryBag.Main][_SlotIndexSelected][_Dir][3];
					
			if(global.Inventory.Bags[_CheckBagIndexTrue].Owns){
				global.Inventory.SlotSelected[0] = _CheckBagIndexTrue;
				global.Inventory.SlotSelected[1] = _CheckSlotIndexTrue;
			}else{
				global.Inventory.SlotSelected[0] = _CheckBagIndexFalse;
				global.Inventory.SlotSelected[1] = _CheckSlotIndexFalse;						
			}
					
		}else{
			global.Inventory.SlotSelected[0] = global.InventorySlotMap[_BagIndexSelected][_SlotIndexSelected][_Dir][0];
			global.Inventory.SlotSelected[1] = global.InventorySlotMap[_BagIndexSelected][_SlotIndexSelected][_Dir][1];					
		}
		
	}until(global.Inventory.Bags[global.Inventory.SlotSelected[0]].Slots[global.Inventory.SlotSelected[1]].Enabled)

	audio_play_sound_stopall(Sound_Text);

}

function Inventory_DrawItem(_BagIndex, _SlotIndex, _OffsetX = 0, _OffsetY = 0){
	
	var _ItemClass = global.Inventory.Bags[_BagIndex].Slots[_SlotIndex].ItemClass;
	var _ItemIndex = global.Inventory.Bags[_BagIndex].Slots[_SlotIndex].ItemIndex;
	
	if(_ItemClass == -1) exit;
	
	//get item sprite
	var _SprInd;
	switch(_ItemClass){
		case ItemClass.Sword: _SprInd = sItem_Sword_Inventory; break;
		default: _SprInd = object_get_sprite(ObjIndexFromItemClass(_ItemClass)); break;
	}

	switch(_ItemClass){
		case ItemClass.MoonPearl: _ItemIndex = global.Level.SwitchBlock_ActiveColor; break;
	}
	
	var _SlotPositionX = oCamera.X + global.Inventory.Bags[_BagIndex].Slots[_SlotIndex].X + _OffsetX;
	var _SlotPositionY = oCamera.Y + global.Inventory.Bags[_BagIndex].Slots[_SlotIndex].Y + _OffsetY;
	
	Offset = Inventory_GetPosOffset(_SprInd, _ItemIndex);
	var DrawItemX = _SlotPositionX + Offset[0] + 2;
	var DrawItemY = _SlotPositionY + Offset[1] + 1;
	
	draw_sprite(_SprInd, _ItemIndex, DrawItemX, DrawItemY);
	
	var _DrawAmount, _ItemAmount;
	switch(_ItemClass){
		
		case ItemClass.ArrowQuiver:
			if(global.Inventory.ItemData[ItemClass.ArrowQuiver].Owns[0]){
				_ItemAmount = global.Inventory.ItemData[ItemClass.Arrows].Amount[0];
				_DrawAmount = true;	
			}
			break;
			
		case ItemClass.FoodBag:
		case ItemClass.BombBag:
		case ItemClass.PendantBag:
		case ItemClass.GemBag:
			var _InventoryBag = ItemClassToInventoryBag(_ItemClass);
			if(global.Inventory.ItemData[_ItemClass].Owns[0]){
				_ItemAmount = BagCount[_InventoryBag];
				_DrawAmount = _ItemAmount > 0;	
			}					
			break;
			
		default:
			_ItemAmount = global.Inventory.Bags[_BagIndex].Slots[_SlotIndex].Amount;
			_DrawAmount = global.ItemData[_ItemClass].Type == ItemType.Inv_Chrg || global.Inventory.Bags[_BagIndex].Slots[_SlotIndex].Amount > 1;
			break;
	}
	

	draw_set_halign(fa_right);
	
	if(_DrawAmount){
		draw_set_font(global.Font_ItemValues);
		draw_text(_SlotPositionX + 18, _SlotPositionY + 11, _ItemAmount == 0 ? "O" : string(_ItemAmount));
	}
	draw_set_halign(fa_left);

}

function Inventory_Add(_ItemClass, _ItemIndex, _Amount = 1, _Slot = [-1, -1]){

	//_Slot = [_BagIndex, SlotIndex]
	
	if(_ItemClass == -1) return false;
	
	//no slot is given, find available slot
	if(_Slot[0] == -1 || _Slot[1] == -1){
		_Slot = Inventory_FindAvailableSlot(_ItemClass, _ItemIndex, _Amount);
	}	
	
	//no slot found, return false
	if(_Slot[0] == -1 || _Slot[1] == -1) return false;
	
	
	var _InventorySlot = global.Inventory.Bags[_Slot[0]].Slots[_Slot[1]];
	
	var _InventoryItemData = global.Inventory.ItemData[_ItemClass];
	
	//Just in case the inv amount gets lower than 0, make sure it starts at 0 here, otherwise items can dissapear.
	//There was a bug that wasn't replicated that made coupons disappear, it might have had to do with potions having 0 amount normally, which was now fixed to have 1.
	//So coupons were adding 1 from -1 making it 0, so it got deleted. That's the only explanation I could come up with
	//if(_SlotIndex >= 0){
		_InventorySlot.Amount = max(_InventorySlot.Amount, 0); 
	//}
	
	var _MaxAmount = Inventory_MaxAmount(_ItemClass, _ItemIndex);
	
	switch(global.ItemData[_ItemClass].Type){
		
		case ItemType.Inv_Bool:			
			_InventoryItemData.Index = _ItemIndex;
			_InventoryItemData.Owns[_ItemIndex] = true;
			break;
			
		case ItemType.Inv_Upg:
			
			//make sure we don't downgrade to a lower item
			if(_ItemIndex < _InventoryItemData.Index){
				Item_NonDuplicatableList_Remove(_ItemClass, _ItemIndex);
				_ItemIndex = _InventoryItemData.Index;
			}

			_InventoryItemData.Index = _ItemIndex;
			_InventoryItemData.Owns = true;
			
			break;
		
		case ItemType.Inv_Stk:
		case ItemType.Inv_NoStk:
		
			
			if(_Amount > 0 && _InventorySlot.Amount >= _MaxAmount) return false

			_InventorySlot.Amount = clamp(_InventorySlot.Amount + _Amount, 0, _MaxAmount);

			if(_InventorySlot.Amount == 0){
				Inventory_DeleteSlot(_Slot);
				_ItemClass = -1;
				_ItemIndex = 0;
			}
			
			break;
			
		case ItemType.Inv_Chrg:
			_InventoryItemData.Index = _ItemIndex;
			_InventoryItemData.Owns[_ItemIndex] = true;
			_InventorySlot.Amount = clamp(_InventorySlot.Amount + _Amount, 0, _MaxAmount);
			break;
			
	}
	
	switch(_ItemClass){
			
		default:
			_InventorySlot.ItemClass = _ItemClass;
			_InventorySlot.ItemIndex = _ItemIndex;
			break;

	}
	
	switch(_ItemClass){
		
		case ItemClass.ArrowQuiver:
			//turn arrows into a pickup item instead of stack item
			var ArrowCount = global.Inventory.ItemData[ItemClass.Arrows].Amount[0];
			global.ItemData[ItemClass.Arrows].Type = ItemType.Pickup;
			if(ArrowCount > 0){
				Inventory_DeleteItemClass(ItemClass.Arrows);
				global.Inventory.ItemData[ItemClass.Arrows].Amount[0] = ArrowCount;
			}
			_InventorySlot.ItemClass = _ItemClass;
			_InventorySlot.ItemIndex = _ItemIndex;
			break;
	
		case ItemClass.FoodBag:	global.Inventory.Bags[InventoryBag.Food].Owns = true; break;
		case ItemClass.BombBag:	global.Inventory.Bags[InventoryBag.Bombs].Owns = true; break;
		case ItemClass.PendantBag: global.Inventory.Bags[InventoryBag.Pendants].Owns = true; break;
		case ItemClass.GemBag: global.Inventory.Bags[InventoryBag.Gems].Owns = true; break;	
			
	}
	
	if(_ItemClass == ItemClass.Pendant && _ItemIndex == Pendant.Secrets) oHUD.CheckPendentSecret = true;
					
	Item_NonDuplicatableList_Remove(_ItemClass, _ItemIndex);
	
	Inventory_Update();

	Link_UpdateAttackDefence();
	
	return true;
	
}

function Inventory_FindAvailableSlot(_ItemClass, _ItemIndex, _Amount = 1){

	//returns [bag index, slot index] if item can be added to inventory, otherwise returns [-1, -1]
	
	if(_ItemClass == -1) return [-1, -1];
	
	
	var _BagIndex = InventoryBag.Main;
	var _SlotIndex = -1;

	
	//Certain items occupy specific bags and slots, set them here
	switch(_ItemClass){
		
		case ItemClass.Sword:
		case ItemClass.Tunic:
		case ItemClass.Shield:
		case ItemClass.Gloves:
		case ItemClass.Lamp:
		case ItemClass.ArrowQuiver:
			_BagIndex = InventoryBag.Gear;
			break;
		
		case ItemClass.Food:
		case ItemClass.Pop:
			if(global.Inventory.ItemData[ItemClass.FoodBag].Owns[0]) _BagIndex = InventoryBag.Food; 
			break;
			
		case ItemClass.Potion:
			if(global.Inventory.ItemData[ItemClass.FoodBag].Owns[0] && _ItemIndex == Potion.Milk) _BagIndex = InventoryBag.Food; 
			break;
			
			
		case ItemClass.Bombs:
			if(global.Inventory.ItemData[ItemClass.BombBag].Owns[0]) _BagIndex = InventoryBag.Bombs;
			break;

		case ItemClass.Pendant:
			if(global.Inventory.ItemData[ItemClass.PendantBag].Owns[0]) _BagIndex = InventoryBag.Pendants; 
			break;			
		
		case ItemClass.Gem:
		case ItemClass.Kinstone:
		case ItemClass.WishStone:
			if(global.Inventory.ItemData[ItemClass.GemBag].Owns[0]) _BagIndex = InventoryBag.Gems; 
			break;


		case ItemClass.FoodBag:		_SlotIndex = 1; break;			
		case ItemClass.BombBag:		_SlotIndex = 2; break;
		case ItemClass.PendantBag:	_SlotIndex = 3; break;
		case ItemClass.GemBag:		_SlotIndex = 4; break;
		
		
	}
	
	if(_SlotIndex != -1) return [_BagIndex, _SlotIndex];
	
	
	
	var _FindExistingItemClass = -1;
	var _FindExistingItemIndex = -1;
	
	switch(global.ItemData[_ItemClass].Type){
		
		case ItemType.Inv_Bool:
		case ItemType.Inv_Chrg:
		case ItemType.Inv_Stk:		
			
			_FindExistingItemClass = _ItemClass;
			_FindExistingItemIndex = _ItemIndex;

			break;
			
		case ItemType.Inv_Upg:
				
			_FindExistingItemClass = _ItemClass;

			break;

	}

	var _Slot = Inventory_FindItem(_FindExistingItemClass, _FindExistingItemIndex, _BagIndex);

	if(_Slot[0] != -1 && _Slot[1] != -1) return [_Slot[0], _Slot[1]];
			
	if(_BagIndex != InventoryBag.Main){
				
		var _EmptySlotIndex = Inventory_FindEmptySlot(_BagIndex);
		if(_EmptySlotIndex != -1) return [_BagIndex, _EmptySlotIndex];
				
		_Slot = Inventory_FindItem(_FindExistingItemClass, _FindExistingItemIndex, InventoryBag.Main);
				
		if(_Slot[0] != -1 && _Slot[1] != -1) return [_Slot[0], _Slot[1]];
	}
			
	return [InventoryBag.Main, Inventory_FindEmptySlot(InventoryBag.Main)];	
	
}

function Inventory_FindItem(_ItemClass, _ItemIndex = -1, _ForceBagIndex = -1){
	
	//returns [bag index, slotindex] if _ItemClass && _ItemIndex exists in one of the inventory bags
	//if _ReturnBool is true, it returns true or false if item is found
	//_BagIndex is to specify to only look in that bag
	
	if(_ItemClass == -1 && _ItemIndex == -1) return [-1, -1];
	
	for(var _BagIndex = 0; _BagIndex < Inventory_Bags; _BagIndex++){
		
		if(_ForceBagIndex != -1 && _BagIndex != _ForceBagIndex) continue;
		
		var _Bag =  global.Inventory.Bags[_BagIndex];
		
		for(var i = 0; i < _Bag.SlotCount; i++){	
			if(_ItemIndex == -1){
				if(_Bag.Slots[i].ItemClass == _ItemClass) return [_BagIndex, i];
			}else{
				if(_Bag.Slots[i].ItemClass == _ItemClass && _Bag.Slots[i].ItemIndex == _ItemIndex) return [_BagIndex, i];
			}
		}
	}
	
	return [-1, -1];
	
}

function Inventory_FindEmptySlot(_BagIndex){
	
	if(_BagIndex == -1) return -1
	
	for(var i = 0; i < global.Inventory.Bags[_BagIndex].SlotCount; i++){
		
		var _Slot = global.Inventory.Bags[_BagIndex].Slots[i];
		
		if(_Slot.Locked || _Slot.Ignore) continue;
		
		if(_Slot.ItemClass == -1) return i;
		
	}
	
	return -1;
}

function Inventory_ItemExists(_ItemClass, _ItemIndex = -1){
	
	//returns [bag index, slotindex] if _ItemClass && _ItemIndex exists in one of the inventory bags
	//if _ReturnBool is true, it returns true or false if item is found
	
	if(_ItemClass == -1 && _ItemIndex == -1) return false;
	
	for(var _BagIndex = 0; _BagIndex < Inventory_Bags; _BagIndex++){
		
		var _Bag =  global.Inventory.Bags[_BagIndex];
		
		for(var i = 0; i < _Bag.SlotCount; i++){	
			if(_ItemIndex == -1){
				if(_Bag.Slots[i].ItemClass == _ItemClass) return true;
			}else{
				if(_Bag.Slots[i].ItemClass == _ItemClass && _Bag.Slots[i].ItemIndex == _ItemIndex) return true;
			}
		}
	}
	
	return false;
	
}

function Inventory_UseItem(_Slot, _FromInventory){

	var _BagIndex = _Slot[0];
	var _SlotIndex = _Slot[1];
	
	if(_BagIndex == -1 || _SlotIndex == -1) return false;
	
	var _ItemClass = global.Inventory.Bags[_BagIndex].Slots[_SlotIndex].ItemClass;
	var _ItemIndex = global.Inventory.Bags[_BagIndex].Slots[_SlotIndex].ItemIndex;
	
	var _Error = false;
	
	var _Added, _ObjIndex, Inst;
	switch(_ItemClass){
		
		case ItemClass.Bow: 
			if(global.Inventory.ItemData[ItemClass.Arrows].Amount[0] > 0){
				with(oLink){
					UpdateState(LinkState.Bow);
				}				
			}else _Error = true;
			break;
			
		case ItemClass.Boomerang: 
			if(!instance_exists(oBoomerang)){
				with(oLink) UpdateState(LinkState.Boomerang);
			}		
			break;
			
		case ItemClass.Hookshot: 
			if(!instance_exists(oHookshot)){
				with(oLink) UpdateState(LinkState.Hookshot);
			}
			break;
		
		case ItemClass.Rod: 
			
			with(oRodCharger){
				if(RodInserted) exit;
			}
			
			if(global.Inventory.Bags[_BagIndex].Slots[_SlotIndex].Amount > 0){
				with(oLink) UpdateState(LinkState.Rod);
				Inventory_Add(_ItemClass, _ItemIndex, -1, [_BagIndex, _SlotIndex]);
				Inventory_Update();
					
			}else _Error = true;
			
			break;

		case ItemClass.Ring:
			
			var _MagicUsed = MagicUse(8);
			if(_MagicUsed == 0){
				_Error = true;
			}else{

				switch(_ItemIndex){
					case Ring.Health:
						if(HealthAdd(Ring_HealthAmount) == 0){
							_Error = true;
							break;
						}
						audio_play_sound(Sound_HealthRefill, 1, false);
						break;
					case Ring.Rupees:
						if(!Item_Consume(ItemClass.Rupee, 0, Ring_RupeeAmount)){
							_Error = true;
							break;							
						}
						audio_play_sound(Sound_RupeeGet, 1, false);
						break;
					case Ring.Bombs:

						if(global.Inventory.ItemData[ItemClass.BombBag].Owns[0])
							_Added = Item_Consume(ItemClass.Bombs, 0, Ring_BombAmount);
						else{
							_Added = Inventory_Add(ItemClass.Bombs, 0, Ring_BombAmount);
						}
						
						if(!_Added){
							var _DropPos = Item_DropPos();
							ItemDrop(_DropPos[0], _DropPos[1], ItemClass.Bombs, 0, Ring_BombAmount, ItemFrom.Inventory);							
						}						
						break;
					
					case Ring.Arrows:
						if(global.Inventory.ItemData[ItemClass.ArrowQuiver].Owns[0])
							_Added = Item_Consume(ItemClass.Arrows, 0, Ring_ArrowAmount);
						else{
							_Added = Inventory_Add(ItemClass.Arrows, 0, Ring_ArrowAmount);
						}
						if(!_Added){
							var _DropPos = Item_DropPos();
							ItemDrop(_DropPos[0], _DropPos[1], ItemClass.Arrows, 0, Ring_ArrowAmount, ItemFrom.Inventory);		
						}
						break;
				}
				
				if(_Error) global.Inventory.ItemData[ItemClass.Magic].Amount = min(global.Inventory.ItemData[ItemClass.Magic].Amount + _MagicUsed, MAGICAMOUNT_MAX);
				
			}
			
			if(!_Error){
				if(_MagicUsed > 0){
					audio_play_sound(Sound_Cane_Magic, 1, false);
					audio_play_sound(Sound_TextDone, 1, false);	
					audio_play_sound(Sound_Throw, 1, false);
				}else{
					_Error = true;
				}
			}
			
			break;
			
		case ItemClass.Powder:

			if(MagicUse(3) > 0){
				with(oLink) UpdateState(LinkState.Powder);
			}else{
				_Error = true;
			}
			break;
		
		case ItemClass.Bombs:
		case ItemClass.Gem:
		case ItemClass.Orb:
		case ItemClass.WishStone:
			
			if(oLink.InDoor_BlockItem || oLink.InDoor_House || !oLink.InDoor_Aligned) break;
			
			switch(_ItemClass){
				case ItemClass.Bombs: _ObjIndex = oBomb; break;
				case ItemClass.Gem: _ObjIndex = oGem; break;
				case ItemClass.Orb: _ObjIndex = oOrb; break;
				case ItemClass.WishStone: _ObjIndex = oWishStone; break;
			}
			
			switch(oLink.Facing){
				case LEFT: Inst = instance_create_layer(oLink.x - 14, oLink.y, oLink.layer, _ObjIndex, {From : ItemFrom.Inventory, FloorLevel : oLink.FloorLevel}); break;
				case RIGHT: Inst = instance_create_layer(oLink.x + 14, oLink.y, oLink.layer, _ObjIndex, {From : ItemFrom.Inventory, FloorLevel : oLink.FloorLevel}); break;
				case UP: Inst = instance_create_layer(oLink.x, oLink.y - 12, oLink.layer, _ObjIndex, {From : ItemFrom.Inventory, FloorLevel : oLink.FloorLevel}); break;
				case DOWN: Inst = instance_create_layer(oLink.x, oLink.y + 12, oLink.layer, _ObjIndex, {From : ItemFrom.Inventory, FloorLevel : oLink.FloorLevel}); break;
			}
			Inst.Index = _ItemIndex;
			
			with(oLink){
				if(_ItemClass == ItemClass.Bombs){
					if(!_FromInventory){
						Inst.alarm[0] = Bomb_IgniteDelay; //ignite bomb
						break; //if not using bomb from inventory, don't pickup
					}
					
				}
				UpdateState(LinkState.PickUp, Inst);			
				
			}

			// Inf. Bombs cheat
			if(!(_ItemClass == ItemClass.Bombs && Cheat_On("Cheat_Inf_Bombs"))) Inventory_Add(_ItemClass, _ItemIndex, -1, _Slot);

			if(oLink.State == LinkState.PickUp) break;
			
			break;	
			
		case ItemClass.Medallion:
			if(MagicUse(MAGICAMOUNT_QUARTER) > 0){
				if(instance_exists(global.InventoryInst)) global.Inventory.Bags[InventoryBag.Main].Status = InventoryBagStatus.Closing;//global.InventoryInst.Close = true;
				with(oLink) instance_create_layer(x, y, "ObjsHigher_" + GetFloorLevelString(FloorLevel), oMedallion);
			}else{
				_Error = true;
			}
			break;
		
		case ItemClass.Cape:
			if(MagicUse(1) > 0){
				MagicUse(-1); //put back the amount used to check
				if(instance_exists(global.InventoryInst)) global.Inventory.Bags[InventoryBag.Main].Status = InventoryBagStatus.Closing;//global.InventoryInst.Close = true;
				with(oLink){
					if(instance_exists(oCape)){
						instance_destroy(oCape);
					}else{
						if(!StarActive) instance_create_layer(x, y, "ObjsHigher_Upper", oCape);
					}
				}
			}else{
				_Error = true;
			}
			break;
			
		default: 
			
			if(_ItemClass == -1) break;
			
			if( Item_CanUse(_ItemClass, _ItemIndex)){
				
				Item_Consume(_ItemClass, _ItemIndex);
				
				if(global.ItemData[_ItemClass].Type == ItemType.Inv_Stk || global.ItemData[_ItemClass].Type == ItemType.Inv_NoStk){
					
					global.Inventory.Bags[_BagIndex].Slots[_SlotIndex].Amount--;
					
					if(global.Inventory.Bags[_BagIndex].Slots[_SlotIndex].Amount <= 0) Inventory_DeleteSlot([_BagIndex, _SlotIndex]);
					
					Inventory_Update();
				}
				
			}else _Error = true;
			break;
			
		
	}
	
	if(_Error) audio_play_sound_stopall(Sound_Error);
	
	return !_Error
	
}

function Inventory_DeleteSlot(_Slot){
	
	var _BagIndex = _Slot[0];
	var _SlotIndex = _Slot[1];
	
	if(_BagIndex == -1 || _SlotIndex == -1) exit;
	
	var _InvSlot = global.Inventory.Bags[_BagIndex].Slots[_SlotIndex];
	
	if(_InvSlot.ItemClass == -1) exit;
	
	var _InvItemData = global.Inventory.ItemData[_InvSlot.ItemClass];
	
	switch(global.ItemData[_InvSlot.ItemClass].Type){
		case ItemType.Inv_Bool:
			_InvItemData.Owns[_InvSlot.ItemIndex] = false; 
			break;
			
		case ItemType.Inv_Chrg:
			_InvItemData.Owns[_InvSlot.ItemIndex] = false; 
			_InvItemData.Amount[_InvSlot.ItemIndex] = 0;
			break;
			
		case ItemType.Inv_Upg: 
			_InvItemData.Owns = false;
			_InvItemData.Index = _InvItemData.Index_Min; 
			break;
		
		case ItemType.Inv_Stk:  
			_InvItemData.Owns[_InvSlot.ItemIndex] = _InvItemData.Amount[_InvSlot.ItemIndex] > 0;
			break;
	}
	
	Inventory_ClearSlot(_Slot);
	
	Link_UpdateAttackDefence();	
	
	if(global.Inventory.SlotEquiped[0] == _BagIndex && global.Inventory.SlotEquiped[1] == _SlotIndex) global.Inventory.SlotEquiped = [-1, -1];
	
}

function Inventory_DeleteItemClass(_ItemClass){
	
	//Finds the first _ItemClass in inventory starting from last slot going down, then deletes it
	
	var _InvSlot = Inventory_FindItem(_ItemClass);
	if(_InvSlot[0] != -1) Inventory_DeleteSlot(_InvSlot);
	
}

function Inventory_DeleteItemIndex(_ItemClass, _ItemIndex){
	
	//Finds the first _ItemClass with index _ItemIndex in inventory starting from last slot going down, then deletes it
	var _InvSlot = Inventory_FindItem(_ItemClass, _ItemIndex);
	if(_InvSlot[0] != -1 && _InvSlot[1] != -1) Inventory_DeleteSlot(_InvSlot);
	
}

function Inventory_Update(){
	
	Inventory_TransferItemsToBags();
	
	Inventory_Defrag();
	
	Inventory_CountStackItems();	
	
	with(oInventory){
		BagCount[InventoryBag.Food] = Inventory_CountBagItems(InventoryBag.Food);
		BagCount[InventoryBag.Bombs] = Inventory_CountBagItems(InventoryBag.Bombs);
		BagCount[InventoryBag.Pendants] = Inventory_CountBagItems(InventoryBag.Pendants);
		BagCount[InventoryBag.Gems] = Inventory_CountBagItems(InventoryBag.Gems);
	}

}

function Inventory_CountStackItems(){
	
	//first clear all the item data amounts for stack items
	for(var _ItemClass = 0; _ItemClass < ItemClasses; _ItemClass++){
		
		switch(global.ItemData[_ItemClass].Type){

			case ItemType.Inv_Stk:

				var _ObjIndex = ObjIndexFromItemClass(_ItemClass);
				var _Indexes = sprite_get_number(object_get_sprite(_ObjIndex));
				var _InvItemData = global.Inventory.ItemData[_ItemClass];
		
				for(var j = 0; j < _Indexes; j++){
					_InvItemData.Amount[j] = 0;
				}
				break;			
			
		}

	}
	
	//now count all stack items in inventory and add to itemdata
	for(var _BagIndex = 0; _BagIndex < Inventory_Bags; _BagIndex++){
		
		var _Bag = global.Inventory.Bags[_BagIndex];
		
		if(!_Bag.Owns) continue;
		
		for(var _SlotIndex = 0; _SlotIndex < _Bag.SlotCount; _SlotIndex++){
			
			var _Slot = _Bag.Slots[_SlotIndex];

			if(_Slot.ItemClass == -1) continue;

			var _InvItemData = global.Inventory.ItemData[_Slot.ItemClass];
			switch(global.ItemData[_Slot.ItemClass].Type){

				case ItemType.Inv_Stk:
					_InvItemData.Amount[_Slot.ItemIndex] = min(_InvItemData.Amount[_Slot.ItemIndex] + _Slot.Amount, Inventory_MaxAmount(_Slot.ItemClass));			
					break;			
			
			}
		}
	
	}
}

function Inventory_Defrag(){
	
	//Shifts over all the items to the front of bags removing empty slots in between them
	
	for(var _BagIndex = 0; _BagIndex < Inventory_Bags; _BagIndex++){
		
		var _Bag = global.Inventory.Bags[_BagIndex];
		
		if(!_Bag.Owns) continue;
		
		for(var _SlotIndex1 = 0; _SlotIndex1 < _Bag.SlotCount - 1; _SlotIndex1++){
			
				var _Slot1 = _Bag.Slots[_SlotIndex1];
				
				if(_Slot1.Ignore || _Slot1.Locked) continue;
				
				if(_Slot1.ItemClass != -1) continue;
				
				for(var _SlotIndex2 = _SlotIndex1 + 1; _SlotIndex2 < _Bag.SlotCount; _SlotIndex2++){
					
					var _Slot2 = _Bag.Slots[_SlotIndex2];
					
					if(_Slot2.Ignore || _Slot2.Locked) continue;
					
					if(_Slot2.ItemClass == -1) continue;
					
					Inventory_MoveSlot([_BagIndex, _SlotIndex2], [_BagIndex, _SlotIndex1]);	
					
					break;
					
				}
				
		}

	}

}

function Inventory_MoveSlot(_Source, _Dest){
	
	var _BagIndex_Source = _Source[0];
	var _SlotIndex_Source = _Source[1];
	var _BagIndex_Dest = _Dest[0];
	var _SlotIndex_Dest = _Dest[1];
	
	if(_BagIndex_Source == -1 || _SlotIndex_Source == -1 || _BagIndex_Dest == -1 || _SlotIndex_Dest == -1) exit;
	
	if(global.Inventory.SlotEquiped[0] == _BagIndex_Source && global.Inventory.SlotEquiped[1] == _SlotIndex_Source){
		global.Inventory.SlotEquiped[0] = _Dest[0];
		global.Inventory.SlotEquiped[1] = _Dest[1];
	}
	
	global.Inventory.Bags[_BagIndex_Dest].Slots[_SlotIndex_Dest].ItemClass = global.Inventory.Bags[_BagIndex_Source].Slots[_SlotIndex_Source].ItemClass;	
	global.Inventory.Bags[_BagIndex_Dest].Slots[_SlotIndex_Dest].ItemIndex = global.Inventory.Bags[_BagIndex_Source].Slots[_SlotIndex_Source].ItemIndex;	
	global.Inventory.Bags[_BagIndex_Dest].Slots[_SlotIndex_Dest].Amount = global.Inventory.Bags[_BagIndex_Source].Slots[_SlotIndex_Source].Amount;	
	Inventory_ClearSlot(_Source);
}

function Inventory_TransferItemsToBags(){

	//Moves all items from the main inventory to the bag slots
	
	for(var _SlotIndex = 0; _SlotIndex < global.Inventory.Bags[InventoryBag.Main].SlotCount; _SlotIndex++){
		
		var _Slot = global.Inventory.Bags[InventoryBag.Main].Slots[_SlotIndex];
		
		if(_Slot.ItemClass == -1) continue;
		
		var _AvailableSlot = Inventory_FindAvailableSlot(_Slot.ItemClass, _Slot.ItemIndex, _Slot.Amount);
		
		if(_AvailableSlot[0] != InventoryBag.Main){	
			Inventory_MoveSlot([InventoryBag.Main, _SlotIndex], _AvailableSlot);
		}
	
	}
	
}

function Inventory_ClearSlot(_Slot){

	var _BagIndex = _Slot[0];
	var _SlotIndex = _Slot[1];
	
	if(_BagIndex == -1 || _SlotIndex == -1) exit;
	
	var _InvSlot = global.Inventory.Bags[_Slot[0]].Slots[_Slot[1]];
	
	_InvSlot.ItemClass = -1;	
	_InvSlot.ItemIndex = -1;	
	_InvSlot.Amount = 0;		
	_InvSlot.Enabled = true;
	
}

function Inventory_ClearAll(){

	global.Inventory.ItemData[ItemClass.Key].Amount = 0;
	global.Inventory.ItemData[ItemClass.Rupee].Amount = 0;
	global.Inventory.ItemData[ItemClass.Magic].Amount = 0;
	global.Inventory.ItemData[ItemClass.Arrows].Amount[0] = 0;
	global.Inventory.ItemData[ItemClass.Bombs].Amount[0] = 0;
	global.ItemData[ItemClass.Arrows].Type = ItemType.Inv_Stk;
	global.ItemData[ItemClass.Bombs].Type = ItemType.Inv_Stk;
	
	for(var _BagIndex = 0; _BagIndex < Inventory_Bags; _BagIndex++){
		var _Bag = global.Inventory.Bags[_BagIndex];
		for(var i = 0; i < _Bag.SlotCount; i++){
			Inventory_DeleteSlot([_BagIndex, i]);
		}
		_Bag.Owns = false;
		_Bag.Status = InventoryBagStatus.Closed;
		_Bag.Position = 0;
	}

	// Deleting slots only resets items that are in a slot. Some items are owned without one
	// (e.g. the Moon Pearl or Master Key given by a cheat when the inventory was full), so reset every item's data too.
	// Hearts are kept; Aghanim calls this mid-fight, and a new game sets them in Link_SetStartingItems.
	for(var _ItemClass = 0; _ItemClass < ItemClasses; _ItemClass++){
		if(_ItemClass == ItemClass.Heart || _ItemClass == ItemClass.HeartPiece) continue;
		Inventory_ResetItemData(global.Inventory.ItemData[_ItemClass]);
	}

	global.Inventory.Bags[InventoryBag.Main].Owns = true;	
	global.Inventory.Bags[InventoryBag.Gear].Owns = true;
	
	var _MainBag = global.Inventory.Bags[InventoryBag.Main];
	for(var i = 0; i < _MainBag.Columns * 2; i++){
		var _Slot = _MainBag.Slots[_MainBag.Columns + i];
		_Slot.Locked = true;
	}	
	
	global.Inventory.SlotSelected = [InventoryBag.Main, global.Inventory.Bags[InventoryBag.Main].Columns];
	global.Inventory.SlotEquiped = [-1, -1];
	
}

/// @description Resets an item's inventory data to "not owned": Owns to false, Amount to 0, and upgrade Index to its minimum.
/// @param {Struct} _InvItemData An entry of global.Inventory.ItemData.
function Inventory_ResetItemData(_InvItemData){

	if(!is_struct(_InvItemData)) exit;

	if(variable_struct_exists(_InvItemData, "Owns")){
		if(is_array(_InvItemData.Owns)){
			for(var i = 0; i < array_length(_InvItemData.Owns); i++) _InvItemData.Owns[i] = false;
		}else{
			_InvItemData.Owns = false;
		}
	}

	if(variable_struct_exists(_InvItemData, "Amount")){
		if(is_array(_InvItemData.Amount)){
			for(var i = 0; i < array_length(_InvItemData.Amount); i++) _InvItemData.Amount[i] = 0;
		}else{
			_InvItemData.Amount = 0;
		}
	}

	if(variable_struct_exists(_InvItemData, "Index")){
		_InvItemData.Index = _InvItemData[$ "Index_Min"] ?? -1;
	}

}

function Inventory_FindLockedSlot(){
	
	for(var i = 0; i < global.Inventory.Bags[InventoryBag.Main].SlotCount; i++){	
		if(global.Inventory.Bags[InventoryBag.Main].Slots[i].Locked) return i;
	}
	return -1;
	
}

function Inventory_MaxAmount(_ItemClass, _ItemIndex = 0){
	
	switch(_ItemClass){
		case ItemClass.Arrows: return global.Inventory.ItemData[ItemClass.ArrowQuiver].Owns[0] ? MaxArrowsQuiver : MaxArrows
		case ItemClass.Bombs: return global.Inventory.ItemData[ItemClass.BombBag].Owns[0] ? MaxBombsBag : MaxBombs
		case ItemClass.Rod: return global.MaxRodCharge[_ItemIndex];
	}
	
	return 99;
	
}

function Inventory_CountBagItems(_BagIndex){
	
	//Counts items in bag
	var _Count = 0;
	var _Bag = global.Inventory.Bags[_BagIndex];
	for(var i = 0; i < _Bag.SlotCount; i++){
		if(_Bag.Slots[i].ItemClass != -1){
			
			var _ItemType = global.ItemData[_Bag.Slots[i].ItemClass].Type;
		
			switch(_ItemType){
			
				default:
					_Count++;
					break;
			
				case ItemType.Inv_Stk:
					_Count += _Bag.Slots[i].Amount;
					break;
			
			}
			
		}
	}
	return _Count
}

function Inventory_GetPosOffset(_SpriteIndex, _ItemIndex){
	
	//Inventory sprites have all sorts of sizes and x/y offsets, so this function sends back how much we wish to offset the sprite when drawing it on the inventory sprite.
	//Default is just sprite_get_x/yoffset(), most sprites this will already work. Some others we shift some more
	
	Offset[0] = sprite_get_xoffset(_SpriteIndex);
	Offset[1] = sprite_get_yoffset(_SpriteIndex);
	
	
	switch(_SpriteIndex){
		
		//case sItem_Shield:
		//	if(_ItemIndex == 0) Offset[1]-=1;
		//	break;
		
		case sItem_Boomerang: 
		case sItem_Coupon:
		case sItem_Letter:
			Offset[0]+=1;
			Offset[1]+=3;
			break;	


		
		case sItem_Mirror:
		case sItem_Book:
			Offset[0]+=1;
			Offset[1]+=1;
			break;

			
		case sItem_ArrowQuiver:
		case sItem_Arrows:
		case sItem_BombBag: 
		case sItem_FoodBag: 
		case sItem_PendantBag: 
		case sItem_GemBag: 
		case sItem_Bow: 
		case sItem_Map: 
		case sItem_Compass: 
		case sItem_Cane: 
		case sItem_Cape: 
		case sItem_Magic_Large: 
		case sItem_Rod: 
		case sItem_Medallion: 
		case sItem_Hookshot: 
		case sItem_Gloves:
		case sItem_Lamp:
		case sItem_Sword_Inventory:
		case sItem_Pendant:
		case sItem_Pop:
		case sItem_Potion:
		case sItem_Ring:
		case sItem_Kinstone:
		case sItem_Key_Master:
		case sItem_Key_Special:
		case sItem_MoonPearl:
		case sItem_Mushroom:
		case sItem_Treasure:
			Offset[1]+=1;
			break;

		case sItem_Tunic:
		case sItem_Powder:
		case sItem_WishStone:
			Offset[1]+=2;
			break;

	}
	
	return Offset;
	
}

function Inventory_ResolveBombBag(_BagIndex, _SlotIndex){

	var _Slot = global.Inventory.Bags[_BagIndex].Slots[_SlotIndex];

	if(_Slot.ItemClass == ItemClass.BombBag){
		var _BombSlot = global.Inventory.Bags[InventoryBag.Bombs].Slots[0];
		if(_BombSlot.ItemClass == ItemClass.Bombs){ 
			return [InventoryBag.Bombs, 0];
		}
		return [-1, -1];   
	}

	return [_BagIndex, _SlotIndex];
}