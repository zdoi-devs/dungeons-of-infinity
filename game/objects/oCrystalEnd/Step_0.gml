
if(!Setup){

	if(oLink.y <= 1156){ 
		oLink.Facing = UP;
		var _X = oCamera.X + oCamera.W_2;
		Cx[0] = _X - 4;	Cy[0] = oLink.y - 16;	Cz[0] = 8;
		Cx[1] = _X + 4;	Cy[1] = oLink.y - 16;	Cz[1] = 8;
		Cx[2] = _X;		Cy[2] = oLink.y - 16;	Cz[2] = 8;
		with(oLink) UpdateState(LinkState.Idle);
		alarm[4] = 60;
		
		Music_Fade(0, 60);
		Setup = true;
	}		
	exit;	
}


if(Spawn){
	for(var i = 0; i < 3; i++){
		Cx[i] += lengthdir_x(CSpeed[i], CAngle[i]);
		Cy[i] += lengthdir_y(CSpeed[i], CAngle[i]);
		Cz[i] += 0.075;
	}	
}

if(Attack){
	
	AttackV += AttackA;

	CVx[0] = lengthdir_x(AttackV, CDir[0]);
	CVy[0] = lengthdir_y(AttackV, CDir[0]);
	CVx[1] = lengthdir_x(AttackV, CDir[1]);
	CVy[1] = lengthdir_y(AttackV, CDir[1]);
	CVx[2] = lengthdir_x(AttackV, CDir[2]);
	CVy[2] = lengthdir_y(AttackV, CDir[2]);

	Cx[AttackTurn] += CVx[AttackTurn];
	Cy[AttackTurn] += CVy[AttackTurn];
	Cz[AttackTurn] -= (0.48 * AttackV);
	
	if(Cy[AttackTurn] <= GateY + 12){
		audio_play_sound(Sound_Crash, 1, false);
		oCamera.alarm[0] = 30;
		oCamera.ShakeAmount = 2;
		AttackScreenFadeDir = 1;
		CVisible[AttackTurn] = false;
		AttackV = 0;
		AttackTurn++;		
		Attack = false;
		if(AttackTurn < 3) alarm[5] = 60;
	}
	
}

AttackScreenFade += (AttackScreenFadeDir * AttackScreenFadeV);
if(AttackScreenFade >= 1){
	AttackScreenFadeDir = -1;
	if(AttackTurn == 3){
		Curse_Done(); //remove any curse during the last whiteout
	}
}
if(AttackScreenFade <= 0){
	AttackScreenFade = 0;
	AttackScreenFadeDir = 0;
	if(AttackTurn == 3){
		if instance_exists(oFinalBossGate){
			oFinalBossGate.Destroyed = true;
		}
		with(oLink) UpdateState(LinkState.Standing);
		instance_destroy(id);
	}
}

