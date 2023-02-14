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
import ColorblindFilters;
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

class VisualsUISubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Visual e UI';
		rpcTitle = 'Menu Ajustes de Visual & UI'; //for Discord Rich Presence

		var option:Option = new Option('Splash da Nota',
			"Se desmarcado, acertar as notas \"Sick!\" nao vai mostrar splashes.",
			'noteSplashes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Esconder HUD',
			'Se marcado, oculta a maioria dos elementos do HUD.',
			'hideHud',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option("Modo Exibicao",
			'Se marcado, oculta todo o HUD e ativa o botplay.',
			'showcaseMode',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Esconder Marca dagua',
			'Se marcado, oculta a marca dagua no canto inferior esquerdo\ndurante a reproducao da musica.',
			'hideWatermark',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Trilha no Personagem',
			'Se ativo, gerava o efeito de trilha do Espirito de Thorns...\n!Disponivel apenas no Modo de Edicao de Notas!',
		/*	'characterTrail',				shit lol. i made better finally*/
			'bool',
			false);
		addOption(option);
		

		var option:Option = new Option('Esconder Ponts',
			'Se marcada, vai ocultar o texto ponts, a precisao e os erros\n abaixo da barra de saude na musica.',
			'hideScoreText',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Bop do Icone',
			'Classico igual ao icone do FNF original, OS igual ao icone do OS Engine.',
			'iconbops',
			'string',
			'OS',
			['OS', 'Classico']);
		addOption(option);

		/*var option:Option = new Option('Posicao do Texto Ponts',
			'Classico igual posicao do Psych Engine, Novo igual a posicao do OS Engine.',
			'scoreposition',
			'string',
			'Classico',
			['Classico', 'Novo']);
		addOption(option);
		*/
		var option:Option = new Option('Filtro daltonico',
			'Definir um filtro daltonico (torna o jogo mais jogavel para pessoas daltonicas).',
			'colorblindMode',
			'string',
			'Nada', 
			['Nada', 'Deuteranopia', 'Protanopia', 'Tritanopia']);
		option.onChange = ColorblindFilters.applyFiltersOnGame;
		addOption(option);
		
		var option:Option = new Option('Barra de Tempo:',
			"Como quer sua barra de tempo?",
			'timeBarType',
			'string',
			'Tempo Restante',
			['Tempo Restante', 'Tempo Recorrido', 'Nome da Musica', 'OS Tempo Restante', 'Desativado']);
		addOption(option);

		var option:Option = new Option('Luzes Piscantes',
			"Desmarque esta opcao se voce for sensivel a luzes piscantes!",
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Zoom da Camera',
			"Se desmarcada, a camera nao vai dar zoom nos hits da batida.",
			'camZooms',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Zoom no Texto Ponts no hit',
			"Se desmarcado, desativa o zoom do Texto de Ponts\nsempre que voce toca uma nota.",
			'scoreZoom',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Transparencia Barra de Vida',
			'Quao transparente deve ser a barra de vida e os icones.',
			'healthBarAlpha',
			'percent',
			1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		
		#if !mobile
		var option:Option = new Option('Contador de FPS',
			'Se desmarcado, oculta o contador de FPS.',
			'showFPS',
			'bool',
			true);
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end

		var option:Option = new Option('Plano de Fundo Tematico do Menu Principal',
			'Se marcado, a cor de fundo do menu principal depende da hora do dia.',
			'themedmainmenubg',
			'bool',
			false);
		option.defaultValue = false;
		addOption(option);
		

		/*
		var option:Option = new Option('Auto Title Skip',
			'If checked, automatically skips the title state.',
			'autotitleskip',
			'bool',
			false);
		option.defaultValue = false;
		addOption(option);
		*/

		var option:Option = new Option('Skin de Nota',
			"Qual aparencia quer para suas notas?",
			'noteSkinSettings',
			'string',
			'Classico',
			['Classico', 'Circulo']);
		addOption(option);
		
		var option:Option = new Option('Musica do Pause:',
			"Que musica prefere que toque ao pausar?",
			'pauseMusic',
			'string',
			'Tea Time',
			['Nada', 'Breakfast', 'Tea Time', 'Crash Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;
		
		#if CHECK_FOR_UPDATES
		var option:Option = new Option('Check for Updates',
			'On Release builds, turn this on to check for updates when you start the game.',
			'checkForUpdates',
			'bool',
			true);
		addOption(option);
		#end

		super();
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.pauseMusic == 'Nada')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)));

		changedMusic = true;
	}

	override function destroy()
	{
		if(changedMusic) FlxG.sound.playMusic(Paths.music('freakyMenu'));
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
	#end
}