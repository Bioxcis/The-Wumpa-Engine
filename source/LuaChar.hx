package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

/**
 * @author Bioxcis-dono
 */
class LuaChar extends Character
{
	/**
	 * Array with default notes for characters created without specified notes.
	 */
	final defaultArrows:Array<String> = ["", "Alt Animation", "Hey!", "GF Sing", "No Animation"];
	
	/**
	 * Array for the notes to be defined for the character.
	 */
	public var arrowArray:Array<String> = [];

	public function new(x:Float, y:Float, ?char:String = 'bf', ?isPlayer:Bool = false, arrows:Array<String>) {
		super(x, y, char, isPlayer);
		if(arrows != null) {
			for (ar in arrows) {
				arrowArray.push(ar);
			}
		} else {
			for (er in defaultArrows) {
				arrowArray.push(er);
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

	/**
	 * Change or add notes for the character.
	 */
	public function changeArrows(newArrows:Array<String>, resetArrows:Bool = false) {
		if(newArrows != null) {
			if(resetArrows)
				arrowArray = [];

			for (news in newArrows) {
				arrowArray.push(news);
			}
		}
	}

	/**
	 * Checks if the note is the same type as the character's notes.
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
