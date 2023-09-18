function onCreatePost()
	-- background shit
	makeLuaSprite('bg', 'NewMexico', -600, -300)
	addLuaSprite('bg', false)

	initLuaShader('curve')
	setProperty('dad.useFramePixels', true)
	setSpriteShader('dad', 'curve')
	setShaderFloat('dad', 'curveX', 0.05)

	-- gpu caching bugs jumpscare!!!!!!!!!
	runHaxeCode([[
		import openfl.Lib;
		import options.OptionsState;
		import backend.MusicBeatState;

		if (ClientPrefs.data.cacheOnGPU) {
			FlxG.fullscreen = false;
			for (cam in FlxG.cameras.list)
				cam.alpha = 0;
			Lib.application.window.alert('bro u have gpu caching enabled, pls disable it!!!!!!!!\n\nSwitching to Options Menu...', 'ERROR');

			var state = new OptionsState();
			MusicBeatState.switchState(state);
			OptionsState.onPlayState = true;
			if (state.options.length > 3)
				OptionsState.curSelected = 3;

			if(ClientPrefs.data.pauseMusic != 'None')
			{
				FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)));
				FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
			}
		}
	]])
end