FloorLevel = GetFloorLevelID(x, y);
Speed = 0.25;
Dir = choose(-1, 1);
ChangeDirAlarmMin = 60;
ChangeDirAlarmMax = 160;
GaveLetter = false;
GaveRupees = false;
GotFortune = false;


sprite_index = asset_get_index("sPrisoner" + string(Index));



State = Prisoner_GetMainStateForIndex();

alarm[0] = irandom_range(ChangeDirAlarmMin, ChangeDirAlarmMax);

DB_Init = false;
DB_Started = false;

#region DialogueBox

	Dialogue = global.Dialogue_Prisoner[Index];
	DialogueSentence = 0;
	
	function ScriptFunction_Letter(){
		return Index == Prisoner.Letter && !GaveLetter;
	}
	function ScriptFunction_GaveRupees(){
		return Index == Prisoner.Justin && GaveRupees;
	}
	function ScriptFunction_Dialogue_Prisoner() {
		if(GaveLetter){
			return global.Dialogue_Prisoner_GaveLetter;
		}else if(GotFortune){
			return global.Dialogue_Prisoner_GotFortune;
		}else{
			
			switch(Index){
				case Prisoner.FortuneTeller:
					
					var _FortuneIndex = DialogueCycle(global.Dialogue_Prisoner[Prisoner.FortuneTeller], global.Users[global.UserIndex].UsedFortuneTellerReadings);

					GotFortune = true;
					return "Here is your fortune: " + global.Dialogue_Prisoner[Prisoner.FortuneTeller][_FortuneIndex];					
					
				default:
					if(DialogueSentence >= (array_length(Dialogue) - (ScriptFunction_GaveRupees() ? 1 : 0)) ) DialogueSentence = 0;
					return Dialogue[DialogueSentence++];	
			}

		}
	}
	
	if global.Speedrun{
		DB_Script = ds_grid_create(5, 4); var i = 0; var Addr=0;

						DB_Script[# 0, Addr] = DBScriptCode.IfGoto;			DB_Script[# ++i, Addr] = method(self, ScriptFunction_Letter);		DB_Script[# ++i, Addr] = 3; DB_Script[# ++i, Addr] = 1; i = 0;
		Addr=1;	DB_Script[# 0, Addr] = DBScriptCode.Dialogue;		DB_Script[# ++i, Addr] = method(self, ScriptFunction_Dialogue_Prisoner); DB_Script[# ++i, Addr] = 2; i = 0;
		Addr=2; DB_Script[# 0, Addr] = DBScriptCode.End;			DB_Script[# ++i, Addr] = 0; i = 0;
		Addr=3; DB_Script[# 0, Addr] = DBScriptCode.End;			DB_Script[# ++i, Addr] = 1; i = 0;
	}
	else{
		DB_Script = ds_grid_create(5, 8); var i = 0; var Addr=0;

				DB_Script[# 0, Addr] = DBScriptCode.IfGoto;			DB_Script[# ++i, Addr] = method(self, ScriptFunction_Letter);		DB_Script[# ++i, Addr] = 2; DB_Script[# ++i, Addr] = 1; i = 0;
		Addr=1;	DB_Script[# 0, Addr] = DBScriptCode.Dialogue;		DB_Script[# ++i, Addr] = method(self, ScriptFunction_Dialogue_Prisoner); DB_Script[# ++i, Addr] = 6; i = 0;
		Addr=2;	DB_Script[# 0, Addr] = DBScriptCode.Dialogue_YesNo;	DB_Script[# ++i, Addr] = global.Dialogue_Prisoner_LetterIntro;		DB_Script[# ++i, Addr] = 3; DB_Script[# ++i, Addr] = 5; i = 0;
		Addr=3;	DB_Script[# 0, Addr] = DBScriptCode.Dialogue_YesNo;	DB_Script[# ++i, Addr] = global.Dialogue_Prisoner_LetterYes1;		DB_Script[# ++i, Addr] = 4; DB_Script[# ++i, Addr] = 5; i = 0;
		Addr=4;	DB_Script[# 0, Addr] = DBScriptCode.Dialogue;		DB_Script[# ++i, Addr] = global.Dialogue_Prisoner_LetterYes2;		DB_Script[# ++i, Addr] = 7; i = 0;
		Addr=5;	DB_Script[# 0, Addr] = DBScriptCode.Dialogue;		DB_Script[# ++i, Addr] = global.Dialogue_Prisoner_LetterNo;			DB_Script[# ++i, Addr] = 6; i = 0;
		Addr=6; DB_Script[# 0, Addr] = DBScriptCode.End;			DB_Script[# ++i, Addr] = 0; i = 0;
		Addr=7; DB_Script[# 0, Addr] = DBScriptCode.End;			DB_Script[# ++i, Addr] = 1; i = 0;
	}

#endregion
