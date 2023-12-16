package;

import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flash.display.BitmapData;
import editors.ChartingState;

using StringTools;

typedef EventNote = {
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

class Note extends FlxSprite
{
	public static var gfxLetter:Array<String> = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
												'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R'];
	public static var ammo:Array<Int> = EKData.gun;
	public static var minMania:Int = 0;
	public static var maxMania:Int = 17;

	public static var scales:Array<Float> = EKData.scales;
	public static var lessX:Array<Int> = EKData.lessX;
	public static var separator:Array<Int> = EKData.noteSep;
	public static var xtra:Array<Float> = EKData.offsetX;
	public static var posRest:Array<Float> = EKData.restPosition;
	public static var gridSizes:Array<Int> = EKData.gridSizes;
	public static var noteSplashOffsets:Map<Int, Array<Int>> = [
		0 => [20, 10],
		9 => [10, 20]
	];
	public static var noteSplashScales:Array<Float> = EKData.splashScales;

	public static var xmlMax:Int = 17;

	public static var minManiaUI_integer:Int = minMania + 1;
	public static var maxManiaUI_integer:Int = maxMania + 1;

	public static var defaultMania:Int = 3;

	// pixel notes
	public static var pixelNotesDivisionValue:Int = 18;
	public static var pixelScales:Array<Float> = EKData.pixelScales;

	public static var keysShit:Map<Int, Map<String, Dynamic>> = EKData.keysShit;

	public var extraData:Map<String,Dynamic> = [];
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var prevNote:Note;
	public var nextNote:Note;

	public var spawned:Bool = false;

	public var tail:Array<Note> = []; // for sustains
	public var parent:Note;
	public var blockHit:Bool = false; // only works for player

	public var shouldbehidden:Bool = false;
	public var charSkin:String = null;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):String = null;

	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var colorSwap:ColorSwap;
	public var inEditor:Bool = false;

	public var animSuffix:String = '';
	public var gfNote:Bool = false;
	public var earlyHitMult:Float = 0.5;
	public var lateHitMult:Float = 1;
	public var lowPriority:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	// Lua shit
	public var noteSplashDisabled:Bool = false;
	public var noteSplashTexture:String = null;
	public var noteSplashHue:Float = 0;
	public var noteSplashSat:Float = 0;
	public var noteSplashBrt:Float = 0;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;
	public var multSpeed(default, set):Float = 1;

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;

	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;
	public var rating:String = 'unknown';
	public var ratingMod:Float = 0; //9 = unknown, 0.25 = shit, 0.5 = bad, 0.75 = good, 1 = sick
	public var ratingDisabled:Bool = false;

	public var texture(default, set):String = null;

	public var noAnimation:Bool = false;
	public var noMissAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;
	public var distance:Float = 2000; //plan on doing scroll directions soon -bb

	public var hitsoundDisabled:Bool = false;
	public var changeAnim:Bool = true;
	public var changeColSwap:Bool = true;

	public function resizeByRatio(ratio:Float) {
		if(isSustainNote && !animation.curAnim.name.endsWith('tail')) {
			scale.y *= ratio;
			updateHitbox();
		}
	}

		private function set_multSpeed(value:Float):Float {
		resizeByRatio(value / multSpeed);
		multSpeed = value;
		//trace('yes');
		return value;
	}

	public var mania:Int = 1;

	var ogW:Float;
	var ogH:Float;

	var defaultWidth:Float = 0;
	var defaultHeight:Float = 0;

	private function set_texture(value:String):String {
		if(texture != value) {
			reloadNote('', value);
		}
		texture = value;
		return value;
	}

	private function set_noteType(value:String):String {
		noteSplashTexture = PlayState.SONG.splashSkin;
		if (noteData > -1 && noteData < ClientPrefs.arrowHSV.length) {
			// colorSwap.hue = ClientPrefs.arrowHSV[noteData][0] / 360;
			// colorSwap.saturation = ClientPrefs.arrowHSV[noteData][1] / 100;
			// colorSwap.brightness = ClientPrefs.arrowHSV[noteData][2] / 100;
			colorSwap.hue = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData] % Note.ammo[mania])][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData] % Note.ammo[mania])][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[Std.int(Note.keysShit.get(mania).get('pixelAnimIndex')[noteData] % Note.ammo[mania])][2] / 100;
		}

		if(noteData > -1 && noteType != value) {
			switch(value) {
				case 'Hurt Note':
					ignoreNote = mustPress;
					reloadNote('HURT');
					noteSplashTexture = 'HURTnoteSplashes';
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					lowPriority = true;

					if(isSustainNote) {
						missHealth = 0.1;
					} else {
						missHealth = 0.3;
					}
					hitCausesMiss = true;
				case 'Alt Animation':
					animSuffix = '-alt';
				case 'No Animation':
					noAnimation = true;
					noMissAnimation = true;
				case 'GF Sing':
					gfNote = true;
			}
			noteType = value;
		}
		noteSplashHue = colorSwap.hue;
		noteSplashSat = colorSwap.saturation;
		noteSplashBrt = colorSwap.brightness;
		return value;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false, ?charSkin:String = null)
	{
		super();

		if (!inEditor && ClientPrefs.getGameplaySetting('randomcharts', false)) {
			noteData = FlxG.random.int(0,3);
			if (sustainNote && prevNote != null) {
				noteData = prevNote.noteData;
			}
		}

		if (!inEditor && ClientPrefs.getGameplaySetting('mirrorcharts', false)) {
			noteData = Std.parseInt(Std.string(Math.abs(Std.parseFloat(Std.string(noteData-3)))));
		}

		mania = PlayState.mania;

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;
		this.charSkin = charSkin;

		x += (ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		if(!inEditor) this.strumTime += ClientPrefs.noteOffset;

		this.noteData = noteData;

		if(noteData > -1) {
			texture = '';
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;

			// x += swagWidth * (noteData);
			// if(!isSustainNote && noteData > -1 && noteData < 4) {
			x += swagWidth * (noteData % Note.ammo[mania]);
			if(!isSustainNote && noteData > -1 && noteData < Note.maxManiaUI_integer) { //Doing this 'if' check to fix the warnings on Senpai songs
				var animToPlay:String = '';
				// switch (noteData % 4) {
				// 	case 0:
				// 		animToPlay = 'purple';
				// 	case 1:
				// 		animToPlay = 'blue';
				// 	case 2:
				// 		animToPlay = 'green';
				// 	case 3:
				// 		animToPlay = 'red';
				// }
				// animation.play(animToPlay + 'Scroll');
				animToPlay = Note.keysShit.get(mania).get('letters')[noteData];
				animation.play(animToPlay);
			}
		}

		// trace(prevNote);

		if(prevNote!=null)
			prevNote.nextNote = this;

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;
			multAlpha = 0.6;
			hitsoundDisabled = true;
			if(ClientPrefs.downScroll) flipY = true;

			offsetX += width / 2;
			copyAngle = false;

			// switch (noteData % 4)
			// {
			// 	case 0:
			// 		animation.play('purpleholdend');
			// 	case 1:
			// 		animation.play('blueholdend');
			// 	case 2:
			// 		animation.play('greenholdend');
			// 	case 3:
			// 		animation.play('redholdend');
			// }
			animation.play(Note.keysShit.get(mania).get('letters')[noteData] + ' tail');

			updateHitbox();

			offsetX -= width / 2;

			if (PlayState.isPixelStage)
				//offsetX += 30;
				offsetX += 30 * Note.pixelScales[mania];

			if (prevNote.isSustainNote) {
				// switch (prevNote.noteData % 4) {
				// 	case 0:
				// 		prevNote.animation.play('purplehold');
				// 	case 1:
				// 		prevNote.animation.play('bluehold');
				// 	case 2:
				// 		prevNote.animation.play('greenhold');
				// 	case 3:
				// 		prevNote.animation.play('redhold');
				// }
				prevNote.animation.play(Note.keysShit.get(mania).get('letters')[prevNote.noteData] + ' hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				if(PlayState.instance != null)
				{
					prevNote.scale.y *= PlayState.instance.songSpeed;
				}

				if(PlayState.isPixelStage) {
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / height); //Auto adjust note size
				}
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}

			if(PlayState.isPixelStage) {
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}
		} else if(!isSustainNote) {
			earlyHitMult = 1;
		}
		x += offsetX;
	}

	var lastNoteOffsetXForPixelAutoAdjusting:Float = 0;
	var lastNoteScaleToo:Float = 1;
	public var originalHeightForCalcs:Float = 6;
	function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '') {
		if(prefix == null) prefix = '';
		if(texture == null) texture = '';
		if(suffix == null) suffix = '';

		var skin:String = texture;
		if(texture.length < 1) {
			skin = PlayState.SONG.arrowSkin;
			if(skin == null || skin.length < 1) {
				skin = 'NOTE_assets';
				if (prefix == '') {
					if(ClientPrefs.noteSkinSettings == 'Classico') {
						skin = 'NOTE_assets';
					} else if (ClientPrefs.noteSkinSettings == 'Circulo') {
						skin = 'NOTE_assets_circle';
					} else {
						skin = 'NOTE_assets'; // for preventing crashes
					}
				}
			}
		}

		if (charSkin != null && (prefix == '')) {
			skin = charSkin;
		}

		var animName:String = null;
		if(animation.curAnim != null) {
			animName = animation.curAnim.name;
		}

		var arraySkin:Array<String> = skin.split('/');
		arraySkin[arraySkin.length-1] = prefix + arraySkin[arraySkin.length-1] + suffix;

		var lastScaleY:Float = scale.y;
		var blahblah:String = arraySkin.join('/');

		defaultWidth = 157;
		defaultHeight = 154;
		if(PlayState.isPixelStage) {
			if(isSustainNote) {
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'));
				//width = width / 4;
				width = width / pixelNotesDivisionValue;
				height = height / 2;
				originalHeightForCalcs = height;
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'), true, Math.floor(width), Math.floor(height));
			} else {
				loadGraphic(Paths.image('pixelUI/' + blahblah));
				//width = width / 4;
				width = width / pixelNotesDivisionValue;
				height = height / 5;
				loadGraphic(Paths.image('pixelUI/' + blahblah), true, Math.floor(width), Math.floor(height));
			}
			defaultWidth = width;
		  	//setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			setGraphicSize(Std.int(width * PlayState.daPixelZoom * Note.pixelScales[mania]));
			loadPixelNoteAnims();
			antialiasing = false;

			if(isSustainNote) {
				offsetX += lastNoteOffsetXForPixelAutoAdjusting;
				lastNoteOffsetXForPixelAutoAdjusting = (width - 7) * (PlayState.daPixelZoom / 2);
				offsetX -= lastNoteOffsetXForPixelAutoAdjusting;

				/*if(animName != null && !animName.endsWith('end'))
				{
					lastScaleY /= lastNoteScaleToo;
					lastNoteScaleToo = (6 / height);
					lastScaleY *= lastNoteScaleToo;
				}*/
			}
		} else {
			frames = Paths.getSparrowAtlas(blahblah);
			loadNoteAnims();
			antialiasing = ClientPrefs.globalAntialiasing;
		}
		if(isSustainNote) {
			scale.y = lastScaleY;
		}
		updateHitbox();

		if(animName != null)
			animation.play(animName, true);

		if(inEditor) {
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
		}
	}

	// public function globalReloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = ''){
	// 	reloadNote(prefix, texture, suffix);
	// }

	function loadNoteAnims() {
		// animation.addByPrefix('greenScroll', 'green0');
		// animation.addByPrefix('redScroll', 'red0');
		// animation.addByPrefix('blueScroll', 'blue0');
		// animation.addByPrefix('purpleScroll', 'purple0');

		// if (isSustainNote)
		// {
		// 	animation.addByPrefix('purpleholdend', 'pruple end hold');
		// 	animation.addByPrefix('greenholdend', 'green hold end');
		// 	animation.addByPrefix('redholdend', 'red hold end');
		// 	animation.addByPrefix('blueholdend', 'blue hold end');

		// 	animation.addByPrefix('purplehold', 'purple hold piece');
		// 	animation.addByPrefix('greenhold', 'green hold piece');
		// 	animation.addByPrefix('redhold', 'red hold piece');
		// 	animation.addByPrefix('bluehold', 'blue hold piece');
		// }
		for (i in 0...gfxLetter.length) {
			animation.addByPrefix(gfxLetter[i], gfxLetter[i] + '0');
			if (isSustainNote) {
				animation.addByPrefix(gfxLetter[i] + ' hold', gfxLetter[i] + ' hold');
				animation.addByPrefix(gfxLetter[i] + ' tail', gfxLetter[i] + ' tail');
			}
		}
		ogW = width;
		ogH = height;
		if (!isSustainNote)
			setGraphicSize(Std.int(defaultWidth * scales[mania]));
		else
			setGraphicSize(Std.int(defaultWidth * scales[mania]), Std.int(defaultHeight * scales[0]));
		updateHitbox();
	}

	// public function globalLoadNoteAnims(){
	// 	loadNoteAnims(); // LOOOOOOOOOOOOOOL TOP 10 0 IQ MOVES
	// }

	function loadPixelNoteAnims() {
		// if(isSustainNote) {
		// 	animation.add('purpleholdend', [PURP_NOTE + 4]);
		// 	animation.add('greenholdend', [GREEN_NOTE + 4]);
		// 	animation.add('redholdend', [RED_NOTE + 4]);
		// 	animation.add('blueholdend', [BLUE_NOTE + 4]);

		// 	animation.add('purplehold', [PURP_NOTE]);
		// 	animation.add('greenhold', [GREEN_NOTE]);
		// 	animation.add('redhold', [RED_NOTE]);
		// 	animation.add('bluehold', [BLUE_NOTE]);
		// } else {
		// 	animation.add('greenScroll', [GREEN_NOTE + 4]);
		// 	animation.add('redScroll', [RED_NOTE + 4]);
		// 	animation.add('blueScroll', [BLUE_NOTE + 4]);
		// 	animation.add('purpleScroll', [PURP_NOTE + 4]);
		// }
		if(isSustainNote) {
			for (i in 0...gfxLetter.length) {
				animation.add(gfxLetter[i] + ' hold', [i]);
				animation.add(gfxLetter[i] + ' tail', [i + pixelNotesDivisionValue]);
			}
		} else {
			for (i in 0...gfxLetter.length) {
				animation.add(gfxLetter[i], [i + pixelNotesDivisionValue]);
			}
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		mania = PlayState.mania;

		if (mustPress) {
			if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult)
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		} else {
			canBeHit = false;

			if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult)) {
				if((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}
		}

		if (tooLate && !inEditor) {
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}