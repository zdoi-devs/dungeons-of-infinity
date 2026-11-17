
depth = -1000;

X = oCamera.X + global.Inventory.Bags[InventoryBag.Main].X;
Y = oCamera.Y + global.Inventory.Bags[InventoryBag.Main].Y;

global.Inventory.Bags[InventoryBag.Main].Status = InventoryBagStatus.Opening;
global.Inventory.Bags[InventoryBag.Main].Position = 0;

OpenSpeed = 0.10;


BagCount[InventoryBag.Food] = Inventory_CountBagItems(InventoryBag.Food);
BagCount[InventoryBag.Bombs] = Inventory_CountBagItems(InventoryBag.Bombs);
BagCount[InventoryBag.Pendants] = Inventory_CountBagItems(InventoryBag.Pendants);
BagCount[InventoryBag.Gems] = Inventory_CountBagItems(InventoryBag.Gems);

//if cursor is inside special bag and there's no items, then move cursor outside of bag
switch(global.Inventory.SlotSelected[0]){

	case InventoryBag.Food:
	case InventoryBag.Bombs:
	case InventoryBag.Pendants:
	case InventoryBag.Gems:	
		if(BagCount[global.Inventory.SlotSelected[0]] == 0){
			global.Inventory.SlotSelected[1] = global.Inventory.SlotSelected[0];
			global.Inventory.SlotSelected[0] = InventoryBag.Main;
		}
		break;
	
}


Inventory_Update();

//Disable top row slots that don't have items, enable the rest.
var i;
for(i = 0; i < global.Inventory.Bags[InventoryBag.Main].Columns; i++) {
	
	var _Slot = global.Inventory.Bags[InventoryBag.Main].Slots[i];
	
	switch(i){
		default: _Slot.Enabled = false; break;
		case InventoryBag.Gear: _Slot.Enabled = true; break;
		case InventoryBag.Food: _Slot.Enabled = global.Inventory.ItemData[ItemClass.FoodBag].Owns[0]; break;
		case InventoryBag.Bombs: _Slot.Enabled = global.Inventory.ItemData[ItemClass.BombBag].Owns[0]; break;
		case InventoryBag.Pendants: _Slot.Enabled = global.Inventory.ItemData[ItemClass.PendantBag].Owns[0]; break;
		case InventoryBag.Gems: _Slot.Enabled = global.Inventory.ItemData[ItemClass.GemBag].Owns[0]; break;
	}

}


//make sure to close any bag that's still open and isn't selected
var _BagIndexSelected = global.Inventory.SlotSelected[0];
var _SlotIndexSelected = global.Inventory.SlotSelected[1];

for(var _BagIndex = 0; _BagIndex < Inventory_Bags; _BagIndex++){
	
	if(_BagIndex == InventoryBag.Main) continue;
	
	var _Bag = global.Inventory.Bags[_BagIndex];
	
	var _OpenBag = (_BagIndexSelected == InventoryBag.Main && _SlotIndexSelected == _BagIndex) || (_BagIndexSelected != InventoryBag.Main && _BagIndexSelected == _BagIndex);
	
	if(_OpenBag){
		_Bag.Status = InventoryBagStatus.Open;
		_Bag.Position = 1;	
	}else{
		_Bag.Status = InventoryBagStatus.Closed;
		_Bag.Position = 0;
	}

}

hover_debounce = true
MenuEnable = false;

MenuItems = 4;
MenuItemGrid = ds_grid_create(2, MenuItems); //x0 = menu caption, x1 = enable status
i = 0;
MenuItemGrid[# 0,   i] = "EQUIP";   MenuItemGrid[# 1, i] = true;
MenuItemGrid[# 0, ++i] = "USE";		MenuItemGrid[# 1, i] = true;
MenuItemGrid[# 0, ++i] = "DROP";	MenuItemGrid[# 1, i] = true;
MenuItemGrid[# 0, ++i] = "INFO";	MenuItemGrid[# 1, i] = true;

MenuSeperator = string_repeat(" ", 3);
MenuStr = "";
MenuItemPos[0] = 0;
draw_set_font(global.Font_Small);
for(i = 0; i < MenuItems; i++){
	MenuItemW[i] = string_width(MenuItemGrid[# 0, i]);
	MenuStr += (MenuItemGrid[# 0, i] + (i < MenuItems - 1 ? MenuSeperator : ""));
	MenuItemPos[i+1] = string_width(MenuStr);
}
MenuStrW = string_width(MenuStr);
MenuX = X + ((global.Inventory.Bags[InventoryBag.Main].W - MenuStrW) / 2) + 1;
MenuY = Y + global.Inventory.Bags[InventoryBag.Main].H - 13;

MenuSelectionIndex = 0;

Fan = InventoryFanStatus.None;
FanXOffset = Inventory_SlotW + 12;
FanPosition = 0;

audio_play_sound(Sound_Pickup, 1, false);


DB_Script = 0;
DB_Init = false;
DB_Started = false;



	//------INFO------

	function DBScriptFunction_Inventory_ItemInfo(){

		var _BagIndex = global.Inventory.SlotSelected[0];
		var _SlotIndex = global.Inventory.SlotSelected[1];
				
		var _Bag = global.Inventory.Bags[_BagIndex];
		var _Slot = _Bag.Slots[_SlotIndex];
				
		var _ItemClass = _Slot.ItemClass;
		var _ItemIndex = _Slot.ItemIndex;
		var _ItemAmount = _Slot.Amount;
		
		return Item_Name(_ItemClass, _ItemIndex, _ItemAmount) + ":^" + Item_Info(_ItemClass, _ItemIndex);
	} 

	
	DBScript_Info = ds_grid_create(3, 2); i = 0; 

var	Addr=0;	DBScript_Info[# 0, Addr] = DBScriptCode.Dialogue	DBScript_Info[# ++i, Addr] = method(self, DBScriptFunction_Inventory_ItemInfo);	DBScript_Info[# ++i, Addr] = 1; i = 0;
	Addr=1;	DBScript_Info[# 0, Addr] = DBScriptCode.End;		DBScript_Info[# ++i, Addr] = 0; i = 0;



global.Paused = true;