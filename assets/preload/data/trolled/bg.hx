import openfl.geom.Point;
import hxcodec.flixel.FlxVideoSprite;

import lime.utils.Log;
Log.throwErrors = false;

function addPoint(point, x, y) {
	point.x += x;
	point.y += y;
	return point;
}

var bg = new FlxSprite(70, -35).loadGraphic(Paths.image('trollge-bg'));
bg.scale.set(1.75, 1.75);
addBehindGF(bg);

// 0.7
game.defaultCamZoom = game.camGame.zoom = 0.7;

game.boyfriend.x += 150;
game.gf.y -= 170;
//game.dad.x += 50;
game.opponentCameraOffset[0] += 150;
game.boyfriendCameraOffset[0] -= 150;
//game.opponentCameraOffset[1] += 50;

var fadeshader = new FlxRuntimeShader("
	#pragma header
	void main() {
		#pragma body
		gl_FragColor.rgb /= 1.5;
		/*if (gl_FragColor.a != 0.) {
			if (gl_FragColor.rgb == vec3(0, 0, 0))
				gl_FragColor.rgb = vec3(1, 1, 1);
			else
				gl_FragColor.rgb = vec3(0, 0, 0);
		}*/
	}
");
game.dad.shader = game.gf.shader = game.boyfriend.shader = fadeshader;

var trollgeidle = new FlxVideoSprite(game.gf.x - 160, game.gf.y - 30);
trollgeidle.play(Paths.video('trollgeidle'), true);
var removegrayshader = new FlxRuntimeShader("
	#pragma header
	void main() {
		#pragma body
		if (gl_FragColor.r < 0.5 && gl_FragColor.g > 0.5 && gl_FragColor.b < 0.5)
			gl_FragColor = vec4(0);

		//if (gl_FragColor.a != 0)
			//gl_FragColor = vec4(1);

		gl_FragColor.rgb /= 1.5;
	}
");
trollgeidle.shader = removegrayshader;
addBehindGF(trollgeidle);

function onPause() {
	trollgeidle.pause();
}
function onResume() {
	trollgeidle.resume();
}