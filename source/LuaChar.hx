package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

class LuaChar extends Character
{
	private var defaultArrows:Array<String> = ["", "Alt Animation", "Hey!", "GF Sing", "No Animation"];
	public var arrowArray:Array<String> = [];

	public function new(x:Float, y:Float, ?char:String = 'bf', ?isPlayer:Bool = false, ?arrows:Array<String> = null) {
		super(x, y, char, isPlayer);
		if(arrows == null) {
			for (ar in defaultArrows) {
				arrowArray.push(ar);
			}
		} else {
			for (ar in arrows) {
				arrowArray.push(ar);
			}
		}
	}

	override function update(elapsed:Float) {
		if (!debugMode && animation.curAnim != null) {
			if(animation.curAnim.name.startsWith('sing')) {
				holdTimer += elapsed;
			} else { 
				holdTimer = 0;
			}

			if (PlayState.instance.daTaeb % danceEveryNumBeats == 0 && animation.curAnim != null && !animation.curAnim.name.startsWith('sing') && !stunned) {
				dance();
			}

			if(animation.curAnim != null && holdTimer > Conductor.stepCrochet * 0.0011 * singDuration && animation.curAnim.name.startsWith('sing') && !animation.curAnim.name.endsWith('miss')) {
				dance();
			}

			if(animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode) {
				playAnim('idle', true, false, 10);
			}

			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished && GameOverSubstate.instance.startedDeathToCustom) {
				playAnim('deathLoop');
			}
		}
		super.update(elapsed);
	}

	public function changeArrows(newArrows:Array<String>, resetArrows:Bool = false) {
		if(newArrows != null) {
			if(resetArrows)
				arrowArray = [];

			for (newAr in newArrows) {
				arrowArray.push(newAr);
			}
		}
	}
/*
	// Ideia aparentemente descartada... ainda...

	public function charNoteHit(noteType:String, hitByOpponent:Bool, animToPlay:String) {
		if(!hitByOpponent && isPlayer) {
			var charNote:Bool = testNote(noteType);
			if(charNote) {
				playAnim(animToPlay, true);
				holdTimer = 0;
			}
		} else if(!isPlayer) {
			var charNote:Bool = testNote(noteType);
			if(charNote) {
				playAnim(animToPlay, true);
				holdTimer = 0;
			}
		}
	}
	public function charNoteMiss(noteType:String, noMissAnimation:Bool, animToPlay:String) {
		if(!noMissAnimation && hasMissAnimations && isPlayer) {
			var charNote:Bool = testNote(noteType);
			if(charNote) {
				playAnim(animToPlay, true);
			}
		}
	}
*/
	public function testNote(noteType:String) {
		for (press in arrowArray) {
			if(press == noteType) {
				return true;
			}
		}
		return false;
	}
}
