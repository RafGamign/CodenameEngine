import funkin.scripting.events.NoteHitEvent;

public var pixelNotesForBF = true;
public var pixelNotesForDad = true;
public var enablePixelUI = true;
public var enableCameraHacks = true;
public var enablePauseMenu = true;
public var isSpooky = false;

static var daPixelZoom = 6;

/**
 * UI
 */
function onNoteCreation(event) {
    if (event.note.mustPress && !pixelNotesForBF) return;
    if (!event.note.mustPress && !pixelNotesForDad) return;
    
    event.cancel();

    var note = event.note;
    if (event.note.isSustainNote) {
        note.loadGraphic(Paths.image('stages/school/ui/arrowEnds'), true, 7, 6);
        note.animation.add("hold", [event.strumID]);
        note.animation.add("holdend", [4 + event.strumID]);
    } else {
        note.loadGraphic(Paths.image('stages/school/ui/arrows-pixels'), true, 17, 17);
        note.animation.add("scroll", [4 + event.strumID]);
    }
    note.scale.set(daPixelZoom, daPixelZoom);
    note.updateHitbox();
}

function onStrumCreation(event) {
    if (event.player == 1 && !pixelNotesForBF) return;
    if (event.player == 0 && !pixelNotesForDad) return;

    event.cancel();

    var strum = event.strum;
    strum.loadGraphic(Paths.image('stages/school/ui/arrows-pixels'), true, 17, 17);
    strum.animation.add("static", [event.strumID]);
    strum.animation.add("pressed", [4 + event.strumID, 8 + event.strumID], 12, false);
    strum.animation.add("confirm", [12 + event.strumID, 16 + event.strumID], 24, false);
    
    strum.scale.set(daPixelZoom, daPixelZoom);
    strum.updateHitbox();
}

function onCountdown(event) {
    if (!enablePixelUI) return;

    if (event.soundPath != null) event.soundPath = 'pixel/' + event.soundPath;
    event.antialiasing = false;
    event.scale = daPixelZoom;
    event.spritePath = switch(event.swagCounter) {
        case 0: null;
        case 1: 'stages/school/ui/ready';
        case 2: 'stages/school/ui/set';
        case 3: 'stages/school/ui/go';
    };
}

function onPlayerHit(event:NoteHitEvent) {
    if (!enablePixelUI) return;
    event.ratingPrefix = "stages/school/ui/";
    event.ratingScale = daPixelZoom * 0.7;
    event.ratingAntialiasing = false;

    event.numScale = daPixelZoom;
    event.numAntialiasing = false;
}

/**
 * CAMERA HACKS!!
 */
function createPost() {
    if (enablePauseMenu) {
        PauseSubState.script = 'data/scripts/week6-pause';
    }
    if (enableCameraHacks) {
        FlxG.camera.antialiasing = false;
        FlxG.camera.pixelPerfectRender = true;
        FlxG.game.stage.quality = 2;
        
        iconP1.antialiasing = false;
        iconP2.antialiasing = false;
    
        makeCameraPixely(camGame);
        defaultCamZoom /= daPixelZoom;
    }
}

function onStartCountdown() {
    var newNoteCamera = new FlxCamera();
    newNoteCamera.bgColor = 0; // transparent
    FlxG.cameras.add(newNoteCamera, false);

    var pixelSwagWidth = Note.swagWidth + (daPixelZoom - (Note.swagWidth % daPixelZoom));
    // TODO: multikey support??
    for(s in 0...4) {
        var i = 0;
        for(str in [cpuStrums.members[s], playerStrums.members[s]]) {
            // TODO: middlescroll???
            str.x = (FlxG.width * (0.25 + (0.5 * i))) + (pixelSwagWidth * (s - 2));
            str.x -= str.x % daPixelZoom;
            str.cameras = [newNoteCamera];
            i++;
        }
    }
    makeCameraPixely(newNoteCamera);
}

/**
 * Use this to make any camera pixelly (you wont be able to zoom with it anymore!)
 */
public function makeCameraPixely(cam) {
    cam.pixelPerfectRender = true;
    cam.zoom /= Math.min(FlxG.scaleMode.scale.x, FlxG.scaleMode.scale.y) * daPixelZoom;

    var shad = new CustomShader('pixelZoomShader');
    cam.addShader(shad);

    pixellyCameras.push(cam);
    pixellyShaders.push(shad);
}

function pixelCam(cam) {
    makeCameraPixely(cam);
}

var pixellyCameras = [];
var pixellyShaders = [];

function updatePost(elapsed) {

    if (enableCameraHacks) {
        notes.forEach(function(n) {
            n.y -= n.y % daPixelZoom;
        });
    }
    
    for(e in pixellyCameras) {
        if (!e.exists) continue;
        e.zoom = 1 / daPixelZoom / Math.min(FlxG.scaleMode.scale.x, FlxG.scaleMode.scale.y);
    }
    for(e in pixellyShaders) {
        e.pixelZoom = 1 / daPixelZoom / Math.min(FlxG.scaleMode.scale.x, FlxG.scaleMode.scale.y);
    }
}