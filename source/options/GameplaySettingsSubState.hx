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
			'Marque isto se for jogar com um controle em vez de teclado.',
			'controllerMode',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Rolagem Abaixo',
			'Se marcado, as notas vem de cima para baixo.',
			'downScroll',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Rolagem Centralizada',
			'Se marcado, suas notas serão centralizadas.',
			'middleScroll',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Exibir MS ao acertar',
			'Se marcado, a janela de acerto (em ms) vai aparecer perto das notas',
			'showMsText',
			'bool',
			false);
		addOption(option);
		/*
		var option:Option = new Option('Ocultar Notas Oponente',
			'Se marcado, oculta as notas do oponente nas partidas.',
			'opponentStrums',
			'bool',
			false);
		addOption(option);
		*/
		var option:Option = new Option('Ghost Tapping',
			'Se marcado, voce não vai errar ao pressionar as teclas enquanto\nnão houver notas que possam ser acertadas. Desativado no modo Nsano.',
			'ghostTapping',
			'bool',
			false);
		addOption(option);
		/*
		var option:Option = new Option('Remove Nsano!!! do Julgamento',
			'Se marcado, remove o julgamento Nsano!!!',
			'removePerfects',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Note Camera Movement',
			'Se marcado, a camera se move ao acertar a nota',
			'cameramoveonnotes',
			'bool',
			true);
		addOption(option);
		*/
		var option:Option = new Option('Desativar Tecla Resete',
			'Se marcado, ao pressionar a tecla Redefinir não acontecerá nada.',
			'noReset',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Volume do Tick de Nota',
			'Cada nota acertada vai fazer um \"Tick!\" quando acertada.',
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

		var option:Option = new Option('Visibilidade das Notas Longas',
			'As linhas das notas longas serao mostradas com a visibilidade selecionada',
			'holdNoteVisibility',
			'percent',
			1);
		addOption(option);
		option.scrollSpeed = 1;
		option.minValue = 0.1;
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
		
		/*
		var option:Option = new Option('Rating Offset',
			'Altera o quão cedo/tarde você tem que acertar para um "Whoa!"\nValores mais altos significam ter que acertar mais tarde.',
			'ratingOffset',
			'int',
			0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Tempo Acerto do nsano!!!',
			'Altera a quantidade de tempo que você tem\npara acertar um \"Nsano!!!\" em milissegundos.',
			'perfectWindow',
			'int',
			10);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 1;
		option.maxValue = 10;
		addOption(option);

		var option:Option = new Option('Tempo Acerto do whoa!!',
			'Altera a quantidade de tempo que você tem\npara acertar um \"Whoa!!\" em milissegundos.',
			'sickWindow',
			'int',
			45);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15;
		option.maxValue = 45;
		addOption(option);

		var option:Option = new Option('Tempo Acerto do boa!',
			'Altera a quantidade de tempo que você tem\npara acertar um "Boa!" em milissegundos.',
			'goodWindow',
			'int',
			90);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 15;
		option.maxValue = 90;
		addOption(option);

		var option:Option = new Option('Tempo Acerto do ruim',
			'Altera a quantidade de tempo que você tem\npara acertar um "Ruim" em milissegundos.',
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
		*/
		super();
	}

	function onChangeHitsoundVolume()
	{
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
	}
}