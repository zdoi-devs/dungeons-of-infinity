if(_Init){
	Alpha += AlphaInc;
	if(Alpha >= 1){
		Alpha = 1;
		alarm[0] = 120;
		_Init = false;
	}
	
}

if(_End){
	Alpha -= AlphaInc;
	if(Alpha <= 0){
		Alpha = 0;
		instance_destroy(id);		
	}	
	
}
