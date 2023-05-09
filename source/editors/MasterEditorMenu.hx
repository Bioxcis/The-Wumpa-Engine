package editors;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.system.FlxSound;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class MasterEditorMenu extends MusicBeatState
{
	var options:Array<String> = [
		'Editor Semana',
		'Editor Personagem Menu',
		'Editor Dialogo',
		//'Editor Notas',
		'Editor Figura Dialogo',
		'Editor Personagem'
		//'Editor Estagios (ALPHA)'
	];
	private var grpTexts:FlxTypedGroup<Alphabet>;
	private var directories:Array<String> = [null];

	private var curSelected = 0;
	private var curDirectory = 0;
	private var directoryTxt:FlxText;

	var backEngine:FlxSprite;
	var frontEngine:FlxSprite;

	override function create()
	{
		FlxG.camera.bgColor = FlxColor.BLACK;
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Editors Main Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = 0xFF234135;
		add(bg);

		grpTexts = new FlxTypedGroup<Alphabet>();
		add(grpTexts);

		for (i in 0...options.length)
		{
			var leText:Alphabet = new Alphabet(0, (70 * i) + 30, options[i], true, false);
			leText.isMenuItem = true;
			leText.targetY = i;
			grpTexts.add(leText);
		}

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
		
		#if MODS_ALLOWED
		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 42).makeGraphic(FlxG.width, 42, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		directoryTxt = new FlxText(textBG.x, textBG.y + 4, FlxG.width, '', 32);
		directoryTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		directoryTxt.scrollFactor.set();
		add(directoryTxt);
		
		for (folder in Paths.getModDirectories())
		{
			directories.push(folder);
		}

		var found:Int = directories.indexOf(Paths.currentModDirectory);
		if(found > -1) curDirectory = found;
		changeDirectory();
		#end
		changeSelection();

		FlxG.mouse.visible = false;
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P)
		{
			frontEngine.animation.play('engineSpin', true, false);
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			frontEngine.animation.play('engineSpin', true, false);
			changeSelection(1);
		}
		#if MODS_ALLOWED
		if(controls.UI_LEFT_P)
		{
			frontEngine.animation.play('engineSpin', true, false);
			changeDirectory(-1);
		}
		if(controls.UI_RIGHT_P)
		{
			frontEngine.animation.play('engineSpin', true, false);
			changeDirectory(1);
		}
		#end

		if (controls.BACK)
		{
			frontEngine.animation.play('engineSpin', true, false);
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			switch(options[curSelected]) {
				case 'Editor Personagem':
					LoadingState.loadAndSwitchState(new CharacterEditorState(Character.DEFAULT_CHARACTER, false));
				case 'Editor Semana':
					LoadingState.loadAndSwitchState(new WeekEditorState());
				case 'Editor Personagem Menu':
					LoadingState.loadAndSwitchState(new MenuCharacterEditorState());
				case 'Editor Figura Dialogo':
					LoadingState.loadAndSwitchState(new DialogueCharacterEditorState(), false);
				case 'Editor Dialogo':
					LoadingState.loadAndSwitchState(new DialogueEditorState(), false);
				//case 'Editor Notas'://felt it would be cool maybe				//isso não é legal se o jogo não salva direito a edição e perde todo o trabalho das notas ao sair, não pretendo arrumar essa engine.
					//LoadingState.loadAndSwitchState(new ChartingState(), false);
				//case 'Editor Estagios (ALPHA)': // i'll finish it somedays... maybe....
					//LoadingState.loadAndSwitchState(new StageEditorState(), false);
			}
			FlxG.sound.music.volume = 0;
			frontEngine.animation.play('engineSpin', true, false);
			FlxG.sound.play(Paths.sound('confirmOption'));
			#if PRELOAD_ALL
			FreeplayState.destroyFreeplayVocals();
			#end
		}
		
		var bullShit:Int = 0;
		for (item in grpTexts.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;
	}

	#if MODS_ALLOWED
	function changeDirectory(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curDirectory += change;

		if(curDirectory < 0)
			curDirectory = directories.length - 1;
		if(curDirectory >= directories.length)
			curDirectory = 0;
	
		WeekData.setDirectoryFromWeek();
		if(directories[curDirectory] == null || directories[curDirectory].length < 1)
			directoryTxt.text = '< Nenhum Diretorio Mod Carregado >';
		else
		{
			Paths.currentModDirectory = directories[curDirectory];
			directoryTxt.text = '< Diretório Mod Carregado: ' + Paths.currentModDirectory + ' >';
		}
		directoryTxt.text = directoryTxt.text.toUpperCase();
	}
	#end
}