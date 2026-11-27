if(DB_Started){
	
	State = PrisonerState.Talking;
	
	if(!instance_exists(global.DB_Inst)){

		alarm[0] = 60;
		
		var inst;
		switch(Index){
			
			case Prisoner.Justin:
			
				if(DialogueSentence == 3){
			
					global.Paused = true;
			
					inst = instance_create_layer(x, y, "ObjsHigher_Upper", oItem_Rupee);
					HoldUpItem(inst, ItemFrom.KinstoneGreen);
			
					GaveRupees = true;

				}
				break;

			case Prisoner.Letter:
			
				//Letter
				if(global.DB_ExitCode == 1){
			
					global.Paused = true;
			
					inst = instance_create_layer(x, y, "ObjsHigher_Upper", oItem_Letter);
					HoldUpItem(inst);
			
					GaveLetter = true;

				}
				break;
			
			case Prisoner.Asleep:
				State = PrisonerState.Sitting;
				break;
		
		}
		
		DB_Started = false;
		
	}
}