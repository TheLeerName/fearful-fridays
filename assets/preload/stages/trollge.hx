import openfl.geom.Point;
import hxcodec.flixel.FlxVideo;
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

var bg:FlxSprite = new FlxSprite();
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

function onCreatePost() {
	bg.setPosition(70, -35);
	bg.loadGraphic(Paths.image('trollge-bg'));
	bg.scale.set(1.75, 1.75);
	addBehindGF(bg);

	game.dad.shader = game.gf.shader = game.boyfriend.shader = fadeshader;

	trollgeidle.setPosition(game.gf.x - 160, game.gf.y - 30);
	trollgeidle.shader = chromakeyshader;
	loadVideoGraphic(trollgeidle, 'trollgeidle', true);
	addBehindGF(trollgeidle);
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