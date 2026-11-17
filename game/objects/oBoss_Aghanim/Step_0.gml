// Feather disable GM2064
event_inherited();

Lighting_UpdateLight_Radius(RoomIndex, LightIndex, LightRadius[irandom(4)]);

if(Intro){
	
	PauseCheck
	
	if(IntroMsg1){
		if(!instance_exists(oDialogueBox)){
			with(oLink){
				UpdateState(LinkState.Idle);
			}
			TakeItems = true;
			alarm[7] = 30;
			IntroMsg1 = false;
		}
	}
	
	if(TakeItems){
		
		if(TakeItems_ShowBag && !TakeItems_ShowShield){
			TakeItems_BagPosY -= TakeItems_BagV;
			TakeItems_BagV += TakeItems_BagA;
			if(TakeItems_BagPosY < y + 12){
				TakeItems_BagPosY = y + 12;
				TakeItems_BagV = 0;
				TakeItems_BagA = 0;
				audio_play_sound(Sound_AghanimCharge, 1, false);
				alarm[8] = 100;
				TakeItems_ShowShield = true;
				Lighting_UpdateLight_Pos(RoomIndex, LightIndex, x, y + 4);
				Lighting_UpdateLight_Visible(RoomIndex, LightIndex, true);
			}
			
		}
		
	}
	
	if(IntroMsg2){
		
		if(!instance_exists(oDialogueBox)){
			Intro = false;
			
			with(oLink){
				UpdateState(LinkState.Standing);
			}
			Lighting_UpdateLight_Visible(RoomIndex, LightIndex_Body, false);
		}
		
	}
	exit;
	
}

if(Hit_Started){
	image_index = 0;
}

if(KnockBackDone){

	Enemy_UpdateState(EnemyState.Idle);
	alarm[0] = -1;
	alarm[2] = -1;
	
	ScriptIndex = ScriptIndexBombMove;
	
	ScriptNext = true;	

	
}

if(Energy <= 4){
	KnockBackEnabled = false;
	Hit_Sound = Sound_Boss_Destroy;
}
	
if(State != EnemyState.Killed && Energy <= 0){
	
	global.Time_PlayingTotalEnd = Time_PlayingTotal();
	array_push(global.CurrentSplits, global.Time_PlayingTotalEnd)
	global.GameBeaten = true;
	
	Enemy_UpdateState(EnemyState.Killed);
	with(oLink){
		UpdateState(LinkState.Idle);
		audio_stop_sound(LowHealthSound);
	}
	
	image_index = 0;
	
	alarm[0] = -1;
	alarm[2] = -1;
	alarm[4] = 30;
	
	with(oBomb){
		instance_create_layer(x, y, EffectLayer(UPPER), oEnemy_Destroy);
		instance_destroy(id);
	}
	
	global.StatsToAdd[Stat.GamesWon]++;
	global.StatsToAdd[Stat.Monsters]++;	
	
	
}

var _x, _y, Angle;
if(State != EnemyState.Killed) PauseCheck

if(ScriptNext){
	
	ScriptNext = false;
	
	var S = Script[ScriptIndex];
	
	ScriptIndex = (ScriptIndex + 1) mod ScriptLen;
	
	alarm[0] = -1; //safety measure
	
	switch(S[0]){
		
		case AghanimScript.Pause:

			State = EnemyState.Standing;
			image_index = 0;

			alarm[0] = S[1];
			
			break;
		
		case AghanimScript.ChargeLR:
				
			State = EnemyState.Charging;
			image_index = 1;
				
			Charge_ImageIndex = 0;
			Charge_PosIndex = 0;
			Charge_Speed = 1 / S[1];
			Charge_Lerp = 0.5;
			
			Charge_InstL = instance_create_layer(x, y, "ObjsHigher_Upper", oAghanim_EnergyBall);
			Charge_InstR = instance_create_layer(x, y, "ObjsHigher_Upper", oAghanim_EnergyBall);

			Charge_InstL.DestroyAnimation = false;
			Charge_InstR.DestroyAnimation = false;
			
			audio_play_sound(Sound_AghanimChargeFast, 1, false);
			
			break;

		case AghanimScript.ChargeL:
				
			State = EnemyState.Charging;
			image_index = 2;
				
			Charge_ImageIndex = 0;
			Charge_PosIndex = 0;
			Charge_Speed = 1 / S[1];
			Charge_Lerp = 0;
			
			Charge_InstL = instance_create_layer(x, y, "ObjsHigher_Upper", oAghanim_EnergyBall);
			Charge_InstL.DestroyAnimation = false;
			
			break;
			
		case AghanimScript.ChargeR:
				
			State = EnemyState.Charging;
			image_index = 3;
				
			Charge_ImageIndex = 0;
			Charge_PosIndex = 0;
			Charge_Speed = 1 / S[1];
			Charge_Lerp = 0;
			
			Charge_InstR = instance_create_layer(x, y, "ObjsHigher_Upper", oAghanim_EnergyBall);
			Charge_InstR.DestroyAnimation = false;
			
			break;
			
		case AghanimScript.Shoot:
			
			State = EnemyState.Shooting;
			image_index = 0;
			
			if(instance_exists(Charge_InstL)){
				_x = Charge_InstL.x;
				_y = Charge_InstL.y;
			}else if(instance_exists(Charge_InstR)){
				_x = Charge_InstR.x;
				_y = Charge_InstR.y;				
			}else{
				
				//fail safe in case the charge insts don't exist, just shoot from centre of hands
				
				var _HandPosLX = global.AghanimHandPos[Dir][0];
				var _HandPosLY = global.AghanimHandPos[Dir][1];
				var _HandPosRX = global.AghanimHandPos[Dir][2];
				var _HandPosRY = global.AghanimHandPos[Dir][3];

				_x = x + lerp(_HandPosLX, _HandPosRX, 0.5);
				_y = y + lerp(_HandPosLY, _HandPosRY, 0.5);	
				
			}
			
			instance_destroy(Charge_InstL);
			instance_destroy(Charge_InstR);			
			
			
			switch(S[1]){
				
				case AghanimWeapon.EnergyBall:

					ShotInst = instance_create_layer(_x, _y, "ObjsHigher_Upper", oAghanim_EnergyBall, {FloorLevel : UPPER});		
					ShotInst.image_speed = 0;
					
					Angle = point_direction(_x, _y, oLink.x, oLink.y - 6);
			
					ShotInst.vx = lengthdir_x(ShootSpeed, Angle);
					ShotInst.vy = lengthdir_y(ShootSpeed, Angle);
					ShotInst.alarm[0] = ShotInst.TrailDelay;
					
					audio_play_sound(Sound_AghanimEnergyBeam, 1, false);
					
					break;
				
				case AghanimWeapon.BlueBalls:

					ShotInst = instance_create_layer(_x, _y, "ObjsHigher_Upper", oAghanim_NewBlueBall, {FloorLevel : UPPER});		
			
					Angle = point_direction(_x, _y, oLink.x, oLink.y - 6);
			
					ShotInst.vx = lengthdir_x(ShootSpeed, Angle);
					ShotInst.vy = lengthdir_y(ShootSpeed, Angle);
					
					audio_play_sound(Sound_SwordBeam, 1, false);
					
					break;
					
			}

			ScriptNext = true;
			
			break;
			
		case AghanimScript.Move:
			
			State = EnemyState.Sleep;
			
			//if(is_array(S[1])){
				S[1] = array_shuffle(S[1]);
				MovePos = (array_length(S[1]) > 1 && CurrentPos == S[1][0] ? S[1][1] : S[1][0]);
			//}else{
				//switch(S[1]){
				
				//	case -1: //random position
				//		MovePos = Aghanim_GetNextMovePos();
				//		break;
				
				//	default:
				//		MovePos = S[1];
				//		break;
				
				//}
			//}
			
			break;
		
		case AghanimScript.Bombs:

			//var _PoofInst = instance_create_layer(Charge_InstL.x, Charge_InstL.y, EffectLayer(UPPER), oSwordBeamHit);

			//instance_destroy(Charge_InstL);
			//instance_destroy(Charge_InstR);	
			
			State = EnemyState.Shooting;
			Dir = DOWN;
			Aghanim_SetSprite();
			image_index = 2;
			BombIndex = 0;
			BombPosIndex = array_shuffle(BombPosIndex);
			alarm[2] = 1;
			ScriptIndexBombMove = ScriptIndex + 1; //store next move script index after getting hit by bomb
			break;
		
		case AghanimScript.GravityBall:
			State = EnemyState.Shooting;
			GravityBall = true;
			Dir = UP;
			Aghanim_SetSprite();
			image_index = 1;
			GravityBallInst = instance_create_layer(x, y - 54, "ObjsHighest", oAghanim_GravityBall);
			alarm[6] = GravityBallTime;
			instance_destroy(Charge_InstL);
			instance_destroy(Charge_InstR);		
			break;
		
	}	
	
}


switch(State){
	
	case EnemyState.Standing:
		
		Dir = Aghanim_FacingLinkDir();
		Aghanim_SetSprite();
		
		break;
	
	case EnemyState.Charging:

		Dir = Aghanim_FacingLinkDir();
		Aghanim_SetSprite();
		
		Aghanim_UpdateCharge();

		Charge_PosIndex += Charge_Speed;
		
		if(Charge_PosIndex >= 1){
			
			ScriptNext = true;		
			
		}

		break;
	
	case EnemyState.Shooting:
		if(GravityBall && oLink.State == LinkState.Falling){
			alarm[6] = 1;
		}
		break;

		
	case EnemyState.Sleep:
		
		BlackballMorph -= MorphToSpeed;
		if(BlackballMorph <= 0){
			BlackballMorph = 0;
			State = EnemyState.Idle;

			instance_create_layer(x, y - 16, "ObjsHigher_Upper", oAghanim_MorphBall, {MoveX : MovePosX[MovePos mod 3], MoveY : MovePosY[MovePos div 3]});
				
		}
		
		break;
	
	case EnemyState.Wake:
	
		BlackballMorph += MorphToSpeed;

		Dir = Aghanim_FacingLinkDir();
		Aghanim_SetSprite();
			
		if(BlackballMorph >= 255){
			BlackballMorph = 255;
			State = EnemyState.Standing;
			CurrentPos = MovePos;
			ScriptNext = true;	
		}
		
		break;
	
	case EnemyState.Killed:

		if(!instance_exists(oDialogueBox) && FinalExplosionsInit){
			alarm[3] = 1;
			with(oLink){
				UpdateState(LinkState.Idle);
			}
			Music_Stop();
			
			FinalExplosionsInit = false;
		}
		KnockBackColorFrame = (KnockBackColorFrame + 1) mod global.KnockBackColorFrames;
		break;
		
	case EnemyState.Idle:
		
		break;
	
}