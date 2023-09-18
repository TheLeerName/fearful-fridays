import flixel.math.FlxMath;
import flixel.effects.FlxFlicker;

import hxcodec.flixel.FlxVideo;

import backend.Conductor;

import lime.utils.Log;
Log.throwErrors = false; // avoid crash on shader errors (im tired from restarting game when i do shaders)

var modchartVideos = [];
var modchartVideosFocusGainedCallbacks = [];
function loadVideoGraphic(sprite:FlxSprite, path:String, shouldLoop:Bool = false) {
	var video = new FlxVideo();
	video.alpha = 0;
	video.play(Paths.video(path), shouldLoop);
	video.onTextureSetup.add(() -> {
		sprite.loadGraphic(video.bitmapData);
	});

	FlxG.signals.focusGained.remove(video.resume);
	var callback = () -> {
		if (!game.paused) video.resume();
	};
	modchartVideosFocusGainedCallbacks.push(callback);
	FlxG.signals.focusGained.add(callback);

	modchartVideos.push(video);
	FlxG.game.addChild(video);
}

var fadeshader:FlxRuntimeShader = new FlxRuntimeShader("
	#pragma header
	void main() {
		#pragma body
		gl_FragColor.rgb /= 1.5; // fade
	}
");
var chromakeyshader = new FlxRuntimeShader("
	#pragma header
	void main() {
		#pragma body
		if (gl_FragColor.r < 0.5 && gl_FragColor.g > 0.5 && gl_FragColor.b < 0.5)
			gl_FragColor = vec4(0.0);

		gl_FragColor.rgb /= 1.5; // fade
	}
");
var trollgeidle:FlxSprite = new FlxSprite();

var bg:FlxSprite = new FlxSprite();
var lightning:FlxSprite = new FlxSprite();
var blackthing:FlxSprite = new FlxSprite();
function onCreatePost() {
	bg.setPosition(-130, 35);
	bg.loadGraphic(Paths.image('trollge-bg'));
	addBehindGF(bg);

	trollgeidle.setPosition(560, 230);
	trollgeidle.shader = chromakeyshader;
	trollgeidle.scale.set(1.25, 1.25);
	trollgeidle.flipX = true;
	loadVideoGraphic(trollgeidle, 'trollgeidle', true);
	addBehindGF(trollgeidle);

	blackthing.makeGraphic(FlxG.width * 3, FlxG.height * 3, 0xff000000);
	blackthing.alpha = 0;
	add(blackthing);

	lightning.setPosition(bg.x, bg.y);
	lightning.loadGraphic(Paths.image('trollge-lightning'));
	lightning.color = 0xffffffff;
	lightning.visible = true;
	add(lightning);

	game.dad.shader = game.boyfriend.shader = fadeshader;
	game.camGame.scroll.set(100, 400);

	// set it to modchartTimers cuz timers not stops when game paused
	game.modchartTimers.set('switchlooped', new FlxTimer().start(FlxG.random.float(2, 5), tmr -> {
		trace('switch', Conductor.stepCrochet / 1000);

		var dur:Float = switchLight();
		tmr.reset(FlxG.random.float(dur + 2, dur + 5));
	}));
}

function makeTween(Object:Dynamic, Values:Dynamic, Duration:Float = 1, ?Options:Dynamic) {
	var tween = FlxTween.tween(Object, Values, Duration, Options);
	game.modchartTweens.set(FlxG.random.float(0, 1) + "", tween);
	return tween;
}
function makeTweenColor(?Sprite:FlxSprite, Duration:Float = 1, FromColor:Int, ToColor:Int, ?Options:Dynamic) {
	var tween = FlxTween.color(Sprite, Duration, FromColor, ToColor, Options);
	game.modchartTweens.set(FlxG.random.float(0, 1) + "", tween);
	return tween;
}

var lerpToLight:Int = 0xffffffff;
function onUpdate(elapsed:Float) {
	lightning.color = FlxMath.lerp(lightning.color, lerpToLight, elapsed * 5);
}

var allowSwitchLight:Bool = false;
function switchLight(?force:Bool) {
	if (allowSwitchLight) {
		var sound = FlxG.sound.play(Paths.sound('buzz'));
		FlxFlicker.flicker(lightning, sound.length / 1000, 0.01, force == null ? !lightning.visible : force);
		return sound.length / 1000;
	}
	return 1;
}

var allowRedLight:Bool = false;
function onSectionHit() {
	if (allowRedLight) lightning.color = 0xffff0000;
}

// 758 764 1020
function onStepHit() {
	switch (curStep) {
		case 124:
			allowSwitchLight = true;
		case 255:
			allowRedLight = true;
		case 758:
			if (!lightning.visible) switchLight(true);
		case 764:
			makeTween(blackthing, {alpha: 0.34}, 4 * Conductor.stepCrochet / 1000);
			game.defaultCamZoom *= 1.25;

			allowRedLight = false;
			lerpToLight = 0xffff0000;
		case 1020:
			makeTween(blackthing, {alpha: 0}, 4 * Conductor.stepCrochet / 1000);
			game.defaultCamZoom /= 1.25;

			allowRedLight = true;
			lerpToLight = 0xffffffff;
		case 1164:
			allowSwitchLight = false;
			if (!lightning.visible) switchLight(true);

			allowRedLight = false;
	}
}

function onDestroy() {
	for (callback in modchartVideosFocusGainedCallbacks) FlxG.signals.focusGained.remove(callback);
	for (video in modchartVideos) if (video != null)
	{
		video.dispose();

		if (FlxG.game.contains(video))
			FlxG.game.removeChild(video);
	}
}

function onPause() {
	for (video in modchartVideos) {
		video.pause();
	}
}
function onResume() {
	for (video in modchartVideos) {
		video.resume();
	}
}