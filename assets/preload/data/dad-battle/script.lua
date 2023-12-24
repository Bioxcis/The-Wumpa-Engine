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