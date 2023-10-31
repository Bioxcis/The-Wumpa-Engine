package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

class LuaChar extends Character
{
	public var arrowArray:Array<String> = [];

	public function new(x:Float, y:Float, char:String = 'bf', isPlayer:Bool = false, arrows:Array<String> = null) {
		super(x, y, char, isPlayer);
		if(arrows == null) {
			arrowArray.push('');
		} else {
			for (ar in arrows) {
				arrowArray.push(ar);
			}
		}
	}

	override function update(elapsed:Float) {
		if (!debugMode && animation.curAnim != null) {
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}
			else
				holdTimer = 0;

			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
			{
				playAnim('idle', true, false, 10);
			}
		}
		super.update(elapsed);
	}
}
