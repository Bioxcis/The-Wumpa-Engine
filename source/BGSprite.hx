package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.graphics.frames.FlxAtlasFrames;

class BGSprite extends FlxSprite {
	public var idleAnim:String;
	public var imagePath:String;
	public var isLooped:Bool = false;
	public var allAnims:Array<String> = [];
	public var animFrames:Int = 24;
	public function new(image:String, x:Float = 0, y:Float = 0, ?scrollX:Float = 1, ?scrollY:Float = 1, ?animArray:Array<String> = null, ?loop:Bool = false, ?frameRate:Int = 24) {
		super(x, y);

		if(animArray != null && animArray.length > 0 && image != null) {
			frames = Paths.getSparrowAtlas(image);
			isLooped = loop;
			animFrames = frameRate;
			for(i in 0...animArray.length) {
				var anim:String = animArray[i];
				animation.addByPrefix(anim, anim, frameRate, loop);
				allAnims.push(anim);
				if(idleAnim == null) {
					idleAnim = anim;
					animation.play(anim);
				}
			}
		} else {
			if(image != null || image != '') {
				imagePath = image;
				loadGraphic(Paths.image(image));
			} else {
				makeGraphic(2, 2, FlxColor.TRANSPARENT);
			}
			active = false;
		}
		scrollFactor.set(scrollX, scrollY);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function dance(?forceplay:Bool = false) {
		if(idleAnim != null) {
			animation.play(idleAnim, forceplay);
		}
	}
}