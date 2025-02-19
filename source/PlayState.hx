package;

import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.effects.chainable.FlxEffectSprite;
import shaderslmfao.BuildingShaders;
import ui.PreferencesMenu;
import shaderslmfao.ColorSwap;
import WiggleEffect.WiggleEffectType;
import shaderslmfao.WaveShader;
#if !hl
#if desktop
import Discord.DiscordClient;
// import Discord.DiscordEventHandlers;
#end
#end
import Section.SwagSection;
import Song.SwagSong;
import SwagCamera.SwagCamPos;
// import flixel.animation.FlxAnimation;I already import it i forgor :skull:
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import lime.ui.Window;
import openfl.utils.Assets as OpenFlAssets;
import flxanimate.FlxAnimate;
import vlc.MP4Handler;
#if sys
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var songEnded:Bool = false;
	public static var practiceMode:Bool = false;
	public static var deathCounter:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var log:Array<String> = [];
	public static function trace(thing:String) {
		for (e in thing.split("\n")) log.push(e);
		trace(thing);
	}

	var halloweenLevel:Bool = false;

	var fromAnimate:FlxAnimate;
	var gfDemon:FlxAnimate;
	var gfDemon2:FlxAnimate;

	var res:Window;
	var video:MP4Handler;
	var _glitch:FlxGlitchEffect;
	public var vocals:FlxSound;
	public var dadVocals:FlxSound;
	public var bfVocals:FlxSound;
	private var vocalsFinished = false;

	public var daHitSound:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	public static var seenVideo:Bool = false;

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;
	private var camPos:FlxPoint;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	var playsCutscene:Bool = false;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	// public var comboSpr:FlxSprite;
	public var numScore:FlxSprite;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var camThing:SwagCamPos;	
	var gfVersion:String = 'gf';
	var foregroundSprites:FlxTypedGroup<BGSprite>;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;
	var lightFadeShader:BuildingShaders;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	// var wiggleShit:WaveShader = new WaveShader();
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;


	var gfCutsceneLayer:FlxGroup;
	var bfTankCutsceneLayer:FlxGroup;

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreCountShit:Int = 0;
	var missCount:Int = 0;
	var audienceRating:String = "";
	var scoreTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;
	
	var henchDies:Bool = false;
	var cs:ChartingState;
	var stageCurtains:FlxSprite;
	var missCauseIgnoreNote:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	override public function create()
	{

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var instPath = Paths.inst(SONG.song.toLowerCase());
		if (OpenFlAssets.exists(instPath, SOUND) || OpenFlAssets.exists(instPath, MUSIC))
			OpenFlAssets.getSound(instPath, true);
		var vocalsPath = Paths.voices(SONG.song.toLowerCase());
		if (OpenFlAssets.exists(vocalsPath, SOUND) || OpenFlAssets.exists(vocalsPath, MUSIC))
			OpenFlAssets.getSound(vocalsPath, true);
		var bfVocalsPath = Paths.bfVoices(SONG.song.toLowerCase());
		if (OpenFlAssets.exists(bfVocalsPath, SOUND) || OpenFlAssets.exists(bfVocalsPath, MUSIC))
			OpenFlAssets.getSound(bfVocalsPath, true);
		var dadVocalsPath = Paths.dadVoices(SONG.song.toLowerCase());
		if (OpenFlAssets.exists(dadVocalsPath, SOUND) || OpenFlAssets.exists(dadVocalsPath, MUSIC))
			OpenFlAssets.getSound(dadVocalsPath, true);				

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.1;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		foregroundSprites = new FlxTypedGroup<BGSprite>();

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"Heh Fucks",
					"After this match get in the car with me.....",
					"Fool"
				];	
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}
		#if !hl
		#if desktop
		initDiscord();
		#end
		#end

		switch (SONG.song.toLowerCase())
		{
                        case 'spookeez' | 'monster' | 'south' | 'south-erect': 
                        {
							curStage = 'spooky';
	                          halloweenLevel = true;

		                  var hallowTex = Paths.getSparrowAtlas('halloween_bg');

	                          halloweenBG = new FlxSprite(-200, -100);
		                  halloweenBG.frames = hallowTex;
	                          halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
	                          halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	                          halloweenBG.animation.play('idle');
	                          halloweenBG.antialiasing = true;
	                          add(halloweenBG);

		                  isHalloween = true;
		          }
		          case 'pico' | 'blammed' | 'philly': 
                        {
							curStage = 'philly';

		                  var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
		                  bg.scrollFactor.set(0.1, 0.1);
		                  add(bg);

	                          var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
		                  city.scrollFactor.set(0.3, 0.3);
		                  city.setGraphicSize(Std.int(city.width * 0.85));
		                  city.updateHitbox();
		                  add(city);

						  lightFadeShader = new BuildingShaders();
		                  phillyCityLights = new FlxTypedGroup<FlxSprite>();
		                  add(phillyCityLights);

		                  for (i in 0...5)
		                  {
		                          var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
		                          light.scrollFactor.set(0.3, 0.3);
		                          light.visible = false;
		                          light.setGraphicSize(Std.int(light.width * 0.85));
		                          light.updateHitbox();
		                          light.antialiasing = true;
								  light.shader = lightFadeShader.shader;
		                          phillyCityLights.add(light);
		                  }

		                  var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
		                  add(streetBehind);

	                          phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
		                  add(phillyTrain);

		                  trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
		                  FlxG.sound.list.add(trainSound);

		                  // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

		                  var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
	                          add(street);
		          }
		          case 'milf' | 'satin-panties' | 'high':
		          {
							loadStage('limo', 0.90);

						//   public static function browserLoad(site:String) {
						// 	#if linux
						// 	Sys.command('/usr/bin/xdg-open', [site]);
						// 	#else
						// 	FlxG.openURL(site);
						// 	#end
						henchDies = true;
	
						  var skyBG:BGSprite = new BGSprite('limo/limoSunset', -120, -50, 0.1, 0.1);
						  add(skyBG);

							  limoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4);
							  add(limoMetalPole);
		  
							  bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
							  add(bgLimo);
		  
							  limoCorpse = new BGSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
							  add(limoCorpse);
		  
							  limoCorpseTwo = new BGSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
							  add(limoCorpseTwo);
		  
							  grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
							  add(grpLimoDancers);
		  
							  for (i in 0...5)
							  {
								  var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
								  dancer.scrollFactor.set(0.4, 0.4);
								  grpLimoDancers.add(dancer);
							  }
		  
							  limoLight = new BGSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
							  add(limoLight);

							  grpLimoParticles = new FlxTypedGroup<BGSprite>();
							  add(grpLimoParticles);
		  
							  //PRECACHE BLOOD
							  var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
							  particle.alpha = 0.01;
							  grpLimoParticles.add(particle);
							  resetLimoKill();

							  limo = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);
		  
							  fastCar = new BGSprite('limo/fastCarLol', -300, 160);
							  fastCar.active = true;
							  fastCar.cameras = [camHUD];
							  limoKillingState = 0;

		                  var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
		                  overlayShit.alpha = 0.5;
						  overlayShit.cameras = [camHUD];
		                  add(overlayShit);

		          }
		          case 'cocoa' | 'eggnog':
		          {
						loadStage('mall', 0.80);

		                  var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  upperBoppers = new FlxSprite(-240, -90);
		                  upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
		                  upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
		                  upperBoppers.antialiasing = true;
		                  upperBoppers.scrollFactor.set(0.33, 0.33);
		                  upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
		                  upperBoppers.updateHitbox();
		                  add(upperBoppers);

		                  var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
		                  bgEscalator.antialiasing = true;
		                  bgEscalator.scrollFactor.set(0.3, 0.3);
		                  bgEscalator.active = false;
		                  bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		                  bgEscalator.updateHitbox();
		                  add(bgEscalator);

		                  var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
		                  tree.antialiasing = true;
		                  tree.scrollFactor.set(0.40, 0.40);
		                  add(tree);

		                  bottomBoppers = new FlxSprite(-300, 140);
		                  bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
		                  bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
		                  bottomBoppers.antialiasing = true;
	                          bottomBoppers.scrollFactor.set(0.9, 0.9);
	                          bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
		                  bottomBoppers.updateHitbox();
		                  add(bottomBoppers);

		                  var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
		                  fgSnow.active = false;
		                  fgSnow.antialiasing = true;
		                  add(fgSnow);

		                  santa = new FlxSprite(-840, 150);
		                  santa.frames = Paths.getSparrowAtlas('christmas/santa');
		                  santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
		                  santa.antialiasing = true;
		                  add(santa);
		          }
		          case 'winter-horrorland':
		          {
						  loadStage('mallEvil',0.9);
		                  var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
		                  evilTree.antialiasing = true;
		                  evilTree.scrollFactor.set(0.2, 0.2);
		                  add(evilTree);

		                  var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
	                          evilSnow.antialiasing = true;
		                  add(evilSnow);
                        }
		          case 'senpai' | 'roses':
		          {
					loadStage('school',1.05);

		                  // defaultCamZoom = 0.9;

		                  var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
		                  bgSky.scrollFactor.set(0.1, 0.1);
		                  add(bgSky);

		                  var repositionShit = -200;

		                  var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
		                  bgSchool.scrollFactor.set(0.6, 0.90);
		                  add(bgSchool);

		                  var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
		                  bgStreet.scrollFactor.set(0.95, 0.95);
		                  add(bgStreet);

		                  var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
		                  fgTrees.scrollFactor.set(0.9, 0.9);
		                  add(fgTrees);

		                  var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
		                  var treetex = Paths.getPackerAtlas('weeb/weebTrees');
		                  bgTrees.frames = treetex;
		                  bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
		                  bgTrees.animation.play('treeLoop');
		                  bgTrees.scrollFactor.set(0.85, 0.85);
		                  add(bgTrees);

		                  var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
		                  treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
		                  treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
		                  treeLeaves.animation.play('leaves');
		                  treeLeaves.scrollFactor.set(0.85, 0.85);
		                  add(treeLeaves);

		                  var widShit = Std.int(bgSky.width * 6);

		                  bgSky.setGraphicSize(widShit);
		                  bgSchool.setGraphicSize(widShit);
		                  bgStreet.setGraphicSize(widShit);
		                  bgTrees.setGraphicSize(Std.int(widShit * 1.4));
		                  fgTrees.setGraphicSize(Std.int(widShit * 0.8));
		                  treeLeaves.setGraphicSize(widShit);

		                  fgTrees.updateHitbox();
		                  bgSky.updateHitbox();
		                  bgSchool.updateHitbox();
		                  bgStreet.updateHitbox();
		                  bgTrees.updateHitbox();
		                  treeLeaves.updateHitbox();

		                  bgGirls = new BackgroundGirls(-100, 190);
		                  bgGirls.scrollFactor.set(0.9, 0.9);

		                  if (SONG.song.toLowerCase() == 'roses')
	                          {
		                          bgGirls.getScared();
		                  }

		                  bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
		                  bgGirls.updateHitbox();
		                  add(bgGirls);
		          }
		          case 'thorns':
		          {
					loadStage('schoolEvil',1.05);


					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

					var posX = 400;
					var posY = 200;

					var bg:FlxSprite = new FlxSprite(posX, posY);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					add(bg);

					var bg2:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
					bg2.scale.set(6, 6);
					bg2.setGraphicSize(Std.int(bg2.width * 6)); //
					bg2.updateHitbox(); //
					add(bg2);

					var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
					fg.scale.set(6, 6);
					fg.setGraphicSize(Std.int(fg.width * 6)); //
					fg.updateHitbox(); //
					add(fg);

					wiggleShit.effectType = WiggleEffectType.DREAMY;
					wiggleShit.waveAmplitude = 0.01;
					wiggleShit.waveFrequency = 60;
					wiggleShit.waveSpeed = 0.8;

					bg.shader = wiggleShit.shader;
					fg.shader = wiggleShit.shader;

					var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
					var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

					// Using scale since setGraphicSize() doesnt work???
					waveSprite.scale.set(6, 6);
					waveSpriteFG.scale.set(6, 6);
					waveSprite.setPosition(posX, posY);
					waveSpriteFG.setPosition(posX, posY);

					waveSprite.scrollFactor.set(0.7, 0.8);
					waveSpriteFG.scrollFactor.set(0.9, 0.8);

					// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
					// waveSprite.updateHitbox();
					// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
					// waveSpriteFG.updateHitbox();

					add(waveSprite);
					add(waveSpriteFG);

					// var posX = 400;
					// var repositionShit = -200;
					// var posY = 200;

					// var schoolBG:FlxSprite = new FlxSprite(-200, 100).loadGraphic(Paths.image('weeb/evilSchool'));
					// wiggleShit.waveAmplitude = 0.02;
					// wiggleShit.waveSpeed = 2;
					// wiggleShit.waveFrequency = 4;
					// schoolBG.shader = wiggleShit.shader;
					// schoolBG.setGraphicSize(Std.int(schoolBG.width * 6));
					// schoolBG.updateHitbox();
					// add(schoolBG);
	
					// var schoolFront:FlxSprite = new FlxSprite(200, 400).loadGraphic(Paths.image('weeb/evilSchoolFG'));
	
					// schoolFront.setGraphicSize(Std.int(schoolFront.width * 6));
					// schoolFront.updateHitbox();
					// add(schoolFront);
		          }
				  case 'guns' | 'stress' | 'ugh':
				  {
					  
						// this goes after tankSky and before tankMoutains in stage file
						// need to accomodate for the velocity thing!
						loadStage('tank', 0.9);
						
						var sky:BGSprite = new BGSprite('tankSky', -400, -400, 0, 0);
						add(sky);
						
						var clouds:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
						clouds.active = true;
						clouds.velocity.x = FlxG.random.float(5, 15);
						add(clouds);
						
						var mountains:BGSprite = new BGSprite('tankMountains', -300, -20, 0.2, 0.2);
						mountains.setGraphicSize(Std.int(mountains.width * 1.2));
						mountains.updateHitbox();
						add(mountains);
						
						var buildings:BGSprite = new BGSprite('tankBuildings', -200, 0, 0.3, 0.3);
						buildings.setGraphicSize(Std.int(buildings.width * 1.1));
						buildings.updateHitbox();
						add(buildings);
						
						var ruins:BGSprite = new BGSprite('tankRuins', -200, 0, 0.35, 0.35);
						ruins.setGraphicSize(Std.int(ruins.width * 1.1));
						ruins.updateHitbox();
						add(ruins);
						
						var smokeL:BGSprite = new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
						add(smokeL);
						
						var smokeR:BGSprite = new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
						add(smokeR);
						
						tankWatchtower = new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
						add(tankWatchtower);
						
						tankGround = new BGSprite('tankRolling', 300, 300, 0.5, 0.5, ['BG tank w lighting'], true);
						add(tankGround);
						
						tankmanRun = new FlxTypedGroup<TankmenBG>();
						add(tankmanRun);
						
						var ground:BGSprite = new BGSprite('tankGround', -420, -150);
						ground.setGraphicSize(Std.int(ground.width * 1.15));
						ground.updateHitbox();
						add(ground);
						moveTank();

						var tank0:BGSprite = new BGSprite('tank0', -500, 650, 1.7, 1.5, ['fg']);
						foregroundSprites.add(tank0);
						
						var tank1:BGSprite = new BGSprite('tank1', -300, 750, 2, 0.2, ['fg']);
						foregroundSprites.add(tank1);
						
						var tank2:BGSprite = new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']);
						foregroundSprites.add(tank2);
						
						var tankdude4:BGSprite = new BGSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']);
						foregroundSprites.add(tankdude4);
						
						var tankdude5:BGSprite = new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']);
						foregroundSprites.add(tankdude5);
						
						var tankdude3:BGSprite = new BGSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']);
						foregroundSprites.add(tankdude3);
				  }
				  case '2hot' | 'darnell' | 'lit-up':
					 {
						// loadStage('street', 0.5);
						curStage = 'street';
						defaultCamZoom = 0.5;
						
						var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('8 Overlay'));
						// overlayShit.alpha = 0.5;
						overlayShit.alpha = 0.3;
						overlayShit.cameras = [camHUD];
						add(overlayShit);

		                  var bg:BGSprite = new BGSprite('backStage', -1500, -1300, 0.9, 0.9);
		                  add(bg);
					} 
		          default:
		          {
						loadStage('stage', 0.9);
		                  var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
		                  add(bg);

		                  var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		                  stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		                  stageFront.updateHitbox();
		                  stageFront.antialiasing = true;
		                  stageFront.scrollFactor.set(0.9, 0.9);
		                  stageFront.active = false;
		                  add(stageFront);

						  var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
						  stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
						  stageLight.updateHitbox();
						  add(stageLight);
						  var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
						  stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
						  stageLight.updateHitbox();
						  stageLight.flipX = true;
						  add(stageLight);

		                  stageCurtains = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		                  stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		                  stageCurtains.updateHitbox();
		                  stageCurtains.antialiasing = true;
		                  stageCurtains.scrollFactor.set(1.3, 1.3);
		                  stageCurtains.active = false;

		                  
		          }
              }


		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
			case 'tank':
				gfVersion = 'gf-tankmen';
			case 'street':
				gfVersion = 'gf-nene';				
		}

		if (SONG.song.toLowerCase() == 'stress')
			gfVersion = 'pico-speaker';

		// #if desktop

		// if (curStage != 'schoolEvil')
		// {
		// 	Application.current.window.title = "Friday Night Funkin' : " + ' - ' + SONG.song.toUpperCase() + ' ('
		// 		+ storyDifficultyText.toUpperCase() + ')';
		// }

		// if (songEnded)
		// {
		// 	Application.current.window.title = "Friday Night Funkin'";
		// }
		// #end

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);
		if (gfVersion == 'pico-speaker')
		{
			gf.x -= 50;
			gf.y -= 200;
			var tankmen:TankmenBG = new TankmenBG(20, 500, true);
			tankmen.strumTime = 10;
			tankmen.resetShit(20, 600, true);
			tankmanRun.add(tankmen);
			for (i in 0...TankmenBG.animationNotes.length)
			{
				if (FlxG.random.bool(16))
				{
					var man:TankmenBG = tankmanRun.recycle(TankmenBG);
					man.strumTime = TankmenBG.animationNotes[i][0];
					man.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
					tankmanRun.add(man);
				}
			}
		}

		dad = new Character(100, 100, SONG.player2);

		camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
				// dad.x += 120;
			case 'monster-christmas':
				dad.y += 130;
				camPos.x += 100;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'darnell':
				camPos.x += 600;
				dad.y += 300;				
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case "tankman":
				dad.y += 180;			
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;				
			case 'tank':
				gf.y += 10;
				gf.x -= 30;
				boyfriend.x += 40;
				boyfriend.y += 0;
				dad.y += 60;
				dad.x -= 80;
				if (gfVersion != 'pico-speaker')
				{
					gf.x -= 170;
					gf.y -= 75;
				}
		}

		add(gf);

		gfCutsceneLayer = new FlxGroup();
		add(gfCutsceneLayer);
		
		bfTankCutsceneLayer = new FlxGroup();
		add(bfTankCutsceneLayer);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);
		// add(tankmanCutsceneLayer);
		add(foregroundSprites);
		add(stageCurtains);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdownPixel;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		if (PreferencesMenu.getPref('downscroll'))
			strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		add(grpNoteSplashes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);
		if (PreferencesMenu.getPref('downscroll'))
			healthBarBG.y = FlxG.height * 0.1;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		grpNoteSplashes.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode && !seenCutscene)
		{
			seenCutscene = true;
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
					#if desktop
					FlxG.sound.music.pitch = 1;
					#end
				case 'ugh':			
					if (PreferencesMenu.getPref('cutscene'))
					{
					ughIntro();							
					}	
					else if	(!PreferencesMenu.getPref('cutscene'))
						{
							startCountdown();
						}

				case 'guns':
					if (PreferencesMenu.getPref('cutscene')) {
					gunsIntro();
					}
					else if	(!PreferencesMenu.getPref('cutscene'))
						{
							startCountdown();
						}
				case 'stress':
					
					if (PreferencesMenu.getPref('cutscene'))
					{	
					stressIntro();
					}
					else if	(!PreferencesMenu.getPref('cutscene'))
						{
							startCountdown();
						}								
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		super.create();
	}

	function numArr(min,max):Array<Int>{
		var a = [];
		var l = max - min;
		var p = min;
		for (i in 0...l){
			a.push(p);
			p++;
		}
		trace(a);
		return a;
	}

	function ughIntro():Void
	{			
		FlxG.camera.zoom = defaultCamZoom * 1.2;

		FlxG.sound.playMusic(Paths.music('DISTORTO'), 0);
		FlxG.sound.music.fadeIn(5, 0, 0.5);
		inCutscene = true;
		dad.visible = false;

		var wellWell = new FlxAnimate(dad.x,dad.y, 'assets/images/cutsceneStuff/WellWell');
		wellWell.antialiasing = true;
		gfCutsceneLayer.add(wellWell);
		wellWell.anim.play();

		wellWell.x = 270;
		wellWell.y = 580;

		camHUD.visible = false;

		FlxG.camera.zoom *= 1.2;
		camFollow.y += 100;

		new FlxTimer().start(0.1, function(tmr:FlxTimer)
		{
			var shit = new FlxSound().loadEmbedded(Paths.sound('wellWellWell','week7'));
			shit.play();
			FlxG.sound.list.add(shit);
		});	

		new FlxTimer().start(3, function(tmr:FlxTimer)
		{
			camFollow.x += 800;
			camFollow.y += 100;
			// FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 0.27, {ease: FlxEase.quadInOut});

			new FlxTimer().start(1.5, function(bep:FlxTimer)
			{
				boyfriend.playAnim('singUP');
				// Play Sound.
				FlxG.sound.play(Paths.sound('bfBeep'), function()
				{
					boyfriend.playAnim('idle');
				});
			});

			new FlxTimer().start(3, function(swaggy:FlxTimer)
			{
				camFollow.x -= 800;
				camFollow.y -= 100;
				// FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 0.5, {ease: FlxEase.quadInOut});
				// tankCutscene.animation.play('killYou');
				FlxG.sound.play(Paths.sound('killYou'), function()
				{
					wellWell.anim.pause();
				});	
				new FlxTimer().start(6.1, function(swagasdga:FlxTimer)
				{
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.crochet / 1000) * 5, {ease: FlxEase.quadInOut});

					FlxG.sound.music.fadeOut((Conductor.crochet / 1000) * 5, 0);

					new FlxTimer().start((Conductor.crochet / 1000) * 5, function(money:FlxTimer)
					{
						dad.visible = true;
						gfCutsceneLayer.remove(wellWell);
					});

					cameraMovement();
					startCountdown();
					camHUD.visible = true;
					inCutscene = false;
				});
			});
		});		

	}	
								

	function playCutscene(name:String)
	{
	  inCutscene = true;
	
	  video = new MP4Handler();
	  video.finishCallback = function()
	  {
		startCountdown();
	  }
	  video.playVideo(Paths.video(name));
	}
	
	function playEndCutscene(name:String)
	{
	  inCutscene = true;
	
	  video = new MP4Handler();
	  video.finishCallback = function()
	  {
		// SONG = Song.loadFromJson(storyPlaylist[0].toLowerCase());
		LoadingState.loadAndSwitchState(new TitleState());
	  }
	  video.playVideo(Paths.video(name));
	}



	function gunsIntro():Void
	{	
		fromAnimate = new FlxAnimate(dad.x,dad.y, 'assets/images/cutsceneStuff/tightBars');
		fromAnimate.antialiasing = true;
		gfCutsceneLayer.add(fromAnimate);
		fromAnimate.anim.play();
		fromAnimate.x = -190;
		fromAnimate.y = 190;

		inCutscene = true;

		camFollow.setPosition(camPos.x, camPos.y);

			camHUD.visible = false;

			FlxG.sound.playMusic(Paths.music('DISTORTO'), 0);
			FlxG.sound.music.fadeIn(5, 0, 0.5);

			camFollow.y += 100;

			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.3}, 4, {ease: FlxEase.quadInOut});

			dad.visible = false;

			new FlxTimer().start(0.1, function(ugly:FlxTimer)
			{
				FlxG.sound.play(Paths.sound('tankSong2'));
			});	

			new FlxTimer().start(4.1, function(ugly:FlxTimer)
			{
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.4}, 0.4, {ease: FlxEase.quadOut});
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.3}, 0.7, {ease: FlxEase.quadInOut, startDelay: 0.45});

				gf.playAnim('sad');
			});

			new FlxTimer().start(11, function(tmr:FlxTimer)
			{
				FlxG.sound.music.fadeOut((Conductor.crochet / 1000) * 5, 0);

				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.crochet * 5) / 1000, {ease: FlxEase.quartIn});
				startCountdown();
				gf.dance();
				new FlxTimer().start((Conductor.crochet * 25) / 1000, function(daTim:FlxTimer)
				{
					dad.visible = true;
					gfCutsceneLayer.remove(fromAnimate);
				});

				camHUD.visible = true;
				inCutscene = false;
		});		
	}

	function stressIntro():Void
	{
		gf.alpha = 0.00001;

		FlxG.camera.zoom = defaultCamZoom = 1.2;

		dad.visible = false;

		camHUD.visible = false;

		

		inCutscene = true;

		// FlxG.camera.zoom *= 1.0;

		// camFollow.x -= dad.x;

		var gfCuts:FlxSprite = new FlxSprite(400, 130);
		gfCuts.frames = Paths.getSparrowAtlas('characters/gfTankmen');
		gfCuts.animation.addByPrefix('dance', 'GF Dancing at Gunpoint0', 24);
		gfCuts.animation.play('dance');
		gfCuts.antialiasing = true;
		gfCuts.y -= 50;
		gfCuts.x = 150;
		gfCuts.alpha = 1.00001;
		gfCutsceneLayer.add(gfCuts);

		fromAnimate = new FlxAnimate(dad.x,dad.y, 'assets/images/cutsceneStuff/TankPissed');
		fromAnimate.antialiasing = true;
		gfCutsceneLayer.add(fromAnimate);
		fromAnimate.anim.play();
		fromAnimate.alpha = 1.00001;
		fromAnimate.x = 460;
		fromAnimate.y = 530;
		fromAnimate.anim.addBySymbol('','TANK TALK 3 P1');
		
		var fromAnimate2 = new FlxAnimate(dad.x,dad.y, 'assets/images/cutsceneStuff/TankReallyPissed');
		fromAnimate2.antialiasing = true;
		fromAnimate2.alpha = 0.00001;
		fromAnimate2.x = 460;
		fromAnimate2.y = 530;
		fromAnimate2.anim.addBySymbol('','TANK TALK 3 P2');

		gfDemon2 = new FlxAnimate(400, -50,'assets/images/cutsceneStuff/Unforeseen Consequences');
		gfDemon2.antialiasing = true;
		gfDemon2.alpha = 0.00001;
		gfDemon2.y = 420;
		gfDemon2.x = 670;


		gfDemon = new FlxAnimate(400, 130,'assets/images/cutsceneStuff/gfDemon');
		gfDemon.antialiasing = true;
		gfDemon.alpha = 0.00001;
		gfDemon.y = -110;
		gfDemon.x = -320;


		camFollow.setPosition(camPos.x, camPos.y);
		camFollow.y += 100;

		
		new FlxTimer().start(0.1, function(GodEfftingDamnit:FlxTimer)
			{
				FlxG.sound.play(Paths.sound('God Effing Dammit'));
				FlxG.sound.playMusic(Paths.music('KALASKIIROMPER'), 0);
				FlxG.sound.music.fadeIn(5, 0, 0.5);
				gf.dance();
			});
			
		new FlxTimer().start(14.8, function(dagfDemon:FlxTimer)
			{
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.6}, 3, {ease: FlxEase.quadInOut});
				camFollow.y -= 200;
				camFollow.x = 570;
				gfCutsceneLayer.remove(gfCuts);
				gfDemon.anim.play('');
				gfDemon.alpha = 1.00001;
				gfCutsceneLayer.add(gfDemon);

			});		
		new FlxTimer().start(15.7, function(dagfDemon:FlxTimer)
			{
				fromAnimate.anim.pause();
			});			
		new FlxTimer().start(17.2, function(dagfDemon:FlxTimer)
			{
				FlxG.camera.zoom = defaultCamZoom = 0.9;
				// camFollow.setPosition(camPos.x, camPos.y);
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 0.9}, 1, {ease: FlxEase.quadInOut});
				camFollow.x = 800;
				gfCutsceneLayer.remove(gfDemon);
				boyfriend.playAnim('bfCatch');	
				gfDemon2.anim.play();
				gfDemon2.alpha = 1.00001;	
				gfCutsceneLayer.add(gfDemon2);		

			});	
		new FlxTimer().start(18.3, function (idle:FlxTimer)
			{
				boyfriend.playAnim('idle');
			});						
		new FlxTimer().start(19.5, function(ahLookWhoIsIt:FlxTimer)
			{
				gfCutsceneLayer.remove(fromAnimate);
				gfCutsceneLayer.add(fromAnimate2);
				FlxG.sound.play(Paths.sound('Tankman After Pico Arrives'));
				fromAnimate2.anim.play();
				fromAnimate2.alpha = 1.00001;
			});	
		new FlxTimer().start(20.5, function(dagfDemon:FlxTimer)
			{
				gfCutsceneLayer.remove(gfDemon2);
				gf.alpha = 1.00001;
			});			
		new FlxTimer().start(20.1, function(daSmth:FlxTimer)	
			{
				camFollow.setPosition(camPos.x, camPos.y);
				camFollow.x = 600;
				camFollow.y = 500;
			});				

		new FlxTimer().start(31.4, function(eugh:FlxTimer)	
		{
			boyfriend.playAnim('singUPmiss');
			FlxG.camera.zoom = defaultCamZoom = 0.9;
			// FlxG.camera.zoom = defaultCamZoom;
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 1.2}, 1, {ease: FlxEase.quadInOut});
			camFollow.x += 500;
			camFollow.y += 100;

			
		});		
		
		new FlxTimer().start(32.3, function(eugh:FlxTimer)	
			{
				FlxG.camera.zoom = defaultCamZoom = 0.9;
				// FlxG.camera.zoom = defaultCamZoom;
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom * 0.9}, 1, {ease: FlxEase.quadInOut});
				cameraMovement();
	
				
			});	

		new FlxTimer().start(35.2, function(dagfDemon:FlxTimer)
			{
				fromAnimate2.anim.pause();

				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.crochet / 1000) * 5, {ease: FlxEase.quadInOut});

				// FlxG.sound.music.fadeOut((Conductor.crochet / 1000) * 5, 0);

				new FlxTimer().start((Conductor.crochet / 1000) * 5, function(money:FlxTimer)
				{
					dad.visible = true;
					gfCutsceneLayer.remove(fromAnimate2);
				});

				cameraMovement();
				startCountdown();
				camHUD.visible = true;
				inCutscene = false;
			});										
	}
#if !hl
	function initDiscord():Void
	{
		#if discord_rpc
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyString();
		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		detailsText = isStoryMode ? "Story Mode: Week " + storyWeek : "Freeplay";

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end
	}
	#end

	public function loadStage(name:String, camZoom:Float) {// i know its look shit but ok lmao
		curStage = name;
		defaultCamZoom = camZoom;
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * daPixelZoom));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += senpaiEvil.width / 5;

		camFollow.setPosition(camPos.x, camPos.y);

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);
			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdownPixel();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer = new FlxTimer();
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		camHUD.visible = true;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer.start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (swagCounter % gfSpeed == 0)
			{
				gf.dance();
			}
			if (swagCounter % 2 == 0)
			{
				if (!boyfriend.animation.curAnim.name.startsWith('sing'))
					boyfriend.playAnim('idle');
				if (!dad.animation.curAnim.name.startsWith('sing'))
					dad.dance();
			}
			else if (dad.curCharacter == 'spooky' && !dad.animation.curAnim.name.startsWith('sing'))
				dad.dance();

			if (generatedMusic)
			{
				notes.members.sort(function (Obj1:Note, Obj2:Note)
				{
					return sortNotes(FlxSort.DESCENDING, Obj1, Obj2);
				});
			}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					if (!curStage.startsWith('school'))
						{
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
						}	
					if (curStage.startsWith('school'))
						{
							FlxG.sound.play(Paths.sound('intro3-pixel'), 0.6);		
						}
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						{
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));		
						FlxG.sound.play(Paths.sound('intro2-pixel'), 0.6);					
						}


					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					if (!curStage.startsWith('school'))
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						{
							FlxG.sound.play(Paths.sound('intro1-pixel'), 0.6);	
						set.setGraphicSize(Std.int(set.width * daPixelZoom));
						}	
					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					if (!curStage.startsWith('school'))
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						{
						go.setGraphicSize(Std.int(go.width * daPixelZoom));		
						FlxG.sound.play(Paths.sound('introGo-pixel'), 0.6);					
						}


					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					if (!curStage.startsWith('school'))
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	function startCountdownPixel():Void
		{
			inCutscene = false;
	
			camHUD.visible = true;
	
			generateStaticArrows(0);
			generateStaticArrows(1);
	
			talking = false;
			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
	
			var swagCounter:Int = 0;
	
			startTimer.start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (swagCounter % gfSpeed == 0)
				{
					gf.dance();
				}
				if (swagCounter % 2 == 0)
				{
					if (!boyfriend.animation.curAnim.name.startsWith('sing'))
						boyfriend.playAnim('idle');
					if (!dad.animation.curAnim.name.startsWith('sing'))
						dad.dance();
				}
				else if (dad.curCharacter == 'spooky' && !dad.animation.curAnim.name.startsWith('sing'))
					dad.dance();
	
				if (generatedMusic)
				{
					notes.members.sort(function (Obj1:Note, Obj2:Note)
					{
						return sortNotes(FlxSort.DESCENDING, Obj1, Obj2);
					});
				}
	
				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', "set", "go"]);
				introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
				introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
	
				var introAlts:Array<String> = introAssets.get('default');
				var altSuffix:String = "";
	
				for (value in introAssets.keys())
				{
					if (value == curStage)
					{
						introAlts = introAssets.get(value);
						altSuffix = '-pixel';
					}
				}
	
				switch (swagCounter)
	
				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3-pixel'), 0.6);
					case 1:
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						ready.scrollFactor.set();
						ready.updateHitbox();
	
						if (curStage.startsWith('school'))
							ready.setGraphicSize(Std.int(ready.width * daPixelZoom));
	
						ready.screenCenter();
						add(ready);
						FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								ready.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2-pixel'), 0.6);
					case 2:
						var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						set.scrollFactor.set();
	
						if (curStage.startsWith('school'))
							set.setGraphicSize(Std.int(set.width * daPixelZoom));
	
						set.screenCenter();
						add(set);
						FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								set.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1-pixel'), 0.6);
					case 3:
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						go.scrollFactor.set();
	
						if (curStage.startsWith('school'))
							go.setGraphicSize(Std.int(go.width * daPixelZoom));
	
						go.updateHitbox();
	
						go.screenCenter();
						add(go);
						FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								go.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo-pixel'), 0.6);
					case 4:
				}
	
				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();
		bfVocals.play();
		// bfVocals.amplitudeRight;
		// dadVocals.amplitudeRight;
		dadVocals.play();
		#if !hl
		#if desktop
		// Song duration in a float, useful for the time left feature
		// songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true);
		#end
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
		{
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			bfVocals = new FlxSound().loadEmbedded(Paths.bfVoices(PlayState.SONG.song));
			dadVocals = new FlxSound().loadEmbedded(Paths.dadVoices(PlayState.SONG.song));
		}	
		else
		{
			vocals = new FlxSound();
			bfVocals = new FlxSound();
			dadVocals = new FlxSound();
		}	


		vocals.onComplete = function()
		{
			vocalsFinished = true;
		};
		bfVocals.onComplete = function()
			{
				vocalsFinished = true;
			};
			dadVocals.onComplete = function()
				{
					vocalsFinished = true;
				};					
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(bfVocals);
		FlxG.sound.list.add(dadVocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.altNote = songNotes[3];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength /= Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return sortNotes(FlxSort.ASCENDING, Obj1, Obj2);
	}

	function sortNotes(Sort:Int = FlxSort.ASCENDING, Obj1:Note, Obj2:Note):Int
	{
		return Obj1.strumTime < Obj2.strumTime ? Sort : Obj1.strumTime > Obj2.strumTime ? -Sort : 0;
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			var colorSwap:ColorSwap = new ColorSwap();

			babyArrow.shader = colorSwap.shader;
			colorSwap.update(Note.arrowColors[i]);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 1');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 2');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 4');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 3');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				bfVocals.pause();
				dadVocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;
			#if !hl
			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if !hl
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if !hl
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if (!_exiting)
		{
			vocals.pause();
			bfVocals.pause();
			dadVocals.pause();
	
			FlxG.sound.music.play();
			#if !debug
			Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;
			#end
			if (!vocalsFinished)
			{
				vocals.time = Conductor.songPosition;
				vocals.play();
				bfVocals.time = Conductor.songPosition;
				bfVocals.play();
				dadVocals.time = Conductor.songPosition;
				dadVocals.play();								
			}
		}
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var limoSpeed:Float = 0;
	var canPause:Bool = true;
	var cameraRightSide:Bool = false;

	override public function update(elapsed:Float)
	{
		FlxG.camera.followLerp = CoolUtil.camLerpShit(0.04);

		#if debug
		perfectMode = false;
		#end

		if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;
			// Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
				lightFadeShader.update(1.5 * (Conductor.crochet / 1000) * FlxG.elapsed);

			case 'limo':
				henchKill();							
			case 'tank':
				moveTank();
		}

		#if desktop
		if (SONG.song.toLowerCase() == 'test')
			{
				if (FlxG.keys.pressed.TWO)//suck my dick you stupid hard code fuck
					{	
						FlxG.sound.music.pitch -= 0.01;	
						
						dadVocals.pitch -= 0.01;
						bfVocals.pitch -= 0.01;
						vocals.pitch -= 0.01;
						// cs.dadVocals.pitch -= 0.01;
						// cs.bfVocals.pitch -= 0.01;
					}
					if (FlxG.keys.pressed.THREE)
					{

					FlxG.sound.music.pitch += 0.01;
						dadVocals.pitch += 0.01;
						bfVocals.pitch += 0.01;
						vocals.pitch += 0.01;
						// cs.dadVocals.pitch += 0.01;
						// cs.bfVocals.pitch += 0.01;
					}
					if (FlxG.keys.justPressed.FIVE)//reset it rn
						{
	
							FlxG.sound.music.pitch = 1;
							dadVocals.pitch = 1;
							bfVocals.pitch = 1;
							vocals.pitch = 1;
							// ps.dadVocals.pitch += 0.01;
							// ps.bfVocals.pitch += 0.01;
							// cs.dadVocals.pitch += 0.01;
							// cs.bfVocals.pitch += 0.01;
						}
			}
			#end

			// #if !debug	
			// if (FlxG.keys.justPressed.EIGHT)//Easter Egg
			// {
			// 	FlxG.switchState(new CoolText());
			// 	FlxG.sound.music.stop();
			// 	dadVocals.stop();
			// 	bfVocals.stop();
			// 	vocals.stop();
			// 	// res.width = 800;
            //     // res.height = 600;
			// }	
			// #end
				
		super.update(elapsed);

		scoreTxt.text = "Miss:" + missCount + " | " + "Score:" + scoreCountShit + " | " + "Combo:" + combo;

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
			{
				var pauseMenu = new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y);
				openSubState(pauseMenu);
				pauseMenu.camera = camHUD;
			}
			#if !hl
			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());
			
			#if !hl
			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.85)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.85)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		// #if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		// #end
		// #if debug
		if (FlxG.keys.justPressed.FOUR)
			FlxG.switchState(new AnimationDebug(SONG.player1));
		// #end

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			cameraRightSide = PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection;
			cameraMovement();
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				// case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					bfVocals.volume = 0;										
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		if (!inCutscene && !_exiting)
		{
			// RESET = Quick Game Over Screen
			if (controls.RESET)
			{
				health = 0;
				trace("RESET = True");
			}

			// CHEAT = brandon's a pussy
			// if (controls.CHEAT)
			// {
			// 	health += 1;
			// 	trace("User is cheating!");
			// }
	
			if (health <= 0 && !practiceMode)
			{
				boyfriend.stunned = true;
	
				persistentUpdate = false;
				persistentDraw = false;
				paused = true;
	
				vocals.stop();
				bfVocals.stop();
				dadVocals.stop();
				FlxG.sound.music.stop();

				deathCounter += 1;
	
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	
				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				#if !hl
				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
				#end
				#end
			}
		}

		while (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1800 / SONG.speed)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.shift();
			}
			else
			{
				break;
			}
		}

		if (generatedMusic)
		{
			
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				var center = strumLine.y + (Note.swagWidth / 2);
				
				// i am so fucking sorry for these if conditions
				if (PreferencesMenu.getPref('downscroll'))
				{
					daNote.y = strumLine.y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);
					
					if (daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
							daNote.y += daNote.prevNote.height;
						else
							daNote.y += daNote.height / 2;

						if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
							&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;
							
							daNote.clipRect = swagRect;
						}
					}
				}
				else
				{
					daNote.y = strumLine.y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);
	
					if (daNote.isSustainNote
						&& daNote.y + daNote.offset.y * daNote.scale.y <= center
						&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
						swagRect.y = (center - daNote.y) / daNote.scale.y;
						swagRect.height -= swagRect.y;

						daNote.clipRect = swagRect;
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}
					if (daNote.altNote)
						altAnim = '-alt';

					switch (Math.abs(daNote.noteData))
					{
						case 0:
							dad.playAnim('singLEFT' + altAnim, true);
							trace('Animation LEFT');
							health -= 0.01;
							if(health <= 0.01)
								{
									health = 0.01;
								}

						case 1:
							dad.playAnim('singDOWN' + altAnim, true);
							health -= 0.01;
							trace('Animation DOWN');
							if(health <= 0.01)
								{
									health = 0.01;
								}
						case 2:
							dad.playAnim('singUP' + altAnim, true);
							health -= 0.01;
							trace('Animation up');
							if(health <= 0.01)
								{
									health = 0.01;
								}

						case 3:
							dad.playAnim('singRIGHT' + altAnim, true);
							health -= 0.01;
							trace('Animation RIGHT');
							if(health <= 0.01)
								{
									health = 0.01;
								}

					}

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;
						dadVocals.volume = 1;
						bfVocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				var doKill = daNote.y < -daNote.height;
				if (PreferencesMenu.getPref('downscroll'))
					doKill = daNote.y > FlxG.height;

				if (doKill)
				{
					if (daNote.tooLate || !daNote.wasGoodHit)
					{
						if (!practiceMode)
						{
						health -= 0.0475;
						missCount += 1;
						combo = 0;
						scoreCountShit -= 10;
						vocals.volume = 0;
						bfVocals.volume = 0;
						dadVocals.volume = 1;
						killCombo();								
						}	
					
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		// if (playsCutscene)
		// 	CoolUtil.coolTextFile(Paths.txt(name + '/' + name));
		
		if (!inCutscene)
			keyShit();


		if (FlxG.keys.justPressed.ONE)
			endSong();

	}

	function killCombo():Void
		{
	
			if (combo > 5 && gf.animOffsets.exists('sad'))
				gf.playAnim('sad');
			if (combo != 0)
			{
				combo = 0;
				missCauseIgnoreNote = true;
			}
	
			if (!practiceMode)
				songScore -= 10;
		}

	public function endSong():Void
	{
		seenCutscene = false;
		deathCounter = 0;
		canPause = false;
		FlxG.sound.music.volume = 0;
		#if desktop
		FlxG.sound.music.pitch = 1;
		#end
		vocals.volume = 0;
		dadVocals.volume = 0;
		bfVocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, scoreCountShit, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{

			songEnded = true;			

			campaignScore += scoreCountShit;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				
				if (storyWeek == 7)
					if (PreferencesMenu.getPref('cutscene'))
						{
							vocals.stop();
							bfVocals.stop();
							dadVocals.stop();
							#if desktop
							FlxG.sound.music.pitch = 1;
							#end
						}	
						else if (!PreferencesMenu.getPref('cutscene'))
							{
								#if desktop
								FlxG.sound.music.pitch = 1;
								#end
								FlxG.sound.playMusic(Paths.music('freakyMenu'));
							}
					


				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				
				if (storyWeek == 7)
					{
						#if desktop
							FlxG.sound.music.pitch = 1;
							#end
							// FlxG.switchState(new StoryMenuState());						
							playEndCutscene('kickstarterTrailer');
					}
					else
					{
						#if desktop
						FlxG.sound.music.pitch = 1;
						#end
						FlxG.switchState(new StoryMenuState());										
						}
													
				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				songEnded = true;
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				if (storyDifficulty == 3)
					difficulty = '-erect';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				FlxG.sound.music.stop();
				vocals.stop();
				bfVocals.stop();
				dadVocals.stop();

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'), 1, false, null, true, function()
					{
						PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
						LoadingState.loadAndSwitchState(new PlayState());
					});
				}
				else
				{
					prevCamFollow = camFollow;
	
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
	
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			
			FlxG.switchState(new FreeplayState());
			
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float, daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;
		bfVocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		// if (PreferencesMenu.getPref('hitsound'))
		// 	{
		// 		FlxG.sound.play(Paths.sound('hitS'), 1.5);
		// 	}

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 50;

		var daRating:String = "sick";
		combo += 1;
		missCauseIgnoreNote = true;
		var audienceRating:String = "Sick!";
		var doSplash:Bool = true;

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			audienceRating = "Shit";
			combo += 1;
			score = 1;
			missCauseIgnoreNote = true;
			doSplash = false;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			audienceRating = "Bad";
			combo += 1;
			score = 5;
			missCauseIgnoreNote = true;
			doSplash = false;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			audienceRating = "Good";
			combo += 1;
			score = 25;
			missCauseIgnoreNote = true;
			doSplash = false;
		}
		else if (combo >= 10)
			{
				// daRating = 'combo';
				score = 200;
				doSplash = true;
				// combo += 1;
				missCauseIgnoreNote = true;
			}		

		if (doSplash)
		{
			var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			splash.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
			grpNoteSplashes.add(splash);
		}

		if (!practiceMode)
			songScore = combo;
			scoreCountShit += score;

			//  if (combo == curBeat)
			// 	daRating = 'combo';
			// else if (combo > 10)
			// 	daRating = 'good'
			// else if (combo > 4)
			// 	daRating = 'bad';
			// else if (combo > 0)
			// 	daRating = 'shit';

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.x = FlxG.width * 0.55 - 40;
		// Make sure rating is visible lol!
		if (rating.x < FlxG.camera.scroll.x)
			rating.x = FlxG.camera.scroll.x;
		else if (rating.x > FlxG.camera.scroll.x + FlxG.camera.width - rating.width)
			rating.x = FlxG.camera.scroll.x + FlxG.camera.width - rating.width;

		rating.y = FlxG.camera.scroll.y + FlxG.camera.height * 0.4 - 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		add(rating);

		if (!curStage.startsWith('school'))
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			}
			rating.updateHitbox();

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
	
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});
			
		if (missCauseIgnoreNote)
		{
			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.y = FlxG.camera.scroll.y + FlxG.camera.height * 0.4 + 80;
			comboSpr.x = FlxG.width * 0.55;
			// Make sure combo is visible lol!
			// 194 firs 4 combo digits
			if (comboSpr.x < FlxG.camera.scroll.x + 194)
				comboSpr.x = FlxG.camera.scroll.x + 194;
			else if (comboSpr.x > FlxG.camera.scroll.x + FlxG.camera.width - comboSpr.width)
				comboSpr.x = FlxG.camera.scroll.x + FlxG.camera.width - comboSpr.width;
	
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;
			comboSpr.velocity.x += FlxG.random.int(1, 10);
			
			add(comboSpr);

	
			if (!curStage.startsWith('school'))
			{
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = true;
			}
			else
			{
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}
	
			comboSpr.updateHitbox();
						var seperatedScore:Array<Int> = [];
	
						seperatedScore.push(Math.floor(combo / 100));
						seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
						seperatedScore.push(combo % 10);
				
						var daLoop:Int = 0;	
						for (i in seperatedScore)
							{
		
								var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
								numScore.screenCenter();
								numScore.x = coolText.x + (43 * daLoop) - 90;
								numScore.y += 100;	
								add(numScore);
					
								if (!curStage.startsWith('school'))
								{
									numScore.antialiasing = true;
									numScore.setGraphicSize(Std.int(numScore.width * 0.5));
								}
								else
								{
									numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
								}
								numScore.updateHitbox();
					
								numScore.acceleration.y = FlxG.random.int(200, 300);
								numScore.velocity.y += FlxG.random.int(40, 10);
								numScore.velocity.x = FlxG.random.float(-5, 5);
					
								FlxTween.tween(numScore, {alpha: 0}, 0.2, {
									onComplete: function(tween:FlxTween)
									{
										numScore.destroy();
									},
									startDelay: Conductor.crochet * 0.002
								});
					
								daLoop++;
								coolText.text = Std.string(seperatedScore);
						}
					
			
			// add(coolText);
	
			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001
			});
	
			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});
	
			curSection += 1;			
		}	

	}

	private function cameraMovement():Void
	{
		if (camFollow.x != dad.getMidpoint().x + 150 && !cameraRightSide)
		{
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

			switch (dad.curCharacter)
			{
				case 'mom':
					camFollow.y = dad.getMidpoint().y;
				case 'senpai' | 'senpai-angry':
					camFollow.y = dad.getMidpoint().y - 430;
					camFollow.x = dad.getMidpoint().x - 100;
			}

			if (dad.curCharacter == 'mom')
				vocals.volume = 1;
				bfVocals.volume = 1;
				dadVocals.volume = 1;

			if (SONG.song.toLowerCase() == 'tutorial')
			{
				tweenCamIn();
			}
		}

		if (cameraRightSide && camFollow.x != boyfriend.getMidpoint().x - 100)
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			switch (curStage)
			{
				case 'limo':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
			}

			if (SONG.song.toLowerCase() == 'tutorial')
			{
				FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
			}
		}
	}

	private function keyShit():Void
	{
		var holdingArray:Array<Bool> = [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT];
		var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
		var releaseArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];

		// FlxG.watch.addQuick('asdfa', upP);
		if (holdingArray.contains(true) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdingArray[daNote.noteData])
					goodNoteHit(daNote);
			});
		}

		if (controlArray.contains(true) && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			var removeList:Array<Note> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					if (ignoreList.contains(daNote.noteData))
					{
						for (possibleNote in possibleNotes)
						{
							if (possibleNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - possibleNote.strumTime) < 10)
							{
								removeList.push(daNote);
							}
							else if (possibleNote.noteData == daNote.noteData && daNote.strumTime < possibleNote.strumTime)
							{
								possibleNotes.remove(possibleNote);
								possibleNotes.push(daNote);
							}
						}
					}
					else
					{
						possibleNotes.push(daNote);
						ignoreList.push(daNote.noteData);
					}
				}
			});

			for (badNote in removeList)
			{
				badNote.kill();
				notes.remove(badNote, true);
				badNote.destroy();
			}

			possibleNotes.sort(function(note1:Note, note2:Note)
			{
				return Std.int(note1.strumTime - note2.strumTime);
			});

			if (perfectMode)
			{
				goodNoteHit(possibleNotes[0]);
			}
			else if (possibleNotes.length > 0)
			{
				for (i in 0...controlArray.length)
				{
					if (controlArray[i] && !ignoreList.contains(i))
					{
						badNoteHit();
					}
				}
				for (possibleNote in possibleNotes)
				{
					if (controlArray[possibleNote.noteData])
					{
						goodNoteHit(possibleNote);
					}
				}
			}
			else
				badNoteHit();
		}
		if (boyfriend.holdTimer > 0.004 * Conductor.stepCrochet && !holdingArray.contains(true) && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
		{
				boyfriend.playAnim('idle');
		}
		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.animation.play('pressed');
			if (!holdingArray[spr.ID])
				spr.animation.play('static');

			if (spr.animation.curAnim.name != 'confirm' || curStage.startsWith('school'))
				spr.centerOffsets();
			else
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
		});
	}

	// function missNote(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
	// 	//Dupe note remove
	// 	notes.forEachAlive(function(note:Note) {
	// 		if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 10) {
	// 			note.kill();
	// 			notes.remove(note, true);
	// 			note.destroy();
	// 		}
	// 	});

	// 	health -= 0.04;
	// 	//trace(daNote.missHealth);
	// 	missCount++;
	// 	vocals.volume = 0;

	// 	var animToPlay:String = '';
	// 	switch (Math.abs(daNote.noteData) % 4)
	// 	{
	// 		case 0:
	// 			animToPlay = 'singLEFTmiss';
	// 		case 1:
	// 			animToPlay = 'singDOWNmiss';
	// 		case 2:
	// 			animToPlay = 'singUPmiss';
	// 		case 3:
	// 			animToPlay = 'singRIGHTmiss';
	// 	}
	// }

	function noteMiss(direction:Int = 1):Void
	{
		// missNote(Note);
		if (!boyfriend.stunned)
		{
			if (!practiceMode)
				{
				songScore = 0;
				scoreCountShit -= 10;
				combo = 0;
				health -= 0.04;	
				}

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
		}
	}

	function badNoteHit()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.NOTE_UP_P;
		var rightP = controls.NOTE_RIGHT_P;
		var downP = controls.NOTE_DOWN_P;
		var leftP = controls.NOTE_LEFT_P;
		if (!PreferencesMenu.getPref('danzah'))
			{
				if (!practiceMode)
					{
					missCount += 1;			
					}	
			
			
					if (leftP)
						noteMiss(0);
					if (downP)
						noteMiss(1);
					if (upP)
						noteMiss(2);
					if (rightP)
						noteMiss(3);
			}

	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				if (!practiceMode)
				{
					popUpScore(note.strumTime, note);

					if (PreferencesMenu.getPref('hitsound'))
						{
							daHitSound = new FlxSound().loadEmbedded(Paths.sound('hitS'));
							daHitSound.play();

							daHitSound.volume = 5.5;	
						}					

				}	
				// combo += 1;
			}

			if (note.noteData >= 0)
			{
				if (!practiceMode)
				{
					health += 0.023;
				}	

			}	
			else
				{
					if (!practiceMode)
					{
						health += 0.004;
					}	
	
				}



			switch (note.noteData)
			{
				case 0:
					boyfriend.playAnim('singLEFT', true);
					if(health <= 0.01)
						{
							health = 0.01;
						}	
				case 1:
					boyfriend.playAnim('singDOWN', true);
					if(health <= 0.01)
						{
							health = 0.01;
						}	
				case 2:
					boyfriend.playAnim('singUP', true);
					if(health <= 0.01)
						{
							health = 0.01;
						}	
				case 3:
					boyfriend.playAnim('singRIGHT', true);
					if(health <= 0.01)
						{
							health = 0.01;
						}	
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;
			bfVocals.volume = 1;

			if (!note.isSustainNote)
			{

				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function henchDied()
	{
		killHenchmen();
		// new FlxTimer().start(6, function(tmr:FlxTimer)
		// 	{
		// 		resetLimoKill();
		// 	});
	}	

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);
		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var tankResetShit:Bool = false;
	var tankMoving:Bool = false;
	var tankAngle:Float = FlxG.random.int(-90, 45);
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankX:Float = 400;

	function moveTank():Void
	{
		if (!inCutscene)
		{
			tankAngle += tankSpeed * FlxG.elapsed;
			tankGround.angle = (tankAngle - 90 + 15);
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}

	function henchKill():Void
	{
		grpLimoParticles.forEach(function(spr:BGSprite) {
			if(spr.animation.curAnim.finished) {
				spr.kill();
				grpLimoParticles.remove(spr, true);
				spr.destroy();
			}
		});

		switch(limoKillingState) {
			case 1:
				limoMetalPole.x += 5000 * FlxG.elapsed;
				limoLight.x = limoMetalPole.x - 180;
				limoCorpse.x = limoLight.x - 50;
				limoCorpseTwo.x = limoLight.x + 35;

				var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
				for (i in 0...dancers.length) {
					if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 130) {
						switch(i) {
							case 0 | 3:
								if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

								var diffStr:String = i == 3 ? ' 2 ' : ' ';
								var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
								grpLimoParticles.add(particle);
								var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
								grpLimoParticles.add(particle);
								var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
								grpLimoParticles.add(particle);

								var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
								particle.flipX = true;
								particle.angle = -57.5;
								grpLimoParticles.add(particle);
							case 1:
								limoCorpse.visible = true;
							case 2:
								limoCorpseTwo.visible = true;
						} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
						dancers[i].x += FlxG.width * 2;
					}
				}

				if(limoMetalPole.x > FlxG.width * 2) {
					// resetLimoKill();
					limoSpeed = 800;
					limoKillingState = 2;
				}

			case 2:
				limoSpeed -= 4000 * FlxG.elapsed;
				bgLimo.x -= limoSpeed * FlxG.elapsed;
				if(bgLimo.x > FlxG.width * 1.5) {
					limoSpeed = 3000;
					limoKillingState = 3;
				}

			case 3:
				limoSpeed -= 2000 * FlxG.elapsed;
				if(limoSpeed < 1000) limoSpeed = 1000;

				bgLimo.x -= limoSpeed * FlxG.elapsed;
				if(bgLimo.x < -275) {
					limoKillingState = 4;
					limoSpeed = 800;
				}

			case 4:
				bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(FlxG.elapsed * 9, 0, 1));
				if(Math.round(bgLimo.x) == -150) {
					bgLimo.x = -150;
					limoKillingState = 0;
				}
		}

		if(limoKillingState > 2) {
			var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
			for (i in 0...dancers.length) {
				dancers[i].x = (370 * i) + bgLimo.x + 280;
			}
		}
	}	
	
	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function killHenchmen():Void
		{
				if(limoKillingState < 1) {
					limoMetalPole.x = -400;
					limoMetalPole.visible = true;
					limoLight.visible = true;
					limoCorpse.visible = false;
					limoCorpseTwo.visible = false;
					limoKillingState = 1;
				}
		}	

	function resetLimoKill():Void
		{
			if(curStage == 'limo') {
				limoMetalPole.x = -500;
				limoMetalPole.visible = false;
				limoLight.x = -500;
				limoLight.visible = false;
				limoCorpse.x = -500;
				limoCorpse.visible = false;
				limoCorpseTwo.x = -500;
				limoCorpseTwo.visible = false;
			}
		}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(bfVocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(dadVocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}				

		// if (SONG.song.toLowerCase() == 'satin-panties' || curStep == 167 || curStep == 427 || curStep == 647)
		#if desktop
		// if (SONG.song.toLowerCase() == 'thorns')
		// 	{
		// 		FlxG.sound.music.pitch = 1.35;
		// 	// if (curStep == 1240)
		// 	// 	{
		// 	// 		FlxG.sound.music.pitch = 1;
		// 	// 	}				
		// 	}
			#end

		// if (SONG.song.toLowerCase() == 'satin-panties')
		// {
		// 	if (PreferencesMenu.getPref('camera-zoom'))
		// 		{	
		// 			if (curSong.toLowerCase() == 'stress' && curBeat >= 896 && curBeat < 1023 && curBeat >= 1280 && curBeat < 1407 && camZooming && FlxG.camera.zoom < 1.35)
		// 				{
		// 					FlxG.camera.zoom += 0.015;
		// 					camHUD.zoom += 0.03;
		// 				}
		// 		}
		// }	


		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.members.sort(function(note1:Note, note2:Note)
			{
				return sortNotes(FlxSort.DESCENDING, note1, note2);
			});
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			// if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
			// 	dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (PreferencesMenu.getPref('camera-zoom'))
		{
			// HARDCODING FOR MILF ZOOMS!
			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

			// if (SONG.song.toLowerCase() == 'satin-panties' || curStep == 167 || curStep == 427 || curStep == 647)
			// {
			// 	killHenchmen();
			// }			

			// CAM ZOOM FOR STRESS HARD BEAT!1!1!1
			if (curSong.toLowerCase() == 'stress' && curBeat >= 896 && curBeat < 1023 && curBeat >= 1280 && curBeat < 1407 && camZooming && FlxG.camera.zoom < 1.35)
				{
					FlxG.camera.zoom += 0.015;
					camHUD.zoom += 0.03;
				}
	
			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (curBeat % 2 == 0)
		{
			if (!boyfriend.animation.curAnim.name.startsWith("sing"))
			{
				boyfriend.playAnim('idle');
			}

			if (!dad.animation.curAnim.name.startsWith("sing"))
			{
				dad.dance();
			}
		}
		else if (dad.curCharacter == 'spooky')
		{
			if (!dad.animation.curAnim.name.startsWith("sing"))
			{
				dad.dance();
			}
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		foregroundSprites.forEach(function(spr:BGSprite)
		{
			spr.dance();
		});

		switch (curStage)
		{
			case 'tank':
				tankWatchtower.dance();
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});
				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
				if(henchDies && FlxG.random.bool(4))
					killHenchmen();	
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					lightFadeShader.reset();

					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;
}
