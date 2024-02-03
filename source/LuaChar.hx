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

	/**
	 * Whether or not the character will do the 'Hey!' animation of the 'Hey!' notes.
	 */
	public var luaCharHey:Bool = false;

	public function new(x:Float, y:Float, ?char:String = 'bf', ?isPlayer:Bool = false, arrows:Array<String>) {
		super(x, y, char, isPlayer);
		if(arrows != null) {
			for(ar in arrows) {
				arrowArray.push(ar);
			}
		} else {
			for(er in defaultArrows) {
				arrowArray.push(er);
			}
		}
	}

	override function update(elapsed:Float) {
		if(!debugMode && animation.curAnim != null) {
			if(animation.curAnim.name.startsWith('sing')) holdTimer += elapsed;
			else holdTimer = 0;

			if(animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && lowHealth && animation.exists('idle-low'))
				playAnim('idle-low', true, false, 10);
			else if(animation.curAnim.name.endsWith('miss') && animation.curAnim.finished)
				playAnim('idle', true, false, 10);

			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished && GameOverSubstate.instance.startedDeathToCustom)
				playAnim('deathLoop');
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

			for (news in newArrows)
				arrowArray.push(news);
		}
	}

	/**
	 * Checks if the note is the same type as the character's notes.
	 */
	public function testNote(noteType:String) {
		for(press in arrowArray)
			if(press == noteType)
				return true;
		return false;
	}
}
