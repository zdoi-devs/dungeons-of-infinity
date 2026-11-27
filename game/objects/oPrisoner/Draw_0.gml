PixelRender_Dim(true, true, false, noone, 0, false, []);

switch(Index){
	
	case Prisoner.WetBandits:
		draw_sprite(sShadow_Large, 0, x - 8, y - 1);
		draw_sprite(sShadow_Large, 0, x + 7, y - 1);
		Dir = 1;
		break;
		
	default:
		draw_sprite(sShadow_Large, 0, x, y - 1);
		break;
}

draw_sprite_ext(sprite_index, image_index, x, y, Dir, 1, 0, c_white, 1);

shader_reset();

