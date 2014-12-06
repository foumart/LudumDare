LudumDare
=========

#### Pre-Shared scripts for using in LudumDare Compo

(prepared for LD#31)

Includes:

- **KeyListener.as** (Keyboard Event controller)
```
	var keyListener:KeyListener = new KeyListener(stage);
	keyListener.space = function():void{ trace("space key was pressed"); }
```

- **Local.as** (Shared Object controller - singleton class)
```
	var _name:String = "myLudumDareGame";
	var _variables:Array = [
		{name:"sound", value:1, save:true},
		{name:"soundMuted", value:false, save:true},
		{name:"members", value:["member1", "member2", "member3"], save:true}
	];
	Local.init(_name, _variables);
	//... later anywhere in your game you can access the variables like this:
	Local.vars.members.push("new member");
	//... and if you're modifying the variables, save to the shared object like this:
	Local.save();
```

- **SoundFX.as** (Sound and Music controller - singleton class)
```
	SoundFX.add(
		[new FXBounce(), new FXComplete(), new FXSlide()],
		[new MusicMenu(), new MusicLevel1()]
	);
	SoundFX.onInit = function():void {
		if(Local.vars.sound) SoundFX.soundVolume = Local.vars.sound;
		if(Local.vars.music) SoundFX.musicVolume = Local.vars.music;
		if(Local.vars.soundMuted) soundOffHandler() else soundOnHandler();
		if(Local.vars.musicMuted) musicOffHandler() else musicOnHandler();
	}
	// start playing music
	SoundFX.playMusic("MusicMenu", 0.5, SoundFX.REPLAY);
	// smooth transition from one track to another
	if(SoundFX.isNowPlaying("MusicMenu")) SoundFX.skipMusic("MusicLevel1", 0.5, 60);
	// playing a sound effect
	SoundFX.playSound("FXSlide", 1, true);
```

- **Tween.as** (a very basic Tweener - singleton class - want to avoid using any third party libraries)
```
	Tween.to(image, {y:image.height}, 10, null,
		function():void{
			trace("tween completed");
		}
	); // tweens the image about 10 frames (sorry - it uses ENTER_FRAME) and then executes a callback function
```
