package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Cor Nota', 'Controles', 'Gameplay', 'Graficos', 'Visual e UI', 'Editor de Nota', 'Ajustar Delay e Combo'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Cor Nota':
				openSubState(new options.NotesSubState());
			case 'Controles':
				openSubState(new options.ControlsSubState());
			case 'Graficos':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visual e UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Ajustar Delay e Combo':
				LoadingState.loadAndSwitchState(new options.NoteOffsetState());
			case 'Editor de Nota':
				openSubState(new options.ChartEditorSettingsSubState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;
	var backEngine:FlxSprite;
	var frontEngine:FlxSprite;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		if (FlxG.sound.music == null) {
			FlxG.sound.playMusic(Paths.music('freakyOptions'), 0);
			FlxG.sound.music.fadeIn(0.2, 0, 1);
		} else {
			FlxG.sound.music.fadeOut(0.2, 0,
				function(fadeOut: FlxTween) {
				FlxG.sound.playMusic(Paths.music('freakyOptions'), 0);
				FlxG.sound.music.fadeIn(0.2, 0, 1);
			});
		}

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xff5a35ff;
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

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

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true, false);
			optionText.screenCenter();
			optionText.ID = i;
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);

			switch (i)//POSIÇÕES DOS ITENS DO MENU OPÇÕES (espaçamento de texto = 87).
			{
				case 0:					
					optionText.y = 64;
				case 1:
					optionText.y = 151;
				case 2:
					optionText.y = 238;
				case 3:
					optionText.y = 325;
				case 4:
					optionText.y = 412;
				case 5:
					optionText.y = 499;
				case 6:
					optionText.y = 586;
			}
		}
	
		selectorLeft = new Alphabet(0, 0, '>', true, false);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true, false);
		add(selectorRight);

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			frontEngine.animation.play('engineSpin', true, false);
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			frontEngine.animation.play('engineSpin', true, false);
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (PauseSubState.wasinsongbeforethenwenttooptions) {
				MusicBeatState.switchState(new PlayState());
				PauseSubState.wasinsongbeforethenwenttooptions = false;
				FlxG.sound.music.fadeOut(0.2, 0);
			} else {
				FlxG.sound.music.fadeOut(0.2, 0,
					function(fadeOut: FlxTween) {
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
						FlxG.sound.music.fadeIn(0.2, 0, 1);
				});
				MusicBeatState.switchState(new MainMenuState());
			}
		}

		if (controls.ACCEPT) {
			openSelectedSubstate(options[curSelected]);
			frontEngine.animation.play('engineSpin', true, false);
			FlxG.sound.play(Paths.sound('confirmOption'));
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
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		//FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}