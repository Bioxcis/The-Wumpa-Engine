local originalHudX = 0;
local icon1HudAngle = 0;
local icon2HudAngle = 0;
local scoreTxtAngle = 0;
local originalGameAngle = 0;
local arrowsThingGoesTo = false;
local beatMultiplier = 10;
local noteMovementStarted = false;
local defaultOpponentStrum = {0, 0, 0, 0};
local defaultPlayerStrum = {0, 0, 0, 0};
local ratingRecalculated = false;
local easeLol = 'smoothstepinout'; -- change it to any type of ease if you want
local duration = 0.5; -- change it if you want to
local funIsInfiniteTxt = 'FUN IS INFINITE';
local textActivated = false;
local textActivatedReason = 'fun is infinite';
local songAboutToEnd = false;
local camGameRotating = false;
local rotatingGameVal = 1;

function onCreate()
    originalHudX = getProperty('camHUD.x');
    icon1HudAngle = getProperty('iconP1.angle');
    icon2HudAngle = getProperty('iconP2.angle');
    scoreTxtAngle = getProperty('scoreTxt.angle');
    originalGameAngle = getProperty('camGame.angle');

    makeLuaSprite('invisibleUseless', '', 0, 0);
    makeGraphic('invisibleUseless', 10, 10, '000000');
    screenCenter('invisibleUseless');
    addLuaSprite('invisibleUseless');

    makeLuaText('funIsInfinite', '', screenWidth, screenHeight);
    setTextFont('funIsInfinite', 'sonic-cd-menu-font.ttf');
    setTextSize('funIsInfinite', 100);
    setTextColor('funIsInfinite', 'FFFFFF');
    setTextBorder('funIsInfinite', 4, '1F00D6');
    setTextAlignment('funIsInfinite', 'center');
    setObjectCamera('funIsInfinite', 'other');
    setProperty('funIsInfinite.alpha', 0);
    screenCenter('funIsInfinite', 'y');
    addLuaText('funIsInfinite');

    setProperty('invisibleUseless.alpha', 0);
end

function onStepHit()
    if curStep == 800 then
        textActivated = false;
        doTweenAlpha('funIsInfinteTxt', 'funIsInfinite', 0, crochet / 1000, 'circout');
        if noteMovementStarted == false then
            noteMovementStarted = true;
        end        
    end

    if curStep == 0 then
        triggerEvent('Set Cam Zoom', 1.2, 0);
    end

    if curStep == 4 then
        triggerEvent('Set Cam Zoom', 1.4, 0);
    end

    if curStep == 8 then
        triggerEvent('Set Cam Zoom', 1.6, 0);
    end

    if curStep == 12 then
        triggerEvent('Set Cam Zoom', 1.8, 0);
    end

    if curStep == 9 then
        textActivatedReason = 'past';
        textActivated = true;        
        setTextString('funIsInfinite', 'PAST');
        screenCenter('funIsInfinite');
        doTweenAlpha('funIsInfinteTxt-past', 'funIsInfinite', 0.5, crochet / 1000, 'circout');
    end

    if curStep == 16 then
        textActivated = false;        
        setTextString('funIsInfinite', 'PAST');
        doTweenAlpha('funIsInfinteTxt-past', 'funIsInfinite', 0, crochet / 1000, 'circout');
        camGameRotating = true;
        triggerEvent('Set Cam Zoom', 0.9, 0);
        doTweenAngle('camGameAngleLeft', 'camGame', originalGameAngle + rotatingGameVal, crochet / 1000, 'circout');
    end

    if curStep == 1056 then
        textActivatedReason = 'fun is infinite'
        textActivated = true;
        doTweenAlpha('funIsInfinteTxt', 'funIsInfinite', 0.5, crochet / 1000, 'circout');
    end

    if curStep == 1328 then
        textActivated = false;
        doTweenAlpha('funIsInfinteTxt', 'funIsInfinite', 0, crochet / 1000, 'circout');        
    end

    if curStep == 254 then
        textActivatedReason = 'subtitles_lol';
        textActivated = true;
        setTextString('funIsInfinite', 'THE');
        screenCenter('funIsInfinite');
        doTweenAlpha('funIsInfinteTxt', 'funIsInfinite', 0.5, crochet / 1000, 'circout');  
    end

    if curStep == 256 then
        setTextString('funIsInfinite', 'THE\nFUN');
        screenCenter('funIsInfinite');
    end

    if curStep == 261 then
        setTextString('funIsInfinite', 'NEVER');
        screenCenter('funIsInfinite');
    end

    if curStep == 264 then
        setTextString('funIsInfinite', 'NEVER\nENDS');
        screenCenter('funIsInfinite'); 
    end

    if curStep == 272 then
        textActivated = false;
        doTweenAlpha('funIsInfinteTxt', 'funIsInfinite', 0, crochet / 1000, 'circout');
        screenCenter('funIsInfinite');
    end

    if curStep == 1616 then
        songAboutToEnd = true;
        doTweenAlpha('hudAlpha', 'camHUD', 0, crochet / 1000, 'circout');
        doTweenAngle('camGameFinal', 'camGame', 0, crochet / 1000, 'circout');
    end

    if curStep == 784 then
        textActivatedReason = 'countdown';
        textActivated = true;
        doTweenAlpha('funIsInfinteTxt-countdown', 'funIsInfinite', 0.5, crochet / 1000, 'circout');
        setTextString('funIsInfinite', 'THREE');
        screenCenter('funIsInfinite');
    end

    if curStep == 788 then
        setTextString('funIsInfinite', 'THREE\nTWO');
        screenCenter('funIsInfinite');
    end

    if curStep == 792 then
        setTextString('funIsInfinite', 'THREE\nTWO\nONE');
        screenCenter('funIsInfinite');
    end

    if curStep == 796 then
        setTextString('funIsInfinite', 'GO');
        screenCenter('funIsInfinite');
    end

    if textActivated == true then
        if borderTurn == false then
            setTextBorder('funIsInfinite', 4, '1F00D6');
            borderTurn = true;
        else
            setTextBorder('funIsInfinite', 4, 'FFE900');
            borderTurn = false;
        end
    end
end

local textStuff = 0;

function onBeatHit()
    if camZooming == true and getProperty('camGame.zoom') < 1.35 and cameraZoomOnBeat == true then
        triggerEvent('Add Camera Zoom', 0.015, 0.03);
    end

    if textActivated == true then
        if textActivatedReason == 'fun is infinite' then
            textStuff = textStuff + 1;
    
            if textStuff == 0 then
                setTextString('funIsInfinite', '');
            end
        
            if textStuff == 1 then
                setTextString('funIsInfinite', 'FUN');
                screenCenter('funIsInfinite');
            end
        
            if textStuff == 2 then
                setTextString('funIsInfinite', 'FUN\nIS');
                screenCenter('funIsInfinite');
            end
        
            if textStuff == 3 then
                setTextString('funIsInfinite', 'FUN\nIS\nINFINITE');
                screenCenter('funIsInfinite');
            end
        
            if textStuff == 4 then
                setTextString('funIsInfinite', 'WITH\nSEGA\nENTERPRISES');
                screenCenter('funIsInfinite');
            end
        
            if textStuff > 4 then
                textStuff = 0;
            end
        end
    end
end

function onSongStart()
    defaultOpponentStrum[0] = defaultOpponentStrumX0;
    defaultOpponentStrum[1] = defaultOpponentStrumX1;
    defaultOpponentStrum[2] = defaultOpponentStrumX2;
    defaultOpponentStrum[3] = defaultOpponentStrumX3;

    defaultPlayerStrum[0] = defaultPlayerStrumX0;
    defaultPlayerStrum[1] = defaultPlayerStrumX1;
    defaultPlayerStrum[2] = defaultPlayerStrumX2;
    defaultPlayerStrum[3] = defaultPlayerStrumX3;

    duration = (crochet / 1000) / 2;

    doTweenX('hudToRight', 'camHUD', originalHudX + 20, crochet / 1000, 'circout');
end

function onTweenCompleted(tag)
    if songAboutToEnd == false then
        if tag == 'startShit' or tag == 'hudToRight' then
            doTweenAngle('iconP1AngleLeft', 'iconP1', icon1HudAngle + -3, crochet / 1000, 'circout');
            doTweenAngle('iconP2AngleLeft', 'iconP2', icon1HudAngle + -3, crochet / 1000, 'circout');
            doTweenAngle('scoreTxtAngleLeft', 'scoreTxt', scoreTxtAngle + -1, crochet / 1000, 'circout');
            doTweenX('hudToLeft', 'camHUD', originalHudX - 20, crochet / 1000, 'circout');
        end
    
        if tag == 'hudToLeft' then
            doTweenAngle('iconP1AngleRight', 'iconP1', icon1HudAngle + 3, crochet / 1000, 'circout');
            doTweenAngle('iconP2AngleRight', 'iconP2', icon1HudAngle + 3, crochet / 1000, 'circout');
            doTweenAngle('scoreTxtAngleRight', 'scoreTxt', scoreTxtAngle + 1, crochet / 1000, 'circout');
            doTweenX('hudToRight', 'camHUD', originalHudX + 20, crochet / 1000, 'circout');
        end

        if camGameRotating == true then
            if tag == 'camGameAngleLeft' then
                doTweenAngle('camGameAngleRight', 'camGame', originalGameAngle + -rotatingGameVal, crochet / 1000, 'circout');
            end

            if tag == 'camGameAngleRight' then
                doTweenAngle('camGameAngleLeft', 'camGame', originalGameAngle + rotatingGameVal, crochet / 1000, 'circout');
            end            
        end
    end
end