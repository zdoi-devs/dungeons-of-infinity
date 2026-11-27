/// @description Change Dir

State = Prisoner_GetMainStateForIndex();

switch(State){
	case PrisonerState.Walking:	
		Dir *= -1;
		image_index = 1;
		break;
	
	case PrisonerState.Sitting:
		switch(Index){
			default: image_index = 0; break;
			//these prisoners move their heads side to side
			case Prisoner.Hungry:
			case Prisoner.Games:
			case Prisoner.Thief:
				if(image_index == 0) image_index = choose(1, 2);
				else image_index = 0;
				break;
		}
		break;
}

alarm[0] = irandom_range(ChangeDirAlarmMin, ChangeDirAlarmMax);