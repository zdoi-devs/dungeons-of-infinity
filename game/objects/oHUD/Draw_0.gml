
if(global.Level.Index == DungeonLevel.Start){
	MainAlpha = 1 - oIntro.DarkScreenAlpha;
}


draw_set_color(c_white);
draw_set_alpha(MainAlpha);

if(ShowLevelName){
	draw_set_halign(fa_center);
	draw_set_font(global.Font_Blue);
	draw_set_alpha(ShowLevelName_Alpha);
	draw_text(oCamera.X + 128, oCamera.Y + 100, global.DungeonNames[global.Level.Index]);
	draw_set_alpha(1);
}


draw_set_halign(fa_left);
draw_set_font(global.FontNumbers);


if(!global.Users[global.UserIndex].Prefs[Pref.HUD]) exit;

	
draw_sprite_ext(sHUD_Life, 0, MainSide + 15, 3, 1, 1, 0, HealthLowPulseColor, 1);
	
//draw empty containers first
var _HeartIndex;
for(_HeartIndex = 0; _HeartIndex < global.Inventory.ItemData[ItemClass.HeartPiece].Amount; _HeartIndex++){
	draw_sprite_ext(sHUD_Heart, 0, HeartsX[_HeartIndex], HeartsY[_HeartIndex], 1, 1, 0, HealthLowPulseColor, 1);	
}
	
var _HealthToDraw = max(LinkHealth - AddHealth, 0);
	
//full hearts
var _FullHearts = floor(_HealthToDraw);
for(_HeartIndex = 0; _HeartIndex < _FullHearts; _HeartIndex++){
	draw_sprite_ext(sHUD_Heart, 4, HeartsX[_HeartIndex], HeartsY[_HeartIndex], 1, 1, 0, HealthLowPulseColor, 1);
}
	
//last heart piece
_HealthToDraw -= _FullHearts;
if(_HealthToDraw > 0){
	var _HeartValue = (_HealthToDraw < 0.25 ? 1 : clamp(floor(_HealthToDraw * 4), 0, 3));
	draw_sprite_ext(sHUD_Heart, _HeartValue, HeartsX[_HeartIndex], HeartsY[_HeartIndex], 1, 1, 0, HealthLowPulseColor, 1);
}


//Magic Meter

draw_sprite(sHUD_Magic, 0, MainSide + 2, 31);
draw_sprite_stretched(sHUD_MagicMeterLiquid, 0, MMX, MMY, MagicW, 6);

//Items

draw_sprite(sHUD_Items, 0, MainSide + 4, 52);
	
if(Inventory_ItemIsEquiped){

	if(Inventory_EquipedItem != -1){

		var _ItemClass = Inventory_EquipedItem.ItemClass;
	
		var _ObjIndex = ObjIndexFromItemClass(_ItemClass);
		
		if(_ObjIndex != -1){
			var SprInd = object_get_sprite(_ObjIndex);
		
			var ItemInd = Inventory_EquipedItem.ItemIndex;	
			Offset = Inventory_GetPosOffset(SprInd, ItemInd);
		
			var _x = ItemX + Offset[0] + 3;
			var _y = ItemY + Offset[1] + 2;
		
			draw_sprite(SprInd, ItemInd, _x, _y);

			var _ItemAmount = Inventory_EquipedItem.Amount;
			var _DrawAmount = global.ItemData[_ItemClass].Type == ItemType.Inv_Chrg || _ItemAmount > 1;
	
			if(_DrawAmount){
				draw_set_font(global.Font_ItemValues);
				draw_set_halign(fa_right);
				draw_text(ItemX + 19, ItemY + 12, string(_ItemAmount));
				draw_set_halign(fa_left);
			}
		}
	}
	
}


draw_set_font(global.FontNumbers);
	
//Keys
if(global.Inventory.ItemData[ItemClass.MasterKey].Owns[0])
	draw_sprite(sHUD_Infinite, 0, KeysX, KeysY + 1);
else
	draw_text(KeysX, KeysY, string(global.Inventory.ItemData[ItemClass.Key].Amount));
	
//Rupees
//draw_sprite(sHUD_Icon_Rupees, 0, RupeesX, RupeesY);
draw_text(RupeesX, RupeesY, RupeesStr);

//Attack / Defense 
draw_set_color(AttackColor);
draw_text(oHUD.AttackX, oHUD.AttackY, string(oLink.AttackPoints));
draw_set_color(DefenseColor);
draw_text(oHUD.DefenseX, oHUD.DefenseY, string(oLink.DefensePoints));
	
//Arrows
draw_set_color(ArrowsColor);
draw_text(ArrowsX, ArrowsY, ScoreText(global.Inventory.ItemData[ItemClass.Arrows].Amount[0], 2));
		
//Bombs
draw_set_color(BombsColor);
draw_text(BombsX, BombsY, ScoreText(global.Inventory.ItemData[ItemClass.Bombs].Amount[0], 2));
	


draw_set_color(c_white);



draw_sprite(sHUD_Side1, 0, MainSide + 3, 92);
draw_sprite(sHUD_Side2, 0, MapSide + 2, 2);


//1st row

//Sword
draw_sprite(sHUD_Sword, global.Inventory.ItemData[ItemClass.Sword].Index + 1, SwordX, SwordY);	

//Tunic
draw_sprite(sHUD_Tunic, max(global.Inventory.ItemData[ItemClass.Tunic].Index, 0), TunicX, TunicY);	

//Shield
draw_sprite(sHUD_Shield, global.Inventory.ItemData[ItemClass.Shield].Index + 1, ShieldX, ShieldY);	

//2nd row	

	
//Map
draw_sprite(sHUD_Map, DrawMap ? 1 : 0, MapItemX, MapItemY);

//Compass
draw_sprite(sHUD_Compass, DrawCompass ? 1 : 0, CompassX, CompassY);

//Gloves
draw_sprite(sHUD_Gloves, global.Inventory.ItemData[ItemClass.Gloves].Index + 1, GlovesX, GlovesY);	

//3rd row

//Moon Pearl
draw_sprite(sHUD_MoonPearl, global.Inventory.ItemData[ItemClass.MoonPearl].Owns[0] ? (global.Level.SwitchBlock_ActiveColor + 1) : 0, MoonPearlX, MoonPearlY);

//Master Key
draw_sprite(sHUD_MasterKey, global.Inventory.ItemData[ItemClass.MasterKey].Owns[0] ? 1 : 0, MasterKeyX, MasterKeyY);	
	
//Lamp
draw_sprite(sHUD_Lamp, global.Inventory.ItemData[ItemClass.Lamp].Index + 1, LampX, LampY);

	
//Pendents
for(var i = 0; i < PendantCount; i++)
	draw_sprite((global.Inventory.ItemData[ItemClass.Pendant].Owns[i] ? sHUD_Pendents : sHUD_Pendents_Grey), i, oHUD.PendantsX[i], oHUD.PendantsY[i]);


//Crystals
if !global.Speedrun{
	for(var i = 0; i < 3; i++){
		draw_sprite(sHUD_Crystal, ShowCrystals && i <= oHUD.BossesDefeated - 1 ? 1 : 0, CrystalsX[i], CrystalsY);
	}
}
//Speedrun Timer
else{
	draw_set_font(global.MenuFont);
	draw_set_halign(fa_left);
	draw_text(TimerX, TimerY, Time_Str(Time_PlayingTotal()));
}

//Dungeon Icons
	
for(var i = oHUD.BossesDefeated; i < 3; i++){
	draw_sprite(sHUD_DungeonIcons, 0, oHUD.DungeonIconsX, oHUD.DungeonIconsY[i]);
}
	
draw_sprite(sHUD_DungeonIcons, 1, oHUD.DungeonIconsX, oHUD.DungeonIconsY[3]); //Village
draw_sprite(sHUD_DungeonIcons, 2, oHUD.DungeonIconsX, oHUD.DungeonIconsY[4]); //Mines
//Saves
for(var i = 5; i <= 9; i++){
	draw_sprite(sHUD_DungeonIcons, 3, oHUD.DungeonIconsX_Save, oHUD.DungeonIconsY[i]);
}

//Dungeon Link
draw_sprite(global.LinkSpr_DungeonIcon, 0, DungeonLinkX, DungeonLinkY);

//small map
if(!global.MapHidden){
	
	if(DrawMap) draw_sprite_ext(global.Level.Map_Sprite_All, 0, SmallMapX, SmallMapY, 0.25, 0.25, 0, c_white, MainAlpha);
	
	draw_sprite_ext(global.Level.Map_Sprite_Explored, 0, SmallMapX, SmallMapY, 0.25, 0.25, 0, c_white, MainAlpha);
	
	if(DrawCompass){
		draw_sprite_ext(global.Level.Map_Sprite_Doors_Explored, 0, SmallMapX, SmallMapY, 0.25, 0.25, 0, c_white, MainAlpha);
		if(DrawMap) draw_sprite_ext(global.Level.Map_Sprite_Doors_All, 0, SmallMapX, SmallMapY, 0.25, 0.25, 0, c_white, MainAlpha);
	}

	//Small map Link
	draw_sprite(sLinkMap, 0, SmallMapX + Map_GetCoordinate_Small(oLink.House_Inside ? oLink.House_OldX : oLink.x) - 0.5, SmallMapY + Map_GetCoordinate_Small(oLink.House_Inside ? oLink.House_OldY :oLink.y) - 0.5);
	
}

draw_set_alpha(1);

with(oAghanim_End){
	
	if(Exiting){
		draw_set_alpha(ExitFade);
		draw_set_color(0);
		draw_rectangle(oHUD.HUD_Left, 0, 0, CAM_H, false);
	}

	draw_set_alpha(1);
	draw_set_color(#FFFFFF);
}