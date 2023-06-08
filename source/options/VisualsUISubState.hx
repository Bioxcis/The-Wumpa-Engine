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
			"Se marcado, ao acertar as notas \"Sick!\" vai mostrar efeitos de splash.",
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
			'Se marcado, oculta todo o HUD e ativa o Botplay.',
			'showcaseMode',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Esconder Texto de Exibicao',
			'Se marcado, oculta o texto de exibição no canto inferior esquerdo\ndurante a reprodução da música.',
			'hideWatermark',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Trilha no Personagem',
			'Gerava o efeito de trilha do Espirito de Thorns...\n!Disponivel apenas no Modo de Edição de Notas!',
		/*	'characterTrail',				shit lol. i made better finally*/
			'bool',
			false);
		addOption(option);
		

		var option:Option = new Option('Esconder Ponts',
			'Se marcada, vai ocultar o texto de pontuação, precisão e erros\nno inferior da HUD nas músicas.',
			'hideScoreText',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Bop do Icone',
			'Clássico igual aos ícones do FNF original / OS igual aos ícone do OS Engine.',
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
			['Classico', 'Novo']);			sla :/
		addOption(option);
		*/
		var option:Option = new Option('Filtro Daltonico',
			'Definir um filtro daltônico\n(torna o jogo mais acessível para pessoas daltônicas).',
			'colorblindMode',
			'string',
			'Nada', 
			['Nada', 'Deuteranopia', 'Protanopia', 'Tritanopia']);
		option.onChange = ColorblindFilters.applyFiltersOnGame;
		addOption(option);
		
		var option:Option = new Option('Barra de Tempo:',
			"Como você quer a sua barra de tempo?",
			'timeBarType',
			'string',
			'Tempo Restante',
			['Tempo Restante', 'Tempo Recorrido', 'Nome da Musica', 'OS Tempo Restante', 'Desativado']);
		addOption(option);

		var option:Option = new Option('Luzes Piscantes',
			"Desmarque esta opção se voce for sensível a luzes piscantes!",
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Zoom da Camera',
			"Se marcado, a câmera vai dar zoom nos hits da batida.",
			'camZooms',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Zoom no Texto Ponts no hit',
			"Se marcado, ativa o zoom do Texto de Pontuação\nsempre que você toca uma nota.",
			'scoreZoom',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Novo Tamanho Hud',
			"Se marcado, a HUD do jogo será alterada\npara um novo tamanho!",
			'hudSize',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Ativar Shaders',
			"Se marcado, as shaders estarão ativadas.\nDesative essa opção caso seu computador rejeite as shaders.",
			'shadersActive',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Ativar Julgamento',
			"Se marcado, todo julgamento de nota será contado e\napresentado na HUD.",
			'showStatus',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Transparencia da Vida',
			'Quão transparente deve ser a barra de vida e os ícones.',
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
			'Se marcado, exibe o contador de FPS.',
			'showFPS',
			'bool',
			false);
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end

		/*var option:Option = new Option('Plano de Fundo Tematico do Menu Principal',
			'Se marcado, a cor de fundo do menu principal depende da hora do dia.',
			'themedmainmenubg',
			'bool',
			false);
		option.defaultValue = false;
		addOption(option);

		var option:Option = new Option('Auto Title Skip',
			'If checked, automatically skips the title state.',
			'autotitleskip',
			'bool',
			false);
		option.defaultValue = false;
		addOption(option);
		*/

		var option:Option = new Option('Skin de Nota',
			"Qual aparência você quer para suas notas?",
			'noteSkinSettings',
			'string',
			'Classico',
			['Classico', 'Circulo']);
		addOption(option);
		
		var option:Option = new Option('Musica do Pause:',
			"Que música você prefere que toque ao pausar?",
			'pauseMusic',
			'string',
			'Crash Time',
			['Nada', 'Breakfast', 'Tea Time', 'Crash Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;
		
		#if CHECK_FOR_UPDATES
		var option:Option = new Option('Checar Updates',
			'Para versões em desenvolvimento, ative para checar por atualizações ao iniciar o jogo.',
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