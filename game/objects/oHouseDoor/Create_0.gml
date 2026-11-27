FloorLevel = GetFloorLevelID(x, y);
Location = "Top";
PassageOrientation = TOP_BOTTOM;


PassageArea = array_create(4, 0);  //This will hold the 4 coordinates of the passageway
PassageArea[0] = x - 4;
PassageArea[1] = y - 40;
PassageArea[2] = x + 20;
PassageArea[3] = y - 2;	


House_RoomIndex = 0; //which Room index the door will take you to
House_X = 0;
House_Y = 0;

WallInst = WallObj_Create("Objs_" + GetFloorLevelString(FloorLevel), x, y, 2, 2);
WallInst.FloorLevel = FloorLevel;
WallInst.BlockLink = false;