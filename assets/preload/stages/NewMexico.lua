function onCreatePost()
	-- background shit
	makeLuaSprite('bg', 'NewMexico', -600, -300)
	addLuaSprite('bg', false)

	initLuaShader('curve')
	setProperty('dad.useFramePixels', true)
	setSpriteShader('dad', 'curve')
	setShaderFloat('dad', 'curveX', 0.05)
end