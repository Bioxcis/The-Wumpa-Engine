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

class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Ajustes Gameplay';
		rpcTitle = 'Menu Ajustes de Jogo'; //for Discord Rich Presence

		var option:Option = new Option('Modo Controle',
			'Marque isto se quiser jogar com um controle em vez de teclado.',
			'controllerMode',
			'bool',
			false);
		addOption(option);

		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Scroll Abaixo', //Name
			'Se marcado, as notas vem de cima em vez de vir de baixo.', //Description
			'downScroll', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Exibir MS Offset ao acertar',
			'Se marcado, um deslocamento (em ms) vai aparecer perto das notas',
			'showMsText',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Scroll Centralizado',
			'Se marcada, suas notas serao centralizadas.',
			'middleScroll',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Ocultar Notas do Oponente',
			'Se marcado, oculta as flechas do oponente ao jogar.',
			'opponentStrums',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Ghost Tapping',
			"Se marcado, voce nao errara ao pressionar teclas\nenquanto nao houver notas que possam ser tocadas.",
			'ghostTapping',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Remove Perfect! do Julgamento',
			'Se marcada, remove o julgamento Perfect!',
			'removePerfects',
			'bool',
			false);
		addOption(option);

		/*
		var option:Option = new Option('Note Camera Movement',
			'If checked, camera will move when pressing notes',
			'cameramoveonnotes',
			'bool',					should fix this someday.
			true);
		addOption(option);
		*/

		var option:Option = new Option('Desativar Tecla Resete',
			"Se marcado, ao pressionar Redefinir nao vai acontecer nada.",
			'noReset',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Volume do Tick de Nota',
			'As notas farao \"Tick!\" quando acertadas."',
			'hitsoundVolume',
			'percent',
			0);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeHitsoundVolume;

		var option:Option = new Option('Visibilidade Notas Longas',
			'As linhas das notas longas serao mostradas com a visibilidade selecionada',
			'holdNoteVisibility',
			'percent',
			1);
		addOption(option);
		option.scrollSpeed = 1;
		option.minValue = 0.0;
		option.changeValue = 0.1;
		option.maxValue = 1;
		option.decimals = 1;

		var option:Option = new Option('Visibilidade Pista do Oponente',
			'Define a visibilidade da base da pista do oponente.',
			'opponentUnderlaneVisibility',
			'percent',
			0);
		addOption(option);	
		option.scrollSpeed = 1;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;

		var option:Option = new Option('Visibilidade Pista do Jogador',
			'Define a visibilidade da base da sua pista.',
			'underlaneVisibility',
			'percent',
			0);
		addOption(option);	
		option.scrollSpeed = 1;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		

		var option:Option = new Option('Rating Offset',
			'Altera o quao cedo/tarde voce tem que acertar para um "Sick!"\nValores mais altos significam ter que acertar mais tarde.',
			'ratingOffset',
			'int',
			0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Janela de Acerto do Perfect!',
			'Altera a quantidade de tempo que voce tem\npara acertar um "Perfect!" em milissegundos.',
			'perfectWindow',
			'int',
			10);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 1;
		option.maxValue = 10;
		addOption(option);

		var option:Option = new Option('Janela de Acerto do Sick!',
			'Altera a quantidade de tempo que voce tem\npara acertar um "Sick!" em milissegundos.',
			'sickWindow',
			'int',
			45);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15;
		option.maxValue = 45;
		addOption(option);

		var option:Option = new Option('Janela de Acerto do Good!',
			'Altera a quantidade de tempo que voce tem\npara acertar um "Good!" em milissegundos.',
			'goodWindow',
			'int',
			90);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 15;
		option.maxValue = 90;
		addOption(option);

		var option:Option = new Option('Janela de Acerto do Bad!',
			'Altera a quantidade de tempo que voce tem\npara acertar um "Bad!" em milissegundos.',
			'badWindow',
			'int',
			135);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15;
		option.maxValue = 135;
		addOption(option);

		var option:Option = new Option('Frames Salvos',
			'Altera quantos frames você tem para\ntocar uma nota mais cedo ou mais tarde.',
			'safeFrames',
			'float',
			10);
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);

		super();
	}

	function onChangeHitsoundVolume()
	{
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
	}
}