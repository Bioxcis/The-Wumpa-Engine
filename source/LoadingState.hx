package;

import lime.app.Promise;
import lime.app.Future;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;

import haxe.io.Path;

class LoadingState extends MusicBeatState
{
	inline static var MIN_TIME = 1.4;

	// Browsers will load create(), you can make your song load a custom directory there
	// If you're compiling to desktop (or something that doesn't use NO_PRELOAD_ALL), search for getNextState instead
	// I'd recommend doing it on both actually lol
	
	// TO DO: Make this easier
	
	var target:FlxState;
	var stopMusic = false;
	var directory:String;
	var callbacks:MultiCallback;
	var targetShit:Float = 0;
	var alphaTween:FlxTween;

	function new(target:FlxState, stopMusic:Bool, directory:String) {
		super();
		this.target = target;
		this.stopMusic = stopMusic;
		this.directory = directory;
	}

	//var funkay:FlxSprite;
	var loadBar:FlxSprite;
	var loadingCrashito:FlxSprite;
	var loadText:FlxSprite;
	public var onFinish:Void->Void = null;

	override function create() {
		var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xff000000);
		add(bg);

		loadingCrashito = new FlxSprite().loadGraphic(Paths.image('loading/loading'), true);
		loadingCrashito.frames = Paths.getSparrowAtlas('loading/loading');
		loadingCrashito.animation.addByPrefix('loading', 'loading', 15, true);
		loadingCrashito.animation.play('loading', true, false);
        loadingCrashito.scrollFactor.set(0, 0);
		loadingCrashito.setGraphicSize(Std.int(loadingCrashito.width * 0.6));
        loadingCrashito.screenCenter();  
		loadingCrashito.alpha = 0.6;
		loadingCrashito.antialiasing = ClientPrefs.globalAntialiasing;
		add(loadingCrashito);

		loadText = new FlxSprite(0, 0).loadGraphic(Paths.getPath('images/loading/carregando.png', IMAGE)); //Antigo aleatório: 'images/loading/carregando'+FlxG.ramdom.int(1,5)+'.png'
		loadText.setGraphicSize(0, FlxG.height);
		loadText.updateHitbox();
		loadText.antialiasing = ClientPrefs.globalAntialiasing;
		loadText.scrollFactor.set();
		loadText.screenCenter();
		loadText.alpha = 0;
		add(loadText);

		loadBar = new FlxSprite(0, FlxG.height - 1000).makeGraphic(FlxG.width + 10, 15, 0xff23a7ff);
		loadBar.screenCenter(X);
		loadBar.antialiasing = ClientPrefs.globalAntialiasing;
		add(loadBar);

		alphaTween = FlxTween.tween(loadText, {alpha: 1}, 0.4, {onComplete: function (twn:FlxTween) {
			alphaTween = FlxTween.tween(loadText, {alpha: 0}, 0.3, {
				startDelay: 0.3,
				onComplete: function (twn:FlxTween) {
					alphaTween = FlxTween.tween(loadText, {alpha: 1}, 0.3, {
						startDelay: 0.3,
						onComplete: function (twn:FlxTween) {
							alphaTween = FlxTween.tween(loadText, {alpha: 0}, 0.3, {
								startDelay: 0.3,
								onComplete: function(twn:FlxTween) {
									alphaTween = null;
									remove(loadText);
									if(onFinish != null) onFinish();
								}
							});
						}
					});
				}
			});
		}});

		initSongsManifest().onComplete (
			function (lib) {
				callbacks = new MultiCallback(onLoad);
				var introComplete = callbacks.add("introComplete");
				/*if (PlayState.SONG != null) {
					checkLoadSong(getSongPath());
					if (PlayState.SONG.needsVoices)
						checkLoadSong(getVocalPath());
				}*/
				checkLibrary("shared");
				if(directory != null && directory.length > 0 && directory != 'shared') {
					checkLibrary(directory);
				}

				var fadeTime = 0.5;
				FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
				new FlxTimer().start(fadeTime + MIN_TIME, function(_) introComplete());
			}
		);
	}

	function checkLoadSong(path:String) {
		if (!Assets.cache.hasSound(path)) {
			var library = Assets.getLibrary("songs");
			final symbolPath = path.split(":").pop();
			var callback = callbacks.add("song:" + path);
			Assets.loadSound(path).onComplete(function (_) { callback(); });
		}
	}
	
	function checkLibrary(library:String) {
		trace(Assets.hasLibrary(library));
		if (Assets.getLibrary(library) == null) {
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library))
				throw "Missing library: " + library;

			var callback = callbacks.add("library:" + library);
			Assets.loadLibrary(library).onComplete(function (_) { callback(); });
		}
	}
	
	override function update(elapsed:Float) {	
		super.update(elapsed);
		/*funkay.setGraphicSize(Std.int(0.88 * FlxG.width + 0.9 * (funkay.width - 0.88 * FlxG.width)));
		funkay.updateHitbox();
		if(controls.ACCEPT)
		{
			funkay.setGraphicSize(Std.int(funkay.width + 60));
			funkay.updateHitbox();
		}*/

		if(callbacks != null) {
			targetShit = FlxMath.remapToRange(callbacks.numRemaining / callbacks.length, 1, 0, 0, 1);
			loadBar.scale.x += 0.8 * (targetShit - loadBar.scale.x);
		}
	}
	
	function onLoad() {
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		MusicBeatState.switchState(target);
	}
	
	static function getSongPath() {
		return Paths.inst(PlayState.SONG.song);
	}
	
	static function getVocalPath() {
		return Paths.voices(PlayState.SONG.song);
	}
	
	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false) {
		MusicBeatState.switchState(getNextState(target, stopMusic));
	}
	
	static function getNextState(target:FlxState, stopMusic = false):FlxState {
		var directory:String = 'shared';
		var weekDir:String = StageData.forceNextDirectory;
		StageData.forceNextDirectory = null;

		if(weekDir != null && weekDir.length > 0 && weekDir != '') directory = weekDir;

		Paths.setCurrentLevel(directory);
		trace('Setting asset folder to ' + directory);

		//#if NO_PRELOAD_ALL
		var loaded:Bool = false;
		if (PlayState.SONG != null) {
			loaded = isSoundLoaded(getSongPath()) && (!PlayState.SONG.needsVoices || isSoundLoaded(getVocalPath())) && isLibraryLoaded("shared") && isLibraryLoaded(directory);
		}
		
		if (!loaded)
			return new LoadingState(target, stopMusic, directory);
		//#end
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		return target;
	}
	
	//#if NO_PRELOAD_ALL
	static function isSoundLoaded(path:String):Bool {
		return Assets.cache.hasSound(path);
	}
	
	static function isLibraryLoaded(library:String):Bool
	{
		return Assets.getLibrary(library) != null;
	}
	//#end
	
	override function destroy() {
		if(alphaTween != null) {
			alphaTween.cancel();
		}

		super.destroy();
		
		callbacks = null;
	}
	
	static function initSongsManifest() {
		var id = "songs";
		var promise = new Promise<AssetLibrary>();

		var library = LimeAssets.getLibrary(id);

		if (library != null)
			return Future.withValue(library);

		var path = id;
		var rootPath = null;

		@:privateAccess
		var libraryPaths = LimeAssets.libraryPaths;
		if (libraryPaths.exists(id)) {
			path = libraryPaths[id];
			rootPath = Path.directory(path);
		} else {
			if (StringTools.endsWith(path, ".bundle")) {
				rootPath = path;
				path += "/library.json";
			} else
				rootPath = Path.directory(path);

			@:privateAccess
			path = LimeAssets.__cacheBreak(path);
		}

		AssetManifest.loadFromFile(path, rootPath).onComplete(function(manifest) {
			if (manifest == null) {
				promise.error("Cannot parse asset manifest for library \"" + id + "\"");
				return;
			}

			var library = AssetLibrary.fromManifest(manifest);

			if (library == null) {
				promise.error("Cannot open library \"" + id + "\"");
			} else {
				@:privateAccess
				LimeAssets.libraries.set(id, library);
				library.onChange.add(LimeAssets.onChange.dispatch);
				promise.completeWith(Future.withValue(library));
			}
		}).onError(function(_) {
			promise.error("There is no asset library with an ID of \"" + id + "\"");
		});

		return promise.future;
	}
}

class MultiCallback {
	public var callback:Void->Void;
	public var logId:String = null;
	public var length(default, null) = 0;
	public var numRemaining(default, null) = 0;
	
	var unfired = new Map<String, Void->Void>();
	var fired = new Array<String>();
	
	public function new (callback:Void->Void, logId:String = null) {
		this.callback = callback;
		this.logId = logId;
	}
	
	public function add(id = "untitled") {
		id = '$length:$id';
		length++;
		numRemaining++;
		var func:Void->Void = null;
		func = function () {
			if (unfired.exists(id)) {
				unfired.remove(id);
				fired.push(id);
				numRemaining--;
				
				if (logId != null)
					log('fired $id, $numRemaining remaining');
				
				if (numRemaining == 0) {
					if (logId != null)
						log('all callbacks fired');
					callback();
				}
			} else
				log('already fired $id');
		}
		unfired[id] = func;
		return func;
	}
	
	inline function log(msg):Void {
		if (logId != null)
			trace('$logId: $msg');
	}
	
	public function getFired() return fired.copy();
	public function getUnfired() return [for (id in unfired.keys()) id];
}