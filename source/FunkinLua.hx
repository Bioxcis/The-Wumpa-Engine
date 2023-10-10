#if LUA_ALLOWED
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
#end

import animateatlas.AtlasFrameMaker;
import flixel.FlxG;
import flixel.addons.effects.FlxTrail;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import openfl.Lib;
import openfl.display.ShaderParameter;
import openfl.filters.ShaderFilter;
import openfl.display.BlendMode;
import openfl.filters.BitmapFilter;
import haxe.Json;
import openfl.utils.Assets;
import flixel.math.FlxMath;
import Shaders;
import flixel.util.FlxSave;
import flixel.addons.transition.FlxTransitionableState;
import flixel.system.FlxAssets.FlxShader;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import Type.ValueType;
import Controls;
import DialogueBoxPsych;
#if hscript
import hscript.Parser;
import hscript.Interp;
#end

#if desktop
import Discord;
#end

using StringTools;

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

		// Song/Week
		set('curBpm', Conductor.bpm);
		set('bpm', PlayState.SONG.bpm);
		set('scrollSpeed', PlayState.SONG.speed);
		set('crochet', Conductor.crochet);
		set('stepCrochet', Conductor.stepCrochet);
		set('songLength', FlxG.sound.music.length);
		set('songName', PlayState.SONG.song);
		set('startedCountdown', false);

		set('isStoryMode', PlayState.isStoryMode);
		set('difficulty', PlayState.storyDifficulty);
		set('difficultyName', CoolUtil.difficulties[PlayState.storyDifficulty]);
		set('weekRaw', PlayState.storyWeek);
		set('week', WeekData.weeksList[PlayState.storyWeek]);
		set('seenCutscene', PlayState.seenCutscene);

		// Camera
		set('cameraX', 0);
		set('cameraY', 0);
		set('defaultzooms', PlayState.instance.defaultCamZoom);

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
		set('version', MainMenuState.osEngineVersion.trim());

		set('inGameOver', false);
		set('deathFinish', false);
		set('mustHitSection', false);
		set('altAnim', false);
		set('gfSection', false);

		// PlayState ratings
		set('totalShits', PlayState.instance.shits);
		set('totalBads', PlayState.instance.bads);
		set('totalGoods', PlayState.instance.goods);
		set('totalSicks', PlayState.instance.sicks);
		set('totalPerfects', PlayState.instance.perfects);
		set('totalCombo', PlayState.instance.combo);

		// Gameplay settings
		set('healthGainMult', PlayState.instance.healthGain);
		set('healthLossMult', PlayState.instance.healthLoss);
		set('instakillOnMiss', PlayState.instance.instakillOnMiss);
		set('botPlay', PlayState.instance.cpuControlled);
		set('practice', PlayState.instance.practiceMode);
		set('chartMode', false);

		for (i in 0...4) {
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
		set('curBoyfriendX', 0);
		set('curBoyfriendY', 0);
		set('curOpponentX', 0);
		set('curOpponentY', 0);
		set('curGirlfriendX', 0);
		set('curGirlfriendY', 0);
		set('curDeathX', 0);
		set('curDeathY', 0);

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
		set('timeBarType', ClientPrefs.timeBarType);
		set('scoreZoom', ClientPrefs.scoreZoom);
		set('showStatus', ClientPrefs.showStatus);
		set('cameraZoomOnBeat', ClientPrefs.camZooms);
		set('flashingLights', ClientPrefs.flashing);
		set('noteOffset', ClientPrefs.noteOffset);
		set('healthBarAlpha', ClientPrefs.healthBarAlpha);
		set('noResetButton', ClientPrefs.noReset);
		set('lowQuality', ClientPrefs.lowQuality);

		set('comboOffset', ClientPrefs.comboOffset);
		set('ratingOffset', ClientPrefs.ratingOffset);
		set('noteSplash', ClientPrefs.noteSplashes);
		set('isShowcaseMode', ClientPrefs.showcaseMode);
		set('trialRules', ClientPrefs.trialrules);
		set('nitroRules', ClientPrefs.nitrorules);
		set('tntRules', ClientPrefs.tntrules);
		set('hudSize', ClientPrefs.hudSize);
		set('shadersActive', ClientPrefs.shadersActive);

		set('scriptName', scriptName);

		// Ratings
		set('isBad', ClientPrefs.badWindow);
		set('isGood', ClientPrefs.goodWindow);
		set('isSick', ClientPrefs.sickWindow);
		set('isPerfect', ClientPrefs.perfectWindow);

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

		Lua_helper.add_callback(lua, "getRunningScripts", function(){
			var runningScripts:Array<String> = [];
			for (idx in 0...PlayState.instance.luaArray.length)
				runningScripts.push(PlayState.instance.luaArray[idx].scriptName);


			return runningScripts;
		});

		Lua_helper.add_callback(lua, "callOnLuas", function(?funcName:String, ?args:Array<Dynamic>, ignoreStops=false, ignoreSelf=true, ?exclusions:Array<String>){
			if(funcName==null){
				#if (linc_luajit >= "0.0.6")
				LuaL.error(lua, "bad argument #1 to 'callOnLuas' (string expected, got nil)");
				#end
				return;
			}
			if(args==null)args = [];

			if(exclusions==null)exclusions=[];

			Lua.getglobal(lua, 'scriptName');
			var daScriptName = Lua.tostring(lua, -1);
			Lua.pop(lua, 1);
			if(ignoreSelf && !exclusions.contains(daScriptName))exclusions.push(daScriptName);
			PlayState.instance.callOnLuas(funcName, args, ignoreStops, exclusions);
		});

		Lua_helper.add_callback(lua, "callScript", function(?luaFile:String, ?funcName:String, ?args:Array<Dynamic>){
			if(luaFile==null){
				#if (linc_luajit >= "0.0.6")
				LuaL.error(lua, "bad argument #1 to 'callScript' (string expected, got nil)");
				#end
				return;
			}
			if(funcName==null){
				#if (linc_luajit >= "0.0.6")
				LuaL.error(lua, "bad argument #2 to 'callScript' (string expected, got nil)");
				#end
				return;
			}
			if(args==null){
				args = [];
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
						luaInstance.call(funcName, args);

						return;
					}

				}
			}
			Lua.pushnil(lua);

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
			var varValue:Array<String> = variable.split('.');
			var spr:FlxSprite = getObjectDirectly(varValue[0]);
			var gX = gridX==null?0:gridX;
			var gY = gridY==null?0:gridY;
			var animated = gX!=0 || gY!=0;

			if(varValue.length > 1) {
				spr = getVarInArray(getPropertyLoopThingWhatever(varValue), varValue[varValue.length-1]);
			}

			if(spr != null && image != null && image.length > 0)
			{
				spr.loadGraphic(Paths.image(image), animated, gX, gY);
			}
		});
		Lua_helper.add_callback(lua, "loadFrames", function(variable:String, image:String, spriteType:String = "sparrow") {
			var varValue:Array<String> = variable.split('.');
			var spr:FlxSprite = getObjectDirectly(varValue[0]);
			if(varValue.length > 1) {
				spr = getVarInArray(getPropertyLoopThingWhatever(varValue), varValue[varValue.length-1]);
			}

			if(spr != null && image != null && image.length > 0)
			{
				loadFrames(spr, image, spriteType);
			}
		});
		Lua_helper.add_callback(lua, 'openURL', function(url:String) {
			CoolUtil.browserLoad(url);
		});
		Lua_helper.add_callback(lua, "pcUserName", function() {
			return Sys.environment()["USERNAME"];
		});
		Lua_helper.add_callback(lua, "setRating", function(or:Int, nr:String) {
			var ratingarray = PlayState.ratingStuff;
			var targetrating = ratingarray[9];
			if (or < 10 && or > -1) {
				targetrating = ratingarray[or];
			} 
			targetrating[0] = nr;
		});

		// Propertys
		Lua_helper.add_callback(lua, "getProperty", function(variable:String) {
			@:privateAccess
			var varValue:Array<String> = variable.split('.');
			if(varValue.length > 1) {
				return getVarInArray(getPropertyLoopThingWhatever(varValue), varValue[varValue.length-1]);
			}
			return getVarInArray(getInstance(), variable);
		});
		Lua_helper.add_callback(lua, "setProperty", function(variable:String, value:Dynamic) {
			@:privateAccess
			var varValue:Array<String> = variable.split('.');
			if(varValue.length > 1) {
				setVarInArray(getPropertyLoopThingWhatever(varValue), varValue[varValue.length-1], value);
				return true;
			}
			setVarInArray(getInstance(), variable, value);
			return true;
		});
		Lua_helper.add_callback(lua, "getPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic) {
			@:privateAccess
			var varValues:Array<String> = obj.split('.');
			var realObject:Dynamic = Reflect.getProperty(getInstance(), obj);
			if(varValues.length>1)
				realObject = getPropertyLoopThingWhatever(varValues, true, false);


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
				realObject = getPropertyLoopThingWhatever(varValues, true, false);

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

		// Objects Layering
		Lua_helper.add_callback(lua, "getObjectOrder", function(obj:String) {
			var varValues:Array<String> = obj.split('.');
			var leObj:FlxBasic = getObjectDirectly(varValues[0]);
			if(varValues.length > 1) {
				leObj = getVarInArray(getPropertyLoopThingWhatever(varValues), varValues[varValues.length-1]);
			}

			if(leObj != null)
			{
				return getInstance().members.indexOf(leObj);
			}
			luaTrace("Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
			return -1;
		});
		Lua_helper.add_callback(lua, "setObjectOrder", function(obj:String, position:Int) {
			var varValues:Array<String> = obj.split('.');
			var leObj:FlxBasic = getObjectDirectly(varValues[0]);
			if(varValues.length > 1) {
				leObj = getVarInArray(getPropertyLoopThingWhatever(varValues), varValues[varValues.length-1]);
			}

			if(leObj != null) {
				getInstance().remove(leObj, true);
				getInstance().insert(position, leObj);
				return;
			}
			luaTrace("Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
		});

		// tweens
		Lua_helper.add_callback(lua, "doTweenX", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			var objectName:Dynamic = tweenVars(tag, vars);
			if(objectName != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(objectName, {x: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenY", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			var objectName:Dynamic = tweenVars(tag, vars);
			if(objectName != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(objectName, {y: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenAngle", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			var objectName:Dynamic = tweenVars(tag, vars);
			if(objectName != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(objectName, {angle: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenAlpha", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			var objectName:Dynamic = tweenVars(tag, vars);
			if(objectName != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(objectName, {alpha: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenZoom", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			var objectName:Dynamic = tweenVars(tag, vars);
			if(objectName != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(objectName, {zoom: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenColor", function(tag:String, vars:String, targetColor:String, duration:Float, ease:String) {
			var objectName:Dynamic = tweenVars(tag, vars);
			if(objectName != null) {
				var color:Int = Std.parseInt(targetColor);
				if(!targetColor.startsWith('0x')) color = Std.parseInt('0xff' + targetColor);

				var curColor:FlxColor = objectName.color;
				curColor.alphaFloat = objectName.alpha;
				PlayState.instance.modchartTweens.set(tag, FlxTween.color(objectName, duration, curColor, color, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.modchartTweens.remove(tag);
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenLinear", function(tag:String, vars:String, toX:Float, toY:Float, duration:Float, ease:String) {
			var objectName:Dynamic = tweenVars(tag, vars);
			if(objectName != null) {
				var fromX:Float = objectName.x;
				var fromY:Float = objectName.y;
				PlayState.instance.modchartTweens.set(tag, FlxTween.linearMotion(objectName, fromX, fromY, toX, toY, duration, true, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});

		// special Tweens
		Lua_helper.add_callback(lua, "doTweenCircular", function(tag:String, vars:String, centerPos:Array<Float>, circleConfig:Array<Float>, clockwise:Bool = true, duration:Float, ease:String) {
			var objectName:Dynamic = tweenVars(tag, vars);
			if(objectName != null) {
				if(centerPos == null) throw "The center point array is empty";
				if(circleConfig == null) throw "The center point array is empty";
				var centerX:Float = centerPos[0];
				var centerY:Float = centerPos[1];
				var radius:Float = circleConfig[0];
				var angle:Float = circleConfig[1];
				PlayState.instance.modchartTweens.set(tag, FlxTween.circularMotion(objectName, centerX, centerY, radius, angle, clockwise, duration, true, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenCurve", function(tag:String, vars:String, controlPos:Array<Float>, toPos:Array<Float>, duration:Float, ease:String) {
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
				PlayState.instance.modchartTweens.set(tag, FlxTween.quadMotion(objectName, fromX, fromY, controlX, controlY, toX, toY, duration, true, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenDualCurve", function(tag:String, vars:String, aControl:Array<Float>, bControl:Array<Float>, toPos:Array<Float>, duration:Float, ease:String) {
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
				PlayState.instance.modchartTweens.set(tag, FlxTween.cubicMotion(objectName, fromX, fromY, aX, aY, bX, bY, toX, toY, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		// path tween
		Lua_helper.add_callback(lua, "doTweenLinearPath", function(tag:String, vars:String, points:Array<Array<Float>>, duration:Float, ease:String) {
			var objectName:Dynamic = tweenVars(tag, vars);
			if(objectName != null) {
				if(points.length < 1) throw "The points array must have at least 1 additional element";
				var allPoints:Array<FlxPoint> = [];
				var defaultPoint:FlxPoint = new FlxPoint(objectName.x, objectName.y);
				allPoints.push(defaultPoint);
				for(subArray in points) {
					var x:Float = 0;
					var y:Float = 0;
					if (subArray.length >= 2) {
						x = subArray[0];
						y = subArray[1];
					} else {
						throw "the subArray must have 2 valid values"; // This is to prevent sudden crashes that close the game
					}
					var newPointG:FlxPoint = new FlxPoint(x, y);
					allPoints.push(newPointG);
				}
				PlayState.instance.modchartTweens.set(tag, FlxTween.linearPath(objectName, allPoints, duration, true, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "doTweenCurvePath", function(tag:String, vars:String, points:Array<Array<Float>>, duration:Float, ease:String) {
			var objectName:Dynamic = tweenVars(tag, vars);
			if(objectName != null) {
				if(points.length < 2) throw "The points array must have at least 2 additional element";
				if(points.length % 2 != 0) throw "The points array must have an even number of elements";
				var allPoints:Array<FlxPoint> = [];
				var defaultPoint:FlxPoint = new FlxPoint(objectName.x, objectName.y);
				allPoints.push(defaultPoint);
				for(subArray in points) {
					var x:Float = 1;
					var y:Float = 1;
					if(subArray.length >= 2) {
						if(subArray.length % 2 == 0 && subArray.length != 0) {
							if(subArray[0] != 0) x = subArray[0];
							if(subArray[1] != 0) y = subArray[1];
						}else{
							x = subArray[0];
							y = subArray[1];
						}
					}else{
						throw "the subArray must have 2 valid values"; // This is to prevent sudden crashes that close the game
					}
					var newPointG:FlxPoint = new FlxPoint(x, y);
					allPoints.push(newPointG);
				}
				PlayState.instance.modchartTweens.set(tag, FlxTween.quadPath(objectName, allPoints, duration, true, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});

		// tween for strums
		Lua_helper.add_callback(lua, "noteTweenX", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var theNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(theNote != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(theNote, {x: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenY", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var theNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(theNote != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(theNote, {y: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenAngle", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var theNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(theNote != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(theNote, {angle: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenAlpha", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var testicle:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(testicle != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(testicle, {alpha: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenDirection", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var theNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(theNote != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(theNote, {direction: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenScaleX", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var theNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(theNote != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(theNote.scale, {x: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenScaleY", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var theNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];

			if(theNote != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.tween(theNote.scale, {y: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenCircle", function(tag:String, note:Int, centerPos:Array<Float>, circleConfig:Array<Float>, clockwise:Bool = true, duration:Float, ease:String) {
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
				PlayState.instance.modchartTweens.set(tag, FlxTween.circularMotion(theNote, centerX, centerY, radius, angle, clockwise, duration, true, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenLinear", function(tag:String, note:Int, toX:Float, toY:Float, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var theNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];
			var fromX:Float = theNote.x;
			var fromY:Float = theNote.y;

			if(theNote != null) {
				PlayState.instance.modchartTweens.set(tag, FlxTween.linearMotion(theNote, fromX, fromY, toX, toY, duration, true, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenLinearPath", function(tag:String, note:Int, points:Array<Array<Float>>, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var theNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];
			if(theNote != null) {
				if(points.length < 1) throw "The points array must have at least 1 additional element";
				var allPoints:Array<FlxPoint> = [];
				var defaultPoint:FlxPoint = new FlxPoint(theNote.x, theNote.y);
				allPoints.push(defaultPoint);
				for(subArray in points) {
					var x:Float = 0;
					var y:Float = 0;
					if (subArray.length >= 2) {
						x = subArray[0];
						y = subArray[1];
					} else {
						throw "the subArray must have 2 valid values"; // This is to prevent sudden crashes that close the game
					}
					var newPointG:FlxPoint = new FlxPoint(x, y);
					allPoints.push(newPointG);
				}
				PlayState.instance.modchartTweens.set(tag, FlxTween.linearPath(theNote, allPoints, duration, true, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "noteTweenCurvePath", function(tag:String, note:Int, points:Array<Array<Float>>, duration:Float, ease:String) {
			cancelTween(tag);
			if(note < 0) note = 0;
			var theNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];
			if(theNote != null) {
				if(points.length < 2) throw "The points array must have at least 2 additional element";
				if(points.length % 2 != 0) throw "The points array must have an even number of elements";
				var allPoints:Array<FlxPoint> = [];
				var defaultPoint:FlxPoint = new FlxPoint(theNote.x, theNote.y);
				allPoints.push(defaultPoint);
				for(subArray in points) {
					var x:Float = 1;
					var y:Float = 1;
					if(subArray.length >= 2) {
						if(subArray.length % 2 == 0 && subArray.length != 0) {
							if(subArray[0] != 0) x = subArray[0];
							if(subArray[1] != 0) y = subArray[1];
						}else{
							x = subArray[0];
							y = subArray[1];
						}
					}else{
						throw "the subArray must have 2 valid values"; // This is to prevent sudden crashes that close the game
					}
					var newPointG:FlxPoint = new FlxPoint(x, y);
					allPoints.push(newPointG);
				}
				PlayState.instance.modchartTweens.set(tag, FlxTween.quadPath(theNote, allPoints, duration, true, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						PlayState.instance.callOnLuas('onTweenCompleted', [tag]);
						PlayState.instance.modchartTweens.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "cancelTween", function(tag:String) {
			cancelTween(tag);
		});

		// Special Flicker
		Lua_helper.add_callback(lua, "startFlicker", function(tag:String, vars:String, duration:Float, interval:Float, ?endVisibility:Bool = true) {
			var objectName:Dynamic = flickVars(tag, vars);
			if(objectName != null) {
				PlayState.instance.modchartFlickers.set(tag, FlxFlicker.flicker(objectName, duration, interval, endVisibility, false, 
					function(flick: FlxFlicker) {
						PlayState.instance.callOnLuas('onFlickerCompleted', [tag]);
						PlayState.instance.modchartFlickers.remove(tag);
					}
				));
			} else {
				luaTrace('Couldnt find object: ' + vars, false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "cancelFlicker", function(tag:String) {
			cancelFlicker(tag);
		});

		// Timer
		Lua_helper.add_callback(lua, "runTimer", function(tag:String, time:Float = 1, loops:Int = 1, ?extraVars:Array<Dynamic>) {
			cancelTimer(tag);
			PlayState.instance.modchartTimers.set(tag, new FlxTimer().start(time, function(tmr:FlxTimer) {
				if(tmr.finished) {
					PlayState.instance.modchartTimers.remove(tag);
				}
				PlayState.instance.callOnLuas('onTimerCompleted', [tag, tmr.loops, tmr.loopsLeft, extraVars]);
				//trace('Timer Completed: ' + tag);
			}, loops));
		});
		Lua_helper.add_callback(lua, "cancelTimer", function(tag:String) {
			cancelTimer(tag);
		});
	
		// Mouse Functions
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

		// gameplay functions
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
		Lua_helper.add_callback(lua, "setScore", function(value:Int = 0) {
			PlayState.instance.songScore = value;
			PlayState.instance.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "setMisses", function(value:Int = 0) {
			PlayState.instance.songMisses = value;
			PlayState.instance.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "setHits", function(value:Int = 0) {
			PlayState.instance.songHits = value;
			PlayState.instance.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "getScore", function() {
			return PlayState.instance.songScore;
		});
		Lua_helper.add_callback(lua, "getMisses", function() {
			return PlayState.instance.songMisses;
		});
		Lua_helper.add_callback(lua, "getHits", function() {
			return PlayState.instance.songHits;
		});

		Lua_helper.add_callback(lua, "setHealth", function(value:Float = 0) {
			PlayState.instance.health = value;
		});
		Lua_helper.add_callback(lua, "addHealth", function(value:Float = 0) {
			PlayState.instance.health += value;
		});
		Lua_helper.add_callback(lua, "getHealth", function() {
			return PlayState.instance.health;
		});

		Lua_helper.add_callback(lua, "getColorFromHex", function(color:String) {
			if(!color.startsWith('0x')) color = '0xff' + color;
			return Std.parseInt(color);
		});

		Lua_helper.add_callback(lua, "keyboardJustPressed", function(name:String)
		{
			return Reflect.getProperty(FlxG.keys.justPressed, name);
		});
		Lua_helper.add_callback(lua, "keyboardPressed", function(name:String)
		{
			return Reflect.getProperty(FlxG.keys.pressed, name);
		});
		Lua_helper.add_callback(lua, "keyboardReleased", function(name:String)
		{
			return Reflect.getProperty(FlxG.keys.justReleased, name);
		});

		Lua_helper.add_callback(lua, "anyGamepadJustPressed", function(name:String)
		{
			return FlxG.gamepads.anyJustPressed(name);
		});
		Lua_helper.add_callback(lua, "anyGamepadPressed", function(name:String)
		{
			return FlxG.gamepads.anyPressed(name);
		});
		Lua_helper.add_callback(lua, "anyGamepadReleased", function(name:String)
		{
			return FlxG.gamepads.anyJustReleased(name);
		});

		Lua_helper.add_callback(lua, "gamepadAnalogX", function(id:Int, ?leftStick:Bool = true)
		{
			return FlxG.gamepads.getByID(id).getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		Lua_helper.add_callback(lua, "gamepadAnalogY", function(id:Int, ?leftStick:Bool = true)
		{
			return FlxG.gamepads.getByID(id).getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		Lua_helper.add_callback(lua, "gamepadJustPressed", function(id:Int, name:String)
		{
			return Reflect.getProperty(FlxG.gamepads.getByID(id).justPressed, name);
		});
		Lua_helper.add_callback(lua, "gamepadPressed", function(id:Int, name:String)
		{
			return Reflect.getProperty(FlxG.gamepads.getByID(id).pressed, name);
		});
		Lua_helper.add_callback(lua, "gamepadReleased", function(id:Int, name:String)
		{
			return Reflect.getProperty(FlxG.gamepads.getByID(id).justReleased, name);
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
		Lua_helper.add_callback(lua, "addCharacterToList", function(name:String, type:String) {
			var charType:Int = 0;
			switch(type.toLowerCase()) {
				case 'dad': charType = 1;
				case 'gf' | 'girlfriend': charType = 2;
			}
			PlayState.instance.addCharacterToList(name, charType);
		});
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
		Lua_helper.add_callback(lua, "precacheImage", function(name:String) {
			Paths.returnGraphic(name);
		});
		Lua_helper.add_callback(lua, "precacheSound", function(name:String) {
			CoolUtil.precacheSound(name);
		});
		Lua_helper.add_callback(lua, "precacheMusic", function(name:String) {
			CoolUtil.precacheMusic(name);
		});
		Lua_helper.add_callback(lua, "triggerEvent", function(name:String, arg1:Dynamic, arg2:Dynamic) {
			var value1:String = arg1;
			var value2:String = arg2;
			PlayState.instance.triggerEventNote(name, value1, value2);
			return true;
		});

		Lua_helper.add_callback(lua, "startCountdown", function() {
			PlayState.instance.startCountdown();
			return true;
		});
		Lua_helper.add_callback(lua, "endSong", function() {
			PlayState.instance.KillNotes();
			PlayState.instance.endSong();
			return true;
		});
		Lua_helper.add_callback(lua, "restartSong", function(?skipTransition:Bool = false) {
			PlayState.instance.persistentUpdate = false;
			PauseSubState.restartSong(skipTransition);
			return true;
		});
		Lua_helper.add_callback(lua, "exitSong", function(?skipTransition:Bool = false) {
			if(skipTransition)
			{
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
		Lua_helper.add_callback(lua, "getSongPosition", function() {
			return Conductor.songPosition;
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
		Lua_helper.add_callback(lua, "cameraSetTarget", function(target:String) {
			var isDad:Bool = false;
			if(target == 'dad') {
				isDad = true;
			}
			PlayState.instance.moveCamera(isDad);
			return isDad;
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
		Lua_helper.add_callback(lua, "cameraShake", function(camera:String, intensity:Float, duration:Float) {
			cameraFromString(camera).shake(intensity, duration);
		});

		Lua_helper.add_callback(lua, "cameraFlash", function(camera:String, color:String, duration:Float, forced:Bool) {
			var colorNum:Int = Std.parseInt(color);
			if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);
			cameraFromString(camera).flash(colorNum, duration,null,forced);
		});
		Lua_helper.add_callback(lua, "cameraFade", function(camera:String, color:String, duration:Float, forced:Bool) {
			var colorNum:Int = Std.parseInt(color);
			if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);
			cameraFromString(camera).fade(colorNum, duration,false,null,forced);
		});
		Lua_helper.add_callback(lua, "setRatingPercent", function(value:Float) {
			PlayState.instance.ratingPercent = value;
		});
		Lua_helper.add_callback(lua, "setRatingName", function(value:String) {
			PlayState.instance.ratingName = value;
		});
		Lua_helper.add_callback(lua, "setBotPlayText", function(value:String) {
			PlayState.instance.botplayTxt.text = value;
		});
		Lua_helper.add_callback(lua, "setWatermarkText", function(value:String) {
			PlayState.instance.songTxt.text = value;
		});
		Lua_helper.add_callback(lua, "setWindowTitle", function(value:String) {
			openfl.Lib.application.window.title = value;
		});
		Lua_helper.add_callback(lua, "setRatingFC", function(value:String) {
			PlayState.instance.ratingFC = value;
		});
		Lua_helper.add_callback(lua, "getMouseX", function(camera:String) {
			var cam:FlxCamera = cameraFromString(camera);
			return FlxG.mouse.getScreenPosition(cam).x;
		});
		Lua_helper.add_callback(lua, "getMouseY", function(camera:String) {
			var cam:FlxCamera = cameraFromString(camera);
			return FlxG.mouse.getScreenPosition(cam).y;
		});

		Lua_helper.add_callback(lua, "getMidpointX", function(variable:String) {
			var varValues:Array<String> = variable.split('.');
			var obj:FlxSprite = getObjectDirectly(varValues[0]);
			if(varValues.length > 1) {
				obj = getVarInArray(getPropertyLoopThingWhatever(varValues), varValues[varValues.length-1]);
			}
			if(obj != null) return obj.getMidpoint().x;

			return 0;
		});
		Lua_helper.add_callback(lua, "getMidpointY", function(variable:String) {
			var varValues:Array<String> = variable.split('.');
			var obj:FlxSprite = getObjectDirectly(varValues[0]);
			if(varValues.length > 1) {
				obj = getVarInArray(getPropertyLoopThingWhatever(varValues), varValues[varValues.length-1]);
			}
			if(obj != null) return obj.getMidpoint().y;

			return 0;
		});
		Lua_helper.add_callback(lua, "getGraphicMidpointX", function(variable:String) {
			var varValues:Array<String> = variable.split('.');
			var obj:FlxSprite = getObjectDirectly(varValues[0]);
			if(varValues.length > 1) {
				obj = getVarInArray(getPropertyLoopThingWhatever(varValues), varValues[varValues.length-1]);
			}
			if(obj != null) return obj.getGraphicMidpoint().x;

			return 0;
		});
		Lua_helper.add_callback(lua, "getGraphicMidpointY", function(variable:String) {
			var varValues:Array<String> = variable.split('.');
			var obj:FlxSprite = getObjectDirectly(varValues[0]);
			if(varValues.length > 1) {
				obj = getVarInArray(getPropertyLoopThingWhatever(varValues), varValues[varValues.length-1]);
			}
			if(obj != null) return obj.getGraphicMidpoint().y;

			return 0;
		});
		Lua_helper.add_callback(lua, "getScreenPositionX", function(variable:String) {
			var varValues:Array<String> = variable.split('.');
			var obj:FlxSprite = getObjectDirectly(varValues[0]);
			if(varValues.length > 1) {
				obj = getVarInArray(getPropertyLoopThingWhatever(varValues), varValues[varValues.length-1]);
			}
			if(obj != null) return obj.getScreenPosition().x;

			return 0;
		});
		Lua_helper.add_callback(lua, "getScreenPositionY", function(variable:String) {
			var varValues:Array<String> = variable.split('.');
			var obj:FlxSprite = getObjectDirectly(varValues[0]);
			if(varValues.length > 1) {
				obj = getVarInArray(getPropertyLoopThingWhatever(varValues), varValues[varValues.length-1]);
			}
			if(obj != null) return obj.getScreenPosition().y;

			return 0;
		});
		Lua_helper.add_callback(lua, "characterDance", function(character:String) {
			switch(character.toLowerCase()) {
				case 'dad': PlayState.instance.dad.dance();
				case 'gf' | 'girlfriend': if(PlayState.instance.gf != null) PlayState.instance.gf.dance();
				default: PlayState.instance.boyfriend.dance();
			}
		});
		Lua_helper.add_callback(lua, "setGfSpeed", function(speed:Float) {
			var newSpeed:Int = Std.int(speed);
			if(Math.isNaN(newSpeed) || newSpeed < 1) newSpeed = 1;
			PlayState.instance.gfSpeed = newSpeed;
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

		Lua_helper.add_callback(lua, "makeLuaSprite", function(tag:String, image:String, x:Float, y:Float) {
			tag = tag.replace('.', '');
			resetSpriteTag(tag);
			var leSprite:ModchartSprite = new ModchartSprite(x, y);
			if(image != null && image.length > 0)
			{
				leSprite.loadGraphic(Paths.image(image));
			}
			leSprite.antialiasing = ClientPrefs.globalAntialiasing;
			PlayState.instance.modchartSprites.set(tag, leSprite);
			leSprite.active = true;
		});	
		Lua_helper.add_callback(lua, "makeLuaShaderSprite", function(tag:String, shader:String, x:Float, y:Float,optimize:Bool=false) {
			tag = tag.replace('.', '');
			resetSpriteTag(tag);
			var leSprite:ModchartSprite = new ModchartSprite(x, y,true,shader,optimize);
			leSprite.antialiasing = ClientPrefs.globalAntialiasing;

			PlayState.instance.modchartSprites.set(tag, leSprite);
			leSprite.active = true;
		});
		Lua_helper.add_callback(lua, "makeAnimatedLuaSprite", function(tag:String, image:String, x:Float, y:Float, ?spriteType:String = "sparrow") {
			tag = tag.replace('.', '');
			resetSpriteTag(tag);
			var leSprite:ModchartSprite = new ModchartSprite(x, y);

			loadFrames(leSprite, image, spriteType);
			leSprite.antialiasing = ClientPrefs.globalAntialiasing;
			PlayState.instance.modchartSprites.set(tag, leSprite);
		});

		Lua_helper.add_callback(lua, "makeGraphic", function(obj:String, width:Int, height:Int, color:String) {
			var colorNum:Int = Std.parseInt(color);
			if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);

			var spr:FlxSprite = PlayState.instance.getLuaObject(obj,false);
			if(spr!=null) {
				PlayState.instance.getLuaObject(obj,false).makeGraphic(width, height, colorNum);
				return;
			}

			var object:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(object != null) {
				object.makeGraphic(width, height, colorNum);
			}
		});
		Lua_helper.add_callback(lua, "addAnimationByPrefix", function(obj:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true) {
			if(PlayState.instance.getLuaObject(obj,false)!=null) {
				var animatinin:FlxSprite = PlayState.instance.getLuaObject(obj,false);
				animatinin.animation.addByPrefix(name, prefix, framerate, loop);
				if(animatinin.animation.curAnim == null) {
					animatinin.animation.play(name, true);
				}
				return;
			}

			var animatinin:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(animatinin != null) {
				animatinin.animation.addByPrefix(name, prefix, framerate, loop);
				if(animatinin.animation.curAnim == null) {
					animatinin.animation.play(name, true);
				}
			}
		});

		Lua_helper.add_callback(lua, "addAnimation", function(obj:String, name:String, frames:Array<Int>, framerate:Int = 24, loop:Bool = true) {
			if(PlayState.instance.getLuaObject(obj,false)!=null) {
				var animatinin:FlxSprite = PlayState.instance.getLuaObject(obj,false);
				animatinin.animation.add(name, frames, framerate, loop);
				if(animatinin.animation.curAnim == null) {
					animatinin.animation.play(name, true);
				}
				return;
			}

			var animatinin:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(animatinin != null) {
				animatinin.animation.add(name, frames, framerate, loop);
				if(animatinin.animation.curAnim == null) {
					animatinin.animation.play(name, true);
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
				var pussy:FlxSprite = PlayState.instance.getLuaObject(obj,false);
				pussy.animation.addByIndices(name, prefix, indie, '', framerate, false);
				if(pussy.animation.curAnim == null) {
					pussy.animation.play(name, true);
				}
				return true;
			}

			var pussy:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(pussy != null) {
				pussy.animation.addByIndices(name, prefix, indie, '', framerate, false);
				if(pussy.animation.curAnim == null) {
					pussy.animation.play(name, true);
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
						spr.animation.play(name, forced, reverse, startFrame);
				}
				return true;
			}
			return false;
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

		Lua_helper.add_callback(lua, "setScrollFactor", function(obj:String, scrollX:Float, scrollY:Float) {
			if(PlayState.instance.getLuaObject(obj,false)!=null) {
				PlayState.instance.getLuaObject(obj,false).scrollFactor.set(scrollX, scrollY);
				return;
			}

			var object:FlxObject = Reflect.getProperty(getInstance(), obj);
			if(object != null) {
				object.scrollFactor.set(scrollX, scrollY);
			}
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
		
		Lua_helper.add_callback(lua, "setupStageObject", function(path:String) {
			if (FileSystem.exists(Paths.modsObjects(path))) {
				var jsonFormatted:Dynamic = File.getContent(Paths.modsObjects(path)).trim();
				jsonFormatted = Json.parse(jsonFormatted);
				
				var tag = jsonFormatted.tag;
				var x = jsonFormatted.x;
				var y = jsonFormatted.y;
				var image = jsonFormatted.path;
				var isanimated = jsonFormatted.animated;
				var scalex = jsonFormatted.scalex;
				var scaley = jsonFormatted.scaley;
				var front = false;

				var updateHitbox = true;

				if (!isanimated) {
					Lua_helper.callbacks['makeLuaSprite'](tag, image, x, y);
					Lua_helper.callbacks['scaleObject'](tag, scalex, scaley);
					Lua_helper.callbacks['addLuaSprite'](tag, front);
				}
			}
		});
		Lua_helper.add_callback(lua, "setGraphicSize", function(obj:String, x:Int, y:Int = 0, updateHitbox:Bool = true) {
			if(PlayState.instance.getLuaObject(obj)!=null) {
				var leImage:FlxSprite = PlayState.instance.getLuaObject(obj);
				leImage.setGraphicSize(x, y);
				if(updateHitbox) leImage.updateHitbox();
				return;
			}

			var varValues:Array<String> = obj.split('.');
			var inLuaPicture:FlxSprite = getObjectDirectly(varValues[0]);
			if(varValues.length > 1) {
				inLuaPicture = getVarInArray(getPropertyLoopThingWhatever(varValues), varValues[varValues.length-1]);
			}

			if(inLuaPicture != null) {
				inLuaPicture.setGraphicSize(x, y);
				if(updateHitbox) inLuaPicture.updateHitbox();
				return;
			}
			luaTrace('Couldnt find object: ' + obj, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "scaleObject", function(obj:String, x:Float, y:Float, updateHitbox:Bool = true) {
			if(PlayState.instance.getLuaObject(obj)!=null) {
				var leImage:FlxSprite = PlayState.instance.getLuaObject(obj);
				leImage.scale.set(x, y);
				if(updateHitbox) leImage.updateHitbox();
				return;
			}

			var varValues:Array<String> = obj.split('.');
			var inLuaPicture:FlxSprite = getObjectDirectly(varValues[0]);
			if(varValues.length > 1) {
				inLuaPicture = getVarInArray(getPropertyLoopThingWhatever(varValues), varValues[varValues.length-1]);
			}

			if(inLuaPicture != null) {
				inLuaPicture.scale.set(x, y);
				if(updateHitbox) inLuaPicture.updateHitbox();
				return;
			}
			luaTrace('Couldnt find object: ' + obj, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "updateHitbox", function(obj:String) {
			if(PlayState.instance.getLuaObject(obj)!=null) {
				var spriteBox:FlxSprite = PlayState.instance.getLuaObject(obj);
				spriteBox.updateHitbox();
				return;
			}

			var inLuaPicture:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(inLuaPicture != null) {
				inLuaPicture.updateHitbox();
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

		Lua_helper.add_callback(lua, "isNoteChild", function(parentID:Int, childID:Int){
			var parent: Note = cast PlayState.instance.getLuaObject('note${parentID}',false);
			var child: Note = cast PlayState.instance.getLuaObject('note${childID}',false);
			if(parent!=null && child!=null)
				return parent.tail.contains(child);

			luaTrace('${parentID} or ${childID} is not a valid note ID', false, false, FlxColor.RED);
			return false;
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

		Lua_helper.add_callback(lua, "luaSpriteExists", function(tag:String) {
			return PlayState.instance.modchartSprites.exists(tag);
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

		Lua_helper.add_callback(lua, "setHealthBarColors", function(leftHex:String, rightHex:String) {
			var left:FlxColor = Std.parseInt(leftHex);
			if(!leftHex.startsWith('0x')) left = Std.parseInt('0xff' + leftHex);
			var right:FlxColor = Std.parseInt(rightHex);
			if(!rightHex.startsWith('0x')) right = Std.parseInt('0xff' + rightHex);

			PlayState.instance.healthBar.createFilledBar(left, right);
			PlayState.instance.healthBar.updateBar();
		});
		Lua_helper.add_callback(lua, "setTimeBarColors", function(leftHex:String, rightHex:String) {
			var left:FlxColor = Std.parseInt(leftHex);
			if(!leftHex.startsWith('0x')) left = Std.parseInt('0xff' + leftHex);
			var right:FlxColor = Std.parseInt(rightHex);
			if(!rightHex.startsWith('0x')) right = Std.parseInt('0xff' + rightHex);

			PlayState.instance.timeBar.createFilledBar(right, left);
			PlayState.instance.timeBar.updateBar();
		});

		Lua_helper.add_callback(lua, "setObjectCamera", function(obj:String, camera:String = '') {
			/*if(PlayState.instance.modchartSprites.exists(obj)) {
				PlayState.instance.modchartSprites.get(obj).cameras = [cameraFromString(camera)];
				return true;
			}
			else if(PlayState.instance.modchartTexts.exists(obj)) {
				PlayState.instance.modchartTexts.get(obj).cameras = [cameraFromString(camera)];
				return true;
			}*/
			var real = PlayState.instance.getLuaObject(obj);
			if(real!=null){
				real.cameras = [cameraFromString(camera)];
				return true;
			}

			var theArray:Array<String> = obj.split('.');
			var object:FlxSprite = getObjectDirectly(theArray[0]);
			if(theArray.length > 1) {
				object = getVarInArray(getPropertyLoopThingWhatever(theArray), theArray[theArray.length-1]);
			}

			if(object != null) {
				object.cameras = [cameraFromString(camera)];
				return true;
			}
			luaTrace("Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setBlendMode", function(obj:String, blend:String = '') {
			var real = PlayState.instance.getLuaObject(obj);
			if(real!=null) {
				real.blend = blendModeFromString(blend);
				return true;
			}

			var varValues:Array<String> = obj.split('.');
			var spr:FlxSprite = getObjectDirectly(varValues[0]);
			if(varValues.length > 1) {
				spr = getVarInArray(getPropertyLoopThingWhatever(varValues), varValues[varValues.length-1]);
			}

			if(spr != null) {
				spr.blend = blendModeFromString(blend);
				return true;
			}
			luaTrace("Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "screenCenter", function(obj:String, pos:String = 'xy') {
			var spr:FlxSprite = PlayState.instance.getLuaObject(obj);

			if(spr==null){
				var varValues:Array<String> = obj.split('.');
				spr = getObjectDirectly(varValues[0]);
				if(varValues.length > 1) {
					spr = getVarInArray(getPropertyLoopThingWhatever(varValues), varValues[varValues.length-1]);
				}
			}

			if(spr != null)
			{
				switch(pos.trim().toLowerCase())
				{
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
		Lua_helper.add_callback(lua, "objectsOverlap", function(obj1:String, obj2:String) {
			var namesArray:Array<String> = [obj1, obj2];
			var objectsArray:Array<FlxSprite> = [];
			for (i in 0...namesArray.length)
			{
				var real = PlayState.instance.getLuaObject(namesArray[i]);
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
		Lua_helper.add_callback(lua, "getPixelColor", function(obj:String, x:Int, y:Int) {
			var leObject:Array<String> = obj.split('.');
			var spr:FlxSprite = getObjectDirectly(leObject[0]);
			if(leObject.length > 1) {
				spr = getVarInArray(getPropertyLoopThingWhatever(leObject), leObject[leObject.length-1]);
			}

			if(spr != null)
			{
				if(spr.framePixels != null) spr.framePixels.getPixel32(x, y);
				return spr.pixels.getPixel32(x, y);
			}
			return 0;
		});
		Lua_helper.add_callback(lua, "getRandomInt", function(min:Int, max:Int = FlxMath.MAX_VALUE_INT, exclude:String = '') {
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Int> = [];
			for (i in 0...excludeArray.length)
			{
				toExclude.push(Std.parseInt(excludeArray[i].trim()));
			}
			return FlxG.random.int(min, max, toExclude);
		});
		Lua_helper.add_callback(lua, "getRandomFloat", function(min:Float, max:Float = 1, exclude:String = '') {
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Float> = [];
			for (i in 0...excludeArray.length)
			{
				toExclude.push(Std.parseFloat(excludeArray[i].trim()));
			}
			return FlxG.random.float(min, max, toExclude);
		});
		Lua_helper.add_callback(lua, "getRandomBool", function(chance:Float = 50) {
			return FlxG.random.bool(chance);
		});
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

		Lua_helper.add_callback(lua, "playMusic", function(sound:String, volume:Float = 1, loop:Bool = false) {
			FlxG.sound.playMusic(Paths.music(sound), volume, loop);
		});
		Lua_helper.add_callback(lua, "playSound", function(sound:String, volume:Float = 1, ?tag:String = null) {
			if(tag != null && tag.length > 0) {
				tag = tag.replace('.', '');
				if(PlayState.instance.modchartSounds.exists(tag)) {
					PlayState.instance.modchartSounds.get(tag).stop();
				}
				PlayState.instance.modchartSounds.set(tag, FlxG.sound.play(Paths.sound(sound), volume, false, function() {
					PlayState.instance.modchartSounds.remove(tag);
					PlayState.instance.callOnLuas('onSoundFinished', [tag]);
				}));
				return;
			}
			FlxG.sound.play(Paths.sound(sound), volume);
		});
		Lua_helper.add_callback(lua, "stopSound", function(tag:String) {
			if(tag != null && tag.length > 1 && PlayState.instance.modchartSounds.exists(tag)) {
				PlayState.instance.modchartSounds.get(tag).stop();
				PlayState.instance.modchartSounds.remove(tag);
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

		Lua_helper.add_callback(lua, "debugPrint", function(text1:Dynamic = '', text2:Dynamic = '', text3:Dynamic = '', text4:Dynamic = '', text5:Dynamic = '') {
			if (text1 == null) text1 = '';
			if (text2 == null) text2 = '';
			if (text3 == null) text3 = '';
			if (text4 == null) text4 = '';
			if (text5 == null) text5 = '';
			luaTrace('' + text1 + text2 + text3 + text4 + text5, true, false);
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


		// LUA TEXTS
		Lua_helper.add_callback(lua, "makeLuaText", function(tag:String, text:String, width:Int, x:Float, y:Float) {
			tag = tag.replace('.', '');
			resetTextTag(tag);
			var leText:ModchartText = new ModchartText(x, y, text, width);
			PlayState.instance.modchartTexts.set(tag, leText);
		});

		Lua_helper.add_callback(lua, "setTextString", function(tag:String, text:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.text = text;
			}
		});
		Lua_helper.add_callback(lua, "setTextSize", function(tag:String, size:Int) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.size = size;
			}
		});
		Lua_helper.add_callback(lua, "setTextWidth", function(tag:String, width:Float) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.fieldWidth = width;
			}
		});
		Lua_helper.add_callback(lua, "setTextBorder", function(tag:String, size:Int, color:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				var colorNum:Int = Std.parseInt(color);
				if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);

				obj.borderSize = size;
				obj.borderColor = colorNum;
			}
		});
		Lua_helper.add_callback(lua, "setTextColor", function(tag:String, color:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				var colorNum:Int = Std.parseInt(color);
				if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);

				obj.color = colorNum;
			}
		});
		Lua_helper.add_callback(lua, "setTextFont", function(tag:String, newFont:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.font = Paths.font(newFont);
			}
		});
		Lua_helper.add_callback(lua, "setTextItalic", function(tag:String, italic:Bool) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.italic = italic;
			}
		});
		Lua_helper.add_callback(lua, "setTextAlignment", function(tag:String, alignment:String = 'left') {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				obj.alignment = LEFT;
				switch(alignment.trim().toLowerCase())
				{
					case 'right':
						obj.alignment = RIGHT;
					case 'center':
						obj.alignment = CENTER;
				}
			}
		});

		Lua_helper.add_callback(lua, "getTextString", function(tag:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				return obj.text;
			}
			return null;
		});
		Lua_helper.add_callback(lua, "getTextSize", function(tag:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				return obj.size;
			}
			return -1;
		});
		Lua_helper.add_callback(lua, "getTextFont", function(tag:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				return obj.font;
			}
			return null;
		});
		Lua_helper.add_callback(lua, "getTextWidth", function(tag:String) {
			var obj:FlxText = getTextObject(tag);
			if(obj != null)
			{
				return obj.fieldWidth;
			}
			return 0;
		});

		Lua_helper.add_callback(lua, "addLuaText", function(tag:String) {
			if(PlayState.instance.modchartTexts.exists(tag)) {
				var textamint:ModchartText = PlayState.instance.modchartTexts.get(tag);
				if(!textamint.wasAdded) {
					getInstance().add(textamint);
					textamint.wasAdded = true;
					//trace('added a thing: ' + tag);
				}
			}
		});
		Lua_helper.add_callback(lua, "removeLuaText", function(tag:String, destroy:Bool = true) {
			if(!PlayState.instance.modchartTexts.exists(tag)) {
				return;
			}

			var byeText:ModchartText = PlayState.instance.modchartTexts.get(tag);
			if(destroy) {
				byeText.kill();
			}

			if(byeText.wasAdded) {
				getInstance().remove(byeText, true);
				byeText.wasAdded = false;
			}

			if(destroy) {
				byeText.destroy();
				PlayState.instance.modchartTexts.remove(tag);
			}
		});

		Lua_helper.add_callback(lua, "initSaveData", function(name:String, ?folder:String = 'psychenginemods') {
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
				var retVal:Dynamic = Reflect.field(PlayState.instance.modchartSaves.get(name).data, field);
				return retVal;
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
		Lua_helper.add_callback(lua, "getTextFromFile", function(path:String, ?ignoreModFolders:Bool = false) {
			return Paths.getTextFromFile(path, ignoreModFolders);
		});

		// DEPRECATED, DONT MESS WITH THESE SHITS, ITS JUST THERE FOR BACKWARD COMPATIBILITY
		Lua_helper.add_callback(lua, "objectPlayAnimation", function(obj:String, name:String, forced:Bool = false, ?startFrame:Int = 0) {
			luaTrace("objectPlayAnimation is deprecated! Use playAnim instead", false, true);
			if(PlayState.instance.getLuaObject(obj,false) != null) {
				PlayState.instance.getLuaObject(obj,false).animation.play(name, forced, false, startFrame);
				return true;
			}

			var spr:FlxSprite = Reflect.getProperty(getInstance(), obj);
			if(spr != null) {
				spr.animation.play(name, forced, false, startFrame);
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
				var pussy:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
				pussy.animation.addByIndices(name, prefix, numbers, '', framerate, false);
				if(pussy.animation.curAnim == null) {
					pussy.animation.play(name, true);
				}
			}
		});
		Lua_helper.add_callback(lua, "luaSpritePlayAnimation", function(tag:String, name:String, forced:Bool = false) {
			luaTrace("luaSpritePlayAnimation is deprecated! Use playAnim instead", false, true);
			if(PlayState.instance.modchartSprites.exists(tag)) {
				PlayState.instance.modchartSprites.get(tag).animation.play(name, forced);
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

		Lua_helper.add_callback(lua, "createShaders", function(fileName:String, ?optimize:Bool = false) {
			if (ClientPrefs.shadersActive)
				var shader = new DynamicShaderHandler(fileName, optimize);
		
				return fileName;
		});
		/*
		Lua_helper.add_callback(lua, "modifyShaderProperty", function(fileName:String, propertyName:String, value:Dynamic)
		{
			//var handler:DynamicShaderHandler = PlayState.instance.luaShaders.get(fileName);
			//trace(Reflect.getProperty(handler.shader.data, propertyName));
			//Reflect.setProperty(Reflect.getProperty(handler.shader.data, propertyName), 'value', value);
			handler.modifyShaderProperty(propertyName, value);
		});
		// shader set
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
		
		// shader clear
		
		Lua_helper.add_callback(lua, "clearShadersFromCamera", function(cameraName) {
			if (ClientPrefs.shadersActive)
				{
					cameraFromString(cameraName).setFilters([]);
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
		Discord.DiscordClient.addLuaCallbacks(lua);

		// Other stuff
		Lua_helper.add_callback(lua, "stringStartsWith", function(str:String, start:String) {
			return str.startsWith(start);
		});
		Lua_helper.add_callback(lua, "stringEndsWith", function(str:String, end:String) {
			return str.endsWith(end);
		});
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

	public static function setVarInArray(instance:Dynamic, variable:String, value:Dynamic):Any
	{
		var inArrayValues:Array<String> = variable.split('[');
		if(inArrayValues.length > 1)
		{
			var blah:Dynamic = Reflect.getProperty(instance, inArrayValues[0]);
			for (i in 1...inArrayValues.length)
			{
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
	public static function getVarInArray(instance:Dynamic, variable:String):Any
	{
		var inArrayValues:Array<String> = variable.split('[');
		if(inArrayValues.length > 1)
		{
			var blah:Dynamic = Reflect.getProperty(instance, inArrayValues[0]);
			for (i in 1...inArrayValues.length)
			{
				var leNum:Dynamic = inArrayValues[i].substr(0, inArrayValues[i].length - 1);
				blah = blah[leNum];
			}
			return blah;
		}

		return Reflect.getProperty(instance, variable);
	}

	inline static function getTextObject(name:String):FlxText
	{
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

	function loadFrames(spr:FlxSprite, image:String, spriteType:String)
	{
		switch(spriteType.toLowerCase().trim())
		{
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
		if(!PlayState.instance.modchartTexts.exists(tag)) {
			return;
		}

		var theModchart:ModchartText = PlayState.instance.modchartTexts.get(tag);
		theModchart.kill();
		if(theModchart.wasAdded) {
			PlayState.instance.remove(theModchart, true);
		}
		theModchart.destroy();
		PlayState.instance.modchartTexts.remove(tag);
	}

	function resetSpriteTag(tag:String) {
		if(!PlayState.instance.modchartSprites.exists(tag)) {
			return;
		}

		var theModchart:ModchartSprite = PlayState.instance.modchartSprites.get(tag);
		theModchart.kill();
		if(theModchart.wasAdded) {
			PlayState.instance.remove(theModchart, true);
		}
		theModchart.destroy();
		PlayState.instance.modchartSprites.remove(tag);
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
		var objectTween:Dynamic = getObjectDirectly(variables[0]);
		if(variables.length > 1) {
			objectTween = getVarInArray(getPropertyLoopThingWhatever(variables), variables[variables.length-1]);
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
		var objectFlicker:Dynamic = getObjectDirectly(variables[0]);
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

	//Better optimized than using getProperty
	function getFlxEaseByString(?ease:String = '') {
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

	public static function getPropertyLoopThingWhatever(niArrayes:Array<String>, ?checkForTextsToo:Bool = true, ?getProperty:Bool=true):Dynamic
	{
		var thePropertys:Dynamic = getObjectDirectly(niArrayes[0], checkForTextsToo);
		var end = niArrayes.length;
		if(getProperty)end=niArrayes.length-1;

		for (i in 1...end) {
			thePropertys = getVarInArray(thePropertys, niArrayes[i]);
		}
		return thePropertys;
	}

	public static function getObjectDirectly(objectName:String, ?checkForTextsToo:Bool = true):Dynamic
	{
		var thePropertys:Dynamic = PlayState.instance.getLuaObject(objectName, checkForTextsToo);
		if(thePropertys==null)
			thePropertys = getVarInArray(getInstance(), objectName);

		return thePropertys;
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
}

class ModchartSprite extends FlxSprite
{
	public var wasAdded:Bool = false;
	public var animOffsets:Map<String, Array<Float>> = new Map<String, Array<Float>>();
	//public var isInFront:Bool = false;
	var hShader:DynamicShaderHandler;

	public function new(?x:Float = 0, ?y:Float = 0,shaderSprite:Bool=false,type:String='', optimize:Bool = false)
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

class ModchartText extends FlxText
{
	public var wasAdded:Bool = false;
	public function new(x:Float, y:Float, text:String, width:Float)
	{
		super(x, y, width, text, 16);
		setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		cameras = [PlayState.instance.camHUD];
		scrollFactor.set();
		borderSize = 2;
	}
}

class DebugLuaText extends FlxText
{
	private var disableTime:Float = 6;
	public var parentGroup:FlxTypedGroup<DebugLuaText>;
	public function new(text:String, parentGroup:FlxTypedGroup<DebugLuaText>, color:FlxColor) {
		this.parentGroup = parentGroup;
		super(10, 10, 0, text, 16);
		setFormat(Paths.font("vcr.ttf"), 20, color, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scrollFactor.set();
		borderSize = 1;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		disableTime -= elapsed;
		if(disableTime < 0) disableTime = 0;
		if(disableTime < 1) alpha = disableTime;
	}

}
