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
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.FlxTrail;
import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.FlxSound;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxStringUtil;
import flixel.util.FlxCollision;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxSave;
import flixel.util.FlxAxes;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxG;

import openfl.filters.ColorMatrixFilter;
import openfl.display.ShaderParameter;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import openfl.display.BlendMode;
import openfl.utils.Assets;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.Lib;

import Type.ValueType;
import haxe.Json;

import animateatlas.AtlasFrameMaker;

import DialogueBoxPsych;
import Achievements;
import Controls;
import Shaders;

#if LUA_ALLOWED
import llua.Convert;
import llua.State;
import llua.LuaL;
import llua.Lua;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if hscript
import hscript.Interp;
import hscript.Parser;
#end

#if desktop
import Discord;
#end

using StringTools;

typedef LuaTweenOptions = {
	type:FlxTweenType,
	startDelay:Float,
	onUpdate:Null<String>,
	onStart:Null<String>,
	onComplete:Null<String>,
	loopDelay:Float,
	ease:EaseFunction
}

class FunkinLua {
	public static var Function_Stop:Dynamic = 1;
	public static var Function_Continue:Dynamic = 0;
	public static var Function_StopLua:Dynamic = 2;
	//public var errorHandler:String->Void;
	#if LUA_ALLOWED
	public var lua:State = null;
	#end
	public var camTarget:FlxCamera;
	public var scriptName:String = '';
	public var closed:Bool = false;
	#if hscript
	public static var haxeInterp:Interp = null;
	#end
	
	public function new(script:String) {
		#if LUA_ALLOWED
		lua = LuaL.newstate();
		LuaL.openlibs(lua);
		Lua.init_callbacks(lua);

		//trace('Lua version: ' + Lua.version());
		//trace("LuaJIT version: " + Lua.versionJIT());

		//LuaL.dostring(lua, CLENSE);

		try{
			var result:Dynamic = LuaL.dofile(lua, script);
			var resultStr:String = Lua.tostring(lua, result);
			if(resultStr != null && result != 0) {
				trace('Error on lua script! ' + resultStr);
				#if windows
				lime.app.Application.current.window.alert(resultStr, 'Error on lua script!');
				#else
				luaTrace('Error loading lua script: "$script"\n' + resultStr, true, false, FlxColor.RED);
				#end
				lua = null;
				return;
			}
		}catch(e:Dynamic){
			trace(e);
			return;
		}
		scriptName = script;
		trace('lua file loaded succesfully:' + script);

		// Lua
		set('Function_StopLua', Function_StopLua);
		set('Function_Stop', Function_Stop);
		set('Function_Continue', Function_Continue);
		set('luaDebugMode', false);
		set('luaDeprecatedWarnings', true);
		set('inChartEditor', false);

		// Song
		set('curBpm', Conductor.bpm);
		set('songBpm', PlayState.SONG.bpm);
		set('scrollSpeed', PlayState.SONG.speed);
		set('crochet', Conductor.crochet);
		set('stepCrochet', Conductor.stepCrochet);
		set('songLength', FlxG.sound.music.length);
		set('songName', PlayState.SONG.song);
		set('songPath', Paths.formatToSongPath(PlayState.SONG.song));
		set('startedCountdown', false);
		set('mania', PlayState.mania);
		set('gameMode', PlayState.gameMode);
	
		// Week
		set('isStoryMode', PlayState.isStoryMode);
		set('difficulty', PlayState.storyDifficulty);
		set('difficultyName', CoolUtil.difficulties[PlayState.storyDifficulty]);
		set('weekRaw', PlayState.storyWeek);
		set('week', WeekData.weeksList[PlayState.storyWeek]);
		set('seenCutscene', PlayState.seenCutscene);

		// Camera
		set('cameraX', 0);
		set('cameraY', 0);
		set('defaultCamZoom', PlayState.instance.defaultCamZoom);
		set('defaultHudZoom', PlayState.instance.defaultHudZoom);
		set('defaultOtherZoom', PlayState.instance.defaultOthZoom);

		// Screen stuff
		set('screenWidth', FlxG.width);
		set('screenHeight', FlxG.height);

		// PlayState
		set('deaths', PlayState.deathCounter);

		set('showCombo', false);
		set('showComboNumber', true);
		set('showRating', true);

		set('curBeat', 0);
		set('curStep', 0);
		set('curDecBeat', 0);
		set('curDecStep', 0);

		set('score', 0);
		set('misses', 0);
		set('hits', 0);
		set('rating', 0);
		set('ratingName', '');
		set('ratingFC', '');

		set('inGameOver', false);
		set('deathFinish', false);

		set('mustHitSection', false);
		set('altAnim', false);
		set('gfSection', false);

		// Health
		set('healthGainMult', PlayState.instance.healthGain);
		set('healthLossMult', PlayState.instance.healthLoss);
		set('instakillOnMiss', PlayState.instance.instakillOnMiss);

		//for (i in 0...4) {
		for (i in 0...PlayState.mania) {
			set('defaultPlayerStrumX' + i, 0);
			set('defaultPlayerStrumY' + i, 0);
			set('defaultOpponentStrumX' + i, 0);
			set('defaultOpponentStrumY' + i, 0);
		}

		// Character Positions
		set('defaultBoyfriendX', PlayState.instance.BF_X);
		set('defaultBoyfriendY', PlayState.instance.BF_Y);
		set('defaultOpponentX', PlayState.instance.DAD_X);
		set('defaultOpponentY', PlayState.instance.DAD_Y);
		set('defaultGirlfriendX', PlayState.instance.GF_X);
		set('defaultGirlfriendY', PlayState.instance.GF_Y);

		// Character
		set('boyfriendName', PlayState.SONG.player1);
		set('dadName', PlayState.SONG.player2);
		set('gfName', PlayState.SONG.gfVersion);

		// Some settings
		set('downscroll', ClientPrefs.downScroll);
		set('middlescroll', ClientPrefs.middleScroll);
		set('framerate', ClientPrefs.framerate);
		set('ghostTapping', ClientPrefs.ghostTapping);
		set('hideHud', ClientPrefs.hideHud);
		set('hideWatermark', ClientPrefs.hideWatermark);
		set('hideScoreText', ClientPrefs.hideScoreText);
		set('iconbops', ClientPrefs.iconbops);
		set('colorblindMode', ClientPrefs.colorblindMode);
		set('underlaneVisibility', ClientPrefs.underlaneVisibility);
		set('holdNoteVisibility', ClientPrefs.holdNoteVisibility);
		set('dadUnderlaneVisibility', ClientPrefs.opponentUnderlaneVisibility);
		set('pauseMusic', ClientPrefs.pauseMusic);
		set('cameraMovement', ClientPrefs.cameramoveonnotes);
		set('convertEK', ClientPrefs.convertEK);
		set('showKeybindsOnStart', ClientPrefs.showKeybindsOnStart);
		set('timeBarType', ClientPrefs.timeBarType);
		set('scoreZoom', ClientPrefs.scoreZoom);
		set('showStatus', ClientPrefs.showStatus);
		set('cameraZoomOnBeat', ClientPrefs.camZooms);
		set('flashingLights', ClientPrefs.flashing);
		set('noteOffset', ClientPrefs.noteOffset);
		set('healthBarAlpha', ClientPrefs.healthBarAlpha);
		set('hitsoundVolume', ClientPrefs.hitsoundVolume);
		set('noResetButton', ClientPrefs.noReset);
		set('lowQuality', ClientPrefs.lowQuality);
		set('comboOffset', ClientPrefs.comboOffset);
		set('comboOffsetMultiplayer', ClientPrefs.comboOffsetMultiplayer);
		set('ratingOffset', ClientPrefs.ratingOffset);
		set('noteSplash', ClientPrefs.noteSplashes);
		set('isShowcaseMode', ClientPrefs.showcaseMode);
		set('hudSize', ClientPrefs.hudSize);
		set('shadersActive', ClientPrefs.shadersActive);

		set('scriptName', scriptName);

		// Ratings
		set('isBad', ClientPrefs.badWindow);
		set('isGood', ClientPrefs.goodWindow);
		set('isSick', ClientPrefs.sickWindow);
		set('isPerfect', ClientPrefs.perfectWindow);

		set('version', MainMenuState.wumpaEngineVersion.trim());
		#if windows
		set('buildTarget', 'windows');
		#elseif linux
		set('buildTarget', 'linux');
		#elseif mac
		set('buildTarget', 'mac');
		#elseif html5
		set('buildTarget', 'browser');
		#elseif android
		set('buildTarget', 'android');
		#else
		set('buildTarget', 'unknown');
		#end


		// Scripts Config

		Lua_helper.add_callback(lua, "getRunningScripts", function(){
			var runningScripts:Array<String> = [];
			for (idx in 0...PlayState.instance.luaArray.length)
				runningScripts.push(PlayState.instance.luaArray[idx].scriptName);
			return runningScripts;
		});

		Lua_helper.add_callback(lua, "setOnLuas", function(variable:String, arg:Dynamic, ?ignoreSelf:Bool = false, ?exclusions:Array<String> = null) {
			if(exclusions == null) exclusions = [];
			if(ignoreSelf && !exclusions.contains(scriptName)) exclusions.push(scriptName);
			PlayState.instance.setOnLuas(variable, arg, exclusions);
		});
		Lua_helper.add_callback(lua, "setOnScripts", function(variable:String, arg:Dynamic, ?ignoreSelf:Bool = false, ?exclusions:Array<String> = null) {
			if(exclusions == null) exclusions = [];
			if(ignoreSelf && !exclusions.contains(scriptName)) exclusions.push(scriptName);
			PlayState.instance.setOnScripts(variable, arg, exclusions);
		});

		Lua_helper.add_callback(lua, "callOnLuas", function(?funcName:String, ?args:Array<Dynamic> = null, ignoreStops = false, ignoreSelf = true, ?exclusions:Array<String> = null){
			// if(excludeScripts == null) excludeScripts = [];
			// if(ignoreSelf && !excludeScripts.contains(scriptName)) excludeScripts.push(scriptName);
			// PlayState.instance.callOnLuas(funcName, args, ignoreStops, excludeScripts, excludeValues);
			// return true;
			if(funcName == null) {
				#if (linc_luajit >= "0.0.6")
				LuaL.error(lua, "bad argument #1 to 'callOnLuas' (string expected, got nil)");
				#end
				return;
			}
			if(args == null) args = [];
			if(exclusions == null) exclusions = [];
			Lua.getglobal(lua, 'scriptName');
			var daScriptName = Lua.tostring(lua, -1);
			Lua.pop(lua, 1);
			if(ignoreSelf && !exclusions.contains(daScriptName)) exclusions.push(daScriptName);
			PlayState.instance.callOnLuas(funcName, args, ignoreStops, exclusions);
		});
		Lua_helper.add_callback(lua, "callOnScripts", function(?funcName:String, ?args:Array<Dynamic> = null, ignoreStops = false, ignoreSelf = true, ?exclusions:Array<String> = null) {
			// if(excludeScripts == null) excludeScripts = [];
			// if(ignoreSelf && !excludeScripts.contains(scriptName)) excludeScripts.push(scriptName);
			// PlayState.instance.callOnScripts(funcName, args, ignoreStops, excludeScripts, excludeValues);
			// return true;
			if(funcName == null) {
				#if (linc_luajit >= "0.0.6")
				LuaL.error(lua, "bad argument #1 to 'callOnScripts' (string expected, got nil)");
				#end
				return;
			}
			if(args == null) args = [];
			if(exclusions == null) exclusions = [];
			Lua.getglobal(lua, 'scriptName');
			var daScriptName = Lua.tostring(lua, -1);
			Lua.pop(lua, 1);
			if(ignoreSelf && !exclusions.contains(daScriptName)) exclusions.push(daScriptName);
			PlayState.instance.callOnScripts(funcName, args, ignoreStops, exclusions);
		});

		Lua_helper.add_callback(lua, "callScript", function(?luaFile:String, ?funcName:String, ?args:Array<Dynamic>){
			if(luaFile == null) {
				#if (linc_luajit >= "0.0.6")
				LuaL.error(lua, "bad argument #1 to 'callScript' (string expected, got nil)");
				#end
				return;
			}
			if(funcName == null) {
				#if (linc_luajit >= "0.0.6")
				LuaL.error(lua, "bad argument #2 to 'callScript' (string expected, got nil)");
				#end
				return;
			}
			if(args == null) args = [];
			var cervix = luaFile + ".lua";
			if(luaFile.endsWith(".lua")) cervix = luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix))) {
				cervix = Paths.modFolders(cervix);
				doPush = true;
			} else if(FileSystem.exists(cervix)) {
				doPush = true;
			} else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix)) {
					doPush = true;
				}
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix)) {
				doPush = true;
			}
			#end
			if(doPush) {
				for (luaInstance in PlayState.instance.luaArray) {
					if(luaInstance.scriptName == cervix) {
						luaInstance.call(funcName, args);
						return;
					}
				}
			}
			Lua.pushnil(lua);
		});
		Lua_helper.add_callback(lua, "getVar", function(varName:String) {
			return PlayState.instance.variables.get(varName);
		});
		Lua_helper.add_callback(lua, "setVar", function(varName:String, value:Dynamic) {
			PlayState.instance.variables.set(varName, value);
		});
		Lua_helper.add_callback(lua, "getGlobalFromScript", function(?luaFile:String, ?global:String){ // returns the global from a script
			if(luaFile==null){
				#if (linc_luajit >= "0.0.6")
				LuaL.error(lua, "bad argument #1 to 'getGlobalFromScript' (string expected, got nil)");
				#end
				return;
			}
			if(global==null){
				#if (linc_luajit >= "0.0.6")
				LuaL.error(lua, "bad argument #2 to 'getGlobalFromScript' (string expected, got nil)");
				#end
				return;
			}
			var cervix = luaFile + ".lua";
			if(luaFile.endsWith(".lua"))cervix=luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if(FileSystem.exists(cervix))
			{
				doPush = true;
			}
			else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix)) {
					doPush = true;
				}
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix)) {
				doPush = true;
			}
			#end
			if(doPush)
			{
				for (luaInstance in PlayState.instance.luaArray)
				{
					if(luaInstance.scriptName == cervix)
					{
						Lua.getglobal(luaInstance.lua, global);
						if(Lua.isnumber(luaInstance.lua,-1)){
							Lua.pushnumber(lua, Lua.tonumber(luaInstance.lua, -1));
						}else if(Lua.isstring(luaInstance.lua,-1)){
							Lua.pushstring(lua, Lua.tostring(luaInstance.lua, -1));
						}else if(Lua.isboolean(luaInstance.lua,-1)){
							Lua.pushboolean(lua, Lua.toboolean(luaInstance.lua, -1));
						}else{
							Lua.pushnil(lua);
						}
						// TODO: table

						Lua.pop(luaInstance.lua,1); // remove the global

						return;
					}

				}
			}
			Lua.pushnil(lua);
		});
		Lua_helper.add_callback(lua, "setGlobalFromScript", function(luaFile:String, global:String, val:Dynamic){ // returns the global from a script
			var cervix = luaFile + ".lua";
			if(luaFile.endsWith(".lua"))cervix=luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if(FileSystem.exists(cervix))
			{
				doPush = true;
			}
			else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix)) {
					doPush = true;
				}
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix)) {
				doPush = true;
			}
			#end
			if(doPush)
			{
				for (luaInstance in PlayState.instance.luaArray)
				{
					if(luaInstance.scriptName == cervix)
					{
						luaInstance.set(global, val);
					}

				}
			}
			Lua.pushnil(lua);
		});
		/*Lua_helper.add_callback(lua, "getGlobals", function(luaFile:String){ // returns a copy of the specified file's globals
			var cervix = luaFile + ".lua";
			if(luaFile.endsWith(".lua"))cervix=luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if(FileSystem.exists(cervix))
			{
				doPush = true;
			}
			else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix)) {
					doPush = true;
				}
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix)) {
				doPush = true;
			}
			#end
			if(doPush)
			{
				for (luaInstance in PlayState.instance.luaArray)
				{
					if(luaInstance.scriptName == cervix)
					{
						Lua.newtable(lua);
						var tableIdx = Lua.gettop(lua);

						Lua.pushvalue(luaInstance.lua, Lua.LUA_GLOBALSINDEX);
						Lua.pushnil(luaInstance.lua);
						while(Lua.next(luaInstance.lua, -2) != 0) {
							// key = -2
							// value = -1

							var pop:Int = 0;

							// Manual conversion
							// first we convert the key
							if(Lua.isnumber(luaInstance.lua,-2)){
								Lua.pushnumber(lua, Lua.tonumber(luaInstance.lua, -2));
								pop++;
							}else if(Lua.isstring(luaInstance.lua,-2)){
								Lua.pushstring(lua, Lua.tostring(luaInstance.lua, -2));
								pop++;
							}else if(Lua.isboolean(luaInstance.lua,-2)){
								Lua.pushboolean(lua, Lua.toboolean(luaInstance.lua, -2));
								pop++;
							}
							// TODO: table


							// then the value
							if(Lua.isnumber(luaInstance.lua,-1)){
								Lua.pushnumber(lua, Lua.tonumber(luaInstance.lua, -1));
								pop++;
							}else if(Lua.isstring(luaInstance.lua,-1)){
								Lua.pushstring(lua, Lua.tostring(luaInstance.lua, -1));
								pop++;
							}else if(Lua.isboolean(luaInstance.lua,-1)){
								Lua.pushboolean(lua, Lua.toboolean(luaInstance.lua, -1));
								pop++;
							}
							// TODO: table

							if(pop==2)Lua.rawset(lua, tableIdx); // then set it
							Lua.pop(luaInstance.lua, 1); // for the loop
						}
						Lua.pop(luaInstance.lua,1); // end the loop entirely
						Lua.pushvalue(lua, tableIdx); // push the table onto the stack so it gets returned

						return;
					}

				}
			}
			Lua.pushnil(lua);
		});*/
		Lua_helper.add_callback(lua, "isRunning", function(luaFile:String){
			var cervix = luaFile + ".lua";
			if(luaFile.endsWith(".lua"))cervix=luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if(FileSystem.exists(cervix))
			{
				doPush = true;
			}
			else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix)) {
					doPush = true;
				}
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix)) {
				doPush = true;
			}
			#end

			if(doPush)
			{
				for (luaInstance in PlayState.instance.luaArray)
				{
					if(luaInstance.scriptName == cervix)
						return true;

				}
			}
			return false;
		});
		Lua_helper.add_callback(lua, "addLuaScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false) { //would be dope asf.
			var cervix = luaFile + ".lua";
			if(luaFile.endsWith(".lua"))cervix=luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if(FileSystem.exists(cervix))
			{
				doPush = true;
			}
			else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix)) {
					doPush = true;
				}
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix)) {
				doPush = true;
			}
			#end

			if(doPush)
			{
				if(!ignoreAlreadyRunning)
				{
					for (luaInstance in PlayState.instance.luaArray)
					{
						if(luaInstance.scriptName == cervix)
						{
							luaTrace('The script "' + cervix + '" is already running!');
							return;
						}
					}
				}
				PlayState.instance.luaArray.push(new FunkinLua(cervix));
				return;
			}
			luaTrace("Script doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "removeLuaScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false) { //would be dope asf.
			var cervix = luaFile + ".lua";
			if(luaFile.endsWith(".lua"))cervix=luaFile;
			var doPush = false;
			#if MODS_ALLOWED
			if(FileSystem.exists(Paths.modFolders(cervix)))
			{
				cervix = Paths.modFolders(cervix);
				doPush = true;
			}
			else if(FileSystem.exists(cervix))
			{
				doPush = true;
			}
			else {
				cervix = Paths.getPreloadPath(cervix);
				if(FileSystem.exists(cervix)) {
					doPush = true;
				}
			}
			#else
			cervix = Paths.getPreloadPath(cervix);
			if(Assets.exists(cervix)) {
				doPush = true;
			}
			#end

			if(doPush)
			{
				if(!ignoreAlreadyRunning)
				{
					for (luaInstance in PlayState.instance.luaArray)
					{
						if(luaInstance.scriptName == cervix)
						{
							//luaTrace('The script "' + cervix + '" is already running!');

								PlayState.instance.luaArray.remove(luaInstance);
							return;
						}
					}
				}
				return;
			}
			luaTrace("Script doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "addHaxeLibrary", function(libName:String, ?libPackage:String = '') {
			#if hscript
			initHaxeInterp();

			try {
				var str:String = '';
				if(libPackage.length > 0)
					str = libPackage + '.';

				haxeInterp.variables.set(libName, Type.resolveClass(str + libName));
			}
			catch (e:Dynamic) {
				luaTrace(scriptName + ":" + lastCalledFunction + " - " + e, false, false, FlxColor.RED);
			}
			#end
		});
		Lua_helper.add_callback(lua, "runHaxeCode", function(codeToRun:String) {
			#if hscript
			initHaxeInterp();

			try {
				var myFunction:Dynamic = haxeInterp.expr(new Parser().parseString(codeToRun));
				myFunction();
			}
			catch (e:Dynamic) {
				switch(e)
				{
					case 'Null Function Pointer', 'SReturn':
						//nothing
					default:
						luaTrace(scriptName + ":" + lastCalledFunction + " - " + e, false, false, FlxColor.RED);
				}
			}
			#end
		});


		// Game Load

		Lua_helper.add_callback(lua, "loadSong", function(?name:String = null, ?difficultyNum:Int = -1) {
			if(name == null || name.length < 1)
				name = PlayState.SONG.song;
			if (difficultyNum == -1)
				difficultyNum = PlayState.storyDifficulty;

			var loadin = Highscore.formatSong(name, difficultyNum);
			PlayState.SONG = Song.loadFromJson(loadin, name);
			PlayState.storyDifficulty = difficultyNum;
			PlayState.instance.persistentUpdate = false;
			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.pause();
			FlxG.sound.music.volume = 0;
			if(PlayState.instance.vocals != null)
			{
				PlayState.instance.vocals.pause();
				PlayState.instance.vocals.volume = 0;
			}
		});
		Lua_helper.add_callback(lua, "loadGraphic", function(variable:String, image:String, ?gridX:Int, ?gridY:Int) {
			var split:Array<String> = variable.split('.');
			var spr:FlxSprite = getObjectDirectly(split[0],true);
			var gX = gridX==null?0:gridX;
			var gY = gridY==null?0:gridY;
			var animated = gX!=0 || gY!=0;

			if(split.length > 1) {
				spr = getVarInArray(getPropertyLoop(split), split[split.length-1]);
			}
			if(spr != null && image != null && image.length > 0)
			{
				spr.loadGraphic(Paths.image(image), animated, gX, gY);
			}
		});
		Lua_helper.add_callback(lua, "loadFrames", function(variable:String, image:String, spriteType:String = "sparrow") {
			var split:Array<String> = variable.split('.');
			var spr:FlxSprite = getObjectDirectly(split[0],true);
			if(split.length > 1) {
				spr = getVarInArray(getPropertyLoop(split), split[split.length-1]);
			}

			if(spr != null && image != null && image.length > 0)
			{
				loadFrames(spr, image, spriteType);
			}
		});


		// Reflection Functions

		Lua_helper.add_callback(lua, "getProperty", function(variable:String) {
			@:privateAccess
			var varValue:Array<String> = variable.split('.');
			if(varValue.length > 1) {
				return getVarInArray(getPropertyLoop(varValue,true,true,true,true), varValue[varValue.length-1]);
			}
			return getVarInArray(getInstance(), variable);
		});
		Lua_helper.add_callback(lua, "setProperty", function(variable:String, value:Dynamic) {
			@:privateAccess
			var varValue:Array<String> = variable.split('.');
			if(varValue.length > 1) {
				setVarInArray(getPropertyLoop(varValue,true,true,true,true), varValue[varValue.length-1], value);
				return true;
			}
			setVarInArray(getInstance(), variable, value);
			return true;
		});
		Lua_helper.add_callback(lua, "getPropertyFromClass", function(classVar:String, variable:String) {
			@:privateAccess
			var varValues:Array<String> = variable.split('.');
			if(varValues.length > 1) {
				var classGroup:Dynamic = getVarInArray(Type.resolveClass(classVar), varValues[0]);
				for (i in 1...varValues.length-1) {
					classGroup = getVarInArray(classGroup, varValues[i]);
				}
				return getVarInArray(classGroup, varValues[varValues.length-1]);
			}
			return getVarInArray(Type.resolveClass(classVar), variable);
		});
		Lua_helper.add_callback(lua, "setPropertyFromClass", function(classVar:String, variable:String, value:Dynamic) {
			@:privateAccess
			var varValues:Array<String> = variable.split('.');
			if(varValues.length > 1) {
				var classGroup:Dynamic = getVarInArray(Type.resolveClass(classVar), varValues[0]);
				for (i in 1...varValues.length-1) {
					classGroup = getVarInArray(classGroup, varValues[i]);
				}
				setVarInArray(classGroup, varValues[varValues.length-1], value);
				return true;
			}
			setVarInArray(Type.resolveClass(classVar), variable, value);
			return true;
		});
		Lua_helper.add_callback(lua, "getPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic) {
			@:privateAccess
			var varValues:Array<String> = obj.split('.');
			var realObject:Dynamic = Reflect.getProperty(getInstance(), obj);
			if(varValues.length>1)
				realObject = getPropertyLoop(varValues, true, false, true, true);


			if(Std.isOfType(realObject, FlxTypedGroup))
				return getGroupStuff(realObject.members[index], variable);


			var leArray:Dynamic = realObject[index];
			if(leArray != null) {
				if(Type.typeof(variable) == ValueType.TInt) {
					return leArray[variable];
				}
				return getGroupStuff(leArray, variable);
			}
			luaTrace("Object #" + index + " from group: " + obj + " doesn't exist!", false, false, FlxColor.RED);
			return null;
		});
		@:privateAccess
		Lua_helper.add_callback(lua, "setPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic, value:Dynamic) {
			var varValues:Array<String> = obj.split('.');
			var realObject:Dynamic = Reflect.getProperty(getInstance(), obj);
			if(varValues.length>1)
				realObject = getPropertyLoop(varValues, true, false, true, true);

			if(Std.isOfType(realObject, FlxTypedGroup)) {
				setGroupStuff(realObject.members[index], variable, value);
				return;
			}

			var leArray:Dynamic = realObject[index];
			if(leArray != null) {
				if(Type.typeof(variable) == ValueType.TInt) {
					leArray[variable] = value;
					return;
				}
				setGroupStuff(leArray, variable, value);
			}
		});
		Lua_helper.add_callback(lua, "removeFromGroup", function(obj:String, index:Int, dontDestroy:Bool = false) {
			if(Std.isOfType(Reflect.getProperty(getInstance(), obj), FlxTypedGroup)) {
				var toNull = Reflect.getProperty(getInstance(), obj).members[index];
				if(!dontDestroy)
					toNull.kill();
				Reflect.getProperty(getInstance(), obj).remove(toNull, true);
				if(!dontDestroy)
					toNull.destroy();
				return;
			}
			Reflect.getProperty(getInstance(), obj).remove(Reflect.getProperty(getInstance(), obj)[index]);
		});
		Lua_helper.add_callback(lua, "callMethod", function(funcToRun:String, ?args:Array<Dynamic> = null) {
			return callMethodFromObject(PlayState.instance, funcToRun, args);
			
		});
		Lua_helper.add_callback(lua, "callMethodFromClass", function(className:String, funcToRun:String, ?args:Array<Dynamic> = null) {
			return callMethodFromObject(Type.resolveClass(className), funcToRun, args);
		});
		Lua_helper.add_callback(lua, "createInstance", function(variableToSave:String, className:String, ?args:Array<Dynamic> = null) {
			variableToSave = variableToSave.trim().replace('.', '');
			if(!PlayState.instance.variables.exists(variableToSave))
			{
				if(args == null) args = [];
				var myType:Dynamic = Type.resolveClass(className);
		
				if(myType == null)
				{
					luaTrace('createInstance: Variable $variableToSave is already being used and cannot be replaced!', false, false, FlxColor.RED);
					return false;
				}

				var obj:Dynamic = Type.createInstance(myType, args);
				if(obj != null)
					PlayState.instance.variables.set(variableToSave, obj);
				else
					luaTrace('createInstance: Failed to create $variableToSave, arguments are possibly wrong.', false, false, FlxColor.RED);

				return (obj != null);
			}
			else luaTrace('createInstance: Variable $variableToSave is already being used and cannot be replaced!', false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "addInstance", function(objectName:String, ?inFront:Bool = false) {
			if(PlayState.instance.variables.exists(objectName))
			{
				var obj:Dynamic = PlayState.instance.variables.get(objectName);
				if (inFront)
					getInstance().add(obj);
				else
				{
					if(!PlayState.instance.isDead)
						PlayState.instance.insert(PlayState.instance.members.indexOf(getLowestCharacterGroup()), obj);
					else
						GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), obj);
				}
			}
			else luaTrace('addInstance: Can\'t add what doesn\'t exist~ ($objectName)', false, false, FlxColor.RED);
		});
		/*Lua_helper.add_callback(lua, "getPropertyAdvanced", function(varsStr:String) {
			var variables:Array<String> = varsStr.replace(' ', '').split(',');
			var leClass:Class<Dynamic> = Type.resolveClass(variables[0]);
			if(variables.length > 2) {
				var curProp:Dynamic = Reflect.getProperty(leClass, variables[1]);
				if(variables.length > 3) {
					for (i in 2...variables.length-1) {
						curProp = Reflect.getProperty(curProp, variables[i]);
					}
				}
				return Reflect.getProperty(curProp, variables[variables.length-1]);
			} else if(variables.length == 2) {
				return Reflect.getProperty(leClass, variables[variables.length-1]);
			}
			return null;
		});
		Lua_helper.add_callback(lua, "setPropertyAdvanced", function(varsStr:String, value:Dynamic) {
			var variables:Array<String> = varsStr.replace(' ', '').split(',');
			var leClass:Class<Dynamic> = Type.resolveClass(variables[0]);
			if(variables.length > 2) {
				var curProp:Dynamic = Reflect.getProperty(leClass, variables[1]);
				if(variables.length > 3) {
					for (i in 2...variables.length-1) {
						curProp = Reflect.getProperty(curProp, variables[i]);
					}
				}
				return Reflect.setProperty(curProp, variables[variables.length-1], value);
			} else if(variables.length == 2) {
				return Reflect.setProperty(leClass, variables[variables.length-1], value);
			}
		});*/


		// Objects Layering

		Lua_helper.add_callback(lua, "getObjectOrder", function(obj:String) {
			var split:Array<String> = obj.split('.');
			var leObj:FlxBasic = getObjectDirectly(split[0], true, true, true);
			if(split.length > 1) {
				leObj = getVarInArray(getPropertyLoop(split,true,true,true,true), split[split.length-1]);
			}

			if(leObj != null)
			{
				return getInstance().members.indexOf(leObj);
			}
			luaTrace("Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
			return -1;
		});
		Lua_helper.add_callback(lua, "setObjectOrder", function(obj:String, position:Int) {
			var split:Array<String> = obj.split('.');
			var leObj:FlxBasic = getObjectDirectly(split[0], true, true, true);
			if(split.length > 1) {
				leObj = getVarInArray(getPropertyLoop(split,true,true,true,true), split[split.length-1]);
			}

			if(leObj != null) {
				getInstance().remove(leObj, true);
				getInstance().insert(position, leObj);
				return;
			}
			luaTrace("Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
		});


		// Precaching

		Lua_helper.add_callback(lua, "precacheImage", function(name:String) {
			Paths.returnGraphic(name);
		});
		Lua_helper.add_callback(lua, "precacheSound", function(name:String) {
			CoolUtil.precacheSound(name);
		});
		Lua_helper.add_callback(lua, "precacheMusic", function(name:String) {
			CoolUtil.precacheMusic(name);
		});
		Lua_helper.add_callback(lua, "addCharacterToList", function(name:String, type:String) {
			var charType:Int = 0;
			switch(type.toLowerCase()) {
				case 'dad': charType = 1;
				case 'gf' | 'girlfriend': charType = 2;
			}
			PlayState.instance.addCharacterToList(name, charType);
		});


		// PlayState Functions

		Lua_helper.add_callback(lua, "startCountdown", function() {
			PlayState.instance.startCountdown();
			return true;
		});
		Lua_helper.add_callback(lua, "makeNewCountdown", function(go:Bool = true, camOther:Bool = false, ?aliasing:Bool = true, introExtra:Array<String> = null) {
			PlayState.instance.initializeCountdown(go, camOther, aliasing, introExtra);
			return true;
		});
		Lua_helper.add_callback(lua, "makeRatingSprite", function(img:String = '', isP2:Bool = false, antialias:Bool = true) {
			PlayState.instance.makeRatingSprite(img, '', '', antialias, FlxG.width * 0.35, isP2);
			return true;
		});
		Lua_helper.add_callback(lua, "makeNumberSprites", function(number:Int = 0, img:String = null, isP2:Bool = false, antialias:Bool = true) {
			if(number > 9999) number = 9999;
			else if(number < 0) number = 0;
			var separatedScore:Array<Int> = [];
			if(!isP2 && PlayState.instance.combo >= 1000) separatedScore.push(Math.floor(number / 1000) % 10);
			if(isP2 && PlayState.instance.comboP2 >= 1000) separatedScore.push(Math.floor(number / 1000) % 10);
			separatedScore.push(Math.floor(number / 100) % 10);
			separatedScore.push(Math.floor(number / 10) % 10);
			separatedScore.push(number % 10);
			PlayState.instance.makeNumberSprites(separatedScore, img, '', '', antialias, FlxG.width * 0.35, isP2);
			return true;
		});
		Lua_helper.add_callback(lua, "makeComboSprite", function(img:String = '', isP2:Bool = false, antialias:Bool = true) {
			PlayState.instance.makeComboSprite(img, '', '', antialias, FlxG.width * 0.35, isP2);
			return true;
		});
		Lua_helper.add_callback(lua, "startStatusTween", function() {
			if(PlayState.instance.statusCancelStartTween)
				PlayState.instance.statusTweening();
			return true;
		});
		Lua_helper.add_callback(lua, "restartSong", function(?skipTransition:Bool = false) {
			PlayState.instance.persistentUpdate = false;
			PauseSubState.restartSong(skipTransition);
			return true;
		});
		Lua_helper.add_callback(lua, "endSong", function() {
			PlayState.instance.KillNotes();
			PlayState.instance.endSong();
			return true;
		});
		Lua_helper.add_callback(lua, "exitSong", function(?skipTransition:Bool = false) {
			if(skipTransition) {
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
			}

			PlayState.cancelMusicFadeTween();
			CustomFadeTransition.nextCamera = PlayState.instance.camOther;
			if(FlxTransitionableState.skipNextTransIn)
				CustomFadeTransition.nextCamera = null;

			if(PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.changedDifficulty = false;
			PlayState.chartingMode = false;
			PlayState.instance.transitioning = true;
			WeekData.loadTheFirstEnabledMod();
			return true;
		});
		Lua_helper.add_callback(lua, "setBotPlayText", function(value:String) {
			PlayState.instance.botplayTxt.text = value;
		});
		Lua_helper.add_callback(lua, "getSongPosition", function() {
			return Conductor.songPosition;
		});
		Lua_helper.add_callback(lua, "setScrollSpeed", function(toFast:Float, toTimed:Float) {
			if (PlayState.instance.songSpeedType == "constante") return;
			var newMultiplier:Float = PlayState.SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * toFast;
			if(toTimed <= 0) {
				PlayState.instance.songSpeed = newMultiplier;
				return;
			}
			PlayState.instance.songSpeedTween = FlxTween.tween(PlayState.instance, {songSpeed: toFast}, toTimed, {ease: FlxEase.linear, onComplete:
				function (twn:FlxTween)
				{
					PlayState.instance.songSpeedTween = null;
				}
			});
		});
		Lua_helper.add_callback(lua, "setHealthBarColors", function(leftHex:String, rightHex:String) {
			PlayState.instance.healthBar.createFilledBar(returnColor(leftHex), returnColor(rightHex));
			PlayState.instance.healthBar.updateBar();
		});
		Lua_helper.add_callback(lua, "setHealthDamageColors", function(colorP1:String, colorP2:String) {
			if(colorP1 != '') PlayState.instance.healthColorP1 = returnColor(colorP1);
			if(colorP2 != '') PlayState.instance.healthColorP2 = returnColor(colorP2);
		});
		Lua_helper.add_callback(lua, "setHealthBumpValues", function(x:Float = 1.05, y:Float = 1.2) {
			PlayState.instance.jumpX = x;
			PlayState.instance.jumpY = y;
		});
		Lua_helper.add_callback(lua, "setTimeBarColors", function(leftHex:String, rightHex:String) {
			PlayState.instance.timeBar.createFilledBar(returnColor(rightHex), returnColor(leftHex));
			PlayState.instance.timeBar.updateBar();
		});
		Lua_helper.add_callback(lua, "changeHealthIcon", function(char:String, isP2:Bool = false) {
			var tempChar:Character = new Character(0, 0, char);
			if(!isP2) {
				PlayState.instance.iconP1.changeIcon(tempChar.healthIcon);
				PlayState.instance.reloadHealthBarColors(tempChar.curCharacter, null);
			} else {
				PlayState.instance.iconP2.changeIcon(tempChar.healthIcon);
				PlayState.instance.reloadHealthBarColors(null, tempChar.curCharacter);
			}
		});
		Lua_helper.add_callback(lua, "triggerEvent", function(name:String, arg1:Dynamic, arg2:Dynamic) {
			var value1:String = arg1;
			var value2:String = arg2;
			PlayState.instance.triggerEventNote(name, value1, value2);
			return true;
		});
		Lua_helper.add_callback(lua, "changeMania", function(newValue:Int, skipTwn:Bool = false) {
			PlayState.instance.changeMania(newValue, skipTwn);
		});


		// Gameplay Functions

		Lua_helper.add_callback(lua, "addScore", function(value:Int = 0) {
			PlayState.instance.songScore += value;
			PlayState.instance.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "addMisses", function(value:Int = 0) {
			PlayState.instance.songMisses += value;
			PlayState.instance.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "addHits", function(value:Int = 0) {
			PlayState.instance.songHits += value;
			PlayState.instance.RecalculateRating();
		});

		Lua_helper.add_callback(lua, "drainScore", function(value:Int = 0) {
			PlayState.instance.songScore -= value;
			PlayState.instance.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "drainMisses", function(value:Int = 0) {
			PlayState.instance.songMisses -= value;
			PlayState.instance.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "drainHits", function(value:Int = 0) {
			PlayState.instance.songHits -= value;
			PlayState.instance.RecalculateRating();
		});

		Lua_helper.add_callback(lua, "setScore", function(value:Int) {
			PlayState.instance.songScore = value;
			PlayState.instance.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "setMisses", function(value:Int) {
			PlayState.instance.songMisses = value;
			PlayState.instance.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "setHits", function(value:Int) {
			PlayState.instance.songHits = value;
			PlayState.instance.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "setPercent", function(value:Float) {
			PlayState.instance.ratingPercent = value;
			PlayState.instance.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "setFC", function(value:String) {
			PlayState.instance.ratingFC = value;
			PlayState.instance.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "setRatingName", function(value:String) {
			PlayState.instance.ratingName = value;
			PlayState.instance.RecalculateRating();
		});

		Lua_helper.add_callback(lua, "addHealth", function(value:Float = 0) {
			PlayState.instance.health += value;
		});
		Lua_helper.add_callback(lua, "drainHealth", function(value:Float = 0) {
			PlayState.instance.health -= value;
		});
		Lua_helper.add_callback(lua, "setHealth", function(value:Float) {
			PlayState.instance.health = value;
		});

		Lua_helper.add_callback(lua, "addLifes", function(value:Int = 0) {
			PlayState.instance.lifes += value;
		});
		Lua_helper.add_callback(lua, "drainLifes", function(value:Int = 0) {
			PlayState.instance.lifes -= value;
		});
		Lua_helper.add_callback(lua, "setLifes", function(value:Int) {
			PlayState.instance.lifes = value;
		});

		Lua_helper.add_callback(lua, "setBonusHealth", function(value:Float = 0) {
			PlayState.instance.bonusHealth = value;
		});


		// Game Camera

		Lua_helper.add_callback(lua, "cameraSetTarget", function(target:String) {
			var toFollow:Int = 0;
			var char:String = '';
			switch(target) {
				case 'dad' | 'opponent':
					toFollow = 1;
				case 'gf' | 'girlfriend':
					toFollow = 2;
				default:
					if(PlayState.instance.luaCharsMap.exists(target)) {
						toFollow = 3;
						char = target;
					}
			}
			PlayState.instance.moveCamera(toFollow, char);
			return toFollow;
		});
		Lua_helper.add_callback(lua, "CameraFollowPos", function(?camX:Dynamic, ?camY:Dynamic) {
			var targetX:String = "";
			var targetY:String = "";
			if(camX == null && camY == null) {
				PlayState.instance.triggerEventNote("Camera Follow Pos", targetX, targetY);
				return false;
			} else {
				targetX = camX != null ? Std.string(camX) : "0";
				targetY = camY != null ? Std.string(camY) : "0";
				PlayState.instance.triggerEventNote("Camera Follow Pos", targetX, targetY);
				return true;
			}
		});
		Lua_helper.add_callback(lua, "cameraShake", function(camera:String, intensity:Float, duration:Float, axe:String, forced:Bool = false) {
			function camFunction():Void {
				var camType:String = cameraToString(camera);
				PlayState.instance.callOnLuas('cameraShakeCompleted', [camType]);
			}
			var axes:FlxAxes;
			switch(axe.trim().toLowerCase()) {
				case 'x': axes = X;
				case 'y': axes = Y;
				default: axes = XY;
			}
			cameraFromString(camera).shake(intensity, duration, camFunction, forced, axes);
		});
		Lua_helper.add_callback(lua, "cameraFlash", function(camera:String, color:String, duration:Float, forced:Bool = false) {
			function camFunction():Void {
				var camType:String = cameraToString(camera);
				PlayState.instance.callOnLuas('cameraFlashCompleted', [camType]);
			}
			cameraFromString(camera).flash(returnColor(color), duration, camFunction, forced);
		});
		Lua_helper.add_callback(lua, "cameraFade", function(camera:String, color:String, duration:Float, fadeIn:Bool = false, forced:Bool = false) {
			function camFunction():Void {
				var camType:String = cameraToString(camera);
				PlayState.instance.callOnLuas('cameraFlashCompleted', [camType]);
			}
			cameraFromString(camera).fade(returnColor(color), duration, fadeIn, camFunction, forced);
		});
		Lua_helper.add_callback(lua, "getScreenPositionX", function(variable:String) {
			var varValues:Array<String> = variable.split('.');
			var obj:FlxSprite = getObjectDirectly(varValues[0], true, true, true);
			if(varValues.length > 1) {
				obj = getVarInArray(getPropertyLoop(varValues,true,true,true,true), varValues[varValues.length-1]);
			}
			if(obj != null) return obj.getScreenPosition().x;

			return 0;
		});
		Lua_helper.add_callback(lua, "getScreenPositionY", function(variable:String) {
			var varValues:Array<String> = variable.split('.');
			var obj:FlxSprite = getObjectDirectly(varValues[0], true, true, true);
			if(varValues.length > 1) {
				obj = getVarInArray(getPropertyLoop(varValues,true,true,true,true), varValues[varValues.length-1]);
			}
			if(obj != null) return obj.getScreenPosition().y;

			return 0;
		});
		Lua_helper.add_callback(lua, "setCameraSpeed", function(value:Float = 1) {
			if(value < 0) value = 1;
			PlayState.instance.cameraSpeed = value;
		});
		Lua_helper.add_callback(lua, "setCameraZoom", function(value:Float = 1.05, camera:String) {
			if(camera!=null) camera = camera.toLowerCase().trim();
			switch(camera) {
				case 'cameraother' | 'camother' | 'other':
					PlayState.instance.defaultOthZoom = value;
				case 'camerahud' | 'camhud' | 'hud':
					PlayState.instance.defaultHudZoom = value;
				default:
					PlayState.instance.defaultCamZoom = value;
			}
		});
		Lua_helper.add_callback(lua, "setZoomIntensity", function(value:Float = 0.015, camera:String) {
			if(camera!=null) camera = camera.toLowerCase().trim();
			switch(camera) {
				case 'cameraother' | 'camother' | 'other':
					PlayState.instance.camOtherZooming = value;
				case 'camerahud' | 'camhud' | 'hud':
					PlayState.instance.camHudZooming = value;
				default:
					PlayState.instance.camGameZooming = value;
			}
		});
		Lua_helper.add_callback(lua, "makeCameraHit", function(camgame:Bool = false, camhud:Bool = false, camother:Bool = false, mult:Float = 1) {
			PlayState.instance.daZooming(camgame, camhud, camother, mult);
		});
		Lua_helper.add_callback(lua, "cameraSpecialMovement", function(char:Int = 0, noteData:Int = 0, ?luaChar:String = '') {
			PlayState.instance.cameraSpecialMovement(char, noteData, luaChar);
		});
		Lua_helper.add_callback(lua, "setCameraMovementOffset", function(value:Float) {
			PlayState.instance.camMoveOffset = value;
		});


		// Lua Sprites

		Lua_helper.add_callback(lua, "makeLuaSprite", function(tag:String, image:String, x:Float, y:Float) {
			tag = tag.replace('.', '');
			resetSpriteTag(tag);
			var leSprite:ModchartSprite = new ModchartSprite(x, y);
			if(image != null && image.length > 0) {
				leSprite.loadGraphic(Paths.image(image));
			}
			leSprite.antialiasing = ClientPrefs.globalAntialiasing;
			PlayState.instance.modchartSprites.set(tag, leSprite);
			leSprite.active = true;
		});
		Lua_helper.add_callback(lua, "makeGraphic", function(obj:String, width:Int, height:Int, color:String) {
			var spr:FlxSprite = PlayState.instance.getLuaObject(obj,false);
			if(spr!=null) {
				PlayState.instance.getLuaObject(obj,false).makeGraphic(width, height, returnColor(color));
				return;
			}

			var object:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(object != null) {
				object.makeGraphic(width, height, returnColor(color));
			}
		});
		Lua_helper.add_callback(lua, "setGraphicSize", function(obj:String, x:Int, y:Int = 0, updateHitbox:Bool = true) {
			if(PlayState.instance.getLuaObject(obj,true)!=null) {
				var leObject:FlxSprite = PlayState.instance.getLuaObject(obj,true);
				leObject.setGraphicSize(x, y);
				if(updateHitbox) leObject.updateHitbox();
				return;
			}
			var varValues:Array<String> = obj.split('.');
			var playStateObj:FlxSprite = getObjectDirectly(varValues[0],true);
			if(varValues.length > 1) {
				playStateObj = getVarInArray(getPropertyLoop(varValues), varValues[varValues.length-1]);
			}
			if(playStateObj != null) {
				playStateObj.setGraphicSize(x, y);
				if(updateHitbox) playStateObj.updateHitbox();
				return;
			}
			luaTrace('Couldnt find object: ' + obj, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "makeShaderSprite", function(tag:String, shader:String, x:Float, y:Float,optimize:Bool=false) {
			tag = tag.replace('.', '');
			resetSpriteTag(tag);
			var leSprite:ModchartSprite = new ModchartSprite(x, y,true,shader,optimize);
			leSprite.antialiasing = ClientPrefs.globalAntialiasing;

			PlayState.instance.modchartSprites.set(tag, leSprite);
			leSprite.active = true;
		});
		Lua_helper.add_callback(lua, "addLuaSprite", function(tag:String, front:Bool = false) {
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var luaImage:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
				if(!luaImage.wasAdded) {
					if(front)
					{
						getInstance().add(luaImage);
					}
					else
					{
						if(PlayState.instance.isDead)
						{
							GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), luaImage);
						}
						else
						{
							var position:Int = PlayState.instance.members.indexOf(PlayState.instance.gfGroup);
							if(PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup) < position) {
								position = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
							} else if(PlayState.instance.members.indexOf(PlayState.instance.dadGroup) < position) {
								position = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
							}
							PlayState.instance.insert(position, luaImage);
						}
					}
					luaImage.wasAdded = true;
					//trace('added a thing: ' + tag);
				}
			}
		});
		Lua_helper.add_callback(lua, "removeLuaSprite", function(tag:String, destroy:Bool = true) {
			if(!PlayState.instance.modchartSprites.exists(tag)) {
				return;
			}

			var chartSprite:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
			if(destroy) {
				chartSprite.kill();
			}

			if(chartSprite.wasAdded) {
				getInstance().remove(chartSprite, true);
				chartSprite.wasAdded = false;
			}

			if(destroy) {
				chartSprite.destroy();
				PlayState.instance.modchartSprites.remove(tag);
			}
		});


		// Skewed Sprite

		Lua_helper.add_callback(lua, "makeSkewedSprite", function(tag:String, image:String, x:Float, y:Float) {
			resetSkewedSprite(tag);
			var leSprite = new FlxSkewedSprite(x, y);
			if(image != null && image.length > 0) {
				leSprite.loadGraphic(Paths.image(image));
			}
			leSprite.antialiasing = ClientPrefs.globalAntialiasing;
			PlayState.instance.modchartSkeweds.set(tag, leSprite);
		});
		Lua_helper.add_callback(lua, "setSpriteSkewX", function(tag:String, value:Float) {
			if(PlayState.instance.modchartSkeweds.exists(tag)) {
				var skewedSprite = PlayState.instance.modchartSkeweds.get(tag);
				skewedSprite.skew.x = value;
			}
		});
		Lua_helper.add_callback(lua, "setSpriteSkewY", function(tag:String, value:Float) {
			if(PlayState.instance.modchartSkeweds.exists(tag)) {
				var skewedSprite = PlayState.instance.modchartSkeweds.get(tag);
				skewedSprite.skew.y = value;
			}
		});
		Lua_helper.add_callback(lua, "skewedMatrixExposed", function(tag:String, value:Bool = false) {
			if(PlayState.instance.modchartSkeweds.exists(tag)) {
				var skewedSprite = PlayState.instance.modchartSkeweds.get(tag);
				skewedSprite.matrixExposed = value;
			}
		});
		Lua_helper.add_callback(lua, "skewedTransformMatrix", function(tag:String, a:Float = 1, b:Float = 0, c:Float = 0, d:Float = 1, tx:Float = 0, ty:Float = 0) {
			if(PlayState.instance.modchartSkeweds.exists(tag)) {
				var skewedSprite = PlayState.instance.modchartSkeweds.get(tag);
				skewedSprite.transformMatrix.setTo(a, b, c, d, tx, ty);
			}
		});
		Lua_helper.add_callback(lua, "addSkewedSprite", function(tag:String, front:Bool = false) {
			if(PlayState.instance.modchartSkeweds.exists(tag)) {
				var luaImage = PlayState.instance.modchartSkeweds.get(tag);
				if(front) {
					getInstance().add(luaImage);
				} else {
					if(PlayState.instance.isDead) {
						GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), luaImage);
					} else {
						var position:Int = PlayState.instance.members.indexOf(PlayState.instance.gfGroup);
						if(PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup) < position) {
							position = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
						} else if(PlayState.instance.members.indexOf(PlayState.instance.dadGroup) < position) {
							position = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
						}
						PlayState.instance.insert(position, luaImage);
					}
				}
			} else {
				luaTrace("Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "removeSkewedSprite", function(tag:String, destroy:Bool = true) {
			if(PlayState.instance.modchartSkeweds.exists(tag)) {
				var luaSprite = PlayState.instance.modchartSkeweds.get(tag);
				if(destroy) {
					luaSprite.kill();
				}
				getInstance().remove(luaSprite, true);
				if(destroy) {
					luaSprite.destroy();
					PlayState.instance.modchartSkeweds.remove(tag);
				}
			} else {
				luaTrace("Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});


		// Lua Animations

		Lua_helper.add_callback(lua, "makeAnimatedLuaSprite", function(tag:String, image:String, x:Float, y:Float, ?spriteType:String = "sparrow") {
			tag = tag.replace('.', '');
			resetSpriteTag(tag);
			var leSprite:ModchartSprite = new ModchartSprite(x, y);

			loadFrames(leSprite, image, spriteType);
			leSprite.antialiasing = ClientPrefs.globalAntialiasing;
			PlayState.instance.modchartSprites.set(tag, leSprite);
		});
		Lua_helper.add_callback(lua, "addAnimation", function(obj:String, name:String, frames:Array<Int>, framerate:Int = 24, loop:Bool = true) {
			if(PlayState.instance.getLuaObject(obj,false)!=null) {
				var anims:FlxSprite = PlayState.instance.getLuaObject(obj,false);
				anims.animation.add(name, frames, framerate, loop);
				if(anims.animation.curAnim == null) {
					anims.animation.play(name, true);
					anims.animation.finishCallback = function(name:String):Void {
						PlayState.instance.callOnLuas('onAnimationCompleted', [name]);
					};
				}
				return;
			}
			var anims:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(anims != null) {
				anims.animation.add(name, frames, framerate, loop);
				if(anims.animation.curAnim == null) {
					anims.animation.play(name, true);
					anims.animation.finishCallback = function(name:String):Void {
						PlayState.instance.callOnLuas('onAnimationCompleted', [name]);
					};
				}
			}
		});
		Lua_helper.add_callback(lua, "addAnimationByPrefix", function(obj:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true) {
			if(PlayState.instance.getLuaObject(obj,false)!=null) {
				var anims:FlxSprite = PlayState.instance.getLuaObject(obj,false);
				anims.animation.addByPrefix(name, prefix, framerate, loop);
				if(anims.animation.curAnim == null) {
					anims.animation.play(name, true);
					anims.animation.finishCallback = function(name:String):Void {
						PlayState.instance.callOnLuas('onAnimationCompleted', [name]);
					};
				}
				return;
			}
			var anims:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(anims != null) {
				anims.animation.addByPrefix(name, prefix, framerate, loop);
				if(anims.animation.curAnim == null) {
					anims.animation.play(name, true);
					anims.animation.finishCallback = function(name:String):Void {
						PlayState.instance.callOnLuas('onAnimationCompleted', [name]);
					};
				}
			}
		});
		Lua_helper.add_callback(lua, "addAnimationByIndices", function(obj:String, name:String, prefix:String, indices:String, framerate:Int = 24) {
			var strIndices:Array<String> = indices.trim().split(',');
			var indie:Array<Int> = [];
			for (i in 0...strIndices.length) {
				indie.push(Std.parseInt(strIndices[i]));
			}
			if(PlayState.instance.getLuaObject(obj, false)!=null) {
				var anims:FlxSprite = PlayState.instance.getLuaObject(obj,false);
				anims.animation.addByIndices(name, prefix, indie, '', framerate, false);
				if(anims.animation.curAnim == null) {
					anims.animation.play(name, true);
					anims.animation.finishCallback = function(name:String):Void {
						PlayState.instance.callOnLuas('onAnimationCompleted', [name]);
					};
				}
				return true;
			}
			var anims:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(anims != null) {
				anims.animation.addByIndices(name, prefix, indie, '', framerate, false);
				if(anims.animation.curAnim == null) {
					anims.animation.play(name, true);
					anims.animation.finishCallback = function(name:String):Void {
						PlayState.instance.callOnLuas('onAnimationCompleted', [name]);
					};
				}
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "playAnim", function(obj:String, name:String, forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0)
		{
			if(PlayState.instance.getLuaObject(obj, false) != null) {
				var luaObj:FlxSprite = PlayState.instance.getLuaObject(obj,false);
				if(luaObj.animation.getByName(name) != null)
				{
					luaObj.animation.play(name, forced, reverse, startFrame);
					luaObj.animation.finishCallback = function(name:String):Void {
						PlayState.instance.callOnLuas('onAnimationCompleted', [name]);
					};
					if(Std.isOfType(luaObj, ModchartSprite))
					{
						//convert luaObj to ModchartSprite
						var obj:Dynamic = luaObj;
						var luaObj:ModchartSprite = obj;

						var daOffset = luaObj.animOffsets.get(name);
						if (luaObj.animOffsets.exists(name))
						{
							luaObj.offset.set(daOffset[0], daOffset[1]);
						}
						else
							luaObj.offset.set(0, 0);
					}
				}
				return true;
			}
			var spr:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(spr != null) {
				if(spr.animation.getByName(name) != null)
				{
					if(Std.isOfType(spr, Character))
					{
						//convert spr to Character
						var obj:Dynamic = spr;
						var spr:Character = obj;
						spr.playAnim(name, forced, reverse, startFrame);
					}
					else
					{
						spr.animation.play(name, forced, reverse, startFrame);
						spr.animation.finishCallback = function(name:String):Void {
							PlayState.instance.callOnLuas('onAnimationCompleted', [name]);
						};
					}
				}
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "pauseAnim", function(obj:String) {
			if(PlayState.instance.getLuaObject(obj, false) != null) {
				var animObj:FlxSprite = PlayState.instance.getLuaObject(obj,false);
				if(animObj.animation.curAnim != null) {
					animObj.animation.pause();
				}
				return;
			}
			var animObj:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(animObj != null) {
				if(animObj.animation.curAnim != null) {
					animObj.animation.pause();
				}
			}
		});
		Lua_helper.add_callback(lua, "resumeAnim", function(obj:String) {
			if(PlayState.instance.getLuaObject(obj, false) != null) {
				var animObj:FlxSprite = PlayState.instance.getLuaObject(obj, false);
				if(animObj.animation.curAnim != null) {
					animObj.animation.resume();
				}
				return;
			}
			var animObj:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(animObj != null) {
				if(animObj.animation.curAnim != null) {
					animObj.animation.resume();
				}
			}
		});
		Lua_helper.add_callback(lua, "addOffset", function(obj:String, anim:String, x:Float, y:Float) {
			if(PlayState.instance.modchartSprites.exists(obj)) {
				PlayState.instance.modchartSprites.get(obj).animOffsets.set(anim, [x, y]);
				return true;
			}

			var char:Character = Reflect.getProperty(getInstance(), obj);
			if(char != null) {
				char.addOffset(anim, x, y);
				return true;
			}
			return false;
		});


		// Image Assets

		Lua_helper.add_callback(lua, "setScrollFactor", function(obj:String, scrollX:Float, scrollY:Float) {
			if(PlayState.instance.getLuaObject(obj,false,true)!=null) {
				PlayState.instance.getLuaObject(obj,false,true).scrollFactor.set(scrollX, scrollY);
				return;
			}
			var object:FlxObject = Reflect.getProperty(getInstance(), obj);
			if(object != null) {
				object.scrollFactor.set(scrollX, scrollY);
			}
		});
		Lua_helper.add_callback(lua, "scaleObject", function(obj:String, x:Float, y:Float, updateHitbox:Bool = true) {
			if(PlayState.instance.getLuaObject(obj,true,false)!=null) {
				var leImage:FlxSprite = PlayState.instance.getLuaObject(obj,true,false);
				leImage.scale.set(x, y);
				if(updateHitbox) leImage.updateHitbox();
				return;
			}

			var varValues:Array<String> = obj.split('.');
			var playStateObj:FlxSprite = getObjectDirectly(varValues[0],true);
			if(varValues.length > 1) {
				playStateObj = getVarInArray(getPropertyLoop(varValues), varValues[varValues.length-1]);
			}

			if(playStateObj != null) {
				playStateObj.scale.set(x, y);
				if(updateHitbox) playStateObj.updateHitbox();
				return;
			}
			luaTrace('Couldnt find object: ' + obj, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "getMidpointX", function(variable:String) {
			var varValues:Array<String> = variable.split('.');
			var obj:FlxSprite = getObjectDirectly(varValues[0], true, true, true);
			if(varValues.length > 1) {
				obj = getVarInArray(getPropertyLoop(varValues,true,true,true), varValues[varValues.length-1]);
			}
			if(obj != null) return obj.getMidpoint().x;

			return 0;
		});
		Lua_helper.add_callback(lua, "getMidpointY", function(variable:String) {
			var varValues:Array<String> = variable.split('.');
			var obj:FlxSprite = getObjectDirectly(varValues[0], true, true, true);
			if(varValues.length > 1) {
				obj = getVarInArray(getPropertyLoop(varValues,true,true,true,true), varValues[varValues.length-1]);
			}
			if(obj != null) return obj.getMidpoint().y;

			return 0;
		});
		Lua_helper.add_callback(lua, "getGraphicMidpointX", function(variable:String) {
			var varValues:Array<String> = variable.split('.');
			var obj:FlxSprite = getObjectDirectly(varValues[0],true,false);
			if(varValues.length > 1) {
				obj = getVarInArray(getPropertyLoop(varValues), varValues[varValues.length-1]);
			}
			if(obj != null) return obj.getGraphicMidpoint().x;

			return 0;
		});
		Lua_helper.add_callback(lua, "getGraphicMidpointY", function(variable:String) {
			var varValues:Array<String> = variable.split('.');
			var obj:FlxSprite = getObjectDirectly(varValues[0],true,false);
			if(varValues.length > 1) {
				obj = getVarInArray(getPropertyLoop(varValues), varValues[varValues.length-1]);
			}
			if(obj != null) return obj.getGraphicMidpoint().y;

			return 0;
		});
		Lua_helper.add_callback(lua, "updateHitbox", function(obj:String) {
			if(PlayState.instance.getLuaObject(obj,true,false)!=null) {
				var spriteBox:FlxSprite = PlayState.instance.getLuaObject(obj,true,false);
				spriteBox.updateHitbox();
				return;
			}
			var playStateObj:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(playStateObj != null) {
				playStateObj.updateHitbox();
				return;
			}
			luaTrace('Couldnt find object: ' + obj, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "updateHitboxFromGroup", function(group:String, index:Int) {
			if(Std.isOfType(Reflect.getProperty(getInstance(), group), FlxTypedGroup)) {
				Reflect.getProperty(getInstance(), group).members[index].updateHitbox();
				return;
			}
			Reflect.getProperty(getInstance(), group)[index].updateHitbox();
		});
		Lua_helper.add_callback(lua, "setObjectCamera", function(obj:String, camera:String = '') {
			var real = PlayState.instance.getLuaObject(obj, true, true, true);
			if(real!=null){
				real.cameras = [cameraFromString(camera)];
				return true;
			}
			var theArray:Array<String> = obj.split('.');
			var object:FlxSprite = getObjectDirectly(theArray[0], true, true, true);
			if(theArray.length > 1) {
				object = getVarInArray(getPropertyLoop(theArray,true,true,true,true), theArray[theArray.length-1]);
			}
			if(object != null) {
				object.cameras = [cameraFromString(camera)];
				return true;
			}
			luaTrace("Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setBlendMode", function(obj:String, blend:String = '') {
			var real = PlayState.instance.getLuaObject(obj,true);
			if(real!=null) {
				real.blend = blendModeFromString(blend);
				return true;
			}
			var varValues:Array<String> = obj.split('.');
			var spr:FlxSprite = getObjectDirectly(varValues[0],true);
			if(varValues.length > 1) {
				spr = getVarInArray(getPropertyLoop(varValues), varValues[varValues.length-1]);
			}
			if(spr != null) {
				spr.blend = blendModeFromString(blend);
				return true;
			}
			luaTrace("Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "screenCenter", function(obj:String, pos:String = 'xy') {
			var spr:FlxSprite = PlayState.instance.getLuaObject(obj, true, true, true);
			if(spr == null) {
				var varValues:Array<String> = obj.split('.');
				spr = getObjectDirectly(varValues[0], true, true, true);
				if(varValues.length > 1) {
					spr = getVarInArray(getPropertyLoop(varValues,true,true,true,true), varValues[varValues.length-1]);
				}
			}
			if(spr != null) {
				switch(pos.trim().toLowerCase()) {
					case 'x':
						spr.screenCenter(X);
						return;
					case 'y':
						spr.screenCenter(Y);
						return;
					default:
						spr.screenCenter(XY);
						return;
				}
			}
			luaTrace("Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "getPixelColor", function(obj:String, x:Int, y:Int) {
			var leObject:Array<String> = obj.split('.');
			var spr:FlxSprite = getObjectDirectly(leObject[0],true);
			if(leObject.length > 1) {
				spr = getVarInArray(getPropertyLoop(leObject), leObject[leObject.length-1]);
			}

			if(spr != null) {
				if(spr.framePixels != null) spr.framePixels.getPixel32(x, y);
				return spr.pixels.getPixel32(x, y);
			}
			return 0;
		});
		Lua_helper.add_callback(lua, "objectsOverlap", function(obj1:String, obj2:String) {
			var namesArray:Array<String> = [obj1, obj2];
			var objectsArray:Array<FlxSprite> = [];
			for (i in 0...namesArray.length)
			{
				var real = PlayState.instance.getLuaObject(namesArray[i],true);
				if(real!=null) {
					objectsArray.push(real);
				} else {
					objectsArray.push(Reflect.getProperty(getInstance(), namesArray[i]));
				}
			}
			if(!objectsArray.contains(null) && FlxG.overlap(objectsArray[0], objectsArray[1]))
			{
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "setSpriteColor", function(obj:String, targetColor:String) {
			if(PlayState.instance.getLuaObject(obj,true) != null) {
				var leImage:FlxSprite = PlayState.instance.getLuaObject(obj,true);
				leImage.color = returnColor(targetColor);
				return;
			}

			var varValues:Array<String> = obj.split('.');
			var playStateObj:FlxSprite = getObjectDirectly(varValues[0],true);
			if(varValues.length > 1)
				playStateObj = getVarInArray(getPropertyLoop(varValues), varValues[varValues.length-1]);

			if(playStateObj != null) {
				playStateObj.color = returnColor(targetColor);
				return;
			}
			luaTrace('Couldnt find object: ' + obj, false, false, FlxColor.RED);
		});
		/*
		Lua_helper.add_callback(lua, "setSpriteGradient", function(obj:String, colors:Array<String>, rotation:Int = 180, interpolate:Bool = true) {
			if(PlayState.instance.getLuaObject(obj,true,false)!=null) {
				var leImage:FlxSprite = PlayState.instance.getLuaObject(obj,true,false);
				var colorArray:Array<Int> = [];
				for (i in 0...colors.length) {
					var color:Int = Std.parseInt(colors[i]);
					if(!colors[i].startsWith('0x')) color = Std.parseInt('0x88' + colors[i]);
					colorArray.push(color);
				}
				var gradient = FlxGradient.overlayGradientOnFlxSprite(leImage, Std.int(leImage.width), Std.int(leImage.height), colorArray, 0, 0, 1, rotation, interpolate);
				leImage.stamp(gradient, 0, 0);
				return;
			}
			var varValues:Array<String> = obj.split('.');
			var lePicture:FlxSprite = getObjectDirectly(varValues[0],true,false);
			if(varValues.length > 1) {
				lePicture = getVarInArray(getPropertyLoop(varValues), varValues[varValues.length-1]);
			}
			if(lePicture != null) {
				var colorArray:Array<Int> = [];
				for (i in 0...colors.length) {
					var color:Int = Std.parseInt(colors[i]);
					if(!colors[i].startsWith('0x')) color = Std.parseInt('0xff' + colors[i]);
					colorArray.push(color);
				}
				var gradient = FlxGradient.overlayGradientOnFlxSprite(lePicture, Std.int(lePicture.width), Std.int(lePicture.height), colorArray, 0, 0, 1, rotation, interpolate);
				lePicture.stamp(gradient, 0, 0);
				return;
			}
			luaTrace('Couldnt find object: ' + obj, false, false, FlxColor.RED);
		});
		*/
		Lua_helper.add_callback(lua, "isNoteChild", function(parentID:Int, childID:Int){
			var parent: Note = cast PlayState.instance.getLuaObject('note${parentID}',false);
			var child: Note = cast PlayState.instance.getLuaObject('note${childID}',false);
			if(parent!=null && child!=null)
				return parent.tail.contains(child);

			luaTrace('${parentID} or ${childID} is not a valid note ID', false, false, FlxColor.RED);
			return false;
		});


		// Setup Stage Objects

		Lua_helper.add_callback(lua, "setupStageSprite", function(path:String) {
			if(FileSystem.exists(Paths.modsObjects(path))) {
				var jsonFormatted:Dynamic = File.getContent(Paths.modsObjects(path)).trim();
				jsonFormatted = Json.parse(jsonFormatted);
				var tag = jsonFormatted.tag;
				var image = jsonFormatted.path;
				var x = jsonFormatted.x;
				var y = jsonFormatted.y;
				var scalex = jsonFormatted.scalex;
				var scaley = jsonFormatted.scaley;
				var scrollx = jsonFormatted.scrollx;
				var scrolly = jsonFormatted.scrolly;
				var isanimated = jsonFormatted.animated;
				var front = jsonFormatted.front;
				var antialiasing = jsonFormatted.antialiasing;
				var flipx = jsonFormatted.flipx;
				var flipy = jsonFormatted.flipy;
				var alpha = jsonFormatted.alpha;
				if(!isanimated) {
					Lua_helper.callbacks['makeLuaSprite'](tag, image, x, y);
					Lua_helper.callbacks['scaleObject'](tag, scalex, scaley);
					Lua_helper.callbacks['setScrollFactor'](tag, scrollx, scrolly);
					Lua_helper.callbacks['setProperty'](tag + '.antialiasing', antialiasing);
					Lua_helper.callbacks['setProperty'](tag + '.flipX', flipx);
					Lua_helper.callbacks['setProperty'](tag + '.flipY', flipy);
					Lua_helper.callbacks['setProperty'](tag + '.alpha', alpha);
					Lua_helper.callbacks['updateHitbox'](tag);
					Lua_helper.callbacks['addLuaSprite'](tag, front);
				}
			}
		});

		// Lua Texts

		Lua_helper.add_callback(lua, "makeLuaText", function(tag:String, text:String, width:Int, x:Float, y:Float) {
			tag = tag.replace('.', '');
			resetTextTag(tag);
			var leText:FlxText = new FlxText(x, y, text, width);
			leText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			leText.cameras = [PlayState.instance.camHUD];
			leText.scrollFactor.set();
			leText.borderSize = 2;
			PlayState.instance.modchartTexts.set(tag, leText);
		});
		Lua_helper.add_callback(lua, "setTextString", function(tag:String, text:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null) {
				obj.text = text;
				return true;
			}
			luaTrace('Couldnt find object: ' + tag, false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextSize", function(tag:String, size:Int) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.size = size;
				return true;
			}
			luaTrace('Couldnt find object: ' + tag, false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextWidth", function(tag:String, width:Float) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.fieldWidth = width;
				return true;
			}
			luaTrace('Couldnt find object: ' + tag, false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextBorder", function(tag:String, size:Int, color:String, style:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				if(size > 0){
					obj.borderStyle = OUTLINE;
					obj.borderSize = size;
				} else
					obj.borderStyle = NONE;
				obj.borderColor = returnColor(color);
				return true;
			}
			luaTrace('Couldnt find object: ' + tag, false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextColor", function(tag:String, color:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null) {
				obj.color = returnColor(color);
				return true;
			}
			luaTrace('Couldnt find object: ' + tag, false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextFont", function(tag:String, newFont:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null) {
				obj.font = Paths.font(newFont);
				return true;
			}
			luaTrace('Couldnt find object: ' + tag, false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextItalic", function(tag:String, italic:Bool) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.italic = italic;
				return true;
			}
			luaTrace('Couldnt find object: ' + tag, false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextAlignment", function(tag:String, alignment:String = 'left') {
			var obj:FlxText = getTextObject(tag);
			if(obj != null) {
				obj.alignment = LEFT;
				switch(alignment.trim().toLowerCase()) {
					case 'right':
						obj.alignment = RIGHT;
					case 'center':
						obj.alignment = CENTER;
				}
				return true;
			}
			luaTrace('Couldnt find object: ' + tag, false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "getTextString", function(tag:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				return obj.text;
			}
			luaTrace('Couldnt find object: ' + tag, false, false, FlxColor.RED);
			return null;
		});
		Lua_helper.add_callback(lua, "getTextSize", function(tag:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				return obj.size;
			}
			luaTrace('Couldnt find object: ' + tag, false, false, FlxColor.RED);
			return -1;
		});
		Lua_helper.add_callback(lua, "getTextFont", function(tag:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				return obj.font;
			}
			luaTrace('Couldnt find object: ' + tag, false, false, FlxColor.RED);
			return null;
		});
		Lua_helper.add_callback(lua, "getTextWidth", function(tag:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				return obj.fieldWidth;
			}
			luaTrace('Couldnt find object: ' + tag, false, false, FlxColor.RED);
			return 0;
		});
		Lua_helper.add_callback(lua, "makeSimpleText", function(tag:String, text:String, width:Int, xy:Array<Float>, size:Int, color:String = null, font:String = null, alignm:String) {
			tag = tag.replace('.', '');
			resetTextTag(tag);
			var leText:FlxText = new FlxText(xy[0], xy[1], text, width);
			leText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			leText.size = size;
			if(color != null) leText.color = returnColor(color);
			if(font != null) leText.font = font;
			switch(alignm.trim().toLowerCase()) {
				case 'right':
					leText.alignment = RIGHT;
				case 'left':
					leText.alignment = LEFT;
			}
			leText.cameras = [PlayState.instance.camHUD];
			leText.scrollFactor.set();
			leText.borderSize = 2;
			PlayState.instance.modchartTexts.set(tag, leText);
		});
		Lua_helper.add_callback(lua, "addLuaText", function(tag:String) {
			if(PlayState.instance.modchartTexts.exists(tag)) {
				var objText:FlxText = PlayState.instance.modchartTexts.get(tag);
				getInstance().add(objText);
			}
		});
		Lua_helper.add_callback(lua, "removeLuaText", function(tag:String, destroy:Bool = true) {
			if(!PlayState.instance.modchartTexts.exists(tag)) {
				return;
			}
			var objText:FlxText = PlayState.instance.modchartTexts.get(tag);
			if(destroy) {
				objText.kill();
			}
			getInstance().remove(objText, true);
			if(destroy) {
				objText.destroy();
				PlayState.instance.modchartTexts.remove(tag);
			}
		});


		// Lua Texts Gradients
	/*
		Lua_helper.add_callback(lua, "makeLuaTextGradient", function(tag:String, text:String, width:Int, x:Float, y:Float, colors:Array<String>) {
			tag = tag.replace('.', '');
			resetTextAndGradientTag(tag);
			var text = new FlxText(x, y, text, width);
			text.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.drawFrame();
			var colorArray:Array<FlxColor> = [];
			if(colors != null){
				for (i in 0...colors.length) {
					var colorNum:Int = Std.parseInt(colors[i]);
					if(!colors[i].startsWith('0x')) colorNum = Std.parseInt('0xff' + colors[i]);
					var colorFlx:FlxColor = new FlxColor(colorNum);
					colorArray.push(colorFlx);
				}
			} else {
				var colorDefault1:FlxColor = new FlxColor(0xff00F400);
				var colorDefault2:FlxColor = new FlxColor(0xff005100);
				colorArray.push(colorDefault1);
				colorArray.push(colorDefault2);
			}
			var gradientText = new FlxSprite();
			var gradient = FlxGradient.createGradientFlxSprite(text.frameWidth, text.frameHeight, [FlxColor.BLACK, FlxColor.GREEN, FlxColor.WHITE]);
			gradientText.screenCenter();
			gradientText.alphaMask(gradient.framePixels, text.framePixels);
			gradientText.cameras = [cameraFromString(cameraType)];
			getInstance().add(gradientText);
			PlayState.instance.modchartTexts.set(tag, leText);
		});
	*/


		// Tweens

		Lua_helper.add_callback(lua, "startTween", function(tag:String, vars:String, values:Any = null, duration:Float, options:Any = null) {
			var objectName:Dynamic = tweenVars(tag, vars);
			if(objectName != null) {
				if(values != null) {
					var myOptions:LuaTweenOptions = getLuaTween(options);
					PlayState.instance.modchartTweens.set(tag, FlxTween.tween(objectName, values, duration, {
						type: myOptions.type,
						ease: myOptions.ease,
						startDelay: myOptions.startDelay,
						loopDelay: myOptions.loopDelay,

						onUpdate: function(twn:FlxTween) {
							if(myOptions.onUpdate != null) PlayState.instance.callOnLuas(myOptions.onUpdate, [tag, vars]);
						},
						onStart: function(twn:FlxTween) {
							if(myOptions.onStart != null) PlayState.instance.callOnLuas(myOptions.onStart, [tag, vars]);
						},
						onComplete: function(twn:FlxTween) {
							if(myOptions.onComplete != null) PlayState.instance.callOnLuas(myOptions.onComplete, [tag, vars]);
							if(twn.type == FlxTweenType.ONESHOT || twn.type == FlxTweenType.BACKWARD) PlayState.instance.modchartTweens.remove(tag);
						}
					}));
				} else {
					luaTrace('No values on 3rd argument!', false, false, FlxColor.RED);
				}
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenX", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String, delay:Float) {
			runTweenFunction(tag, vars, {x: value}, duration, delay, ease, 'doTweenX');
		});
		Lua_helper.add_callback(lua, "doTweenY", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String, delay:Float) {
			runTweenFunction(tag, vars, {y: value}, duration, delay, ease, 'doTweenY');
		});
		Lua_helper.add_callback(lua, "doTweenAngle", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String, delay:Float) {
			runTweenFunction(tag, vars, {angle: value}, duration, delay, ease, 'doTweenAngle');
		});
		Lua_helper.add_callback(lua, "doTweenAlpha", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String, delay:Float) {
			runTweenFunction(tag, vars, {alpha: value}, duration, delay, ease, 'doTweenAlpha');
		});
		Lua_helper.add_callback(lua, "doTweenZoom", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String, delay:Float) {
			runTweenFunction(tag, vars, {zoom: value}, duration, delay, ease, 'doTweenZoom');
		});
		Lua_helper.add_callback(lua, "doTweenColor", function(tag:String, vars:String, color:String, duration:Float, ease:String, delay:Float) {
			var objectName:Dynamic = tweenVars(tag, vars);
			if(objectName != null) {
				var curColor:FlxColor = objectName.color;
				curColor.alphaFloat = objectName.alpha;
				PlayState.instance.modchartTweens.set(tag, FlxTween.color(objectName, duration, curColor, returnColor(color), {startDelay: delay, ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					},
					onUpdate: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenProgress', [tag]);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});


		// Special Tweens

		Lua_helper.add_callback(lua, "doTweenLinear", function(tag:String, vars:String, toX:Float, toY:Float, duration:Float, ease:String, delay:Float) {
			var objectName:Dynamic = tweenVars(tag, vars);
			if(objectName != null) {
				var fromX:Float = objectName.x;
				var fromY:Float = objectName.y;
				PlayState.instance.modchartTweens.set(tag, FlxTween.linearMotion(objectName, fromX, fromY, toX, toY, duration, true, {startDelay: delay, ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					},
					onUpdate: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenProgress', [tag]);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenPath", function(tag:String, vars:String, points:Array<Array<Float>>, duration:Float, ease:String, delay:Float) {
			var objectName:Dynamic = tweenVars(tag, vars);
			if(objectName != null) {
				if(points.length < 1) throw "The points array must have at least 1 additional element";
				var allPoints:Array<FlxPoint> = [];
				allPoints.push(new FlxPoint(objectName.x, objectName.y));
				for (subArray in points) {
					if (subArray.length < 2) throw "the subArray must have 2 valid values";
					var x:Float = subArray[0];
					var y:Float = subArray[1];
					allPoints.push(new FlxPoint(x, y));
				}
				PlayState.instance.modchartTweens.set(tag, FlxTween.linearPath(objectName, allPoints, duration, true, {startDelay: delay, ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					},
					onUpdate: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenProgress', [tag]);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenCurve", function(tag:String, vars:String, controlPos:Array<Float>, toPos:Array<Float>, duration:Float, ease:String, delay:Float) {
			var objectName:Dynamic = tweenVars(tag, vars);
			if(objectName != null) {
				if(controlPos == null) throw "The curve control point array is empty";
				if(toPos == null) throw "The target position array is empty";
				var fromX:Float = objectName.x;
				var fromY:Float = objectName.y;
				var controlX:Float = controlPos[0];
				var controlY:Float = controlPos[1];
				var toX:Float = toPos[0];
				var toY:Float = toPos[1];
				PlayState.instance.modchartTweens.set(tag, FlxTween.quadMotion(objectName, fromX, fromY, controlX, controlY, toX, toY, duration, true, {startDelay: delay, ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					},
					onUpdate: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenProgress', [tag]);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenDualCurve", function(tag:String, vars:String, aControl:Array<Float>, bControl:Array<Float>, toPos:Array<Float>, duration:Float, ease:String, delay:Float) {
			var objectName:Dynamic = tweenVars(tag, vars);
			if(objectName != null) {
				if(aControl == null) throw "The first curve control point array is empty";
				if(bControl == null) throw "The second curve control point array is empty";
				if(toPos == null) throw "The target position array is empty";
				var fromX:Float = objectName.x;
				var fromY:Float = objectName.y;
				var aX:Float = aControl[0];
				var aY:Float = aControl[1];
				var bX:Float = bControl[0];
				var bY:Float = bControl[1];
				var toX:Float = toPos[0];
				var toY:Float = toPos[1];
				PlayState.instance.modchartTweens.set(tag, FlxTween.cubicMotion(objectName, fromX, fromY, aX, aY, bX, bY, toX, toY, duration, {startDelay: delay, ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					},
					onUpdate: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenProgress', [tag]);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenCurvePath", function(tag:String, vars:String, points:Array<Array<Float>>, duration:Float, ease:String, delay:Float) {
			var objectName:Dynamic = tweenVars(tag, vars);
			if(objectName != null) {
				if(points.length < 2) throw "The points array must have at least 2 additional element";
				var allPoints:Array<FlxPoint> = [];
				allPoints.push(new FlxPoint(objectName.x, objectName.y));
				for (subArray in points) {
					if (subArray.length < 2) throw "the subArray must have 2 valid values";
					var x:Float = 2;
					var y:Float = 2;
					if ((points.indexOf(subArray) + 1) % 2 == 1) { 	// This is to prevent sudden crashes that close the game -_-
						if (subArray[0] != 0) x = subArray[0]; 
						if (subArray[1] != 0) y = subArray[1]; 
					} else {
						x = subArray[0]; 
						y = subArray[1];
					}
					allPoints.push(new FlxPoint(x, y));
				}
				PlayState.instance.modchartTweens.set(tag, FlxTween.quadPath(objectName, allPoints, duration, true, {startDelay: delay, ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					},
					onUpdate: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenProgress', [tag]);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenCircular", function(tag:String, vars:String, centerPos:Array<Float>, circleConfig:Array<Float>, clockwise:Bool = true, duration:Float, ease:String, delay:Float) {
			var objectName:Dynamic = tweenVars(tag, vars);
			if(objectName != null) {
				if(centerPos == null) throw "The center point array is empty";
				if(circleConfig == null) throw "The radius and angle array is empty";
				var centerX:Float = centerPos[0];
				var centerY:Float = centerPos[1];
				var radius:Float = circleConfig[0];
				var angle:Float = circleConfig[1];
				PlayState.instance.modchartTweens.set(tag, FlxTween.circularMotion(objectName, centerX, centerY, radius, angle, clockwise, duration, true, {startDelay: delay, ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					},
					onUpdate: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenProgress', [tag]);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenNum", function(tag:String, fromValue:Float, toValue:Float, duration:Float, ease:String, delay:Float, ?updateFunction:String = 'tweenNum') {
			cancelTween(tag);
			function tweenFunction(v:Float) {
				if(updateFunction == null || updateFunction.length <= 0)
					updateFunction = 'tweenNum';

				PlayState.instance.callOnLuas(updateFunction, [tag, v]); 
			}
			PlayState.instance.modchartTweens.set(tag, FlxTween.num(fromValue, toValue, duration, {startDelay: delay, ease: getFlxEaseByString(ease),
				onComplete: function(twn:FlxTween) {
					PlayState.instance.modchartTweens.remove(tag);
					PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
				},
				onUpdate: function(twn:FlxTween) {
					PlayState.instance.callOnLuas('onTweenProgress', [tag]);
				}}, tweenFunction)
			);
		});


		// Strums Tweens

		Lua_helper.add_callback(lua, "noteTweenX", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String, delay:Float) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var theNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(theNote != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(theNote, {x: value}, duration, {startDelay: delay, ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					},
					onUpdate: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenProgress', [tag]);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenY", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String, delay:Float) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var theNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(theNote != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(theNote, {y: value}, duration, {startDelay: delay, ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					},
					onUpdate: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenProgress', [tag]);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenAngle", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String, delay:Float) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var theNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(theNote != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(theNote, {angle: value}, duration, {startDelay: delay, ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					},
					onUpdate: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenProgress', [tag]);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenAlpha", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String, delay:Float) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var testicle:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(testicle != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(testicle, {alpha: value}, duration, {startDelay: delay, ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					},
					onUpdate: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenProgress', [tag]);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenDirection", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String, delay:Float) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var theNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(theNote != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(theNote, {direction: value}, duration, {startDelay: delay, ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					},
					onUpdate: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenProgress', [tag]);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenScaleX", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String, delay:Float) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var theNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(theNote != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(theNote.scale, {x: value}, duration, {startDelay: delay, ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					},
					onUpdate: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenProgress', [tag]);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenScaleY", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String, delay:Float) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var theNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(theNote != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(theNote.scale, {y: value}, duration, {startDelay: delay, ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					},
					onUpdate: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenProgress', [tag]);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenLinear", function(tag:String, note:Int, toX:Float, toY:Float, duration:Float, ease:String, delay:Float) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var theNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];
			var fromX:Float = theNote.x;
			var fromY:Float = theNote.y;

			if(theNote != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.linearMotion(theNote, fromX, fromY, toX, toY, duration, true, {startDelay: delay, ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					},
					onUpdate: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenProgress', [tag]);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenPath", function(tag:String, note:Int, points:Array<Array<Float>>, duration:Float, ease:String, delay:Float) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var theNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];
			if(theNote != null) {
				if(points.length < 1) throw "The points array must have at least 1 additional element";
				var allPoints:Array<FlxPoint> = [];
				allPoints.push(new FlxPoint(theNote.x, theNote.y));
				for (i in 0...points.length) {
					var subArray = points[i];
					if (subArray.length < 2) throw "the subArray must have 2 valid values";
					var x:Float = 0;
					var y:Float = 0;
					x = subArray[0];
					y = subArray[1];	
					allPoints.push(new FlxPoint(x, y));
				}
				PlayState.instance.modchartTweens.set(tag, FlxTween.linearPath(theNote, allPoints, duration, true, {startDelay: delay, ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					},
					onUpdate: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenProgress', [tag]);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenCurve", function(tag:String, note:Int, controlPos:Array<Float>, toPos:Array<Float>, duration:Float, ease:String, delay:Float) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var theNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];
			if(controlPos == null) throw "The curve control point array is empty";
			if(toPos == null) throw "The target position array is empty";
			var fromX:Float = theNote.x;
			var fromY:Float = theNote.y;
			var controlX:Float = controlPos[0];
			var controlY:Float = controlPos[1];
			var toX:Float = toPos[0];
			var toY:Float = toPos[1];
			if(theNote != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.quadMotion(theNote, fromX, fromY, controlX, controlY, toX, toY, duration, true, {startDelay: delay, ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					},
					onUpdate: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenProgress', [tag]);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenCurvePath", function(tag:String, note:Int, points:Array<Array<Float>>, duration:Float, ease:String, delay:Float) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var theNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];
			if(theNote != null) {
				if(points.length < 2) throw "The points array must have at least 2 additional element";
				if(points.length % 2 != 0) throw "The points array must have an even number of elements";
				var allPoints:Array<FlxPoint> = [];
				allPoints.push(new FlxPoint(theNote.x, theNote.y));
				for (subArray in points) {
					if (subArray.length < 2) throw "the subArray must have 2 valid values";
					var x:Float = 2;
					var y:Float = 2;
					if ((points.indexOf(subArray) + 1) % 2 == 1) { 	// This is to prevent sudden crashes that close the game
						if (subArray[0] != 0) x = subArray[0]; 
						if (subArray[1] != 0) y = subArray[1]; 
					} else {
						x = subArray[0]; 
						y = subArray[1];
					}
					allPoints.push(new FlxPoint(x, y));
				}
				PlayState.instance.modchartTweens.set(tag, FlxTween.quadPath(theNote, allPoints, duration, true, {startDelay: delay, ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					},
					onUpdate: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenProgress', [tag]);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenCircle", function(tag:String, note:Int, centerPos:Array<Float>, circleConfig:Array<Float>, clockwise:Bool = true, duration:Float, ease:String, delay:Float) {
			cancelTween(tag);
			if(note < 0) note = 0;
			if(centerPos == null) throw "The center point array is empty";
			if(circleConfig == null) throw "The center point array is empty";
			var theNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];
			var centerX:Float = centerPos[0];
			var centerY:Float = centerPos[1];
			var radius:Float = circleConfig[0];
			var angle:Float = circleConfig[1];

			if(theNote != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.circularMotion(theNote, centerX, centerY, radius, angle, clockwise, duration, true, {startDelay: delay, ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					},
					onUpdate: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenProgress', [tag]);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "cancelTween", function(tag:String) {
			cancelTween(tag);
		});


		// Flickers

		Lua_helper.add_callback(lua, "startFlicker", function(tag:String, vars:String, duration:Float, interval:Float, ?endVisibility:Bool = true) {
			var objectName:Dynamic = flickVars(tag, vars);
			if(objectName != null) {
				PlayState.instance.modchartFlickers.set(tag, FlxFlicker.flicker(objectName, duration, interval, endVisibility, false, 
					function(flick:FlxFlicker) {
						PlayState.instance.modchartFlickers.remove(tag);
						PlayState.instance.callOnLuas('onFlickerCompleted', [tag]);
					},
					function(flick:FlxFlicker) {
						PlayState.instance.callOnLuas('onFlickerProgress', [tag]);
					}
				));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "cancelFlicker", function(tag:String) {
			cancelFlicker(tag);
		});


		// Timers

		Lua_helper.add_callback(lua, "runTimer", function(tag:String, time:Float = 1, loops:Int = 1) {
			cancelTimer(tag);
			PlayState.instance.modchartTimers.set(tag, new FlxTimer().start(time, function(tmr:FlxTimer) {
				if(tmr.finished) {
					PlayState.instance.modchartTimers.remove(tag);
				}
				PlayState.instance.callOnLuas('onTimerCompleted', [tag, tmr.loops, tmr.loopsLeft]);
			}, loops));
		});
		Lua_helper.add_callback(lua, "cancelTimer", function(tag:String) {
			cancelTimer(tag);
		});


		// Lua Characters

		Lua_helper.add_callback(lua, "makeLuaCharacter", function(tag:String, char:String, x:Float, y:Float, player:Bool = false, arrows:Array<String>) {
			resetLuaChar(tag);
			var luaChar:LuaChar = new LuaChar(x, y, char, player, arrows);
			luaChar.x += luaChar.positionArray[0];
			luaChar.y += luaChar.positionArray[1];
			PlayState.instance.startCharacterLua(luaChar.curCharacter);
			PlayState.instance.luaCharsMap.set(tag, luaChar);
			getInstance().add(luaChar);
		});
		Lua_helper.add_callback(lua, "changeLuaCharArrow", function(tag:String, arrows:Array<String>, ?reset:Bool = false) {
			if(PlayState.instance.luaCharsMap.exists(tag)) {
				var luaChar:LuaChar = PlayState.instance.luaCharsMap.get(tag);
				luaChar.changeArrows(arrows, reset);
			} else {
				luaTrace("The character " + tag + " doesn't exist!", false, false, FlxColor.RED);	
			}
		});
		Lua_helper.add_callback(lua, "setLuaCharHeyAnim", function(tag:String, hey:Bool = false) {
			if(PlayState.instance.luaCharsMap.exists(tag)) {
				var luaChar:LuaChar = PlayState.instance.luaCharsMap.get(tag);
				luaChar.luaCharHey = hey;
			} else {
				luaTrace("The character " + tag + " doesn't exist!", false, false, FlxColor.RED);	
			}
		});
		Lua_helper.add_callback(lua, "luacharPlayAnim", function(tag:String, anim:String, ?forced:Bool = false) {
			if(PlayState.instance.luaCharsMap.exists(tag)) {
				var luaChar:LuaChar = PlayState.instance.luaCharsMap.get(tag);
				if(luaChar.animOffsets.exists(anim)) luaChar.playAnim(anim, forced);
			} else {
				luaTrace("The character " + tag + " doesn't exist!", false, false, FlxColor.RED);	
			}
		});
		Lua_helper.add_callback(lua, "getLuaCharacterX", function(tag:String) {
			var luaChar:LuaChar = PlayState.instance.luaCharsMap.get(tag);
			if(luaChar != null) return luaChar.x;
			return PlayState.instance.boyfriendGroup.x;
		});
		Lua_helper.add_callback(lua, "setLuaCharacterX", function(tag:String, value:Float) {
			var luaChar:LuaChar = PlayState.instance.luaCharsMap.get(tag);
			if(luaChar != null) luaChar.x = value;
		});
		Lua_helper.add_callback(lua, "getLuaCharacterY", function(tag:String) {
			var luaChar:LuaChar = PlayState.instance.luaCharsMap.get(tag);
			if(luaChar != null) return luaChar.y;
			return PlayState.instance.boyfriendGroup.y;
		});
		Lua_helper.add_callback(lua, "setLuaCharacterY", function(tag:String, value:Float) {
			var luaChar:LuaChar = PlayState.instance.luaCharsMap.get(tag);
			if(luaChar != null) luaChar.y = value;
		});
		Lua_helper.add_callback(lua, "luaCharDance", function(tag:String) {
			if(PlayState.instance.luaCharsMap.exists(tag)) {
				var luaChar:LuaChar = PlayState.instance.luaCharsMap.get(tag);
				luaChar.dance();
			} else {
				luaTrace("The character " + tag + " doesn't exist!", false, false, FlxColor.RED);	
			}
		});
		Lua_helper.add_callback(lua, "changeLuaCharacter", function(tag:String, newCharacter:String) {
			if(PlayState.instance.luaCharsMap.exists(tag)) {
				var oldChar:LuaChar = PlayState.instance.luaCharsMap.get(tag);
				var lastAlpha:Float = oldChar.alpha;
				var lastVisible:Bool = oldChar.visible;

				if(oldChar.curCharacter != newCharacter) {
					var newChar:LuaChar = new LuaChar(oldChar.x, oldChar.y, newCharacter, oldChar.isPlayer, oldChar.arrowArray);
					PlayState.instance.luaCharsMap.set(newCharacter, newChar);
					newChar.x += newChar.positionArray[0];
					newChar.y += newChar.positionArray[1];
					newChar.alpha = 0.00001;
					PlayState.instance.startCharacterLua(newChar.curCharacter);
				}

				oldChar.alpha = 0.00001;
				oldChar = PlayState.instance.luaCharsMap.get(newCharacter);
				PlayState.instance.luaCharsMap.remove(newCharacter);
				oldChar.alpha = lastAlpha;
				oldChar.visible = lastVisible;
			} else {
				luaTrace("The character " + tag + " doesn't exist!", false, false, FlxColor.RED);	
			}
		});
		Lua_helper.add_callback(lua, "removeLuaCharacter", function(tag:String) {
			resetLuaChar(tag);
		});


		// Default Characters

		Lua_helper.add_callback(lua, "changeCharacter", function(type:String, newCharacter:String) {
			var charType:Int = 0;
			switch(type.toLowerCase()) {
				case 'bf' | 'boyfriend': charType = 0;
				case 'dad' | 'opponent': charType = 1;
				case 'gf' | 'girlfriend': charType = 2;
			}
			switch(charType) {
				case 0:
					if(PlayState.instance.boyfriend.curCharacter != newCharacter) {
						if(!PlayState.instance.boyfriendMap.exists(newCharacter)) {
							PlayState.instance.addCharacterToList(newCharacter, charType);
						}
						var lastAlpha:Float = PlayState.instance.boyfriend.alpha;
						PlayState.instance.boyfriend.alpha = 0.00001;
						PlayState.instance.boyfriend = PlayState.instance.boyfriendMap.get(newCharacter);
						PlayState.instance.boyfriend.alpha = lastAlpha;
						PlayState.instance.iconP1.changeIcon(PlayState.instance.boyfriend.healthIcon);
					}
					set('boyfriendName', PlayState.instance.boyfriend.curCharacter);
				case 1:
					if(PlayState.instance.dad.curCharacter != newCharacter) {
						if(!PlayState.instance.dadMap.exists(newCharacter)) {
							PlayState.instance.addCharacterToList(newCharacter, charType);
						}
						var wasGf:Bool = PlayState.instance.dad.curCharacter.startsWith('gf');
						var lastAlpha:Float = PlayState.instance.dad.alpha;
						PlayState.instance.dad.alpha = 0.00001;
						PlayState.instance.dad = PlayState.instance.dadMap.get(newCharacter);
						if(!PlayState.instance.dad.curCharacter.startsWith('gf')) {
							if(wasGf && PlayState.instance.gf != null) {
								PlayState.instance.gf.visible = true;
							}
						} else if(PlayState.instance.gf != null) {
							PlayState.instance.gf.visible = false;
						}
						PlayState.instance.dad.alpha = lastAlpha;
						PlayState.instance.iconP2.changeIcon(PlayState.instance.dad.healthIcon);
					}
					set('dadName', PlayState.instance.dad.curCharacter);
				case 2:
					if(PlayState.instance.gf != null) {
						if(PlayState.instance.gf.curCharacter != newCharacter) {
							if(!PlayState.instance.gfMap.exists(newCharacter)) {
								PlayState.instance.addCharacterToList(newCharacter, charType);
							}
							var lastAlpha:Float = PlayState.instance.gf.alpha;
							PlayState.instance.gf.alpha = 0.00001;
							PlayState.instance.gf = PlayState.instance.gfMap.get(newCharacter);
							PlayState.instance.gf.alpha = lastAlpha;
						}
						set('gfName', PlayState.instance.gf.curCharacter);
					}
			}
		});
		Lua_helper.add_callback(lua, "characterDance", function(type:String) {
			switch(type.toLowerCase()) {
				case 'dad' | 'opponent': PlayState.instance.dad.dance();
				case 'gf' | 'girlfriend': if(PlayState.instance.gf != null) PlayState.instance.gf.dance();
				default: PlayState.instance.boyfriend.dance();
			}
		});
		Lua_helper.add_callback(lua, "setGfSpeed", function(speed:Float) {
			var newSpeed:Int = Std.int(speed);
			if(Math.isNaN(newSpeed) || newSpeed < 1) newSpeed = 1;
			PlayState.instance.gfSpeed = newSpeed;
		});
		Lua_helper.add_callback(lua, "getCharacterX", function(type:String) {
			switch(type.toLowerCase()) {
				case 'dad' | 'opponent':
					return PlayState.instance.dadGroup.x;
				case 'gf' | 'girlfriend':
					return PlayState.instance.gfGroup.x;
				default:
					return PlayState.instance.boyfriendGroup.x;
			}
		});
		Lua_helper.add_callback(lua, "setCharacterX", function(type:String, value:Float) {
			switch(type.toLowerCase()) {
				case 'dad' | 'opponent':
					PlayState.instance.dadGroup.x = value;
				case 'gf' | 'girlfriend':
					PlayState.instance.gfGroup.x = value;
				default:
					PlayState.instance.boyfriendGroup.x = value;
			}
		});
		Lua_helper.add_callback(lua, "getCharacterY", function(type:String) {
			switch(type.toLowerCase()) {
				case 'dad' | 'opponent':
					return PlayState.instance.dadGroup.y;
				case 'gf' | 'girlfriend':
					return PlayState.instance.gfGroup.y;
				default:
					return PlayState.instance.boyfriendGroup.y;
			}
		});
		Lua_helper.add_callback(lua, "setCharacterY", function(type:String, value:Float) {
			switch(type.toLowerCase()) {
				case 'dad' | 'opponent':
					PlayState.instance.dadGroup.y = value;
				case 'gf' | 'girlfriend':
					PlayState.instance.gfGroup.y = value;
				default:
					PlayState.instance.boyfriendGroup.y = value;
			}
		});


		// Lua Bars

		Lua_helper.add_callback(lua, "makeLuaBar", function(tag:String, x:Float, y:Float, width:Float, height:Float, min:Float = 0, max:Float = 1) {
			tag = tag.replace('.', '');
			luaBarRemove(tag);
			if(min < 0) min = 0;
			if(max <= min) max = min + 1;
			var theBar:FlxBar = new FlxBar(x, y, LEFT_TO_RIGHT, Std.int(width), Std.int(height));
			theBar.setRange(min, max);
			theBar.value = 0;
			PlayState.instance.modchartBars.set(tag, theBar);
		});
		Lua_helper.add_callback(lua, "setLuaBarColors", function(tag:String, empty:Array<String>, fill:Array<String>, chunkSize:Int = 1, rotation:Int = 0, showBorder:Bool = false, border:String = 'FF000000') {
			if(PlayState.instance.modchartBars.exists(tag)) {
				var luaBar:FlxBar = PlayState.instance.modchartBars.get(tag);
				var colorEmpty:Array<Int> = [];
				for(color1 in empty) {
					colorEmpty.push(returnColor(color1));
				}
				var colorFill:Array<Int> = [];
				for(color2 in fill) {
					colorFill.push(returnColor(color2));
				}
				var borderColor:Int = Std.parseInt(border);
				luaBar.createGradientBar(colorEmpty, colorFill, chunkSize, rotation, showBorder, returnColor(border));
			} else
				luaTrace("Lua Bar " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "setLuaBarSprites", function(tag:String, emptyImage:String, fillImage:String) {
			if(PlayState.instance.modchartBars.exists(tag)) {
				var luaBar:FlxBar = PlayState.instance.modchartBars.get(tag);
				luaBar.createImageBar(Paths.image(emptyImage), Paths.image(fillImage), FlxColor.GREEN, FlxColor.LIME);
			} else
				luaTrace("Lua Bar " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "setLuaBarRange", function(tag:String, min:Float = 0, max:Float = 1) {
			if(PlayState.instance.modchartBars.exists(tag)) {
				if(min < 0) min = 0;
				if(max <= min) max = min + 1;
				PlayState.instance.modchartBars.get(tag).setRange(min, max);
			} else
				luaTrace("Lua Bar " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "setLuaBarDirection", function(tag:String, direction:String) {
			if(PlayState.instance.modchartBars.exists(tag)) {
				var luaBar:FlxBar = PlayState.instance.modchartBars.get(tag);
				luaBar.fillDirection = getDirectionByString(direction);
			} else
				luaTrace("Lua Bar " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "setLuaBarDivisions", function(tag:String, number:Int = 100) {
			if(PlayState.instance.modchartBars.exists(tag)) {
				var luaBar:FlxBar = PlayState.instance.modchartBars.get(tag);
				luaBar.numDivisions = number;
			} else
				luaTrace("Lua Bar " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "addLuaBarValue", function(tag:String, number:Float) {
			if(PlayState.instance.modchartBars.exists(tag)) {
				var luaBar:FlxBar = PlayState.instance.modchartBars.get(tag);
				luaBar.value += number;
			} else
				luaTrace("Lua Bar " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "drainLuaBarValue", function(tag:String, number:Float) {
			if(PlayState.instance.modchartBars.exists(tag)) {
				var luaBar:FlxBar = PlayState.instance.modchartBars.get(tag);
				luaBar.value -= number;
			} else
				luaTrace("Lua Bar " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "setLuaBarValue", function(tag:String, target:Float) {
			if(PlayState.instance.modchartBars.exists(tag)) {
				var luaBar:FlxBar = PlayState.instance.modchartBars.get(tag);
				luaBar.value = target;
			} else
				luaTrace("Lua Bar " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "setLuaBarCallback", function(tag:String, type:String, ?callBack:Array<String>, ?kill:Bool = false) {
			if(PlayState.instance.modchartBars.exists(tag)) {
				var luaBar:FlxBar = PlayState.instance.modchartBars.get(tag);
				function barCallbackA():Void {
					if(callBack.length > 0) {
						var callBackA = callBack[0].trim();
						if(callBackA.length > 0) PlayState.instance.callOnLuas(callBackA, [tag]);
					} else PlayState.instance.callOnLuas('onBarCompleted', [tag]);
				}
				function barCallbackB():Void {
					if(callBack.length > 1) {
						var callBackB = callBack[1].trim();
						if(callBackB.length > 0) PlayState.instance.callOnLuas(callBackB, [tag]);
					} else PlayState.instance.callOnLuas('onBarCompleted', [tag]);
				}
				switch (type.trim().toLowerCase()) {
					case 'empty':
						luaBar.setCallbacks(barCallbackA, null, kill);
					case 'fill':
						luaBar.setCallbacks(null, barCallbackA, kill);
					case 'dual':
						luaBar.setCallbacks(barCallbackA, barCallbackB, kill);
					default:
						luaBar.setCallbacks(null, null);
				}
			} else
				luaTrace("Lua Bar " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "getLuaBarPercent", function(tag:String) {
			if(PlayState.instance.modchartBars.exists(tag))
				return PlayState.instance.modchartBars.get(tag).percent;
			else
				luaTrace("Lua Bar " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return 0;
		});
		/*	Revisar!!!!!!!!
		Lua_helper.add_callback(lua, "setLuaBarParent", function(tag:String, parentRef:String, variable:String = "") {
			if(PlayState.instance.modchartBars.exists(tag)) {
				var luaBar:FlxBar = PlayState.instance.modchartBars.get(tag);
				var varValue:Array<String> = parentRef.split('.');
				if(varValue.length > 1)
					parentRef = getVarInArray(getPropertyLoop(varValue,true,true,true), varValue[varValue.length-1]);
				if (parentRef != null) {
					luaBar.parent = parentRef;
					luaBar.parentVariable = variable;
				}
			} else {
				luaTrace("Lua Bar " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});			*/
		Lua_helper.add_callback(lua, "addLuaBar", function(tag:String) {
			if(PlayState.instance.modchartBars.exists(tag)) {
				var luaBar:FlxBar = PlayState.instance.modchartBars.get(tag);
				getInstance().add(luaBar);
			} else
				luaTrace("Lua Bar " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "removeLuaBar", function(tag:String) {
			if(!PlayState.instance.modchartBars.exists(tag)) return;
			var luaBar:FlxBar = PlayState.instance.modchartBars.get(tag);
			luaBar.kill();
			getInstance().remove(luaBar, true);
			luaBar.destroy();
			PlayState.instance.modchartBars.remove(tag);
		});


		// Lua Emitters

		Lua_helper.add_callback(lua, "makeParticlesEmitter", function(tag:String, x:Float, y:Float, amount:Int) {
			resetEmitter(tag);
			var emitter:FlxEmitter = new FlxEmitter(x, y, amount);
			PlayState.instance.modchartEmitters.set(tag, emitter);
		});
		Lua_helper.add_callback(lua, "loadEmitterGraphic", function(tag:String, width:Float, height:Float, color:String, quantity:Int = 1) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				emitter.makeParticles(Std.int(width), Std.int(height), returnColor(color), quantity);
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "loadEmitterSprite", function(tag:String, image:String, quantity:Int = 50, rotations:Int = 16, ?multiply:Bool = false, ?buff:Bool = false) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				emitter.loadParticles(Paths.image(image), quantity, rotations, multiply, buff);
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "makeEmitterSprite", function(tag:String, image:String, quantity:Int = 1, ?areaEffect:String = null) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var trailArea:FlxTrailArea = new FlxTrailArea();
				var areaExists:Bool = false;
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				if(quantity <= 0) quantity = 1;
				if(areaEffect != null && areaEffect != '') {
					if(PlayState.instance.modchartTrailAreas.exists(areaEffect)) {
						trailArea = PlayState.instance.modchartTrailAreas.get(areaEffect);
						areaExists = true;
					}
				}
				for(i in 0...quantity) {
					var particle = new FlxParticle();
					particle.loadGraphic(Paths.image(image));
					particle.exists = false;
					emitter.add(particle);
				 	if(areaExists) trailArea.add(particle);
				}
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "makeEmitterAnimatedSprite", function(tag:String, image:String, prefix:String, framerate:Int = 24, loop:Bool = true, quantity:Int = 1, ?areaEffect:String = null) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var trailArea:FlxTrailArea = new FlxTrailArea();
				var areaExists = false;
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				if(quantity <= 0) quantity = 1;
				if(areaEffect != null && areaEffect != '') {
					if(PlayState.instance.modchartTrailAreas.exists(areaEffect)) {
						trailArea = PlayState.instance.modchartTrailAreas.get(areaEffect);
						areaExists = true;
					}
				}
				for (i in 0...quantity) {
					var particle = new FlxParticle();
					particle.loadGraphic(Paths.image(image));
					particle.animation.addByPrefix('startAnim', prefix, framerate, loop);
					particle.animation.play('startAnim');
					emitter.add(particle);
					if(areaExists) trailArea.add(particle);
				}
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "addEmitter", function(tag:String) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				getInstance().add(emitter);
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "startEmitter", function(tag:String, explode:Bool = false, frequency:Float = 0.1, quantity:Int = 0) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				emitter.start(explode, frequency, quantity);
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "emitParticle", function(tag:String) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				emitter.emitParticle();
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "toggleEmitting", function(tag:String, toggle:Bool = true) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				emitter.emitting = toggle;
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "removeEmitter", function(tag:String, ?destroy:Bool = true) {
			if(!PlayState.instance.modchartEmitters.exists(tag)) return;
			var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
			if(destroy) emitter.kill();
			getInstance().remove(emitter, true);
			if(destroy) {
				emitter.destroy();
				PlayState.instance.modchartEmitters.remove(tag);
			}
		});


		// Emitters Assets

		Lua_helper.add_callback(lua, "setLaunchMode", function(tag:String, type:String) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				emitter.launchMode = getLaunchType(type);
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "setLaunchAngle", function(tag:String, min:Float, max:Float) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				// Only CIRCLE emitter mode
				emitter.launchAngle.set(min, max);
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "setEmitterFrequency", function(tag:String, value:Float) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				emitter.frequency = value;
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "setEmitterPosition", function(tag:String, posX:Float, posY:Float) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				emitter.setPosition(posX, posY);
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "setEmitterSize", function(tag:String, sizeX:Float, sizeY:Float) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				emitter.setSize(sizeX, sizeY);
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "setEmitterVelocity", function(tag:String, startMinXY:Array<Float>, ?startMaxXY:Array<Float>, ?endMinXY:Array<Float>, ?endMaxXY:Array<Float>) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				// Only SQUARE emitter mode
				if(emitter.launchMode == SQUARE) {
					var startMinX:Float = startMinXY[0];
					var startMinY:Float = startMinXY[1];
					if(startMaxXY != null){
						var startMaxX:Float = startMaxXY[0];
						var startMaxY:Float = startMaxXY[1];
						if(endMinXY != null) {
							var endMinX:Float = endMinXY[0];
							var endMinY:Float = endMinXY[1];
							if(endMaxXY != null){
								var endMaxX:Float = endMaxXY[0];
								var endMaxY:Float = endMaxXY[1];	
								emitter.velocity.set(startMinX, startMinY, startMaxX, startMaxY, endMinX, endMinY, endMaxX, endMaxY);
								return true;
							}
							emitter.velocity.set(startMinX, startMinY, startMaxX, startMaxY, endMinX, endMinY);
							return true;
						}
						emitter.velocity.set(startMinX, startMinY, startMaxX, startMaxY);
						return true;
					}
					emitter.velocity.set(startMinX, startMinY);
					return true;
				}
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setEmitterSpeed", function(tag:String, startXY:Array<Float>, ?endXY:Array<Float>) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				// Only CIRCLE emitter mode
				if(emitter.launchMode == CIRCLE) {
					var startMin:Float = startXY[0];
					var startMax:Float = startXY[1];
					if(endXY != null) {
						var endMin:Float = endXY[0];
						var endMax:Float = endXY[1];
						
						emitter.speed.set(startMin, startMax, endMin, endMax);
						return true;
					}
					emitter.speed.set(startMin, startMax);
					return true;
				}
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setAngularAcceleration", function(tag:String, startXY:Array<Float>, ?endXY:Array<Float>) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				var startMin:Float = startXY[0];
				var startMax:Float = startXY[1];
				if(endXY != null) {
					var endMin:Float = endXY[0];
					var endMax:Float = endXY[1];
					emitter.angularAcceleration.set(startMin, startMax, endMin, endMax);
					return true;
				}
				emitter.angularAcceleration.set(startMin, startMax);
				return true;
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setAngularDrag", function(tag:String, startXY:Array<Float>, ?endXY:Array<Float>) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				var startMin:Float = startXY[0];
				var startMax:Float = startXY[1];
				if(endXY != null) {
					var endMin:Float = endXY[0];
					var endMax:Float = endXY[1];
					emitter.angularDrag.set(startMin, startMax, endMin, endMax);
					return true;
				}
				emitter.angularDrag.set(startMin, startMax);
				return true;
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setAngularVelocity", function(tag:String, startXY:Array<Float>, ?endXY:Array<Float>) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				var startMin:Float = startXY[0];
				var startMax:Float = startXY[1];
				if(endXY != null) {
					var endMin:Float = endXY[0];
					var endMax:Float = endXY[1];
					emitter.angularVelocity.set(startMin, startMax, endMin, endMax);
					return true;
				}
				emitter.angularVelocity.set(startMin, startMax);
				return true;
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "keepScaleRatio", function(tag:String, value:Bool = false) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				emitter.keepScaleRatio = value;
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "ignoreAngularVelocity", function(tag:String, value:Bool = false) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				emitter.ignoreAngularVelocity = value;
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});


		// Particles Assets

		Lua_helper.add_callback(lua, "setParticleBlend", function(tag:String, blend:String) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				emitter.blend = blendModeFromString(blend);
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "setParticleLife", function(tag:String, min:Float, ?max:Float = null) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				emitter.lifespan.set(min, max);
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "setParticleAngle", function(tag:String, startXY:Array<Float>, ?endXY:Array<Float>) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				var startMin:Float = startXY[0];
				var startMax:Float = startXY[1];
				if(endXY != null) {
					var endMin:Float = endXY[0];
					var endMax:Float = endXY[1];
					emitter.angle.set(startMin, startMax, endMin, endMax);
					return true;
				}
				emitter.angle.set(startMin, startMax);
				return true;
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setParticleScale", function(tag:String, startMinXY:Array<Float>, ?startMaxXY:Array<Float>, ?endMinXY:Array<Float>, ?endMaxXY:Array<Float>) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				var startMinX:Float = startMinXY[0];
				var startMinY:Float = startMinXY[1];
				if(startMaxXY != null){
					var startMaxX:Float = startMaxXY[0];
					var startMaxY:Float = startMaxXY[1];
					if(endMinXY != null) {
						var endMinX:Float = endMinXY[0];
						var endMinY:Float = endMinXY[1];
						if(endMaxXY != null){
							var endMaxX:Float = endMaxXY[0];
							var endMaxY:Float = endMaxXY[1];	
							emitter.scale.set(startMinX, startMinY, startMaxX, startMaxY, endMinX, endMinY, endMaxX, endMaxY);
							return true;
						}
						emitter.scale.set(startMinX, startMinY, startMaxX, startMaxY, endMinX, endMinY);
						return true;
					}
					emitter.scale.set(startMinX, startMinY, startMaxX, startMaxY);
					return true;
				}
				emitter.scale.set(startMinX, startMinY);
				return true;
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setParticleAlpha", function(tag:String, startXY:Array<Float>, ?endXY:Array<Float>) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				var startMin:Float = startXY[0];
				var startMax:Float = startXY[1];
				if(endXY != null) {
					var endMin:Float = endXY[0];
					var endMax:Float = endXY[1];
					emitter.alpha.set(startMin, startMax, endMin, endMax);
					return true;
				}
				emitter.alpha.set(startMin, startMax);
				return true;
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setParticleColor", function(tag:String, color1:String = '0xFFFFFFFF', ?color2:String = null, ?color3:String = null, ?color4:String = null) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				if(color2 != null) {
					if(color3 != null) {
						if(color4 != null) {
							emitter.color.set(returnColor(color1), returnColor(color2), returnColor(color3), returnColor(color4));
							return true;
						}
						emitter.color.set(returnColor(color1), returnColor(color2), returnColor(color3));
						return true;
					}
					emitter.color.set(returnColor(color1), returnColor(color2));
					return true;
				}
				emitter.color.set(returnColor(color1));
				return true;
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setParticleDrag", function(tag:String, startMinXY:Array<Float>, ?startMaxXY:Array<Float>, ?endMinXY:Array<Float>, ?endMaxXY:Array<Float>) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				var startMinX:Float = startMinXY[0];
				var startMinY:Float = startMinXY[1];
				if(startMaxXY != null){
					var startMaxX:Float = startMaxXY[0];
					var startMaxY:Float = startMaxXY[1];
					if(endMinXY != null) {
						var endMinX:Float = endMinXY[0];
						var endMinY:Float = endMinXY[1];
						if(endMaxXY != null){
							var endMaxX:Float = endMaxXY[0];
							var endMaxY:Float = endMaxXY[1];	
							emitter.drag.set(startMinX, startMinY, startMaxX, startMaxY, endMinX, endMinY, endMaxX, endMaxY);
							return true;
						}
						emitter.drag.set(startMinX, startMinY, startMaxX, startMaxY, endMinX, endMinY);
						return true;
					}
					emitter.drag.set(startMinX, startMinY, startMaxX, startMaxY);
					return true;
				}
				emitter.drag.set(startMinX, startMinY);
				return true;
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setParticleGravity", function(tag:String, startMinXY:Array<Float>, ?startMaxXY:Array<Float>, ?endMinXY:Array<Float>, ?endMaxXY:Array<Float>) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				var startMinX:Float = startMinXY[0];
				var startMinY:Float = startMinXY[1];
				if(startMaxXY != null){
					var startMaxX:Float = startMaxXY[0];
					var startMaxY:Float = startMaxXY[1];
					if(endMinXY != null) {
						var endMinX:Float = endMinXY[0];
						var endMinY:Float = endMinXY[1];
						if(endMaxXY != null){
							var endMaxX:Float = endMaxXY[0];
							var endMaxY:Float = endMaxXY[1];	
							emitter.acceleration.set(startMinX, startMinY, startMaxX, startMaxY, endMinX, endMinY, endMaxX, endMaxY);
							return true;
						}
						emitter.acceleration.set(startMinX, startMinY, startMaxX, startMaxY, endMinX, endMinY);
						return true;
					}
					emitter.acceleration.set(startMinX, startMinY, startMaxX, startMaxY);
					return true;
				}
				emitter.acceleration.set(startMinX, startMinY);
				return true;
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setParticleAutoUpdateHitbox", function(tag:String, value:Bool = false) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				emitter.autoUpdateHitbox = value;
			} else
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		// Futuramente farei colisões.. de alguma forma
		/*
		Lua_helper.add_callback(lua, "setParticleElasticity", function(tag:String, startXY:Array<Float>, ?endXY:Array<Float>) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				var startMin:Float = startXY[0];
				var startMax:Float = startXY[1];
				if(endXY != null) {
					var endMin:Float = endXY[0];
					var endMax:Float = endXY[1];
					emitter.elasticity.set(startMin, startMax, endMin, endMax);
					return true;
				}
				emitter.elasticity.set(startMin, startMax);
				return true;
			} else {
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "setParticleImmovable", function(tag:String, value:Bool = false) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				emitter.immovable = value;
			} else {
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "setParticleSolid", function(tag:String, value:Bool = false) {
			if(PlayState.instance.modchartEmitters.exists(tag)) {
				var emitter:FlxEmitter = PlayState.instance.modchartEmitters.get(tag);
				emitter.solid = value;
			} else {
				luaTrace("Lua Emitter " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});
		*/

		// Lua Trails

		Lua_helper.add_callback(lua, "makeObjectTrail", function(tag:String, obj:String, graphic:String, length:Int, delay:Int, alpha:Float, diff:Float) {
			trailExists(tag);
			var objSprite = PlayState.instance.getLuaObject(obj, true, true, true);
			if(objSprite != null){
				var trail:FlxTrail = new FlxTrail(objSprite, Paths.image(graphic), length, delay, alpha, diff);
				PlayState.instance.modchartTrails.set(tag, trail);
			} else {
				var theArray:Array<String> = obj.split('.');
				var object:FlxSprite = getObjectDirectly(theArray[0], true, true, true);
				if(theArray.length > 1)
					object = getVarInArray(getPropertyLoop(theArray,true,true,true,true), theArray[theArray.length-1]);

				if(object != null) {
					var trail:FlxTrail = new FlxTrail(object, Paths.image(graphic), length, delay, alpha, diff);
					PlayState.instance.modchartTrails.set(tag, trail);
				} else {
					luaTrace("Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
				}
			}
		});
		Lua_helper.add_callback(lua, "setTrailDelay", function(tag:String, value:Int) {
			if(PlayState.instance.modchartTrails.exists(tag)) {
				var trail:FlxTrail = PlayState.instance.modchartTrails.get(tag);
				trail.delay = value;
			} else {
				luaTrace("Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "changeTrailGraphic", function(tag:String, graphic:String) {
			if(PlayState.instance.modchartTrails.exists(tag)) {
				var trail:FlxTrail = PlayState.instance.modchartTrails.get(tag);
				trail.changeGraphic(Paths.image(graphic));
			} else {
				luaTrace("Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "increaseTrailLength", function(tag:String, value:Int) {
			if(PlayState.instance.modchartTrails.exists(tag)) {
				var trail:FlxTrail = PlayState.instance.modchartTrails.get(tag);
				trail.increaseLength(value);
			} else {
				luaTrace("Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "trailValuesEnabled", function(tag:String, angle:Bool, x:Bool, y:Bool, scale:Bool) {
			if(PlayState.instance.modchartTrails.exists(tag)) {
				var trail:FlxTrail = PlayState.instance.modchartTrails.get(tag);
				trail.changeValuesEnabled(angle, x, y, scale);
			} else {
				luaTrace("Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "resetTrail", function(tag:String) {
			if(PlayState.instance.modchartTrails.exists(tag)) {
				var trail:FlxTrail = PlayState.instance.modchartTrails.get(tag);
				trail.resetTrail();
			} else {
				luaTrace("Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "addTrail", function(tag:String, ?front:Bool = false) {
			if(PlayState.instance.modchartTrails.exists(tag)) {
				var trail:FlxTrail = PlayState.instance.modchartTrails.get(tag);
				if(front) {
					getInstance().add(trail);
				} else {
					if(PlayState.instance.isDead) {
						GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), trail);
					} else {
						var position:Int = PlayState.instance.members.indexOf(PlayState.instance.gfGroup);
						if(PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup) < position) {
							position = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
						} else if(PlayState.instance.members.indexOf(PlayState.instance.dadGroup) < position) {
							position = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
						}
						PlayState.instance.insert(position, trail);
					}
				}
			} else {
				luaTrace("Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "removeTrail", function(tag:String, ?destroy:Bool = true) {
			if(!PlayState.instance.modchartTrails.exists(tag)) {
				return;
			}
			var trail:FlxTrail = PlayState.instance.modchartTrails.get(tag);
			if(destroy) {
				trail.kill();
			}
			getInstance().remove(trail, true);
			if(destroy) {
				trail.destroy();
				PlayState.instance.modchartTrails.remove(tag);
			}
		});


		// Lua Trails Areas
		
		Lua_helper.add_callback(lua, "makeTrailArea", function(tag:String, xy:Array<Int>, size:Array<Int>, alphaMultiplier:Float, delay:Int, simpleRender:Bool = false, antialiasing:Bool = true) {
			trailAreaExists(tag);
			var x:Int = xy[0];
			var y:Int = xy[1];
			var width:Int = size[0];
			var height:Int = size[1];
			var trailArea:FlxTrailArea = new FlxTrailArea(x, y, width, height, alphaMultiplier, delay, simpleRender, antialiasing);
			PlayState.instance.modchartTrailAreas.set(tag, trailArea);
		});
		Lua_helper.add_callback(lua, "setAreaSize", function(tag:String, width:Float, height:Float) {
			if(PlayState.instance.modchartTrailAreas.exists(tag)) {
				var trailArea:FlxTrailArea = PlayState.instance.modchartTrailAreas.get(tag);
				trailArea.setSize(width, height);
			} else {
				luaTrace("Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "setSimpleAreaRender", function(tag:String, toggle:Bool = false) {
			if(PlayState.instance.modchartTrailAreas.exists(tag)) {
				var trailArea:FlxTrailArea = PlayState.instance.modchartTrailAreas.get(tag);
				trailArea.simpleRender = toggle;
			} else {
				luaTrace("Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "setAreaDelay", function(tag:String, value:Int) {
			if(PlayState.instance.modchartTrailAreas.exists(tag)) {
				var trailArea:FlxTrailArea = PlayState.instance.modchartTrailAreas.get(tag);
				trailArea.delay = value;
			} else {
				luaTrace("Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "setAreaMultipliers", function(tag:String, red:Float = 1, green:Float = 1, blue:Float = 1, alpha:Float = 1) {
			if(PlayState.instance.modchartTrailAreas.exists(tag)) {
				var trailArea:FlxTrailArea = PlayState.instance.modchartTrailAreas.get(tag);
				// 0 to 1
				trailArea.redMultiplier = red;
				trailArea.greenMultiplier = green;
				trailArea.blueMultiplier = blue;
				trailArea.alphaMultiplier = alpha;
			} else {
				luaTrace("Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "setAreaOffsets", function(tag:String, red:Float = 0, green:Float = 0, blue:Float = 0, alpha:Float = 0) {
			if(PlayState.instance.modchartTrailAreas.exists(tag)) {
				var trailArea:FlxTrailArea = PlayState.instance.modchartTrailAreas.get(tag);
				// -255 to 255
				trailArea.redOffset = red;
				trailArea.greenOffset = green;
				trailArea.blueOffset = blue;
				trailArea.alphaOffset = alpha;
			} else {
				luaTrace("Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "addSpritesToArea", function(tag:String, objects:Array<String>) {
			if(PlayState.instance.modchartTrailAreas.exists(tag)) {
				var trailArea:FlxTrailArea = PlayState.instance.modchartTrailAreas.get(tag);
				for(obj in objects) {
					var objSprite = PlayState.instance.getLuaObject(obj, true, true, true);
					if(objSprite != null){
						trailArea.add(objSprite);
					} else {
						var theArray:Array<String> = obj.split('.');
						var object:FlxSprite = getObjectDirectly(theArray[0], true, true, true);
						if(theArray.length > 1)
							object = getVarInArray(getPropertyLoop(theArray,true,true,true,true), theArray[theArray.length-1]);

						if(object != null) {
							trailArea.add(object);
						}
					}
				}
			} else {
				luaTrace("Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "resetTrailArea", function(tag:String) {
			if(PlayState.instance.modchartTrailAreas.exists(tag)) {
				var trailArea:FlxTrailArea = PlayState.instance.modchartTrailAreas.get(tag);
				trailArea.resetTrail();
			} else {
				luaTrace("Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "addTrailArea", function(tag:String) {
			if(PlayState.instance.modchartTrailAreas.exists(tag)) {
				var trailArea:FlxTrailArea = PlayState.instance.modchartTrailAreas.get(tag);
				getInstance().add(trailArea);
			} else {
				luaTrace("Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "removeTrailArea", function(tag:String, ?destroy:Bool = true) {
			if(!PlayState.instance.modchartTrailAreas.exists(tag)) {
				return;
			}
			var trailArea:FlxTrailArea = PlayState.instance.modchartTrailAreas.get(tag);
			if(destroy) {
				trailArea.kill();
			}
			getInstance().remove(trailArea, true);
			if(destroy) {
				trailArea.destroy();
				PlayState.instance.modchartTrailAreas.remove(tag);
			}
		});
		#if flash
		Lua_helper.add_callback(lua, "setAreaBlendMode", function(tag:String, blend:String) {
			if(PlayState.instance.modchartTrailAreas.exists(tag)) {
				var trailArea:FlxTrailArea = PlayState.instance.modchartTrailAreas.get(tag);
				trailArea.blendMode = blendModeFromString(blend);
			} else {
				luaTrace("Object " + tag + " doesn't exist!", false, false, FlxColor.RED);
			}
		});
		#end


		// Start Special Objects

		Lua_helper.add_callback(lua, "startDialogue", function(dialogueFile:String, music:String = null) {
			var path:String;
			#if MODS_ALLOWED
			path = Paths.modsJson(Paths.formatToSongPath(PlayState.SONG.song) + '/' + dialogueFile);
			if(!FileSystem.exists(path))
			#end
				path = Paths.json(Paths.formatToSongPath(PlayState.SONG.song) + '/' + dialogueFile);

			luaTrace('Trying to load dialogue: ' + path);

			#if MODS_ALLOWED
			if(FileSystem.exists(path))
			#else
			if(Assets.exists(path))
			#end
			{
				var conversation:DialogueFile = DialogueBoxPsych.parseDialogue(path);
				if(conversation.dialogue.length > 0) {
					PlayState.instance.startDialogue(conversation, music);
					luaTrace('Successfully loaded dialogue', false, false, FlxColor.GREEN);
					return true;
				} else {
					luaTrace('Your dialogue file is badly formatted!', false, false, FlxColor.RED);
				}
			} else {
				luaTrace('Dialogue file not found', false, false, FlxColor.RED);
				if(PlayState.instance.endingSong) {
					PlayState.instance.endSong();
				} else {
					PlayState.instance.startCountdown();
				}
			}
			return false;
		});
		Lua_helper.add_callback(lua, "startVideo", function(videoFile:String) {
			#if VIDEOS_ALLOWED
			if(FileSystem.exists(Paths.video(videoFile))) {
				PlayState.instance.startVideo(videoFile);
				return true;
			} else {
				luaTrace('Video file not found: ' + videoFile, false, false, FlxColor.RED);
			}
			return false;

			#else
			if(PlayState.instance.endingSong) {
				PlayState.instance.endSong();
			} else {
				PlayState.instance.startCountdown();
			}
			return true;
			#end
		});


		// Music and Sounds

		Lua_helper.add_callback(lua, "playMusic", function(sound:String, volume:Float = 1, loop:Bool = false) {
			FlxG.sound.playMusic(Paths.music(sound), volume, loop);
		});
		Lua_helper.add_callback(lua, "playSound", function(sound:String, volume:Float = 1, ?tag:String = null, ?loop:Bool = false) {
			if(tag != null && tag.length > 0) {
				tag = tag.replace('.', '');
				if(PlayState.instance.modchartSounds.exists(tag)) {
					PlayState.instance.modchartSounds.get(tag).stop();
					PlayState.instance.modchartSounds.remove(tag);
				}
				PlayState.instance.modchartSounds.set(tag, FlxG.sound.play(Paths.sound(sound), volume, loop, function() {
					if(!loop) PlayState.instance.modchartSounds.remove(tag);
					PlayState.instance.callOnLuas('onSoundFinished', [tag]);
				}));
				return;
			}
			FlxG.sound.play(Paths.sound(sound), volume, loop);
		});
		Lua_helper.add_callback(lua, "setSoundPosition", function(tag:String, x:Float = 0, y:Float = 0) {
			if(tag != null && tag.length > 1 && PlayState.instance.modchartSounds.exists(tag)) {
				PlayState.instance.modchartSounds.get(tag).setPosition(x, y);
			}
		});
		Lua_helper.add_callback(lua, "setSoundProximity", function(tag:String, x:Float, y:Float, object:String, radius:Float, pan:Bool = true) {
			if(tag != null && tag.length > 1 && PlayState.instance.modchartSounds.exists(tag)) {
				var targetObj:Dynamic;
				var objSprite = PlayState.instance.getLuaObject(object, true, true, true);
				if(objSprite != null){
					targetObj = objSprite;
				} else {
					var theArray:Array<String> = object.split('.');
					var object:FlxSprite = getObjectDirectly(theArray[0], true, true, true);
					if(theArray.length > 1)
						object = getVarInArray(getPropertyLoop(theArray,true,true,true,true), theArray[theArray.length-1]);

					if(object != null) {
						targetObj = object;
					} else {
						targetObj = FlxG.camera;
					}
				}
				PlayState.instance.modchartSounds.get(tag).proximity(x, y, targetObj, radius, pan);
			}
		});
		Lua_helper.add_callback(lua, "pauseSound", function(tag:String) {
			if(tag != null && tag.length > 1 && PlayState.instance.modchartSounds.exists(tag)) {
				PlayState.instance.modchartSounds.get(tag).pause();
			}
		});
		Lua_helper.add_callback(lua, "resumeSound", function(tag:String) {
			if(tag != null && tag.length > 1 && PlayState.instance.modchartSounds.exists(tag)) {
				PlayState.instance.modchartSounds.get(tag).play();
			}
		});
		Lua_helper.add_callback(lua, "stopSound", function(tag:String) {
			if(tag != null && tag.length > 1 && PlayState.instance.modchartSounds.exists(tag)) {
				PlayState.instance.modchartSounds.get(tag).stop();
				PlayState.instance.modchartSounds.remove(tag);
			}
		});
		Lua_helper.add_callback(lua, "soundFadeIn", function(tag:String, duration:Float, fromValue:Float = 0, toValue:Float = 1) {
			if(tag == null || tag.length < 1) {
				FlxG.sound.music.fadeIn(duration, fromValue, toValue);
			} else if(PlayState.instance.modchartSounds.exists(tag)) {
				PlayState.instance.modchartSounds.get(tag).fadeIn(duration, fromValue, toValue);
			}
		});
		Lua_helper.add_callback(lua, "soundFadeOut", function(tag:String, duration:Float, toValue:Float = 0) {
			if(tag == null || tag.length < 1) {
				FlxG.sound.music.fadeOut(duration, toValue);
			} else if(PlayState.instance.modchartSounds.exists(tag)) {
				PlayState.instance.modchartSounds.get(tag).fadeOut(duration, toValue);
			}
		});
		Lua_helper.add_callback(lua, "soundFadeCancel", function(tag:String) {
			if(tag == null || tag.length < 1) {
				if(FlxG.sound.music.fadeTween != null) {
					FlxG.sound.music.fadeTween.cancel();
				}
			} else if(PlayState.instance.modchartSounds.exists(tag)) {
				var theSound:FlxSound = PlayState.instance.modchartSounds.get(tag);
				if(theSound.fadeTween != null) {
					theSound.fadeTween.cancel();
					PlayState.instance.modchartSounds.remove(tag);
				}
			}
		});
		Lua_helper.add_callback(lua, "getSoundVolume", function(tag:String) {
			if(tag == null || tag.length < 1) {
				if(FlxG.sound.music != null) {
					return FlxG.sound.music.volume;
				}
			} else if(PlayState.instance.modchartSounds.exists(tag)) {
				return PlayState.instance.modchartSounds.get(tag).volume;
			}
			return 0;
		});
		Lua_helper.add_callback(lua, "setSoundVolume", function(tag:String, value:Float) {
			if(tag == null || tag.length < 1) {
				if(FlxG.sound.music != null) {
					FlxG.sound.music.volume = value;
				}
			} else if(PlayState.instance.modchartSounds.exists(tag)) {
				PlayState.instance.modchartSounds.get(tag).volume = value;
			}
		});
		Lua_helper.add_callback(lua, "getSoundTime", function(tag:String) {
			if(tag != null && tag.length > 0 && PlayState.instance.modchartSounds.exists(tag)) {
				return PlayState.instance.modchartSounds.get(tag).time;
			}
			return 0;
		});
		Lua_helper.add_callback(lua, "setSoundTime", function(tag:String, value:Float) {
			if(tag != null && tag.length > 0 && PlayState.instance.modchartSounds.exists(tag)) {
				var theSound:FlxSound = PlayState.instance.modchartSounds.get(tag);
				if(theSound != null) {
					var wasResumed:Bool = theSound.playing;
					theSound.pause();
					theSound.time = value;
					if(wasResumed) theSound.play();
				}
			}
		});
		// THIS IS BUGGED, FUNK THIS XEET
		// Lua_helper.add_callback(lua, "getSoundPitch", function(tag:String) {
		// 	if(tag != null && tag.length > 0 && PlayState.instance.modchartSounds.exists(tag)) {
		// 		return PlayState.instance.modchartSounds.get(tag).pitch;
		// 	}
		// 	return 0;
		// });
		// Lua_helper.add_callback(lua, "setSoundPitch", function(tag:String, value:Float) {
		// 	if(tag != null && tag.length > 0 && PlayState.instance.modchartSounds.exists(tag)) {
		// 		var theSound:FlxSound = PlayState.instance.modchartSounds.get(tag);
		// 		if(theSound != null) theSound.pitch = value;
		// 	}
		// });
		Lua_helper.add_callback(lua, "getSoundPan", function(tag:String) {
			if(tag != null && tag.length > 0 && PlayState.instance.modchartSounds.exists(tag)) {
				return PlayState.instance.modchartSounds.get(tag).pan;
			}
			return 0;
		});
		Lua_helper.add_callback(lua, "setSoundPan", function(tag:String, value:Float) {
			if(tag != null && tag.length > 0 && PlayState.instance.modchartSounds.exists(tag)) {
				var theSound:FlxSound = PlayState.instance.modchartSounds.get(tag);
				if(theSound != null) {
					var wasResumed:Bool = theSound.playing;
					theSound.pause();
					theSound.pan = value;
					if(wasResumed) theSound.play();
				}
			}
		});


		// Save Load Archives

		Lua_helper.add_callback(lua, "initSaveData", function(name:String, ?folder:String = 'TrashBaracutaPath') {
			if(!PlayState.instance.modchartSaves.exists(name))
			{
				var save:FlxSave = new FlxSave();
				save.bind(name, folder);
				PlayState.instance.modchartSaves.set(name, save);
				return;
			}
			luaTrace('Save file already initialized: ' + name);
		});
		Lua_helper.add_callback(lua, "flushSaveData", function(name:String) {
			if(PlayState.instance.modchartSaves.exists(name))
			{
				PlayState.instance.modchartSaves.get(name).flush();
				return;
			}
			luaTrace('Save file not initialized: ' + name, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "getDataFromSave", function(name:String, field:String, ?defaultValue:Dynamic = null) {
			if(PlayState.instance.modchartSaves.exists(name))
			{
				var getVal:Dynamic = Reflect.field(PlayState.instance.modchartSaves.get(name).data, field);
				return getVal;
			}
			luaTrace('Save file not initialized: ' + name, false, false, FlxColor.RED);
			return defaultValue;
		});
		Lua_helper.add_callback(lua, "setDataFromSave", function(name:String, field:String, value:Dynamic) {
			if(PlayState.instance.modchartSaves.exists(name))
			{
				Reflect.setField(PlayState.instance.modchartSaves.get(name).data, field, value);
				return;
			}
			luaTrace('Save file not initialized: ' + name, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "checkFileExists", function(filename:String, ?absolute:Bool = false) {
			#if MODS_ALLOWED
			if(absolute)
			{
				return FileSystem.exists(filename);
			}

			var path:String = Paths.modFolders(filename);
			if(FileSystem.exists(path))
			{
				return true;
			}
			return FileSystem.exists(Paths.getPath('assets/$filename', TEXT));
			#else
			if(absolute)
			{
				return Assets.exists(filename);
			}
			return Assets.exists(Paths.getPath('assets/$filename', TEXT));
			#end
		});
		Lua_helper.add_callback(lua, "saveFile", function(path:String, content:String, ?absolute:Bool = false)
		{
			try {
				if(!absolute)
					File.saveContent(Paths.mods(path), content);
				else
					File.saveContent(path, content);

				return true;
			} catch (e:Dynamic) {
				luaTrace("Error trying to save " + path + ": " + e, false, false, FlxColor.RED);
			}
			return false;
		});
		Lua_helper.add_callback(lua, "deleteFile", function(path:String, ?ignoreModFolders:Bool = false)
		{
			try {
				#if MODS_ALLOWED
				if(!ignoreModFolders)
				{
					var lePath:String = Paths.modFolders(path);
					if(FileSystem.exists(lePath))
					{
						FileSystem.deleteFile(lePath);
						return true;
					}
				}
				#end

				var lePath:String = Paths.getPath(path, TEXT);
				if(Assets.exists(lePath))
				{
					FileSystem.deleteFile(lePath);
					return true;
				}
			} catch (e:Dynamic) {
				luaTrace("Error trying to delete " + path + ": " + e, false, false, FlxColor.RED);
			}
			return false;
		});


		// Lua Objects Exists

		Lua_helper.add_callback(lua, "luaSpriteExists", function(tag:String) {
			return PlayState.instance.modchartSprites.exists(tag);
		});
		Lua_helper.add_callback(lua, "luaSkewedSpriteExists", function(tag:String) {
			return PlayState.instance.modchartSkeweds.exists(tag);
		});
		Lua_helper.add_callback(lua, "luaTextExists", function(tag:String) {
			return PlayState.instance.modchartTexts.exists(tag);
		});
		Lua_helper.add_callback(lua, "luaSoundExists", function(tag:String) {
			return PlayState.instance.modchartSounds.exists(tag);
		});
		Lua_helper.add_callback(lua, "luaTimerExists", function(tag:String) {
			return PlayState.instance.modchartTimers.exists(tag);
		});
		Lua_helper.add_callback(lua, "luaTweenExists", function(tag:String) {
			return PlayState.instance.modchartTweens.exists(tag);
		});
		Lua_helper.add_callback(lua, "luaFlickerExists", function(tag:String) {
			return PlayState.instance.modchartFlickers.exists(tag);
		});
		Lua_helper.add_callback(lua, "luaBarExists", function(tag:String) {
			return PlayState.instance.modchartFlickers.exists(tag);
		});
		Lua_helper.add_callback(lua, "luaEmitterExists", function(tag:String) {
			return PlayState.instance.modchartEmitters.exists(tag);
		});
		Lua_helper.add_callback(lua, "luaSavesExists", function(tag:String) {
			return PlayState.instance.modchartSaves.exists(tag);
		});
		Lua_helper.add_callback(lua, "luaCharExists", function(tag:String) {
			return PlayState.instance.luaCharsMap.exists(tag);
		});
		Lua_helper.add_callback(lua, "luaTrailsExists", function(tag:String) {
			return PlayState.instance.modchartTrails.exists(tag);
		});
		Lua_helper.add_callback(lua, "luaTrailAreasExists", function(tag:String) {
			return PlayState.instance.modchartTrailAreas.exists(tag);
		});
		Lua_helper.add_callback(lua, "luaWaveEffectsExists", function(tag:String) {
			return PlayState.instance.modchartWaveEffects.exists(tag);
		});
		Lua_helper.add_callback(lua, "luaShakeEffectsExists", function(tag:String) {
			return PlayState.instance.modchartShakeEffects.exists(tag);
		});
		Lua_helper.add_callback(lua, "luaGlitchEffectsExists", function(tag:String) {
			return PlayState.instance.modchartGlitchEffects.exists(tag);
		});
		Lua_helper.add_callback(lua, "luaRainbowEffectsExists", function(tag:String) {
			return PlayState.instance.modchartRainbowEffects.exists(tag);
		});
		Lua_helper.add_callback(lua, "luaOutlineEffectsExists", function(tag:String) {
			return PlayState.instance.modchartOutlineEffects.exists(tag);
		});
		Lua_helper.add_callback(lua, "luaEffectSpritesExists", function(tag:String) {
			return PlayState.instance.modchartEffectSprites.exists(tag);
		});

		
		// Controls assets

		Lua_helper.add_callback(lua, "keyboardPressed", function(name:String) {
			return Reflect.getProperty(FlxG.keys.pressed, name);
		});
		Lua_helper.add_callback(lua, "keyboardJustPressed", function(name:String) {
			return Reflect.getProperty(FlxG.keys.justPressed, name);
		});
		Lua_helper.add_callback(lua, "keyboardReleased", function(name:String) {
			return Reflect.getProperty(FlxG.keys.justReleased, name);
		});
		Lua_helper.add_callback(lua, "keyPressed", function(name:String) {
			var key:Bool = false;
			switch(name) {
				case 'left': key = PlayState.instance.getControl('NOTE_LEFT');
				case 'down': key = PlayState.instance.getControl('NOTE_DOWN');
				case 'up': key = PlayState.instance.getControl('NOTE_UP');
				case 'right': key = PlayState.instance.getControl('NOTE_RIGHT');
				case 'space': key = FlxG.keys.pressed.SPACE;//an extra key for convinience
			}
			return key;
		});
		Lua_helper.add_callback(lua, "keyJustPressed", function(name:String) {
			var key:Bool = false;
			switch(name) {
				case 'left': key = PlayState.instance.getControl('NOTE_LEFT_P');
				case 'down': key = PlayState.instance.getControl('NOTE_DOWN_P');
				case 'up': key = PlayState.instance.getControl('NOTE_UP_P');
				case 'right': key = PlayState.instance.getControl('NOTE_RIGHT_P');
				case 'accept': key = PlayState.instance.getControl('ACCEPT');
				case 'back': key = PlayState.instance.getControl('BACK');
				case 'pause': key = PlayState.instance.getControl('PAUSE');
				case 'reset': key = PlayState.instance.getControl('RESET');
				case 'space': key = FlxG.keys.justPressed.SPACE;//an extra key for convinience
			}
			return key;
		});
		Lua_helper.add_callback(lua, "keyReleased", function(name:String) {
			var key:Bool = false;
			switch(name) {
				case 'left': key = PlayState.instance.getControl('NOTE_LEFT_R');
				case 'down': key = PlayState.instance.getControl('NOTE_DOWN_R');
				case 'up': key = PlayState.instance.getControl('NOTE_UP_R');
				case 'right': key = PlayState.instance.getControl('NOTE_RIGHT_R');
				case 'space': key = FlxG.keys.justReleased.SPACE;//an extra key for convinience
			}
			return key;
		});
		Lua_helper.add_callback(lua, "anyGamepadPressed", function(name:String) {
			return FlxG.gamepads.anyPressed(name);
		});
		Lua_helper.add_callback(lua, "anyGamepadJustPressed", function(name:String) {
			return FlxG.gamepads.anyJustPressed(name);
		});
		Lua_helper.add_callback(lua, "anyGamepadReleased", function(name:String) {
			return FlxG.gamepads.anyJustReleased(name);
		});
		Lua_helper.add_callback(lua, "gamepadAnalogX", function(id:Int, ?leftStick:Bool = true) {
			return FlxG.gamepads.getByID(id).getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		Lua_helper.add_callback(lua, "gamepadAnalogY", function(id:Int, ?leftStick:Bool = true) {
			return FlxG.gamepads.getByID(id).getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		Lua_helper.add_callback(lua, "gamepadPressed", function(id:Int, name:String) {
			return Reflect.getProperty(FlxG.gamepads.getByID(id).pressed, name);
		});
		Lua_helper.add_callback(lua, "gamepadJustPressed", function(id:Int, name:String) {
			return Reflect.getProperty(FlxG.gamepads.getByID(id).justPressed, name);
		});
		Lua_helper.add_callback(lua, "gamepadReleased", function(id:Int, name:String) {
			return Reflect.getProperty(FlxG.gamepads.getByID(id).justReleased, name);
		});
		Lua_helper.add_callback(lua, "mouseClicked", function(button:String) {
			var ratata = FlxG.mouse.justPressed;
			switch(button){
				case 'middle':
					ratata = FlxG.mouse.justPressedMiddle;
				case 'right':
					ratata = FlxG.mouse.justPressedRight;
			}
			return ratata;
		});
		Lua_helper.add_callback(lua, "mousePressed", function(button:String) {
			var ratata = FlxG.mouse.pressed;
			switch(button){
				case 'middle':
					ratata = FlxG.mouse.pressedMiddle;
				case 'right':
					ratata = FlxG.mouse.pressedRight;
			}
			return ratata;
		});
		Lua_helper.add_callback(lua, "mouseReleased", function(button:String) {
			var ratata = FlxG.mouse.justReleased;
			switch(button){
				case 'middle':
					ratata = FlxG.mouse.justReleasedMiddle;
				case 'right':
					ratata = FlxG.mouse.justReleasedRight;
			}
			return ratata;
		});
		Lua_helper.add_callback(lua, "getMouseX", function(camera:String) {
			var cam:FlxCamera = cameraFromString(camera);
			return FlxG.mouse.getScreenPosition(cam).x;
		});
		Lua_helper.add_callback(lua, "getMouseY", function(camera:String) {
			var cam:FlxCamera = cameraFromString(camera);
			return FlxG.mouse.getScreenPosition(cam).y;
		});


		// Lua Effects

		Lua_helper.add_callback(lua, "makeWaveEffect", function(tag:String, mode:String, strength:Int, center:Float, speed:Float, wavelength:Int, direction:String, interlaceOffset:Float) {
			restartEffect(tag, 1);
			var waveEffect:FlxWaveEffect = new FlxWaveEffect(getWaveMode(mode), strength, center, speed, wavelength, getWaveDirection(direction), interlaceOffset);
			PlayState.instance.modchartWaveEffects.set(tag, waveEffect);
		});
		Lua_helper.add_callback(lua, "makeShakeEffect", function(tag:String, intensity:Float, duration:Float, ?axe:String = 'xy') {
			restartEffect(tag, 2);
			var axes:FlxAxes;
			switch(axe.trim().toLowerCase()) {
				case 'x': axes = X;
				case 'y': axes = Y;
				default: axes = XY;
			}
			var shakeEffect = new FlxShakeEffect(intensity, duration, null, axes);
			PlayState.instance.modchartShakeEffects.set(tag, shakeEffect);
		});
		Lua_helper.add_callback(lua, "makeGlitchEffect", function(tag:String, strength:Int, size:Int, delay:Float, ?direction:String) {
			restartEffect(tag, 3);
			var glitchEffect = new FlxGlitchEffect(strength, size, delay, getGlitchDirection(direction));
			PlayState.instance.modchartGlitchEffects.set(tag, glitchEffect);
		});
		Lua_helper.add_callback(lua, "makeRainbowEffect", function(tag:String, alpha:Float, brightness:Float, speed:Float, startHue:Int) {
			restartEffect(tag, 4);
			if(startHue < 0) startHue = 0;
			if(startHue > 360) startHue = 360;
			var rainbowEffect = new FlxRainbowEffect(alpha, brightness, speed, startHue);
			PlayState.instance.modchartRainbowEffects.set(tag, rainbowEffect);
		});
		Lua_helper.add_callback(lua, "makeOutlineEffect", function(tag:String, mode:String, color:String, thickness:Int, threshold:Int, quality:Float) {
			restartEffect(tag, 5);
			var outlineEffect = new FlxOutlineEffect(getOutlineMode(mode), returnColor(color), thickness, threshold, quality);
			PlayState.instance.modchartOutlineEffects.set(tag, outlineEffect);
		});
		Lua_helper.add_callback(lua, "removeEffect", function(tag:String) {
			restartEffect(tag, 0);
		});
		// Bruh, I've already messed with a lot of 'trails' in this engine.
		// Lua_helper.add_callback(lua, "makeTrailEffect", function(tag:String) {
		// 	restartEffect(tag, 6);
		// 	var trailEffect = new FlxTrailEffect();
		// 	PlayState.instance.modchartTrailEffects.set(tag, trailEffect);
		// });

		//Fist version (;-;) 11 hours... i didn't want to delete it, although it is possible to add a graphic in 'makeSpriteEffect'...
		Lua_helper.add_callback(lua, "makeGraphicEffect", function(tag:String, x:Float, y:Float, width:Int, height:Int, color:String, effect:Array<String> = null) {
			if(effect != null && effect.length > 0) {
				var effectsGroup:Array<IFlxEffect> = [];
				for(ez in effect) {
					if(ez.length > 0 && gettingEffects(ez)) {
						var theEffect:Dynamic = null;
						var effectType:String = getEffectType(ez);
						if(effectType != '') {
							switch(effectType) {
								case 'wave': theEffect = PlayState.instance.modchartWaveEffects.get(ez);
								case 'shake': theEffect = PlayState.instance.modchartShakeEffects.get(ez);
								case 'glitch': theEffect = PlayState.instance.modchartGlitchEffects.get(ez);
								case 'rainbow': theEffect = PlayState.instance.modchartRainbowEffects.get(ez);
								case 'outline': theEffect = PlayState.instance.modchartOutlineEffects.get(ez);
							}
							effectsGroup.push(theEffect);
						}
					}
				}
				if(effectsGroup.length > 0) {
					resetSpecialSprite(tag);
					var leSprite:FlxSprite = new FlxSprite(x, y).makeGraphic(width, height, returnColor(color));
					leSprite.antialiasing = ClientPrefs.globalAntialiasing;

					var effectSprite:FlxEffectSprite = new FlxEffectSprite(leSprite, effectsGroup);
					PlayState.instance.modchartEffectSprites.set(tag, effectSprite);
				} else 
					luaTrace("No valid effects were found", false, false, FlxColor.RED);
			} else
				luaTrace("Effects table is empty or invalid!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "makeSpriteEffect", function(tag:String, obj:String, x:Float, y:Float, effect:Array<String> = null) {
			if(effect != null && effect.length > 0) {
				if(PlayState.instance.modchartSprites.exists(obj)) {
					var effectsGroup:Array<IFlxEffect> = [];
					for(ez in effect) {
						if(ez.length > 0 && gettingEffects(ez)) {
							var theEffect:Dynamic = null;
							var effectType:String = getEffectType(ez);
							if(effectType != '') {
								switch(effectType) {
									case 'wave': theEffect = PlayState.instance.modchartWaveEffects.get(ez);
									case 'shake': theEffect = PlayState.instance.modchartShakeEffects.get(ez);
									case 'glitch': theEffect = PlayState.instance.modchartGlitchEffects.get(ez);
									case 'rainbow': theEffect = PlayState.instance.modchartRainbowEffects.get(ez);
									case 'outline': theEffect = PlayState.instance.modchartOutlineEffects.get(ez);
								}
								effectsGroup.push(theEffect);
							}
						}
					}
					if(effectsGroup.length > 0) {
						resetSpecialSprite(tag);

						if(PlayState.instance.getLuaObject(obj, false) != null) {
							var leSprite:FlxSprite = PlayState.instance.getLuaObject(obj, false);
							var effectSprite:FlxEffectSprite = new FlxEffectSprite(leSprite, effectsGroup);
							effectSprite.x = x;
							effectSprite.y = y;
							PlayState.instance.modchartEffectSprites.set(tag, effectSprite);
							return;
						}
						var varValues:Array<String> = obj.split('.');
						var leSprite:FlxSprite = getObjectDirectly(varValues[0], false);
						if(varValues.length > 1) leSprite = getVarInArray(getPropertyLoop(varValues), varValues[varValues.length-1]);
						if(leSprite != null) {
							var effectSprite:FlxEffectSprite = new FlxEffectSprite(leSprite, effectsGroup);
							effectSprite.x = x;
							effectSprite.y = y;
							PlayState.instance.modchartEffectSprites.set(tag, effectSprite);
							return;
						}
					} else 
						luaTrace("No valid effects were found", false, false, FlxColor.RED);
				} else
					luaTrace("object " + obj + " not found", false, false, FlxColor.RED);
			} else
				luaTrace("Effects table is empty or invalid", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "addSpriteEffect", function(tag:String, front:Bool = false) {
			if(PlayState.instance.modchartEffectSprites.exists(tag)) {
				var effectSprite:FlxEffectSprite = PlayState.instance.modchartEffectSprites.get(tag);
				if(front)
					getInstance().add(effectSprite);
				else {
					if(PlayState.instance.isDead)
						GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), effectSprite);
					else {
						var position:Int = PlayState.instance.members.indexOf(PlayState.instance.gfGroup);
						if(PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup) < position)
							position = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
						else if(PlayState.instance.members.indexOf(PlayState.instance.dadGroup) < position)
							position = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
						PlayState.instance.insert(position, effectSprite);
					}
				}
			} else
				luaTrace("The sprite " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "toggleSpriteEffect", function(tag:String, toggle:Bool = false) {
			if(PlayState.instance.modchartEffectSprites.exists(tag)) {
				var effectSprite:FlxEffectSprite = PlayState.instance.modchartEffectSprites.get(tag);
				effectSprite.effectsEnabled = toggle;
			} else
				luaTrace("The sprite " + tag + " doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "removeSpriteEffect", function(tag:String) {
			resetSpecialSprite(tag);
		});

		Lua_helper.add_callback(lua, "loadSpriteEffect", function(obj:String, effects:Array<String>) {
			if(effects!=null && effects.length > 0) {
				var spr:FlxSprite = PlayState.instance.getLuaObject(obj,false);
				var effectsList:Array<IFlxEffect> = [];
				for (effectTag in effects) {
					var efc:IFlxEffect = null;
					if(PlayState.instance.modchartWaveEffects.exists(effectTag))
						efc = PlayState.instance.modchartWaveEffects.get(effectTag);
	
					if(PlayState.instance.modchartShakeEffects.exists(effectTag))
						efc = PlayState.instance.modchartShakeEffects.get(effectTag);
	
					if(PlayState.instance.modchartGlitchEffects.exists(effectTag))
						efc = PlayState.instance.modchartGlitchEffects.get(effectTag);
	
					if(PlayState.instance.modchartRainbowEffects.exists(effectTag))
						efc = PlayState.instance.modchartRainbowEffects.get(effectTag);
	
					if(PlayState.instance.modchartOutlineEffects.exists(effectTag))
						efc = PlayState.instance.modchartOutlineEffects.get(effectTag);
	
					if(efc!=null)
						effectsList.push(efc);
				}
				if(spr!=null) {
					var leSprite:FlxSprite = new FlxSprite().loadGraphicFromSprite(spr);
					var effectSprite = new FlxEffectSprite(leSprite, effectsList);
					spr = effectSprite;
					return;
				}
				var object:FlxSprite = Reflect.getProperty(getInstance(), obj);
				if(object != null) {
					var leSprite:FlxSprite = new FlxSprite().loadGraphicFromSprite(object);
					var effectSprite = new FlxEffectSprite(leSprite, effectsList);
					object = effectSprite;
					return;
				}
			}
		});


		// Lua Extra Functions

		Lua_helper.add_callback(lua, "luaAchievement", function(achievement:String, id:Int = 0) {
			#if ACHIEVEMENTS_ALLOWED
			var achieve:String = confirmAchievement(achievement, id);
			if (achieve != null) {
				var achievementObj = new AchievementObject(achieve, PlayState.instance.camOther);
				PlayState.instance.add(achievementObj);
				return true;
			}
			return false;
			#end
		});

		Lua_helper.add_callback(lua, "setWatermarkText", function(value:String) {
			PlayState.instance.songTxt.text = value;
		});
		Lua_helper.add_callback(lua, "setWindowTitle", function(value:String) {
			openfl.Lib.application.window.title = value;
		});
		Lua_helper.add_callback(lua, "getTextFromFile", function(path:String, ?ignoreModFolders:Bool = false) {
			return Paths.getTextFromFile(path, ignoreModFolders);
		});
		Lua_helper.add_callback(lua, "directoryFileList", function(folder:String) {
			var list:Array<String> = [];
			#if sys
			if(FileSystem.exists(folder)) {
				for (folder in FileSystem.readDirectory(folder)) {
					if (!list.contains(folder)) {
						list.push(folder);
					}
				}
			}
			#end
			return list;
		});

		Lua_helper.add_callback(lua, "stringStartsWith", function(str:String, start:String) {
			return str.startsWith(start);
		});
		Lua_helper.add_callback(lua, "stringEndsWith", function(str:String, end:String) {
			return str.endsWith(end);
		});
		Lua_helper.add_callback(lua, "stringSplit", function(str:String, split:String) {
			return str.split(split);
		});
		Lua_helper.add_callback(lua, "stringTrim", function(str:String) {
			return str.trim();
		});

		Lua_helper.add_callback(lua, "luaTableContains", function(table:Array<Dynamic> = null, value:Any = null) {
			return table.contains(value);
		});

		Lua_helper.add_callback(lua, "getRandomInt", function(min:Int, max:Int = FlxMath.MAX_VALUE_INT, exclude:String = '') {
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Int> = [];
			for (i in 0...excludeArray.length) {
				toExclude.push(Std.parseInt(excludeArray[i].trim()));
			}
			return FlxG.random.int(min, max, toExclude);
		});
		Lua_helper.add_callback(lua, "getRandomFloat", function(min:Float, max:Float = 1, exclude:String = '') {
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Float> = [];
			for (i in 0...excludeArray.length) {
				toExclude.push(Std.parseFloat(excludeArray[i].trim()));
			}
			return FlxG.random.float(min, max, toExclude);
		});
		Lua_helper.add_callback(lua, "getRandomBool", function(chance:Float = 50) {
			return FlxG.random.bool(chance);
		});

		Lua_helper.add_callback(lua, "getColorFromInt", function(value:Int) {
			return FlxColor.fromInt(value);
		});
		Lua_helper.add_callback(lua, "getColorFromRGB", function(red:Int, green:Int, blue:Int) {
			return FlxColor.fromRGB(red, green, blue);
		});
		Lua_helper.add_callback(lua, "getColorFromRGBFloat", function(red:Float, green:Float, blue:Float) {
			return FlxColor.fromRGBFloat(red, green, blue);
		});
		Lua_helper.add_callback(lua, "getColorFromCMYK", function(cyan:Float, magenta:Float, yellow:Float, black:Float) {
			return FlxColor.fromCMYK(cyan, magenta, yellow, black);
		});
		Lua_helper.add_callback(lua, "getColorFromHSB", function(hue:Float, saturation:Float, brightness:Float) {
			return FlxColor.fromHSB(hue, saturation, brightness);
		});
		Lua_helper.add_callback(lua, "getColorFromHSL", function(hue:Float, saturation:Float, lightness:Float) {
			return FlxColor.fromHSL(hue, saturation, lightness);
		});
		Lua_helper.add_callback(lua, "getColorFromString", function(str:String) {
			return FlxColor.fromString(str);
		});
		Lua_helper.add_callback(lua, "getColorFromHex", function(color:String) {
			return FlxColor.fromString('#$color');
		});

		Lua_helper.add_callback(lua, "debugPrint", function(text:Dynamic = '', color:String) {
			PlayState.instance.addTextToDebug(text, returnColor(color));
		});

		Lua_helper.add_callback(lua, "close", function() {
			closed = true;
			return closed;
		});

		Lua_helper.add_callback(lua, "changePresence", function(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {
			#if desktop
			DiscordClient.changePresence(details, state, smallImageKey, hasStartTimestamp, endTimestamp);
			#end
		});

		Lua_helper.add_callback(lua, 'openURL', function(url:String) {
			CoolUtil.browserLoad(url);
		});
		Lua_helper.add_callback(lua, "pcUserName", function() {
			return Sys.environment()["USERNAME"];
		});

		Lua_helper.add_callback(lua, "changeRatingStuff", function(index:Int, ?ratingText:String, ?ratingFC:String) {
			var ratingArray = PlayState.ratingStuff;
			var lastIndex = ratingArray.length - 1;
			var targetRating = ratingArray[lastIndex];
			if(index < lastIndex + 1 && index > -1) targetRating = ratingArray[index];
			if(ratingText != null && ratingText != '') targetRating[0] = ratingText;
			if(ratingFC != null && ratingFC != '') targetRating[2] = ratingText;
		});

/*		Lua_helper.add_callback(lua, "luaAchievement", function(name:String, description:String, achievTag:String) {
	 		if(name != null) {
	 			var achieve:Array<String> = [name, description, achievTag];
	 			Achievements.achievementsStuff.push(achieve);
	 			var achievementObj = new AchievementObject(achieve, PlayState.instance.camOther);
	 			achievementObj.onFinish = achievementEnd;
	 			add(achievementObj);
	 			return;
			}
		});			*/


		// Shaders Functions

		Lua_helper.add_callback(lua, "createShaders", function(fileName:String, ?optimize:Bool = false) {
			if (ClientPrefs.shadersActive) {
				var shader = new DynamicShaderHandler(fileName, optimize);
				return fileName;
			}
			return null;
		});
		/*
		Lua_helper.add_callback(lua, "modifyShaderProperty", function(fileName:String, propertyName:String, value:Dynamic)
		{
			var handler:DynamicShaderHandler = PlayState.instance.luaShaders.get(fileName);
			trace(Reflect.getProperty(handler.shader.data, propertyName));
			Reflect.setProperty(Reflect.getProperty(handler.shader.data, propertyName), 'value', value);
			handler.modifyShaderProperty(propertyName, value);
		});
		*/
		Lua_helper.add_callback(lua, "setShadersToCamera", function(fileName:Array<String>, cameraName:String) {
			if (ClientPrefs.shadersActive)
				{			
					var shaderArray = new Array<BitmapFilter>();

					for (i in fileName)
					{
						shaderArray.push(new ShaderFilter(PlayState.instance.luaShaders[i].shader));
					}

					cameraFromString(cameraName).setFilters(shaderArray);
				}
		});
		Lua_helper.add_callback(lua, "clearShadersFromCamera", function(cameraName) {
			if (ClientPrefs.shadersActive)
				{
					cameraFromString(cameraName).setFilters([]);
				}
		});
		Lua_helper.add_callback(lua, "addChromaticAbberationEffect", function(camera:String,chromeOffset:Float = 0.005) {
			if (ClientPrefs.shadersActive)
			{
				PlayState.instance.addShaderToCamera(camera, new ChromaticAberrationEffect(chromeOffset));
			}
		});
		Lua_helper.add_callback(lua, "addScanlineEffect", function(camera:String,lockAlpha:Bool=false) {
			if (ClientPrefs.shadersActive)
			{
				PlayState.instance.addShaderToCamera(camera, new ScanlineEffect(lockAlpha));
			}
		});
		Lua_helper.add_callback(lua, "addGrainEffect", function(camera:String,grainSize:Float,lumAmount:Float,lockAlpha:Bool=false) {
			if (ClientPrefs.shadersActive)
			{
				PlayState.instance.addShaderToCamera(camera, new GrainEffect(grainSize,lumAmount,lockAlpha));
			}
		});
		Lua_helper.add_callback(lua, "addTiltshiftEffect", function(camera:String,blurAmount:Float,center:Float) {
			if (ClientPrefs.shadersActive)
			{
				PlayState.instance.addShaderToCamera(camera, new TiltshiftEffect(blurAmount,center));
			}
		});
		Lua_helper.add_callback(lua, "addVCREffect", function(camera:String,glitchFactor:Float = 0.0,distortion:Bool=true,perspectiveOn:Bool=true,vignetteMoving:Bool=true) {
			if (ClientPrefs.shadersActive)
			{
				PlayState.instance.addShaderToCamera(camera, new VCRDistortionEffect(glitchFactor,distortion,perspectiveOn,vignetteMoving));
			}
		});		
		Lua_helper.add_callback(lua, "addGlitchEffect", function(camera:String,waveSpeed:Float = 0.1,waveFrq:Float = 0.1,waveAmp:Float = 0.1) {
			if (ClientPrefs.shadersActive)
			{
				PlayState.instance.addShaderToCamera(camera, new GlitchEffect(waveSpeed,waveFrq,waveAmp));
			}
		});
		Lua_helper.add_callback(lua, "addPulseEffect", function(camera:String,waveSpeed:Float = 0.1,waveFrq:Float = 0.1,waveAmp:Float = 0.1) {
			if (ClientPrefs.shadersActive)
			{
				PlayState.instance.addShaderToCamera(camera, new PulseEffect(waveSpeed,waveFrq,waveAmp));
			}
		});
		Lua_helper.add_callback(lua, "addDistortionEffect", function(camera:String,waveSpeed:Float = 0.1,waveFrq:Float = 0.1,waveAmp:Float = 0.1) {
			if (ClientPrefs.shadersActive)
			{
				PlayState.instance.addShaderToCamera(camera, new DistortBGEffect(waveSpeed,waveFrq,waveAmp));
			}
		});
		Lua_helper.add_callback(lua, "addInvertEffect", function(camera:String,lockAlpha:Bool=false) {
			if (ClientPrefs.shadersActive)
			{
				PlayState.instance.addShaderToCamera(camera, new InvertColorsEffect(lockAlpha));
			}
			
		});
		Lua_helper.add_callback(lua, "addGreyscaleEffect", function(camera:String) { //for dem funkies
			if (ClientPrefs.shadersActive)
			{
				PlayState.instance.addShaderToCamera(camera, new GreyscaleEffect());
			}
		});
		Lua_helper.add_callback(lua, "addGrayscaleEffect", function(camera:String) { //for dem funkies
			if (ClientPrefs.shadersActive)
			{
				PlayState.instance.addShaderToCamera(camera, new GreyscaleEffect());
			}
		});
		Lua_helper.add_callback(lua, "add3DEffect", function(camera:String,xrotation:Float=0,yrotation:Float=0,zrotation:Float=0,depth:Float=0) { //for dem funkies
			if (ClientPrefs.shadersActive)
			{
				PlayState.instance.addShaderToCamera(camera, new ThreeDEffect(xrotation,yrotation,zrotation,depth));
			}
		});
		Lua_helper.add_callback(lua, "addBloomEffect", function(camera:String,intensity:Float = 0.35,blurSize:Float=1.0) {
			if (ClientPrefs.shadersActive)
			{
				PlayState.instance.addShaderToCamera(camera, new BloomEffect(blurSize/512.0,intensity));
			}
		});
		Lua_helper.add_callback(lua, "clearEffects", function(camera:String) {
			if (ClientPrefs.shadersActive)
			{
				PlayState.instance.clearShaderFromCamera(camera);
			}
		});



		// Deprecated!!!
		// Dont mess with these functions, its just there for backward compatibility

		Lua_helper.add_callback(lua, "objectPlayAnimation", function(obj:String, name:String, forced:Bool = false, ?startFrame:Int = 0) {
			luaTrace("objectPlayAnimation is deprecated! Use playAnim instead", false, true);
			if(PlayState.instance.getLuaObject(obj,false,false) != null) {
				PlayState.instance.getLuaObject(obj,false,false).animation.play(name, forced, false, startFrame);
				PlayState.instance.getLuaObject(obj,false,false).animation.finishCallback = function(name:String):Void {
					PlayState.instance.callOnLuas('onAnimationCompleted', [name]);
				};
				return true;
			}

			var spr:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(spr != null) {
				spr.animation.play(name, forced, false, startFrame);
				spr.animation.finishCallback = function(name:String):Void {
					PlayState.instance.callOnLuas('onAnimationCompleted', [name]);
				};
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "characterPlayAnim", function(character:String, anim:String, ?forced:Bool = false) {
			luaTrace("characterPlayAnim is deprecated! Use playAnim instead", false, true);
			switch(character.toLowerCase()) {
				case 'dad':
					if(PlayState.instance.dad.animOffsets.exists(anim))
						PlayState.instance.dad.playAnim(anim, forced);
				case 'gf' | 'girlfriend':
					if(PlayState.instance.gf != null && PlayState.instance.gf.animOffsets.exists(anim))
						PlayState.instance.gf.playAnim(anim, forced);
				default:
					if(PlayState.instance.boyfriend.animOffsets.exists(anim))
						PlayState.instance.boyfriend.playAnim(anim, forced);
			}
		});
		Lua_helper.add_callback(lua, "luaSpriteMakeGraphic", function(tag:String, width:Int, height:Int, color:String) {
			luaTrace("luaSpriteMakeGraphic is deprecated! Use makeGraphic instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var colorNum:Int = Std.parseInt(color);
				if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);

				PlayState.instance.modchartSprites.get(tag).makeGraphic(width, height, colorNum);
			}
		});
		Lua_helper.add_callback(lua, "luaSpriteAddAnimationByPrefix", function(tag:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true) {
			luaTrace("luaSpriteAddAnimationByPrefix is deprecated! Use addAnimationByPrefix instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var inSprites:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
				inSprites.animation.addByPrefix(name, prefix, framerate, loop);
				if(inSprites.animation.curAnim == null) {
					inSprites.animation.play(name, true);
					inSprites.animation.finishCallback = function(name:String):Void {
						PlayState.instance.callOnLuas('onAnimationCompleted', [name]);
					};
				}
			}
		});
		Lua_helper.add_callback(lua, "luaSpriteAddAnimationByIndices", function(tag:String, name:String, prefix:String, indices:String, framerate:Int = 24) {
			luaTrace("luaSpriteAddAnimationByIndices is deprecated! Use addAnimationByIndices instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var strIndices:Array<String> = indices.trim().split(',');
				var numbers:Array<Int> = [];
				for (i in 0...strIndices.length) {
					numbers.push(Std.parseInt(strIndices[i]));
				}
				var anims:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
				anims.animation.addByIndices(name, prefix, numbers, '', framerate, false);
				if(anims.animation.curAnim == null) {
					anims.animation.play(name, true);
					anims.animation.finishCallback = function(name:String):Void {
						PlayState.instance.callOnLuas('onAnimationCompleted', [name]);
					};
				}
			}
		});
		Lua_helper.add_callback(lua, "luaSpritePlayAnimation", function(tag:String, name:String, forced:Bool = false) {
			luaTrace("luaSpritePlayAnimation is deprecated! Use playAnim instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				PlayState.instance.modchartSprites.get(tag).animation.play(name, forced);
				PlayState.instance.modchartSprites.get(tag).animation.finishCallback = function(name:String):Void {
					PlayState.instance.callOnLuas('onAnimationCompleted', [name]);
				};
			}
		});
		Lua_helper.add_callback(lua, "setLuaSpriteCamera", function(tag:String, camera:String = '') {
			luaTrace("setLuaSpriteCamera is deprecated! Use setObjectCamera instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				PlayState.instance.modchartSprites.get(tag).cameras = [cameraFromString(camera)];
				return true;
			}
			luaTrace("Lua sprite with tag: " + tag + " doesn't exist!");
			return false;
		});
		Lua_helper.add_callback(lua, "setLuaSpriteScrollFactor", function(tag:String, scrollX:Float, scrollY:Float) {
			luaTrace("setLuaSpriteScrollFactor is deprecated! Use setScrollFactor instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				PlayState.instance.modchartSprites.get(tag).scrollFactor.set(scrollX, scrollY);
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "scaleLuaSprite", function(tag:String, x:Float, y:Float) {
			luaTrace("scaleLuaSprite is deprecated! Use scaleObject instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var theScaleModchart:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
				theScaleModchart.scale.set(x, y);
				theScaleModchart.updateHitbox();
				return true;
			}
			return false;
		});
		Lua_helper.add_callback(lua, "getPropertyLuaSprite", function(tag:String, variable:String) {
			luaTrace("getPropertyLuaSprite is deprecated! Use getProperty instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var nomNomBion:Array<String> = variable.split('.');
				if(nomNomBion.length > 1) {
					var noDinamo:Dynamic = Reflect.getProperty(PlayState.instance.modchartSprites.get(tag), nomNomBion[0]);
					for (i in 1...nomNomBion.length-1) {
						noDinamo = Reflect.getProperty(noDinamo, nomNomBion[i]);
					}
					return Reflect.getProperty(noDinamo, nomNomBion[nomNomBion.length-1]);
				}
				return Reflect.getProperty(PlayState.instance.modchartSprites.get(tag), variable);
			}
			return null;
		});
		Lua_helper.add_callback(lua, "setPropertyLuaSprite", function(tag:String, variable:String, value:Dynamic) {
			luaTrace("setPropertyLuaSprite is deprecated! Use setProperty instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				var nomNomBion:Array<String> = variable.split('.');
				if(nomNomBion.length > 1) {
					var noDinamo:Dynamic = Reflect.getProperty(PlayState.instance.modchartSprites.get(tag), nomNomBion[0]);
					for (i in 1...nomNomBion.length-1) {
						noDinamo = Reflect.getProperty(noDinamo, nomNomBion[i]);
					}
					Reflect.setProperty(noDinamo, nomNomBion[nomNomBion.length-1], value);
					return true;
				}
				Reflect.setProperty(PlayState.instance.modchartSprites.get(tag), variable, value);
				return true;
			}
			luaTrace("Lua sprite with tag: " + tag + " doesn't exist!");
			return false;
		});
		Lua_helper.add_callback(lua, "musicFadeIn", function(duration:Float, fromValue:Float = 0, toValue:Float = 1) {
			FlxG.sound.music.fadeIn(duration, fromValue, toValue);
			luaTrace('musicFadeIn is deprecated! Use soundFadeIn instead.', false, true);

		});
		Lua_helper.add_callback(lua, "musicFadeOut", function(duration:Float, toValue:Float = 0) {
			FlxG.sound.music.fadeOut(duration, toValue);
			luaTrace('musicFadeOut is deprecated! Use soundFadeOut instead.', false, true);
		});
		Lua_helper.add_callback(lua, "luacharNoteHit", function(tag:String, noteId:Int) {
			luaTrace("luacharNoteHit is deprecated! Note animation is Automatic or use luacharPlayAnim instead", false, true);
			if(PlayState.instance.luaCharsMap.exists(tag)) {
				var daNote:Note;
				if(noteId >= 0) daNote = PlayState.instance.notes.members[noteId];
				else throw "The object was not found";
				var luaChar:LuaChar = PlayState.instance.luaCharsMap.get(tag);
				var animToPlay:String = 'sing' + Note.keysAssets.get(PlayState.mania).get('anims')[daNote.noteData] + daNote.animSuffix;
				if(!daNote.hitByOpponent && luaChar.isPlayer) {
					if(luaChar.testNote(daNote.noteType)) {
						luaChar.playAnim(animToPlay, true);
						luaChar.holdTimer = 0;
					}
				} else if(!luaChar.isPlayer) {
					if(luaChar.testNote(daNote.noteType)) {
						luaChar.playAnim(animToPlay, true);
						luaChar.holdTimer = 0;
					}
				}
			} else {
				luaTrace("The character " + tag + " doesn't exist!", false, false, FlxColor.RED);	
			}
		});
		Lua_helper.add_callback(lua, "luacharMissAnim", function(tag:String, noteId:Int) {
			luaTrace("luacharMissAnim is deprecated! Note animation is Automatic or use luacharPlayAnim instead", false, true);
			if(PlayState.instance.luaCharsMap.exists(tag)) {
				var daNote:Note;
				if(noteId >= 0) daNote = PlayState.instance.notes.members[noteId];
				else throw "The object was not found";
				var luaChar:LuaChar = PlayState.instance.luaCharsMap.get(tag);
				var animToPlay:String = 'sing' + Note.keysAssets.get(PlayState.mania).get('anims')[daNote.noteData] + 'miss' + daNote.animSuffix;
				if(!daNote.noMissAnimation && luaChar.hasMissAnimations && luaChar.isPlayer) {
					if(luaChar.testNote(daNote.noteType)) luaChar.playAnim(animToPlay, true);
				}
			} else {
				luaTrace("The character " + tag + " doesn't exist!", false, false, FlxColor.RED);	
			}
		});


		Discord.DiscordClient.addLuaCallbacks(lua);
		call('onCreate', []);
		#end
	}

	#if hscript
	public function initHaxeInterp()
	{
		if(haxeInterp == null)
		{
			haxeInterp = new Interp();
			haxeInterp.variables.set('FlxG', FlxG);
			haxeInterp.variables.set('FlxSprite', FlxSprite);
			haxeInterp.variables.set('FlxCamera', FlxCamera);
			haxeInterp.variables.set('FlxTween', FlxTween);
			haxeInterp.variables.set('FlxEase', FlxEase);
			haxeInterp.variables.set('PlayState', PlayState);
			haxeInterp.variables.set('game', PlayState.instance);
			haxeInterp.variables.set('Paths', Paths);
			haxeInterp.variables.set('Conductor', Conductor);
			haxeInterp.variables.set('ClientPrefs', ClientPrefs);
			haxeInterp.variables.set('Character', Character);
			haxeInterp.variables.set('Alphabet', Alphabet);
			haxeInterp.variables.set('StringTools', StringTools);

			haxeInterp.variables.set('setVar', function(name:String, value:Dynamic)
			{
				PlayState.instance.variables.set(name, value);
			});
			haxeInterp.variables.set('getVar', function(name:String)
			{
				if(!PlayState.instance.variables.exists(name)) return null;
				return PlayState.instance.variables.get(name);
			});
		}
	}
	#end

	public static function setVarInArray(instance:Dynamic, variable:String, value:Dynamic):Any {
		var inArrayValues:Array<String> = variable.split('[');
		if(inArrayValues.length > 1) {
			var blah:Dynamic = Reflect.getProperty(instance, inArrayValues[0]);
			for (i in 1...inArrayValues.length) {
				var leNum:Dynamic = inArrayValues[i].substr(0, inArrayValues[i].length - 1);
				if(i >= inArrayValues.length-1) //Last array
					blah[leNum] = value;
				else //Anything else
					blah = blah[leNum];
			}
			return blah;
		}
		/*if(Std.isOfType(instance, Map))
			instance.set(variable,value);
		else*/

		Reflect.setProperty(instance, variable, value);
		return true;
	}

	public static function getVarInArray(instance:Dynamic, variable:String):Any {
		var splitProps:Array<String> = variable.split('[');
		if(splitProps.length > 1) {
			var target:Dynamic = null;
			if(PlayState.instance.variables.exists(splitProps[0])) {
				var retVal:Dynamic = PlayState.instance.variables.get(splitProps[0]);
				if(retVal != null) target = retVal;
			} else {
				target = Reflect.getProperty(instance, splitProps[0]);
			}

			for (i in 1...splitProps.length) {
				var leNum:Dynamic = splitProps[i].substr(0, splitProps[i].length - 1);
				target = target[leNum];
			}
			return target;
		}
		return Reflect.getProperty(instance, variable);
	}

	inline static function getTextObject(name:String):FlxText {
		return PlayState.instance.modchartTexts.exists(name) ? PlayState.instance.modchartTexts.get(name) : Reflect.getProperty(PlayState.instance, name);
	}

	function getGroupStuff(leArray:Dynamic, variable:String) {
		var leValues:Array<String> = variable.split('.');
		if(leValues.length > 1) {
			var leGrouped:Dynamic = Reflect.getProperty(leArray, leValues[0]);
			for (i in 1...leValues.length-1) {
				leGrouped = Reflect.getProperty(leGrouped, leValues[i]);
			}
			switch(Type.typeof(leGrouped)){
				case ValueType.TClass(haxe.ds.StringMap) | ValueType.TClass(haxe.ds.ObjectMap) | ValueType.TClass(haxe.ds.IntMap) | ValueType.TClass(haxe.ds.EnumValueMap):
					return leGrouped.get(leValues[leValues.length-1]);
				default:
					return Reflect.getProperty(leGrouped, leValues[leValues.length-1]);
			};
		}
		switch(Type.typeof(leArray)){
			case ValueType.TClass(haxe.ds.StringMap) | ValueType.TClass(haxe.ds.ObjectMap) | ValueType.TClass(haxe.ds.IntMap) | ValueType.TClass(haxe.ds.EnumValueMap):
				return leArray.get(variable);
			default:
				return Reflect.getProperty(leArray, variable);
		};
	}

	function loadFrames(spr:FlxSprite, image:String, spriteType:String) {
		switch(spriteType.toLowerCase().trim()) {
			case "texture" | "textureatlas" | "tex":
				spr.frames = AtlasFrameMaker.construct(image);

			case "texture_noaa" | "textureatlas_noaa" | "tex_noaa":
				spr.frames = AtlasFrameMaker.construct(image, null, true);

			case "packer" | "packeratlas" | "pac":
				spr.frames = Paths.getPackerAtlas(image);

			default:
				spr.frames = Paths.getSparrowAtlas(image);
		}
	}

	function setGroupStuff(leArray:Dynamic, variable:String, value:Dynamic) {
		var leValues:Array<String> = variable.split('.');
		if(leValues.length > 1) {
			var leGrouped:Dynamic = Reflect.getProperty(leArray, leValues[0]);
			for (i in 1...leValues.length-1) {
				leGrouped = Reflect.getProperty(leGrouped, leValues[i]);
			}
			Reflect.setProperty(leGrouped, leValues[leValues.length-1], value);
			return;
		}
		Reflect.setProperty(leArray, variable, value);
	}

	function resetTextTag(tag:String) {
		#if LUA_ALLOWED
		if(!PlayState.instance.modchartTexts.exists(tag)) {
			return;
		}
		var theText:FlxText = PlayState.instance.modchartTexts.get(tag);
		theText.kill();
		PlayState.instance.remove(theText, true);
		theText.destroy();
		PlayState.instance.modchartTexts.remove(tag);
		#end
	}

	// function resetTextAndGradientTag(tag:String) {
	// 	#if LUA_ALLOWED
	// 	if(!PlayState.instance.modchartTexts.exists(tag) && (!PlayState.instance.modchartGradients.exists(tag))) {
	// 		return;
	// 	}
	// 	var theText:FlxText = PlayState.instance.modchartTexts.get(tag);
	// 	theText.kill();
	// 	PlayState.instance.remove(theText, true);
	// 	theText.destroy();
	// 	PlayState.instance.modchartTexts.remove(tag);

	// 	var theSprite:FlxSprite = PlayState.instance.modchartGradients.get(tag);
	// 	theSprite.kill();
	// 	PlayState.instance.remove(theSprite, true);
	// 	theSprite.destroy();
	// 	PlayState.instance.modchartGradients.remove(tag);
	// 	#end
	// }

	function resetSpriteTag(tag:String) {
		if(!PlayState.instance.modchartSprites.exists(tag)) return;
		var theSprite:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
		theSprite.kill();
		if(theSprite.wasAdded) {
			PlayState.instance.remove(theSprite, true);
		}
		theSprite.destroy();
		PlayState.instance.modchartSprites.remove(tag);
	}

	function resetSpecialSprite(tag:String) {
		if(!PlayState.instance.modchartEffectSprites.exists(tag)) return;
		var theSprite:FlxEffectSprite = PlayState.instance.modchartEffectSprites.get(tag);
		theSprite.kill();
		PlayState.instance.remove(theSprite, true);
		theSprite.destroy();
		PlayState.instance.modchartEffectSprites.remove(tag);
	}

	function resetSkewedSprite(tag:String) {
		if(PlayState.instance.modchartSkeweds.exists(tag)) {
			PlayState.instance.modchartSkeweds.get(tag).kill();
			PlayState.instance.modchartSkeweds.get(tag).destroy();
			PlayState.instance.modchartSkeweds.remove(tag);
		}
	}

	function cancelTween(tag:String) {
		if(PlayState.instance.modchartTweens.exists(tag)) {
			PlayState.instance.modchartTweens.get(tag).cancel();
			PlayState.instance.modchartTweens.get(tag).destroy();
			PlayState.instance.modchartTweens.remove(tag);
		}
	}

	function tweenVars(tag:String, vars:String) {
		cancelTween(tag);
		var variables:Array<String> = vars.split('.');
		var objectTween:Dynamic = getObjectDirectly(variables[0], true, true, true);
		if(variables.length > 1) {
			objectTween = getVarInArray(getPropertyLoop(variables,true,true,true,true), variables[variables.length-1]);
		}
		return objectTween;
	}

	function cancelFlicker(tag:String) {
		if(PlayState.instance.modchartFlickers.exists(tag)) {
			PlayState.instance.modchartFlickers.get(tag).stop();
			PlayState.instance.modchartFlickers.get(tag).destroy();
			PlayState.instance.modchartFlickers.remove(tag);
		}
	}

	function flickVars(tag:String, vars:String) {
		cancelFlicker(tag);
		var variables:Array<String> = vars.split('.');
		var objectFlicker:Dynamic = getObjectDirectly(variables[0], true, true, true);
		return objectFlicker;
	}

	function cancelTimer(tag:String) {
		if(PlayState.instance.modchartTimers.exists(tag)) {
			var theTimer:FlxTimer = PlayState.instance.modchartTimers.get(tag);
			theTimer.cancel();
			theTimer.destroy();
			PlayState.instance.modchartTimers.remove(tag);
		}
	}

	function luaBarRemove(tag:String) {
		if(PlayState.instance.modchartBars.exists(tag)) {
			PlayState.instance.modchartBars.get(tag).destroy();
			PlayState.instance.modchartBars.remove(tag);
		}
	}

	function resetLuaChar(tag:String) {
		if(PlayState.instance.luaCharsMap.exists(tag)) {
			PlayState.instance.luaCharsMap.get(tag).kill();
			PlayState.instance.luaCharsMap.get(tag).destroy();
			PlayState.instance.luaCharsMap.remove(tag);
		}
	}

	function resetEmitter(tag:String) {
		if(PlayState.instance.modchartEmitters.exists(tag)) {
			PlayState.instance.modchartEmitters.get(tag).kill();
			PlayState.instance.modchartEmitters.get(tag).destroy();
			PlayState.instance.modchartEmitters.remove(tag);
		}
	}

	function trailExists(tag:String) {
		if(PlayState.instance.modchartTrails.exists(tag)) {
			PlayState.instance.modchartTrails.get(tag).kill();
			PlayState.instance.modchartTrails.get(tag).destroy();
			PlayState.instance.modchartTrails.remove(tag);
		}
	}

	function trailAreaExists(tag:String) {
		if(PlayState.instance.modchartTrailAreas.exists(tag)) {
			PlayState.instance.modchartTrailAreas.get(tag).kill();
			PlayState.instance.modchartTrailAreas.get(tag).destroy();
			PlayState.instance.modchartTrailAreas.remove(tag);
		}
	}

	function restartEffect(tag:String, num:Int) {	
		if(num==1 || num==0) {
			if(PlayState.instance.modchartWaveEffects.exists(tag)) {
				PlayState.instance.modchartWaveEffects.get(tag).destroy();
				PlayState.instance.modchartWaveEffects.remove(tag);
			}
		}
		if(num==2 || num==0) {
			if(PlayState.instance.modchartShakeEffects.exists(tag)) {
				PlayState.instance.modchartShakeEffects.get(tag).destroy();
				PlayState.instance.modchartShakeEffects.remove(tag);
			}
		}
		if(num==3 || num==0) {
			if(PlayState.instance.modchartGlitchEffects.exists(tag)) {
				PlayState.instance.modchartGlitchEffects.get(tag).destroy();
				PlayState.instance.modchartGlitchEffects.remove(tag);
			}
		}
		if(num==4 || num==0) {
			if(PlayState.instance.modchartRainbowEffects.exists(tag)) {
				PlayState.instance.modchartRainbowEffects.get(tag).destroy();
				PlayState.instance.modchartRainbowEffects.remove(tag);
			}
		}
		if(num==5 || num==0) {
			if(PlayState.instance.modchartOutlineEffects.exists(tag)) {
				PlayState.instance.modchartOutlineEffects.get(tag).destroy();
				PlayState.instance.modchartOutlineEffects.remove(tag);
			}
		}
	}

	public static function getLuaTween(options:Dynamic) {
		return {
			type: getTweenTypeByString(options.type),
			startDelay: options.startDelay,
			onUpdate: options.onUpdate,
			onStart: options.onStart,
			onComplete: options.onComplete,
			loopDelay: options.loopDelay,
			ease: getFlxEaseByString(options.ease)
		};
	}

	#if ACHIEVEMENTS_ALLOWED
	function confirmAchievement(achievementName:String, id:Int):String
	{
		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		if(!Achievements.isAchievementUnlocked(achievementName) && !PlayState.instance.cpuControlled) {
			var unlock:Bool = false;
			switch(achievementName) {
				// Para todo Cristal Ganho em:
				// Bosque
				case 'flora':
					if(Paths.formatToSongPath(PlayState.SONG.song) == 'bosques-de-wumpa' && !usedPractice && id == 13) {
						unlock = true;
					}
				// Bonus
				case 'bonus':
					if(Paths.formatToSongPath(PlayState.SONG.song) == 'bonus' && !usedPractice && id == 21) {
						unlock = true;
					}
				// Templo
				case 'templo':
					if(Paths.formatToSongPath(PlayState.SONG.song) == 'templo-obscuro' && !usedPractice && id == 38) {
						unlock = true;
					}
				// Esgoto
				case 'toxico':
					if(Paths.formatToSongPath(PlayState.SONG.song) == 'canal-toxico' && !usedPractice && id == 45) {
						unlock = true;
					}
				// Secreto
				case 'precioso':
					if(Paths.formatToSongPath(PlayState.SONG.song) == 'bosques-de-wumpa' && !usedPractice && id == 69) {
						unlock = true;
					}
			}

			if(unlock) {
				Achievements.unlockAchievement(achievementName);
				return achievementName;
			}
		}
		return null;
	}
	#end

	public static function getTweenTypeByString(?type:String = '') {
		switch(type.toLowerCase().trim())
		{
			case 'backward': return FlxTweenType.BACKWARD;
			case 'looping'|'loop': return FlxTweenType.LOOPING;
			case 'persist': return FlxTweenType.PERSIST;
			case 'pingpong': return FlxTweenType.PINGPONG;
		}
		return FlxTweenType.ONESHOT;
	}

	public static function getFlxEaseByString(?ease:String = '') {
		switch(ease.toLowerCase().trim()) {
			case 'backin': return FlxEase.backIn;
			case 'backinout': return FlxEase.backInOut;
			case 'backout': return FlxEase.backOut;
			case 'bouncein': return FlxEase.bounceIn;
			case 'bounceinout': return FlxEase.bounceInOut;
			case 'bounceout': return FlxEase.bounceOut;
			case 'circin': return FlxEase.circIn;
			case 'circinout': return FlxEase.circInOut;
			case 'circout': return FlxEase.circOut;
			case 'cubein': return FlxEase.cubeIn;
			case 'cubeinout': return FlxEase.cubeInOut;
			case 'cubeout': return FlxEase.cubeOut;
			case 'elasticin': return FlxEase.elasticIn;
			case 'elasticinout': return FlxEase.elasticInOut;
			case 'elasticout': return FlxEase.elasticOut;
			case 'expoin': return FlxEase.expoIn;
			case 'expoinout': return FlxEase.expoInOut;
			case 'expoout': return FlxEase.expoOut;
			case 'quadin': return FlxEase.quadIn;
			case 'quadinout': return FlxEase.quadInOut;
			case 'quadout': return FlxEase.quadOut;
			case 'quartin': return FlxEase.quartIn;
			case 'quartinout': return FlxEase.quartInOut;
			case 'quartout': return FlxEase.quartOut;
			case 'quintin': return FlxEase.quintIn;
			case 'quintinout': return FlxEase.quintInOut;
			case 'quintout': return FlxEase.quintOut;
			case 'sinein': return FlxEase.sineIn;
			case 'sineinout': return FlxEase.sineInOut;
			case 'sineout': return FlxEase.sineOut;
			case 'smoothstepin': return FlxEase.smoothStepIn;
			case 'smoothstepinout': return FlxEase.smoothStepInOut;
			case 'smoothstepout': return FlxEase.smoothStepInOut;
			case 'smootherstepin': return FlxEase.smootherStepIn;
			case 'smootherstepinout': return FlxEase.smootherStepInOut;
			case 'smootherstepout': return FlxEase.smootherStepOut;
		}
		return FlxEase.linear;
	}

	function blendModeFromString(blend:String):BlendMode {
		switch(blend.toLowerCase().trim()) {
			case 'add': return ADD;
			case 'alpha': return ALPHA;
			case 'darken': return DARKEN;
			case 'difference': return DIFFERENCE;
			case 'erase': return ERASE;
			case 'hardlight': return HARDLIGHT;
			case 'invert': return INVERT;
			case 'layer': return LAYER;
			case 'lighten': return LIGHTEN;
			case 'multiply': return MULTIPLY;
			case 'overlay': return OVERLAY;
			case 'screen': return SCREEN;
			case 'shader': return SHADER;
			case 'subtract': return SUBTRACT;
		}
		return NORMAL;
	}

	function cameraFromString(cam:String):FlxCamera {
		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud': return PlayState.instance.camHUD;
			case 'camother' | 'other': return PlayState.instance.camOther;
		}
		return PlayState.instance.camGame;
	}

	function cameraToString(cam:String):String {
		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud': return 'hud';
			case 'camother' | 'other': return 'other';
		}
		return 'game';
	}

	function getDirectionByString(direction:String) {
		switch(direction.toLowerCase().trim()) {
			case 'right': return RIGHT_TO_LEFT;
			case 'top': return TOP_TO_BOTTOM;
			case 'bottom': return BOTTOM_TO_TOP;
			case 'horizontal': return HORIZONTAL_INSIDE_OUT;
			case 'horizontaloutside': return HORIZONTAL_OUTSIDE_IN;
			case 'verticalinside': return VERTICAL_INSIDE_OUT;
			case 'verticaloutside': return VERTICAL_OUTSIDE_IN;
		}
		return LEFT_TO_RIGHT;
	}

	function getWaveMode(mode:String) {
		switch(mode.toLowerCase().trim()) {
			case 'start': return FlxWaveMode.START;
			case 'end': return FlxWaveMode.END;
		}
		return FlxWaveMode.ALL;
	}

	function getWaveDirection(direction:String) {
		switch(direction.toLowerCase().trim()) {
			case 'vertical':
				return FlxWaveDirection.VERTICAL;
			default:
				return FlxWaveDirection.HORIZONTAL;
		}
	}

	function getGlitchDirection(direction:String) {
		switch(direction.toLowerCase().trim()) {
			case 'vertical':
				return FlxGlitchDirection.VERTICAL;
			default:
				return FlxGlitchDirection.HORIZONTAL;
		}
	}

	function getLaunchType(type:String) {
		switch(type) {
			case 'square':
				return SQUARE;
			default:
				return CIRCLE;
		}
	}

	function getOutlineMode(mode:String) {
		switch(mode) {
			case 'fast':
				return FlxOutlineMode.FAST;
			case 'pixel':
				return FlxOutlineMode.PIXEL_BY_PIXEL;
			default:
				return FlxOutlineMode.NORMAL;
		}
	}

	function gettingEffects(effect:String) {
		if(PlayState.instance.modchartWaveEffects.exists(effect)) return true;
		if(PlayState.instance.modchartShakeEffects.exists(effect)) return true;
		if(PlayState.instance.modchartGlitchEffects.exists(effect)) return true;
		if(PlayState.instance.modchartRainbowEffects.exists(effect)) return true;
		if(PlayState.instance.modchartOutlineEffects.exists(effect)) return true;
		return false;
	}

	function getEffectType(effect:String) {
		if(PlayState.instance.modchartWaveEffects.exists(effect)) return 'wave';
		if(PlayState.instance.modchartShakeEffects.exists(effect)) return 'shake';
		if(PlayState.instance.modchartGlitchEffects.exists(effect)) return 'glitch';
		if(PlayState.instance.modchartRainbowEffects.exists(effect)) return 'rainbow';
		if(PlayState.instance.modchartOutlineEffects.exists(effect)) return 'outline';
		return '';
	}

	function returnColor(str:String) {
		var leColor = FlxColor.fromString(str);
		if(leColor == null && !str.startsWith('0x') && !str.startsWith('#'))
			leColor = return FlxColor.fromString('#$str');
		return leColor;
	}

	function runTweenFunction(tag:String, vars:String, tweenValue:Any, duration:Float, delay:Float, ease:String, funcName:String) {
		#if LUA_ALLOWED
		var objectName:Dynamic = tweenVars(tag, vars);
		if(objectName != null) {
			PlayState.instance.modchartTweens.set(tag, FlxTween.tween(objectName, tweenValue, duration, {startDelay: delay, ease: getFlxEaseByString(ease),
				onComplete: function(twn:FlxTween) {
					PlayState.instance.modchartTweens.remove(tag);
					PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
				},
				onUpdate: function(twn:FlxTween) {
					PlayState.instance.callOnLuas('onTweenProgress', [tag]);
				}
			}));
		} else {
			luaTrace(funcName + ': Couldnt find object: ' + vars, false, false, FlxColor.RED);
		}
		#end
	}


	public function luaTrace(text:String, ignoreCheck:Bool = false, deprecated:Bool = false, color:FlxColor = FlxColor.WHITE) {
		#if LUA_ALLOWED
		if(ignoreCheck || getBool('luaDebugMode')) {
			if(deprecated && !getBool('luaDeprecatedWarnings')) {
				return;
			}
			PlayState.instance.addTextToDebug(text, color);
			trace(text);
		}
		#end
	}

	function getErrorMessage() {
		#if LUA_ALLOWED
		var v:String = Lua.tostring(lua, -1);
		if(!isErrorAllowed(v)) v = null;
		return v;
		#end
	}

	var lastCalledFunction:String = '';
	public function call(func:String, args:Array<Dynamic>): Dynamic{
		#if LUA_ALLOWED
		if(closed) return Function_Continue;

		lastCalledFunction = func;
		try {
			if(lua == null) return Function_Continue;

			Lua.getglobal(lua, func);
			
			for(arg in args) {
				Convert.toLua(lua, arg);
			}

			var result:Null<Int> = Lua.pcall(lua, args.length, 1, 0);
			var error:Dynamic = getErrorMessage();
			if(!resultIsAllowed(lua, result))
			{
				Lua.pop(lua, 1);
				if(error != null) luaTrace("ERROR (" + func + "): " + error, false, false, FlxColor.RED);
			}
			else
			{
				var conv:Dynamic = Convert.fromLua(lua, result);
				Lua.pop(lua, 1);
				if(conv == null) conv = Function_Continue;
				return conv;
			}
			return Function_Continue;
		}
		catch (e:Dynamic) {
			trace(e);
		}
		#end
		return Function_Continue;
	}

	public static function getPropertyLoop(splitArrays:Array<String>, ?checkForTextsToo:Bool = true, ?getProperty:Bool=true, ?checkForBarsToo:Bool = false, ?checkForTrailsToo:Bool = false):Dynamic
	{
		var thePropertys:Dynamic = getObjectDirectly(splitArrays[0], checkForTextsToo, checkForBarsToo, checkForTrailsToo);
		var end = splitArrays.length;
		if(getProperty) end = splitArrays.length-1;

		for (i in 1...end) {
			thePropertys = getVarInArray(thePropertys, splitArrays[i]);
		}
		return thePropertys;
	}

	public static function getObjectDirectly(objectName:String, ?checkForTextsToo:Bool = true, ?checkForBarsToo:Bool = false, ?checkForTrailsToo:Bool = false):Dynamic
	{
		switch(objectName)
		{
			case 'this' | 'instance' | 'game':
				return PlayState.instance;
			default:
				var thePropertys:Dynamic = PlayState.instance.getLuaObject(objectName, checkForTextsToo, checkForBarsToo, checkForTrailsToo);
				if(thePropertys == null)
					thePropertys = PlayState.instance.getLuaEmitter(objectName);
				if(thePropertys == null)
					thePropertys = getVarInArray(getInstance(), objectName);

				return thePropertys;
		}
	}

	public static function callMethodFromObject(classObj:Dynamic, funcStr:String, args:Array<Dynamic> = null)
	{
		if(args == null) args = [];

		var split:Array<String> = funcStr.split('.');
		var funcToRun:Any = null;
		var obj:Dynamic = classObj;
		//trace('start: $obj');
		if(obj == null)
		{
			return null;
		}

		for (i in 0...split.length)
		{
			obj = getVarInArray(obj, split[i].trim());
			//trace(obj, split[i]);
		}

		funcToRun = cast obj;
		//trace('end: $obj');
		return funcToRun != null ? Reflect.callMethod(obj, funcToRun, args) : null;
	}	

	#if LUA_ALLOWED
	function resultIsAllowed(leLua:State, leResult:Null<Int>) { //Makes it ignore warnings
		return Lua.type(leLua, leResult) >= Lua.LUA_TNIL;
	}

	function isErrorAllowed(error:String) {
		switch(error)
		{
			case 'attempt to call a nil value' | 'C++ exception':
				return false;
		}
		return true;
	}
	#end

	public function set(variable:String, data:Dynamic) {
		#if LUA_ALLOWED
		if(lua == null) {
			return;
		}

		Convert.toLua(lua, data);
		Lua.setglobal(lua, variable);
		#end
	}

	#if LUA_ALLOWED
	public function getBool(variable:String) {
		var result:String = null;
		Lua.getglobal(lua, variable);
		result = Convert.fromLua(lua, -1);
		Lua.pop(lua, 1);

		if(result == null) {
			return false;
		}
		return (result == 'true');
	}
	#end

	public function stop() {
		#if LUA_ALLOWED
		if(lua == null) {
			return;
		}

		Lua.close(lua);
		lua = null;
		#end
	}

	public static inline function getInstance()
	{
		return PlayState.instance.isDead ? GameOverSubstate.instance : PlayState.instance;
	}

	public static inline function getLowestCharacterGroup():FlxSpriteGroup
		{
		var group:FlxSpriteGroup = PlayState.instance.gfGroup;
		var pos:Int = PlayState.instance.members.indexOf(group);

		var newPos:Int = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
		if(newPos < pos)
		{
			group = PlayState.instance.boyfriendGroup;
			pos = newPos;
		}
		
		newPos = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
		if(newPos < pos)
		{
			group = PlayState.instance.dadGroup;
			pos = newPos;
		}
		return group;
	}
}

class ModchartSprite extends FlxSprite
{
	public var wasAdded:Bool = false;
	public var animOffsets:Map<String, Array<Float>> = new Map<String, Array<Float>>();
	//public var isInFront:Bool = false;
	var hShader:DynamicShaderHandler;

	public function new(?x:Float = 0, ?y:Float = 0, shaderSprite:Bool=false,type:String = '', optimize:Bool = false)
	{
		super(x, y);
		antialiasing = FlxG.save.data.antialiasing;
		if(shaderSprite){
			flipY = true;
			makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
			hShader = new DynamicShaderHandler(type, optimize);
			if (hShader.shader != null)
			{
				shader = hShader.shader;
			}
		}
	}
}

// class ModchartText extends FlxText
// {
// 	public var wasAdded:Bool = false;
// 	public function new(x:Float, y:Float, text:String, width:Float)
// 	{
// 		super(x, y, width, text, 16);
// 		setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
// 		cameras = [PlayState.instance.camHUD];
// 		scrollFactor.set();
// 		borderSize = 2;
// 	}
// }

class DebugLuaText extends FlxText
{
	public var disableTime:Float = 6;
	public function new() {
		super(10, 10, FlxG.width - 20, '', 16);

		setFormat(Paths.font("vcr.ttf"), 20, color, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scrollFactor.set();
		borderSize = 1;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		disableTime -= elapsed;
		if(disableTime < 0) disableTime = 0;
		if(disableTime < 1) alpha = disableTime;

		if(alpha == 0 || y >= FlxG.height) kill();
	}
}
