draw_set_alpha(BlackoutFade);
draw_set_color(0);
draw_rectangle(oCamera.X, oCamera.Y, oCamera.X2, oCamera.Y2, false);

draw_set_alpha(1);
draw_set_color(#FFFFFF);

if(EndGraphics){

	var _LinkX = oCamera.X + oCamera.W_2 - 1;
	var _LinkY = oCamera.Y + oCamera.H_2 - 1;
	draw_sprite(global.LinkSpr_HoldingItem2, 0, _LinkX, _LinkY);
	draw_sprite(sTriforce, 0, _LinkX, _LinkY - 19);
	
	draw_set_font(global.MenuFont);
	draw_set_halign(fa_center);
	var _x = oCamera.X + 128;
	var _y = oCamera.Y + 24;
	draw_text(_x, _y, "Thanks Link, you're"); _y+=16;
	draw_text(_x, _y, "the hero of Hyrule."); _y+=80;
	
	draw_text(_x, _y, "Finally,"); _y+=16;
	draw_text(_x, _y, "peace returns to Hyrule."); _y+=16;
	draw_text(_x, _y, "The End."); _y+=32; 

	draw_text(_x, _y, "Total time: " + Time_Str(global.Time_PlayingTotal)); 
	if global.Speedrun{
		_y+=32;
		draw_text(_x, _y, "Run performed on version " + VERSION); 
	}
	global.PersonalBestSplits = array_push(global.PersonalBestSplits, Time_PlayingTotal())

	draw_set_alpha(EndGraphicsFade);
	draw_set_color(0);
	draw_rectangle(oCamera.X, oCamera.Y, oCamera.X2, oCamera.Y2, false);
	
}

if(Exiting){
	draw_set_alpha(ExitFade);
	draw_set_color(0);
	draw_rectangle(oCamera.X, oCamera.Y, oCamera.X2, oCamera.Y2, false);
}

draw_set_alpha(1);
draw_set_color(#FFFFFF);