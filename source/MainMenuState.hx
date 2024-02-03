package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import ColorblindFilters;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var wumpaEngineVersion:String = '1.5.1';
	public static var curSelected:Int = 0;
	public static var firstStart:Bool = true;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionsGroup:Array<String> = [
		'story_mode',
		'freeplay',
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'options',
		'exit'
	];
		//#if MODS_ALLOWED 'mods', #end
		//'credits',
		//'donate',
		//'discord',

	#if MODS_ALLOWED
	var customOption:String;
	var	customOptionLink:String;
	#end

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	var backEngine:FlxSprite;
	var frontEngine:FlxSprite;
	var version1Box:FlxSprite;
	var version2Box:FlxSprite;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();
		if (ClientPrefs.colorblindMode != null) ColorblindFilters.applyFiltersOnGame(); // applies colorbind filters, ok?

		#if desktop
		// Updating Discord Rich Presence

		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];
		//camera.zoom = 1.85;

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		//var yScroll:Float = Math.max(0.25 - (0.05 * (optionsGroup.length - 4)), 0.1);
		var yScroll:Float = 0;
        var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
        bg.scrollFactor.set(0, yScroll);
        bg.setGraphicSize(Std.int(bg.width * 1.175));
        bg.updateHitbox();
        bg.screenCenter();
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        add(bg);

        if(ClientPrefs.themedmainmenubg == true) {

            var themedBg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
            themedBg.scrollFactor.set(0, yScroll);
            themedBg.setGraphicSize(Std.int(bg.width));
            themedBg.updateHitbox();
            themedBg.screenCenter();
            themedBg.antialiasing = ClientPrefs.globalAntialiasing;
            add(themedBg);

            var hours:Int = Date.now().getHours();
            if(hours > 18) {
                themedBg.color = 0x545f8a; // 0x6939ff
            } else if(hours > 8) {
                themedBg.loadGraphic(Paths.image('menuBG'));
            }
        }

        camFollow = new FlxObject(0, 0, 1, 1);
        camFollowPos = new FlxObject(0, 0, 1, 1);
        add(camFollow);
        add(camFollowPos);

        magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
        magenta.scrollFactor.set(0, yScroll);
        magenta.setGraphicSize(Std.int(magenta.width * 1.175));
        magenta.updateHitbox();
        magenta.screenCenter();
        magenta.visible = false;
        magenta.antialiasing = ClientPrefs.globalAntialiasing;
        magenta.color = 0xff7371fd;
        add(magenta);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 0.7;
		/*if(optionsGroup.length > 6) {
			scale = 6 / optionsGroup.length;
		}*/

		backEngine = new FlxSprite().loadGraphic(Paths.image('mainmenu/menuEngine'));
        backEngine.scrollFactor.set(0, 0);
        backEngine.setGraphicSize(Std.int(backEngine.width * 1));
        backEngine.screenCenter();
        backEngine.antialiasing = ClientPrefs.globalAntialiasing;
        add(backEngine);

		frontEngine = new FlxSprite();
		frontEngine.frames = Paths.getSparrowAtlas('mainmenu/engine');
		frontEngine.animation.addByPrefix('engineSpin', 'engineSpin', 24, false);
		frontEngine.animation.play('engineSpin', true, false);
        frontEngine.scrollFactor.set(0, 0);
		frontEngine.x = FlxG.width - 230;
		frontEngine.y = -10;
		frontEngine.antialiasing = ClientPrefs.globalAntialiasing;
		add(frontEngine);

		var curoffset:Float = 100;
		#if MODS_ALLOWED
		pushModMenuItemsToList(Paths.currentModDirectory);
		#end

		for (i in 0...optionsGroup.length) {
			var offset:Float = 108 - (Math.max(optionsGroup.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(curoffset, (i * 140) + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionsGroup[i]);
			menuItem.animation.addByPrefix('idle', optionsGroup[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionsGroup[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionsGroup.length - 4) * 0.135;
			if(optionsGroup.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			//curoffset = curoffset + 20;
			var size:Float = 0.5;

			switch (i) { //ITENS DO MENU E SUAS POSIÇÕES/TAMANHOS
				case 0: //aventura
					menuItem.x = 320;
					menuItem.y = 80;
					menuItem.scale.x = size;
					menuItem.scale.y = size;
				case 1: //modo livre
					menuItem.x = 330;
					menuItem.y = 210;
					menuItem.scale.x = size;
					menuItem.scale.y = size;
				case 2: //missões
					menuItem.x = 324;
					menuItem.y = 300;
					menuItem.scale.x = size - 0.1;
					menuItem.scale.y = size - 0.1;
				case 3: //opções
					menuItem.x = 420;
					menuItem.y = 440;
					menuItem.scale.x = size;
					menuItem.scale.y = size;
				case 4: //sair
					menuItem.x = 390;
					menuItem.y = 520;
					menuItem.scale.x = size - 0.2;
					menuItem.scale.y = size - 0.23;
			}

			/*if(FlxG.save.data.antialiasing)
				{
				 menuItem.antialiasing = true;
				}
			   	if (firstStart)
				FlxTween.tween(menuItem,{y: 1 + (i * 120)}, 0.5 + (i * 0.25), {ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
				{ 
					changeItem();
				}});
			   	else
				menuItem.y = 1 + (i * 120);*/			//Por algum motivo idiota eu não consigo definir a posição y dos itens 'missões' e 'sair' após essa animação. Se VOCÊ consegue arrumar isso, entre em contato
		}

		//firstStart = false; //fim

		FlxG.camera.follow(camFollowPos, null, 1);

		version1Box = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		version1Box.alpha = 0.5;
		version1Box.scrollFactor.set();
		version1Box.setPosition(-60, 695);
		version1Box.setGraphicSize(400, 50);
		version1Box.updateHitbox();
		add(version1Box);

		version2Box = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		version2Box.alpha = 0.5;
		version2Box.scrollFactor.set();
		version2Box.setPosition(1040, 695);
		version2Box.setGraphicSize(400, 50);
		version2Box.updateHitbox();
		add(version2Box);

		var versionWumpa:FlxText = new FlxText(FlxG.width * 0.01, FlxG.height - 21, 0, "Wumpa Engine v" + wumpaEngineVersion + " - por Bioxcis-dono", 24);
		versionWumpa.scrollFactor.set();
		versionWumpa.setFormat("CCZoinks Regular", 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionWumpa);
		var versionFNF:FlxText = new FlxText(FlxG.width * 0.82, FlxG.height - 21, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 24);
		versionFNF.scrollFactor.set();
		versionFNF.setFormat("CCZoinks Regular", 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionFNF);
		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if MODS_ALLOWED
	private var modsAdded:Array<String> = [];
	function pushModMenuItemsToList(folder:String)
	{
		if(modsAdded.contains(folder)) return;

		var menuitemsFile:String = null;
		if(folder != null && folder.trim().length > 0) menuitemsFile = Paths.mods(folder + '/data/menuitems.txt');
		else menuitemsFile = Paths.mods('data/menuitems.txt');

		if (FileSystem.exists(menuitemsFile))
		{
			var firstarray:Array<String> = File.getContent(menuitemsFile).split('\n');
			if (firstarray[0].length > 0) {
				var arr:Array<String> = firstarray[0].split('||');
				//if(arr.length == 1) arr.push(folder);
				optionsGroup.push(arr[0]);
				customOption = arr[0];
				customOptionLink = arr[1];
			}
		}
		modsAdded.push(folder);
	}
	#end


	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('crash/cristal'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;
	var currentFrame:Int = 0;
	override function update(elapsed:Float) {
		if(FlxG.sound.music.volume < 0.8) {
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		menuItems.forEach(function(spr:FlxSprite) {
			if (spr.animation.curAnim.name == 'idle') {
				currentFrame = spr.animation.curAnim.curFrame;
			}	
		});

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin) {
			if (controls.UI_UP_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				frontEngine.animation.play('engineSpin', true, false);
				changeItem(-1);
			}

			if (controls.UI_DOWN_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				frontEngine.animation.play('engineSpin', true, false);
				changeItem(1);
			}

			if (controls.BACK) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT) {
				if (optionsGroup[curSelected] == 'donate') {
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				} else if (optionsGroup[curSelected] == customOption) {
					CoolUtil.browserLoad(customOptionLink);
				} else {
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmFall'));
					frontEngine.animation.play('engineSpin', true, false);

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite) {
						if (curSelected != spr.ID) {
							/*
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
							*/
							FlxTween.tween(spr, {y: 1100}, 2, {ease: FlxEase.backInOut, type: ONESHOT, onComplete: function(twn:FlxTween) {
								spr.kill();
							}});
						} else {
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker) {
								var daChoice:String = optionsGroup[curSelected];

								switch (daChoice) {
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									//#if MODS_ALLOWED
									//case 'mods':
									// 	MusicBeatState.switchState(new ModsMenuState()); 
									//#end
									//case 'credits':
									//	MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState(), false, false);
									case 'exit':
										MusicBeatState.switchState(new GameExitState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys)) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('debugSecret'));
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite) {
			//spr.screenCenter(X);
		});
	}

	override function beatHit() {
		super.beatHit();
		
		if (curBeat % 4 == 2) {
			FlxG.camera.zoom = 1.02;
		}
	}

	var prevSelected: Int = 999;
	function changeItem(huh:Int = 0) {
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite) {
			// spr.updateHitbox();
			// spr.scale.x = 0.7;
			// spr.scale.y = 0.7;

			if (spr.ID == prevSelected) {
				spr.animation.play('idle', false, false, currentFrame);
				spr.scale.x -= 0.1;
				spr.scale.y -= 0.1;
			}
			if (spr.ID == curSelected) {
				spr.animation.play('selected');
				spr.scale.x += 0.1;
				spr.scale.y += 0.1;
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				// spr.centerOffsets();
			}
		});
		prevSelected = curSelected;
	}
}
