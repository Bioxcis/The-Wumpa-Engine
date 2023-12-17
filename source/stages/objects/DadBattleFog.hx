package stages.objects;

import flixel.group.FlxSpriteGroup;
import flixel.FlxG;

class DadBattleFog extends FlxSpriteGroup
{
	public function new()
	{
		super();
		
		//alpha = 0;
		blend = ADD;

		var offsetX = 200;
		var smoke1:BGSprite = new BGSprite('smoke', -1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
		smoke1.setGraphicSize(Std.int(smoke1.width * FlxG.random.float(1.1, 1.22)));
		smoke1.updateHitbox();
		smoke1.velocity.x = FlxG.random.float(15, 22);
		smoke1.active = true;
		smoke1.antialiasing = ClientPrefs.globalAntialiasing;
		add(smoke1);

		var smoke2:BGSprite = new BGSprite('smoke', 1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
		smoke2.setGraphicSize(Std.int(smoke2.width * FlxG.random.float(1.1, 1.22)));
		smoke2.updateHitbox();
		smoke2.velocity.x = FlxG.random.float(-15, -22);
		smoke2.active = true;
		smoke2.flipX = true;
		smoke2.antialiasing = ClientPrefs.globalAntialiasing;
		add(smoke2);
	}
}