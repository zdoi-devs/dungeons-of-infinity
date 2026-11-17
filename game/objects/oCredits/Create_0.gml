TileW = 32;
TileH = 22;

BoxW = TileW * 8;
BoxH = TileH * 8;


x = (camera_get_view_width(view_camera[0]) - BoxW) / 2;
y = 24;

Alpha = 0;
AlphaSpeed = 0.02;

Open = true;
Close = false;
Destroy = false;

TextSurfaceW = (BoxW - 10) * 4;
TextSurfaceH = (BoxH - 10) * 4;
TextSurface = surface_create(TextSurfaceW, TextSurfaceH);
TextSurfaceX = (x * 4) + 20;
TextSurfaceY = (y * 4) + 20;

TextX = TextSurfaceW / 2;
TextY = TextSurfaceH;

TextSpeed = 1.25;

TextArray = [];
array_push(TextArray, "Credits");

repeat(2) array_push(TextArray, "");	
array_push(TextArray, "Original Game:");
array_push(TextArray, "The Legend of Zelda: A Link to the Past");
array_push(TextArray, "Created by Nintendo 1991");
array_push(TextArray, "Hiroshi Yamauchi, Shigeru Miyamoto,");	
array_push(TextArray, "Takashi Tezuka, Koji Kondo, and more...");	

repeat(2) array_push(TextArray, "");
array_push(TextArray, "The Legend of Zelda: Dungeons of Infinity");	
array_push(TextArray, "Design, Programming, Dialogue:");	
array_push(TextArray, "Justin Bohemier");	

repeat(2) array_push(TextArray, "");
array_push(TextArray, "Original Art and Sounds:");
array_push(TextArray, "Nintendo");

repeat(2) array_push(TextArray, "");
array_push(TextArray, "Manual by:");
array_push(TextArray, "Calico Stonewolf");

repeat(1) array_push(TextArray, "");
array_push(TextArray, "Additional Assets:");
array_push(TextArray, "ALTTP Randomizer Community");
array_push(TextArray, "Justin Bohemier");
array_push(TextArray, "Riley O'Neail");
array_push(TextArray, "Errors");
array_push(TextArray, "Triston Tracy");
array_push(TextArray, "Glasus");
array_push(TextArray, "Castle");
array_push(TextArray, "Void42");
array_push(TextArray, "DJvenom");
array_push(TextArray, "ChaosMiles07");
array_push(TextArray, "IvyIvee");
array_push(TextArray, "Jamie Brownhill");
array_push(TextArray, "MalibuDarby");
array_push(TextArray, "Sascha Naderer");
array_push(TextArray, "Valenberg");
array_push(TextArray, "Havi Averilla Xavier");
array_push(TextArray, "Cheyenne Lysohirka");
array_push(TextArray, "Kyrise");
array_push(TextArray, "Deon");
array_push(TextArray, "Derekfcc");



repeat(1) array_push(TextArray, "");
array_push(TextArray, "Created Using:");
array_push(TextArray, "Gamemaker Studio 2");
array_push(TextArray, "Tiled Editor by Thorbjorn Lindeijer");

repeat(1) array_push(TextArray, "");
array_push(TextArray, "Additional Libraries:");
array_push(TextArray, "Input by Juju Adams & Alynne Keith");
array_push(TextArray, "Xzip by XGASoft");

repeat(2) array_push(TextArray, "");
array_push(TextArray, "Special Thanks to:");
array_push(TextArray, "Discord Staff & Community");
array_push(TextArray, "Riley O'Neail");
array_push(TextArray, "Shallow");
array_push(TextArray, "Nikose");
array_push(TextArray, "Triston Tracy");
array_push(TextArray, "Castle");
array_push(TextArray, "Errors");
array_push(TextArray, "Void42");
array_push(TextArray, "Charade");
array_push(TextArray, "Murder Who");
array_push(TextArray, "Xeonon");
array_push(TextArray, "Kim09");
array_push(TextArray, "TacoPete");
array_push(TextArray, "MATrethewey");
array_push(TextArray, "Mothula");
array_push(TextArray, "Lostflake");
array_push(TextArray, "ToDeleteAGeek");
array_push(TextArray, "Haru Zulux");
array_push(TextArray, "Brody Nekwinda");
array_push(TextArray, "Cheyenne Lysohirka");
array_push(TextArray, "Stephane Normandeau");
array_push(TextArray, "Dan Joseph");

repeat(3) array_push(TextArray, "");
array_push(TextArray, "This has been an incredible journey,");
array_push(TextArray, "thank you very much for playing!");

repeat(1) array_push(TextArray, "");
array_push(TextArray, "Justin Bohemier 2024");
array_push(TextArray, "discord.gg/2FY2G63VXa ");

TextArrayLen = array_length(TextArray);

TextArrayH = TextArrayLen * 64;
TextYMax = -TextArrayH + 480;

layer_set_visible(layer_get_id("Sparkles"), false);
layer_set_visible(layer_get_id("Instances"), false);

FX_BW = fx_create("_filter_greyscale");
fx_set_parameter(FX_BW, "g_Intensity", 0);
layer_set_fx("Effect_Contrast", FX_BW);

Music = noone;
MusicFadeTime = (((1 / AlphaSpeed) / 60) * 1000) + 200;