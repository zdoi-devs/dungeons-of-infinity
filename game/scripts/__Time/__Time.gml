global.Time_PlayingStart = 0;

global.Time_PausedStart = -1;
global.Time_PausedTotal = 0; //keep track of total time paused (loading levels, menue screen, etc), then at the end of the game, subtract total paused time from time playing

global.Time_PlayingTotalEnd = 0;
global.Time_PlayingTotalSaved = 0;

function Time_Str(_Time){
	
	//returns formatted time string where _Time is in milliseconds

	_Time = (_Time) / 1000000;

	var _MSecs = floor(frac(_Time) * 100);
	var _Secs = floor(_Time mod 60);
	var _Mins = floor(_Time / 60) mod 60;
	var _Hours = floor(_Time / 3600);
	
	var _ShowHours = (_Hours > 0);
	var _ShowMins = (_Mins > 0 || _ShowHours);
	var _MinScoreText = _ShowHours;
	var _SecScoreText = _ShowMins;
	
	var _TimeStr = "";
	
	if(_ShowHours) _TimeStr += (string(_Hours) + ":");
	
	if(_ShowMins){
		if(_MinScoreText){
			_TimeStr += (ScoreText(_Mins, 2) + ":");
		}else{
			_TimeStr += (string(_Mins) + ":");
		}
	}
	
	if(_SecScoreText){
		_TimeStr += (ScoreText(_Secs, 2));
	}else{
		_TimeStr += (string(_Secs));
	}
	
	_TimeStr += ("." + ScoreText(_MSecs, 2));
	//if(_ShowDenom){
	//	if(_ShowHours){
	//		_TimeStr += " HRS";
	//	}else if(_ShowMins){
	//		_TimeStr += " MINS";
	//	}else{
	//		_TimeStr += " SECS";
	//	}
	//}
	
	return _TimeStr;

}

function Time_PlayingStart(){
	
	global.Time_PlayingTotalEnd = 0;
	global.Time_PlayingTotalSaved = 0;
	global.Time_PausedTotal = 0;	
	global.Time_PlayingStart = get_timer();
	
}

function Time_PlayingTotal(){
	
	return get_timer() - global.Time_PlayingStart - global.Time_PausedTotal + global.Time_PlayingTotalSaved;
	
}

function Time_PauseStart(){
	
	global.Time_PausedStart = get_timer();
	
}

function Time_PauseEnd(){
	
	if(global.Time_PausedStart == -1) exit; //pause wasn't started so exit
	
	var _PauseTime = get_timer() - global.Time_PausedStart;
	global.Time_PausedTotal += _PauseTime;
	
	global.Time_PausedStart = -1;
	
}