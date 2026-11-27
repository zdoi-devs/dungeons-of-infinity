RoomIndex = Dungeon_GetRoomIndex(x, y);

FloorLevel = GetFloorLevelID(x, y);

LightIndex = Lighting_CreateLight(RoomIndex, x, y, 1.0, [0.8, 0.8, 0.8]);

SparkleX = x;
SparkleY = y;
SparkleVX = 0;
SparkleVY = 0;
SparkleV = 0.5;

SparkleDelay = 4;
alarm[0] = SparkleDelay;

AddStart = false;
Add = false;

End = false;
DestroyDelay = 85;
FlashDelay = 1;

WaitForSoundEnd = false;

DB_Init = false;
DB_Started = false;


#region DialogueBox
	
	Dialogues = "I will sooth your wounds and comfort your weariness...Close your eyes and relax...";	
	
	DB_Script = ds_grid_create(3, 2); var i = 0;
	
var	Addr=0; DB_Script[# 0, Addr] = DBScriptCode.Dialogue	DB_Script[# ++i, Addr] = Dialogues;	DB_Script[# ++i, Addr] = 1;	i = 0;
	Addr=1; DB_Script[# 0, Addr] = DBScriptCode.End;		DB_Script[# ++i, Addr] = 0; i = 0;
	

#endregion