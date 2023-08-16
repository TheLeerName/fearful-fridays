import flixel.addons.display.FlxRuntimeShader;
import backend.MusicBeatState;
import objects.Note;
import Reflect;
import backend.Conductor;

function makeShader(glsl_code:String) {
	var shader = new FlxRuntimeShader(glsl_code);
	shader.setFloat('iTime', 0);
	return shader;
}
function makeShaderFromRuntime(name:String) {
	game.initLuaShader(name);
	var shader = game.createRuntimeShader(name);
	shader.setFloat('iTime', 0);
	return shader;
}
function makeShaderFromFunction(glsl_func:String, glsl_outside:String) {
	var shader = makeShader("
		#pragma header
		uniform float iTime;
		" + glsl_outside + "
		void main() {
			gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
			" + glsl_func + "
		}
	");
	return shader;
}

var shaders = [
	// cool shader which replaces some gray color to static
	"bg" => makeShader("
		#pragma header

		#define STATIC_ALPHA 0.7
		#define STATIC_STRENGTH 1.5

		uniform float iTime;
		uniform float colorAdd;

		float rand(vec2 co) {
			return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
		}

		void main() {
			gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
			if (gl_FragColor.rgb == vec3(164. / 255.)) {
				vec2 staticCoord = floor(openfl_TextureSize / openfl_TextureCoordv / STATIC_STRENGTH);
				vec3 staticColor = vec3(rand(vec2(staticCoord.x * staticCoord.y, iTime)));
				gl_FragColor.rgb = mix(gl_FragColor.rgb, staticColor, STATIC_ALPHA) * gl_FragColor.a;
			}

			gl_FragColor.rgb += colorAdd;
		}
	"),
	"psv" => makeShaderFromRuntime('PSV'),
	"zoomblur" => makeShaderFromRuntime('zoomblur'),
	"dad" => makeShaderFromFunction("gl_FragColor.rgb += colorAdd;", "uniform float colorAdd;"),
];
function tweenShader(shader:String, name:String, value:Float, duration:Float, ?options:Dynamic) {
	var field = Reflect.field(shaders[shader].data, name);
	if (field == null) return null;
	if (field.value == null) field.value = [0];
	return FlxTween.num(field.value[0], value, duration, options, function(val:Float) {
		field.value = [val];
	});
}

var camChars_zoomMult = 1;
var camChars:FlxCamera = new FlxCamera();
camChars.bgColor = 0;
FlxG.cameras.remove(game.camHUD, false);
FlxG.cameras.remove(game.camOther, false);
FlxG.cameras.add(camChars, false);
FlxG.cameras.add(game.camHUD, false);
FlxG.cameras.add(game.camOther, false);
game.boyfriendGroup.camera = game.gfGroup.camera = game.dadGroup.camera = camChars;

// bg of dad (your)
var bg = new FlxSprite(-185, 50).loadGraphic(Paths.image('BG3'));
bg.scale.set(1.35, 1.35);
bg.shader = shaders["bg"];
addBehindDad(bg);

// get out bro
game.gfGroup.visible = false;
game.boyfriendGroup.visible = false;

// repos camera
game.isCameraOnForcedPos = true;
game.camGame.scroll.set(0, 0);
game.camGame.snapToTarget();

// change bf icon to coolie
game.iconP1.changeIcon('bf-another');
game.healthBar.rightBar.color = 0xff0066ff;

// applying my best shader!!!!!
var camshaders = [
	new ShaderFilter(shaders["psv"]),
	new ShaderFilter(shaders["zoomblur"]),
];
game.camGame.setFilters(camshaders);
camChars.setFilters(camshaders);
game.camHUD.setFilters(camshaders);

function tweenBlackout(?bgAdd:Float = 0, ?dadAdd:Float = 0, ?duration:Float = 2) {
	tweenShader("bg", "colorAdd", bgAdd, duration);
	tweenShader("dad", "colorAdd", dadAdd, duration);
}

tweenBlackout(0, 0, 0.001); // idk why but uniforms in shaders stays the same in state reloading
var zoomblurAllowed = false;
function onStepHit() {
	switch(curStep) {
		case 16:
			game.playerStrums.members[0].y = -37;
		case 24:
			game.playerStrums.members[0].y = 50;
		case 48:
			game.playerStrums.members[1].y = -37;
		case 56:
			game.playerStrums.members[1].y = 50;
		case 80:
			game.playerStrums.members[2].y = -37;
		case 88:
			game.playerStrums.members[2].y = 50;
		case 112:
			game.playerStrums.members[3].y = -37;
		case 120:
			game.playerStrums.members[3].y = 50;
		case 551:
			zoomblurAllowed = true;
			game.camZoomingDecay = 2;
		case 815:
			zoomblurAllowed = false;
			game.camZoomingDecay = 1;
		case 935:
			zoomblurAllowed = true;
			game.camZoomingDecay = 2;
		case 1071:
			zoomblurAllowed = false;
			game.camZoomingDecay = 1;
		case 1264:
			tweenBlackout(1, -1, Conductor.stepCrochet / 1000 * 64);
		case 1560:
			tweenBlackout(0, 0, Conductor.stepCrochet / 1000 * 24);
		case 2223:
			zoomblurAllowed = true;
			game.camZoomingDecay = 2;
		case 2495:
			zoomblurAllowed = false;
			game.camZoomingDecay = 1;
		case 2599:
			zoomblurAllowed = true;
			game.camZoomingDecay = 2;
		case 2751:
			zoomblurAllowed = false;
			game.camZoomingDecay = 1;
		case 2832:
			tweenBlackout(-1, 1, Conductor.stepCrochet / 1000 * 32);
		case 2992:
			tweenBlackout(-0.5, 0.5, Conductor.stepCrochet / 1000 * 24);
		case 3024:
			tweenBlackout(0, 0, Conductor.stepCrochet / 1000 * 24);
		case 3056:
			tweenBlackout(0.5, -0.5, Conductor.stepCrochet / 1000 * 24);
		case 3088:
			tweenBlackout(1, -1, Conductor.stepCrochet / 1000 * 24);
		case 3120:
			//game.defaultCamZoom *= 1.25;
			camChars_zoomMult *= 1.25;
		case 3136:
			//game.defaultCamZoom *= 1.25;
			camChars_zoomMult *= 1.25;
		case 3152:
			//game.defaultCamZoom *= 1.25;
			camChars_zoomMult *= 1.25;
		case 3168:
			camChars_zoomMult *= 1.25;
		case 3184:
			camChars_zoomMult *= 1.25;
		case 3196:
			camChars_zoomMult *= 1.25;
		case 3204:
			camChars_zoomMult *= 1.5;
		case 3216:
			camChars_zoomMult *= 1.5;
		case 3240:
			camChars_zoomMult *= 1.5;
		case 3242:
			tweenBlackout(0, -1, 0.001);
			FlxTween.tween(game.dad, {alpha: 0}, Conductor.stepCrochet / 1000 * 12);
			FlxTween.tween(game.iconP2, {alpha: 0}, Conductor.stepCrochet / 1000 * 12);
			for (note in game.playerStrums)
				FlxTween.tween(note, {alpha: 0}, Conductor.stepCrochet / 1000 * 32);
			FlxTween.tween(game.iconP1, {alpha: 0}, Conductor.stepCrochet / 1000 * 32);
			FlxTween.tween(game.healthBar, {alpha: 0}, Conductor.stepCrochet / 1000 * 32);
			game.camZoomingMult = 0;
	}
}

// force middlescroll!!!!!!
game.skipArrowStartTween = true;
var saveopst = ClientPrefs.data.opponentStrums;
ClientPrefs.data.opponentStrums = false;
function onCountdownStarted() {
	for (note in game.playerStrums) {
		note.x = Note.swagWidth * note.noteData + 50 + FlxG.width / 2 + PlayState.STRUM_X_MIDDLESCROLL;
		if (!ClientPrefs.data.downScroll) {
			note.y = -125;
		}
	}
}
function onDestroy() {
	ClientPrefs.data.opponentStrums = saveopst;
}

function onCreatePost() {
	// repos dad
	game.dad.y -= 50;
	game.dad.shader = shaders["dad"];
}
function onUpdate(elapsed) {
	if (camChars != null) {
		camChars.scroll.x = game.camGame.scroll.x;
		camChars.scroll.y = game.camGame.scroll.y;
		camChars.zoom = game.camGame.zoom * camChars_zoomMult;
	}

	// updating some bitches
	for (shader in shaders) if (shader.data.iTime != null)
		shader.setFloat('iTime', shader.getFloat('iTime') + elapsed);

	if (zoomblurAllowed)
		shaders["zoomblur"].setFloat('focusPower', (game.camHUD.zoom - 1) * 500);
	else
		shaders["zoomblur"].setFloat('focusPower', 0);
}