import Main;

game.camGame.bgColor = 0; // pls do it if you want use my shadow shader properly
game.gf.visible = false;
game.defaultCamZoom = game.camGame.zoom = 0.5;

function onCreatePost() {
	// the cool shadow shader created by me <3
	game.initLuaShader('shadow');
	var shadow = game.createRuntimeShader('shadow');
	shadow.setFloatArray('bgColor', [1.0, 1.0, 1.0]);
	shadow.setFloatArray('shadowColor', [0.7, 0.7, 0.7]);
	shadow.setFloat('offsetY', 0.725);
	shadow.setFloat('sizeY', 1.5);
	game.camGame.setFilters([new ShaderFilter(shadow)]);

	// repositioning
	game.dad.x -= 200;
	game.boyfriend.x += 200;
	game.opponentCameraOffset = [0, 50];
	game.moveCamera(!PlayState.SONG.notes[0].mustHitSection);
	game.camGame.snapToTarget();
}

function onUpdate(elapsed) {
	// make fpsVar black cuz bg is white
	if (Main.fpsVar.textColor == 0xffffffff) 
		Main.fpsVar.textColor = 0xff000000;
}