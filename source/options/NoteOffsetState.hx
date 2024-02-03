package options;

import flixel.util.FlxStringUtil;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.ui.FlxBar;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;

using StringTools;

class NoteOffsetState extends MusicBeatState
{
	var boyfriend:Character;
	var gf:Character;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;

	var playerMode:Int = 0;

	var coolText:FlxText;
	var rating:FlxSprite;
	var comboNums:FlxSpriteGroup;
	var ratingP2:FlxSprite;
	var comboNumsP2:FlxSpriteGroup;
	var dumbTexts:FlxTypedGroup<FlxText>;

	var barPercent:Float = 0;
	var delayMin:Int = 0;
	var delayMax:Int = 500;
	var timeBarBG:FlxSprite;
	var timeBar:FlxBar;
	var timeTxt:FlxText;
	var startX:Float;
	var beatText:Alphabet;
	var beatTween:FlxTween;
	var gameMode:FlxSprite;

	var changeModeText:FlxText;
	var exitText:FlxText;
	var tipText:FlxText;
	var modeTip:FlxText;

	private var tip1:String = 'Setas    - Mover texto\nA S D W - Mover números\nMOUSE    - Mover ambos';

	private var tip2:String = 'Setas    - Mover texto P1\nA S D W - Mover números P1\nJ K L I  - Mover texto P2\nF G H T - Mover números P2';

	var backEngine:FlxSprite;

	override public function create()
	{
		// Cameras
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;
		FlxG.camera.scroll.set(120, 130);

		persistentUpdate = true;
		FlxG.sound.pause();
		// Stage
		var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
		add(bg);

		var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		add(stageFront);

		if(!ClientPrefs.lowQuality) {
			var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
			stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
			stageLight.updateHitbox();
			add(stageLight);
			var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
			stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
			stageLight.updateHitbox();
			stageLight.flipX = true;
			add(stageLight);

			var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			add(stageCurtains);
		}

		// Characters
		gf = new Character(400, 130, 'gf');
		gf.x += gf.positionArray[0];
		gf.y += gf.positionArray[1];
		gf.scrollFactor.set(0.95, 0.95);
		boyfriend = new Character(770, 100, 'bf', true);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		add(gf);
		add(boyfriend);

		// Combo stuff
		coolText = new FlxText(0, 0, 0, '', 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;

		var possibleRatings:Array<String> = ['shit', 'bad', 'good', 'sick', 'perfect'];
		rating = new FlxSprite().loadGraphic(Paths.image(possibleRatings[FlxG.random.int(0, 4)]));
		rating.cameras = [camHUD];
		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.updateHitbox();
		rating.antialiasing = ClientPrefs.globalAntialiasing;
		add(rating);

		ratingP2 = new FlxSprite().loadGraphic(Paths.image(possibleRatings[FlxG.random.int(0, 4)]));
		ratingP2.cameras = [camHUD];
		ratingP2.setGraphicSize(Std.int(ratingP2.width * 0.7));
		ratingP2.updateHitbox();
		ratingP2.antialiasing = ClientPrefs.globalAntialiasing;
		ratingP2.alpha = 0;
		add(ratingP2);

		comboNums = new FlxSpriteGroup();
		comboNums.cameras = [camHUD];
		add(comboNums);

		comboNumsP2 = new FlxSpriteGroup();
		comboNumsP2.cameras = [camHUD];
		comboNumsP2.alpha = 0;
		add(comboNumsP2);

		var seperatedScore:Array<Int> = [];
		for(i in 0...6)
			seperatedScore.push(FlxG.random.int(0, 9));

		var daLoop:Int = 0;
		for(i in seperatedScore) {
			var numScore:FlxSprite = new FlxSprite(43 * daLoop).loadGraphic(Paths.image('num' + i));
			numScore.cameras = [camHUD];
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			numScore.updateHitbox();
			numScore.antialiasing = ClientPrefs.globalAntialiasing;
			if(daLoop > 2) 
				comboNumsP2.add(numScore);
			else
				comboNums.add(numScore);
			daLoop++;
		}

		dumbTexts = new FlxTypedGroup<FlxText>();
		dumbTexts.cameras = [camHUD];
		add(dumbTexts);

		createTexts();
		repositionCombo();

		// Note delay stuff

		beatText = new Alphabet(0, 0, 'DAP!', true, false, 0.05, 0.6);
		beatText.x += 460;
		beatText.alpha = 0;
		beatText.acceleration.y = 250;
		beatText.visible = false;
		add(beatText);
		
		timeTxt = new FlxText(0, 600, FlxG.width, "", 32);
		timeTxt.setFormat(Paths.font("nsane.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.borderSize = 2;
		timeTxt.visible = false;
		timeTxt.cameras = [camHUD];

		barPercent = ClientPrefs.noteOffset;
		updateNoteDelay();

		timeBarBG = new FlxSprite(0, timeTxt.y + 8).loadGraphic(Paths.image('timeBar'));
		timeBarBG.setGraphicSize(Std.int(timeBarBG.width * 1.2));
		timeBarBG.updateHitbox();
		timeBarBG.cameras = [camHUD];
		timeBarBG.screenCenter(X);
		timeBarBG.visible = false;

		timeBar = new FlxBar(0, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this, 'barPercent', delayMin, delayMax);
		timeBar.scrollFactor.set();
		timeBar.screenCenter(X);
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.visible = false;
		timeBar.cameras = [camHUD];

		add(timeBarBG);
		add(timeBar);
		add(timeTxt);

		var blackBox:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 60, FlxColor.BLACK);
		blackBox.scrollFactor.set();
		blackBox.alpha = 0.6;
		blackBox.cameras = [camHUD];
		add(blackBox);

		changeModeText = new FlxText(0, 28, FlxG.width, "", 32);
		changeModeText.setFormat(Paths.font("nsane.ttf"), 28, FlxColor.WHITE, CENTER);
		changeModeText.scrollFactor.set();
		changeModeText.cameras = [camHUD];
		add(changeModeText);

		var textBG:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 50, FlxColor.BLACK);
		textBG.scrollFactor.set();
		textBG.alpha = 0.6;
		textBG.y = FlxG.height - 60;
		textBG.cameras = [camHUD];
		add(textBG);

		exitText = new FlxText(0, textBG.y + 5, FlxG.width, 'Press Esc ou Back para voltar', 32);
		exitText.setFormat(Paths.font("nsane.ttf"), 28, FlxColor.WHITE, CENTER);
		exitText.scrollFactor.set();
		exitText.cameras = [camHUD];
		add(exitText);

		tipText = new FlxText(960, 65, 500, tip1, 24);
		tipText.setFormat(Paths.font("nsane.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.scrollFactor.set();
		tipText.cameras = [camHUD];
		tipText.borderSize = 2;
		add(tipText);

		modeTip = new FlxText(830, 170, 500, 'Press TAB para Modo', 24);
		modeTip.setFormat(Paths.font("nsane.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		modeTip.scrollFactor.set();
		modeTip.cameras = [camHUD];
		modeTip.borderSize = 2;
		add(modeTip);

		gameMode = new FlxSprite(980, 170);
		gameMode.frames = Paths.getSparrowAtlas('gameMode');
		gameMode.animation.addByPrefix('frame0', 'solo', 1, false);
		gameMode.animation.addByPrefix('frame1', 'versus', 1, false);
		gameMode.animation.play('frame' + playerMode, true);
        gameMode.scrollFactor.set(0, 0);
        gameMode.scale.set(0.3, 0.3);
		gameMode.cameras = [camHUD];
		gameMode.antialiasing = ClientPrefs.globalAntialiasing;
		gameMode.updateHitbox();
		add(gameMode);

		updateMode();

		backEngine = new FlxSprite().loadGraphic(Paths.image('mainmenu/menuEngine'));
        backEngine.scrollFactor.set(0, 0);
		backEngine.cameras = [camHUD];
        backEngine.setGraphicSize(Std.int(backEngine.width * 1));
        backEngine.screenCenter();
        backEngine.antialiasing = ClientPrefs.globalAntialiasing;
        add(backEngine);

		Conductor.changeBPM(128.0);
		FlxG.sound.playMusic(Paths.music('offsetSong'), 1, true);

		super.create();
	}

	var holdTime:Float = 0;
	var onComboMenu:Bool = true;
	var holdingObjectType:Null<Bool> = null;

	var startMousePos:FlxPoint = new FlxPoint();
	var startComboOffset:FlxPoint = new FlxPoint();

	var isChange:Bool = false;

	override public function update(elapsed:Float)
	{
		var addNum:Int = 1;
		if(FlxG.keys.pressed.SHIFT) addNum = 10;
		else if(FlxG.keys.pressed.CONTROL) addNum = 50;

		ratingP2.alpha = playerMode;
		comboNumsP2.alpha = playerMode;

		if(onComboMenu) {
			var controlArray:Array<Bool> = [
				FlxG.keys.justPressed.LEFT,
				FlxG.keys.justPressed.RIGHT,
				FlxG.keys.justPressed.UP,
				FlxG.keys.justPressed.DOWN,
			
				FlxG.keys.justPressed.A,
				FlxG.keys.justPressed.D,
				FlxG.keys.justPressed.W,
				FlxG.keys.justPressed.S,

				FlxG.keys.justPressed.J,
				FlxG.keys.justPressed.L,
				FlxG.keys.justPressed.I,
				FlxG.keys.justPressed.K,
			
				FlxG.keys.justPressed.F,
				FlxG.keys.justPressed.H,
				FlxG.keys.justPressed.T,
				FlxG.keys.justPressed.G
			];

			if(controlArray.contains(true) && playerMode == 0) {
				for(i in 0...controlArray.length) {
					if(controlArray[i]) {
						switch(i) {
							case 0:
								ClientPrefs.comboOffset[0] -= addNum;
							case 1:
								ClientPrefs.comboOffset[0] += addNum;
							case 2:
								ClientPrefs.comboOffset[1] += addNum;
							case 3:
								ClientPrefs.comboOffset[1] -= addNum;
							case 4:
								ClientPrefs.comboOffset[2] -= addNum;
							case 5:
								ClientPrefs.comboOffset[2] += addNum;
							case 6:
								ClientPrefs.comboOffset[3] += addNum;
							case 7:
								ClientPrefs.comboOffset[3] -= addNum;
						}
					}
				}
				repositionCombo();

			} else if(controlArray.contains(true) && playerMode == 1) {
				for(i in 0...controlArray.length) {
					if(controlArray[i]) {
						switch(i) {
							case 0:
								ClientPrefs.comboOffsetMultiplayer[0] -= addNum;
							case 1:
								ClientPrefs.comboOffsetMultiplayer[0] += addNum;
							case 2:
								ClientPrefs.comboOffsetMultiplayer[1] += addNum;
							case 3:
								ClientPrefs.comboOffsetMultiplayer[1] -= addNum;
							case 4:
								ClientPrefs.comboOffsetMultiplayer[2] -= addNum;
							case 5:
								ClientPrefs.comboOffsetMultiplayer[2] += addNum;
							case 6:
								ClientPrefs.comboOffsetMultiplayer[3] += addNum;
							case 7:
								ClientPrefs.comboOffsetMultiplayer[3] -= addNum;

							case 8:
								ClientPrefs.comboOffsetMultiplayer[4] -= addNum;
							case 9:
								ClientPrefs.comboOffsetMultiplayer[4] += addNum;
							case 10:
								ClientPrefs.comboOffsetMultiplayer[5] += addNum;
							case 11:
								ClientPrefs.comboOffsetMultiplayer[5] -= addNum;
							case 12:
								ClientPrefs.comboOffsetMultiplayer[6] -= addNum;
							case 13:
								ClientPrefs.comboOffsetMultiplayer[6] += addNum;
							case 14:
								ClientPrefs.comboOffsetMultiplayer[7] += addNum;
							case 15:
								ClientPrefs.comboOffsetMultiplayer[7] -= addNum;
						}
					}
				}
				repositionCombo();
			}

			if(FlxG.keys.justPressed.TAB && !isChange) {
				changeMode();
			}

			// probably there's a better way to do this but, oh well.
			if(playerMode == 0) {
				if (FlxG.mouse.justPressed) {
					holdingObjectType = null;
					FlxG.mouse.getScreenPosition(camHUD, startMousePos);
					if (startMousePos.x - comboNums.x >= 0 && startMousePos.x - comboNums.x <= comboNums.width &&
						startMousePos.y - comboNums.y >= 0 && startMousePos.y - comboNums.y <= comboNums.height)
					{
						holdingObjectType = true;
						startComboOffset.x = ClientPrefs.comboOffset[2];
						startComboOffset.y = ClientPrefs.comboOffset[3];
					}
					else if (startMousePos.x - rating.x >= 0 && startMousePos.x - rating.x <= rating.width &&
								startMousePos.y - rating.y >= 0 && startMousePos.y - rating.y <= rating.height)
					{
						holdingObjectType = false;
						startComboOffset.x = ClientPrefs.comboOffset[0];
						startComboOffset.y = ClientPrefs.comboOffset[1];
					}
				}
				if(FlxG.mouse.justReleased) {
					holdingObjectType = null;
				}
	
				if(holdingObjectType != null)
				{
					if(FlxG.mouse.justMoved)
					{
						var mousePos:FlxPoint = FlxG.mouse.getScreenPosition(camHUD);
						var addNum:Int = holdingObjectType ? 2 : 0;
						ClientPrefs.comboOffset[addNum + 0] = Math.round((mousePos.x - startMousePos.x) + startComboOffset.x);
						ClientPrefs.comboOffset[addNum + 1] = -Math.round((mousePos.y - startMousePos.y) - startComboOffset.y);
						repositionCombo();
					}
				}
			}

			if(controls.RESET) {
				if(playerMode == 0) {
					for(i in 0...ClientPrefs.comboOffset.length)
						ClientPrefs.comboOffset[i] = 0;
				} else if(playerMode == 1) {
					for(i in 0...ClientPrefs.comboOffsetMultiplayer.length) {
						if(i < 4) ClientPrefs.comboOffsetMultiplayer[i] = 0;
						else ClientPrefs.comboOffsetMultiplayer[i] = 100;
					}						
				}
				repositionCombo();
			}

		} else {
			if(controls.UI_LEFT_P) {
				barPercent = Math.max(delayMin, Math.min(ClientPrefs.noteOffset - 1, delayMax));
				updateNoteDelay();

			} else if(controls.UI_RIGHT_P) {
				barPercent = Math.max(delayMin, Math.min(ClientPrefs.noteOffset + 1, delayMax));
				updateNoteDelay();
			}

			var mult:Int = 1;
			if(controls.UI_LEFT || controls.UI_RIGHT) {
				holdTime += elapsed;
				if(controls.UI_LEFT) mult = -1;
			}

			if(controls.UI_LEFT_R || controls.UI_RIGHT_R) holdTime = 0;

			if(holdTime > 0.5) {
				barPercent += 100 * elapsed * mult;
				barPercent = Math.max(delayMin, Math.min(barPercent, delayMax));
				updateNoteDelay();
			}

			if(controls.RESET) {
				holdTime = 0;
				barPercent = 0;
				updateNoteDelay();
			}
		}

		if(controls.ACCEPT) {
			onComboMenu = !onComboMenu;
			updateMode();
		}

		if(controls.BACK) {
			if(zoomTween != null) zoomTween.cancel();
			if(beatTween != null) beatTween.cancel();

			persistentUpdate = false;
			CustomFadeTransition.nextCamera = camOther;
			//FlxG.sound.playMusic(Paths.music('freakyOptions'), 0);
			FlxG.sound.music.fadeIn(0.2, 0, 1);
			MusicBeatState.switchState(new options.OptionsState());
			FlxG.mouse.visible = false;
		}

		Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);
	}
	
	function changeMode() {
		isChange = true;
		if(playerMode == 0) {
			playerMode = 1;
			tipText.text = tip2;
			FlxG.mouse.visible = false;
		} else {
			playerMode = 0;
			tipText.text = tip1;
			FlxG.mouse.visible = true;
		}
		gameMode.animation.play('frame' + playerMode, true);
		FlxTween.tween(gameMode.scale, {x: 0.1}, 0.04, {
			onComplete: function(twn:FlxTween) {
				FlxTween.tween(gameMode.scale, {x: 0.3}, 0.04);
			}
		});
		new FlxTimer().start(0.2, function(_) { isChange = false; });

		repositionCombo();
	}

	var zoomTween:FlxTween;
	var lastBeatHit:Int = -1;
	override public function beatHit() {
		super.beatHit();

		if(lastBeatHit == curBeat) return;

		if(curBeat % 2 == 0) {
			boyfriend.dance();
			gf.dance();
		}
		
		if(curBeat % 4 == 2) {
			FlxG.camera.zoom = 1.15;

			if(zoomTween != null) zoomTween.cancel();
			zoomTween = FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.circOut,
				onComplete: function(twn:FlxTween) {
					zoomTween = null;
				}
			});

			beatText.alpha = 1;
			beatText.y = 320;
			beatText.velocity.y = -150;
			if(beatTween != null) beatTween.cancel();
			beatTween = FlxTween.tween(beatText, {alpha: 0}, 1, {ease: FlxEase.sineIn,
				onComplete: function(twn:FlxTween) {
					beatTween = null;
				}
			});
		}

		lastBeatHit = curBeat;
	}

	function repositionCombo() {
		rating.screenCenter();
		if(playerMode == 1) {
			rating.x = coolText.x - 40 + ClientPrefs.comboOffsetMultiplayer[0];
			rating.y -= 60 + ClientPrefs.comboOffsetMultiplayer[1];
		} else if(playerMode == 0) {
			rating.x = coolText.x - 40 + ClientPrefs.comboOffset[0];
			rating.y -= 60 + ClientPrefs.comboOffset[1];
		}

		comboNums.screenCenter();
		if(playerMode == 1) {
			comboNums.x = coolText.x - 40 + ClientPrefs.comboOffsetMultiplayer[2];
			comboNums.y += 80 - ClientPrefs.comboOffsetMultiplayer[3];
		} else if(playerMode == 0){
			comboNums.x = coolText.x - 40 + ClientPrefs.comboOffset[2];
			comboNums.y += 80 - ClientPrefs.comboOffset[3];
		}

		ratingP2.screenCenter();
		ratingP2.x = coolText.x - 40 + ClientPrefs.comboOffsetMultiplayer[4];
		ratingP2.y -= 60 + ClientPrefs.comboOffsetMultiplayer[5];

		comboNumsP2.screenCenter();
		comboNumsP2.x = coolText.x - 40 + ClientPrefs.comboOffsetMultiplayer[6];
		comboNumsP2.y += 80 - ClientPrefs.comboOffsetMultiplayer[7];

		reloadTexts();
	}

	function createTexts() {
		var spaceValue:Float = 0;
		for(i in 0...8) {
			var text:FlxText = new FlxText(70, 70 + (i * 30), 0, '', 24);
			text.setFormat(Paths.font("nsane.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.scrollFactor.set();
			text.borderSize = 2;
			dumbTexts.add(text);
			text.cameras = [camHUD];
			if(i % 2 == 0 && i != 0)
				spaceValue += 24;
			text.y += spaceValue;
		}
	}

	function reloadTexts() {
		for(i in 0...dumbTexts.length) {
			switch(i) {
				case 0:
					if(playerMode == 1)
						dumbTexts.members[i].text = 'Posição Julgamento P1:'; 
					else
						dumbTexts.members[i].text = 'Posição Julgamento:'; 

				case 1: 
					if(playerMode == 1)
						dumbTexts.members[i].text = '[' + ClientPrefs.comboOffsetMultiplayer[0] + ', ' + ClientPrefs.comboOffsetMultiplayer[1] + ']';
					else
						dumbTexts.members[i].text = '[' + ClientPrefs.comboOffset[0] + ', ' + ClientPrefs.comboOffset[1] + ']';

				case 2:
					if(playerMode == 1)
						dumbTexts.members[i].text = 'Posição Números P1:';
					else
						dumbTexts.members[i].text = 'Posição Números:';

				case 3:
					if(playerMode == 1)
						dumbTexts.members[i].text = '[' + ClientPrefs.comboOffsetMultiplayer[2] + ', ' + ClientPrefs.comboOffsetMultiplayer[3] + ']';
					else
						dumbTexts.members[i].text = '[' + ClientPrefs.comboOffset[2] + ', ' + ClientPrefs.comboOffset[3] + ']';

				case 4:
					if(playerMode == 1)
						dumbTexts.members[i].text = 'Posição Julgamento P2:'; 
					else
						dumbTexts.members[i].text = ''; 

				case 5: 
					if(playerMode == 1)
						dumbTexts.members[i].text = '[' + ClientPrefs.comboOffsetMultiplayer[4] + ', ' + ClientPrefs.comboOffsetMultiplayer[5] + ']';
					else
						dumbTexts.members[i].text = '';

				case 6:
					if(playerMode == 1)
						dumbTexts.members[i].text = 'Posição Números P2:';
					else
						dumbTexts.members[i].text = '';

				case 7:
					if(playerMode == 1)
						dumbTexts.members[i].text = '[' + ClientPrefs.comboOffsetMultiplayer[6] + ', ' + ClientPrefs.comboOffsetMultiplayer[7] + ']';
					else
						dumbTexts.members[i].text = '';
			}
		}
	}

	function updateNoteDelay() {
		ClientPrefs.noteOffset = Math.round(barPercent);
		timeTxt.text = 'offset atual: ' + Math.floor(barPercent) + ' ms';
	}

	var lastMouseVisible:Bool = true;

	function updateMode() {
		rating.visible = onComboMenu;
		comboNums.visible = onComboMenu;
		ratingP2.visible = onComboMenu;
		comboNumsP2.visible = onComboMenu;
		dumbTexts.visible = onComboMenu;
		tipText.visible = onComboMenu;
		modeTip.visible = onComboMenu;
		gameMode.visible = onComboMenu;
		
		timeBarBG.visible = !onComboMenu;
		timeBar.visible = !onComboMenu;
		timeTxt.visible = !onComboMenu;
		beatText.visible = !onComboMenu;

		if(onComboMenu) {
			changeModeText.text = '< Posição do Combo (Press Space para Batida) >';
			FlxG.mouse.visible = lastMouseVisible;
		} else {
			changeModeText.text = '< Batida da Nota (Press Space para Combo) >';
			lastMouseVisible = FlxG.mouse.visible;
			FlxG.mouse.visible = false;
		}
		changeModeText.text = changeModeText.text.toUpperCase();
	}
}
