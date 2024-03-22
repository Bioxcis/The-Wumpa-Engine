package editors;

#if desktop
import Discord.DiscordClient;
#end
import flixel.system.debug.interaction.tools.Pointer.GraphicCursorCross;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUI;
import flixel.animation.FlxAnimation;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.ui.FlxSpriteButton;
import flixel.ui.FlxButton;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxG;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import openfl.events.Event;
import animateatlas.AtlasFrameMaker;
import lime.system.Clipboard;
import haxe.Json;
import Character;
import Paths;

#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

// Original By Notweuz - https://youtu.be/LwqHwiF4CF8

// Modded by Bioxcis

class StageEditorState extends MusicBeatState
{
	var UI_box:FlxUITabMenu;

    var theFont:String = "nsane.ttf";

    private var camEditor:FlxCamera;
	private var camHUD:FlxCamera;
	private var camMenu:FlxCamera;

    var bfjson:Dynamic;
    var gfjson:Dynamic;
    var dadjson:Dynamic;
    var charAnimOffsets:Dynamic;

    // Characters
    var characterList:Dynamic;
    var charLayer:FlxTypedGroup<Character>;

    var bf:Character;
    var dad:Character;
    var gf:Character;

    var bfidle:Array<Int> = [0, 0];
    var gfidle:Array<Int> = [0, 0];
    var dadidle:Array<Int> = [0, 0];

    var daDadAnim:String = 'dad';
    var daBfAnim:String = 'bf';
    var daGfAnim:String = 'gf';
    var daCharAnim:String = 'bf';

    // Objects
    var bgMapInfos:Map<FlxSprite, Dynamic> = [];
    var bgGroup:FlxTypedGroup<FlxSprite>;
    var spritesTag:Array<String> = [];

    var selectedObj:FlxSprite;
    var objectName:String;
    var tagName:String;
    var objectIndex:Int;
    var loadingObj:String;

    var isFront:Bool = false;
    var isAnimated:Bool = false;
    var spriteAntialiasing:Bool = true;
    var idleAnim:String = '';
    var animFrames:Int = 24;
    var isLooped:Bool = false;

    var daSpriteAnim:String = 'gf';

    // Texts
    var curTag:FlxText;
    var objCoords:FlxText;
    var objSize:FlxText;
    var objScroll:FlxText;
    var cameraZoom:FlxText;
    var cameraPosition:FlxText;

    // Others
    var dummy:FlxSprite;
    var charactersOnStage:Array<String>;
    var charactersObjects:Array<Character>;

	var camFollow:FlxObject;
	var cameraFollowPointer:FlxSprite;

    var framesValue:Int = 24;

    var flipX:Bool = false;
    var flipY:Bool = false;
    var visibility:Bool = false;

    var defaultcamzoom:Float = 1;
    var stageispixel:Bool = false;

    var cameraSpeed:Float = 1;
    var camBoy:Array<Float> = [0, 0];
    var camDad:Array<Float> = [0, 0];
    var camGirl:Array<Float> = [0, 0];

    override function create() {
		FlxG.sound.playMusic(Paths.music('breakfast'), 0.5);

        camEditor = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camMenu = new FlxCamera();
		camMenu.bgColor.alpha = 0;

		FlxG.cameras.reset(camEditor);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camMenu);
		FlxCamera.defaultCameras = [camEditor];

        var uibox_tabs = [
            {name: '1 - Sprite Objects', label: 'Adicionar'},
            {name: '2 - Sprite Assets', label: 'Configurar'},
            {name: '3 - Characters', label: 'Personagens'},
            {name: '4 - Stage Assets', label: 'Estágio'}
        ];

        UI_box = new FlxUITabMenu(null, uibox_tabs, true);
		UI_box.cameras = [camMenu];

		UI_box.resize(300, 250);
		UI_box.x = FlxG.width - 325;
		UI_box.y = 25;
		UI_box.scrollFactor.set();

		var tipTextArray1:Array<String> =
		"E / Q
		\nR
        \nU I O P
		\nV B N M
		\nW A S D
		\nSetas
		\nShift
        \nCtrl
        \n1\n".split('\n');

		var tipTextArray2:Array<String> =
		"- Aumenta/Diminui Zoom
		\n- Resetar Zoom
        \n- Aumenta/Diminui Tamanho
        \n- Aumenta/Diminui Rolagem
		\n- Move Camera
		\n- Move Objeto
		\n- Move 10x mais Rapido
        \n- Move 100x mais Rapido
        \n- Altera visibilidade da Hud\n".split('\n');

        for (i in 0...tipTextArray1.length-1) {
			var tipText1:FlxText = new FlxText(FlxG.width - 320, FlxG.height - 20 - (16 * (tipTextArray1.length - i)), 0, tipTextArray1[i], 12);
			tipText1.cameras = [camHUD];
			tipText1.setFormat(Paths.font(theFont), 18, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
			tipText1.scrollFactor.set();
			tipText1.borderSize = 1;
			add(tipText1);

			var tipText2:FlxText = new FlxText(tipText1.x + 80, FlxG.height - 20 - (16 * (tipTextArray2.length - i)), 0, tipTextArray2[i], 12);
			tipText2.cameras = [camHUD];
			tipText2.setFormat(Paths.font(theFont), 18, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
			tipText2.scrollFactor.set();
			tipText2.borderSize = 1;
			add(tipText2);
		}

        curTag = new FlxText(20, 20, 0, 'Nome: Jogador ', 30);
        curTag.setFormat(Paths.font(theFont), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
        curTag.cameras = [camHUD];
        curTag.scrollFactor.set();
        curTag.borderSize = 1;
        add(curTag);

        objCoords = new FlxText(curTag.x, curTag.y + 40, 0, 'Coordenadas: - - ', 30);
        objCoords.setFormat(Paths.font(theFont), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
        objCoords.cameras = [camHUD];
        objCoords.scrollFactor.set();
        objCoords.borderSize = 1;
        add(objCoords);

        objSize = new FlxText(objCoords.x, objCoords.y + 40, 0, 'Tamanho: - - ', 30);
        objSize.setFormat(Paths.font(theFont), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
        objSize.cameras = [camHUD];
        objSize.scrollFactor.set();
        objSize.borderSize = 1;
        add(objSize);
        
        objScroll = new FlxText(objSize.x, objSize.y + 40, 0, 'Rolagem: - - ', 30);
        objScroll.setFormat(Paths.font(theFont), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
        objScroll.cameras = [camHUD];
        objScroll.scrollFactor.set();
        objScroll.borderSize = 1;
        add(objScroll);

        cameraZoom = new FlxText(20, FlxG.height - 80, 0, 'Camera Zoom: - - ', 30);
        cameraZoom.setFormat(Paths.font(theFont), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
        cameraZoom.cameras = [camHUD];
        cameraZoom.scrollFactor.set();
        cameraZoom.borderSize = 1;
        add(cameraZoom);

        cameraPosition = new FlxText(cameraZoom.x, cameraZoom.y + 40, 0, 'Camera Posição: - - ', 30);
        cameraPosition.setFormat(Paths.font(theFont), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
        cameraPosition.cameras = [camHUD];
        cameraPosition.scrollFactor.set();
        cameraPosition.borderSize = 1;
        add(cameraPosition);

        bgGroup = new FlxTypedGroup<FlxSprite>();
		charLayer = new FlxTypedGroup<Character>();
		add(bgGroup);
		add(charLayer);

        bf = new Character(1110, 300, "bf", true);
        gf = new Character(600, 0, "gf", false);
        dad = new Character(330, -50, "dad", false);

        charLayer.add(gf);
        charLayer.add(dad);
        charLayer.add(bf);

        charactersOnStage = ['bf', 'gf', 'dad'];
        charactersObjects = [bf, gf, dad];
        for (i in charactersObjects) {
            i.updateHitbox();
        }

        dummy = new FlxSprite(0, 0);
        dummy.makeGraphic(2, 2, FlxColor.TRANSPARENT, false, 'dummy');
        dummy.updateHitbox();
        var objectArray:Array<Dynamic> = makeObjArray('Escolha Imagem', 'dummy', dummy);
        bgMapInfos.set(dummy, objectArray);
        bgGroup.add(dummy);
        spritesTag = [objectArray[0]];

		add(UI_box);
        selectedObj = bf;

        var posX:Float = gf.getGraphicMidpoint().x;
        var posY:Float = gf.getGraphicMidpoint().y;
        camFollow = new FlxObject(posX, posY, 2, 2);
		add(camFollow);

		FlxG.camera.follow(camFollow);
        FlxG.camera.zoom = 1;

        for (i in charactersOnStage) {
            var cjson:CharacterFile = characterjson(i);
            if (i == 'dad') {
                dadjson = cjson;
                dadidle = getIdleOffset('dad');
            } else if (i == 'gf') {
                gfjson = cjson;
                gfidle = getIdleOffset('gf');
            } else {
                bfjson = cjson;
                bfidle = getIdleOffset('bf');
            }
        }

        addSpritesUI();
        addAnimationsUI();
        addCharactersUI();
        addStageUI();

		UI_box.selected_tab_id = '1 - Sprite Objects';
		FlxG.mouse.visible = true;

        #if desktop
        // Updating Discord Rich Presence
        DiscordClient.changePresence("In Stage Editor", "Making a stage...");
        #end

        super.create();
    }

    var objectInputText:FlxUIInputText;
    var prefixInputText:FlxUIInputText;
    var check_isAnim:FlxUICheckBox;
    var check_isLoop:FlxUICheckBox;
    var tagInputText:FlxUIInputText;
    var objectAdd:FlxButton;
    var stepper_frame:FlxUINumericStepper;
    var objectLoadText:FlxUIInputText;
    var loadedObjectAdd:FlxButton;

    function addSpritesUI() {
        var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "1 - Sprite Objects";
        
        objectInputText = new FlxUIInputText(10, 30, 280, "folder/img", 8);
        objectInputText.focusGained = () -> FlxG.stage.window.textInputEnabled = true;

        prefixInputText = new FlxUIInputText(10, objectInputText.y + 40, 280, "xml-anim", 8);
        prefixInputText.focusGained = () -> FlxG.stage.window.textInputEnabled = true;

        tagInputText = new FlxUIInputText(prefixInputText.x, prefixInputText.y + 40, 160, "name", 8);
        tagInputText.focusGained = () -> FlxG.stage.window.textInputEnabled = true;

        check_isAnim = new FlxUICheckBox(tagInputText.x + 180, tagInputText.y, null, null, "Animação", 100);
		check_isAnim.checked = isAnimated;
		check_isAnim.callback = function() { isAnimated = check_isAnim.checked; };

        check_isLoop = new FlxUICheckBox(check_isAnim.x, check_isAnim.y + 30, null, null, "Loop", 100);
		check_isLoop.checked = isLooped;
		check_isLoop.callback = function() { isLooped = check_isLoop.checked; };

        objectAdd = new FlxButton(tagInputText.x, tagInputText.y + 35, "Adicionar", function() {
            if(FileSystem.exists(Paths.modsImages(objectName))) {
                var sprite:FlxSprite = new FlxSprite(0, 0);

                if(isAnimated && (idleAnim != '' || idleAnim != null)) {
                    sprite.frames = Paths.getSparrowAtlas(objectName);
                    sprite.animation.addByPrefix(idleAnim + 'toPlay', idleAnim, animFrames, isLooped);
                    sprite.animation.play(idleAnim + 'toPlay');
                } else {
                    if(isAnimated) isAnimated = false;
                    sprite.loadGraphic(Paths.image(objectName), isAnimated, 0, 0, false, objectName);
                }

                sprite.antialiasing = true;
                sprite.updateHitbox();
                isFront = false;
                tagName = tagNameCheck(tagName);

                var obArr:Array<Dynamic> = makeObjArray(tagName, objectName, sprite);
                bgMapInfos.set(sprite, obArr);
                bgGroup.add(sprite);
                spritesTag.push(obArr[0]);

                emptyFields();
                reloadSpritesDropdown();
                makeWarningText("Imagem adicionada! Confira na Lista de Imagens!");
            } else
                makeWarningText("Imagem não encontrada!");
        });

        stepper_frame = new FlxUINumericStepper(objectAdd.x + 100, objectAdd.y + 5, 1, 24, 1, 360, 0);
        stepper_frame.name = 'anim_frame';

        objectLoadText = new FlxUIInputText(10, objectAdd.y + 56, 160, "folder/obj", 8);
        objectLoadText.focusGained = () -> FlxG.stage.window.textInputEnabled = true;

        loadedObjectAdd = new FlxButton(objectLoadText.x + 180, objectLoadText.y - 3, "Carregar", function() {
            if(FileSystem.exists(Paths.modsObjects(loadingObj))) {
                var obJson:Dynamic = File.getContent(Paths.modsObjects(loadingObj)).trim();
				obJson = Json.parse(obJson);
				var objtag = obJson.tag;
				var image = obJson.path;
				var posx = obJson.x;
				var posy = obJson.y;
				var scalex = obJson.scalex;
				var scaley = obJson.scaley;
				var scrollx = obJson.scrollx;
				var scrolly = obJson.scrolly;
                var flipx = obJson.flipx;
				var flipy = obJson.flipy;
				var alpha = obJson.alpha;
                var front = obJson.front;
				var isanimated = obJson.animated;
				var alias = obJson.antialiasing;
                var idleAnim = obJson.idleAnim;
				var frames = obJson.frames;
				var isLoop = obJson.loop;

                if(FileSystem.exists(Paths.modsImages(image))) {
                    var sprite:FlxSprite = new FlxSprite(posx, posy);
    
                    if(isanimated && (idleAnim != '' || idleAnim != null)) {
                        sprite.frames = Paths.getSparrowAtlas(image);
                        sprite.animation.addByPrefix(idleAnim, idleAnim, frames, isLoop);
                        sprite.animation.play(idleAnim);
                    } else
                        sprite.loadGraphic(Paths.image(image), false, 0, 0, false, image);
    
                    sprite.antialiasing = alias;
                    sprite.scale.x = scalex;
                    sprite.scale.y = scaley;
                    sprite.scrollFactor.x = scrollx;
                    sprite.scrollFactor.y = scrolly;
                    sprite.flipX = flipx;
                    sprite.flipY = flipy;
                    sprite.alpha = alpha;
                    sprite.updateHitbox();
                    tagName = tagNameCheck(objtag);
                    isFront = front;
    
                    var obArr:Array<Dynamic> = makeObjArray(tagName, image, sprite);
                    bgMapInfos.set(sprite, obArr);
                    bgGroup.add(sprite);
                    spritesTag.push(obArr[0]);

                    emptyFields();
                    reloadSpritesDropdown();
                    makeWarningText("Objeto carregado! Confira na Lista de Imagens!");
                } else
                    makeWarningText("Imagem do objeto não encontrada!");
            } else
                makeWarningText("Objeto não encontrado!");
        });

        updateValues();
        updateCoords();
        updateSize();
        updateScroll();
        //reloadSpritesDropdown();

        tab_group.add(objectInputText);
		tab_group.add(new FlxText(objectInputText.x, objectInputText.y - 18, 0, 'Local da imagem:'));
        tab_group.add(prefixInputText);
		tab_group.add(new FlxText(prefixInputText.x, prefixInputText.y - 18, 0, 'Animação:'));
        tab_group.add(tagInputText);
		tab_group.add(new FlxText(tagInputText.x, tagInputText.y - 18, 0, 'Nome do Objeto:'));
        tab_group.add(check_isAnim);
        tab_group.add(check_isLoop);
        tab_group.add(stepper_frame);
		tab_group.add(new FlxText(stepper_frame.x, stepper_frame.y - 18, 0, 'Anim FPS:'));
        tab_group.add(objectAdd);
        tab_group.add(objectLoadText);
		tab_group.add(new FlxText(objectLoadText.x, objectLoadText.y - 18, 0, 'Carregar objeto:'));
        tab_group.add(loadedObjectAdd);
        UI_box.addGroup(tab_group);
	}

    var spritesDropDown:FlxUIDropDownMenuCustom;
    var check_Antialiasing:FlxUICheckBox;
    var check_Layer:FlxUICheckBox;
    var check_FlipX:FlxUICheckBox;
    var check_FlipY:FlxUICheckBox;
    var check_Visible:FlxUICheckBox;
    var stepper_Alpha:FlxUINumericStepper;
    var objectForward:FlxButton;
    var objectBackward:FlxButton;
    var objectRemove:FlxButton;
    var objectDuplicate:FlxButton;
    
    function addAnimationsUI() {
        var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "2 - Sprite Assets";

        spritesDropDown = new FlxUIDropDownMenuCustom(10, 30, FlxUIDropDownMenuCustom.makeStrIdLabelArray([''], true), function(spriteTag:String) {
            var index:Int = Std.parseInt(spriteTag);
            objectIndex = index;
            bgGroup.update(1);
            selectedObj = bgGroup.members[index];
            selectedObj.updateHitbox();

            updateValues();
            updateCoords();
            updateSize();
            updateScroll();

            characterOpponent.checked = false;
            characterGirfriend.checked = false;
			characterBoyfriend.checked = false;

            for(img in bgMapInfos.keys()) {
                if (img == selectedObj) {
                    if(selectedObj == dummy) makeWarningText("Selecione ou adicione uma imagem a lista!");
                    else makeWarningText("Imagem selecionada: " + bgMapInfos[img][0]);
                }
            }
            if(selectedObj == dummy) emptyFields();
		});

        check_Antialiasing = new FlxUICheckBox(spritesDropDown.x + 160, spritesDropDown.y - 15, null, null, "Antialiasing", 100);
		check_Antialiasing.checked = spriteAntialiasing;
		check_Antialiasing.callback = function() {
            if(selectedObj != null && selectedObj != dummy && selectedObj != bf && selectedObj != gf && selectedObj != dad) {
                spriteAntialiasing = check_Antialiasing.checked;
                changeSpriteAntialiasing();
            }
		};

        check_Layer = new FlxUICheckBox(check_Antialiasing.x, check_Antialiasing.y + 24, null, null, "Na Frente", 100);
		check_Layer.checked = isFront;
		check_Layer.callback = function() {
            if(selectedObj != null && selectedObj != dummy && selectedObj != bf && selectedObj != gf && selectedObj != dad) {
                isFront = check_Layer.checked;
                changeSpriteLayer();
            }
		};

        check_Visible = new FlxUICheckBox(check_Layer.x, check_Layer.y + 24, null, null, "Visivel", 100);
		check_Visible.checked = visibility;
		check_Visible.callback = function() {
            if(selectedObj != null && selectedObj != dummy && selectedObj != bf && selectedObj != gf && selectedObj != dad) {
                visibility = check_Visible.checked;
                spriteVisibility();
            }
		};

        check_FlipX = new FlxUICheckBox(check_Visible.x, check_Visible.y + 24, null, null, "Inverter X", 100);
		check_FlipX.checked = flipX;
		check_FlipX.callback = function() {
            if(selectedObj != null && selectedObj != dummy && selectedObj != bf && selectedObj != gf && selectedObj != dad) {
			    flipX = check_FlipX.checked;
                selectedObj.flipX = flipX;
                spriteFlips();
            }
		};

        check_FlipY = new FlxUICheckBox(check_FlipX.x, check_FlipX.y + 24, null, null, "Inverter Y", 100);
		check_FlipY.checked = flipY;
		check_FlipY.callback = function() {
            if(selectedObj != null && selectedObj != dummy && selectedObj != bf && selectedObj != gf && selectedObj != dad) {
                flipY = check_FlipY.checked;
                selectedObj.flipY = flipY;
                spriteFlips();
            }
		};

        stepper_Alpha = new FlxUINumericStepper(check_FlipY.x, check_FlipY.y + 38, 0.05, 1, 0, 1, 2);
        stepper_Alpha.name = 'sprite_alpha';

        objectDuplicate = new FlxButton(stepper_Alpha.x, stepper_Alpha.y + 25, "Duplicar Img", function() {
            if(selectedObj != null && selectedObj != dummy && selectedObj != bf && selectedObj != gf && selectedObj != dad) {
                var copySpr:FlxSprite = new FlxSprite(selectedObj.x, selectedObj.y);
                copySpr.loadGraphicFromSprite(selectedObj);
                copySpr.scale.x = selectedObj.scale.x;
                copySpr.scale.y = selectedObj.scale.y;
                copySpr.scrollFactor.x = selectedObj.scrollFactor.x;
                copySpr.scrollFactor.y = selectedObj.scrollFactor.y;
                copySpr.flipX = selectedObj.flipX;
                copySpr.flipY = selectedObj.flipY;
                copySpr.alpha = selectedObj.alpha;
                copySpr.updateHitbox();

                var newObjectArray:Array<Dynamic> = [];
                for(theObj in bgMapInfos.keys()) {
                    if(theObj == selectedObj) {
                        var copyTag:String = tagNameCheck(bgMapInfos[theObj][0]);
                        newObjectArray = [
                            copyTag,
                            bgMapInfos[theObj][1],
                            copySpr.x,
                            copySpr.y,
                            copySpr.scale.x,
                            copySpr.scale.y,
                            copySpr.scrollFactor.x,
                            copySpr.scrollFactor.y,
                            bgMapInfos[theObj][8],
                            bgMapInfos[theObj][9],
                            copySpr.antialiasing,
                            copySpr.flipX,
                            copySpr.flipY,
                            copySpr.alpha,
                            bgMapInfos[theObj][14],
                            bgMapInfos[theObj][15],
                            bgMapInfos[theObj][16],
                            copySpr
                        ];
                    }
                }
                bgMapInfos.set(copySpr, newObjectArray);
                bgGroup.add(copySpr);
                spritesTag.push(newObjectArray[0]);
                emptyFields();
                reloadSpritesDropdown();
                makeWarningText("Imagem Duplicada! Confira na Lista de Imagens!");
            } else
                makeWarningText("Selecione uma imagem válida!");
        });

        objectRemove = new FlxButton(objectDuplicate.x, objectDuplicate.y + 25, "Remover Img", function() {
            if(selectedObj != null && selectedObj != dummy && selectedObj != bf && selectedObj != gf && selectedObj != dad) {
                bgGroup.remove(selectedObj, true);
                for(img in bgMapInfos.keys())
                    if (img == selectedObj)
                        bgMapInfos.remove(selectedObj);

                selectedObj.destroy();
                spritesTag.splice(objectIndex, 1);
                objectIndex = -1;
                selectedObj = dummy;

                updateValues();
                updateCoords();
                updateSize();
                updateScroll();
                reloadSpritesDropdown();

                bgGroup.update(1);
                curTag.text = 'Nome: Vazio';
                emptyFields();
                makeWarningText("Imagem removida!");
            } else
                makeWarningText("Selecione ou adicione uma imagem a lista!");
        });
        objectRemove.color = 0xFFCE0000;
        objectRemove.label.color = FlxColor.WHITE;

        updateValues();
        updateCoords();
        updateSize();
        updateScroll();
        reloadSpritesDropdown();

        tab_group.add(check_Antialiasing);
        tab_group.add(check_Layer);
        tab_group.add(check_FlipX);
        tab_group.add(check_FlipY);
        tab_group.add(check_Visible);
        tab_group.add(stepper_Alpha);
		tab_group.add(new FlxText(stepper_Alpha.x, stepper_Alpha.y - 18, 0, 'Valor de Alfa:'));
        tab_group.add(objectDuplicate);
        tab_group.add(objectRemove);
        tab_group.add(spritesDropDown);
        tab_group.add(new FlxText(spritesDropDown.x, spritesDropDown.y - 18, 0, 'Lista de Imagens:'));
        UI_box.addGroup(tab_group);
    }

    var dadSelect:FlxUIDropDownMenuCustom;
    var bfSelect:FlxUIDropDownMenuCustom;
    var gfSelect:FlxUIDropDownMenuCustom;
    var characterBoyfriend:FlxUICheckBox;
    var characterOpponent:FlxUICheckBox;
    var characterGirfriend:FlxUICheckBox;
    //var charDropDown:FlxUIDropDownMenuCustom;
    function addCharactersUI() {
        var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "3 - Characters";
        
        dadSelect = new FlxUIDropDownMenuCustom(10, 30, FlxUIDropDownMenuCustom.makeStrIdLabelArray([''], true), function(sprite:String) {
            charLayer.remove(dad);
            dad = new Character(dad.x, dad.y, characterList[Std.parseInt(sprite)], false);
            daDadAnim = characterList[Std.parseInt(sprite)];
            charLayer.add(dad);
            dad.updateHitbox();
            charactersObjects = [bf, gf, dad];
            var json:CharacterFile = characterjson(characterList[Std.parseInt(sprite)]);
            dadjson = json;
            dadidle = getIdleOffset(characterList[Std.parseInt(sprite)]);
            reloadCharDrops();
        });

        bfSelect = new FlxUIDropDownMenuCustom(dadSelect.x + 130, dadSelect.y, FlxUIDropDownMenuCustom.makeStrIdLabelArray([''], true), function(sprite:String) {
            charLayer.remove(bf);
            bf = new Character(bf.x, bf.y, characterList[Std.parseInt(sprite)], true);
            daBfAnim = characterList[Std.parseInt(sprite)];
            charLayer.add(bf);
            bf.updateHitbox();
            charactersObjects = [bf, gf, dad];
            var json:CharacterFile = characterjson(characterList[Std.parseInt(sprite)]);
            bfjson = json;
            bfidle = getIdleOffset(characterList[Std.parseInt(sprite)]);
            reloadCharDrops();
        });

        gfSelect = new FlxUIDropDownMenuCustom(dadSelect.x, dadSelect.y + 80, FlxUIDropDownMenuCustom.makeStrIdLabelArray([''], true), function(sprite:String) {
            charLayer.remove(gf);
            gf = new Character(gf.x, gf.y, characterList[Std.parseInt(sprite)], false);
            daGfAnim = characterList[Std.parseInt(sprite)];
            charLayer.add(gf);
            gf.updateHitbox();
            charactersObjects = [bf, gf, dad];
            var json:CharacterFile = characterjson(characterList[Std.parseInt(sprite)]);
            gfjson = json;
            gfidle = getIdleOffset(characterList[Std.parseInt(sprite)]);
            reloadCharDrops();
        });

        reloadCharDrops();

        characterBoyfriend = new FlxUICheckBox(gfSelect.x + 140, gfSelect.y, null, null, "Jogador", 100);
		characterBoyfriend.checked = true;
		characterBoyfriend.callback = function() {
			characterOpponent.checked = false;
            characterGirfriend.checked = false;
            selectedObj = bf;
            selectedObj.updateHitbox();
            curTag.text = 'Nome: Jogador';
            changeGeneralStatus();
		};

		characterOpponent = new FlxUICheckBox(characterBoyfriend.x, characterBoyfriend.y + 25, null, null, "Oponente", 100);
		characterOpponent.checked = false;
		characterOpponent.callback = function() {
			characterBoyfriend.checked = false;
            characterGirfriend.checked = false;
            selectedObj = dad;
            selectedObj.updateHitbox();
            curTag.text = 'Nome: Oponente';
            changeGeneralStatus();
		};

        characterGirfriend = new FlxUICheckBox(characterOpponent.x, characterOpponent.y + 25, null, null, "Namorada", 100);
		characterGirfriend.checked = false;
		characterGirfriend.callback = function() {
			characterOpponent.checked = false;
            characterBoyfriend.checked = false;
            selectedObj = gf;
            selectedObj.updateHitbox();
            curTag.text = 'Nome: Namorada';
            changeGeneralStatus();
		};
        
        // charDropDown = new FlxUIDropDownMenuCustom(dadSelect.x + 130, dadSelect.y + 80, FlxUIDropDownMenuCustom.makeStrIdLabelArray([''], true), function(character:String) {
        //     selectedObj = charactersObjects[Std.parseInt(character)];
        //     selectedObj.updateHitbox();
        //     daCharAnim = charactersOnStage[Std.parseInt(character)];
        //     reloadCharacterDropDown();
		// });
		//reloadCharacterDropDown();


        tab_group.add(new FlxText(dadSelect.x, dadSelect.y - 15, 0, 'Oponente:'));
        tab_group.add(new FlxText(bfSelect.x, bfSelect.y - 15, 0, 'Jogador:'));
        tab_group.add(new FlxText(gfSelect.x, gfSelect.y - 15, 0, 'Namorada:'));
        tab_group.add(characterBoyfriend);
        tab_group.add(characterOpponent);
        tab_group.add(characterGirfriend);
        tab_group.add(new FlxText(characterBoyfriend.x - 10, characterBoyfriend.y - 18, 0, 'Selecionar personagem:'));  
        tab_group.add(gfSelect);
        tab_group.add(dadSelect);
        tab_group.add(bfSelect);
        //tab_group.add(charDropDown);
        UI_box.addGroup(tab_group);
	}

    var objCopyCoords:FlxButton;
    var objCopySize:FlxButton;
    var objCopyScroll:FlxButton;
    var objCopyFlip:FlxButton;
    var objCopyVisibility:FlxButton;
    var saveObjectStage:FlxButton;
    var saveStageSettings:FlxButton;
    var objTitle:FlxText;
    function addStageUI() {
        var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "4 - Stage Assets";

        objCopyCoords = new FlxButton(10, 25, "Copiar Coord.", function() {
            var objTag:String = '';
            var objPath:String = '';
            for(img in bgMapInfos.keys()) {
                if (img == selectedObj) {
                    objTag = bgMapInfos[img][0];
                    objPath = bgMapInfos[img][1];
                }
            }
            if(selectedObj != null && selectedObj != dummy && selectedObj != bf && selectedObj != gf && selectedObj != dad) {
                Clipboard.text = "makeLuaSprite('"+ objTag + "', '" + objPath +"', " + selectedObj.x + ", " + selectedObj.y + ")";
                makeWarningText("Coordenadas do objeto copiadas!");
            } else
                makeWarningText("Objeto Inválido!");
        });

        objCopySize = new FlxButton(objCopyCoords.x + 100, objCopyCoords.y, "Copiar Taman.", function() {
            var objTag:String = '';
            for(img in bgMapInfos.keys())
                if (img == selectedObj)
                    objTag = bgMapInfos[img][0];

            if(selectedObj != null && selectedObj != dummy && selectedObj != bf && selectedObj != gf && selectedObj != dad) {
                Clipboard.text = "scaleObject('"+ objTag + "', " + selectedObj.scale.x +", " + selectedObj.scale.y + ")";
                makeWarningText("Tamanho do objeto copiado!");
            } else
                makeWarningText("Objeto Inválido!");
        });

        objCopyScroll = new FlxButton(objCopySize.x + 100, objCopySize.y, "Copiar Rolag.", function() {
            var objTag:String = '';
            for(img in bgMapInfos.keys())
                if (img == selectedObj)
                    objTag = bgMapInfos[img][0];

            if(selectedObj != null && selectedObj != dummy && selectedObj != bf && selectedObj != gf && selectedObj != dad) {
                Clipboard.text = "setScrollFactor('"+ objTag + "', " + selectedObj.scrollFactor.x +", " + selectedObj.scrollFactor.y + ")";
                makeWarningText("Rolagem do objeto copiada!");
            } else
                makeWarningText("Objeto Inválido!");
        });

        objCopyFlip = new FlxButton(objCopyCoords.x, objCopyCoords.y + 30, "Copiar Direc.", function() {
            var objTag:String = '';
            for(img in bgMapInfos.keys())
                if (img == selectedObj)
                    objTag = bgMapInfos[img][0];

            if(selectedObj != null && selectedObj != dummy && selectedObj != bf && selectedObj != gf && selectedObj != dad) {
                Clipboard.text = "setProperty('"+ objTag + ".flipX', " + selectedObj.flipX + ")\nsetProperty('"+ objTag + ".flipY', " + selectedObj.flipY + ")";
                makeWarningText("Direções do objeto copiadas!");
            } else
                makeWarningText("Objeto Inválido!");
        });

        objCopyVisibility = new FlxButton(objCopyFlip.x + 100, objCopyFlip.y, "Copiar Visib.", function() {
            var objTag:String = '';
            for(img in bgMapInfos.keys())
                if (img == selectedObj)
                    objTag = bgMapInfos[img][0];

            if(selectedObj != null && selectedObj != dummy && selectedObj != bf && selectedObj != gf && selectedObj != dad) {
                Clipboard.text = "setProperty('"+ objTag + ".alpha', " + selectedObj.alpha + ")\nsetProperty('"+ objTag + ".antialiasing', " + selectedObj.antialiasing + ")";
                makeWarningText("Visibilidade do objeto copiada!");
            } else
                makeWarningText("Objeto Inválido!");
        });

        saveObjectStage = new FlxButton(objCopyVisibility.x + 100, objCopyVisibility.y, 'Salvar Objeto', function() {
            if(selectedObj != null && selectedObj != dummy && selectedObj != bf && selectedObj != gf && selectedObj != dad)
                saveAdvancedJson();
            else
                makeWarningText("Objeto Inválido!");
        });
        saveObjectStage.color = 0xFFE0DBC2;

        objTitle = new FlxText(objCopyCoords.x, objCopyCoords.y - 20, 0, 'Objeto Selecionado: Inválido', 10);

		var stepper_Zoom:FlxUINumericStepper = new FlxUINumericStepper(objCopyCoords.x, objCopyCoords.y + 90, 0.05, 1, 0.1, 10, 2);
		stepper_Zoom.name = 'stage_zoom';

        var stepper_Speed:FlxUINumericStepper = new FlxUINumericStepper(stepper_Zoom.x + 160, stepper_Zoom.y, 0.05, 1, 0.1, 100, 2);
		stepper_Speed.name = 'camera_speed';

        var stepper_BfCameraX:FlxUINumericStepper = new FlxUINumericStepper(stepper_Zoom.x, stepper_Zoom.y + 30, 5, 0, -9000, 9000, 0);
        stepper_BfCameraX.name = 'bfzoomx';
        var stepper_BfCameraY:FlxUINumericStepper = new FlxUINumericStepper(stepper_BfCameraX.x + 70, stepper_BfCameraX.y, 5, 0, -9000, 9000, 0);
        stepper_BfCameraY.name = 'bfzoomy';

        var stepper_DadCameraX:FlxUINumericStepper = new FlxUINumericStepper(stepper_BfCameraX.x, stepper_BfCameraX.y + 30, 5, 0, -9000, 9000, 0);
        stepper_DadCameraX.name = 'dadzoomx';
        var stepper_DadCameraY:FlxUINumericStepper = new FlxUINumericStepper(stepper_DadCameraX.x + 70, stepper_DadCameraX.y, 5, 0, -9000, 9000, 0);
        stepper_DadCameraY.name = 'dadzoomy';

        var stepper_GfCameraX:FlxUINumericStepper = new FlxUINumericStepper(stepper_DadCameraX.x, stepper_DadCameraX.y + 30, 5, 0, -9000, 9000, 0);
        stepper_GfCameraX.name = 'gfzoomx';
        var stepper_GfCameraY:FlxUINumericStepper = new FlxUINumericStepper(stepper_GfCameraX.x + 70, stepper_GfCameraX.y, 5, 0, -9000, 9000, 0);
        stepper_GfCameraY.name = 'gfzoomy';

        var check_Pixel = new FlxUICheckBox(stepper_BfCameraX.x + 160, stepper_BfCameraX.y - 1, null, null, "Estágio Pixel", 100);
		check_Pixel.checked = stageispixel;
		check_Pixel.callback = function() {
			stageispixel = check_Pixel.checked;
		};

        var check_hideGirlfriend = new FlxUICheckBox(check_Pixel.x, stepper_DadCameraX.y - 1, null, null, "Sem GF", 100);
		check_hideGirlfriend.checked = !gf.visible;
		check_hideGirlfriend.callback = function() {
			gf.visible = !check_hideGirlfriend.checked;
		};

        saveStageSettings = new FlxButton(check_Pixel.x, stepper_GfCameraX.y - 3, "Salvar Estagio", function() {
            saveCharacterCoords();
        });
        saveStageSettings.color = 0xFFDBF3D8;

        tab_group.add(objCopyCoords);
        tab_group.add(objCopySize);
        tab_group.add(objCopyScroll);
        tab_group.add(objCopyFlip);
        tab_group.add(objCopyVisibility);
        tab_group.add(saveObjectStage);
        tab_group.add(objTitle);
        tab_group.add(stepper_Zoom);
		tab_group.add(new FlxText(stepper_Zoom.x, stepper_Zoom.y - 15, 0, 'Zoom Padrão:'));
        tab_group.add(stepper_Speed);
		tab_group.add(new FlxText(stepper_Speed.x, stepper_Speed.y - 15, 0, 'Vel. da Camera:'));
		tab_group.add(new FlxText(stepper_Zoom.x, stepper_Zoom.y - 33, 0, 'Alterações de Estágio', 10));
        tab_group.add(stepper_BfCameraX);
        tab_group.add(stepper_BfCameraY);
		tab_group.add(new FlxText(stepper_BfCameraX.x, stepper_BfCameraX.y - 15, 0, 'BF - Deslocar Camera X/Y:'));
        tab_group.add(stepper_DadCameraX);
        tab_group.add(stepper_DadCameraY);
		tab_group.add(new FlxText(stepper_DadCameraX.x, stepper_DadCameraX.y - 15, 0, 'DAD - Deslocar Camera X/Y:'));
        tab_group.add(stepper_GfCameraX);
        tab_group.add(stepper_GfCameraY);
		tab_group.add(new FlxText(stepper_GfCameraX.x, stepper_GfCameraX.y - 15, 0, 'GF - Deslocar Camera X/Y:'));
        tab_group.add(check_Pixel);
        tab_group.add(check_hideGirlfriend);
        tab_group.add(saveStageSettings);
        UI_box.addGroup(tab_group);
	}

    function makeObjArray(tag:String, name:String, spr:FlxSprite):Array<Dynamic> {
        var theArray:Array<Dynamic> = [
            tag,
            name,
            spr.x,
            spr.y,
            spr.scale.x,
            spr.scale.y,
            spr.scrollFactor.x,
            spr.scrollFactor.y,
            isAnimated,
            isFront,
            spriteAntialiasing,
            spr.flipX,
            spr.flipY,
            spr.alpha,
            idleAnim,
            animFrames,
            isLooped,
            spr
        ];
        return theArray;
    }

    function spriteVisibility() {
        for(theObj in bgGroup)
            if(selectedObj == theObj) theObj.visible = visibility;
    }

    function emptyFields() {
        check_isAnim.checked = false;
        check_isLoop.checked = false;
        objectInputText.text = '';
        tagInputText.text = '';
        prefixInputText.text = '';
        objectName = '';
        tagName = '';
        objectLoadText.text = '';
    }

    function tagNameCheck(?tag:String):String {
        if(tag == null || tag == "") tag = "sprite";
        var count:Int = 1;
        var newTag:String = tag;
        while(spritesTag.indexOf(newTag) != -1) {
            newTag = tag + "-" + count;
            count++;
        }
        return newTag;
    }

    function changeGeneralStatus() {
        objTitle.text = 'Objeto Selecionado: Inválido';
        objectInputText.text = '';
        tagInputText.text = '';
        prefixInputText.text = '';
        objectName = '';
        tagName = '';
        objectLoadText.text = '';
        updateCoords();
        updateSize();
        updateScroll();
    }

    function updateValues() {
        for(img in bgMapInfos.keys()) {
            if (img == selectedObj) {
                curTag.text = 'Nome: ' + bgMapInfos[img][0];
                if(img == dummy) objTitle.text = 'Objeto Selecionado: Inválido';
                else objTitle.text = 'Objeto Selecionado: ' + bgMapInfos[img][0];
                // tagInputText.text = bgMapInfos[img][0];
                // objectInputText.text = bgMapInfos[img][1];
                // check_Layer.checked = bgMapInfos[img][9];
                check_Antialiasing.checked = bgMapInfos[img][10];
                check_FlipX.checked = bgMapInfos[img][11];
                check_FlipY.checked = bgMapInfos[img][12];
                check_Visible.checked = img.visible;
                stepper_Alpha.value = img.alpha;
                daSpriteAnim = bgMapInfos[img][0];
            }
        }
    }

    // function reloadCharacterDropDown() {
	// 	charDropDown.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(charactersOnStage, true));
    //     charDropDown.selectedLabel = daCharAnim;
	// }

    function reloadSpritesDropdown() {
        bgGroup.update(1);
        spritesDropDown.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(spritesTag, true));
        spritesDropDown.selectedLabel = daSpriteAnim;
    }

    function reloadCharDrops() {
        var charsLoaded:Map<String, Bool> = new Map();
		#if MODS_ALLOWED
		characterList = [];
		var directories:Array<String> = [Paths.mods('characters/'), Paths.mods(Paths.currentModDirectory + '/characters/'), Paths.getPreloadPath('characters/')];
		for(mod in Paths.getGlobalMods())
			directories.push(Paths.mods(mod + '/characters/'));
		for (i in 0...directories.length) {
			var directory:String = directories[i];
			if(FileSystem.exists(directory)) {
				for (file in FileSystem.readDirectory(directory)) {
					var path = haxe.io.Path.join([directory, file]);
					if (!sys.FileSystem.isDirectory(path) && file.endsWith('.json')) {
						var charToCheck:String = file.substr(0, file.length - 5);
						if(!charsLoaded.exists(charToCheck)) {
							characterList.push(charToCheck);
							charsLoaded.set(charToCheck, true);
						}
					}
				}
			}
		}
		#else
		characterList = CoolUtil.coolTextFile(Paths.txt('characterList'));
		#end

		dadSelect.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(characterList, true));
        bfSelect.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(characterList, true));
        gfSelect.setData(FlxUIDropDownMenuCustom.makeStrIdLabelArray(characterList, true));
		dadSelect.selectedLabel = daDadAnim;
		bfSelect.selectedLabel = daBfAnim;
		gfSelect.selectedLabel = daGfAnim;
    }

    function characterjson(characteruse:String) {
        var characterPath:String = 'characters/' + characteruse + '.json';

        #if MODS_ALLOWED
        var path:String = Paths.modFolders(characterPath);
        if (!FileSystem.exists(path)) {
            path = Paths.getPreloadPath(characterPath);
        }

        if (!FileSystem.exists(path))
        #else
        var path:String = Paths.getPreloadPath(characterPath);
        if (!Assets.exists(path))
        #end
        {
            path = Paths.getPreloadPath('characters/bf.json'); //If a character couldn't be found, change him to BF just to prevent a crash
        }

        #if MODS_ALLOWED
        var rawJson = File.getContent(path);
        #else
        var rawJson = Assets.getText(path);
        #end

        var json:CharacterFile = cast Json.parse(rawJson);
        return json;
    }

    function updateCoords() {
        if (selectedObj == bf || selectedObj == dad) {
            var xobj = selectedObj.x;
            var yobj = selectedObj.y;
            objCoords.text = 'Coordenadas: [' + xobj + '; ' + yobj + ']';
        } else {
            objCoords.text = 'Coordenadas: [' + selectedObj.x + '; ' + selectedObj.y + ']';
            for (i in bgMapInfos.keys()) {
                if (i == selectedObj) {
                    var objectArray:Array<Dynamic> = [
                        bgMapInfos[i][0],
                        bgMapInfos[i][1],
                        selectedObj.x,
                        selectedObj.y,
                        bgMapInfos[i][4],
                        bgMapInfos[i][5],
                        bgMapInfos[i][6],
                        bgMapInfos[i][7],
                        bgMapInfos[i][8],
                        bgMapInfos[i][9],
                        bgMapInfos[i][10],
                        bgMapInfos[i][11],
                        bgMapInfos[i][12],
                        bgMapInfos[i][13],
                        bgMapInfos[i][14],
                        bgMapInfos[i][15],
                        bgMapInfos[i][16],
                        bgMapInfos[i][17]
                    ];
                    bgMapInfos.set(i, objectArray);
                }
            }
        }
        selectedObj.updateHitbox();
    }      
    
    function updateSize() {
        selectedObj.updateHitbox();
        objSize.text = 'Tamanho: [' + selectedObj.scale.x + '; ' + selectedObj.scale.y + ']';
        for (i in bgMapInfos.keys()) {
            if (i == selectedObj) {
                var objectArray:Array<Dynamic> = [
                    bgMapInfos[i][0],
                    bgMapInfos[i][1],
                    bgMapInfos[i][2],
                    bgMapInfos[i][3],
                    selectedObj.scale.x,
                    selectedObj.scale.y,
                    bgMapInfos[i][6],
                    bgMapInfos[i][7],
                    bgMapInfos[i][8],
                    bgMapInfos[i][9],
                    bgMapInfos[i][10],
                    bgMapInfos[i][11],
                    bgMapInfos[i][12],
                    bgMapInfos[i][13],
                    bgMapInfos[i][14],
                    bgMapInfos[i][15],
                    bgMapInfos[i][16],
                    bgMapInfos[i][17]
                ];
                bgMapInfos.set(i, objectArray);
            }
        }
        updateCoords();
    }

    function updateScroll() {
        selectedObj.updateHitbox();
        objScroll.text = 'Rolagem: [' + selectedObj.scrollFactor.x + '; ' + selectedObj.scrollFactor.y + ']';
        for (i in bgMapInfos.keys()) {
            if (i == selectedObj) {
                var objectArray:Array<Dynamic> = [
                    bgMapInfos[i][0],
                    bgMapInfos[i][1],
                    bgMapInfos[i][2],
                    bgMapInfos[i][3],
                    bgMapInfos[i][4],
                    bgMapInfos[i][5],
                    selectedObj.scrollFactor.x,
                    selectedObj.scrollFactor.y,
                    bgMapInfos[i][8],
                    bgMapInfos[i][9],
                    bgMapInfos[i][10],
                    bgMapInfos[i][11],
                    bgMapInfos[i][12],
                    bgMapInfos[i][13],
                    bgMapInfos[i][14],
                    bgMapInfos[i][15],
                    bgMapInfos[i][16],
                    bgMapInfos[i][17]
                ];
                bgMapInfos.set(i, objectArray);
            }
        }
        updateCoords();
    }

    function changeSpriteLayer() {
        for(theObj in bgMapInfos.keys()) {
            if(theObj == selectedObj) {
                var objectArray:Array<Dynamic> = [
                    bgMapInfos[theObj][0],
                    bgMapInfos[theObj][1],
                    bgMapInfos[theObj][2],
                    bgMapInfos[theObj][3],
                    bgMapInfos[theObj][4],
                    bgMapInfos[theObj][5],
                    bgMapInfos[theObj][6],
                    bgMapInfos[theObj][7],
                    bgMapInfos[theObj][8],
                    isFront,
                    bgMapInfos[theObj][10],
                    bgMapInfos[theObj][11],
                    bgMapInfos[theObj][12],
                    bgMapInfos[theObj][13],
                    bgMapInfos[theObj][14],
                    bgMapInfos[theObj][15],
                    bgMapInfos[theObj][16],
                    bgMapInfos[theObj][17]
                ];
                bgMapInfos.set(theObj, objectArray);
            }
        }
    }

    function changeSpriteAntialiasing() {
        for(theObj in bgMapInfos.keys()) {
            if(theObj == selectedObj) {
                theObj.antialiasing = spriteAntialiasing;
                var objectArray:Array<Dynamic> = [
                    bgMapInfos[theObj][0],
                    bgMapInfos[theObj][1],
                    bgMapInfos[theObj][2],
                    bgMapInfos[theObj][3],
                    bgMapInfos[theObj][4],
                    bgMapInfos[theObj][5],
                    bgMapInfos[theObj][6],
                    bgMapInfos[theObj][7],
                    bgMapInfos[theObj][8],
                    bgMapInfos[theObj][9],
                    theObj.antialiasing,
                    bgMapInfos[theObj][11],
                    bgMapInfos[theObj][12],
                    bgMapInfos[theObj][13],
                    bgMapInfos[theObj][14],
                    bgMapInfos[theObj][15],
                    bgMapInfos[theObj][16],
                    bgMapInfos[theObj][17]
                ];
                bgMapInfos.set(theObj, objectArray);
            }
        }
    }

    function spriteFlips() {
        for(theObj in bgGroup) {
            if(theObj == selectedObj) {
                var objectArray:Array<Dynamic> = [
                    bgMapInfos[theObj][0],
                    bgMapInfos[theObj][1],
                    bgMapInfos[theObj][2],
                    bgMapInfos[theObj][3],
                    bgMapInfos[theObj][4],
                    bgMapInfos[theObj][5],
                    bgMapInfos[theObj][6],
                    bgMapInfos[theObj][7],
                    bgMapInfos[theObj][8],
                    bgMapInfos[theObj][9],
                    bgMapInfos[theObj][10],
                    flipX,
                    flipY,
                    bgMapInfos[theObj][13],
                    bgMapInfos[theObj][14],
                    bgMapInfos[theObj][15],
                    bgMapInfos[theObj][16],
                    bgMapInfos[theObj][17]
                ];
                bgMapInfos.set(theObj, objectArray);
            }
        }
    }

    function changeSpriteAlpha() {
        for(theObj in bgMapInfos.keys()) {
            if(theObj == selectedObj) {
                var objectArray:Array<Dynamic> = [
                    bgMapInfos[theObj][0],
                    bgMapInfos[theObj][1],
                    bgMapInfos[theObj][2],
                    bgMapInfos[theObj][3],
                    bgMapInfos[theObj][4],
                    bgMapInfos[theObj][5],
                    bgMapInfos[theObj][6],
                    bgMapInfos[theObj][7],
                    bgMapInfos[theObj][8],
                    bgMapInfos[theObj][9],
                    bgMapInfos[theObj][10],
                    bgMapInfos[theObj][11],
                    bgMapInfos[theObj][12],
                    theObj.alpha,
                    bgMapInfos[theObj][14],
                    bgMapInfos[theObj][15],
                    bgMapInfos[theObj][16],
                    bgMapInfos[theObj][17]
                ];
                bgMapInfos.set(theObj, objectArray);
            }
        }
    }

    var menuVis:Bool = false;
    var tableTab:String = '';
    function menuChangeVisibility() {
        menuVis = !menuVis;
        tableTab = UI_box.selected_tab_id;
        UI_box.visible = menuVis;
        UI_box.selected_tab_id = tableTab;
        curTag.visible = menuVis;
        objCoords.visible = menuVis;
        objSize.visible = menuVis;
        objScroll.visible = menuVis;
        cameraZoom.visible = menuVis;
        cameraPosition.visible = menuVis;
    }

	var _file:FileReference;

    function onSaveComplete(_):Void {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
        FlxG.log.notice("Successfully saved file.");
    }
    
    /**
     * Called when the save file dialog is cancelled.
     */
    function onSaveCancel(_):Void {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
    }

    /**
     * Called if there is an error while saving the gameplay recording.
     */
    function onSaveError(_):Void {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
        FlxG.log.error("Problem saving file");
    }

    function saveCharacterCoords() {
        var json = {
            "directory": "", // <-- wtf is this?
            "defaultZoom": defaultcamzoom,
            "isPixelStage": stageispixel,

            "boyfriend": [ bf.x - bfjson.position[0] + bfidle[0], bf.y - bfjson.position[1] + bfidle[1] ],
            "girlfriend": [ gf.x - gfjson.position[0] + gfidle[0], gf.y- gfjson.position[1] + gfidle[1] ],
            "opponent": [ dad.x - dadjson.position[0] + dadidle[0], dad.y - dadjson.position[1] + dadidle[1] ],
            "hide_girlfriend": !gf.visible,

            "camera_boyfriend": camBoy,
            "camera_opponent": camDad,
            "camera_girlfriend": camGirl,
            "camera_speed": cameraSpeed
        };

		var data:String = Json.stringify(json, "\t");

		if (data.length > 0) {
            _file = new FileReference();
            _file.addEventListener(Event.COMPLETE, onSaveComplete);
            _file.addEventListener(Event.CANCEL, onSaveCancel);
            _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            _file.save(data, "stage.json");
        }
    }

    function saveAdvancedJson() {
        var json = {};
        for (i in bgMapInfos.keys()) {
            if (i == selectedObj) {
                var tempy = bgMapInfos[i];
                json = {
                    "tag": tempy[0],
                    "path": tempy[1],
                    "x": tempy[2],
                    "y": tempy[3],
                    "scalex": tempy[4],
                    "scaley": tempy[5],
                    "scrollx": tempy[6],
                    "scrolly": tempy[7],
                    "animated": tempy[8],
                    "front": tempy[9],
                    "antialiasing": tempy[10],
                    "flipx": tempy[11],
                    "flipy": tempy[12],
                    "alpha": tempy[13],
                    "idleAnim": tempy[14],
                    "frames": tempy[15],
                    "loop": tempy[16]
                }
            }
        }

		var data:String = Json.stringify(json, "\t");

		if (data.length > 0) {
            _file = new FileReference();
            _file.addEventListener(Event.COMPLETE, onSaveComplete);
            _file.addEventListener(Event.CANCEL, onSaveCancel);
            _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            _file.save(data, "object.json");
        }
    }
    
    private function makeWarningText(theHolyText:String = '') {
        var warnText:FlxText = new FlxText(0, 20, 0, "", 25);
        warnText.setFormat(Paths.font(theFont), 25, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
        warnText.text = theHolyText;
        warnText.x -= 30;
        warnText.cameras = [camHUD];
        warnText.scrollFactor.set();
        warnText.screenCenter(X);
        warnText.borderSize = 1;
        add(warnText);

        new FlxTimer().start(1, function(_) {
            FlxTween.tween(warnText, {y: warnText.y - 20, alpha: 0}, 1, {ease: FlxEase.quadInOut, onComplete:
            function(twn:FlxTween) {
                remove(warnText);
            }});
        });
    }

    private function generateName(base:String, count:Int):String {
        if (count > 0) {
            return base + "-" + count;
        } else {
            return base;
        }
    }

    override function update(elapsed:Float) {
        cameraZoom.text = 'Camera Zoom: ' + Highscore.floorDecimal(FlxG.camera.zoom, 2); // Bruh
        cameraPosition.text = 'Camera Posição: [' + Highscore.floorDecimal(camFollow.x, 2) + ' : ' + Highscore.floorDecimal(camFollow.y, 2) + ']';
        var inputTexts:Array<FlxUIInputText> = [objectInputText, prefixInputText, tagInputText, objectLoadText];
		for (i in 0...inputTexts.length) {
			if(inputTexts[i].hasFocus) {
				if(FlxG.keys.justPressed.ENTER) {
					inputTexts[i].hasFocus = false;
				}
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				super.update(elapsed);
				return;
			}
		}

        FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;

        if(!spritesDropDown.dropPanel.visible && !dadSelect.dropPanel.visible && !bfSelect.dropPanel.visible && !gfSelect.dropPanel.visible) {
            // Back Menu
            if(FlxG.keys.justPressed.ESCAPE) {
                MusicBeatState.switchState(new editors.MasterEditorMenu());
                FlxG.sound.playMusic(Paths.music('freakyMenu'));
				FlxG.mouse.visible = false;
			}

            // Reset Zoom
            if(FlxG.keys.justPressed.R) {
                FlxG.camera.zoom = 1;
            }

            // Change Visibility
            if(FlxG.keys.justPressed.ONE) {
                menuChangeVisibility();
            }

            // Zooming
            if(FlxG.keys.pressed.E && FlxG.camera.zoom < 3) {
                var addToCam:Float = elapsed * FlxG.camera.zoom;
                if(FlxG.keys.pressed.SHIFT) addToCam *= 2;
                FlxG.camera.zoom += addToCam;
                if(FlxG.camera.zoom > 3) FlxG.camera.zoom = 3;
            }
            if(FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.1) {
                var addToCam:Float = elapsed * FlxG.camera.zoom;
                if(FlxG.keys.pressed.SHIFT) addToCam *= 2;
                FlxG.camera.zoom -= addToCam;
                if(FlxG.camera.zoom < 0.1) FlxG.camera.zoom = 0.1;
            }

            // Moving Camera
            if(FlxG.keys.pressed.W || FlxG.keys.pressed.A || FlxG.keys.pressed.S || FlxG.keys.pressed.D) {
                var addToCam:Float = 500 * elapsed;
                if(FlxG.keys.pressed.SHIFT)
                    addToCam *= 4;

                if(FlxG.keys.pressed.W)
                    camFollow.y -= addToCam;
                else if(FlxG.keys.pressed.S)
                    camFollow.y += addToCam;

                if(FlxG.keys.pressed.A)
                    camFollow.x -= addToCam;
                else if(FlxG.keys.pressed.D)
                    camFollow.x += addToCam;
            }

            // Moving Sprite
            if(selectedObj != dummy) {
                if(FlxG.keys.justPressed.LEFT) {
                    var addToObj:Float = 1;
                    if(FlxG.keys.pressed.SHIFT)
                        addToObj *= 10;
                    else if(FlxG.keys.pressed.CONTROL)
                        addToObj *= 100;
    
                    selectedObj.x -= addToObj;
                    updateCoords();
                } else if(FlxG.keys.justPressed.UP) {
                    var addToObj:Float = 1;
                    if(FlxG.keys.pressed.SHIFT)
                        addToObj *= 10;
                    else if(FlxG.keys.pressed.CONTROL)
                        addToObj *= 100;
    
                    selectedObj.y -= addToObj;
                    updateCoords();
                } else if(FlxG.keys.justPressed.RIGHT) {
                    var addToObj:Float = 1;
                    if(FlxG.keys.pressed.SHIFT)
                        addToObj *= 10;
                    else if(FlxG.keys.pressed.CONTROL)
                        addToObj *= 100;
    
                    selectedObj.x += addToObj;
                    updateCoords();
                } else if(FlxG.keys.justPressed.DOWN) {
                    var addToObj:Float = 1;
                    if(FlxG.keys.pressed.SHIFT)
                        addToObj *= 10;
                    else if(FlxG.keys.pressed.CONTROL)
                        addToObj *= 100;
    
                    selectedObj.y += addToObj;
                    updateCoords();
                }
            }

            // Changing Size
            if((FlxG.keys.justPressed.U || FlxG.keys.justPressed.I) && selectedObj != bf && selectedObj != gf && selectedObj != dad && selectedObj != dummy) {
                if(FlxG.keys.justPressed.I) {
                    if(FlxG.keys.pressed.CONTROL) {
                        selectedObj.scale.x += 0.1;
                        updateSize();
                    } else if(FlxG.keys.pressed.SHIFT) {
                        selectedObj.scale.x += 0.05;
                        updateSize();
                    } else {
                        selectedObj.scale.x += 0.01;
                        updateSize();
                    }
                } else if(FlxG.keys.justPressed.U) {
                    if(FlxG.keys.pressed.CONTROL) {
                        selectedObj.scale.x -= 0.1;
                        updateSize();
                    } else if(FlxG.keys.pressed.SHIFT) {
                        selectedObj.scale.x -= 0.05;
                        updateSize();
                    } else {
                        selectedObj.scale.x -= 0.01;
                        updateSize();
                    }
                }
            } else if((FlxG.keys.justPressed.O || FlxG.keys.justPressed.P) && selectedObj != bf && selectedObj != gf && selectedObj != dad && selectedObj != dummy) {
                if(FlxG.keys.justPressed.P) {
                    if(FlxG.keys.pressed.CONTROL) {
                        selectedObj.scale.y += 0.1;
                        updateSize();
                    } else if(FlxG.keys.pressed.SHIFT) {
                        selectedObj.scale.y += 0.05;
                        updateSize();
                    } else {
                        selectedObj.scale.y += 0.01;
                        updateSize();
                    }
                } else if(FlxG.keys.justPressed.O) {
                    if(FlxG.keys.pressed.CONTROL) {
                        selectedObj.scale.y -= 0.1;
                        updateSize();
                    } else if(FlxG.keys.pressed.SHIFT) {
                        selectedObj.scale.y -= 0.05;
                        updateSize();
                    } else {
                        selectedObj.scale.y -= 0.01;
                        updateSize();
                    }
                }
            }

            // Changing Scroll Factor
            if((FlxG.keys.justPressed.V || FlxG.keys.justPressed.B) && selectedObj != bf && selectedObj != gf && selectedObj != dad && selectedObj != dummy) {
                if(FlxG.keys.justPressed.B){
                    if(FlxG.keys.pressed.CONTROL) {
                        selectedObj.scrollFactor.x += 0.1;
                        updateScroll();
                    } else if(FlxG.keys.pressed.SHIFT) {
                        selectedObj.scrollFactor.x += 0.05;
                        updateScroll();
                    } else {
                        selectedObj.scrollFactor.x += 0.01;
                        updateScroll();
                    }
                } else if(FlxG.keys.justPressed.V) {
                    if(FlxG.keys.pressed.CONTROL) {
                        selectedObj.scrollFactor.x -= 0.1;
                        updateScroll();
                    } else if(FlxG.keys.pressed.SHIFT) {
                        selectedObj.scrollFactor.x -= 0.05;
                        updateScroll();
                    } else {
                        selectedObj.scrollFactor.x -= 0.01;
                        updateScroll();
                    }
                }
            } else if((FlxG.keys.justPressed.N || FlxG.keys.justPressed.M) && selectedObj != bf && selectedObj != gf && selectedObj != dad && selectedObj != dummy) {
                if(FlxG.keys.justPressed.M){
                    if(FlxG.keys.pressed.CONTROL) {
                        selectedObj.scrollFactor.y += 0.1;
                        updateScroll();
                    } else if(FlxG.keys.pressed.SHIFT) {
                        selectedObj.scrollFactor.y += 0.05;
                        updateScroll();
                    } else {
                        selectedObj.scrollFactor.y += 0.01;
                        updateScroll();
                    }
                } else if(FlxG.keys.justPressed.N) {
                    if(FlxG.keys.pressed.CONTROL) {
                        selectedObj.scrollFactor.y -= 0.1;
                        updateScroll();
                    } else if(FlxG.keys.pressed.SHIFT) {
                        selectedObj.scrollFactor.y -= 0.05;
                        updateScroll();
                    } else {
                        selectedObj.scrollFactor.y -= 0.01;
                        updateScroll();
                    }
                }
            }
        }
        super.update(elapsed);
    }

    function getIdleOffset(character:String) {
        var tempjson = characterjson(character);

        for (i in tempjson.animations) {
            if (i.anim == "idle") {
                charAnimOffsets = i.offsets;
            }
        }
        return charAnimOffsets;
    }

    function ClipboardAdd(prefix:String = ''):String {
		if(prefix.toLowerCase().endsWith('v')) { //probably copy paste attempt
			prefix = prefix.substring(0, prefix.length-1);
		}

		var text:String = prefix + Clipboard.text.replace('\n', '');
		return text;
	}
    
    override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
        if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)) {
			if(sender == objectInputText)
				objectName = objectInputText.text;

            if(sender == prefixInputText)
				idleAnim = prefixInputText.text;

            if (sender == tagInputText)
                tagName = tagInputText.text;

            if (sender == objectLoadText)
                loadingObj = objectLoadText.text;

		} else if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
            switch(wname) {
                case 'sprite_alpha':
                    if(selectedObj != bf && selectedObj != gf && selectedObj != dad && selectedObj != dummy) {
                        selectedObj.alpha = nums.value;
                        changeSpriteAlpha();
                    }
                case 'anim_frame':
                    framesValue = Std.int(nums.value);
                case 'stage_zoom':
                    defaultcamzoom = nums.value;
                    FlxG.camera.zoom = nums.value;
                case 'camera_speed':
                    cameraSpeed = nums.value;
                case 'bfzoomx':
                    camBoy[0] = nums.value;
                case 'bfzoomy':
                    camBoy[1] = nums.value;
                case 'dadzoomx':
                    camDad[0] = nums.value;
                case 'dadzoomy':
                    camDad[1] = nums.value;
                case 'gfzoomx':
                    camGirl[0] = nums.value;
                case 'gfzoomy':
                    camGirl[1] = nums.value;
            }
		}
    }
}