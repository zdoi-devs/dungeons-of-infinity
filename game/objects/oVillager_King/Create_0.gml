event_inherited();

RoomIndex = Dungeon_GetRoomIndex(x, y);

LightIndex = Lighting_CreateLight(RoomIndex, x + 16, y + 16, 1.0, [0.8, 0.8, 0.8]);
Lighting_UpdateLight_RGB(RoomIndex, LightIndex, [0.0, 0.0, 0.0]);

layer = layer_get_id("Objs_Upper");
FloorLevel = UPPERLOWER;

ItemHolding = ItemClass.SpecialKey;

HoverFrame = 0;
HoverY = 0;

Alpha = 0;
AwakeInit = false;
Reveal = false;
Revealed = false;
Sleep = false;
SleepDone = false;
DialogueSkipOnce = false;
DialogueIgnore =  true;



