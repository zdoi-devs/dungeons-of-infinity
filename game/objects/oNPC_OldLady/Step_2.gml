if(!global.Speedrun && !DB_Started && State == NPCState_OldLady.Letter && oLink.State != LinkState.Idle && !global.Paused){
	
	global.Paused = true;
	with(oLink){
		UpdateState(LinkState.Idle);
		Facing = LEFT;
		UpdateSprites();
	}	
	
}