package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;
	var playingDeathSound:Bool = false;

	var stageSuffix:String = "";
	var killSound:FlxSound;

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';
	public static var quitSoundName:String = 'gameOverQuit';

	public static var endDeathIntro:Bool = false;
	public static var curDeathX:Float = 0;
	public static var curDeathY:Float = 0;
	public var startedDeathToCustom:Bool = false;

	public var versusGame:Bool = false;
	
	var isP2:Bool = false;
	var isDeadAnim:Bool = false;
	var charColor:FlxColor = 0x00000000;

	public static var instance:GameOverSubstate;

	public static function resetVariables() {
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
		quitSoundName = 'gameOverEnd';
	}

	override function create() {
		instance = this;
		endDeathIntro = false;
		PlayState.instance.callOnLuas('onGameOverStart', [isP2]);

		super.create();
	}

	public function new(x:Float, y:Float, isVersus:Bool = false, isDad:Bool = false, curCharacter:String = null) {
		super();
		isP2 = isDad;
		versusGame = isVersus;
		startedDeathToCustom = true;

		PlayState.instance.setOnLuas('inGameOver', true);

		Conductor.songPosition = 0;

		if(isVersus) {
			var loadChar:String = curCharacter + '-dead';
			var characterPath:String = 'characters/' + curCharacter + '-dead.json';
			#if MODS_ALLOWED
			var path:String = Paths.modFolders(characterPath);
			if (!FileSystem.exists(path)) path = Paths.getPreloadPath(characterPath);
			if (!FileSystem.exists(path))
			#else
			var path:String = Paths.getPreloadPath(characterPath);
			if (!Assets.exists(path))
			#end
			{
				loadChar = curCharacter;
				charColor = 0xFFE40000;
				isDeadAnim = true;
			}
			boyfriend = new Boyfriend(x, y, loadChar);
			if(isDad && isDeadAnim) boyfriend.flipX = !boyfriend.flipX;
		} else
			boyfriend = new Boyfriend(x, y, characterName);
	
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		add(boyfriend);

		if(isDeadAnim) FlxTween.color(boyfriend, 1, boyfriend.color, charColor);		

		PlayState.instance.setOnLuas('curDeathX', boyfriend.x);
		PlayState.instance.setOnLuas('curDeathY', boyfriend.y);

		camFollow = new FlxPoint(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y);
		camFollow.x -= boyfriend.cameraPosition[0];
		camFollow.y += boyfriend.cameraPosition[1];

		//FlxG.sound.play(Paths.sound(deathSoundName));
		killSound = new FlxSound().loadEmbedded(Paths.sound(deathSoundName));
		killSound.onComplete = soundEnded;
		killSound.play();
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		if(boyfriend.animOffsets.exists('firstDeath'))
			boyfriend.playAnim('firstDeath');
		else
			boyfriend.playAnim('idle');

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);
	}

	var soundIsEnded:Bool = false;
	function soundEnded():Void {
		soundIsEnded = true;
	}

	var isFollowingAlready:Bool = false;
	var coolStarted:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if(endDeathIntro) {
			if (controls.ACCEPT) restartStage();
			if (controls.BACK) endStage();
		}

		if(boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name == 'firstDeath') {
			if(boyfriend.animation.curAnim.curFrame >= 12 && !isFollowingAlready) {
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
				isFollowingAlready = true;
			}

			if(boyfriend.animation.curAnim.finished && !playingDeathSound) {
				if (PlayState.SONG.stage == 'tank y') { // RANDOM SOUND ON START GAMEOVER
					// playingDeathSound = true;
					// coolStartDeath(0.2);
					
					// var exclude:Array<Int> = [];
					// //if(!ClientPrefs.cursing) exclude = [1, 3, 8, 13, 17, 21];

					// FlxG.sound.play(Paths.sound('gameover/end-' + FlxG.random.int(1, 4, exclude)), 1, false, null, true, function() {
					// 	if(!isEnding) {
					// 		FlxG.sound.music.fadeIn(0.2, 1, 4);
					// 	}
					// });
				} else {
					endDeathIntro = true;
					coolStartDeath();
					PlayState.instance.setOnLuas('deathFinish', true);
				}
				boyfriend.startedDeath = true;
			}
		} else {
			if(killSound.time >= (killSound.length / 2) && !isFollowingAlready) {
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
				isFollowingAlready = true;
			}

			if(versusGame && soundIsEnded && !coolStarted) {
				endDeathIntro = true;
				coolStartDeath();
				PlayState.instance.setOnLuas('deathFinish', true);
			}
		}

		if(FlxG.sound.music.playing) Conductor.songPosition = FlxG.sound.music.time;
		PlayState.instance.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit() {
		super.beatHit();
	}

	function coolStartDeath(?volume:Float = 1):Void {
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
		coolStarted = true;
	}

	var isEnding:Bool = false;
	function restartStage():Void {
		if(!isEnding) {
			isEnding = true;
			endDeathIntro = false;

			PlayState.instance.setOnLuas('deathFinish', false);
			if(boyfriend.animOffsets.exists('deathConfirm'))
				boyfriend.playAnim('deathConfirm', true);

			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			new FlxTimer().start(0.7, function(tmr:FlxTimer) {
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function() {
					MusicBeatState.resetState();
				});
			});
			PlayState.instance.callOnLuas('onGameOverConfirm', [true]);
		}
	}

	function endStage() {
		if(!isEnding) {
			isEnding = true;
			endDeathIntro = false;

			PlayState.instance.setOnLuas('deathFinish', false);
			if(boyfriend.animOffsets.exists('deathQuit'))
				boyfriend.playAnim('deathQuit', true);
			else if(boyfriend.animOffsets.exists('deathConfirm'))
				boyfriend.playAnim('deathConfirm');

			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(quitSoundName));

			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;
			PlayState.chartingMode = false;

			new FlxTimer().start(0.7, function(tmr:FlxTimer) {
				FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function() {
					WeekData.loadTheFirstEnabledMod();
					MusicBeatState.switchState(new FreeplayState());
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
				});
			});
			PlayState.instance.callOnLuas('onGameOverConfirm', [false]);
		}
	}
}
