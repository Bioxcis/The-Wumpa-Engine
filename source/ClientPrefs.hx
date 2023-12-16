package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

class ClientPrefs {
	public static var downScroll:Bool = false;
	public static var middleScroll:Bool = false;
	public static var showFPS:Bool = false;
	public static var flashing:Bool = true;
	public static var autosaveInterval:Int = 5;
	public static var autosavecharts:Bool = true;
	public static var themedmainmenubg:Bool = false;
	public static var autotitleskip:Bool = false;
	public static var globalAntialiasing:Bool = true;
	public static var noteSplashes:Bool = true;
	public static var lowQuality:Bool = false;
	public static var framerate:Int = 60;
	public static var cursing:Bool = true;
	public static var violence:Bool = true;
	public static var flashWarning:Bool = true;
	public static var camZooms:Bool = true;
	public static var hideHud:Bool = false;
	public static var hideWatermark:Bool = false;
	public static var hideScoreText:Bool = false;
	public static var noteOffset:Int = 0;
	//public static var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
	public static var arrowHSV:Array<Array<Int>> = [
		[0, 0, 0], [0, 0, 0],
		[0, 0, 0], [0, 0, 0],
		[0, 0, 0], [0, 0, 0],
		[0, 0, 0], [0, 0, 0],
		[0, 0, 0], [0, 0, 0],
		[0, 0, 0], [0, 0, 0],
		[0, 0, 0], [0, 0, 0],
		[0, 0, 0], [0, 0, 0],
		[0, 0, 0], [0, 0, 0]
	];
	public static var imagesPersist:Bool = false;
	public static var ghostTapping:Bool = false;
	public static var timeBarType:String = 'Tempo Restante';
	public static var iconbops:String = 'Especial';
	public static var colorblindMode:String = 'Nada';
	public static var opponentStrums:Bool = false;
	public static var scoreZoom:Bool = true;
	public static var hudSize:Bool = true;
	public static var shadersActive:Bool = true;
	public static var showStatus:Bool = false;
	public static var noReset:Bool = false;
	public static var showMsText:Bool = false;
	public static var healthBarAlpha:Float = 1;
	public static var controllerMode:Bool = false;
	public static var hitsoundVolume:Float = 0;
	public static var underlaneVisibility:Float = 0;
	public static var holdNoteVisibility:Float = 1;
	public static var opponentUnderlaneVisibility:Float = 0;
	public static var noteSkinSettings:String = 'Classico';
	public static var pauseMusic:String = 'Crash Time';
	public static var showcaseMode:Bool = false;
	public static var cameramoveonnotes:Bool = true;
	public static var removePerfects:Bool = false;
	public static var characterTrail:Bool = false;
	public static var checkForUpdates:Bool = true;

	// Set in Lua for Crash Night Funkin Mod
	public static var tntrules:Bool = false;
	public static var nitrorules:Bool = false;
	public static var trialrules:Bool = false;

	public static var convertEK:Bool = true;
	public static var showKeybindsOnStart:Bool = true;
	public static var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicativo', 
		// anyone reading this, amod is multiplicative speed mod, cmod is constant speed mod, and xmod is bpm based speed mod.
		// an amod example would be chartSpeed * multiplier
		// cmod would just be constantSpeed = chartSpeed
		// and xmod basically works by basing the speed on the bpm.
		// iirc (beatsPerSecond * (conductorToNoteDifference / 1000)) * noteSize (110 or something like that depending on it, prolly just use note.height)
		// bps is calculated by bpm / 60
		// oh yeah and you'd have to actually convert the difference to seconds which I already do, because this is based on beats and stuff. but it should work
		// just fine. but I wont implement it because I don't know how you handle sustains and other stuff like that.
		// oh yeah when you calculate the bps divide it by the songSpeed or rate because it wont scroll correctly when speeds exist.
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'botplay' => false,
		'opponentplay' => false
	];

	public static var comboOffset:Array<Int> = [64, -123, 185, -90];
	public static var ratingOffset:Int = 0;
	public static var perfectWindow:Int = 15;
	public static var sickWindow:Int = 45;
	public static var goodWindow:Int = 90;
	public static var badWindow:Int = 135;
	public static var safeFrames:Float = 10;

	// Every key has two bindings, add your default key binding here.
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		// 1K
		'note_one1'		=> [SPACE, G],
		// 2K
		'note_two1'		=> [D, LEFT],
		'note_two2'		=> [L, RIGHT],
		// 3K
		'note_three1'	=> [D, LEFT],
		'note_three2'	=> [SPACE, NONE],
		'note_three3'	=> [L, RIGHT],
		// 4K
		'note_left'		=> [A, LEFT],
		'note_down'		=> [S, DOWN],
		'note_up'		=> [W, UP],
		'note_right'	=> [D, RIGHT],
		// 5K
		'note_five1'	=> [A, LEFT],
		'note_five2'	=> [S, DOWN],
		'note_five3'	=> [SPACE, G],
		'note_five4'	=> [K, UP],
		'note_five5'	=> [L, RIGHT],
		// 6K
		'note_six1'		=> [A, Q],
		'note_six2'		=> [S, W],
		'note_six3'		=> [D, E],
		'note_six4'		=> [J, I],
		'note_six5'		=> [K, O],
		'note_six6'		=> [L, P],
		// 7K
		'note_seven1'	=> [A, Q],
		'note_seven2'	=> [S, W],
		'note_seven3'	=> [D, E],
		'note_seven4'	=> [SPACE, G],
		'note_seven5'	=> [J, I],
		'note_seven6'	=> [K, O],
		'note_seven7'	=> [L, P],
		// 8K
		'note_eight1'	=> [A, Q],
		'note_eight2'	=> [S, W],
		'note_eight3'	=> [D, E],
		'note_eight4'	=> [F, R],
		'note_eight5'	=> [H, U],
		'note_eight6'	=> [J, I],
		'note_eight7'	=> [K, O],
		'note_eight8'	=> [L, P],
		// 9K
		'note_nine1'	=> [A, Q],
		'note_nine2'	=> [S, W],
		'note_nine3'	=> [D, E],
		'note_nine4'	=> [F, R],
		'note_nine5'	=> [SPACE, G],
		'note_nine6'	=> [H, U],
		'note_nine7'	=> [J, I],
		'note_nine8'	=> [K, O],
		'note_nine9'	=> [L, P],
		// 10K
		'note_ten1'		=> [A, Q],
		'note_ten2'		=> [S, W],
		'note_ten3'		=> [D, E],
		'note_ten4'		=> [F, R],
		'note_ten5'		=> [G, T],
		'note_ten6'		=> [SPACE, Y],
		'note_ten7'		=> [H, U],
		'note_ten8'     => [J, I],
		'note_ten9'		=> [K, O],
		'note_ten10'	=> [L, P],
		// 11K
		'note_elev1'	=> [A, Q],
		'note_elev2'	=> [S, W],
		'note_elev3'	=> [D, E],
		'note_elev4'	=> [F, R],
		'note_elev5'	=> [G, T],
		'note_elev6'	=> [SPACE, NONE],
		'note_elev7'	=> [H, Y],
		'note_elev8'    => [J, U],
		'note_elev9'	=> [K, I],
		'note_elev10'	=> [L, O],
		'note_elev11'	=> [PERIOD, P],
		// 12K
		'note_twel1'	=> [A, NONE],
		'note_twel2'	=> [S, NONE],
		'note_twel3'	=> [D, NONE],
		'note_twel4'	=> [F, NONE],
		'note_twel5'	=> [C, NONE],
		'note_twel6'	=> [V, NONE],
		'note_twel7'	=> [N, NONE],
		'note_twel8'    => [M, NONE],
		'note_twel9'	=> [H, NONE],
		'note_twel10'	=> [J, NONE],
		'note_twel11'	=> [K, NONE],
		'note_twel12'	=> [L, NONE],
		// 13K
		'note_thir1'	=> [A, NONE],
		'note_thir2'	=> [S, NONE],
		'note_thir3'	=> [D, NONE],
		'note_thir4'	=> [F, NONE],
		'note_thir5'	=> [C, NONE],
		'note_thir6'	=> [V, NONE],
		'note_thir7'	=> [SPACE, NONE],
		'note_thir8'	=> [N, NONE],
		'note_thir9'    => [M, NONE],
		'note_thir10'	=> [H, NONE],
		'note_thir11'	=> [J, NONE],
		'note_thir12'	=> [K, NONE],
		'note_thir13'	=> [L, NONE],
		// 14K
		'note_fourt1'	=> [A, NONE],
		'note_fourt2'	=> [S, NONE],
		'note_fourt3'	=> [D, NONE],
		'note_fourt4'	=> [F, NONE],
		'note_fourt5'	=> [C, NONE],
		'note_fourt6'	=> [V, NONE],
		'note_fourt7'	=> [T, NONE],
		'note_fourt8'    => [Y, NONE],
		'note_fourt9'	=> [N, NONE],
		'note_fourt10'	=> [M, NONE],
		'note_fourt11'	=> [H, NONE],
		'note_fourt12'	=> [J, NONE],
		'note_fourt13'	=> [K, NONE],
		'note_fourt14'	=> [L, NONE],
		// 15K
		'note_151'		=> [A, NONE],
		'note_152'		=> [S, NONE],
		'note_153'		=> [D, NONE],
		'note_154'		=> [F, NONE],
		'note_155'		=> [C, NONE],
		'note_156'		=> [V, NONE],
		'note_157'		=> [T, NONE],
		'note_158'    	=> [Y, NONE],
		'note_159'    	=> [U, NONE],
		'note_1510'		=> [N, NONE],
		'note_1511'		=> [M, NONE],
		'note_1512'		=> [H, NONE],
		'note_1513'		=> [J, NONE],
		'note_1514'		=> [K, NONE],
		'note_1515'		=> [L, NONE],
		// 16K
		'note_161'		=> [A, NONE],
		'note_162'		=> [S, NONE],
		'note_163'		=> [D, NONE],
		'note_164'		=> [F, NONE],
		'note_165'		=> [Q, NONE],
		'note_166'		=> [W, NONE],
		'note_167'		=> [E, NONE],
		'note_168'    	=> [R, NONE],
		'note_169'    	=> [Y, NONE],
		'note_1610'		=> [U, NONE],
		'note_1611'		=> [I, NONE],
		'note_1612'		=> [O, NONE],
		'note_1613'		=> [H, NONE],
		'note_1614'		=> [J, NONE],
		'note_1615'		=> [K, NONE],
		'note_1616'		=> [L, NONE],
		// 17K
		'note_171'		=> [A, NONE],
		'note_172'		=> [S, NONE],
		'note_173'		=> [D, NONE],
		'note_174'		=> [F, NONE],
		'note_175'		=> [Q, NONE],
		'note_176'		=> [W, NONE],
		'note_177'		=> [E, NONE],
		'note_178'    	=> [R, NONE],
		'note_179'		=> [SPACE, NONE],
		'note_1710'    	=> [Y, NONE],
		'note_1711'		=> [U, NONE],
		'note_1712'		=> [I, NONE],
		'note_1713'		=> [O, NONE],
		'note_1714'		=> [H, NONE],
		'note_1715'		=> [J, NONE],
		'note_1716'		=> [K, NONE],
		'note_1717'		=> [L, NONE],
		// 18K
		'note_181'		=> [A, NONE],
		'note_182'		=> [S, NONE],
		'note_183'		=> [D, NONE],
		'note_184'		=> [F, NONE],
		'note_185'		=> [SPACE, NONE],
		'note_186'		=> [H, NONE],
		'note_187'		=> [J, NONE],
		'note_188'		=> [K, NONE],
		'note_189'  	=> [L, NONE],
		'note_1810' 	=> [Q, NONE],
		'note_1811'		=> [W, NONE],
		'note_1812'		=> [E, NONE],
		'note_1813'		=> [R, NONE],
		'note_1814'		=> [T, NONE],
		'note_1815'		=> [Y, NONE],
		'note_1816'		=> [U, NONE],
		'note_1817'		=> [I, NONE],
		'note_1818'		=> [O, NONE],
		
		'ui_left'		=> [A, LEFT],
		'ui_down'		=> [S, DOWN],
		'ui_up'			=> [W, UP],
		'ui_right'		=> [D, RIGHT],
		
		'accept'		=> [SPACE, ENTER],
		'back'			=> [BACKSPACE, ESCAPE],
		'pause'			=> [ENTER, ESCAPE],
		'reset'			=> [R, NONE],
		
		'volume_mute'	=> [ZERO, NONE],
		'volume_up'		=> [NUMPADPLUS, PLUS],
		'volume_down'	=> [NUMPADMINUS, MINUS],
		
		'debug_1'		=> [SEVEN, NONE],
		'debug_2'		=> [EIGHT, NONE]
	];
	//public static var defaultKeys:Map<String, Array<FlxKey>> = null;
	public static var defaultKeys:Map<String, Array<FlxKey>> = keyBinds;

	// public static function loadDefaultKeys() {
	// 	defaultKeys = keyBinds.copy();
	// 	//trace(defaultKeys);
	// }

	public static function saveSettings() {
		FlxG.save.data.downScroll = downScroll;
		FlxG.save.data.middleScroll = middleScroll;
		FlxG.save.data.showFPS = showFPS;
		FlxG.save.data.flashing = flashing;
		FlxG.save.data.globalAntialiasing = globalAntialiasing;
		FlxG.save.data.noteSplashes = noteSplashes;
		FlxG.save.data.lowQuality = lowQuality;
		FlxG.save.data.framerate = framerate;
		//FlxG.save.data.cursing = cursing;
		//FlxG.save.data.violence = violence;
		FlxG.save.data.flashWarning = flashWarning;
		FlxG.save.data.camZooms = camZooms;
		FlxG.save.data.colorblindMode = colorblindMode;
		FlxG.save.data.opponentStrums = opponentStrums;
		FlxG.save.data.noteOffset = noteOffset;
		FlxG.save.data.hideHud = hideHud;
		FlxG.save.data.hideWatermark = hideWatermark;
		FlxG.save.data.hideScoreText = hideScoreText;
		FlxG.save.data.arrowHSV = arrowHSV;
		FlxG.save.data.imagesPersist = imagesPersist;
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.data.timeBarType = timeBarType;
		FlxG.save.data.scoreZoom = scoreZoom;
		FlxG.save.data.hudSize = hudSize;
		FlxG.save.data.shadersActive = shadersActive;
		FlxG.save.data.showStatus = showStatus;
		FlxG.save.data.characterTrail = characterTrail;
		FlxG.save.data.noReset = noReset;
		FlxG.save.data.showMsText = showMsText;
		FlxG.save.data.holdNoteVisibility = holdNoteVisibility;
		FlxG.save.data.healthBarAlpha = healthBarAlpha;
		FlxG.save.data.comboOffset = comboOffset;
		FlxG.save.data.achievementsMap = Achievements.achievementsMap;
		FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
		FlxG.save.data.autosaveInterval = autosaveInterval;
		FlxG.save.data.autosavecharts = autosavecharts;
		FlxG.save.data.themedmainmenubg = themedmainmenubg;
		FlxG.save.data.autotitleskip = autotitleskip;
		FlxG.save.data.iconbops = iconbops;
		FlxG.save.data.tntrules = tntrules;
		FlxG.save.data.nitrorules = nitrorules;
		FlxG.save.data.trialrules = trialrules;

		FlxG.save.data.ratingOffset = ratingOffset;
		FlxG.save.data.showcaseMode = showcaseMode;
		FlxG.save.data.removePerfects = removePerfects;
		FlxG.save.data.perfectWindow = perfectWindow;
		FlxG.save.data.sickWindow = sickWindow;
		FlxG.save.data.goodWindow = goodWindow;
		FlxG.save.data.badWindow = badWindow;
		FlxG.save.data.safeFrames = safeFrames;
		FlxG.save.data.gameplaySettings = gameplaySettings;
		FlxG.save.data.controllerMode = controllerMode;
		FlxG.save.data.hitsoundVolume = hitsoundVolume;
		FlxG.save.data.underlaneVisibility = underlaneVisibility;
		FlxG.save.data.pauseMusic = pauseMusic;
		FlxG.save.data.noteSkinSettings = noteSkinSettings;
		FlxG.save.data.checkForUpdates = checkForUpdates;
		FlxG.save.data.convertEK = convertEK;
		FlxG.save.data.showKeybindsOnStart = showKeybindsOnStart;
	
		FlxG.save.flush();

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'bioxcis_dono'); //Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = keyBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs() {
		if(FlxG.save.data.downScroll != null) {
			downScroll = FlxG.save.data.downScroll;
		}
		if(FlxG.save.data.middleScroll != null) {
			middleScroll = FlxG.save.data.middleScroll;
		}
		if(FlxG.save.data.showFPS != null) {
			showFPS = FlxG.save.data.showFPS;
			if(Main.fpsVar != null) {
				Main.fpsVar.visible = showFPS;
			}
		}
		if(FlxG.save.data.flashing != null) {
			flashing = FlxG.save.data.flashing;
		}
		if(FlxG.save.data.holdNoteVisibility != null) {
			holdNoteVisibility = FlxG.save.data.holdNoteVisibility;
		}
		if(FlxG.save.data.globalAntialiasing != null) {
			globalAntialiasing = FlxG.save.data.globalAntialiasing;
		}
		if(FlxG.save.data.colorblindMode != null) {
			colorblindMode = FlxG.save.data.colorblindMode;
		}
		if(FlxG.save.data.opponentStrums != null) {
			opponentStrums = FlxG.save.data.opponentStrums;
		}
		if(FlxG.save.data.noteSplashes != null) {
			noteSplashes = FlxG.save.data.noteSplashes;
		}
		if(FlxG.save.data.lowQuality != null) {
			lowQuality = FlxG.save.data.lowQuality;
		}
		if(FlxG.save.data.characterTrail != null) {
			characterTrail = FlxG.save.data.characterTrail;
		}
		if(FlxG.save.data.framerate != null) {
			framerate = FlxG.save.data.framerate;
			if(framerate > FlxG.drawFramerate) {
				FlxG.updateFramerate = framerate;
				FlxG.drawFramerate = framerate;
			} else {
				FlxG.drawFramerate = framerate;
				FlxG.updateFramerate = framerate;
			}
		}
		if(FlxG.save.data.iconbops != null) {
			iconbops = FlxG.save.data.iconbops;
		}
		if(FlxG.save.data.autosaveInterval != null) {
			autosaveInterval = FlxG.save.data.autosaveInterval;
		}
		if(FlxG.save.data.autosavecharts != null) {
			autosavecharts = FlxG.save.data.autosavecharts;
		}
		if(FlxG.save.data.themedmainmenubg != null) {
			themedmainmenubg = FlxG.save.data.themedmainmenubg;
		}
		if(FlxG.save.data.autotitleskip != null) {
			autotitleskip = FlxG.save.data.autotitleskip;
		}
		/*if(FlxG.save.data.cursing != null) {
			cursing = FlxG.save.data.cursing;
		}
		if(FlxG.save.data.violence != null) {
			violence = FlxG.save.data.violence;
		}*/
		if(FlxG.save.data.flashWarning != null) {
			flashWarning = FlxG.save.data.flashWarning;
		}
		if(FlxG.save.data.camZooms != null) {
			camZooms = FlxG.save.data.camZooms;
		}
		if(FlxG.save.data.hideHud != null) {
			hideHud = FlxG.save.data.hideHud;
		}
		if(FlxG.save.data.hideWatermark != null) {
			hideWatermark = FlxG.save.data.hideWatermark;
		}
		if(FlxG.save.data.hideWatermark != null) {
			hideScoreText = FlxG.save.data.hideScoreText;
		}
		if(FlxG.save.data.noteOffset != null) {
			noteOffset = FlxG.save.data.noteOffset;
		}
		if(FlxG.save.data.removePerfects != null) {
			removePerfects = FlxG.save.data.removePerfects;
		}
		if(FlxG.save.data.showcaseMode != null) {
			showcaseMode = FlxG.save.data.showcaseMode;
		}
		if(FlxG.save.data.arrowHSV != null) {
			arrowHSV = FlxG.save.data.arrowHSV;
		}
		if(FlxG.save.data.ghostTapping != null) {
			ghostTapping = FlxG.save.data.ghostTapping;
		}
		if(FlxG.save.data.timeBarType != null) {
			timeBarType = FlxG.save.data.timeBarType;
		}
		if(FlxG.save.data.scoreZoom != null) {
			scoreZoom = FlxG.save.data.scoreZoom;
		}
		if(FlxG.save.data.hudSize != null) {
			hudSize = FlxG.save.data.hudSize;
		}
		if(FlxG.save.data.shadersActive != null) {
			shadersActive = FlxG.save.data.shadersActive;
		}
		if(FlxG.save.data.showStatus != null) {
			showStatus = FlxG.save.data.showStatus;
		}
		if(FlxG.save.data.noReset != null) {
			noReset = FlxG.save.data.noReset;
		}
		if(FlxG.save.data.showMsText != null) {
			showMsText = FlxG.save.data.showMsText;
		}
		if(FlxG.save.data.healthBarAlpha != null) {
			healthBarAlpha = FlxG.save.data.healthBarAlpha;
		}
		if(FlxG.save.data.comboOffset != null) {
			comboOffset = FlxG.save.data.comboOffset;
		}
		if(FlxG.save.data.tntrules != null) {
			tntrules = FlxG.save.data.tntrules;
		}
		if(FlxG.save.data.nitrorules != null) {
			nitrorules = FlxG.save.data.nitrorules;
		}
		if(FlxG.save.data.trialrules != null) {
			trialrules = FlxG.save.data.trialrules;
		}
		
		if(FlxG.save.data.ratingOffset != null) {
			ratingOffset = FlxG.save.data.ratingOffset;
		}
		if(FlxG.save.data.perfectWindow != null) {
			perfectWindow = FlxG.save.data.perfectWindow;
		}
		if(FlxG.save.data.sickWindow != null) {
			sickWindow = FlxG.save.data.sickWindow;
		}
		if(FlxG.save.data.goodWindow != null) {
			goodWindow = FlxG.save.data.goodWindow;
		}
		if(FlxG.save.data.badWindow != null) {
			badWindow = FlxG.save.data.badWindow;
		}
		if(FlxG.save.data.safeFrames != null) {
			safeFrames = FlxG.save.data.safeFrames;
		}
		if(FlxG.save.data.controllerMode != null) {
			controllerMode = FlxG.save.data.controllerMode;
		}
		if(FlxG.save.data.hitsoundVolume != null) {
			hitsoundVolume = FlxG.save.data.hitsoundVolume;
		}
		if(FlxG.save.data.cameramoveonnotes != null) {
			cameramoveonnotes = FlxG.save.data.cameramoveonnotes;
		}
		if (FlxG.save.data.convertEK != null)
		{
			convertEK = FlxG.save.data.convertEK;
		}
		if (FlxG.save.data.showKeybindsOnStart != null)
		{
			showKeybindsOnStart = FlxG.save.data.showKeybindsOnStart;
		}
		if(FlxG.save.data.underlaneVisibility != null) {
			underlaneVisibility = FlxG.save.data.underlaneVisibility;
		}
		if(FlxG.save.data.OpponentUnderlaneVisibility != null) {
			opponentUnderlaneVisibility = FlxG.save.data.OpponentUnderlaneVisibility;
		}
		if(FlxG.save.data.pauseMusic != null) {
			pauseMusic = FlxG.save.data.pauseMusic;
		}
		if(FlxG.save.data.pauseMusic != null) {
			noteSkinSettings = FlxG.save.data.noteSkinSettings;
		}
		if(FlxG.save.data.gameplaySettings != null)
		{
			var savedMap:Map<String, Dynamic> = FlxG.save.data.gameplaySettings;
			for (name => value in savedMap)
			{
				gameplaySettings.set(name, value);
			}
		}
		
		// flixel automatically saves your volume!
		if(FlxG.save.data.volume != null)
		{
			FlxG.sound.volume = FlxG.save.data.volume;
		}
		if (FlxG.save.data.mute != null)
		{
			FlxG.sound.muted = FlxG.save.data.mute;
		}
		if (FlxG.save.data.checkForUpdates != null)
		{
			checkForUpdates = FlxG.save.data.checkForUpdates;
		}

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'bioxcis_dono');
		if(save != null && save.data.customControls != null) {
			var loadedControls:Map<String, Array<FlxKey>> = save.data.customControls;
			for (control => keys in loadedControls) {
				keyBinds.set(control, keys);
			}
			reloadControls();
		}
	}

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic):Dynamic {
		return /*PlayState.isStoryMode ? defaultValue : */ (gameplaySettings.exists(name) ? gameplaySettings.get(name) : defaultValue);
	}

	public static function reloadControls() {
		PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);

		TitleState.muteKeys = copyKey(keyBinds.get('volume_mute'));
		TitleState.volumeDownKeys = copyKey(keyBinds.get('volume_down'));
		TitleState.volumeUpKeys = copyKey(keyBinds.get('volume_up'));
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
	}
	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey> {
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len) {
			if(copiedArray[i] == NONE) {
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
}
