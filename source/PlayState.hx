package;

//import flixel.addons.display.FlxShaderMaskCamera;
//using flixel.util.FlxSpriteUtil;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.effects.chainable.FlxOutlineEffect;
import flixel.addons.effects.chainable.FlxRainbowEffect;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.effects.chainable.FlxShakeEffect;
import flixel.addons.effects.chainable.FlxTrailEffect;
import flixel.addons.effects.chainable.IFlxEffect;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.FlxTrail;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.FlxGraphic;
import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.FlxFlicker;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxStringUtil;
import flixel.util.FlxCollision;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxSave;
import flixel.util.FlxAxes;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.FlxSubState;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxState;
import flixel.FlxGame;
import flixel.FlxG;

import openfl.utils.Assets as OpenFlAssets;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import openfl.events.KeyboardEvent;
import openfl.display.StageQuality;
import openfl.display.BlendMode;
import openfl.display.Shader;
import openfl.Lib;

import animateatlas.AtlasFrameMaker;
import editors.CharacterEditorState;
import editors.ChartingState;

import lime.utils.Assets;
import hscript.Interp;
import hscript.Parser;
import haxe.Json;
import haxe.Timer;

import WiggleEffect.WiggleEffectType;
import DynamicShaderHandler;
import Section.SwagSection;
import DialogueBoxPsych;
import Conductor.Rating;
import Note.EventNote;
import HscriptHandler;
import Song.SwagSong;
import Achievements;
import FunkinLua;
import StageData;
import Shaders;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

#if desktop
import Discord.DiscordClient;
#end

#if VIDEOS_ALLOWED
import vlc.MP4Handler;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

/* 	Original Stuff
	public static var ratingStuff:Array<Dynamic> = [
		['QUE?!', 0.2], 	//From 0% to 19%
		['PÉSSIMO!', 0.4], 	//From 20% to 39%
		['RUIM', 0.5], 		//From 40% to 49%
		['MEH', 0.6], 		//From 50% to 59%
		['BOA', 0.69], 		//From 60% to 68%
		['BOA', 0.7], 		//69%
		['YEAH!', 0.8], 	//From 70% to 79%
		['WHOA!', 0.9], 	//From 80% to 89%
		['NSANO!', 1], 		//From 90% to 99%
		['NSANO!', 1] 		//The value on this one isn't used actually, since Perfect is always "1"
	];	*/

	public static var ratingStuff:Array<Dynamic> = [
	/* 	RatingName		Percent		 FC			*/
		['NSANO!!!',	0.988, 	   'SSS+'],	  //Between 100% and 98.8%
		['WHOA!!',		0.96, 	   'SS'], 	  //Between 98.8% and 96%
		['YEAH!', 		0.92, 	   'S+'], 	  //Between 97% and 92%
		['LOUCO!', 		0.86, 	   'A+'], 	  //Between 92% and 86%
		['BOM!', 		0.8,       'A'], 	  //Between 86% and 80%
		['ACEITÁVEL', 	0.7, 	   'B+'], 	  //Between 80% and 70%
		['MEH', 		0.6,       'B'], 	  //Between 70% and 60%
		['RUIM', 		0.45,      'C'], 	  //Between 60% and 45%
		['PÉSSIMO', 	0.3,       'D'], 	  //Between 45% and 30%
		['BRUH', 		0.2,       'E'], 	  //Between 30% and 20%
		['HORRÍVEL', 	0,    	   'F'] 	  //Between 20% and 0%
	];

	public static var ratingJudges:Array<String> = ['UGH', 'RUIM', 'BOA', 'WHOA', 'NSANO', 'COMBO'];
	
	#if LUA_ALLOWED
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartSkeweds:Map<String, FlxSkewedSprite> = new Map<String, FlxSkewedSprite>();
	public var modchartEffectSprites:Map<String, FlxEffectSprite> = new Map<String, FlxEffectSprite>();
	public var modchartTrailAreas:Map<String, FlxTrailArea> = new Map<String, FlxTrailArea>();
	public var modchartTrails:Map<String, FlxTrail> = new Map<String, FlxTrail>();
	public var modchartEmitters:Map<String, FlxEmitter> = new Map<String, FlxEmitter>();

	public var modchartFlickers:Map<String, FlxFlicker> = new Map<String, FlxFlicker>();
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();

	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, FlxText> = new Map<String, FlxText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	public var modchartBars:Map<String, FlxBar> = new Map<String, FlxBar>();

	public var modchartWaveEffects:Map<String, FlxWaveEffect> = new Map<String, FlxWaveEffect>();
	public var modchartShakeEffects:Map<String, FlxShakeEffect> = new Map<String, FlxShakeEffect>();
	public var modchartGlitchEffects:Map<String, FlxGlitchEffect> = new Map<String, FlxGlitchEffect>();
	public var modchartRainbowEffects:Map<String, FlxRainbowEffect> = new Map<String, FlxRainbowEffect>();
	public var modchartOutlineEffects:Map<String, FlxOutlineEffect> = new Map<String, FlxOutlineEffect>();
	//public var modchartTrailEffects:Map<String, FlxTrailEffect> = new Map<String, FlxTrailEffect>();

	public var flxBarTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	#end

	//event variables
	public static var animatedShaders:Map<String, DynamicShaderHandler> = new Map<String, DynamicShaderHandler>();
	public var shader_chromatic_abberation:ChromaticAberrationEffect;

	public var camGameShaders:Array<ShaderEffect> = [];
	public var camHUDShaders:Array<ShaderEffect> = [];
	public var camOtherShaders:Array<ShaderEffect> = [];

	private var isCameraOnForcedPos:Bool = false;

	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var luaCharsMap:Map<String, LuaChar> = new Map<String, LuaChar>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicativo";
	public var noteKillOffset:Float = 350;

	public var isVanillaSong:Bool = false;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public var shaderUpdates:Array<Float->Void> = [];
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public var isGhostTapping:Bool = false;
	public var fullComboFunction:Void->Void = null;

	public var spawnTime:Float = 2000;

	public var vocals:FlxSound;
	public var vocalGeneralVol:Float = 1;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	//cam code
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var laneunderlay:FlxSprite;
    public var laneunderlayOp:FlxSprite;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	public var startInvisible:Bool = false;

	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBarOverlay:FlxSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	public var ratingsData:Array<Rating> = [];
	public var perfects:Int = 0;
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	public static var mania:Int = 0;

	public var statusCancelStartTween:Bool = false;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;
	public var bubble:Int = 0;
	public var isNoHIT:Bool = false;
	public var daTaeb:Int = 0;

	private var tweenGet:FlxTween;
	private var tweenReady:FlxTween;
	private var tweenSet:FlxTween;
	private var tweenGo:FlxTween;
	private var iconP1Tween:FlxTween;
	private var iconP2Tween:FlxTween;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	var trailunderdad:FlxTrail;
	var trailunderbf:FlxTrail;
	var trailundergf:FlxTrail;

	var dancingLeft:Bool = false;

	var wiggleShit:WiggleEffect = new WiggleEffect();
	
	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	public var songTxt:FlxText;

	var allNotesMs:Float = 0;
	var averageMs:Float = 0;

	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	var msTimeTxt:FlxText;
	var msTimeTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;

	public static var deathCounter:Int = 0;

	// Cameras
	public var camZooming:Bool = false;
	public var camZoomingDecay:Float = 1;
	public var camZoomingMult:Float = 1;

	public var defaultCamZoom:Float = 1.05;
	public var defaultHudZoom:Float = 1.0;
	public var defaultOthZoom:Float = 1.0;

	public var camGameZooming:Float = 0.015;
	public var camHudZooming:Float = 0.03;
	public var camOtherZooming:Float = 0;

	// Pixel Assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;

	var songLength:Float = 0;
	var instCurTime:Float = 0;
	var voicesCurTime:Float = 0;

	// Restart With no Countdown (set on Lua)
	public static var restartSkipCountdown:Bool = false;

	// Characters Camera
	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var storyDifficultyDiscordText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	// Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua Assets
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	public var hscriptArray:Map<String, Interp> = []; // it should work like luaarray. String is tag and interp is actual hscript interp
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';
	public var luaShaders:Map<String, DynamicShaderHandler> = new Map<String, DynamicShaderHandler>();

	// Debug Buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	private var controlArray:Array<String>; //hmm...

	public var precacheList:Map<String, String> = new Map<String, String>();
	public var songName:String;

	// Callbacks for stages
	public var startCallback:Void->Void = null;
	public var endCallback:Void->Void = null;

	override public function create()
	{
		Paths.clearStoredMemory();

		// for lua
		instance = this;

		startCallback = startCountdown;
		endCallback = endSong;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));

		PauseSubState.songName = null; //Reset to default
		fullComboFunction = fullComboUpdate;

		// keysArray = [
		// 	ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
		// 	ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
		// 	ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
		// 	ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		// ];
		keysArray = EKData.Keybinds.fill();

		isGhostTapping = ClientPrefs.ghostTapping;

		//Ratings
		if(!ClientPrefs.removePerfects) ratingsData.push(new Rating('perfect'));

		var rating:Rating = new Rating('sick');
		rating.ratingMod = 1;
		rating.score = 350;
		rating.noteSplash = true;
		ratingsData.push(rating);

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.7;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.4;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);

		// For the "Just the Two of Us" achievement
		//for (i in 0...keysArray.length) {
		for (i in 0...keysArray[mania].length) {
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		mania = SONG.mania;
		if (mania < Note.minMania || mania > Note.maxMania)
			mania = Note.defaultMania;
		//trace("song keys: " + (mania + 1) + " / mania value: " + mania);

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		var s_termination = "s";
		if (mania == 0) s_termination = "";

		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];
		storyDifficultyDiscordText = CoolUtil.difficulties[storyDifficulty] + ", " + (mania + 1) + " key" + s_termination;

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode) detailsText = "Modo Aventura: " + WeekData.getCurrentWeek().weekName;
		else detailsText = "Jogo Livre";

		// String for when the game is paused
		detailsPausedText = "Pausado - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		
		songName = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		if(SONG.stage == null || SONG.stage.length < 1) {
			switch (songName) {
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
					isVanillaSong = true;
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					curStage = 'philly';
					isVanillaSong = true;
				case 'milf' | 'satin-panties' | 'high' | 'ridge':
					curStage = 'limo';
					isVanillaSong = true;
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
					isVanillaSong = true;
				case 'winter-horrorland':
					curStage = 'mallEvil';
					isVanillaSong = true;
				case 'senpai' | 'roses':
					curStage = 'school';
					isVanillaSong = true;
				case 'thorns':
					curStage = 'schoolEvil';
					isVanillaSong = true;
				case 'ugh' | 'guns' | 'stress':
					curStage = 'tank';
					isVanillaSong = true;
				default:
					curStage = 'stage';
					if(songName == 'bopeebo' || songName == 'fresh' 
					|| songName == 'dad-battle') isVanillaSong = true;
			}
		}
		SONG.stage = curStage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		// Stage couldn't be found, create a dummy stage for preventing a crash
		if(stageData == null) stageData = StageData.dummy();

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null)
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage) {
			case 'stage': new stages.StageWeek1(); //Week 1
			case 'spooky': new stages.Spooky(); //Week 2
			case 'philly': new stages.Philly(); //Week 3
			case 'limo': new stages.Limo(); //Week 4
			case 'mall': new stages.Mall(); //Week 5 - Cocoa, Eggnog
			case 'mallEvil': new stages.MallEvil(); //Week 5 - Winter Horrorland
			case 'school': new stages.School(); //Week 6 - Senpai, Roses
			case 'schoolEvil': new stages.SchoolEvil(); //Week 6 - Thorns
			case 'tank': new stages.Tank(); //Week 7 - Ugh, Guns, Stress
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup);
		add(dadGroup);
		add(boyfriendGroup);

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					} else if (file.endsWith('.hx') && !filesPushed.contains(file)) {
						var exparser = new Parser();
						exparser.allowMetadata = true;
						exparser.allowTypes = true;
						var parsedstring = exparser.parseString(File.getContent(folder + file));
						var interp = new Interp();
						interp = HscriptHandler.setVars(interp);
						//var interp = HscriptHandler.createInterpWithVars();

						interp.execute(parsedstring);
						hscriptArray.set(folder + file,interp);
						filesPushed.push(file);
						trace('ARQUIVO HSCRIPT CARREGADO: ' + folder + file);
					}
				}
			}
		}
		#end


		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush)
			luaArray.push(new FunkinLua(luaFile));
		#end

		var gfVersion:String = SONG.gfVersion;
		if (!stageData.hide_girlfriend) {
			if(gfVersion == null || gfVersion.length < 1)
				SONG.gfVersion = 'gf'; //Fix for the Chart Editor

			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null) {
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}
		stagesFunc(function(stage:BaseStage) stage.createPost());

		if (SONG.characterTrails) {
			trailunderdad = new FlxTrail(dad, null, 6, 5, 0.2, 0.01);
			insert(members.indexOf(dadGroup) - 1, trailunderdad);
		}
		if (SONG.bfTrails) {
			trailunderbf = new FlxTrail(boyfriend, null, 6, 5, 0.2, 0.01);
			insert(members.indexOf(boyfriendGroup) - 1, trailunderbf);
		}
		if (SONG.gfTrails) {
			trailundergf = new FlxTrail(gf, null, 6, 5, 0.2, 0.01);
			insert(members.indexOf(gfGroup) - 1, trailundergf);
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		laneunderlayOp = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlayOp.color = FlxColor.BLACK;
		laneunderlayOp.scrollFactor.set();
        laneunderlayOp.alpha = ClientPrefs.opponentUnderlaneVisibility-1;
        laneunderlayOp.visible = true;

		laneunderlay = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();
        laneunderlay.alpha = ClientPrefs.underlaneVisibility - 1;
        laneunderlay.visible = true;
		if (!ClientPrefs.middleScroll) 
		{
			add(laneunderlayOp);
		  }
	  	add(laneunderlay);

		var showTime:Bool = (ClientPrefs.timeBarType != 'Desativado');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 20, 400, "", 32);
		timeTxt.setFormat(Paths.font("crash.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if(isPixelStage) {
			timeTxt.font = Paths.font("pixel.otf");
			timeTxt.size = 16;
		}
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) {
			timeTxt.y = FlxG.height - 45;
			if(ClientPrefs.hudSize) timeTxt.y = FlxG.height - 15;
		} else {
			if(ClientPrefs.hudSize) timeTxt.y = -10;
		}
		if(ClientPrefs.timeBarType == 'Nome da Musica') timeTxt.text = SONG.song;
		updateTime = showTime;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this, 'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFF9100);
		timeBar.numDivisions = 600;	
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		msTimeTxt = new FlxText(0, 0, 400, "", 32);
		msTimeTxt.setFormat(Paths.font('crash.ttf'), 32, 0xFFFFE0A6, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if(isPixelStage) {
			msTimeTxt.font = Paths.font("pixel.otf");
			msTimeTxt.size = 16;
		}
		msTimeTxt.scrollFactor.set();
		msTimeTxt.alpha = 0;
		msTimeTxt.visible = true;
		msTimeTxt.borderSize = 2;
		add(msTimeTxt);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if(ClientPrefs.timeBarType == 'Nome da Musica') {
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		for (event in eventPushedMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_events/' + event + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		if(ClientPrefs.hudSize) defaultHudZoom = 0.9;

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		camHUD.zoom = defaultHudZoom;
		camOther.zoom = defaultOthZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection();

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		if(ClientPrefs.downScroll) {
			healthBarBG.y = 0.10 * FlxG.height;
			if(ClientPrefs.hudSize) healthBarBG.y = 0.04 * FlxG.height;
		} else {
			healthBarBG.y = FlxG.height * 0.88;
			if(ClientPrefs.hudSize) healthBarBG.y = FlxG.height * 0.92;
		}
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		healthBarOverlay = new FlxSprite().loadGraphic(Paths.image('healthBarOverlay'));
		healthBarOverlay.y = FlxG.height * 0.89;
		healthBarOverlay.screenCenter(X);
		healthBarOverlay.scrollFactor.set();
		healthBarOverlay.visible = !ClientPrefs.hideHud;
        healthBarOverlay.color = FlxColor.BLACK;
		healthBarOverlay.blend = MULTIPLY;
		healthBarOverlay.x = healthBarBG.x-1.9;
	    healthBarOverlay.alpha = ClientPrefs.healthBarAlpha;
		healthBarOverlay.antialiasing = ClientPrefs.globalAntialiasing;
		add(healthBarOverlay); healthBarOverlay.alpha = ClientPrefs.healthBarAlpha; if(ClientPrefs.downScroll) healthBarOverlay.y = 0.11 * FlxG.height;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();

		makeRatingStatus();

		scoreTxt = new FlxText(0, healthBarBG.y + 60, FlxG.width, "", 25);
		scoreTxt.setFormat(Paths.font("crash.ttf"), 25, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if(isPixelStage) {
			scoreTxt.font = Paths.font("pixel.otf");
			scoreTxt.size = 16;
		}
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.2;
		if(ClientPrefs.hideScoreText || ClientPrefs.hideHud) scoreTxt.visible = false;
		if(ClientPrefs.downScroll) scoreTxt.y = healthBarBG.y - 65;
		add(scoreTxt);

		songTxt = new FlxText(12, FlxG.height - 30, 0, "", 22);
		songTxt.setFormat(Paths.font("crash.ttf"), 22, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if(isPixelStage) {
			songTxt.font = Paths.font("pixel.otf");
			songTxt.size = 16;
		}
		songTxt.scrollFactor.set();
		songTxt.borderSize = 1;
		if(ClientPrefs.hideHud || ClientPrefs.hideWatermark) songTxt.visible = false;
		if(ClientPrefs.hudSize) {
			songTxt.y = FlxG.height + 10;
			songTxt.x = -40;
		}
		if(ClientPrefs.downScroll) {
			songTxt.y = FlxG.height * 0.01;
			if(ClientPrefs.hudSize) songTxt.y = FlxG.height * 0.01 - 35;			
		}
		add(songTxt);
		songTxt.text = curSong + " (" + storyDifficultyText + ")";

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("crash.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if(isPixelStage) {
			botplayTxt.font = Paths.font("pixel.otf");
			botplayTxt.size = 18;
		}
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) botplayTxt.y = timeBarBG.y - 78;

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];

		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		healthBarOverlay.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];

		songTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];

		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		msTimeTxt.cameras = [camHUD];
		laneunderlay.cameras = [camHUD];
		laneunderlayOp.cameras = [camHUD];

		startingSong = true;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/data/' + Paths.formatToSongPath(SONG.song) + '/' ));// using push instead of insert because these should run after everything else
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					} else if (file.endsWith('.hx') && !filesPushed.contains(file)) {
						var exparser = new Parser();
						exparser.allowMetadata = true;
						exparser.allowTypes = true;
						var parsedstring = exparser.parseString(File.getContent(folder + file));
						var interp = new Interp();
						interp = HscriptHandler.setVars(interp);
						//var interp = HscriptHandler.createInterpWithVars();

						interp.execute(parsedstring);
						hscriptArray.set(folder + file, interp);
						filesPushed.push(file);
						trace('ARQUIVO HSCRIPT CARREGADO: ' + folder + file);
					}
				}
			}
		}
		#end

		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode && !seenCutscene) {
			startCallback();
			seenCutscene = true;
		} else {
			startCallback();
		}
		RecalculateRating();

		//Precaching miss sounds
		if(ClientPrefs.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if(ClientPrefs.pauseMusic != 'Nada') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');
		}

		setDefaultCharacterCamPosOnLua();

		#if desktop
		// Updating Discord Rich Presence.
		//DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyDiscordText + ")", iconP2.getCharacter());
		DiscordClient.changePresence(detailsText, SONG.song + storyDifficultyDiscordText, iconP2.getCharacter());
		#end

		// if(!ClientPrefs.controllerMode)
		// {
		// 	FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		// 	FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		// }
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000;

		setOnLuas('maniaAnims', Note.keysShit.get(mania).get('anims'));
		setOnLuas('maniaControls', keysArray[mania]);
		setOnLuas('isVanillaSong', isVanillaSong);

		callOnLuas('onCreatePost', []);
		callOnHScripts('create', []);

		super.create();

		for (key => type in precacheList)
		{
			//trace('Key $key is type $type');
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}
		Paths.clearUnusedMemory();

		CustomFadeTransition.nextCamera = camOther;
		if (ClientPrefs.showcaseMode) {
			camHUD.visible = false;
			instance.cpuControlled = true;
		}
	}

	function setDefaultCharacterCamPosOnLua() {
		setOnLuas('boyfriendCamX', boyfriend.getMidpoint().x - 100 - (boyfriend.cameraPosition[0] - boyfriendCameraOffset[0]));
		setOnLuas('boyfriendCamY', boyfriend.getMidpoint().y - 100 + (boyfriend.cameraPosition[1] + boyfriendCameraOffset[1]));
		setOnLuas('dadCamX', dad.getMidpoint().x + 150 + (dad.cameraPosition[0] + opponentCameraOffset[0]));
		setOnLuas('dadCamY', dad.getMidpoint().y - 100 + (dad.cameraPosition[1] + opponentCameraOffset[1]));
		setOnLuas('gfCamX', gf.getMidpoint().x + 80 + (gf.cameraPosition[0] + girlfriendCameraOffset[0]));
		setOnLuas('gfCamY', gf.getMidpoint().y - 80 + (gf.cameraPosition[1] + girlfriendCameraOffset[1]));
	}
 
	var shitTxt:FlxText;
	var badTxt:FlxText;
	var goodTxt:FlxText;
	var sickTxt:FlxText;
	var perfectTxt:FlxText;
	var bestComboTxt:FlxText;

	private var statusLoaded:Bool = false;
	private function makeRatingStatus() {
		if(ClientPrefs.showStatus) {
			shitTxt = new FlxText(-300, FlxG.height * 0.4, 0, "", 20);
			shitTxt.setFormat(Paths.font("nsane.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			if(isPixelStage) {
				shitTxt.font = Paths.font("pixel.otf");
				shitTxt.size = 13;
			}
			shitTxt.borderSize = 1.8;
			shitTxt.scrollFactor.set();
			shitTxt.cameras = [camHUD];
			add(shitTxt);

			badTxt = new FlxText(-300, FlxG.height * 0.4 + 30, 0, "", 20);
			badTxt.setFormat(Paths.font("nsane.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			if(isPixelStage) {
				badTxt.font = Paths.font("pixel.otf");
				badTxt.size = 13;
			}
			badTxt.borderSize = 1.8;
			badTxt.scrollFactor.set();
			badTxt.cameras = [camHUD];
			add(badTxt);

			goodTxt = new FlxText(-300, FlxG.height * 0.4 + 60, 0, "", 20);
			goodTxt.setFormat(Paths.font("nsane.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			if(isPixelStage) {
				goodTxt.font = Paths.font("pixel.otf");
				goodTxt.size = 13;
			}
			goodTxt.borderSize = 1.8;
			goodTxt.scrollFactor.set();
			goodTxt.cameras = [camHUD];
			add(goodTxt);

			sickTxt = new FlxText(-300, FlxG.height * 0.4 + 90, 0, "", 20);
			sickTxt.setFormat(Paths.font("nsane.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			if(isPixelStage) {
				sickTxt.font = Paths.font("pixel.otf");
				sickTxt.size = 13;
			}
			sickTxt.borderSize = 1.8;
			sickTxt.scrollFactor.set();
			sickTxt.cameras = [camHUD];
			add(sickTxt);

			perfectTxt = new FlxText(-300, FlxG.height * 0.4 + 120, 0, "", 20);
			perfectTxt.setFormat(Paths.font("nsane.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			if(isPixelStage) {
				perfectTxt.font = Paths.font("pixel.otf");
				perfectTxt.size = 13;
			}
			perfectTxt.borderSize = 1.8;
			perfectTxt.scrollFactor.set();
			perfectTxt.cameras = [camHUD];
			add(perfectTxt);

			bestComboTxt = new FlxText(-300, FlxG.height * 0.4 + 150, 0, "", 20);
			bestComboTxt.setFormat(Paths.font("nsane.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			if(isPixelStage) {
				bestComboTxt.font = Paths.font("pixel.otf");
				bestComboTxt.size = 13;
			}
			bestComboTxt.borderSize = 1.8;
			bestComboTxt.scrollFactor.set();
			bestComboTxt.cameras = [camHUD];
			add(bestComboTxt);

			if(ClientPrefs.colorStatus) {
				shitTxt.color = 0xFFFF0000;
				badTxt.color = 0xFFFF8800;
				goodTxt.color = 0xFF00FF00;
				sickTxt.color = 0xFF0000FF;
				perfectTxt.color = 0xFF8800FF;
				bestComboTxt.color = 0xFF00DDFF;
			}
			statusLoaded = true;
		}
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed;
			for (note in notes) note.resizeByRatio(ratio);
			for (note in unspawnNotes) note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	public function addTextToDebug(text:String, color:FlxColor) {
		#if LUA_ALLOWED
		var newText:DebugLuaText = luaDebugGroup.recycle(DebugLuaText);
		newText.text = text;
		newText.color = color;
		newText.disableTime = 6;
		newText.alpha = 1;
		newText.setPosition(10, 8 - newText.height);

		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += newText.height + 2;
		});
		luaDebugGroup.add(newText);
		#end
	}

	public function reloadHealthBarColors() {
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));

		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	public function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		#if MODS_ALLOWED
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		#else
		luaFile = Paths.getPreloadPath(luaFile);
		if(Assets.exists(luaFile)) {
			doPush = true;
		}
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	public function addShaderToCamera(cam:String,effect:Dynamic) { //STOLE FROM ANDROMEDA	// actually i got it from old psych engine
		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud':
					camHUDShaders.push(effect);
					var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
					for(i in camHUDShaders){
					  newCamEffects.push(new ShaderFilter(i.shader));
					}
					camHUD.setFilters(newCamEffects);
			case 'camother' | 'other':
					camOtherShaders.push(effect);
					var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
					for(i in camOtherShaders){
					  newCamEffects.push(new ShaderFilter(i.shader));
					}
					camOther.setFilters(newCamEffects);
			case 'camgame' | 'game':
					camGameShaders.push(effect);
					var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
					for(i in camGameShaders){
					  newCamEffects.push(new ShaderFilter(i.shader));
					}
					camGame.setFilters(newCamEffects);
			default:
				if(modchartSprites.exists(cam)) {
					Reflect.setProperty(modchartSprites.get(cam),"shader",effect.shader);
				} else if(modchartTexts.exists(cam)) {
					Reflect.setProperty(modchartTexts.get(cam),"shader",effect.shader);
				} else {
					var OBJ = Reflect.getProperty(PlayState.instance,cam);
					Reflect.setProperty(OBJ,"shader", effect.shader);
				}
		}
	}

	public function removeShaderFromCamera(cam:String,effect:ShaderEffect) {
		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud': 
				camHUDShaders.remove(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in camHUDShaders) {
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camHUD.setFilters(newCamEffects);
			case 'camother' | 'other':
				camOtherShaders.remove(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in camOtherShaders) {
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camOther.setFilters(newCamEffects);
			default:
				if (modchartSprites.exists(cam)) {
					Reflect.setProperty(modchartSprites.get(cam), "shader", null);
				} else if (modchartTexts.exists(cam)) {
					Reflect.setProperty(modchartTexts.get(cam), "shader", null);
				} else {
					var OBJ = Reflect.getProperty(PlayState.instance, cam);
					Reflect.setProperty(OBJ, "shader", null);
				}
		}
	}
	
	public function clearShaderFromCamera(cam:String) {
		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud': 
				camHUDShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camHUD.setFilters(newCamEffects);
			case 'camother' | 'other': 
				camOtherShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camOther.setFilters(newCamEffects);
			case 'camgame' | 'game': 
				camGameShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camGame.setFilters(newCamEffects);
			default: 
				camGameShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camGame.setFilters(newCamEffects);
		}  
  	}

	public function getLuaObject(tag:String, text:Bool = true, bar:Bool = false, trails:Bool = false):FlxSprite {
		if(luaCharsMap.exists(tag)) return luaCharsMap.get(tag);
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(modchartSkeweds.exists(tag)) return modchartSkeweds.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		if(bar && modchartBars.exists(tag)) return modchartBars.get(tag);
		if(trails && modchartTrails.exists(tag)) return modchartTrails.get(tag);
		if(trails && modchartTrailAreas.exists(tag)) return modchartTrailAreas.get(tag);
		return null;
	}

	public function getLuaEmitter(tag:String):FlxEmitter {
		if(modchartEmitters.exists(tag)) return modchartEmitters.get(tag);
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String) {
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:MP4Handler = new MP4Handler();
		video.playVideo(filepath);
		video.finishCallback = function() {
			startAndEnd();
			return;
		}
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	function startAndEnd() {
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void {
		if(psychDialogue != null) return;
		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	public function updateLuaDefaultPos() {
		for (i in 0...playerStrums.length) {
			setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
			setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
		}
		for (i in 0...opponentStrums.length) {
			setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
			setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
			//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownGet:FlxSprite;
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	public function startCountdown():Void {
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}
		var songName:String = Paths.formatToSongPath(SONG.song);

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', [], false);
		if(ret != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			updateLuaDefaultPos();

			laneunderlay.x = playerStrums.members[0].x - 25;
			laneunderlay.screenCenter(Y);
		    laneunderlayOp.x = opponentStrums.members[0].x - 25;
		    laneunderlayOp.screenCenter(Y);

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			if (ClientPrefs.showMsText) {
				if (ClientPrefs.downScroll) {
					msTimeTxt.x = playerStrums.members[1].x-100;
					msTimeTxt.y = playerStrums.members[1].y+100;
				} else {
					msTimeTxt.x = playerStrums.members[1].x-100;
					msTimeTxt.y = playerStrums.members[1].y-50;
				}

				if (ClientPrefs.middleScroll) {
					msTimeTxt.x = playerStrums.members[0].x-250;
					msTimeTxt.y = playerStrums.members[1].y+30;
				}
			}

			if(startOnTime < 0) startOnTime = 0;

			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return;
			} else if (skipCountdown) {
				setSongTime(0);
				return;
			}
			moveCameraSection();

			firstCountdown = true;
			initializeCountdown();
		}
	}

	private var firstCountdown:Bool = false;
	private var countdownStarted:Bool = false;
	public function initializeCountdown(makeGo:Bool = true, cameOther:Bool = false) {
		if (!countdownStarted) {
			countdownStarted = true;

			var swagCounter:Int = 0;

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['get', 'ready', 'set', 'go']);
			introAssets.set('pixel', ['pixelUI/get-pixel', 'pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var antialias:Bool = ClientPrefs.globalAntialiasing;
			if(isPixelStage) {
				introAlts = introAssets.get('pixel');
				antialias = false;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer) {
				if(firstCountdown) {
					if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null
					  && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned) {
						gf.dance();
					}
					if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null
					  && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned) {
						boyfriend.dance();
					}
					if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null
					  && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned) {
						dad.dance();
					}
					for (luaChar in luaCharsMap) {
						if (tmr.loopsLeft % luaChar.danceEveryNumBeats == 0 && luaChar.animation.curAnim != null
						  && !luaChar.animation.curAnim.name.startsWith('sing') && !luaChar.stunned) {
							luaChar.dance();
						}
					}
				}

				switch (swagCounter) {
					case 0:
						countdownGet = createCountdownSprite(introAlts[0], antialias, cameOther);
						tweenGet = FlxTween.tween(countdownGet.scale, {x: 0.01, y: 0.01}, Conductor.crochet / 1000, {
							startDelay: Conductor.crochet / 2000,
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween) {
								remove(countdownGet);
								countdownGet.destroy();
								countdownGet = null;
								tweenGet = null;
							}
						});
						playCountdownSounds(songName, '3');
					case 1:
						countdownReady = createCountdownSprite(introAlts[1], antialias, cameOther);
						tweenReady = FlxTween.tween(countdownReady.scale, {x: 0.01, y: 0.01}, Conductor.crochet / 1000, {
							startDelay: Conductor.crochet / 2000,
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween) {
								remove(countdownReady);
								countdownReady.destroy();
								countdownReady = null;
								tweenReady = null;
							}
						});
						playCountdownSounds(songName, '2');
					case 2:
						countdownSet = createCountdownSprite(introAlts[2], antialias, cameOther);
						tweenSet = FlxTween.tween(countdownSet.scale, {x: 0.01, y: 0.01}, Conductor.crochet / 1000, {
							startDelay: Conductor.crochet / 2000,
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween) {
								remove(countdownSet);
								countdownSet.destroy();
								countdownSet = null;
								tweenSet = null;
							}
						});
						playCountdownSounds(songName, '1');
					case 3:
						if(makeGo){
							countdownGo = createCountdownSprite(introAlts[3], antialias, cameOther);
							tweenGo = FlxTween.tween(countdownGo, {alpha: 0}, Conductor.crochet / 1000, {
								startDelay: Conductor.crochet / 2000,
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween) {
									remove(countdownGo);
									countdownGo.destroy();
									countdownGo = null;
									tweenGo = null;
								}
							});
							playCountdownSounds(songName, 'Go');
						}
					case 4:
						firstCountdown = false;
						countdownStarted = false;
						//trace('First Countdown: ' + firstCountdown + ', countdownStarted: ' + countdownStarted);
				}

				if(firstCountdown) {
					notes.forEachAlive(function(note:Note) {
						if(ClientPrefs.opponentStrums || note.mustPress) {
							note.copyAlpha = false;
							note.alpha = note.multAlpha;
							if(ClientPrefs.middleScroll && !note.mustPress) {
								note.alpha *= 0.35;
							}
						}
					});
					stagesFunc(function(stage:BaseStage) stage.countdownTick(swagCounter));
					FlxTween.tween(laneunderlay, {alpha: ClientPrefs.underlaneVisibility}, 0.5, {ease: FlxEase.quadOut});
					FlxTween.tween(laneunderlayOp, {alpha: ClientPrefs.opponentUnderlaneVisibility}, 0.5, {ease: FlxEase.quadOut});
				}

				callOnLuas('onCountdownTick', [swagCounter]);
				swagCounter++;
			}, 5);
		}
	}

	inline private function createCountdownSprite(image:String, antialias:Bool, cameOther:Bool = false):FlxSprite {
		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(image));
		if(cameOther) spr.cameras = [camOther];
		else spr.cameras = [camHUD];
		spr.scrollFactor.set();
		spr.updateHitbox();

		if (PlayState.isPixelStage)
			spr.setGraphicSize(Std.int(spr.width * daPixelZoom));

		spr.screenCenter();
		spr.antialiasing = antialias;
		insert(members.indexOf(notes), spr);
		return spr;
	}

	inline private function playCountdownSounds(songName:String, suffix:String){
		if (FileSystem.exists(Paths.modsSounds('sounds', songName + '+' + 'intro' + suffix))) {
			FlxG.sound.play(Paths.sound(songName + '+' + 'intro' + suffix, 'ogg'), 0.6);
		} else {
			FlxG.sound.play(Paths.sound('intro' + suffix + introSoundsSuffix), 0.6);
		}
	}

	public function addBehindGF(obj:FlxObject) {
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxObject) {
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad (obj:FlxObject) {
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float) {
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time) {
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time) {
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length) {
			vocals.time = time;
		}
		vocals.play();
		Conductor.songPosition = time;
		songTime = time;
	}

	public function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	public function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), PlayState.SONG.songInstVolume, false);
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();

		if(startOnTime > 0) {
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if(paused) {
			//trace('Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		startedSong = true;

		if(!statusCancelStartTween) {
			statusTweening();
		}

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		//DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyDiscordText + ")", iconP2.getCharacter(), true, songLength);
		DiscordClient.changePresence(detailsText, SONG.song + storyDifficultyDiscordText, iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	private var shitTween:FlxTween;
	private var badTween:FlxTween;
	private var goodTween:FlxTween;
	private var sickTween:FlxTween;
	private var perfectTween:FlxTween;
	private var comboTween:FlxTween;
	public function statusTweening() {
		if(statusLoaded && shitTween == null) {
			var value:Float = 0;
			if(ClientPrefs.hudSize) value = 70;
			shitTween = FlxTween.tween(shitTxt, {x: FlxG.width * 0.01 - value}, 0.6, { ease: FlxEase.backOut, startDelay: 0.4 });
			badTween = FlxTween.tween(badTxt, {x: FlxG.width * 0.01 - value}, 0.6, { ease: FlxEase.backOut, startDelay: 0.4 });
			goodTween = FlxTween.tween(goodTxt, {x: FlxG.width * 0.01 - value}, 0.6, { ease: FlxEase.backOut, startDelay: 0.4 });
			sickTween = FlxTween.tween(sickTxt, {x: FlxG.width * 0.01 - value}, 0.6, { ease: FlxEase.backOut, startDelay: 0.4 });
			perfectTween = FlxTween.tween(perfectTxt, {x: FlxG.width * 0.01 - value}, 0.6, { ease: FlxEase.backOut, startDelay: 0.4 });
			comboTween = FlxTween.tween(bestComboTxt, {x: FlxG.width * 0.01 - value}, 0.6, { ease: FlxEase.backOut, startDelay: 0.4 });
		}
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void {
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicativo');

		switch(songSpeedType) {
			case "multiplicativo":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constante":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) { 	//Event Notes 
				for (i in 0...event[1].length) {
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData) {
			for (songNotes in section.sectionNotes) {
				var daStrumTime:Float = songNotes[0];
				//var daNoteData:Int = Std.int(songNotes[1] % 4);
				var daNoteData:Int = Std.int(songNotes[1] % Note.ammo[mania]);

				var gottaHitNote:Bool = section.mustHitSection;

				//if (songNotes[1] > 3) {
				if (songNotes[1] > (Note.ammo[mania] - 1)) {
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var ishouldsetthisskin:String = null;
				if (gottaHitNote) {
					if (FileSystem.exists(Paths.modsImages("NOTE_" + SONG.player1 + '_assets'))) {
						ishouldsetthisskin = 'NOTE_' + SONG.player1 + '_assets';
					}
				} else {
					if (FileSystem.exists(Paths.modsImages("NOTE_" + SONG.player2 + '_assets'))) {
						ishouldsetthisskin = 'NOTE_' + SONG.player2 + '_assets';
					}
				}

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				//swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.gfNote = (section.gfSection && (songNotes[1] < Note.ammo[mania]));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus + 1) {
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						// var susskin:String = null;
						// if (gottaHitNote) {
						// 	if (FileSystem.exists(Paths.modsImages("NOTE_" + SONG.player1 + '_assets'))) {
						// 		susskin = 'NOTE_' + SONG.player1 + '_assets';
						// 	}
						// } else {
						// 	if (FileSystem.exists(Paths.modsImages("NOTE_" + SONG.player2 + '_assets'))) {
						// 		susskin = 'NOTE_' + SONG.player2 + '_assets';
						// 	}
						// }

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						//sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<Note.ammo[mania]));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						sustainNote.alpha = ClientPrefs.holdNoteVisibility;
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress) {
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll) {
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress) {
					swagNote.x += FlxG.width / 2; // general offset
				} else if(ClientPrefs.middleScroll) {
					swagNote.x += 310;
					if(daNoteData > 1) { //Up and Right
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) { //Event Notes
			for (i in 0...event[1].length) {
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
		stagesFunc(function(stage:BaseStage) stage.eventPushed(event));
	}

	function eventEarlyTrigger(event:EventNote):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event, event.value1, event.value2, event.strumTime]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false;
	private function generateStaticArrows(player:Int):Void {
		//for (i in 0...4)
		for (i in 0...Note.ammo[mania]) {
			var twnDuration:Float = 2 / mania;
			var twnStart:Float = 0.5 + ((0.8 / mania) * i);
			var targetAlpha:Float = 1;

			if (player < 1) {
				if(ClientPrefs.opponentStrums) targetAlpha = 0;
				else if(ClientPrefs.middleScroll) targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			//if (!isStoryMode && !skipArrowStartTween)
			if (!isStoryMode && !skipArrowStartTween && mania > 1) {
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				//if(!startInvisible) FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
				if(!startInvisible) FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, twnDuration, {ease: FlxEase.circOut, startDelay: twnStart});
			} else {
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1) {
				playerStrums.add(babyArrow);
			} else {
				if(ClientPrefs.middleScroll) {
					var separator:Int = Note.separator[mania];
					babyArrow.x += 310;
					//if(i > 1) {
					if(i > separator) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();

			// Arrow KeyBinds
			if (ClientPrefs.showKeybindsOnStart) {
				var j:Int = 0;
				if(player < 1) j = 1;
				var txtSize:Int = 40;
				var txtKeyTip:FlxText = new FlxText(babyArrow.x, babyArrow.y - 450, 0, InputFormatter.getKeyName(keysArray[mania][i][j]), txtSize);
				txtKeyTip.setFormat(Paths.font("crash.ttf"), txtSize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				if(isPixelStage) {
					txtKeyTip.font = Paths.font("pixel.otf");
					txtKeyTip.size = 16;
				}
				txtKeyTip.borderSize = 1.15;
				txtKeyTip.alpha = 0;
				txtKeyTip.size = txtSize - mania;
				txtKeyTip.x = babyArrow.x + (babyArrow.width / 2);
				txtKeyTip.x -= txtKeyTip.width / 2;
				txtKeyTip.cameras = [camHUD];
				if(ClientPrefs.downScroll) txtKeyTip.y = babyArrow.y + 450;

				add(txtKeyTip);

				if (mania > 1 && !skipArrowStartTween) { // Spawn Move
					var upDownTxt:Float = 120;
					if(ClientPrefs.downScroll) upDownTxt = upDownTxt * -1 + 30;
					FlxTween.tween(txtKeyTip, {y: babyArrow.y + upDownTxt, alpha: 1}, twnDuration, {ease: FlxEase.circOut, startDelay: twnStart});
				} else {
					txtKeyTip.y += 16;
					txtKeyTip.alpha = 1;
				}

				new FlxTimer().start(Conductor.crochet * 0.001 * 12, function(_) { // Despawn Move
					var goTxt:Float = 32;
					if(ClientPrefs.downScroll) goTxt = goTxt * -1;
					FlxTween.tween(txtKeyTip, {y: txtKeyTip.y + goTxt, alpha: 0}, twnDuration, {ease: FlxEase.circIn, startDelay: twnStart, onComplete:
					function(twn:FlxTween) {
						remove(txtKeyTip);
					}});
				});
			}
		}
	}

	function updateNote(note:Note) {
		var tMania:Int = mania + 1;
		var noteData:Int = note.noteData;

		note.scale.set(1, 1);
		note.updateHitbox();

		var lastScaleY:Float = note.scale.y;
		if (isPixelStage) {
			if (note.isSustainNote) {note.originalHeightForCalcs = note.height;}
			note.setGraphicSize(Std.int(note.width * daPixelZoom * Note.pixelScales[mania]));
		} else {
			note.setGraphicSize(Std.int(note.width * Note.scales[mania]));
			note.updateHitbox();
		}

		note.updateHitbox();

		var prevNote:Note = note.prevNote;
		if (note.isSustainNote && prevNote != null) {
			note.offsetX += note.width / 2;
			note.animation.play(Note.keysShit.get(mania).get('letters')[noteData] + ' tail');
			note.updateHitbox();
			note.offsetX -= note.width / 2;
			if (note != null && prevNote != null && prevNote.isSustainNote && prevNote.animation != null) {
				prevNote.animation.play(Note.keysShit.get(mania).get('letters')[noteData % tMania] + ' hold');
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				prevNote.scale.y *= songSpeed;
				if(isPixelStage) {
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / note.height);
				}
				prevNote.updateHitbox();
			}
			if (isPixelStage){
				prevNote.scale.y *= daPixelZoom * (Note.pixelScales[mania]);
				prevNote.updateHitbox();
			}
		} else if (!note.isSustainNote && noteData > - 1 && noteData < tMania) {
			if (note.changeAnim) {
				var animToPlay:String = '';
				animToPlay = Note.keysShit.get(mania).get('letters')[noteData % tMania];
				note.animation.play(animToPlay);
			}
		}

		if (note.changeColSwap) {
			var hsvNumThing = Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData % tMania]);
			var colSwap = note.colorSwap;
			colSwap.hue = ClientPrefs.arrowHSV[hsvNumThing][0] / 360;
			colSwap.saturation = ClientPrefs.arrowHSV[hsvNumThing][1] / 100;
			colSwap.brightness = ClientPrefs.arrowHSV[hsvNumThing][2] / 100;
		}
	}

	public function changeMania(newValue:Int, skipStrumFadeOut:Bool = false) {
		//funny dissapear transitions
		//while new strums appear
		var daOldMania = mania;
		mania = newValue;
		if (!skipStrumFadeOut) {
			for (i in 0...strumLineNotes.members.length) {
				var oldStrum:FlxSprite = strumLineNotes.members[i].clone();
				oldStrum.x = strumLineNotes.members[i].x;
				oldStrum.y = strumLineNotes.members[i].y;
				oldStrum.alpha = strumLineNotes.members[i].alpha;
				oldStrum.scrollFactor.set();
				oldStrum.cameras = [camHUD];
				oldStrum.setGraphicSize(Std.int(oldStrum.width * Note.scales[daOldMania]));
				oldStrum.updateHitbox();
				add(oldStrum);
	
				FlxTween.tween(oldStrum, {alpha: 0}, 0.3, {onComplete: function(_) {
					remove(oldStrum);
				}});
			}
		}

		playerStrums.clear();
		opponentStrums.clear();
		strumLineNotes.clear();
		setOnLuas('mania', mania);
		setOnLuas('maniaAnims', Note.keysShit.get(mania).get('anims'));
		setOnLuas('maniaControls', keysArray[mania]);

		notes.forEachAlive(function(note:Note) {updateNote(note);});
		for (noteI in 0...unspawnNotes.length) {
			var note:Note = unspawnNotes[noteI];
			updateNote(note);
		}
		generateStaticArrows(0);
		generateStaticArrows(1);
		updateLuaDefaultPos();
		callOnLuas('onChangeMania', [mania, daOldMania]);
	}

	var soundIsPaused:Map<FlxSound, Bool> = new Map<FlxSound, Bool>();
	var emitterActive:Map<FlxEmitter, Bool> = new Map<FlxEmitter, Bool>();
	override function openSubState(SubState:FlxSubState)
	{
		stagesFunc(function(stage:BaseStage) stage.openSubState(SubState));
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (bartween in flxBarTweens) {
				bartween.active = false;
			}
			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
			for (flick in modchartFlickers) {
				flick.pause();
			}
			for (sound in modchartSounds) {
				if(sound.playing) {
					sound.pause();
				} else {
					soundIsPaused.set(sound, false);
				}
			}
			for (emitter in modchartEmitters) {
				if(emitter.emitting) {
					emitter.emitting = false;
				} else {
					emitterActive.set(emitter, false);
				}
			}
			if (tweenGet != null) tweenGet.active = false;
			if (tweenReady != null) tweenReady.active = false;
			if (tweenSet != null) tweenSet.active = false;
			if (tweenGo != null) tweenGo.active = false;
			if (iconP1Tween != null) iconP1Tween.active = false;
			if (iconP2Tween != null) iconP2Tween.active = false;
			if (shitTween != null) shitTween.active = false;
			if (badTween != null) badTween.active = false;
			if (goodTween != null) goodTween.active = false;
			if (sickTween != null) sickTween.active = false;
			if (perfectTween != null) perfectTween.active = false;
			if (comboTween != null) comboTween.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		stagesFunc(function(stage:BaseStage) stage.closeSubState());
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong) {
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished) startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished) finishTimer.active = true;
			if (songSpeedTween != null) songSpeedTween.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}

			for (bartween in flxBarTweens) {
				bartween.active = true;
			}
			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			for (flick in modchartFlickers) {
				flick.resume();
			}
			for (sound in modchartSounds) {
				if(soundIsPaused.exists(sound)) {
					soundIsPaused.remove(sound);
				} else {
					sound.resume();
				}
			}
			for (emitter in modchartEmitters) {
				if(emitterActive.exists(emitter)) {
					emitterActive.remove(emitter);
				} else {
					emitter.emitting = true;
				}
			}
			if (tweenGet != null) tweenGet.active = true;
			if (tweenReady != null) tweenReady.active = true;
			if (tweenSet != null) tweenSet.active = true;
			if (tweenGo != null) tweenGo.active = true;
			if (iconP1Tween != null) iconP1Tween.active = true;
			if (iconP2Tween != null) iconP2Tween.active = true;
			if (shitTween != null) shitTween.active = true;
			if (badTween != null) badTween.active = true;
			if (goodTween != null) goodTween.active = true;
			if (sickTween != null) sickTween.active = true;
			if (perfectTween != null) perfectTween.active = true;
			if (comboTween != null) comboTween.active = true;

			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer != null && startTimer.finished) {
				//DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyDiscordText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
				DiscordClient.changePresence(detailsText, SONG.song + storyDifficultyDiscordText, iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			} else {
				//DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyDiscordText + ")", iconP2.getCharacter());
				DiscordClient.changePresence(detailsText, SONG.song + storyDifficultyDiscordText, iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0) {
				//DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyDiscordText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
				DiscordClient.changePresence(detailsText, SONG.song + storyDifficultyDiscordText, iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			} else {
				//DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyDiscordText + ")", iconP2.getCharacter());
				DiscordClient.changePresence(detailsText, SONG.song + storyDifficultyDiscordText, iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			//DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyDiscordText + ")", iconP2.getCharacter());
			DiscordClient.changePresence(detailsPausedText, SONG.song + storyDifficultyDiscordText, iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
		}
		vocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var startedSong:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;
	public var bestCombo:Int = 0;

	override public function update(elapsed:Float)
	{
		/*if (FlxG.keys.justPressed.NINE) {
			iconP1.swapOldIcon();
		}*/
		callOnLuas('onUpdate', [elapsed]);
		callOnHScripts('update', [elapsed]);

		instCurTime = FlxG.sound.music.time;
		voicesCurTime = vocals.time;
		setOnLuas('instCurTime', instCurTime);
		setOnLuas('voicesCurTime', voicesCurTime);

		setOnLuas('isPixelStage', isPixelStage);

		// Update spawn notes scales
		for (oneNote in notes) {
			if(oneNote.mustPress) {		//BF STRUM
				for (i in 0...mania + 1) {
					if(oneNote.noteData == i) {
						oneNote.scale.x = playerStrums.members[i].scale.x;
						if(!oneNote.isSustainNote)
							oneNote.scale.y = playerStrums.members[i].scale.y;
					}
				}
			} else { 					// DAD STRUM
				for (i in 0...mania + 1) {
					if(oneNote.noteData == i) {
						oneNote.scale.x = opponentStrums.members[i].scale.x;
						if(!oneNote.isSustainNote)
							oneNote.scale.y = opponentStrums.members[i].scale.y;
					}
				}
			}
        }

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some players
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		if(statusLoaded) {
			if (combo > bestCombo) {
				bestCombo = combo;
			}
			shitTxt.text = ratingJudges[0] + ': ' + Std.string(shits);
			badTxt.text = ratingJudges[1] + ': ' + Std.string(bads);
			goodTxt.text = ratingJudges[2] + ': ' + Std.string(goods);
			sickTxt.text = ratingJudges[3] + ': ' + Std.string(sicks);
			perfectTxt.text = ratingJudges[4] + ': ' + Std.string(perfects);
			bestComboTxt.text = ratingJudges[5] + ': ' + Std.string(bestCombo);
		}

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause && startedSong) {
			var ret:Dynamic = callOnLuas('onPause', [], false);
			if(ret != FunkinLua.Function_Stop) {
				openPauseMenu();
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene && !SONG.disableDebugButtons) {
			FlxG.sound.play(Paths.sound('debugSecret'), 0.6);
			openChartEditor();
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;
		daTaeb = curBeat;

		if(totalPlayed < 0) totalPlayed = 0;
		if(totalNotesHit < 0) totalNotesHit = 0;
		if(totalNotesHit > totalPlayed) totalNotesHit = totalPlayed;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;

		if (health > 2) health = 2;

		if (iconP1.animation.frames == 3) {
			if (healthBar.percent < 35) iconP1.animation.curAnim.curFrame = 1;
			else if (healthBar.percent > 75) iconP1.animation.curAnim.curFrame = 2;
			else iconP1.animation.curAnim.curFrame = 0;
		} else {
			if (healthBar.percent < 35) iconP1.animation.curAnim.curFrame = 1;
			else iconP1.animation.curAnim.curFrame = 0;
		}
		if (iconP2.animation.frames == 3) {
			if (healthBar.percent > 75) iconP2.animation.curAnim.curFrame = 1;
			else if (healthBar.percent < 35) iconP2.animation.curAnim.curFrame = 2;
			else iconP2.animation.curAnim.curFrame = 0;
		} else {
			if (healthBar.percent > 75) iconP2.animation.curAnim.curFrame = 1;
			else iconP2.animation.curAnim.curFrame = 0;
		}

		// Tell me if there is a better way to do this and how to do it, please
		if(healthBar.percent < 35 && boyfriend.lowHealth == false) {
			boyfriend.lowHealth = true;
			for(luaChar in luaCharsMap)
				if(luaChar.isPlayer) luaChar.lowHealth = true;

		} else if(healthBar.percent >= 35 && boyfriend.lowHealth == true) {
			boyfriend.lowHealth = false;
			for(luaChar in luaCharsMap)
				if(luaChar.isPlayer) luaChar.lowHealth = false;
		}

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			FlxG.sound.play(Paths.sound('debugSecret'));
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if (startedCountdown)
			Conductor.songPosition += FlxG.elapsed * 1000;

		if (startingSong) {
			if (startedCountdown && Conductor.songPosition >= 0) startSong();
			else if(!startedCountdown) Conductor.songPosition = -Conductor.crochet * 5;

		} else {
			if (!paused) {
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition) {
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Tempo Recorrido') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Nome da Musica')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}
			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming) {
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
			camHUD.zoom = FlxMath.lerp(defaultHudZoom, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
			camOther.zoom = FlxMath.lerp(defaultOthZoom, camOther.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
		}
		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong) {
			health = 0;
			trace("FORCED TO FINISH");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null) {
			var time:Float = spawnTime;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time) {
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;
				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote, dunceNote.strumTime]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic) {
			if (!inCutscene) {
				if(!cpuControlled) {
					keyShit();
				} else {
					if(boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration
					  && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
						boyfriend.dance();
					}

					for(luaChar in luaCharsMap) {
						if(luaChar.animation.curAnim != null && luaChar.holdTimer > Conductor.stepCrochet * 0.0011 * luaChar.singDuration
						  && luaChar.animation.curAnim.name.startsWith('sing') && !luaChar.animation.curAnim.name.endsWith('miss') && luaChar.isPlayer) {
							luaChar.dance();
						}
					}
				}
			}

			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note) {
				var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
				if(!daNote.mustPress) strumGroup = opponentStrums;

				var strumX:Float = strumGroup.members[daNote.noteData].x;
				var strumY:Float = strumGroup.members[daNote.noteData].y;
				var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
				var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
				var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
				var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;
				var strumHeight:Float = strumGroup.members[daNote.noteData].height;

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;

				if (strumScroll) {	//Downscroll
					//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
				} else { 			//Upscroll 
					//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
				}

				var angleDir = strumDirection * Math.PI / 180;
				if (daNote.copyAngle)
					daNote.angle = strumDirection - 90 + strumAngle;

				if(daNote.copyAlpha)
					if (daNote.parent != null) {
						if (!daNote.parent.shouldbehidden) {
							daNote.alpha = strumAlpha;
						}
					} else {
						daNote.alpha = strumAlpha;
					}

				if(daNote.copyX)
					daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

				if(daNote.copyY) {
					daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

					if(strumScroll && daNote.isSustainNote) {
						if (daNote.animation.curAnim.name.endsWith('tail')) {
							daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
							daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
							if(PlayState.isPixelStage) {
								daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
							} else {
								daNote.y -= 19;
							}
						}
						daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
						//daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
						daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1) * Note.scales[mania];
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote) {
					opponentNoteHit(daNote);
				}

				if(!daNote.blockHit && daNote.mustPress && cpuControlled && daNote.canBeHit) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote) {
						goodNoteHit(daNote);
					}
				}

				var center:Float = strumY + Note.swagWidth / 2;
				if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
				  (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit)))) {
					if (strumScroll) {
						if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center) {
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					} else {
						if (daNote.y + daNote.offset.y * daNote.scale.y <= center) {
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				// Kill extremely late notes and cause misses
				if (Conductor.songPosition > noteKillOffset + daNote.strumTime) {
					if (daNote.mustPress && !cpuControlled && !daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
						noteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					callOnLuas('onDespawnNote', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote, daNote.strumTime]);
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		checkEventNote();

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end
		
		// Gameplay
		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		setOnLuas('chartMode', chartingMode);
		setOnLuas('practice', practiceMode);
		setOnLuas('health', health);
		setOnLuas('lifes', lifes);

		// Ratings
		setOnLuas('totalShits', shits);
		setOnLuas('totalBads', bads);
		setOnLuas('totalGoods', goods);
		setOnLuas('totalSicks', sicks);
		setOnLuas('totalPerfects', perfects);
		setOnLuas('totalCombo', combo);
		setOnLuas("showCombo", showCombo);
		setOnLuas("showComboNumber", showComboNum);
		setOnLuas("showRating", showRating);

		// Characters
		setOnLuas('curBfX', boyfriend.x);
		setOnLuas('curBfY', boyfriend.y);
		setOnLuas('curDadX', dad.x);
		setOnLuas('curDadY', dad.y);
		setOnLuas('curGfX', gf.x);
		setOnLuas('curGfY', gf.y);
		
		// Steps/Beats
		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);

		for (shader in animatedShaders)
			{
				shader.update(elapsed);
			}
		#if LUA_ALLOWED
			for (key => value in luaShaders)
			{
				value.update(elapsed);
			}
		#end
		callOnLuas('onUpdatePost', [elapsed]);
		for (i in shaderUpdates){
			i(elapsed);
		}
	}

	function openPauseMenu() {
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		// 1 / 1000 chance for Gitaroo Man easter egg
		/*if (FlxG.random.bool(0.1))
		{
			// gitaroo man easter egg
			cancelMusicFadeTween();
			MusicBeatState.switchState(new GitarooPause());
		}
		else {*/
		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		//}

		#if desktop
		//DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyDiscordText + ")", iconP2.getCharacter());
		DiscordClient.changePresence(detailsPausedText, SONG.song + storyDifficultyDiscordText, iconP2.getCharacter());
		#end
	}

	public function openChangersMenu() {
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		// 1 / 1000 chance for Gitaroo Man easter egg
		/*if (FlxG.random.bool(0.1))
		{
			// gitaroo man easter egg
			cancelMusicFadeTween();
			MusicBeatState.switchState(new GitarooPause());
		}
		else {*/
		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
		openSubState(new GameplayChangersSubstate());
	}

	function openChartEditor() {
		persistentUpdate = false;
		paused = true;
		chartingMode = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var lifes:Int = 0; // Value to avoid death (1UP+). Set it in Lua!
	public var bonusHealth:Float = 1; // Set it in Lua!
	public var isDead:Bool = false;
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead && lifes <= 0) {
			var ret:Dynamic = callOnLuas('onGameOver', [], false);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (bartween in flxBarTweens) {
					bartween.active = true;
				}
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				for (flick in modchartFlickers) {
					flick.resume();
				}
				for (sound in modchartSounds) {
					if(soundIsPaused.exists(sound)) {
						soundIsPaused.remove(sound);
					} else {
						sound.resume();
					}
				}
				for (emitter in modchartEmitters) {
					if(emitterActive.exists(emitter)) {
						emitterActive.remove(emitter);
					} else {
						emitter.emitting = true;
					}
				}
				if (tweenGet != null) tweenGet.active = true;
				if (tweenReady != null) tweenReady.active = true;
				if (tweenSet != null) tweenSet.active = true;
				if (tweenGo != null) tweenGo.active = true;
				if (iconP1Tween != null) iconP1Tween.active = true;
				if (iconP2Tween != null) iconP2Tween.active = true;
				if (shitTween != null) shitTween.active = true;
				if (badTween != null) badTween.active = true;
				if (goodTween != null) goodTween.active = true;
				if (sickTween != null) sickTween.active = true;
				if (perfectTween != null) perfectTween.active = true;
				if (comboTween != null) comboTween.active = true;
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				//DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyDiscordText + ")", iconP2.getCharacter());
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + storyDifficultyDiscordText, iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		} else if(lifes > 0) {
			health += bonusHealth;
			lifes--;
			callOnLuas('onEscapingDeath', []);
			return true;
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;

						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}

			case 'Change Mania':
				var newMania:Int = 0;
				var skipTween:Bool = value2 == "true" ? true : false;

				newMania = Std.parseInt(value1);
				if(Math.isNaN(newMania) && newMania < 0 && newMania > 9)
					newMania = 0;
				changeMania(newMania, skipTween);

			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);
						setDefaultCharacterCamPosOnLua();
					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);
						setDefaultCharacterCamPosOnLua();
					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
							setDefaultCharacterCamPosOnLua();
						}
				}
				reloadHealthBarColors();
				if (SONG.characterTrails) {
					remove(trailunderdad);
					trailunderdad = new FlxTrail(dad, null, 6, 5, 0.2, 0.01); //nice
					insert(members.indexOf(dadGroup) - 1, trailunderdad);
				}
				if (SONG.bfTrails) {
					remove(trailunderbf);
					trailunderbf = new FlxTrail(boyfriend, null, 6, 5, 0.2, 0.01); //nice
					insert(members.indexOf(boyfriendGroup) - 1, trailunderbf);
				}
				if (SONG.gfTrails) {
					remove(trailundergf);
					trailundergf = new FlxTrail(gf, null, 6, 5, 0.2, 0.01); //nice
					insert(members.indexOf(gfGroup) - 1, trailundergf);
				}

			case 'Change Scroll Speed':
				if (songSpeedType == "constante")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}

			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if(killMe.length > 1) {
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoop(killMe, true, true), killMe[killMe.length-1], value2);
				} else {
					FunkinLua.setVarInArray(this, value1, value2);
				}
		}
		stagesFunc(function(stage:BaseStage) stage.eventCalled(eventName, value1, value2));
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection():Void {
		if(SONG.notes[curSection] == null) return;

		if (gf != null && SONG.notes[curSection].gfSection) {
			moveCamera(2);
		} else if (!SONG.notes[curSection].mustHitSection) {
			moveCamera(1);
		} else {
			moveCamera(0);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(toFollow:Int = 0, ?char:String = '') {
		switch(toFollow) {
			case 3:
				var luaChar:LuaChar = luaCharsMap.get(char);
				if(luaChar != null) {
					camFollow.set(luaChar.getMidpoint().x + 100, luaChar.getMidpoint().y - 100);
					camFollow.x += luaChar.cameraPosition[0];
					camFollow.y += luaChar.cameraPosition[1];
					if(luaChar.isPlayer) {
						tweenCamIn(1);
					} else {
						tweenCamIn(1.3);
					}
					callOnLuas('onMoveCamera', ['luachar']);
				} else {
					moveCamera(0);
				}
			case 2:
				camFollow.set(gf.getMidpoint().x + 80, gf.getMidpoint().y - 80);
				camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
				camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
				tweenCamIn(1.3);
				callOnLuas('onMoveCamera', ['gf']);
			case 1:
				camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
				camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
				tweenCamIn(1.3);
				callOnLuas('onMoveCamera', ['dad']);
			default:
				camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
				camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
				camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];
				tweenCamIn(1);
				callOnLuas('onMoveCamera', ['bf']);
		}
	}

	function tweenCamIn(value:Float) {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != value) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: value}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void {
		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			endCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				endCallback();
			});
		}
	}

	public var transitioning = false;
	public function endSong():Void {
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		restartSkipCountdown = false;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement([
				'week1_nomiss', 'week2_nomiss', 'week3_nomiss', 'week4_nomiss', 'week5_nomiss', 'week6_nomiss', 'week7_nomiss',
				'warp1_nomiss', 'megamix_nomiss', 'fnf_nomiss', 'extra_nomiss', 'intro_nomiss',
				'ur_bad', 'ur_good', 'hype', 'two_keys', 'toastie', 'debugger',
				'flora', 'templo', 'bonus', 'toxico', 'precioso',
				'music1', 'music2', 'music3', 'music4',
				'perfect1', 'perfect2', 'perfect3', 'perfect4'
			]);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end

		var ret:Dynamic = callOnLuas('onEndSong', [], false);
		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore && !closedScore) {
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}

			if (chartingMode) {
				openChartEditor();
				return;
			}

			if (isStoryMode) {
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0) {
					WeekData.loadTheFirstEnabledMod();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new StoryMenuState());

					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore && !closedScore) {
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				} else {
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('CARREGANDO A PRÓXIMA MÚSICA');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					cancelMusicFadeTween();
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				//trace('VOLTOU AO FREEPLAY??');
				WeekData.loadTheFirstEnabledMod();
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('GANHANDO A CONQUISTA ' + achieve);
	}

	function achievementEnd():Void {
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	private function onKeyPress(event:KeyboardEvent):Void {
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		//if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode)) {
		if (!cpuControlled && startedCountdown && !paused && key > -1 && FlxG.keys.checkStatus(eventKey, JUST_PRESSED)) {
			if(!boyfriend.stunned && generatedMusic && !endingSong) {
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note) {
					if (daNote.canBeHit && !isNoHIT && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit) {
						if(daNote.noteData == key) {
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						if (SONG.disableAntiMash) {
							canMiss = false;
						} else {
							canMiss = true;
						}
					}  else if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit && daNote.noteType == 'enforceCrate') {
						if(daNote.noteData == key) {
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						if (SONG.disableAntiMash) {
							canMiss = false;
						} else {
							canMiss = true;
						}
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList) {
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}
						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}
					}
				} else {
					callOnLuas('onGhostTap', [key]);
					if (canMiss) {
						noteMissPress(key);
						callOnHScripts('noteMissPress', [key]);
					}
				}
				keysPressed[key] = true;
				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(spr != null && spr.animation.curAnim.name != 'confirm') {
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
			callOnHScripts('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}

	function sortHitNotes(a:Note, b:Note):Int {
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void {
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1) {
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null) {
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int {
		// if(key != NONE) {
		// 	for (i in 0...keysArray.length) {
		// 		for (j in 0...keysArray[i].length) {
		// 			if(key == keysArray[i][j]) {
		// 				return i;
		// 			}
		// 		}
		// 	}
		// }
		// return -1;
		if(key != NONE) {
			for (i in 0...keysArray[mania].length) {
				for (j in 0...keysArray[mania][i].length) {
					if(key == keysArray[mania][i][j]) {
						return i;
					}
				}
			}
		}
		return -1;
	}

	private function keysArePressed():Bool {
		for (i in 0...keysArray[mania].length) {
			for (j in 0...keysArray[mania][i].length) {
				if (FlxG.keys.checkStatus(keysArray[mania][i][j], PRESSED)) return true;
			}
		}
		return false;
	}

	private function dataKeyIsPressed(data:Int):Bool {
		for (i in 0...keysArray[mania][data].length) {
			if (FlxG.keys.checkStatus(keysArray[mania][data][i], PRESSED)) return true;
		}
		return false;
	}

	// Hold notes
	private function keyShit():Void {
	// HOLDING
		// var up = controls.NOTE_UP;
		// var right = controls.NOTE_RIGHT;
		// var down = controls.NOTE_DOWN;
		// var left = controls.NOTE_LEFT;
		// var controlHoldArray:Array<Bool> = [left, down, up, right];

	// TO DO: Find a better way to handle controller inputs, this should work for now
		// if(ClientPrefs.controllerMode) {
		// 	var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
		// 	if(controlArray.contains(true)) {
		// 		for (i in 0...controlArray.length) {
		// 			if(controlArray[i])
		// 				onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
		// 		}
		// 	}
		// }

		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic) {
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note) {
				// hold note functions
				if (daNote.isSustainNote && dataKeyIsPressed(daNote.noteData % Note.ammo[mania]) && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit && !isNoHIT) {
					goodNoteHit(daNote);
				} else if (daNote.isSustainNote && dataKeyIsPressed(daNote.noteData % Note.ammo[mania]) && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit
				&& daNote.noteType == 'enforceCrate') {
					goodNoteHit(daNote);
				}
			});

			//if (controlHoldArray.contains(true) && !endingSong) {
			if (keysArePressed() && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			} else {
				if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration 
				  && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
					boyfriend.dance();
				}

				for(luaChar in luaCharsMap) {
					if(luaChar.animation.curAnim != null && luaChar.holdTimer > Conductor.stepCrochet * 0.0011 * luaChar.singDuration
					  && luaChar.animation.curAnim.name.startsWith('sing') && !luaChar.animation.curAnim.name.endsWith('miss') && luaChar.isPlayer) {
						luaChar.dance();
					}
				}
			}
		}
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		callOnHScripts('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote, daNote.strumTime]);
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		noteMissCommon(daNote.noteData, daNote);
		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote, daNote.strumTime]);
	}

	function noteMissPress(direction:Int = 1):Void { //You pressed a key when there was no notes to press for this key
		if(isGhostTapping) return;
		noteMissCommon(direction);
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		callOnLuas('noteMissPress', [direction]);
	}

	function noteMissCommon(direction:Int, note:Note = null) {
		// score and data
		var subtract:Float = 0.05;
		if(note != null) subtract = note.missHealth;
		health -= subtract * healthLoss;

		if(instakillOnMiss) {
			vocals.volume = 0;
			doDeathCheck(true);
		}
		combo = 0;

		if(!practiceMode) songScore -= 10;
		if(!endingSong) songMisses++;
		totalPlayed++;
		RecalculateRating(true);

		//var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, direction)))] + 'miss' + suffix;
		var mainAnim:String = Note.keysShit.get(mania).get('anims')[direction];
		var altAnim:String = '';
		if(note != null) altAnim = note.animSuffix;

		// Play Character Anims
		if((note != null && note.gfNote) || (SONG.notes[curSection] != null && SONG.notes[curSection].gfSection)) {
			if(gf != null) gf.playAnim('sing' + mainAnim + 'miss' + altAnim, true);

		} else if(boyfriend.hasMissAnimations) {
			boyfriend.playAnim('sing' + mainAnim + 'miss' + altAnim, true);

			if(combo > 9 && gf != null && gf.animOffsets.exists('sad')) {
				gf.playAnim('sad');
				gf.specialAnim = true;
			}
		}

		// Lua Character Player Animation
		for(luaChar in luaCharsMap) {
			if(luaChar.isPlayer && luaChar.testNote(note.noteType)) {
				luaChar.playAnim('sing' + mainAnim + 'miss' + altAnim, true);
			}
		}
		vocals.volume = 0;
	}

	function opponentNoteHit(note:Note):Void {
		if (Paths.formatToSongPath(SONG.song) != 'tutorial') camZooming = true;

		//var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
		var mainAnim:String = Note.keysShit.get(mania).get('anims')[note.noteData];
		var altAnim:String = note.animSuffix;
		var char:Character = dad;

		if (SONG.notes[curSection] != null)
			if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection)
				altAnim = '-alt';

		if (note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if (!note.noAnimation) {
			if(note.gfNote) char = gf;
			if(char != null) {
				char.playAnim('sing' + mainAnim + altAnim, true);
				char.holdTimer = 0;
			}
		}

		// Lua Character Opponent Animation
		for(luaChar in luaCharsMap) {
			if(!luaChar.isPlayer && luaChar.testNote(note.noteType)) {
				if(note.noteType == 'Hey!' && luaChar.animOffsets.exists('hey') && luaChar.luaCharHey) {
					luaChar.playAnim('hey', true);
					luaChar.specialAnim = true;
					luaChar.heyTimer = 0.6;
				} else {
					luaChar.playAnim('sing' + mainAnim + altAnim, true);
					luaChar.holdTimer = 0;
				}
			}
		}

		// Special Camera Move
		if (SONG.cameraMoveOnNotes && ClientPrefs.cameramoveonnotes && !note.isSustainNote) {
			if(gf != null && SONG.notes[curSection].gfSection)
				cameraSpecialMovement(1, note.noteData);
			else if(!SONG.notes[curSection].mustHitSection)
				cameraSpecialMovement(2, note.noteData);
		}

		// Health Drain
		if(SONG.healthdrain > 0) {
			var opDrain = SONG.healthdrain / 250;
			if (SONG.healthdrainKill) health -= opDrain;
			else {
				if (health - opDrain < 0) health = 0.01;
				else if(health - opDrain > 0) health -= opDrain;
			}
		}

		if (SONG.needsVoices) vocals.volume = vocalGeneralVol;

		var time:Float = 0.15;
		//if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('tail'))
			time += 0.15;

		//StrumPlayAnim(true, Std.int(Math.abs(note.noteData)), time);
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % Note.ammo[mania], time);
		note.hitByOpponent = true;

		// if(!note.noAnimation) {
		// 	var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + note.animSuffix;
		// 	LuaChar.instance.charNoteHit(note.noteType, note.hitByOpponent, animToPlay);
		// }

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote, note.strumTime]);
		callOnHScripts('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote, note.strumTime]);

		if (!note.isSustainNote) {
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void {
		if (!note.wasGoodHit) {
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled) //Hit sound
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);

			// Miss Notes
			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote)
					spawnNoteSplashOnNote(note);

				if(!note.noMissAnimation) {
					switch(note.noteType) {
						case 'Hurt Note':
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}
					}
				}
				note.wasGoodHit = true;
				if (!note.isSustainNote) {
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			// Score and Health
			if (!note.isSustainNote) {
				combo += 1;
				if(combo > 9999) combo = 9999;
				popUpScore(note);
				if(health < 2) health += note.hitHealth * healthGain;
			}

			//var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];
			var mainAnim:String = Note.keysShit.get(mania).get('anims')[note.noteData];
			var altAnim:String = note.animSuffix;

			if(SONG.notes[curSection] != null)
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection)
					altAnim = '-alt';

			if(!note.gfNote && healthBar.percent < 35 && boyfriend.animation.exists('sing' + mainAnim + '-low'))
				altAnim = '-low';

			// Character Animation
			if(note.noteType == 'Hey!') {
				if(boyfriend.animOffsets.exists('hey')) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = 0.6;
				}
				if(gf != null && gf.animOffsets.exists('cheer')) {
					gf.playAnim('cheer', true);
					gf.specialAnim = true;
					gf.heyTimer = 0.6;
				}
			} else if(!note.noAnimation) {
				if(note.gfNote) {
					if(gf != null) {
						gf.playAnim('sing' + mainAnim + altAnim, true);
						gf.holdTimer = 0;
					}
				} else {
					boyfriend.playAnim('sing' + mainAnim + altAnim, true);
					boyfriend.holdTimer = 0;
				}
			}

			// Lua Character Player Animation
			for(luaChar in luaCharsMap) {
				if(luaChar.isPlayer && luaChar.testNote(note.noteType)) {
					if(altAnim == '-low' && !luaChar.animation.exists('sing' + mainAnim + '-low')) altAnim == '';
					if(note.noteType == 'Hey!' && luaChar.animOffsets.exists('hey') && luaChar.luaCharHey) {
						luaChar.playAnim('hey', true);
						luaChar.specialAnim = true;
						luaChar.heyTimer = 0.6;
					} else {
						luaChar.playAnim('sing' + mainAnim + altAnim, true);
						luaChar.holdTimer = 0;
					}
				}
			}

			// Special Camera Move
			if (SONG.cameraMoveOnNotes && ClientPrefs.cameramoveonnotes && !note.isSustainNote) {
				if(gf != null && SONG.notes[curSection].gfSection)
					cameraSpecialMovement(1, note.noteData);
				else if(SONG.notes[curSection].mustHitSection)
					cameraSpecialMovement(0, note.noteData);
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('tail'))
					time += 0.15;

				//StrumPlayAnim(false, Std.int(Math.abs(note.noteData)), time);
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % Note.ammo[mania], time);
			} else {
				var spr = playerStrums.members[note.noteData];
				if(spr != null) {
					spr.playAnim('confirm', true);
				}
			}

			note.wasGoodHit = true;
			vocals.volume = vocalGeneralVol;

			var leData:Int = Math.round(Math.abs(note.noteData));
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, note.noteType, note.isSustainNote, note.strumTime]);
			callOnHScripts('goodNoteHit', [notes.members.indexOf(note), leData, note.noteType, note.isSustainNote, note.strumTime]);

			if (!note.isSustainNote) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		var hue:Float = 0;
		var sat:Float = 0;
		var brt:Float = 0;
		if (data > -1 && data < ClientPrefs.arrowHSV.length) {
			// hue = ClientPrefs.arrowHSV[data][0] / 360;
			// sat = ClientPrefs.arrowHSV[data][1] / 100;
			// brt = ClientPrefs.arrowHSV[data][2] / 100;
			hue = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[data] % Note.ammo[mania])][0] / 360;
			sat = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[data] % Note.ammo[mania])][1] / 100;
			brt = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[data] % Note.ammo[mania])][2] / 100;
			if(note != null) {
				skin = note.noteSplashTexture;
				hue = note.noteSplashHue;
				sat = note.noteSplashSat;
				brt = note.noteSplashBrt;
			}
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	public var cameramovingoffset:Float = 20;
	public function cameraSpecialMovement(char:Int, noteData:Int, ?luaChar:String) {
		switch(char) {
			case 1:
				var camX:Float = gf.getMidpoint().x + 160 + (gf.cameraPosition[0] + girlfriendCameraOffset[0]);
				var camY:Float = gf.getMidpoint().y + (gf.cameraPosition[1] + girlfriendCameraOffset[1]);
				if(!gf.stunned) {
					makeMovement(camX, camY, noteData);
				}
			case 2:
				var camX:Float = dad.getMidpoint().x + 150 + (dad.cameraPosition[0] + opponentCameraOffset[0]);
				var camY:Float = dad.getMidpoint().y - 100 + (dad.cameraPosition[1] + opponentCameraOffset[1]);
				if(!dad.stunned) {
					makeMovement(camX, camY, noteData);
				}
			case 3: // Only with Lua
				if(luaChar!=null && luaCharsMap.exists(luaChar)) {
					var luaCharacter:LuaChar = luaCharsMap.get(luaChar);
					var camX:Float = luaCharacter.getMidpoint().x + luaCharacter.cameraPosition[0];
					var camY:Float = luaCharacter.getMidpoint().y + luaCharacter.cameraPosition[1];
					if(!luaCharacter.stunned) {
						makeMovement(camX, camY, noteData);
					}
				} else {
					cameraSpecialMovement(0, noteData);
				}
			default:
				var camX:Float = boyfriend.getMidpoint().x - 100 - (boyfriend.cameraPosition[0] - boyfriendCameraOffset[0]);
				var camY:Float = boyfriend.getMidpoint().y - 100 + (boyfriend.cameraPosition[1] + boyfriendCameraOffset[1]);
				if(!boyfriend.stunned) {
					makeMovement(camX, camY, noteData);
				}
		}
	}

	private function makeMovement(cameraX:Float, cameraY:Float, noteData:Int) {
		var animIndex:String = Note.keysShit.get(mania).get('anims')[noteData];
		if(animIndex == 'LEFT') {
			camFollow.x = cameraX - cameramovingoffset;
			camFollow.y = cameraY;
		} else if(animIndex == 'RIGHT') {							
			camFollow.x = cameraX + cameramovingoffset;
			camFollow.y = cameraY;
		} else if(animIndex == 'UP') {
			camFollow.x = cameraX;
			camFollow.y = cameraY - cameramovingoffset;
		} else if(animIndex == 'DOWN') {
			camFollow.x = cameraX;
			camFollow.y = cameraY + cameramovingoffset;
		}
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
		  || (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20)) {
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', [curStep]);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var lastBeatHit:Int = -1;
	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		dancingLeft = !dancingLeft;

		if (ClientPrefs.iconbops == "Especial") {
			// OS Engine didn't have this update, BRUH...
			// if (dancingLeft){
			// 	iconP1.angle = 8; iconP2.angle = 8; // maybe i should do it with tweens, but i'm lazy // i'll make it in -1.0.0, i promise
			// } else { 
			// 	iconP1.angle = -8; iconP2.angle = -8;
			// }
			// So I've done it now! WHOA!
			if (dancingLeft){
				iconP1Tween = FlxTween.angle(iconP1, iconP1.angle, 8, Conductor.crochet / 6000, { ease: FlxEase.quadInOut });
				iconP2Tween = FlxTween.angle(iconP2, iconP2.angle, 8, Conductor.crochet / 6000, { ease: FlxEase.quadInOut });
			} else { 
				iconP1Tween = FlxTween.angle(iconP1, iconP1.angle, -8, Conductor.crochet / 6000, { ease: FlxEase.quadInOut });
				iconP2Tween = FlxTween.angle(iconP2, iconP2.angle, -8, Conductor.crochet / 6000, { ease: FlxEase.quadInOut });
			}
		}

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned) {
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned) {
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned) {
			dad.dance();
		}
		for (luaChar in luaCharsMap) {
			if (curBeat % luaChar.danceEveryNumBeats == 0 && luaChar.animation.curAnim != null && !luaChar.animation.curAnim.name.startsWith('sing') && !luaChar.stunned) {
				luaChar.dance();
			}
		}

		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat);
		callOnLuas('onBeatHit', [curBeat]);
		callOnHScripts('beatHit', [curBeat]);
	}

	public function setCameraForced(kade:Bool):Void {
        isCameraOnForcedPos = kade;
    }

	override function sectionHit() {
		super.sectionHit();

		if (SONG.notes[curSection] != null) {
			if (generatedMusic && !endingSong && !isCameraOnForcedPos) {
				moveCameraSection();
			}

			daZooming(true, true, true, camZoomingMult);

			if (SONG.notes[curSection].changeBPM) {
				Conductor.changeBPM(SONG.notes[curSection].bpm);
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnLuas('altAnim', SONG.notes[curSection].altAnim);
			setOnLuas('gfSection', SONG.notes[curSection].gfSection);
		}
		
		setOnLuas('curSection', curSection);
		callOnLuas('onSectionHit', []);
		callOnHScripts('sectionHit', [curSection]);
	}

	public function daZooming(cgame:Bool = false, chud:Bool = false, cother:Bool = false, mult:Float = 1) {
		if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms) {
			if(cgame) FlxG.camera.zoom += camGameZooming * mult;
			if(chud) camHUD.zoom += camHudZooming * mult;
			if(cother) camOther.zoom += camOtherZooming * mult;
		}
	}

	function callSingleHScript(func:String, args:Array<Dynamic>, filename:String) {
		if (!hscriptArray.get(filename).variables.exists(func)) {
			return;
		}
		var method = hscriptArray.get(filename).variables.get(func);
		if (args.length == 0) {
			method();
		} else if (args.length == 1) {
			method(args[0]);
		} else if (args.length == 5) {
			method(args[0], args[1], args[2], args[3], args[4]);
		} else if (args.length == 4) {
			method(args[0], args[1], args[2], args[3]);
		}else if (args.length == 3) {						// BEST CODE EVER I KNOW
			method(args[0], args[1], args[2]);
		}else if (args.length == 2) {
			method(args[0], args[1]);
		}
	}

	function callOnHScripts(func:String, args:Array<Dynamic>) {
		for (i in hscriptArray.keys()) {
			callSingleHScript(func, args, i);	// it could be easier ig
		}
	}

	// original
	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			var ret:Dynamic = script.call(event, args);
			if(ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;
			
			if(ret != FunkinLua.Function_Continue)
				returnVal = ret;
		}
		#end
		//trace(event, returnVal);
		return returnVal;
	}
	// new
	// public function callOnLuas(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
	// 	var returnVal:Dynamic = FunkinLua.Function_Continue;
	// 	#if LUA_ALLOWED
	// 	if(args == null) args = [];
	// 	if(exclusions == null) exclusions = [];
	// 	if(excludeValues == null) excludeValues = [FunkinLua.Function_Continue];
	// 	var len:Int = luaArray.length;
	// 	var i:Int = 0;
	// 	while(i < len) {
	// 		var script:FunkinLua = luaArray[i];
	// 		if(exclusions.contains(script.scriptName)) {
	// 			i++;
	// 			continue;
	// 		}
	// 		var myValue:Dynamic = script.call(funcToCall, args);
	// 		if((myValue == FunkinLua.Function_StopLua || myValue == FunkinLua.Function_Stop) && !excludeValues.contains(myValue) && !ignoreStops) {
	// 			returnVal = myValue;
	// 			break;
	// 		}	
	// 		if(myValue != null && !excludeValues.contains(myValue))
	// 			returnVal = myValue;
	// 		if(!script.closed) i++;
	// 		else len--;

	// 	}
	// 	#end
	// 	return returnVal;
	// }

	// New
	public function callOnScripts(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		var result:Dynamic = callOnLuas(event, args, ignoreStops, exclusions);
		//if(result == null || excludeValues.contains(result)) result = callOnHScripts(event, args);
		return result;
	}

	// original
	// public function setOnLuas(variable:String, arg:Dynamic) {
	// 	#if LUA_ALLOWED
	// 	for (i in 0...luaArray.length) {
	// 		luaArray[i].set(variable, arg);
	// 	}
	// 	#end
	// }

	// new
	public function setOnLuas(variable:String, arg:Dynamic, ?exclusions:Array<String> = null) {
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;
			script.set(variable, arg);
		}
		#end
	}

	// New
	public function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		if(exclusions == null) exclusions = [];
		setOnLuas(variable, arg, exclusions);
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;
	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var formattedRatingPct:Float;
	public var ratingFC:String;
	private var closedScore:Bool = false;
	private function popUpScore(note:Note = null):Void {
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);

		allNotesMs += noteDiff;
		averageMs = allNotesMs/songHits;
		if (ClientPrefs.showMsText) {
			msTimeTxt.alpha = 1;
			msTimeTxt.text = Std.string(Math.round(noteDiff)) + "ms";
			if (msTimeTxtTween != null){
				msTimeTxtTween.cancel(); 
				msTimeTxtTween.destroy();
			}
			msTimeTxtTween = FlxTween.tween(msTimeTxt, {alpha: 0}, 0.25, {
				onComplete: function(tw:FlxTween) {msTimeTxtTween = null;},
				startDelay: 0.7
			});
		}

		vocals.volume = vocalGeneralVol;

		var placement:Float =  FlxG.width * 0.35;
		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(ratingsData, noteDiff);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.increase();
		note.rating = daRating.name;
		score = daRating.score;

		if(daRating.noteSplash && !note.noteSplashDisabled) {
			spawnNoteSplashOnNote(note);
		}

		if(!closedScore){
			if(!practiceMode && !cpuControlled) {
				songScore += score;
				if(!note.ratingDisabled) {
					songHits++;
					totalPlayed++;
					RecalculateRating(false);
				}
			}
		}

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';
		var antialias:Bool = ClientPrefs.globalAntialiasing;
		
		if (isPixelStage) {
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
			antialias = !isPixelStage;
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = placement - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];
		rating.antialiasing = antialias;

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = placement;
		comboSpr.acceleration.y = FlxG.random.int(200, 300);
		comboSpr.velocity.y -= FlxG.random.int(140, 160);
		comboSpr.visible = (!ClientPrefs.hideHud && showCombo);
		comboSpr.x += ClientPrefs.comboOffset[0];
		comboSpr.y -= ClientPrefs.comboOffset[1];
		comboSpr.antialiasing = antialias;
		comboSpr.y += 60;
		comboSpr.velocity.x += FlxG.random.int(1, 10);

		insert(members.indexOf(strumLineNotes), rating);

		if (!PlayState.isPixelStage) {
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		} else {
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (showCombo) {
			insert(members.indexOf(strumLineNotes), comboSpr);
		}
		for (i in seperatedScore) {
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = placement + (43 * daLoop) - 90 + ClientPrefs.comboOffset[2];
			numScore.y += 80 - ClientPrefs.comboOffset[3];

			if (!PlayState.isPixelStage) numScore.setGraphicSize(Std.int(numScore.width * 0.45));
			else numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.visible = !ClientPrefs.hideHud;
			numScore.antialiasing = antialias;

			//if (combo >= 10 || combo == 0)
			if(showComboNum)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween) {
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}
		comboSpr.x = xThing + 50;
		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				comboSpr.destroy();
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002
		});
	}

	public function RecalculateRating(badHit:Bool = false) {
		var ret:Dynamic = callOnLuas('onRecalculateRating', [], false);
		if(ret != FunkinLua.Function_Stop) {
			ratingName = '?';
			if(totalNotesHit > 0 && totalPlayed != 0) { //Prevent divide by 0
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));

				// Rating Name/FC
				ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				ratingFC = 'LIMPO';
				if(ratingPercent <= 1)
					for (i in 0...ratingStuff.length-1)
						if(ratingPercent >= ratingStuff[i][1]) {
							ratingName = ratingStuff[i][0];
							ratingFC = ratingStuff[i][2]; // Nova definição do FC (New way to define FC)
							break;
						}
			}
			fullComboFunction();
		}
		updateScore(badHit);
	}

	public function updateScore(miss:Bool = false) {
		formattedRatingPct = Highscore.floorDecimal(ratingPercent * 100, 2);
		if(ClientPrefs.getGameplaySetting('botplay', false) || closedScore) {
			scoreTxt.text = 'Pontos: -000000 | Erros: -100000 | Precisão: -999% | Botplay [BRUH]';
			closedScore = true;
		} else {
			if(ratingName == '?') {
				scoreTxt.text = 'Pontos: ' + songScore
				+ ' | Erros: ' + songMisses
				+ ' | Precisão: ' + ratingName;
			} else {
				scoreTxt.text = 'Pontos: ' + songScore
				+ ' | Erros: ' + songMisses
				+ ' | Precisão: ' + formattedRatingPct + '%'
				+ ' | ' + ratingName + ' [ ' + ratingFC + ' ]';
			}

			if(ClientPrefs.scoreZoom && !miss && !cpuControlled) {
				if(scoreTxtTween != null) {
					scoreTxtTween.cancel();
				}
				scoreTxt.scale.x = 1.085;
				scoreTxt.scale.y = 1.085;
				scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween) {
						scoreTxtTween = null;
					}
				});
			}
		}
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('rating', ratingPercent);
		setOnLuas('formatterdRating', formattedRatingPct);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
		setOnLuas('hits', songHits);
		callOnLuas('onUpdateScore', [miss]);
	}

	function fullComboUpdate() {
	// Psych 0.7.1
	/* 	var sicks:Int = ratingsData[0].hits;
		var goods:Int = ratingsData[1].hits;
		var bads:Int = ratingsData[2].hits;
		var shits:Int = ratingsData[3].hits;
		
		ratingFC = 'Clear';
		if(songMisses < 1)
		{
			if (bads > 0 || shits > 0) ratingFC = 'FC';
			else if (goods > 0) ratingFC = 'GFC';
			else if (sicks > 0) ratingFC = 'SFC';
		}
		else if (songMisses < 10)
			ratingFC = 'SDCB';

	// OS Engine / Old Psychs
		ratingFC = "";
		if (perfects > 0 && !ClientPrefs.removePerfects) ratingFC = "SS+";
		if (sicks > 0) ratingFC = "A";
		if (goods > 0) ratingFC = "B";
		if (bads > 0 || shits > 0) ratingFC = "D";
		if (songMisses > 0 && songMisses < 10) ratingFC = "S+";
		else if (songMisses >= 10) ratingFC = "A+";
	*/
	}

	override function destroy() {
		for (lua in luaArray) {
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];

		// if(!ClientPrefs.controllerMode)
		// {
		// 	FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		// 	FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		// }
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		#if hscript
		FunkinLua.haxeInterp = null;
		#end

		super.destroy();
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if(chartingMode) return null;
		var acceptableDiff:Bool = false;
		if((CoolUtil.difficultyString() == 'DIFICIL' || CoolUtil.difficultyString() == 'NSANO')) acceptableDiff = true;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled) {
				var unlock:Bool = false;
				switch(achievementName) {
					// Para as semanas
					case 'week1_nomiss' | 'week2_nomiss' | 'week3_nomiss' | 'week4_nomiss' | 'week5_nomiss' | 'intro_nomiss'| 'warp1_nomiss' | 'megamix_nomiss' | 'fnf_nomiss' | 'extra_nomiss':
						if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'DIFICIL' && storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice) {
							var weekName:String = WeekData.getWeekFileName();
							switch(weekName) { //I know this is a lot of duplicated code, but it's easier readable and you can add weeks with different names than the achievement tag
								//Para toda semana completada de forma perfeita
								// case 'week1':
								// 	if(achievementName == 'week1_nomiss') unlock = true;
								// case 'week2':
								// 	if(achievementName == 'week2_nomiss') unlock = true;
								// case 'week3':
								// 	if(achievementName == 'week3_nomiss') unlock = true;
								// case 'week4':
								// 	if(achievementName == 'week4_nomiss') unlock = true;
								// case 'week5':
								// 	if(achievementName == 'week5_nomiss') unlock = true;
								case 'intro':
									if(achievementName == 'intro_nomiss') unlock = true;
								case 'warp1':
									if(achievementName == 'warp1_nomiss') unlock = true;
								// case 'megamix':
								// 	if(achievementName == 'megamix_nomiss') unlock = true;
								// case 'fnf':
								// 	if(achievementName == 'fnf_nomiss') unlock = true;
								// case 'extra':
								// 	if(achievementName == 'extra_nomiss') unlock = true;
							}
						}

					// Tenha 20% ou menos
					case 'ur_bad':
						if(Paths.formatToSongPath(SONG.song) != 'estatisticas' && ratingPercent < 0.2 && !practiceMode) {
							unlock = true;
						}
					// Tenha 100% ou mais (até parece q vai ter mais...)
					case 'ur_good':
						if(Paths.formatToSongPath(SONG.song) != 'estatisticas' && ratingPercent >= 1 
							&& !usedPractice && acceptableDiff) {
							unlock = true;
						}
					// Nada...
					// case 'roadkill_enthusiast':
					// 	if(Paths.formatToSongPath(SONG.song) != 'estatisticas' && Achievements.henchmenDeath >= 100) {
					// 		unlock = true;
					// 	}
					// Nota Longa
					case 'oversinging':
						if(Paths.formatToSongPath(SONG.song) != 'estatisticas' && boyfriend.holdTimer >= 10 && !usedPractice) {
							unlock = true;
						}
					// Sem ficar Ocioso
					case 'hype':
						if(Paths.formatToSongPath(SONG.song) != 'estatisticas' && !boyfriendIdled && !usedPractice) {
							unlock = true;
						}
					// Apenas duas notas
					case 'two_keys':
						if(Paths.formatToSongPath(SONG.song) != 'estatisticas' && !usedPractice) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								unlock = true;
							}
						}
					// Graficos Ruins
					case 'toastie':
						if(Paths.formatToSongPath(SONG.song) != 'estatisticas' &&
							(Paths.formatToSongPath(SONG.song) == 'bosques-de-wumpa' || Paths.formatToSongPath(SONG.song) == 'bonus' ||
							Paths.formatToSongPath(SONG.song) == 'templo-obscuro' || Paths.formatToSongPath(SONG.song) == 'canal-toxico') &&
							ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing && !ClientPrefs.imagesPersist) {
							unlock = true;
						}
					// Zona de Testes
					case 'debugger':
						if(Paths.formatToSongPath(SONG.song) == 'teste-zone' && !usedPractice) {
							unlock = true;
						}
					//Para Musicas Sem Erros!
					// Bosque
					case 'music1':
						if(Paths.formatToSongPath(SONG.song) == 'bosques-de-wumpa' && songMisses < 1) {
							unlock = true;
						}
					// Bonus
					case 'music2':
						if(Paths.formatToSongPath(SONG.song) == 'bonus' && songMisses < 1) {
							unlock = true;
						}
					// Templo
					case 'music3':
						if(Paths.formatToSongPath(SONG.song) == 'templo-obscuro' && songMisses < 1) {
							unlock = true;
						}
					// Esgoto
					case 'music4':
						if(Paths.formatToSongPath(SONG.song) == 'canal-toxico' && songMisses < 1) {
							unlock = true;
						}
					//Para Musicas Insanamente Perfeitas!
					// Bosque
					case 'perfect1':
						if(Paths.formatToSongPath(SONG.song) == 'bosques-de-wumpa' && ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
					// Bonus
					case 'perfect2':
						if(Paths.formatToSongPath(SONG.song) == 'bonus' && ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
					// Templo
					case 'perfect3':
						if(Paths.formatToSongPath(SONG.song) == 'templo-obscuro' && ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
					// Esgoto
					case 'perfect4':
						if(Paths.formatToSongPath(SONG.song) == 'canal-toxico' && ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end
}