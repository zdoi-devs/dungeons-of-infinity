if(instance_exists(ErrorMsgInst)) exit;

draw_set_halign(fa_left);

var _y = 0;
//draw_text(8, _y, "CHX: " + string(NameEntryCross_X)); _y+=12;
//draw_text(8, _y, "CHY: " + string(NameEntryCross_Y)); _y+=12;
//draw_text(8, _y, "GridX: " + string(NameEntryCross_GridX)); _y+=12;
//draw_text(8, _y, "GridY: " + string(NameEntryCross_GridY)); _y+=12;
//draw_text(8, _y, "Letter: " + LetterGrid_GetLetter()); _y+=12;


var _MainTitle = Menu_Title[MenuWin_Main_MenuIndex]
var _OptionsTitle = Menu_Title[MenuWin_Options_MenuIndex];

//Draw Main menu

draw_set_font(MenuWin_Main_Active ? global.MenuFont : global.MenuFont_Innactive);

var _MainChanged = Menu_HasChanges(MenuWin_Main_MenuIndex);
if(_MainChanged) _MainTitle += " (unsaved)";
for(var i = 0; i < Menu_Count[MenuWin_Main_MenuIndex]; i++){
	if(!Menu_IsRowVisible(MenuWin_Main_MenuIndex, i)) continue;
	var _Row = Menu[MenuWin_Main_MenuIndex][i];
	var _RowY = Menu_RowY(MenuWin_Main_MenuIndex, i);
	draw_text(MenuWinInst_Main.x + 32, _RowY, Menu_RowLabel(_Row, _MainChanged));
	if(_Row.OnDraw != undefined) _Row.OnDraw(_Row, MenuWinInst_Main.x, _RowY);
}
Menu_DrawScrollArrows(MenuWin_Main_MenuIndex, MenuWinInst_Main.x + MenuWinInst_Main.W - 16, MENU_TOP_Y, MenuWinInst_Main.y + MenuWinInst_Main.H - 22);
		

//Draw Options menu

draw_set_font(global.MenuFont);


var PosX, PosY;
if(MenuWinInst_Options.visible){
	
	switch(MenuWin_Options_MenuIndex){
		
		// Pages built from rows: label, then the row's value/slider and any extra icons it draws
		default:
			var _Page = MenuWin_Options_MenuIndex;
			var _WinX = MenuWinInst_Options.x;
			var _Changed = Menu_HasChanges(_Page);
			if(_Changed) _OptionsTitle += " (unsaved)";

			var _Msg = Menu_Config[_Page][$ "Message"];
			if(_Msg != undefined){
				Menu_DrawMessage(_Msg, _WinX + 16, MENU_TOP_Y, MenuWinInst_Options.W - 32);
				draw_set_font(global.MenuFont);
			}

			for(var i = 0; i < Menu_Count[_Page]; i++){
				if(!Menu_IsRowVisible(_Page, i)) continue;
				var _Row = Menu[_Page][i];
				var _RowY = Menu_RowY(_Page, i);
				
				var _Label = Menu_RowLabel(_Row, _Changed);
				draw_set_font(Menu_Font[_Page]);
				draw_text(_WinX + 32, _RowY + Menu_TextOffsetY[_Page], _Label);
				var _LabelRight = _WinX + 32 + string_width(_Label);
				draw_set_font(global.MenuFont);
				
				if(Menu_RowHasValue(_Row)) Menu_DrawRowValue(_Row, _LabelRight, _WinX + MenuWinInst_Options.W - 16, _RowY);
				if(_Row.OnDraw != undefined) _Row.OnDraw(_Row, _WinX, _RowY);
			}
			Menu_DrawScrollArrows(_Page, _WinX + MenuWinInst_Options.W - 16, MENU_TOP_Y, MenuWinInst_Options.y + MenuWinInst_Options.H - 22);
			
			var _Selected = Menu_Count[_Page] > 0 ? Menu[_Page][Selector_Index_Options] : undefined;
			if(_Selected != undefined && _Selected.Title != undefined) _OptionsTitle = _Selected.Title(_Selected);
			break;
		
		case MenuIndex.NewUser:
			
			//letters
			draw_set_halign(fa_center);
			draw_set_valign(fa_center);
			var Chr = 0;
			for(_y = 0; _y < global.LetterGridRows; _y++){
				
				if(_y == global.LetterGridRows - 1){
					draw_set_halign(fa_left);
					draw_set_valign(fa_left);
				}
				
				for(var _x = 0; _x < global.LetterGridColumns; _x++){
					var Letter = global.NewUserChrMap[Chr];
					PosX = LetterGridX + (_x * global.LetterGridSpacingW) + (_y < global.LetterGridRows - 1 ? 3 : 0);
					PosY = LetterGridY + (_y * global.LetterGridSpacingH) + (_y < global.LetterGridRows - 1 ? 8 : 0);
					switch(Letter){
						case "!": draw_text(PosX, PosY, "Ok"); break;
						case "@": draw_text(PosX, PosY, ""); break;
						case "#": draw_text(PosX, PosY, "Back"); break;
						case "$": draw_text(PosX, PosY, ""); break;
						default:  draw_text(PosX, PosY, Letter); break;
					}
					Chr++;
				}
			
			}
		
			//crosshair
			LetterGrid_DrawCrossHair_H();
			LetterGrid_DrawCrossHair_V();			
			
			break;
		
		case MenuIndex.Character:
			for(var i = 0; i < LinkCharacters; i++){
				PosX = MenuWinInst_Options.x + 24 + ((i mod 3) * 42);
				PosY = MenuWinInst_Options.y + 21 + ((i div 3) * 48);
				//if(i < 2)	
					draw_sprite(global.CharacterSprites, i, PosX, PosY);
				//else 
				//	draw_sprite_ext(global.CharacterSprites, i, PosX, PosY, 1, 1, 0, c_black, 1);
				if(i == global.LinkCharacterIndex) draw_sprite(sCharacterSelector, 0, PosX - 3, PosY - 2);
			}
			
			break;
			
		case MenuIndex.Stats:
			
			draw_set_halign(fa_right);
			
			PosX = MenuWinInst_Options.x + 112;
			PosY = MenuWinInst_Options.y + 14;
			var Stats = global.Users[global.UserIndex].Stats;
			
			draw_text(PosX, PosY, "Games Played:"); PosY+=16;
			draw_text(PosX, PosY, "Games Won:"); PosY+=16;
			draw_text(PosX, PosY, "Best Time:"); PosY+=16;
			draw_text(PosX, PosY, "Deaths:"); PosY+=16;
			draw_text(PosX, PosY, "Monsters Killed:"); PosY+=16;
			draw_text(PosX, PosY, "Rupees Collected:"); PosY+=16;
			draw_text(PosX, PosY, "Treasures Opened:"); PosY+=16;
			
			draw_set_halign(fa_left);
			PosX = MenuWinInst_Options.x + 116;
			PosY = MenuWinInst_Options.y + 14;
			draw_text(PosX, PosY, string(Stats[Stat.GamesPlayed])); PosY+=16;
			draw_text(PosX, PosY, string(Stats[Stat.GamesWon])); PosY+=16;
			draw_text(PosX, PosY, Stats[Stat.BestTime] == 0 ? "0" : Time_Str(Stats[Stat.BestTime])); PosY+=16;
			draw_text(PosX, PosY, string(Stats[Stat.Deaths])); PosY+=16;
			draw_text(PosX, PosY, string(Stats[Stat.Monsters])); PosY+=16;
			draw_text(PosX, PosY, string(Stats[Stat.Rupees])); PosY+=16;
			draw_text(PosX, PosY, string(Stats[Stat.Treasures])); PosY+=16;
			draw_text(PosX, PosY, Stats[Stat.PersonalBestSplits] == 0 ? "0" : Stats[Stat.PersonalBestSplits]); PosY+=16;
			break;
			
	}
	
	
	//extra drawing stuff. If menu has to be drawn, plus other things need to be drawn too
	switch(MenuWin_Options_MenuIndex){
	
		case MenuIndex.Controls_Gamepad:

			draw_set_halign(fa_right);
			
			PosX = MenuWinInst_Options.x + 136;
			PosY = MenuWinInst_Options.y + 14;

			draw_text(PosX, PosY, "Sword:"); PosY+=16;
			draw_text(PosX, PosY, "Action:"); PosY+=16;
			draw_text(PosX, PosY, "Item:"); PosY+=16;
			draw_text(PosX, PosY, "Map:"); PosY+=16;
			draw_text(PosX, PosY, "Strafe:"); PosY+=16;
			draw_text(PosX, PosY, "Inventory:"); PosY+=16;
			draw_text(PosX, PosY, "Menu:"); PosY+=16;
			draw_text(PosX, PosY, "HUD:"); PosY+=16;
			
			
			draw_set_halign(fa_left);
			PosX = MenuWinInst_Options.x + 140;
			PosY = MenuWinInst_Options.y + 14;
				
			for(var i = 0; i < global.BindingIconCount[Input_Index.Gamepad]; i++){

				if(Bindings_Remap){
					_OptionsTitle = "Backspace to skip";
					if(i == global.BindingRemap_VerbIndex)
						draw_rectangle(PosX, PosY, PosX + 36, PosY + 15, false);	
					else draw_text(PosX, PosY, global.BindingIcons[Input_Index.Gamepad][i]);
				}else draw_text(PosX, PosY, global.BindingIcons[Input_Index.Gamepad][i]); 
					
				PosY+=16;
			}

			break;
			
		case MenuIndex.Controls_Keyboard:
		
			draw_set_halign(fa_right);
			draw_set_font(global.Font_Small);
			
			PosX = MenuWinInst_Options.x + 136;
			PosY = MenuWinInst_Options.y + 22;
			var _TextSep = 9;
			
			draw_text(PosX, PosY, "UP:"); PosY+=_TextSep;
			draw_text(PosX, PosY, "DOWN:"); PosY+=_TextSep;
			draw_text(PosX, PosY, "LEFT:"); PosY+=_TextSep;
			draw_text(PosX, PosY, "RIGHT:"); PosY+=_TextSep;
			draw_text(PosX, PosY, "SWORD:"); PosY+=_TextSep;
			draw_text(PosX, PosY, "ACTION:"); PosY+=_TextSep;
			draw_text(PosX, PosY, "ITEM:"); PosY+=_TextSep;
			draw_text(PosX, PosY, "MAP:"); PosY+=_TextSep;
			draw_text(PosX, PosY, "STRAFE:"); PosY+=_TextSep;
			draw_text(PosX, PosY, "INVENTORY:"); PosY+=_TextSep;
			draw_text(PosX, PosY, "MENU:"); PosY+=_TextSep;
			draw_text(PosX, PosY, "HUD:"); PosY+=_TextSep;
			

			draw_set_halign(fa_left);
			PosX = MenuWinInst_Options.x + 140;
			PosY = MenuWinInst_Options.y + 22;
				
			for(var i = 0; i < global.BindingIconCount[Input_Index.Keyboard]; i++){
				
				var BindingIcon = string_upper(global.BindingIcons[Input_Index.Keyboard][i]);
				BindingIcon = string_replace(BindingIcon, "empty", "");
				
				if(Bindings_Remap){
					_OptionsTitle = "Backspace to skip";
					if(i == global.BindingRemap_VerbIndex)
						draw_rectangle(PosX, PosY, PosX + 36, PosY + 5, false);	
					else draw_text(PosX, PosY, BindingIcon);
				}else draw_text(PosX, PosY, BindingIcon); 
					
				PosY+=_TextSep;
				
			}

			break;
		
	}
}




if(Menu_Selector[MenuWin_Main_MenuIndex]) draw_sprite(MenuWin_Main_Active ? sMenu_Selector_Active : sMenu_Selector_Innactive, Selector_Frame, MenuWinInst_Main.x + 12, Menu_RowY(MenuWin_Main_MenuIndex, Selector_Index_Main));
if(Menu_Active && MenuWin_Options_Active && Menu_Selector[MenuWin_Options_MenuIndex]) draw_sprite(sMenu_Selector_Active, Selector_Frame, MenuWinInst_Options.x + 12, Menu_RowY(MenuWin_Options_MenuIndex, Selector_Index_Options));

draw_set_halign(fa_center);
draw_set_font(MenuWin_Main_Active ? global.MenuFont : global.MenuFont_Innactive);
draw_text(MenuWinInst_Title1.x + (MenuWinInst_Title1.W / 2), MenuWinInst_Title1.y + 8.5, _MainTitle);

draw_set_font(global.MenuFont);
if(MenuWinInst_Title2.visible) draw_text(MenuWinInst_Title2.x + (MenuWinInst_Title2.W / 2), MenuWinInst_Title2.y + 8.5, _OptionsTitle);

//draw_set_halign(fa_left);
//draw_text(0, 0, string(global.BindingRemap_InputIndex));