package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxStringUtil;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Continuar', 'Reiniciar fase', /*'Trocar Dificuldade', 'Config Gameplay',*/'Ajustes', 'Sair'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	public static var wasinsongbeforethenwenttooptions:Bool;
	var skipTimeText:FlxText;
	var skipTimeTracker:Alphabet;
	var curTime:Float = Math.max(0, Conductor.songPosition);
	//var botplayText:FlxText;

	public static var songName:String = '';

	var backEngine:FlxSprite;

	public function new(x:Float, y:Float)
	{
		super();
		//if(CoolUtil.difficulties.length < 4) menuItemsOG.remove('Trocar Dificuldade'); //No need to change difficulty if there is only one!

		if(PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'Deixar Editor de Notas');
			
			var num:Int = 0;
			if(!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(3, 'Pular Tempo');
			}
			menuItemsOG.insert(3 + num, 'Terminar Musica');
			menuItemsOG.insert(4 + num, 'Modo Pratico');
			menuItemsOG.insert(5 + num, 'Botplay');
		}
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficulties.length) {
			var diff:String = '' + CoolUtil.difficulties[i];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('VOLTAR');


		pauseMusic = new FlxSound();
		if(songName != null) {
			pauseMusic.loadEmbedded(Paths.music(songName), true, true);
		} else if (songName != 'None') {
			pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)), true, true);
		}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(-20, 30, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.color = 0xffe05a00;
		levelInfo.setFormat(Paths.font("crash.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(-20, 30 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.color = 0xff006dd3;
		levelDifficulty.setFormat(Paths.font('crash.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(-20, 30 + 64, 0, "", 32);
		blueballedTxt.text = "Mortes: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.color = 0xffdd0000;
		blueballedTxt.setFormat(Paths.font('crash.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(-20, 30 + 96, 0, "MODO PRATICO", 32);
		practiceText.scrollFactor.set();
		practiceText.color = 0xff23cf00;
		practiceText.setFormat(Paths.font('crash.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		var chartingText:FlxText = new FlxText(-20, 15 + 96, 0, "EDITOR DE NOTAS", 32);
		chartingText.scrollFactor.set();
		chartingText.color = 0xfffdf900;
		chartingText.setFormat(Paths.font('crash.ttf'), 32);
		chartingText.x = FlxG.width - (chartingText.width + 50);
		chartingText.y = FlxG.height - (chartingText.height + 60);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		backEngine = new FlxSprite().loadGraphic(Paths.image('mainmenu/menuEngine'));
        backEngine.scrollFactor.set(0, 0);
        backEngine.screenCenter();
		backEngine.scale.x = 1.3;
		backEngine.scale.y = 1.3;
        backEngine.antialiasing = ClientPrefs.globalAntialiasing;
        add(backEngine);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		practiceText.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 95);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 75);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 55);
		practiceText.x = FlxG.width - (practiceText.width + 45);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(backEngine.scale, {x: 1, y: 1}, 0.2, {ease: FlxEase.quadInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: levelInfo.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(practiceText, {alpha: 1, y: practiceText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	var optionAccepted:Bool = false;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);
		updateSkipTextStuff();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (!optionAccepted) {
			if (upP) {
				changeSelection(-1);
			}
			if (downP) {
				changeSelection(1);
			}

			if (FlxG.keys.justPressed.ESCAPE) {
				optionAccepted = true;
				returnToGame();
			}

			var daSelected:String = menuItems[curSelected];
			switch (daSelected) {
				case 'Pular Tempo':
					if (controls.UI_LEFT_P) {
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
						curTime -= 1000;
						holdTime = 0;
					}
					if (controls.UI_RIGHT_P) {
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
						curTime += 1000;
						holdTime = 0;
					}

					if(controls.UI_LEFT || controls.UI_RIGHT) {
						holdTime += elapsed;
						if(holdTime > 0.5) {
							curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
						}

						if(curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
						else if(curTime < 0) curTime += FlxG.sound.music.length;
						updateSkipTimeText();
					}
			}

			//if (accepted && (cantUnpause <= 0 || !ClientPrefs.controllerMode))
			if (accepted && cantUnpause <= 0) {
				if (menuItems == difficultyChoices) {
					if(menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected)) {
						var name:String = PlayState.SONG.song;
						var poop = Highscore.formatSong(name, curSelected);
						PlayState.SONG = Song.loadFromJson(poop, name);
						PlayState.storyDifficulty = curSelected;
						MusicBeatState.resetState();
						FlxG.sound.music.volume = 0;
						PlayState.changedDifficulty = true;
						PlayState.chartingMode = false;
						return;
					}

					menuItems = menuItemsOG;
					regenMenu();
				}

				switch (daSelected) {
					case "Continuar":
						optionAccepted = true;
						returnToGame();
						selectedEffect();
					case 'Trocar Dificuldade':
						menuItems = difficultyChoices;
						deleteSkipTimeText();
						regenMenu();
						selectedEffect();
					case 'Modo Pratico':
						PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
						PlayState.changedDifficulty = true;
						practiceText.visible = PlayState.instance.practiceMode;
						selectedEffect();
					case "Reiniciar fase":
						optionAccepted = true;
						FlxTween.tween(backEngine.scale, {x: 1.3, y: 1.3}, 0.1, {ease: FlxEase.quadInOut, onComplete:
							function (twn:FlxTween) {
								PlayState.restartSkipCountdown = false;
								restartSong();
							}
						});
						selectedEffect();
					case "Deixar Editor de Notas":
						optionAccepted = true;
						FlxTween.tween(backEngine.scale, {x: 1.3, y: 1.3}, 0.1, {ease: FlxEase.quadInOut, onComplete:
							function (twn:FlxTween) {
								PlayState.restartSkipCountdown = false;
								restartSong();
							}
						});
						PlayState.chartingMode = false;
						selectedEffect();
					case 'Pular Tempo':
						optionAccepted = true;
						if(curTime < Conductor.songPosition) {
							PlayState.startOnTime = curTime;
							PlayState.restartSkipCountdown = false;
							restartSong(true);
						} else {
							if (curTime != Conductor.songPosition) {
								PlayState.instance.clearNotesBefore(curTime);
								PlayState.instance.setSongTime(curTime);
							}
							close();
						}
						selectedEffect();
					case "Terminar Musica":
						optionAccepted = true;
						FlxTween.tween(backEngine.scale, {x: 1.3, y: 1.3}, 0.1, {ease: FlxEase.quadInOut, onComplete:
							function (twn:FlxTween) {
								close();
								PlayState.instance.finishSong(true);
							}
						});
						selectedEffect();
					case 'Botplay':
						PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
						PlayState.changedDifficulty = true;
						PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
						PlayState.instance.botplayTxt.alpha = 1;
						PlayState.instance.botplaySine = 0;
						selectedEffect();
					case 'Ajustes':
						optionAccepted = true;
						FlxTween.tween(backEngine.scale, {x: 1.3, y: 1.3}, 0.1, {ease: FlxEase.quadInOut, onComplete:
							function (twn:FlxTween) {
								wasinsongbeforethenwenttooptions = true;
								PlayState.deathCounter = 0;
								PlayState.restartSkipCountdown = false;
								PlayState.seenCutscene = false;
								MusicBeatState.switchState(new options.OptionsState());
								//FlxG.sound.playMusic(Paths.music('freakyOptions'));
							}
						});
						selectedEffect();
					case 'Config Gameplay':
						FlxTween.tween(backEngine.scale, {x: 1.3, y: 1.3}, 0.1, {ease: FlxEase.quadInOut, onComplete:
							function (twn:FlxTween) {
								close();
								PlayState.instance.openChangersMenu();
							}
						});
						selectedEffect();
					case "Sair":
						optionAccepted = true;
						FlxTween.tween(backEngine.scale, {x: 1.3, y: 1.3}, 0.1, {ease: FlxEase.quadInOut, onComplete:
							function (twn:FlxTween) {
								PlayState.deathCounter = 0;
								PlayState.restartSkipCountdown = false;
								PlayState.seenCutscene = false;
			
								WeekData.loadTheFirstEnabledMod();
								if(PlayState.isStoryMode) {
									MusicBeatState.switchState(new StoryMenuState());
								} else {
									MusicBeatState.switchState(new FreeplayState());
								}
								PlayState.cancelMusicFadeTween();
								FlxG.sound.playMusic(Paths.music('freakyMenu'));
								PlayState.changedDifficulty = false;
								PlayState.chartingMode = false;
							}
						});
						selectedEffect();
				}
			}
		}
	}

	function deleteSkipTimeText()
	{
		if(skipTimeText != null)
		{
			skipTimeText.kill();
			remove(skipTimeText);
			skipTimeText.destroy();
		}
		skipTimeText = null;
		skipTimeTracker = null;
	}

	private function selectedEffect() {
		FlxG.sound.play(Paths.sound('confirmOption'), 0.4);
	}

	private function returnToGame() {
		FlxTween.tween(backEngine.scale, {x: 1.3, y: 1.3}, 0.1, {ease: FlxEase.quadInOut,
			startDelay: 0.2,
			onComplete:
			function (twn:FlxTween) {
				close();
			}
		});
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));

				if(item == skipTimeTracker)
				{
					curTime = Math.max(0, Conductor.songPosition);
					updateSkipTimeText();
				}
			}
		}
	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length) {
			var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
			item.isMenuItem = true;
			item.targetY = i;
			grpMenuShit.add(item);

			if(menuItems[i] == 'Pular Tempo')
			{
				skipTimeText = new FlxText(0, 0, 0, '', 64);
				skipTimeText.setFormat(Paths.font("crash.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				skipTimeText.scrollFactor.set();
				skipTimeText.borderSize = 2;
				skipTimeTracker = item;
				add(skipTimeText);

				updateSkipTextStuff();
				updateSkipTimeText();
			}
		}
		curSelected = 0;
		changeSelection();
	}
	
	function updateSkipTextStuff()
	{
		if(skipTimeText == null || skipTimeTracker == null) return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText()
	{
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}
}
