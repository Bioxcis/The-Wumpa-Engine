package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxEmitter;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import Achievements;

using StringTools;

class AchievementsMenuState extends MusicBeatState
{
	#if ACHIEVEMENTS_ALLOWED
	var options:Array<String> = [];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	private var achievementArray:Array<AttachedAchievement> = [];
	private var achievementIndex:Array<Int> = [];
	private var descText:FlxText;
	
	var crystalCrash:FlxSound;
	var backEngine:FlxSprite;
	var frontEngine:FlxSprite;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Achievements Menu", null);
		#end

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGAchiev'));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(menuBG);

		makeCrystalEmitter();

		crystalCrash = FlxG.sound.play(Paths.sound('crystals'), 0.3, true);

		var menuCrystal:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuCrystalAchiev'));
		menuCrystal.color = 0xFFea71fd;
		menuCrystal.setGraphicSize(Std.int(menuCrystal.width * 1.1));
		menuCrystal.updateHitbox();
		menuCrystal.screenCenter();
		menuCrystal.antialiasing = ClientPrefs.globalAntialiasing;
		add(menuCrystal);

		makeGlowEmitter();

		var darkBG:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		darkBG.alpha = 0.2;
		add(darkBG);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		Achievements.loadAchievements();
		for (i in 0...Achievements.achievementsStuff.length) {
			if(!Achievements.achievementsStuff[i][3] || Achievements.achievementsMap.exists(Achievements.achievementsStuff[i][2])) {
				options.push(Achievements.achievementsStuff[i]);
				achievementIndex.push(i);
			}
		}

		for (i in 0...options.length) {
			var achieveName:String = Achievements.achievementsStuff[achievementIndex[i]][2];
			var optionText:Alphabet = new Alphabet(0, (100 * i) + 210, Achievements.isAchievementUnlocked(achieveName) ? Achievements.achievementsStuff[achievementIndex[i]][0] : '?', false, false);
			optionText.isMenuItem = true;
			optionText.x += 280;
			optionText.xAdd = 200;
			optionText.targetY = i;
			grpOptions.add(optionText);

			var icon:AttachedAchievement = new AttachedAchievement(optionText.x - 105, optionText.y, achieveName);
			icon.sprTracker = optionText;
			achievementArray.push(icon);
			add(icon);
		}

		descText = new FlxText(150, 600, 980, "", 32);
		descText.setFormat(Paths.font("crash.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);
		changeSelection();

		backEngine = new FlxSprite().loadGraphic(Paths.image('mainmenu/menuEngine'));
        backEngine.scrollFactor.set(0, 0);
        backEngine.setGraphicSize(Std.int(backEngine.width * 1));
        backEngine.screenCenter();
        backEngine.antialiasing = ClientPrefs.globalAntialiasing;
        add(backEngine);

		frontEngine = new FlxSprite();
		frontEngine.frames = Paths.getSparrowAtlas('mainmenu/engine');
		frontEngine.animation.addByPrefix('engineSpin', 'engineSpin', 24, false);
		frontEngine.animation.play('engineSpin', false, false);
        frontEngine.scrollFactor.set(0, 0);
		frontEngine.x = FlxG.width - 1320;
		frontEngine.y = -10;
		frontEngine.flipX = true;
		frontEngine.antialiasing = ClientPrefs.globalAntialiasing;
		add(frontEngine);

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			frontEngine.animation.play('engineSpin', true, false);
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			frontEngine.animation.play('engineSpin', true, false);
			changeSelection(1);
		}

		if (controls.BACK) {
			crystalCrash.stop();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}		
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}

		for (i in 0...achievementArray.length) {
			achievementArray[i].alpha = 0.6;
			if(i == curSelected) {
				achievementArray[i].alpha = 1;
			}
		}
		descText.text = Achievements.achievementsStuff[achievementIndex[curSelected]][1];
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
	#end

	function makeCrystalEmitter() {
		var crystalEmitter:FlxEmitter = new FlxEmitter(0, -100, 100);
		for (i in 0...100) {
			var particle = new FlxParticle();
			particle.loadGraphic(Paths.image('particles/ParticleCrystal'));
			particle.exists = false;
			crystalEmitter.add(particle);
		}
		crystalEmitter.setSize(1300, 0);
		crystalEmitter.speed.set(0, 40, 0, 40);
		crystalEmitter.launchMode = CIRCLE;
		crystalEmitter.launchAngle.set(90, 90);
		crystalEmitter.angularVelocity.set(100, -100, 360, -360);
		crystalEmitter.lifespan.set(0, 0);
		crystalEmitter.scale.set(0.3, 0.3, 0.6, 0.6);
		crystalEmitter.acceleration.set(0, 150, 0, 200);
		crystalEmitter.keepScaleRatio = true;
		add(crystalEmitter);
		crystalEmitter.start(false, 0.03);
	}

	function makeGlowEmitter() {
		var glowEmitter:FlxEmitter = new FlxEmitter(0, 0, 100);
		for (i in 0...100) {
			var particle = new FlxParticle();
			particle.loadGraphic(Paths.image('particles/ParticleSparkle'));
			particle.exists = false;
			glowEmitter.add(particle);
		}
		glowEmitter.setSize(FlxG.width, FlxG.height);
		glowEmitter.speed.set(0, 40, 0, 40);
		glowEmitter.launchMode = SQUARE;
		glowEmitter.alpha.set(0.6, 1, 0, 0);
		glowEmitter.color.set(0xFFD6BDFF, 0xFFFFBDFD);
		glowEmitter.lifespan.set(3, 4);
		glowEmitter.scale.set(0.5, 0.5, 0.8, 0.8);
		glowEmitter.keepScaleRatio = true;
		add(glowEmitter);
		glowEmitter.start(false, 0.2);
	}
}

/*
	Plano para 'Custom Achievements':
	- Adicionar Conquistas via Lua
	- Adicionar Conquista e salvar para o 'achievementsMap'
	- Ao carregar no menu, deve-se carregar pelo mapa:
		- conquista
		- icone
		- texto
*/