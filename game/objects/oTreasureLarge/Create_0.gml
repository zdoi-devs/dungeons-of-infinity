FloorLevel = GetFloorLevelID(x, y);

ContentsObj = RandomItem;

visible = true;

WallInst = WallObj_Create(layer, x, y, 4, 3);
WallInst.FloorLevel = FloorLevel;
