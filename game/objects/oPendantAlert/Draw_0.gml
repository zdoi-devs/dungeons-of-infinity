draw_set_font(global.Font_Small);
draw_set_halign(fa_left);

var Rw = string_width(Str) + 25;
var Rh = 20;
var Rx = oCamera.X + ((CAM_W - Rw) / 2);
var Ry = oCamera.Y + 70;

draw_set_alpha(Alpha / 2);
draw_set_color(c_dkgray);
draw_rectangle(Rx, Ry, Rx + Rw - 1, Ry + Rh - 1, false);

draw_set_alpha(Alpha);
draw_set_color(c_white);
draw_sprite(sprite_index, image_index, Rx + 10, Ry + 18);
draw_text(Rx + 21, Ry + 8, Str);

draw_set_alpha(1);