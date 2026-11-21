if(DB_Init && !DB_Delay && !DialogueIgnore){

	if(DialogueSkipOnce){
		DialogueSkipOnce = false;
		DB_InitDone = false;
		DB_Init = false;
		exit;
	}
	
	if(!DB_InitDone){
		DB_Init_Child = true;
		DB_Init_GrandChild = true;
		exit;
	}
	DB_InitDone = false;
	
	if(Dialogue_GetCurrentSentence() != ""){
		global.DB_Inst = instance_create_layer(0,0, "System", oDialogueBox);
		global.DB_Inst.Script = DB_Script;
		DB_Started = true;
		DB_Init = false;
		
	}	

}