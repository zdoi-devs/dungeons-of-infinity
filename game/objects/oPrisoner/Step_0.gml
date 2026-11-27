

if(global.Paused && !DB_Started){
	image_speed = 0;
	ObjIncAlarms();
	exit;
}
if(DB_Started){
	ObjIncAlarms();
}

switch(State){
	case PrisonerState.Sitting:
		image_speed = 1;
		break;
		
	case PrisonerState.Walking:
		
		image_speed = 1;
		if(image_index >= image_number - 0.1 || image_index < 1) image_index = 1;
	
		if( ObjCollision(x + (4 * Dir), y, oWall, FloorLevel) == noone){
			x += (Speed * Dir);
		}else{		
			Dir *= -1;
			alarm[0] = irandom_range(ChangeDirAlarmMin, ChangeDirAlarmMax);		
		}		
		
		break;
		
	case PrisonerState.Talking:
		switch(Index){
			default:
				image_index = 0;
				break;
			case Prisoner.Asleep:
				image_index = 1;
				break;
		}
		image_speed = 0;
		break;
	
}

if(DB_Init){
	
	global.DB_Inst = instance_create_layer(0,0, "System", oDialogueBox);

	global.DB_Inst.Script = DB_Script;
	
	DB_Init = false;
	DB_Started = true;

}

