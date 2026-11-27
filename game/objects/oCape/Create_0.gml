instance_create_layer(oLink.x, oLink.y - 8, "ObjsHighest", oPoof_NoSound);
audio_play_sound(Sound_Cape_On, 1, false);
oLink.Cape = true;
MagicDelay = 30;
alarm[0] = 1;
