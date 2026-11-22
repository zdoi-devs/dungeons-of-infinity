// Feather disable GM2064


enum ItemClass {ArrowQuiver, Arrows, BagSlot, Book, BombBag, Bombs, Boomerang, Bow, Cane, Cape,				//0-9
				Compass, Crystal, Fairy, Food, Gem, GemBag, Gloves, Heart, HeartPiece, Hookshot,			//10-19
				Key, MasterKey, SpecialKey, Kinstone, Lamp, Letter, Magic, MagicLarge, Map, Medallion,		//20-29
				Mirror, MoonPearl, Mushroom, Orb, Pendant, Pop, Potion, Powder, Ring, Rod,					//30-39
				Rupee, Shield, Star, Stopwatch, Sword, Treasure, Tunic, WishStone, Coupon, FoodBag,			//40-49
				PendantBag}																					//50+
				
#macro ItemClasses 51

//Item Types
//Pickup: (hearts, rupees, star, etc)
//Inventory_Boolean:(Compass, Map, MoonPearl..)
//Inventory_Upgradeable:(Sword, Tunic, Gloves..)
//Inventory_Stackable(Arrows, Bombs, Potion, food..) 
enum ItemType {Pickup, Inv_Bool, Inv_Upg, Inv_Stk, Inv_Chrg, Inv_NoStk} 

enum ItemFrom {Pot, PotSimple, Treasure, LargeTreasure, Shop, KinstoneGreen, KinstoneBlue, KinstoneRed, KinstoneGold, WeaponStore, TreasureStore, MagicStore, FoodStore, WishPond, TreasureRupees, Enemy, EnemyTiny, EnemySmall, EnemyMedium, EnemyLarge, Inventory, Zora, RupeeCane, Anywhere}

enum ItemSpawnType {None, DropShort, DropHigh, DropVeryHigh, DropScatter, DropSky, DropInventory, DropTreasure, DropZora, Float, Appear}


#macro RandomItem -99

global.Font_ItemValues = font_add_sprite_ext(sFont_ItemValues, "0123456789O-+", true, 0);

//Stores shop and dropped items that exist in the current dungeon level that can't have duplicates.
//Example, if a shop has a level 3 sword, or there's a dropped map somewhere, then those items should be in this list and shouldn't be picked for opened treasures
//Clear this list at the beginning of each level init
global.NonDuplicatableItemsThatExist = ds_grid_create(2, 0); 

#macro ItemDropDist 20
global.ItemDropPosTable = [[-ItemDropDist, 0], [ItemDropDist, 0], [0, -ItemDropDist], [-ItemDropDist, ItemDropDist], [ItemDropDist, ItemDropDist], [-ItemDropDist, -ItemDropDist], [ItemDropDist, -ItemDropDist], [0, ItemDropDist]]


function ItemDataInit(_ItemClass, _ItemType, _CanEquip, _CanUse, _CanDrop, _LimitMin, _LimitStart) {
	
	global.ItemData[_ItemClass] = {};

	global.ItemData[_ItemClass][$ "Type"] = _ItemType; 
	global.ItemData[_ItemClass][$ "CanEquip"] = (_CanEquip == 0 ? false : true);	//If item can be equiped from the inventory (hookshot, potion, etc)
	global.ItemData[_ItemClass][$ "CanUse"] = (_CanUse == 0 ? false : true);		//If item can be used from the inventory(potion, food, etc).
	global.ItemData[_ItemClass][$ "CanDrop"] = (_CanDrop == 0 ? false : true);		//If item can be dropped from the inventory(bags can't, etc)
	
	//The Limiter variables prevent certain items from appearing in treasures. Once one of those items
	//get collected, the corresponding variable has a number added, let's say 10.
	//Every treasure that is collected these get counted down by 1.
	//If the item that is picked is at 0, then it's allowed. If not, then don't pick that item.
	//This prevents, let's say, a pendant being collected in a treasure right after getting another one.
	global.ItemData[_ItemClass][$ "LimitMin"] = _LimitMin; //the min amount of limitcount. Some items need more than others
	global.ItemData[_ItemClass][$ "LimitStart"] = _LimitStart; //the min amount of limitcount. Some items need more than others
	global.ItemData[_ItemClass][$ "LimitCount"] = TreasureLimiter_NewLimitCount(_LimitStart);
	
}

function Items_InitData(){

									//  Type				Can	Can	Can	Lmt	Lmt
									//						Eqp	Use	Drp	Min	St
	ItemDataInit(ItemClass.ArrowQuiver,	ItemType.Inv_Bool,	0,	0,	0,	0,	7);
	ItemDataInit(ItemClass.BombBag,		ItemType.Inv_Bool,	1,	0,	0,	0,	7);
	ItemDataInit(ItemClass.FoodBag,		ItemType.Inv_Bool,	0,	0,	0,	0,	7);
	ItemDataInit(ItemClass.PendantBag,	ItemType.Inv_Bool,	0,	0,	0,	0,	7);
	ItemDataInit(ItemClass.GemBag,		ItemType.Inv_Bool,	0,	0,	0,	0,	7);
	
	
	ItemDataInit(ItemClass.Arrows,		ItemType.Inv_Stk,	0,	0,	1,	5,	0);
	ItemDataInit(ItemClass.BagSlot,		ItemType.Pickup,	0,	0,	0,	6,	3);
	ItemDataInit(ItemClass.Bombs,		ItemType.Inv_Stk,	1,	1,	1,	5,	0);
	ItemDataInit(ItemClass.Boomerang,	ItemType.Inv_Bool,	1,	0,	1,	0,	0);
	ItemDataInit(ItemClass.Bow,			ItemType.Inv_Upg,	1,	0,	1,	8,	5);
	ItemDataInit(ItemClass.Cane,		ItemType.Inv_Chrg,	1,	0,	1,	8,	6); //not used anymore, but keeping it there and all code relating to cane in case it gets added in the future
	ItemDataInit(ItemClass.Cape,		ItemType.Inv_Bool,	1,	1,	1,	0,	8);
	ItemDataInit(ItemClass.Compass,		ItemType.Inv_Bool,	0,	0,	1,	4,	0);
	ItemDataInit(ItemClass.Coupon,		ItemType.Inv_Stk,	1,	0,	1,	6,	2);
	ItemDataInit(ItemClass.Crystal,		ItemType.Inv_Bool,	0,	0,	0,	0,	0);
	ItemDataInit(ItemClass.Fairy,		ItemType.Pickup,	0,	0,	0,	0,	0);
	ItemDataInit(ItemClass.Food,		ItemType.Inv_Stk,	1,	1,	1,	4,	0);
	ItemDataInit(ItemClass.Gem,			ItemType.Inv_Stk,	1,	1,	1,	4,	0);
	ItemDataInit(ItemClass.Gloves,		ItemType.Inv_Upg,	0,	0,	0,	7,	5);
	ItemDataInit(ItemClass.Heart,		ItemType.Pickup,	0,	0,	0,	0,	0);
	ItemDataInit(ItemClass.HeartPiece,	ItemType.Pickup,	0,	0,	0,	6,	3);
	ItemDataInit(ItemClass.Hookshot,	ItemType.Inv_Bool,	1,	0,	1,	0,	0);
	ItemDataInit(ItemClass.Key,			ItemType.Pickup,	0,	0,	0,	0,	0);
	ItemDataInit(ItemClass.MasterKey,	ItemType.Inv_Bool,	0,	0,	1,	0,	0);
	ItemDataInit(ItemClass.Kinstone,	ItemType.Inv_Stk,	0,	0,	1,	4,	0);
	ItemDataInit(ItemClass.Lamp,		ItemType.Inv_Upg,	0,	0,	1,	8,	8);
	ItemDataInit(ItemClass.Magic,		ItemType.Pickup,	0,	0,	0,	0,	0);
	ItemDataInit(ItemClass.MagicLarge,	ItemType.Inv_Stk,	1,	1,	1,	6,	0);
	ItemDataInit(ItemClass.Map,			ItemType.Inv_Bool,	0,	0,	1,	4,	0);
	ItemDataInit(ItemClass.MoonPearl,	ItemType.Inv_Bool,	0,	0,	1,	0,	0);
	ItemDataInit(ItemClass.Orb,			ItemType.Inv_Stk,	1,	1,	1,	5,	0);
	ItemDataInit(ItemClass.Pendant,		ItemType.Inv_Bool,	0,	0,  1,	7,  6);
	ItemDataInit(ItemClass.Potion,		ItemType.Inv_NoStk,	1,	1,	1,	6,	2);
	ItemDataInit(ItemClass.Pop,			ItemType.Inv_Stk,	1,	1,	1,	6,	0);	
	ItemDataInit(ItemClass.Ring,		ItemType.Inv_Bool,	1,	1,	1,	7,	6);
	ItemDataInit(ItemClass.Rod,			ItemType.Inv_Chrg,	1,	0,	1,	7,	6);
	ItemDataInit(ItemClass.Rupee,		ItemType.Pickup,	0,	0,	0,	1,	0);
	ItemDataInit(ItemClass.Shield,		ItemType.Inv_Upg,	0,	0,	0,	7,	4);
	ItemDataInit(ItemClass.Stopwatch,	ItemType.Pickup,	0,	0,	0,	0,	0);
	ItemDataInit(ItemClass.Star,		ItemType.Pickup,	0,	0,	1,	0,	0);
	ItemDataInit(ItemClass.Sword,		ItemType.Inv_Upg,	0,	0,	0,	7,	4);
	ItemDataInit(ItemClass.Treasure,	ItemType.Inv_NoStk,	0,	0,	1,	0,	0);
	ItemDataInit(ItemClass.Tunic,		ItemType.Inv_Upg,	0,	0,	0,	7,	4);
	
	
	//Village items
	ItemDataInit(ItemClass.Book,		ItemType.Inv_Bool,	0,	0,	1,	0,	0);
	ItemDataInit(ItemClass.SpecialKey,	ItemType.Inv_Bool,	0,	0,	1,	0,	0);
	ItemDataInit(ItemClass.Letter,		ItemType.Inv_Bool,	0,	0,	1,	0,	0);
	ItemDataInit(ItemClass.Medallion,	ItemType.Inv_Bool,	1,	1,	1,	0,	0);
	ItemDataInit(ItemClass.Mirror,		ItemType.Inv_Bool,	0,	0,	1,	0,	0);
	ItemDataInit(ItemClass.Mushroom,	ItemType.Inv_Bool,	0,	0,	1,	0,	0);
	ItemDataInit(ItemClass.Powder,		ItemType.Inv_Bool,	1,	0,	1,	0,	0);
	ItemDataInit(ItemClass.WishStone,	ItemType.Inv_Stk,	1,	1,	1,	0,	0);


	global.PossibleItemLists = [];

	#region ItemFrom.Pot
		
		global.PossibleItemLists[ItemFrom.Pot] = ds_list_create();
		
		repeat(49){ds_list_add(global.PossibleItemLists[ItemFrom.Pot], ItemClass.Rupee)};
		repeat(29){ds_list_add(global.PossibleItemLists[ItemFrom.Pot], ItemClass.Heart)};
		repeat(26){ds_list_add(global.PossibleItemLists[ItemFrom.Pot], ItemClass.Magic)};
		repeat(5){ds_list_add(global.PossibleItemLists[ItemFrom.Pot], ItemClass.Bombs)};
		repeat(5){ds_list_add(global.PossibleItemLists[ItemFrom.Pot], ItemClass.Arrows)};
		repeat(4){ds_list_add(global.PossibleItemLists[ItemFrom.Pot], ItemClass.Gem)};
		repeat(4){ds_list_add(global.PossibleItemLists[ItemFrom.Pot], ItemClass.Stopwatch)};
		repeat(3){ds_list_add(global.PossibleItemLists[ItemFrom.Pot], ItemClass.Food)};
		repeat(3){ds_list_add(global.PossibleItemLists[ItemFrom.Pot], ItemClass.Fairy)};
		repeat(3){ds_list_add(global.PossibleItemLists[ItemFrom.Pot], ItemClass.Orb)};
		repeat(2){ds_list_add(global.PossibleItemLists[ItemFrom.Pot], ItemClass.Kinstone)};
		repeat(2){ds_list_add(global.PossibleItemLists[ItemFrom.Pot], ItemClass.Pop)};		
		repeat(1){ds_list_add(global.PossibleItemLists[ItemFrom.Pot], ItemClass.Coupon)};
		repeat(1){ds_list_add(global.PossibleItemLists[ItemFrom.Pot], ItemClass.MagicLarge)};

	#endregion
	
	#region ItemFrom.PotSimple:

		global.PossibleItemLists[ItemFrom.PotSimple] = ds_list_create();

		repeat(10){ds_list_add(global.PossibleItemLists[ItemFrom.PotSimple] , ItemClass.Rupee)};
		repeat(5){ds_list_add(global.PossibleItemLists[ItemFrom.PotSimple] , ItemClass.Heart)};
		repeat(4){ds_list_add(global.PossibleItemLists[ItemFrom.PotSimple] , ItemClass.Magic)};
		repeat(2){ds_list_add(global.PossibleItemLists[ItemFrom.PotSimple] , ItemClass.Bombs)};
		repeat(2){ds_list_add(global.PossibleItemLists[ItemFrom.PotSimple] , ItemClass.Arrows)};


	#endregion
			
	#region ItemFrom.Treasure:

		global.PossibleItemLists[ItemFrom.Treasure] = ds_list_create();
		
		repeat(39){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure],	ItemClass.Rupee)};
		repeat(4){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.Map)};
		repeat(4){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.Compass)};
		repeat(3){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.Gem)};
		repeat(3){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.Kinstone)};
		repeat(3){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.MagicLarge)};
		repeat(3){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.Food)};
		repeat(3){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.Pop)};
		repeat(3){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.Orb)};
		repeat(3){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.Potion)};
		repeat(3){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.Arrows)};
		repeat(3){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.Bombs)};
		repeat(3){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.Coupon)};
		repeat(2){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.BagSlot)};
		repeat(2){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.HeartPiece)};
		repeat(1){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.Bow)};
		repeat(1){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.Ring)};
		repeat(1){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.Rod)};
		repeat(1){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.Shield)};
		repeat(1){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.Sword)};
		repeat(1){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.Tunic)};
		repeat(1){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.Gloves)};
		repeat(1){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.ArrowQuiver)};
		repeat(1){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.BombBag)};
		repeat(1){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.GemBag)};
		repeat(1){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.FoodBag)};
		repeat(1){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.PendantBag)};
		repeat(1){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.Lamp)};
		repeat(1){ds_list_add(global.PossibleItemLists[ItemFrom.Treasure], ItemClass.Cape)};
		
	#endregion
			
	#region ItemFrom.LargeTreasure:

		global.PossibleItemLists[ItemFrom.LargeTreasure] = ds_list_create();
		
		ds_list_add(global.PossibleItemLists[ItemFrom.LargeTreasure],
			ItemClass.BagSlot,
			ItemClass.ArrowQuiver, 
			ItemClass.BombBag, 	
			ItemClass.GemBag,
			ItemClass.FoodBag,
			ItemClass.PendantBag,
			ItemClass.Boomerang,
			ItemClass.Bow,ItemClass.Bow,
			ItemClass.Cape,
			ItemClass.Gloves,ItemClass.Gloves,
			ItemClass.Hookshot,
			ItemClass.Lamp,ItemClass.Lamp,
			ItemClass.Pendant,ItemClass.Pendant,
			ItemClass.Ring,ItemClass.Ring,
			ItemClass.Rod,ItemClass.Rod,
			ItemClass.Shield,ItemClass.Shield,
			ItemClass.Sword,ItemClass.Sword,
			ItemClass.Tunic,ItemClass.Tunic										
		)

	#endregion
			
	#region ItemFrom.Shop:
		
		global.PossibleItemLists[ItemFrom.Shop] = ds_list_create();
		
		ds_list_add(global.PossibleItemLists[ItemFrom.Shop],
			ItemClass.ArrowQuiver,ItemClass.ArrowQuiver,
			ItemClass.BagSlot,ItemClass.BagSlot,ItemClass.BagSlot,
			ItemClass.BombBag,ItemClass.BombBag,
			ItemClass.FoodBag,ItemClass.FoodBag,
			ItemClass.GemBag,ItemClass.GemBag,
			ItemClass.PendantBag,ItemClass.PendantBag,
			ItemClass.Arrows,ItemClass.Arrows,ItemClass.Arrows,
			ItemClass.Bombs,ItemClass.Bombs,ItemClass.Bombs,
			ItemClass.Bow,ItemClass.Bow,ItemClass.Bow,ItemClass.Bow,
			ItemClass.Cape,ItemClass.Cape,
			ItemClass.Food,ItemClass.Food,ItemClass.Food,ItemClass.Food,ItemClass.Food,
			ItemClass.Gloves,ItemClass.Gloves,ItemClass.Gloves,ItemClass.Gloves,
			ItemClass.HeartPiece,ItemClass.HeartPiece,ItemClass.HeartPiece,ItemClass.HeartPiece,
			ItemClass.Key,ItemClass.Key,
			ItemClass.Lamp,ItemClass.Lamp,
			ItemClass.MagicLarge,ItemClass.MagicLarge,ItemClass.MagicLarge,
			ItemClass.Orb,ItemClass.Orb,ItemClass.Orb,ItemClass.Orb,
			ItemClass.Pendant,ItemClass.Pendant,ItemClass.Pendant,ItemClass.Pendant,
			ItemClass.Potion,ItemClass.Potion,ItemClass.Potion,ItemClass.Potion,
			ItemClass.Pop,ItemClass.Pop,ItemClass.Pop,ItemClass.Pop,
			ItemClass.Ring,ItemClass.Ring,ItemClass.Ring,ItemClass.Ring,
			ItemClass.Rod,ItemClass.Rod,ItemClass.Rod,ItemClass.Rod,
			ItemClass.Shield,ItemClass.Shield,ItemClass.Shield,ItemClass.Shield,
			ItemClass.Sword,ItemClass.Sword,ItemClass.Sword,ItemClass.Sword,
			ItemClass.Treasure,ItemClass.Treasure,ItemClass.Treasure,ItemClass.Treasure,
			ItemClass.Tunic,ItemClass.Tunic,ItemClass.Tunic,ItemClass.Tunic
		)
		
		//if(DEBUG){
		//	repeat(500){ds_list_add(global.PossibleItemLists[ItemFrom.Shop], ItemClass.Lamp)};
		//}
		
	#endregion
		
	#region ItemFrom.KinstoneGreen:
		
		global.PossibleItemLists[ItemFrom.KinstoneGreen] = ds_list_create();
		
		ds_list_add(global.PossibleItemLists[ItemFrom.KinstoneGreen],
			ItemClass.Arrows,
			ItemClass.Bombs,
			ItemClass.Food,
			ItemClass.Gem,
			ItemClass.MagicLarge,
			ItemClass.Orb,
			ItemClass.Pop,
			ItemClass.Rupee,ItemClass.Rupee
		)
			
	#endregion
			
	#region ItemFrom.KinstoneBlue:
		
		global.PossibleItemLists[ItemFrom.KinstoneBlue] = ds_list_create();
		
		ds_list_add(global.PossibleItemLists[ItemFrom.KinstoneBlue],
			ItemClass.ArrowQuiver,
			ItemClass.BagSlot,
			ItemClass.BombBag,
			ItemClass.Food,
			ItemClass.HeartPiece,
			ItemClass.Potion,
			ItemClass.Rupee,ItemClass.Rupee
		)
						
	#endregion
			
	#region ItemFrom.KinstoneRed:
		
		global.PossibleItemLists[ItemFrom.KinstoneRed] = ds_list_create();
		
		ds_list_add(global.PossibleItemLists[ItemFrom.KinstoneRed],

			ItemClass.FoodBag,
			ItemClass.PendantBag,
			ItemClass.Bow,
			ItemClass.Lamp,
			ItemClass.Ring,
			ItemClass.Rod,
			ItemClass.Rupee,ItemClass.Rupee
		)
			
	#endregion
			
	#region ItemFrom.KinstoneGold:
		
		global.PossibleItemLists[ItemFrom.KinstoneGold] = ds_list_create();
		
		ds_list_add(global.PossibleItemLists[ItemFrom.KinstoneGold],
			ItemClass.Cape,
			ItemClass.GemBag,
			ItemClass.Gloves,
			ItemClass.Pendant,
			ItemClass.Rupee,ItemClass.Rupee,
			ItemClass.Shield,
			ItemClass.Sword,
			ItemClass.Tunic
		)
			
	#endregion
			
	#region ItemFrom.WeaponStore:
		
		global.PossibleItemLists[ItemFrom.WeaponStore] = ds_list_create();
		
		ds_list_add(global.PossibleItemLists[ItemFrom.WeaponStore],
			ItemClass.Arrows,
			ItemClass.ArrowQuiver,
			ItemClass.BombBag,
			ItemClass.Bombs,
			ItemClass.Boomerang,
			ItemClass.Bow,ItemClass.Bow,ItemClass.Bow,ItemClass.Bow,
			ItemClass.Gloves,ItemClass.Gloves,ItemClass.Gloves,
			ItemClass.Hookshot,
			ItemClass.Shield,ItemClass.Shield,ItemClass.Shield,
			ItemClass.Sword,ItemClass.Sword, ItemClass.Sword, ItemClass.Sword,
			ItemClass.Tunic, ItemClass.Tunic, ItemClass.Tunic
		)
		
	#endregion
			
	#region ItemFrom.TreasureStore:
		
		global.PossibleItemLists[ItemFrom.TreasureStore] = ds_list_create();
		
		ds_list_add(global.PossibleItemLists[ItemFrom.TreasureStore],	
			ItemClass.BagSlot, ItemClass.BagSlot, ItemClass.BagSlot, ItemClass.BagSlot, ItemClass.BagSlot,
			ItemClass.GemBag,ItemClass.GemBag,ItemClass.GemBag,
			ItemClass.HeartPiece, ItemClass.HeartPiece,
			ItemClass.MasterKey, ItemClass.MasterKey, ItemClass.MasterKey,
			ItemClass.MoonPearl, ItemClass.MoonPearl, ItemClass.MoonPearl,
			ItemClass.Lamp,ItemClass.Lamp,ItemClass.Lamp,ItemClass.Lamp,
			ItemClass.Orb,
			ItemClass.Kinstone,ItemClass.Kinstone,
			ItemClass.Treasure, ItemClass.Treasure, ItemClass.Treasure, ItemClass.Treasure
		)
		
	#endregion
			
	#region ItemFrom.MagicStore:
		
		global.PossibleItemLists[ItemFrom.MagicStore] = ds_list_create();
		
		ds_list_add(global.PossibleItemLists[ItemFrom.MagicStore],
			ItemClass.Cape,ItemClass.Cape,
			ItemClass.PendantBag,ItemClass.PendantBag,ItemClass.PendantBag,
			ItemClass.Orb,
			ItemClass.Pendant,ItemClass.Pendant,ItemClass.Pendant,ItemClass.Pendant,
			ItemClass.Ring,ItemClass.Ring,ItemClass.Ring,
			ItemClass.Rod,ItemClass.Rod,ItemClass.Rod,ItemClass.Rod
		)
		
	#endregion
	
	#region ItemFrom.FoodStore:
		
		global.PossibleItemLists[ItemFrom.FoodStore] = ds_list_create();
		
		ds_list_add(global.PossibleItemLists[ItemFrom.FoodStore],
			ItemClass.Food,ItemClass.Food,ItemClass.Food,ItemClass.Food,ItemClass.Food,ItemClass.Food,ItemClass.Food,ItemClass.Food,ItemClass.Food,
			ItemClass.FoodBag,ItemClass.FoodBag,ItemClass.FoodBag,
			ItemClass.Potion
		)
		
	#endregion
			
	#region ItemFrom.WishPond:
		
		global.PossibleItemLists[ItemFrom.WishPond] = ds_list_create();
		
		ds_list_add(global.PossibleItemLists[ItemFrom.WishPond],	
			ItemClass.ArrowQuiver, 
			ItemClass.BagSlot,
			ItemClass.BombBag,  
			ItemClass.GemBag,
			ItemClass.FoodBag,
			ItemClass.PendantBag,
			ItemClass.Bow, 
			ItemClass.Boomerang,
			ItemClass.Cape, 
			ItemClass.Gloves,
			ItemClass.Hookshot,
			ItemClass.Lamp,
			ItemClass.Pendant,
			ItemClass.Ring,
			ItemClass.Rod,
			ItemClass.Shield,
			ItemClass.Sword,
			ItemClass.Tunic
		)

	#endregion

	
}

function Item_Name(_ItemClass, _ItemIndex, _Amount = 1){
	
	switch(_ItemClass){

		case ItemClass.ArrowQuiver: return "Arrow Quiver";
		case ItemClass.Arrows: return "Arrows";
		case ItemClass.BagSlot: return "Extra Inventory Slot";
		case ItemClass.BombBag: return "Bomb Bag";
		case ItemClass.GemBag: return "Treasure Bag";
		case ItemClass.FoodBag: return "Food Bag";
		case ItemClass.PendantBag: return "Pendant Bag";
		case ItemClass.Bombs: return "Bombs";
		case ItemClass.Boomerang: return "Boomerang";
		case ItemClass.Bow: 
			switch(_ItemIndex){
				case Bow.Normal:	return "Bow";
				case Bow.Spread:	return "Spread Bow";
			}
			break;
		//case ItemClass.Cane: return "Cane of " + global.CaneNames[_ItemIndex]; break;
		case ItemClass.Cape: return "Magic Cape";
		case ItemClass.Compass: return "Compass";
		case ItemClass.Coupon: return "Coupon";
		case ItemClass.Food: return _ItemIndex == -1 ? "Invalid name" : (_Amount > 1 ? global.FoodNames_Plural[_ItemIndex] : global.FoodNames[_ItemIndex]);
		case ItemClass.Gem: return _ItemIndex == -1 ? "Invalid name" : (global.GemNames[_ItemIndex] + " Gemstone");
		case ItemClass.Gloves:
			switch(_ItemIndex){
				case 0:	return "Leather Gloves";
				case 1:	return "Power Gloves";
				case 2:	return "Super-Duper Gloves";
			}
			break;
		case ItemClass.HeartPiece: return "Heart Container";
		case ItemClass.Hookshot: return "Hookshot";	
		case ItemClass.Key: return "Spare Key";
		case ItemClass.MasterKey: return "Master Key";
		case ItemClass.Kinstone:
			switch(_ItemIndex){
				case 0:	return "Green Kinstone Piece";
				case 1:	return "Blue Kinstone Piece";
				case 2:	return "Red Kinstone Piece";
				case 3:	return "Gold Kinstone Piece";
			}
			break;
		case ItemClass.Lamp: 
			switch(_ItemIndex){
				case 0:	return "Candle";
				case 1:	return "Oil Lamp";
			}
			break;
		case ItemClass.Magic: return "Small Magic Refill";
		case ItemClass.MagicLarge: return "Large Magic Refill";
		case ItemClass.Map: return "Map";
		case ItemClass.MoonPearl: return "Moon Pearl";
		case ItemClass.Orb: return _ItemIndex == -1 ? "Invalid name" : (global.OrbNames[_ItemIndex] + " Orb" + (_Amount > 1 ? "s" : ""));
		case ItemClass.Pendant: return _ItemIndex == -1 ? "Invalid name" : ("Pendant of " + global.PendantNames[_ItemIndex]);
		case ItemClass.Pop: return _ItemIndex == -1 ? "Invalid name" : ("Can" + (_Amount > 1 ? "s" : "") + " of " + global.PopNames[_ItemIndex]);
		case ItemClass.Potion: return _ItemIndex == -1 ? "Invalid name" : global.PotionNames[_ItemIndex];
		case ItemClass.Ring: return _ItemIndex == -1 ? "Invalid name" : ("Ring of " + global.RingNames[_ItemIndex]);
		case ItemClass.Rod: return _ItemIndex == -1 ? "Invalid name" : ("Rod of " + global.RodNames[_ItemIndex]);
		case ItemClass.Shield: return _ItemIndex == -1 ? "Invalid name" : (global.ShieldNames[_ItemIndex] + " Shield");
		case ItemClass.Sword: return _ItemIndex == -1 ? "Invalid name" : (global.SwordName[_ItemIndex] + " Sword");

		case ItemClass.Treasure: return "Treasure Chest";
		case ItemClass.Tunic: return _ItemIndex == -1 ? "Invalid name" : ("Level " + string(_ItemIndex + 1) + " Tunic");
		
		//village items
		case ItemClass.Book: return "The All-Donut Diet Book";
		case ItemClass.Mirror: return "Mirror";
		case ItemClass.Mushroom: return "Mushroom";
		case ItemClass.Powder: return "Magic Powder";
		case ItemClass.Medallion: return "Bombos Medallion";
		case ItemClass.SpecialKey: return "Treasure Room Key";
		case ItemClass.Letter: return "Pezo's Letter";
		case ItemClass.WishStone: return "Wishing Stone";

		
	}	
	
	return "Item Name Unavailable";	
	
}

function Item_Info(_ItemClass, _ItemIndex){
	
	switch(_ItemClass){

		case ItemClass.Arrows: return "Use with a bow to shoot enemies.";
		
		case ItemClass.ArrowQuiver: return "Increases your arrow capacity to " + string(MaxArrowsQuiver) + ". Arrows no longer take up an inventory slot.";
		
		case ItemClass.BombBag: return "Increases your bomb capacity to " + string(MaxBombsBag) + ". Bombs no longer take up an inventory slot.";
		
		case ItemClass.GemBag: return "A separate bag to hold your gems and kinstones.";
		
		case ItemClass.FoodBag: return "A separate bag to hold 3 food items.";
		
		case ItemClass.PendantBag: return "A separate bag to hold 3 pendants.";
		
		case ItemClass.BagSlot: return "Unlocks an extra inventory slot."; 
		
		case ItemClass.Boomerang: return "Stuns enemies, kills small ones, shoots in 8 directions.";

		case ItemClass.Bombs: return "Blow stuff up!";

		case ItemClass.Bow: 
			switch(_ItemIndex){
				case Bow.Normal:	return "Shoots arrows.";
				case Bow.Spread:	return "Shoots 3 arrows at the cost of 1 arrow.";
			}
			break;
			
		case ItemClass.Hookshot: return "Stuns enemies, kills small ones, can pick up items.";
		
		case ItemClass.Map: return "Reveals all unexplored rooms on the dungeon map.";
		
		case ItemClass.Compass: return "Reveals doors and important locations on the dungeon map.";

		case ItemClass.Coupon:
			switch(_ItemIndex){
				case Coupon.Blue:	return "15% off any shop item. Equip to apply.";
				case Coupon.Silver:	return "30% off any shop item. Equip to apply.";
				case Coupon.Gold:	return "50% off any shop item. Equip to apply.";
				case Coupon.Green:	return "Good for 1 free magic refill item at any shop. Equip to apply.";
				case Coupon.Red:	return "Good for 1 free health item at any shop. Equip to apply.";
				case Coupon.Pink:	return "Good for 1 free treasure chest at any shop. Equip to apply.";
			}
			break;
			
		case ItemClass.Ring:
			switch(_ItemIndex){
				case Ring.Health: return "Converts magic from your magic meter into hearts.";
				case Ring.Rupees: return "Converts magic from your magic meter into rupees.";
				case Ring.Bombs:  return "Converts magic from your magic meter into bombs.";
				case Ring.Arrows:  return "Converts magic from your magic meter into arrows.";
			}
			break;
			
		case ItemClass.Rod:
			switch(_ItemIndex){
				case Rod.Stone: return "Shoot a beam that turns enemies into stone. Needs to be charged.";
				case Rod.Ice: return "Shoot a beam that turns enemies into ice. Needs to be charged.";
				case Rod.Fire:  return "Shoot a beam that ignites enemies on fire. Needs to be charged.";
				case Rod.Bomb:  return "Shoot a beam that turns enemies into ignited bombs. Needs to be charged.";
				case Rod.Heart:  return "Shoot a beam that turns enemies into hearts. Needs to be charged.";
				case Rod.Wealth:  return "Shoot a beam that turns enemies into rupees. Needs to be charged.";
			}
			break;
			
		case ItemClass.Cape: return "You are invisible when you wear it. Uses magic.";
		
		case ItemClass.Gem: return "Find one of Zora's ponds to trade gems for items."
		
		case ItemClass.Food: 
			switch(_ItemIndex){
				default:
					var _FoodHearts = FoodHearts(_ItemIndex);
					return "Replenishes " + string(_FoodHearts) + " hearts.";
				case Food.GoldenEgg:
					return "Replenishes all of your health and gives you " + string(GoldenEggRupees) + " rupees."
			}

		case ItemClass.Pop: return "Replenishes " + string(PopHearts) + " hearts.";
			
		case ItemClass.MagicLarge: return "Fills up 50% of your magic meter.";
		
		case ItemClass.HeartPiece: return "Increases your max health by 1.";
		
		case ItemClass.Treasure: return "Contains a random item inside. Could be good, could be bad. Take a risk and find out.";
		
		case ItemClass.Key: return "Spare key to unlock a door.";
		case ItemClass.MasterKey: return "Unlocks all regular locked doors.";
		
		case ItemClass.MoonPearl: return "Colored gates will automatically lower when you walk up to them. No need to activate the crystal switches.";		
			
		case ItemClass.Sword: 
			var _Str = "+" + string(_ItemIndex + 1) + " Attack";
			switch(_ItemIndex){
				case Swords.Steel: _Str += ". Break pots with your sword."; break;
				case Swords.Long: _Str += ". Spin Attack. Hold sword button to charge."; break;
				case Swords.Dragon: _Str += ". Shock resistant."; break;
				case Swords.Blood: _Str += ". Destroy more enemy types."; break;
				case Swords.Master: _Str += ". Shoot a beam when at max health."; break;
				
			}
			return _Str;

		case ItemClass.Tunic: return "+" + string(_ItemIndex) + " Defense";
		case ItemClass.Shield: 
			switch(_ItemIndex){
				case 0: return "+" + string(_ItemIndex + 1) + " Defense. Blocks small projectiles.";
				case 1: return "+" + string(_ItemIndex + 1) + " Defense. Blocks larger projectiles and small fireballs.";
				case 2: return "+" + string(_ItemIndex + 1) + " Defense. Blocks larger projectiles, large fireballs, and magic beams.";
				case 3: return "+" + string(_ItemIndex + 1) + " Defense. Blocks all projectiles, magic beams, and lasers.";
			}
			break;
			
		case ItemClass.Gloves:
			switch(_ItemIndex){
				case 0:	return "+1 Defense";
				case 1:	return "+1 Attack, +1 Defense";
				case 2:	return "+2 Attack, +1 Defense";
			}
			break;
			
		case ItemClass.Kinstone: return "Find the other half of this kinstone and fuse them together."
		case ItemClass.Letter: return "Deliver this to his friend who lives in the rebel village."
		case ItemClass.WishStone: return "Throw this stone into a wishing pond and make a wish."
			
		case ItemClass.Lamp:
			switch(_ItemIndex){
				case 0: return "Helps you see in the dark. You can light torches with the action button."
				case 1:	return "Shines brighter than the candle.";
			}
			break;

		
		case ItemClass.Orb:
			switch(_ItemIndex){
				case Orb.Fire:		return "Break to unleash a fire storm.";
				case Orb.Ice:		return "Break to unleash an ice storm.";
				case Orb.Fairy:		return "Break to reveal 1 or more fairies inside.";
			}			
			break;
		
		case ItemClass.Pendant:
			switch(_ItemIndex){
				case Pendant.Health:	 return "+25% bonus for items that replenish your health.";
				case Pendant.Magic:		 return "Items that use magic will use 25% less."; 
				case Pendant.Protection: return "Protects you against floor spikes and explosion blasts."; 
				case Pendant.Secrets:	 return "You will be alerted when a hidden door is in the room.";
				case Pendant.Direction:	 return "Gives you a permanent map and compass, revealing all dungeon rooms and special locations."; 
				case Pendant.Immunity:	 return "Blocks all curses."; 
				case Pendant.Wealth:	 return "+" + string(round((WEALTHMULTIPLIER - 1) * 100)) + "% bonus added to all collected rupees."; 
				case Pendant.Revival:	 return "You will be revived if you die. You will lose this pendant afterwards."; 
			
			}
			break;
		
		case ItemClass.Potion:
			switch(_ItemIndex){
				case Potion.Health:			return "Restores all your health.";
				case Potion.Magic:			return "Restores all your magic.";
				case Potion.HealthMagic:	return "Restores all your health and magic.";
				case Potion.Antidote:		return "Cancels the effect of curses.";
				case Potion.Milk:			return "Restores " + string(MILKHEARTS) + " hearts.";
			}
			break;

		//village items
		case ItemClass.Book: return "Probably belongs to the library.";
		case ItemClass.Mirror: return "Someone is probably looking for this.";
		case ItemClass.Mushroom: return "Sweet and magical smelling.";
		case ItemClass.Powder: return "Sprinkle it on things, who knows what might happen. Uses magic.";
		case ItemClass.Medallion: return "Wreak havoc! Uses magic.";
		case ItemClass.SpecialKey: return "Key to the King's treasure room!";

		
	}
	
	return "No Info Available";
	
}

function Item_Price(_ItemClass, _ItemIndex, _Amount){
	
	var Price = 20;
	
	switch(_ItemClass){

		case ItemClass.Arrows:
			Price = _Amount / 2;
			break;

		case ItemClass.Bombs:
			Price = _Amount * 3;
			break;

		case ItemClass.Pop:
			Price = _Amount * 8;
			break;
			
		case ItemClass.Orb:
			switch(_ItemIndex){
				case Orb.Fire:
				case Orb.Ice:
					Price = _Amount * 6;
					break;
				
				case Orb.Fairy:
					Price = 35;
					break;
			}
			
			break;

		case ItemClass.Compass:
		case ItemClass.Map:
		case ItemClass.Key:
			Price = irandom_range(10, 20);
			break;

		case ItemClass.Food:
			var _FoodHearts = FoodHearts(_ItemIndex);
			Price = 5 + ((_FoodHearts - 1) * 5);			
			break;

		case ItemClass.Gem:
			Price = 10 + (_ItemIndex * 3);
			break;
		
		case ItemClass.MagicLarge:
			Price = 25;
			break;
		
		case ItemClass.Treasure:
			Price = 30;
			break;

			
		case ItemClass.Kinstone:
			Price = 10 + (_ItemIndex * 10);
			break;

			
		case ItemClass.Potion:
			switch(_ItemIndex){
				case Potion.Milk:
				case Potion.Antidote:
					Price = 40; 
					break;
				case Potion.Magic:
				case Potion.Health:				
					Price = 50; 
					break;
				case Potion.HealthMagic:
					Price = 60; 
					break;
			}
			break;
		
		case ItemClass.Rod:
			switch(_ItemIndex){
				case Rod.Stone: 
					Price = irandom_range(40, 60); 
					break;
					
				case Rod.Bomb: 
				case Rod.Ice: 
				case Rod.Fire:
					Price = irandom_range(60, 80); 
					break;
				
				case Rod.Heart:
				case Rod.Wealth:
					Price = irandom_range(80, 100); 
					break;
			}
			break;
			
		case ItemClass.Sword: 
		case ItemClass.Tunic: 
			Price = irandom_range(30, 50) + (_ItemIndex * 20);
			break;
			
		case ItemClass.Shield: 
			Price = irandom_range(40, 60) + (_ItemIndex * 20);
			break;	
		
		
		case ItemClass.Gloves: 
		case ItemClass.Cane:
			Price = 50 + (_ItemIndex * 25);
			break;
		
		case ItemClass.BagSlot:
		case ItemClass.HeartPiece:
			Price = 50;
			break;
					
		case ItemClass.Lamp: 
			Price = irandom_range(50, 75);
			break;
					
		case ItemClass.Ring:
			switch(_ItemIndex){
				case Ring.Bombs:
				case Ring.Arrows:
					Price = irandom_range(50, 75); 
					break;				
				case Ring.Health:
					Price = irandom_range(70, 90); 
					break;				
				case Ring.Rupees:
					Price = irandom_range(90, 120); 
					break;
			}
			break;
			
		case ItemClass.Pendant:
			switch(_ItemIndex){
				
				case Pendant.Magic: 
				case Pendant.Direction:
				case Pendant.Health:
				case Pendant.Protection:
					Price = irandom_range(80, 100); 
					break;
				
				case Pendant.Wealth:
				case Pendant.Revival:
				case Pendant.Secrets:
				case Pendant.Immunity:
					Price = irandom_range(100, 125); 
					break;
					
			}			
			break;
			
		case ItemClass.ArrowQuiver:
		case ItemClass.BombBag: 		
			Price = irandom_range(60, 85);
			break;
		
		case ItemClass.FoodBag:
		case ItemClass.PendantBag: 		
			Price = irandom_range(75, 100);
			break;
		
		case ItemClass.Bow:
			switch(_ItemIndex){
				default:
					Price = irandom_range(60, 85);
					break;
				case Bow.Spread:
					Price = irandom_range(100, 150);
					break;
			}
			break;

		
		case ItemClass.Cape:
		case ItemClass.GemBag: 
			Price = irandom_range(90, 125);
			break;
			
		case ItemClass.Boomerang:
		case ItemClass.Hookshot:
			Price = irandom_range(100, 150);
			break;

			
		case ItemClass.MoonPearl: 
		case ItemClass.MasterKey: 
			Price = irandom_range(160, 225);
			break;
		
	}
	
	return floor(Price * ChallengeMax_ShopPrices);
	
}

function Item_Price_RoundToNearest(_Price, _Amount){
	return min(round(_Price / _Amount) * _Amount, 999);
}

function Item_Allowed(_ItemClass, _ItemIndex = -1, _From = ItemFrom.Anywhere){
	
	//returns false if that item should not be allowed to be spawned
	//If itemIndex != -1, then it only checks that specific index


	//Limit items from small treasures if their limit count is above 0. 
	//Should be from small treasures since if you start the game, all the good items have a high limit count, so most if not all would be not allowed for large treasure chests and gold kinstone.
	var _IndexesToCheckList, _MaxDefensePointsThatExist, _AttkOrDef;
	if(FromAnySmallTreasure(_From) && global.ItemData[_ItemClass].LimitCount > 0 && !FromAnyKinstone(_From)) return false


	switch(global.ItemData[_ItemClass].Type){

		default:
			
			switch(_ItemClass){
				
				case ItemClass.BagSlot:
					if(Inventory_FindLockedSlot() == -1) return false;
					if(FromAnyStore(_From) && global.Level.ShopBagSlotsCreated > 0) return false
					break;
					
				case ItemClass.HeartPiece:	
					if(global.Inventory.ItemData[ItemClass.HeartPiece].Amount >= ChallengeMax_Hearts) return false;
					if(FromAnyStore(_From) && global.Level.ShopHeartPiecesCreated > 0) return false
					break;
				case ItemClass.Key:
					if(global.Inventory.ItemData[ItemClass.Key].Amount >= MaxKeys) return false;
					if(_From == ItemFrom.Shop && global.Level.ShopKeysCreated > 0) return false
					break;
				case ItemClass.MagicLarge:
					if(_From == ItemFrom.Shop && global.Level.ShopLargeMagicCreated > 0) return false
					break;
				case ItemClass.Arrows:
					if(_From == ItemFrom.Shop && global.Level.ShopArrowsCreated > 0) return false
					break;
				case ItemClass.Bombs:
					if(_From == ItemFrom.Shop && global.Level.ShopBombsCreated > 0) return false
					break;
				case ItemClass.Orb:
					if(_From == ItemFrom.Shop && global.Level.ShopOrbsCreated > 0) return false
					break;
				case ItemClass.Pop:
					if(_From == ItemFrom.Shop && global.Level.ShopPopsCreated > 0) return false
					break;
			
			}
			
			break;
			
			
			
		case ItemType.Inv_Bool:
		case ItemType.Inv_Chrg:

			switch(_ItemClass){
				
				case ItemClass.FoodBag:
					if(global.Challenges[Challenges.NoFood]) return false
					break;
					
				case ItemClass.Map:
				case ItemClass.Compass:
					if(global.Level.RoomsVistedPercent > 0.6 || global.Inventory.ItemData[ItemClass.Pendant].Owns[Pendant.Direction] || global.Challenges[Challenges.NoMap] || global.Level.Index == DungeonLevel.Village || global.Level.Index == DungeonLevel.Mines) return false;
					break;
					
				case ItemClass.Lamp:
					if(global.ChallengeOptions[ChallengeOption.Darkness] == ChallengeOption_Darkness.NoLights || !global.GlobalLighting) return false;
					break;			
			}


			//make a list of indexes to check. If the index is specified, the list will only have that value. If it's -1, then the list will have all indexes
			if(_ItemIndex == -1){
				_IndexesToCheckList = ds_list_create_sequence(0, array_length(global.Inventory.ItemData[_ItemClass].Owns) - 1);
			}else{
				_IndexesToCheckList = ds_list_create();
				ds_list_add(_IndexesToCheckList, _ItemIndex);
			}
			
			var ItemIsAvailable = false;
			var Indexes = ds_list_size(_IndexesToCheckList);
			
			for(var _ListIndex = 0; _ListIndex < Indexes; _ListIndex++){
				
				var _Index = _IndexesToCheckList[| _ListIndex];

				//special cases for specific indexes
				switch(_ItemClass){
					case ItemClass.Pendant:

						switch(_Index){
							case Pendant.Direction:
								if(global.Challenges[Challenges.NoMap]) continue;
								break;
							case Pendant.Secrets:
								if(!FromAnyStore(_From) || global.Level.Index < DungeonLevel.Village) continue; //only allow pendent of secrets in shops and in later levels, too overpowering otherwise
								break;
							case Pendant.Immunity:
								if(global.ChallengeOptions[ChallengeOption.Curses] > 0) continue; //no pendant of immunity for any curse challenge
								break;
						}
						break;
				}
				
				//Check if item doesn't exist and isn't owned 
				
				if(global.Inventory.ItemData[_ItemClass].Owns[_Index]) continue;
				
				if(Item_NonDuplicatableList_Find(_ItemClass, _Index) != -1) continue;
				
				ItemIsAvailable = true;
				break;				
				
			}
			ds_list_destroy(_IndexesToCheckList);
			
			return ItemIsAvailable;
			
		
		case ItemType.Inv_Upg:

			if(global.Inventory.ItemData[_ItemClass].Index == global.Inventory.ItemData[_ItemClass].Index_Max) return false;
			
			//if the upgradeable already exists(on-screen/active) and it's a level higher than what you own, then don't allow.
			var _ItemClassExists = Item_NonDuplicatableList_Find(_ItemClass);
			if(_ItemClassExists != -1 && global.Inventory.ItemData[_ItemClass].Index <= global.NonDuplicatableItemsThatExist[# 1, _ItemClassExists]) return false
			
			switch(_ItemClass){
				
				case ItemClass.Sword:
				
					if(global.Swordless) return false
					
					if(AttackOrDefenseTooHigh(MaxAttackPointsThatExist())) return false;					
					
					break;
			
				case ItemClass.Shield:
				case ItemClass.Tunic:
					
					_MaxDefensePointsThatExist = MaxDefensePointsThatExist();
					
					if(_MaxDefensePointsThatExist >= ChallengeMax_Defense) return false;
					
					if(AttackOrDefenseTooHigh(_MaxDefensePointsThatExist)) return false;
					
					break;
			
				case ItemClass.Gloves:
					
					_MaxDefensePointsThatExist = MaxDefensePointsThatExist();
					
					if(global.Inventory.ItemData[ItemClass.Gloves].Index == -1){
						
						if(_MaxDefensePointsThatExist >= ChallengeMax_Defense) return false;
						
						_AttkOrDef = _MaxDefensePointsThatExist;
						
					}else{
						
						_AttkOrDef = MaxAttackPointsThatExist();
						
					}
					
					if(AttackOrDefenseTooHigh(_AttkOrDef)) return false;
					
					break;
				
				case ItemClass.Bow:
					if(global.Inventory.ItemData[ItemClass.Bow].Index >= 0){
						if(FromAnySmallTreasure(_From) || FromAnyLargeTreasure(_From)) return false
					}
					break;
					
			}
			
			break;
		
		case ItemType.Inv_Stk:
			switch(_ItemClass){
				
				case ItemClass.Food:
				case ItemClass.Pop:
					if(global.Challenges[Challenges.NoFood]) return false;
					break;
			
			}			
			break;

			
	}
	
	
	return true
	
}

function Item_Get(_ItemClass, _ItemIndex = 0, _Amount = 1){
	
	var _GotItem = global.ItemData[_ItemClass].Type == ItemType.Pickup ? Item_Consume(_ItemClass, _ItemIndex, _Amount) : Inventory_Add(_ItemClass, _ItemIndex, _Amount);
	
	return _GotItem;
	
}

function Item_GetDialogue(_ItemClass, _ItemIndex = 0, _Amount = 1){
	
	if(!Item_GetDialogueClass(_ItemClass) || !global.Users[global.UserIndex].Prefs[Pref.ItemMsg]) exit;
	
	var _Suffix = "a ";
	
	switch(_ItemClass){
		case ItemClass.ArrowQuiver:
		case ItemClass.Lamp:
			_Suffix = "an "
			break;
			
		case ItemClass.Orb:
			if(_Amount == 1){
				switch(_ItemIndex){	
					case Orb.Ice:
						_Suffix = "an ";
						break;
				}					
			}else{
				_Suffix = "some ";				
			}
		
			break;
		
		case ItemClass.Pop:
			if(_Amount != 1){
				_Suffix = "";				
			}			
			break;
			
		case ItemClass.Food:
			
			if(_Amount == 1){
				
				switch(_ItemIndex){					
					case Food.Apple: 
					case Food.Avocado: 
					case Food.Egg: 
					case Food.EnergyBar: 
					case Food.IceCreamBar: 
					case Food.Orange: 				
						_Suffix = "an "
						break;
				
					case Food.BaconEggs:
					case Food.Bananas:
					case Food.Blueberries:
					case Food.Broth:
					case Food.Candy:
					case Food.Cheese:
					case Food.Cherries:
					case Food.Chili:
					case Food.ChocolateMilk:
					case Food.Corn:
					case Food.Milk:
					case Food.Nuts:
					case Food.Ramen:
					case Food.Soup:
					case Food.Spaghetti:
					case Food.Sushi:
						_Suffix = "some "
						break;					
				}
				
			}else{
				_Suffix = "some ";				
			}			
			break;
		
		case ItemClass.Gem:
			switch(_ItemIndex){
				case Gem.Amethyst:
				case Gem.Opal:
					_Suffix = "an ";
					break;
			}
			break;
			
		case ItemClass.Potion:
			switch(_ItemIndex){					
				case Potion.Milk: 				
					_Suffix = "some "
					break;
				
				case Potion.Antidote:
					_Suffix = "an "
					break;					
			}			
			break;
			
		case ItemClass.Gloves:
		case ItemClass.Book:
			_Suffix = ""
			break;
		
		case ItemClass.Sword:
			switch(_ItemIndex){
				case Swords.Master:
					_Suffix = "the "
					break;					
			}
			break;
			
		case ItemClass.MasterKey:
		case ItemClass.MoonPearl:
			_Suffix = "the "
			break;
		
	}
	
	MsgBox("You got " + _Suffix + Item_Name(_ItemClass, _ItemIndex, _Amount) + "!^" + Item_Info(_ItemClass, _ItemIndex))
	
}

function Item_GetDialogueClass(_ItemClass){
	
	switch(_ItemClass){
		case ItemClass.Arrows:
		case ItemClass.Bombs:
		case ItemClass.Crystal:
		case ItemClass.Fairy:
		case ItemClass.Heart:
		case ItemClass.HeartPiece:
		case ItemClass.Key:
		case ItemClass.Letter:
		case ItemClass.Magic:
		case ItemClass.Mirror:
		case ItemClass.Mushroom:
		case ItemClass.Powder:
		case ItemClass.Rupee:
		case ItemClass.Medallion:
		case ItemClass.SpecialKey:
		case ItemClass.Star:
		case ItemClass.Stopwatch:
		case ItemClass.Treasure:
		case ItemClass.WishStone:
			return false
	}
	return true
}

function Item_Consume(_ItemClass, _ItemIndex = 0, _Amount = 1){
	
	var ItemConsumed = true;
	
	switch(_ItemClass){
		
		case ItemClass.Rupee: 
			
			var RupeeMultiplier = Pendant_Check(Pendant.Wealth) ? WEALTHMULTIPLIER : 1;
			
			var RupeeAmount = ceil(_Amount * RupeeMultiplier);
			
			Curse_CheckTask(CurseTasks.Collect, ItemClass.Rupee, RupeeAmount);
			
			if(Curse_Check(CurseEffects.RupeesNoValue) && !global.CurseTreasure_Rupees) RupeeAmount = 0;			
			global.CurseTreasure_Rupees = false;
			
			RupeesAdd(RupeeAmount);
					
			global.StatsToAdd[Stat.Rupees] += RupeeAmount;
					
			break; 
					
				
		case ItemClass.Heart: 
			
			Curse_CheckTask(CurseTasks.Collect, ItemClass.Heart);
			
			var _CurseHeartsHurt = Curse_Check(CurseEffects.HeartsReduceHealth);
			
			if(_CurseHeartsHurt && (oLink.Invincible || oLink.State == LinkState.Star)) break;
			
			if(_CurseHeartsHurt){
				HealthAdd(-0.5);
				if(oLink.State == LinkState.Dead) break;
				UpdateState(LinkState.Hit);
				LinkBounceBack(0, 0, 10, false);
			}else{
				HealthAdd(1); 
			}
			break;
		
		case ItemClass.BagSlot:
			AddInventorySlot();
			break;
			
		case ItemClass.HeartPiece:
			Curse_CheckTask(CurseTasks.Collect, ItemClass.HeartPiece);
			HeartPieceAdd(); 
			break;
		
		case ItemClass.Fairy:
			HealthAdd(8); 
			audio_play_sound_stopall(Sound_FairyGet);
			break;
			
		case ItemClass.Arrows: 
			var _Arrows = global.Inventory.ItemData[_ItemClass];
			var _MaxAmount = Inventory_MaxAmount(_ItemClass);
			if(_Amount > 0 && _Arrows.Amount[0] == _MaxAmount) return false
			_Arrows.Amount[0] = min(_Arrows.Amount[0] + _Amount, _MaxAmount);
			break;
			
		//case ItemClass.Bombs: 
		//	var _Bombs = global.Inventory.ItemData[_ItemClass];
		//	var _MaxAmount = Inventory_MaxAmount(_ItemClass);
		//	if(_Amount > 0 && _Bombs.Amount[0] == _MaxAmount) return false
		//	_Bombs.Amount[0] = min(_Bombs.Amount[0] + _Amount, _MaxAmount);
		//	break;
					
		case ItemClass.Key:
			// Inf. Keys cheat
			if (Cheat_On("Cheat_Inf_Keys"))
				break;
			
			var _Keys = global.Inventory.ItemData[ItemClass.Key];
			_Keys.Amount += _Amount;
			if(_Keys.Amount > MaxKeys) _Keys.Amount = MaxKeys;
			if(_Keys.Amount <= 0) _Keys.Amount = 0;
			break;
		
		case ItemClass.SpecialKey:
			Inventory_DeleteItemClass(ItemClass.SpecialKey);
			break;
			
		case ItemClass.Magic:
			MagicAdd(MAGICAMOUNT_BASEUNIT);
			break;

		case ItemClass.MagicLarge:
			MagicAdd(MAGICAMOUNT_HALF);
			break;
			
		case ItemClass.Food:
			HealthAdd(FoodHearts(_ItemIndex));
			if(_ItemIndex == Food.GoldenEgg) Item_Consume(ItemClass.Rupee, 0, GoldenEggRupees);
			break;
			
		case ItemClass.Pop:
			HealthAdd(PopHearts);
			break;

		case ItemClass.Potion:
			switch(_ItemIndex){
				case Potion.Health:
					HealthAdd(ChallengeMax_Hearts);
					break;
				case Potion.Magic:
					MagicAdd(MAGICAMOUNT_MAX);
					break;
				case Potion.HealthMagic:
					HealthAdd(ChallengeMax_Hearts);
					MagicAdd(MAGICAMOUNT_MAX);
					break;
				case Potion.Milk:
					HealthAdd(MILKHEARTS);
					break;
				case Potion.Antidote:					
					MsgBox("Oof, tastes awful! You are now uncursed!",,Sound_Antidote, Curse_Done);
					break;					

			}
			break;

		case ItemClass.Stopwatch:
			with(oEnemy){

				switch(object_index){
					case oEnemy_Wallmaster:
						continue;
				}
				
				if(State == EnemyState.Frozen || State == EnemyState.OnFire) continue;
				
				Enemy_UpdateState(EnemyState.Frozen);
			}
			with(oEnemy_Guru_Bar){
				Enemy_UpdateState(EnemyState.Frozen);
			}
			with(oEnemy_Beamos){
				Beamos_DestroyLaserLights();
			}
			break;
								
		case ItemClass.Star:
			with(oLink) UpdateState(LinkState.Star);
			break;
		
		default:
			ItemConsumed = false;
			break;
			
	}
	
	return ItemConsumed
	
}

function Item_CanConsume(_ItemClass, _ItemIndex){
	
	//returns true if item can be consumed (instead of adding to inventory)
	
	if(_ItemClass == -1) return false;
	
	var CanConsume = false;
	var _HealthItem = false;
	var _MagicItem = false;
	
	switch(_ItemClass){
		
		case ItemClass.Food:
			if(_ItemIndex == Food.GoldenEgg) return true;
		case ItemClass.Pop:
			_HealthItem = true;
			break;
			
		case ItemClass.MagicLarge:
			_MagicItem = true;
			break;
			
		case ItemClass.Potion:			
			switch(_ItemIndex){
				case Potion.Health:
				case Potion.Milk:
					_HealthItem = true;
					break;
				case Potion.Magic:
					_MagicItem = true;
					break;
				case Potion.HealthMagic:
					_HealthItem = true;
					_MagicItem = true;
					break;
				case Potion.Antidote:
					CanConsume = global.Cursed;
					break;
				
			}
			break;
			
	}

	var _InvHealth = global.Inventory.ItemData[ItemClass.Heart];
	var _InvHealthMax = global.Inventory.ItemData[ItemClass.HeartPiece];
	var _InvMagic = global.Inventory.ItemData[ItemClass.Magic];
			
	if(_HealthItem){
		if(_InvHealth.Amount < _InvHealthMax.Amount && !Curse_Check(CurseEffects.HealthNoValue)) CanConsume = true;
	}
	
	if(_MagicItem){
		if(_InvMagic.Amount < MAGICAMOUNT_MAX) CanConsume = true;
	}
	
	return CanConsume;

}
	
function Item_CanUse(_ItemClass, _ItemIndex){
	
	var _InvHealth = global.Inventory.ItemData[ItemClass.Heart];
	var _InvHealthMax = global.Inventory.ItemData[ItemClass.HeartPiece];
	var _InvMagic = global.Inventory.ItemData[ItemClass.Magic];
	
	var _CantAddHealth = (_InvHealth.Amount == _InvHealthMax.Amount || Curse_Check(CurseEffects.HealthNoValue));
	var _CantAddMagic = _InvMagic.Amount == MAGICAMOUNT_MAX;
	
	switch(_ItemClass){
		
		case ItemClass.Coupon:
			return false;
			
		case ItemClass.Food:
		case ItemClass.Pop:
		
			if(_CantAddHealth && !(_ItemClass == ItemClass.Food && _ItemIndex == Food.GoldenEgg)){
				return false;
			}
			break;
		
		case ItemClass.MagicLarge:
			if(_CantAddMagic) return false;
			break;
		
		case ItemClass.Potion:
			switch(_ItemIndex){
				case Potion.Health:	
				case Potion.Milk:	
					if(_CantAddHealth) return false;
					break;
				
				case Potion.Magic:
					if(_CantAddMagic) return false;
					break;
				
				case Potion.HealthMagic:
					if(_CantAddHealth && _CantAddMagic) return false;
					break;
				case Potion.Antidote:
					if(!global.Cursed) return false;
					break;
			}
			break;

		case ItemClass.Ring:			
			switch(_ItemIndex){
				case Ring.Health:
					if(_CantAddHealth) return false;
					break;
				case Ring.Bombs:
					if(global.Inventory.ItemData[ItemClass.Bombs].Amount[0] >= Inventory_MaxAmount(ItemClass.Bombs)) return false
					break;
				case Ring.Arrows:
					if(global.Inventory.ItemData[ItemClass.Arrows].Amount[0] >= Inventory_MaxAmount(ItemClass.Arrows)) return false
					break;				
			}
			break;
		
		case ItemClass.BombBag:
			if(global.Inventory.ItemData[ItemClass.Bombs].Amount[0] == 0) return false
		case ItemClass.Bombs:			
		case ItemClass.Orb:	
		case ItemClass.Gem:
		case ItemClass.WishStone:
			
			if(oLink.InDoor_Facing || oLink.InDoor_BlockItem || oLink.InDoor_House || !oLink.InDoor_Aligned) return false;
			
			//prevents using a pick-up obj from the inventory while carrying one
			if(oLink.ItemHolding != noone){
				return false;
			}
			break;
	
		
	}
	
	return true;
	
}

function ItemSpawn(_ItemClass, _x, _y, _From, _SpawnType, _FloorLevel, _ValidCheck = true){
	
	var _FloorLevelStr = GetFloorLevelString(_FloorLevel);
	
	var Layer;
	switch(_SpawnType){
		
		default: 
			Layer = "ObjsHigher_" + _FloorLevelStr; 
			break;
		
		case ItemSpawnType.DropSky:
		case ItemSpawnType.Float:
			Layer = "ObjsHighest"; break;
			
		case ItemSpawnType.DropInventory:
		case ItemSpawnType.DropScatter: 
		case ItemSpawnType.Appear: 
			Layer = "Objs_" + _FloorLevelStr; 
			break;		
			
	}
	
	var _ObjIndex = ObjIndexFromItemClass(_ItemClass);
	var Inst = instance_create_layer(_x, _y, Layer, _ObjIndex, {From : _From, FloorLevel : _FloorLevel});
	
	if(_ValidCheck){
		if(!Item_Valid(Inst.Class, Inst.Index)){
			instance_destroy(Inst);
			return noone;
		}
	}
		
	Inst.SpawnType = _SpawnType;
	if(_SpawnType != ItemSpawnType.None){
		Inst.Spawning = true;
		Inst.SpawnAnimationInit = true;	
	}


	switch(_SpawnType){
		
		case ItemSpawnType.Float:
			//These are on highest layer which don't get drawn oDepthDrawObjs, so set inst.visible to true
			Inst.visible = true;
			break;
			
		case ItemSpawnType.Appear: 
			Inst.Alpha = 0; //1 frame too late if set in the step init routine, flashes for 1 frame with full alpha
			Inst.Lighting = false;
			break;		
			
	}


	if(FromAnyTreasure(_From)){
		if(Item_IsNonDuplicatableClassType(_ItemClass)) Item_NonDuplicatableList_Add(_ItemClass, Inst.Index);
	}
	
	return Inst;
	
}

function ItemExplosion(_x, _y, _FloorLevel, _ItemFrom, Rupees = 0, Hearts = 0, Magics = 0, ExtraItemClass = -1, ExtraItemSpawnType = ItemSpawnType.DropShort){
	
	if(ExtraItemClass != -1){
		var _ItemInst = ItemSpawn(ExtraItemClass, _x, _y, _ItemFrom, ExtraItemSpawnType, _FloorLevel);
		ItemExplosionInst_CheckWalls(_ItemInst);
	}
	
	
	
	var _RupeeCount = 0; //keep track to only play sound if there's more than 1 rupee item
	
	if(ExtraItemClass == ItemClass.Rupee) _RupeeCount++;
	
	if(Rupees > 0){		
		
		while(Rupees > 0){

			var _ItemInst = ItemSpawn(ItemClass.Rupee, _x, _y, _ItemFrom, ItemSpawnType.DropScatter, _FloorLevel);
			ItemExplosionInst_CheckWalls(_ItemInst);
			if(Rupees >= 20 && Prob(0.4)){
				_ItemInst.Amount = 20;
			}else if(Rupees >= 10 && Prob(0.4)){
				_ItemInst.Amount = 10;
			}else if(Rupees >= 5 && Prob(0.4)){
				_ItemInst.Amount = 5;
			}else{
				_ItemInst.Amount = 1;
			}
			with(_ItemInst){
				Setup = false;
				Rupee_Init(Amount);
			}
			Rupees-=_ItemInst.Amount;
			_RupeeCount++;
		}
		
	}
	
	if(_RupeeCount > 1) audio_play_sound(Sound_RupeeGetRegister, 1, false);	
	
	if(Hearts > 0){
		while(Hearts > 0){	
			var _ItemInst = ItemSpawn(ItemClass.Heart, _x, _y, _ItemFrom, ItemSpawnType.DropScatter, _FloorLevel);
			ItemExplosionInst_CheckWalls(_ItemInst);
			Hearts--;
		}
	}
	
	if(Magics > 0){
		while(Magics > 0){	
			var _ItemInst = ItemSpawn(ItemClass.Magic, _x, _y, _ItemFrom, ItemSpawnType.DropScatter, _FloorLevel);
			ItemExplosionInst_CheckWalls(_ItemInst);
			Magics--;
		}
	}
	
}

function ItemExplosionInst_CheckWalls(_Inst){
	
	//sometimes items from item explosions get stuck in walls if item is larger than enemy, so check for walls and adjust position
	with(_Inst){
		
		var _Buffer = 5;
		
		var _WallInst = instance_place(x - _Buffer, y_base, oWall)
		if(_WallInst != noone){
			if(_WallInst.BlockItems) x += _Buffer;
		}
		_WallInst = instance_place(x + _Buffer, y_base, oWall)
		if(_WallInst != noone){
			if(_WallInst.BlockItems) x -= _Buffer;
		}
		_WallInst = instance_place(x, y_base - _Buffer, oWall)
		if(_WallInst != noone){
			if(_WallInst.BlockItems) ObjSetY(y_base + _Buffer);
		}
		_WallInst = instance_place(x, y_base + _Buffer, oWall)
		if(_WallInst != noone){
			if(_WallInst.BlockItems) ObjSetY(y_base - _Buffer);
		}
	}
}

function ItemDrop(_x, _y, _ItemClass, _ItemIndex, _Amount, _SpawnFrom){
	
	
	var DroppedInst = ItemSpawn(_ItemClass, _x, _y, _SpawnFrom, ItemSpawnType.DropShort, oLink.FloorLevel, false);
	
	switch(_ItemClass){
			
		case ItemClass.Shield:
			//fix shadows here. since upgradeable items have their index increased in the create event, and here it resets it back to the original index after drop, some shadows are the wrong ones.
			//A solution would be to have a function that sets the shadow for any object with any index
			DroppedInst.ShadowSpr = (DroppedInst.Index == 0 ? sShadow_Medium : sShadow_Large);
			break;

	}

	with(DroppedInst){
		
		Item_SetIndex(_ItemIndex)
		layer = layer_get_id("Objs_" + GetFloorLevelString(oLink.FloorLevel));
		Amount = _Amount;
		Setup = false;

	}

	
	if(Item_IsNonDuplicatableClassType(_ItemClass)) Item_NonDuplicatableList_Add(_ItemClass, _ItemIndex);
	
	return DroppedInst;
	
}

function Item_DropPos(){
	
	
	for(var i = 0; i < array_length(global.ItemDropPosTable); i++){
		
		var _x = oLink.x + global.ItemDropPosTable[i][0];
		var _y = oLink.y + global.ItemDropPosTable[i][1];
		
		var _Hole = false;
		if(oLink.FloorLevel == UPPER){
			_Hole = (tilemap_get_at_pixel(global.TMID_Floor_Upper, _x, _y) == 0);
		}else{
			_Hole = (tilemap_get_at_pixel(global.TMID_Floor_Lower, _x, _y) == 0);
		}
		if(_Hole) continue;
		
		if(instance_position(_x, _y - 6, oWall) == noone && instance_position(_x, _y - 6, oItem) == noone) return [_x, _y]
	}

	return [oLink.x, oLink.y]
	
}

function Item_OverHole(){
	
	return (tilemap_get_at_pixel(global.TMID_Floor_Lower, ObjCenterX(), ObjCenterY()) == 0);
}

function Item_FallInHole(){

	instance_create_layer(ObjCenterX(), ObjCenterY(), "ObjsHigher_Upper", oSparkle);
	audio_play_sound_stopall(Sound_Fall);
	instance_destroy(id);
	
}

function Item_CheckPondWater(){
		
	if(z >= 1) return false

	var PondInst = noone;
	with(oGemPondWater){
		if(point_in_rectangle(other.x, other.y, x, y, X2, Y2)){	
			PondInst = instance_position(x, y, id);
			break;
		}
	}
			
	if(PondInst != noone){
				
		instance_create_layer(x, y, "Objs_" + FloorLevelStr, oWaterSplash, {PalIndex : (PondInst.GID == TemplateObjGID.WishPond ? 1 : 0)});
				
		switch(object_index){
			case oGem:
				PondInst.GemsInWater[Index]++;
				if(PondInst.GID == TemplateObjGID.GemPond && GemsInPond(PondInst) >= 2){
					instance_create_layer(PondInst.x + (PondInst.W / 2), PondInst.y + (PondInst.H / 2), "Objs_" + FloorLevelStr, oZora, {GemCombo : GetGemCombo(PondInst)});
				}
				break;
			case oWishStone:
				if(PondInst.GID == TemplateObjGID.WishPond){// && !PondInst.WishStone){
					instance_create_layer(PondInst.x + (PondInst.W / 2), PondInst.y + (PondInst.H / 2), "System", oFairy_Queen, {RoomIndex});
					with(oLink) UpdateState(LinkState.Idle);
					global.Paused = true;
					//PondInst.WishStone = true;
				}
				break;
		}
		instance_destroy(id);
		return true;
	}
	
	return false;
	
}

function Item_CheckWater(){
	
	if(z > 2){
		InWater = false;
		exit;
	}
	
	var _InWater = OnWaterTile(FloorLevel == UPPER ? global.TMID_Water_Upper : global.TMID_Water_Lower, x, y_base);
	
	if(InWater && !_InWater){
		InWater = false;
	}else if(!InWater && _InWater){
		InWater = true;
		if(oCamera.InView(x, y_base) && !instance_exists(oInventory)){
			audio_play_sound_stopall(Sound_Water_Walk);
		}
	}

}

function Item_CheckFloorLevelSwitch(){
	
	if(z <= 13 && FloorLevel == UPPER){
		
		var _FloorLevelBase = GetFloorLevelID(x, y_base);
		var _FloorLevelCentre = GetFloorLevelID(ObjCenterX(), ObjCenterY());
		
		if(_FloorLevelBase == _FloorLevelCentre){ //item base could be on lower floor while centre is on Upper causing item to go under upper floor partially, so only switch if both points are on the same floor level
			FloorLevel = GetFloorLevelID(x, y_base);
			FloorLevelStr = GetFloorLevelString(FloorLevel)
			layer = layer_get_id("Objs_" + FloorLevelStr);
		}
	}
	
}

function HealthAdd(Amount, Checks = true){
	if (Cheat_On("Cheat_Inf_Health")) {
		Amount = 0;
	}
	
	if(Checks && Amount > 0 && !global.CurseTreasure_HeartPiece){	
		if(Curse_Check(CurseEffects.HealthNoValue)) return 0;
		if(Pendant_Check(Pendant.Health)) Amount *= 1.25;
		if(Curse_Check(CurseEffects.HealthDrain)) oLink.alarm[3] = global.CurseHealthDrainDelay;
	}
	global.CurseTreasure_HeartPiece = false;
	
	var OriginalAmount = Amount; //Before modifying it, remember the original amount since will add to oHUD only if the original amount is higher than 1
	
	var _Health = global.Inventory.ItemData[ItemClass.Heart];
	var _HealthMax = global.Inventory.ItemData[ItemClass.HeartPiece];
	
	if(_Health.Amount + Amount > _HealthMax.Amount) Amount = _HealthMax.Amount - _Health.Amount; //make Amount the exact amount that will be added to HUD
	
	_Health.Amount = max(0, _Health.Amount + Amount);	
	
	if(OriginalAmount > 1) oHUD.AddHealth = Amount;	

	if(LinkHealth <= 0){
		with(oLink){
			UpdateState(LinkState.Dead);
		}
	}
			
	return Amount;
}

function HealthCheckSound(){
	
	if(global.FadeIn) exit; //so when continuing game from save, the sound doesn't start immediately, it waits for the fade to end
	
	if(instance_exists(oMenu_Game)) exit;
	
	if(global.Paused) exit;
	
	if(global.GameBeaten) exit;
	
	if(LinkHealth < min(4 - global.ChallengeOptions[ChallengeOption.StartingHearts], 2)){
		if(oLink.State != LinkState.Dead && LinkHealth > 0 && oLink.State != LinkState.Idle){
			if(!audio_is_playing(oLink.LowHealthSound)){
				oLink.LowHealthSound = audio_play_sound(Sound_LowHealth, 1, false);
				oHUD.HealthLowPulseDir = 1;
			}
		}
	}
	
}

function MagicAdd(Amount){
	if (Cheat_On("Cheat_Inf_Magic")){
		if (Amount < 0)
			exit;
	}

	if(Curse_Check(CurseEffects.MagicNoValue)) exit;
	
	var _Magic = global.Inventory.ItemData[ItemClass.Magic];
	if(_Magic.Amount + Amount > MAGICAMOUNT_MAX) Amount = MAGICAMOUNT_MAX - _Magic.Amount; //make Amount the exact amount that will be added to HUD
	
	_Magic.Amount += Amount;
	
	oHUD.AddMagic += Amount;

}

function MagicUse(Amount){

	if(Pendant_Check(Pendant.Magic)) Amount *= 0.75;
	if(Curse_Check(CurseEffects.MagicUsesDouble)) Amount *= 2;	
	
	var _Magic = global.Inventory.ItemData[ItemClass.Magic];
	if(Amount > _Magic.Amount) return 0;
	
	// Inf. Magic cheat
	// The item still works, but won't cost anything
	if(!Cheat_On("Cheat_Inf_Magic")) _Magic.Amount -= Amount;
	return Amount;
		
}

/// Every rupee gain or loss goes through here.
/// @param {Real} _Amount Amount of rupees to gain or lose.
/// @param {Bool} _Roll If true, the HUD counts the total towards the change (pickups, shops). Otherwise, the total changes at once (arcade bets, theft).
function RupeesAdd(_Amount, _Roll = true){
	
	// Inf. Rupees cheat
	// Whatever was bought/won/lost still happens, but the total doesn't move
	if(Cheat_On("Cheat_Inf_Rupees")){
		global.Inventory.ItemData[ItemClass.Rupee].Amount = CHEAT_INF_RUPEES;
		return;
	}
	
	if(_Roll){
		oHUD.AddRupees += _Amount;
	}else{
		var _Rupees = global.Inventory.ItemData[ItemClass.Rupee];
		_Rupees.Amount = max(_Rupees.Amount + _Amount, 0);
	}
	
}

function HeartPieceAdd(){
	
	var _HealthMax = global.Inventory.ItemData[ItemClass.HeartPiece];
	
	_HealthMax.Amount++;
	if(_HealthMax.Amount >= ChallengeMax_Hearts){
		_HealthMax.Amount = ChallengeMax_Hearts;
	}
	
	HealthAdd(_HealthMax.Amount);
	
}

function AddInventorySlot(){
	
	var _SlotIndex = Inventory_FindLockedSlot();
	
	if(_SlotIndex != -1) global.Inventory.Bags[InventoryBag.Main].Slots[_SlotIndex].Locked = false;

}

function Item_PickAvailableIndex(_ItemClass, _From = ItemFrom.Anywhere){
	
	//for objects that have different indexes and can have only 1 of each(pendants, rods, etc),
	//this figures out the available items left from the owns array, then returns a random one from that list
	
	var AvailableItems = ds_list_create();
	var ItemCount = array_length(global.Inventory.ItemData[_ItemClass].Owns);
	var _Index = -1;
	
	for(var _ItemIndex = 0; _ItemIndex < ItemCount; _ItemIndex++){
		
		if(!Item_Allowed(_ItemClass, _ItemIndex, _From)) continue;

		ds_list_add(AvailableItems, _ItemIndex);		
		
	}
	
	if(ds_list_size(AvailableItems) > 0){
		ds_list_shuffle(AvailableItems);
		_Index = AvailableItems[| 0];
	}
		
	ds_list_destroy(AvailableItems);
	
	return _Index

}

function Probs_RandomItemClass(_From){
	
	var _ChosenItem = ItemClass.Food; //fail-safe
	
	var _ItemList = ds_list_create();
	ds_list_copy(_ItemList, global.PossibleItemLists[_From]);
	
	ds_list_shuffle(_ItemList);
	
	while(ds_list_size(_ItemList) > 0){
		
		var _ListItem = _ItemList[| 0];
		
		if(Item_Allowed(_ListItem, -1, _From)){
			_ChosenItem = _ListItem;
			break;
		}else{
			ds_list_finddelete_all(_ItemList, _ListItem)
		}
		
	}
	
	ds_list_destroy(_ItemList);
	
	return _ChosenItem;
	
}

function Probs_RandomItemClass_Pot(Force, SimpleItems = true){
	
	var _ItemClass = -1;
	if(Force || Prob(Chance_PotHasItem)){
		_ItemClass = Probs_RandomItemClass((SimpleItems || global.Level.Index == DungeonLevel.Village) ? ItemFrom.PotSimple : ItemFrom.Pot);
	}

	if(global.Cursed){
		if(global.CurseTask == CurseTasks.Collect && global.CurseTaskItem == ItemClass.Heart){
			if(_ItemClass != ItemClass.Heart){
				if(Prob(Chance_CurseExtraChance_Heart)){
					_ItemClass = ItemClass.Heart;
				}
			}
		}
	}
	
	
	return _ItemClass
}

function Item_IsNonDuplicatableClassType(_ItemClass){
	return global.ItemData[_ItemClass].Type == ItemType.Inv_Bool || global.ItemData[_ItemClass].Type == ItemType.Inv_Upg || global.ItemData[_ItemClass].Type == ItemType.Inv_Chrg;
}

function Item_NonDuplicatableList_Add(_ItemClass, _ItemIndex){
		
	var GridH = ds_grid_height(global.NonDuplicatableItemsThatExist);	

	ds_grid_resize(global.NonDuplicatableItemsThatExist, 2, GridH + 1);
	ds_grid_add(global.NonDuplicatableItemsThatExist, 0, GridH, _ItemClass);
	ds_grid_add(global.NonDuplicatableItemsThatExist, 1, GridH, _ItemIndex);		
	
	
}

function Item_NonDuplicatableList_Remove(_ItemClass, _ItemIndex){

	//find if item is in list, if so remove it
	var ItemRow = Item_NonDuplicatableList_Find(_ItemClass, _ItemIndex);
	if(ItemRow != -1) ds_grid_delete_row(global.NonDuplicatableItemsThatExist, ItemRow);
	
}

function Item_NonDuplicatableList_Find(_ItemClass, _ItemIndex = -1){
	
	//return row # if Obj/Index is in NonDuplicatableList
	
	var GridH = ds_grid_height(global.NonDuplicatableItemsThatExist);
		
	for(var i = 0; i < GridH; i++){
		if(_ItemIndex == -1){
			//if itemindex not specified, just look for objindex
			if(_ItemClass == global.NonDuplicatableItemsThatExist[# 0, i]) return i;
		}else{
			if(_ItemClass == global.NonDuplicatableItemsThatExist[# 0, i] && _ItemIndex == global.NonDuplicatableItemsThatExist[# 1, i]) return i;
		}
	}
	
	return -1;
	
}

function Item_SetIndex(_NewIndex){
	Index = _NewIndex;
	image_index = Index;
}

function TreasureLimiter_Reset(){	

	for(var _ItemClass = 0; _ItemClass < ItemClasses; _ItemClass++){
		global.ItemData[_ItemClass].LimitCount = TreasureLimiter_NewLimitCount(global.ItemData[_ItemClass].LimitStart);
	}

}

function TreasureLimiter_Update(_ItemClass, _DecreaseAll = true){	
	
	//decrease any limit counts
	if(_DecreaseAll){
		for(var i = 0; i < ItemClasses; i++){
			global.ItemData[i].LimitCount = max(--global.ItemData[i].LimitCount, 0);
		}
	}
	
	//Pick a new limit count for chosen object index
	if(global.ItemData[_ItemClass].LimitMin > 0) global.ItemData[_ItemClass].LimitCount = TreasureLimiter_NewLimitCount(global.ItemData[_ItemClass].LimitMin);
	
}

function TreasureLimiter_NewLimitCount(_Min){
	return floor(_Min * random_range(1, 2.5));
}

function FromAnyTreasure(_From){	
	return FromAnyTreasureChest(_From) || _From == ItemFrom.WishPond || _From == ItemFrom.Zora
}

function FromAnySmallTreasure(_From){	
	return _From == ItemFrom.Treasure || _From == ItemFrom.KinstoneGreen || _From == ItemFrom.KinstoneBlue || _From == ItemFrom.KinstoneRed
}

function FromAnyLargeTreasure(_From){	
	return _From == ItemFrom.LargeTreasure || _From == ItemFrom.KinstoneGold
}

function FromAnyTreasureChest(_From){
	return FromAnySmallTreasure(_From) || FromAnyLargeTreasure(_From)
}

function FromAnyStore(_From){
	return (_From == ItemFrom.Shop || _From == ItemFrom.TreasureStore || _From == ItemFrom.WeaponStore || _From == ItemFrom.MagicStore || _From == ItemFrom.FoodStore)
}

function FromAnyKinstone(_From){
	return (_From == ItemFrom.KinstoneGreen || _From == ItemFrom.KinstoneBlue || _From == ItemFrom.KinstoneRed || _From == ItemFrom.KinstoneGold)
}

function Item_HealthBonusStr(_OriginalAmount){//, _AddNextLine = true){
	//returns a string that says how many bonus hearts you get because of the pendant of health. Used in Item Info dialogues
	var BonusAmount = _OriginalAmount * 0.25;
	return Pendant_Check(Pendant.Health) ? " (+" + string_format(BonusAmount, 1, frac(BonusAmount) != 0 ? 1 : 0) + " bonus)" : "";
}

function ItemClassFromObjIndex(_ObjIndex){
	//returns the item ID based on the object index
	
	switch(_ObjIndex){
		case oItem_ArrowQuiver: return ItemClass.ArrowQuiver;
		case oItem_Arrows: return ItemClass.Arrows;		   
		case oItem_BagSlot: return ItemClass.BagSlot;
		case oItem_BombBag: return ItemClass.BombBag;
		case oItem_GemBag: return ItemClass.GemBag;
		case oItem_FoodBag: return ItemClass.FoodBag;
		case oItem_PendantBag: return ItemClass.PendantBag;
		case oItem_Bombs: return ItemClass.Bombs;
		case oItem_Boomerang: return ItemClass.Boomerang;
		case oItem_Bow: return ItemClass.Bow;
		case oItem_Cane: return ItemClass.Cane;
		case oItem_Cape: return ItemClass.Cape;
		case oItem_Compass: return ItemClass.Compass;
		case oItem_Coupon: return ItemClass.Coupon;
		case oItem_Crystal: return ItemClass.Crystal;
		case oItem_Fairy: return ItemClass.Fairy;
		case oItem_Food: return ItemClass.Food;
		case oItem_Gem: return ItemClass.Gem;
		case oItem_Gloves: return ItemClass.Gloves;
		case oItem_Heart: return ItemClass.Heart;
		case oItem_HeartPiece: return ItemClass.HeartPiece;
		case oItem_Hookshot: return ItemClass.Hookshot;
		case oItem_Key: return ItemClass.Key;
		case oItem_Key_Master: return ItemClass.MasterKey;
		case oItem_Kinstone: return ItemClass.Kinstone;
		case oItem_Lamp: return ItemClass.Lamp;
		case oItem_Magic: return ItemClass.Magic;
		case oItem_Magic_Large: return ItemClass.MagicLarge;
		case oItem_Map: return ItemClass.Map;
		case oItem_MoonPearl: return ItemClass.MoonPearl;
		case oItem_Orb: return ItemClass.Orb;
		case oItem_Pendant: return ItemClass.Pendant;
		case oItem_Pop: return ItemClass.Pop;
		case oItem_Potion: return ItemClass.Potion;
		case oItem_Ring: return ItemClass.Ring;
		case oItem_Rod: return ItemClass.Rod;
		case oItem_Rupee: return ItemClass.Rupee;
		case oItem_Shield: return ItemClass.Shield;
		case oItem_Star: return ItemClass.Star;
		case oItem_Stopwatch: return ItemClass.Stopwatch;
		case oItem_Sword: return ItemClass.Sword;
		case oItem_Treasure: return ItemClass.Treasure;
		case oItem_Tunic: return ItemClass.Tunic;
		
		//village items
		case oItem_Book: return ItemClass.Book;
		case oItem_Mirror: return ItemClass.Mirror;
		case oItem_Mushroom: return ItemClass.Mushroom;
		case oItem_Powder: return ItemClass.Powder;
		case oItem_Medallion: return ItemClass.Medallion;
		case oItem_Key_Special: return ItemClass.SpecialKey;
		case oItem_Letter: return ItemClass.Letter;
		case oItem_WishStone: return ItemClass.WishStone;
	}
	
	return -1;
	
}

function ObjIndexFromItemClass(_ItemClass){
	//returns the item ID based on the object index
	
	switch(_ItemClass){
		case ItemClass.ArrowQuiver: return oItem_ArrowQuiver;
		case ItemClass.Arrows: return oItem_Arrows;
		case ItemClass.BagSlot: return oItem_BagSlot;
		case ItemClass.BombBag: return oItem_BombBag;
		case ItemClass.GemBag: return oItem_GemBag;
		case ItemClass.FoodBag: return oItem_FoodBag;
		case ItemClass.PendantBag: return oItem_PendantBag;
		case ItemClass.Bombs: return oItem_Bombs;
		case ItemClass.Boomerang: return oItem_Boomerang;
		case ItemClass.Bow: return oItem_Bow;
		case ItemClass.Cane: return oItem_Cane;
		case ItemClass.Cape: return oItem_Cape;
		case ItemClass.Compass: return oItem_Compass;
		case ItemClass.Coupon: return oItem_Coupon;
		case ItemClass.Crystal: return oItem_Crystal;
		case ItemClass.Fairy: return oItem_Fairy;
		case ItemClass.Food: return oItem_Food;
		case ItemClass.Gem: return oItem_Gem;
		case ItemClass.Gloves: return oItem_Gloves;
		case ItemClass.Heart: return oItem_Heart;
		case ItemClass.HeartPiece: return oItem_HeartPiece;
		case ItemClass.Hookshot: return oItem_Hookshot;
		case ItemClass.Key: return oItem_Key;
		case ItemClass.MasterKey: return oItem_Key_Master;
		case ItemClass.Kinstone: return oItem_Kinstone;
		case ItemClass.Lamp: return oItem_Lamp;
		case ItemClass.Magic: return oItem_Magic;
		case ItemClass.MagicLarge: return oItem_Magic_Large;
		case ItemClass.Map: return oItem_Map;
		case ItemClass.MoonPearl: return oItem_MoonPearl;
		case ItemClass.Orb: return oItem_Orb;
		case ItemClass.Pendant: return oItem_Pendant;
		case ItemClass.Pop: return oItem_Pop;
		case ItemClass.Potion: return oItem_Potion;
		case ItemClass.Ring: return oItem_Ring;
		case ItemClass.Rod: return oItem_Rod;
		case ItemClass.Rupee: return oItem_Rupee;
		case ItemClass.Shield: return oItem_Shield;
		case ItemClass.Star: return oItem_Star;
		case ItemClass.Stopwatch: return oItem_Stopwatch;
		case ItemClass.Sword: return oItem_Sword;
		case ItemClass.Treasure: return oItem_Treasure;
		case ItemClass.Tunic: return oItem_Tunic;
		
		//village items
		case ItemClass.Book: return oItem_Book;
		case ItemClass.Mirror: return oItem_Mirror;
		case ItemClass.Mushroom: return oItem_Mushroom;
		case ItemClass.Powder: return oItem_Powder;
		case ItemClass.Medallion: return oItem_Medallion;
		case ItemClass.SpecialKey: return oItem_Key_Special;
		case ItemClass.Letter: return oItem_Letter;		
		case ItemClass.WishStone: return oItem_WishStone;		
	}
	
	return -1;
	
}

function ObjFromItem(_ObjIndex){
	switch(_ObjIndex){
		case oItem_Orb: return oOrb
		case oItem_Gem: return oGem
		case oItem_Bombs: return oBomb
		case oItem_WishStone: return oWishStone
	}
	return noone
}
	
function ItemFromObj(_ObjIndex){
	switch(_ObjIndex){
		case oOrb: return oItem_Orb
		case oGem: return oItem_Gem
		case oBomb: return oItem_Bombs
		case oWishStone: return oItem_WishStone
	}
	return noone
}

function ItemClassToInventoryBag(_ItemClass){
	
	switch(_ItemClass){
		case ItemClass.FoodBag: return InventoryBag.Food;
		case ItemClass.BombBag: return InventoryBag.Bombs;
		case ItemClass.PendantBag: return InventoryBag.Pendants;
		case ItemClass.GemBag: return InventoryBag.Gems;
		
	}
	
	return -1
	
}

function Item_AmountOffsetX(_ItemClass){
	
	switch(_ItemClass){
		
		case ItemClass.Rupee:
			return 0;
			
		case ItemClass.Arrows:
		case ItemClass.Pop:
		case ItemClass.MagicLarge:
		case ItemClass.Orb:
			return 1;

		default: 
			return 2;

	}
}

function Item_Valid(_ItemClass, _ItemIndex){
	
	
	switch(_ItemClass){
		case ItemClass.Food:
		case ItemClass.Gem:
		case ItemClass.Gloves:
		case ItemClass.Kinstone:
		case ItemClass.Orb:
		case ItemClass.Pendant:
		case ItemClass.Pop:
		case ItemClass.Potion:
		case ItemClass.Ring:
		case ItemClass.Rod:
		case ItemClass.Shield:
		case ItemClass.Sword:
		case ItemClass.Tunic:
			if(_ItemIndex == -1) return false
		
	}
	
	return true
	
}