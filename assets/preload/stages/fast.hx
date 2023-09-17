import hxcodec.flixel.FlxVideo;
import backend.Conductor;

var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('fast-bg'));
bg.scale.set(1.5, 1.5);
addBehindGF(bg);

var bitmap;
var shader;

function onCreatePost() {
	game.cameraSpeed = 0.5;
	game.camZoomingMult = 4;
	game.camZoomingDecay = 2;

	game.camFollow.x += 100;
	game.camFollow.y -= 100;
	game.camGame.snapToTarget();

	game.initLuaShader('pixel');
	shader = game.createRuntimeShader('pixel');
	shader.setFloat('strength', 1);
	game.camGame.setFilters([new ShaderFilter(shader)]);
	game.camGame.alpha = game.camHUD.alpha = 0;

	bitmap = new FlxVideo();
	bitmap.play(Paths.video('sonicintro'));
	bitmap.pause();
	FlxG.game.addChild(bitmap);

	bitmap.onEndReached.add(() -> {
		bitmap.dispose();
		FlxG.game.removeChild(bitmap);
		trace('stopped', curStep);
	});
}
function onSongStart() {
	bitmap.resume();
}
function onDestroy() {
	if (bitmap != null) {
		bitmap.dispose();
		if (FlxG.game.contains(bitmap))
			FlxG.game.removeChild(bitmap);
	}
}

function onStepHit() {
	switch(curStep) {
		case 64:
			FlxTween.tween(game.camGame, {alpha: 1}, Conductor.stepCrochet / 1000 * 5);
			FlxTween.tween(game.camHUD, {alpha: 1}, Conductor.stepCrochet / 1000 * 5);
			FlxTween.num(1, 0, Conductor.stepCrochet / 1000 * 16, {ease: FlxEase.circIn}, v -> {
				shader.setFloat('strength', v);
			});
		case 80:
			game.cameraSpeed = 1.25;
	}
}