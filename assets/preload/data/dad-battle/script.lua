function onStepHit(step)
	if step == 116 then
		doTweenZoom('startZoom', 'camGame', 0.75, 1, 'quadOut')
	end
end

function onTweenCompleted(tag)
	if tag == 'startZoom' then
		setCameraZoom(0.9, 'game')
	end
end

function onUpdatePost(elapsed)
	-- if keyboardJustPressed('ONE') then
	-- 	restartSong(false)
	-- end
end

function onStartCountdown()
	--makeMenu()
	--return Function_Stop
end

function makeMenu()
	local size = 80
	makeCusTxt('titulo', 'Resultados', 490, 40, size, 'center')

	makeCusTxt('subtitulo1', 'Jogador 1', 750, 180, size - 20, 'center')
	makeCusTxt('part1', 'Pontos: 500200', getProperty('subtitulo1.x') + 20, getProperty('subtitulo1.y') + 120, size - 50, 'left')
	makeCusTxt('part2', 'Erros: 2', getProperty('subtitulo1.x') + 20, getProperty('part1.y') + 60, size - 50, 'left')
	makeCusTxt('part3', 'Precisão: 100%', getProperty('subtitulo1.x') + 20, getProperty('part1.y') + 120, size - 50, 'left')
	makeCusTxt('part4', 'Qualificação: NSANO!!! [ SSS ]', getProperty('subtitulo1.x') + 20, getProperty('part1.y') + 180, size - 50, 'left')
	makeCusTxt('part5', 'Maior Combo: 20', getProperty('subtitulo1.x') + 20, getProperty('part1.y') + 240, size - 50, 'left')

	makeCusTxt('subtitulo2', 'Jogador 2', 100, 180, size - 20, 'center')
	makeCusTxt('partA1', 'Pontos: 400700', getProperty('subtitulo2.x') + 20, getProperty('subtitulo2.y') + 120, size - 50, 'left')
	makeCusTxt('partA2', 'Erros: 6', getProperty('subtitulo2.x') + 20, getProperty('partA1.y') + 60, size - 50, 'left')
	makeCusTxt('partA3', 'Precisão: 98%', getProperty('subtitulo2.x') + 20, getProperty('partA1.y') + 120, size - 50, 'left')
	makeCusTxt('partA4', 'Qualificação: WHOA!! [ S+ ]', getProperty('subtitulo2.x') + 20, getProperty('partA1.y') + 180, size - 50, 'left')
	makeCusTxt('partA5', 'Maior Combo: 18', getProperty('subtitulo2.x') + 20, getProperty('partA1.y') + 240, size - 50, 'left')

	makeCusTxt('exit', 'Press Esc para sair', getProperty('titulo.x') + 10, 630, size - 40, 'center')
	makeCusTxt('restart', 'Press Enter para Reiniciar', getProperty('titulo.x') - 45, 670, size - 40, 'center')
end

function makeCusTxt(tag, txt, x, y, s, a)
	makeLuaText(tag, txt, 800, x, y)
    setObjectCamera(tag, 'other')
    setTextColor(tag, '0xe85405')
    setTextBorder(tag, 2, '0xff000000')
    setTextSize(tag, s)
    setTextAlignment(tag, a)
    setTextFont(tag, "nsane.ttf")
    addLuaText(tag, true)
end