import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class Achievements {
	public static var achievementsStuff:Array<Dynamic> = [ //Name, Description, Achievement save tag, Hidden achievement
		["Dance Comigo, Querida!", 			"Jogue em uma Sexta... a Noite.",						'friday_night_play',	 true],
		["Nenhum Lugar como Wumpa!",		"Termine a Semana 1 no NSano sem erros.",				'week1_nomiss',			 true],
		["Girl Power!",						"Termine a Semana 2 no NSano sem erros.",				'week2_nomiss',			 true],
		["Nao recicle!", 		     		"Termine a Semana 3 no NSano sem erros.",				'week3_nomiss',			 true],
		["Uma Wumpa, Um dia!",				"Termine a Semana 4 no NSano sem erros.",				'week4_nomiss',			 true],
		["O Buraco Fica Mais Embaixo!", 	"Termine a Semana 5 no NSano sem erros.",				'week5_nomiss',			 true],
		["Crash Atascado",					"Complete uma musica com score de 20%.",	        	'ur_bad',				false],
		["Crash King!",			    		"Complete uma musica com score de 100%.",				'ur_good',				false],
		["Grande Tiro",  		        	"Pressione uma seta por 10 segundos.",					'oversinging',			false],
		["Movido a Suco Wumpa!",			"Termine uma musica sem ficar parado!",    				'hype',					false],
		["Duplex Crash",     				"Termine uma musica apenas com 2 notas!",				'two_keys',				false],
		["Um Gamer em uma Torradeira",		"Porque não pede o Notebook da Coco emprestado?",		'toastie',				false],
		["Crunched",						"Termine o Estagio \"Test\" do Editor de Notas.",		'debugger',				false],
		["Musica no Bosque", 	   /*Novo*/	"Consiga um Cristal nos Bosques da Ilha Wumpa",			'flora',				false],
		["Um Bonus Descontraido",			"Consiga um Cristal na rodada Bonus",					'bonus',				false],
		["Atrapalhadas no Escuro",			"Consiga um Cristal nos Templos Subterraneos",			'templo',				false],
		["Triunfo Tóxico",					"Consiga um Cristal nos Esgotos da Ilha Industrial",	'toxico',				false],
		["Perfectus Flora",					"Um desempenho insanamente perfeito!",					'music1',				false],
		["Perfectus Bonus",					"Um desempenho insanamente perfeito!",					'music2',				false],
		["Perfectus Tenebris",				"Um desempenho insanamente perfeito!",					'music3',				false],
		["Perfectus Ardens",				"Um desempenho insanamente perfeito!",					'music4',				false],
		["Acontecimentos e encontros",		"Termine a intro de forma NSana!",						'intro_nomiss',			 true],
		["Nenhum Lugar como Wumpa...",		"Termine o primeiro warp de forma NSana!",				'warp1_nomiss',			 true],
		["Um mix de sentimentos...",		"Termine o mega mix de forma NSana!",					'megamix_nomiss',		 true],
		["So as melhores, Radio Wumpa",		"Termine os mais famosos de forma NSana!",				'fnf_nomiss',			 true],
		["Extra, Extra!",					"Termine os extras de forma NSana!",					'extra_nomiss',			 true]
	];
	public static var achievementsMap:Map<String, Bool> = new Map<String, Bool>();

	public static var henchmenDeath:Int = 0;
	public static function unlockAchievement(name:String):Void {
		FlxG.log.add('Conquista completa "' + name +'"');
		achievementsMap.set(name, true);
		FlxG.sound.play(Paths.sound('crash/cristal'), 0.7);
	}

	public static function isAchievementUnlocked(name:String) {
		if(achievementsMap.exists(name) && achievementsMap.get(name)) {
			return true;
		}
		return false;
	}

	public static function getAchievementIndex(name:String) {
		for (i in 0...achievementsStuff.length) {
			if(achievementsStuff[i][2] == name) {
				return i;
			}
		}
		return -1;
	}

	public static function loadAchievements():Void {
		if(FlxG.save.data != null) {
			if(FlxG.save.data.achievementsMap != null) {
				achievementsMap = FlxG.save.data.achievementsMap;
			}
			if(henchmenDeath == 0 && FlxG.save.data.henchmenDeath != null) {
				henchmenDeath = FlxG.save.data.henchmenDeath;
			}
		}
	}
}

class AttachedAchievement extends FlxSprite {
	public var sprTracker:FlxSprite;
	private var tag:String;
	public function new(x:Float = 0, y:Float = 0, name:String) {
		super(x, y);

		changeAchievement(name);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function changeAchievement(tag:String) {
		this.tag = tag;
		reloadAchievementImage();
	}

	public function reloadAchievementImage() {
		if(Achievements.isAchievementUnlocked(tag)) {
			loadGraphic(Paths.image('achievements/' + tag));
		} else {
			loadGraphic(Paths.image('achievements/lockedachievement'));
		}
		scale.set(0.7, 0.7);
		updateHitbox();
	}

	override function update(elapsed:Float) {
		if (sprTracker != null)
			setPosition(sprTracker.x - 130, sprTracker.y + 25);

		super.update(elapsed);
	}
}

class AchievementObject extends FlxSpriteGroup {
	public var onFinish:Void->Void = null;
	var alphaTween:FlxTween;
	public function new(name:String, ?camera:FlxCamera = null)
	{
		super(x, y);
		ClientPrefs.saveSettings();

		var id:Int = Achievements.getAchievementIndex(name);
		var achievementBG:FlxSprite = new FlxSprite(60, 50).makeGraphic(420, 120, FlxColor.BLACK);
		achievementBG.scrollFactor.set();

		var achievementIcon:FlxSprite = new FlxSprite(achievementBG.x + 10, achievementBG.y + 10).loadGraphic(Paths.image('achievements/' + name));
		achievementIcon.scrollFactor.set();
		achievementIcon.setGraphicSize(Std.int(achievementIcon.width * (2 / 3)));
		achievementIcon.updateHitbox();
		achievementIcon.antialiasing = ClientPrefs.globalAntialiasing;

		var achievementName:FlxText = new FlxText(achievementIcon.x + achievementIcon.width + 20, achievementIcon.y + 16, 280, Achievements.achievementsStuff[id][0], 16);
		achievementName.setFormat(Paths.font("crash.ttf"), 20, FlxColor.WHITE, LEFT);
		achievementName.scrollFactor.set();

		var achievementText:FlxText = new FlxText(achievementName.x, achievementName.y + 32, 280, Achievements.achievementsStuff[id][1], 16);
		achievementText.setFormat(Paths.font("crash.ttf"), 20, FlxColor.WHITE, LEFT);
		achievementText.scrollFactor.set();

		add(achievementBG);
		add(achievementName);
		add(achievementText);
		add(achievementIcon);

		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if(camera != null) {
			cam = [camera];
		}
		alpha = 0;
		achievementBG.cameras = cam;
		achievementName.cameras = cam;
		achievementText.cameras = cam;
		achievementIcon.cameras = cam;
		alphaTween = FlxTween.tween(this, {alpha: 1}, 0.5, {onComplete: function (twn:FlxTween) {
			alphaTween = FlxTween.tween(this, {alpha: 0}, 0.5, {
				startDelay: 2.5,
				onComplete: function(twn:FlxTween) {
					alphaTween = null;
					remove(this);
					if(onFinish != null) onFinish();
				}
			});
		}});
	}

	override function destroy() {
		if(alphaTween != null) {
			alphaTween.cancel();
		}
		super.destroy();
	}
}