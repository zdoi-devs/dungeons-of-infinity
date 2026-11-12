visible = false; //visible set to false so DepthDrawObjs can sort and draw everything manually

Link_LoadCharacterIndex();

global.CurrentSplits = [];

keyUp = false;
keyDown = false;
keyLeft = false;
keyRight = false;
Action[ActionKey.Up] = false;
Action[ActionKey.Down] = false;
Action[ActionKey.Left] = false;
Action[ActionKey.Right] = false;
Action[ActionKey.Sword] = false;
Action[ActionKey.Interact] = false;
Action[ActionKey.Item] = false;
Action[ActionKey.Jump] = false;
Action[ActionKey.Strafe] = false;

DescendingPhase = 0;
DescendingLocation = NONE;

EnterDungeonSplits = [];
MoveAssist = false;
MoveAssistDir = NONE;
MoveAssistWallInst = noone;

InitNewDungeon = false;

vx = 0;
vy = 0;

Facing = UP;
FacingLock = Facing;

WalkSpeed = 1.5;
RunSpeed = 2.0
CarryingSpeed = 1.25;
MoveAssistSpeed = 1;
StairSpeed = 0.5;
StairsAutoMove = false;
StairsFloorLevelDir = NONE;

RoomIndex = 0;

AutoMoveFrames = 0; //How many frames to count down. Once at 0, normal control takes over. Set at -1 for infinite frames(will count down never reaching 0)
AutoMoveSpeed = 0;
AutoMoveDirX = 0;
AutoMoveDirY = 0;

PushingWall = false;
PushingDirX = 0;
PushingDirY = 0;

SwordCharge = 0;
SwordChargeSpeed = 0.02;
SwordChargePlaySound = true;
SwordChargeAllowed = true; //don't allow it if sword hit an enemy first

CollidedObjList = ds_list_create();
CollidedWallList = ds_list_create();
CollidedShopItemList = ds_list_create();

FloorLevel = 1;
FloorLevelStr = "Upper";

House_Entering = false;
House_Inside = false;
House_Leaving = false;
House_RoomIndex = 0;
House_OldRoomIndex = 0;
House_X = 0;
House_Y = 0;
House_OldX = 0;
House_OldY = 0;
House_DoorInst = noone;

Castle_Entering = false;
Castle_EntranceWallInst = noone; //the wall that prevents Link from going back outside. If he collides with it(trying to go back out), the display message
AllowCastleEntranceWallCollide = true;

Warp_Engage = false;
Warp_RoomIndex_From = 0;
Warp_RoomIndex_To = 0;


HitBox = instance_create_layer(x, y, "ObjsHigher_Upper", oLink_HitBox);

Invincible = false;
HitFlashingStatus = false;
HitFlashingDelay = 3;
HitFlashingLength = 80;
HitSoundDelay = 3;


StarActive = false;
UncurseAfterStar = false;

ShockEnemyX = 0;
ShockEnemyY = 0;
ShockEnemyAttack = 0;

ShockDrawSword = false;

AttackPoints = 1;
DefensePoints = 0;

ShieldDir = DOWN;
Shield_InitData();

BowSprite = sBow;
BowArrow = Bow.Normal;

Lighting = false;

LampLightMaxR = 0.6; LampLightMaxG = 0.6; LampLightMaxB = 0.6;

LampLightR = LampLightMaxR; LampLightG = LampLightMaxG; LampLightB = LampLightMaxB;
LampStrength[0] = 0;
LampStrength[1] = 1.4;
LampStrength[2] = 2.2;
LampStrength[3] = 3.0; //used for star

LampFlickerDist = 0;
LampFlickerDir = 1;
LampFlickerMaxLen = 0.18;
LampMaxFlickerLen = random_range(0.01, LampFlickerMaxLen);

LampDim = 1;
LampDimMin = 0;

LightArrayIndex[0] = 0; //Link's index will always be 0 in the LightArray

ShopItemLook = noone;
AllowFairy = true;

ItemHolding = noone;

HoldBossCrystal = false;

Cape = false;

AghanimTakingItems = false;

InventoryFullInst = noone;

StandingOnMap = false;
StandingOnCompass = false;

LowHealthSound = noone;

LastDoorID = noone;

GoingThruClosedDoor = false;
GoingThruClosedDoorID = noone;

DoorPassage = array_create(4, 0);
InDoorPassage = 0;
PassageOrientation = TOP_BOTTOM;

InDoor = false; //touching the door would trigger true
InDoor_Full = false; //only true when his full body is in the door
InDoor_Facing = false;
InDoor_BlockItem = false;
InDoor_Aligned = true;
InDoor_House = false;

InWater = false;

StarColors = [KB_R, KB_In, KB_G, KB_Br, KB_B, KB_In, KB_Gr, KB_Br];
StarColorIndex = 0;
StarColorDelay = 6;
StarSparkleDist = 16;
StarLightColors = [[1.25,0.65,0.65], [1.25,1.25,0.65], [0.65,1.25,0.65], [1.25,1.25,0.65], [0.65,0.65,1.25], [1.25,1.25,0.65]];
StarLightIndex = 0;
StarTimer = 500;

FallSpawnX = 0;
FallSpawnY = 0;
FallSpawnFloorLevel = UPPER;
FallSpawnFacing = UP;

BounceBack = false;

global.Cursed = false;

Link_SetStartingItems();

UpdateState(LinkState.Standing);
