import openfl.geom.Point;
import hxcodec.flixel.FlxVideoSprite; // u cant use this without my pr!!!! https://github.com/ShadowMario/FNF-PsychEngine/pull/12953/
import lime.utils.Log;

Log.throwErrors = false; // avoid crash on shader errors (im tired from restarting game when i do shaders)

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
var trollgeidle:FlxVideoSprite = new FlxVideoSprite();

function onCreatePost() {
	bg.setPosition(70, -35);
	bg.loadGraphic(Paths.image('trollge-bg'));
	bg.scale.set(1.75, 1.75);
	addBehindGF(bg);

	game.dad.shader = game.gf.shader = game.boyfriend.shader = fadeshader;

	trollgeidle.setPosition(game.gf.x - 160, game.gf.y - 30);
	trollgeidle.play(Paths.video('trollgeidle'), true);
	trollgeidle.shader = chromakeyshader;
	addBehindGF(trollgeidle);
}

function onPause() {
	trollgeidle.pause();
}
function onResume() {
	trollgeidle.resume();
}