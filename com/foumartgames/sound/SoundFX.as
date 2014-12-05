/*
	Copyright (C) 23-FEB-2014 by Noncho Savov | Foumart Games | <http://www.foumartgames.com>
	All rights reserved.

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.

	You can reach the author at <contact(at)foumartgames.com>
*/

package com.foumartgames.sound {
	
	/*
	*
	* SoundFX - Sound Controller and Music Player. Can be used as both singleton and object.
	*
	* @param soundCollection Initialized Sounds held in an array.
	*
	* @param musicCollection Initialized Songs held in an array. example: SoundFX.add([new Sound_1(), ...], [new Music_1(), ...]);
	*
	* @langversion ActionScript 3.0
	* @playerversion Flash 9.0
	* @tiptext
	*/
	
	import flash.events.Event;
	
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	
	import flash.media.Sound;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.media.SoundChannel;
	
	public class SoundFX {
		
		public static const REPLAY:String = "replay";
		public static const NEXT:String = "next";
		public static const ONCE:String = "once";
		
		private static var _musicVolume:Number = 1;
		private static var _soundVolume:Number = 1;
		
		public static var _musicMute:Boolean;
		public static var _soundMute:Boolean;
		
		public static var soundFX:Object;
		public static var soundArray:Array;
		public static var musicArray:Array;
		public static var soundCollection:Array;
		public static var musicCollection:Array;
		
		public static var onInit:Function;
		
		public static var onMusicComplete:String = "replay"; // behaviour
		public static var musicID:uint;
		
		private static var check:SoundCheck;
		private static var instance:SoundFX;
		
		public static var isStatic:Boolean;
		public static var initialized:Boolean;
		
		private var _timeout:uint;
		
		
		public static function add(sound_collection:Array = null, music_collection:Array = null):void {
			if( instance == null ) {
				check = new SoundCheck(sound_collection, music_collection);
				instance = new SoundFX(check);
			} else {
				instance.init(check, sound_collection, music_collection);
			}
		}
		
		
		// GETTER / SETTERS
		public static function set musicVolume(vol:Number):void{
			_musicVolume = vol;
			for each(var channel:Channel in musicArray){
				channel.volume = vol;
			}
		}
		public static function get musicVolume():Number{
			return _musicVolume;
		}
		
		public static function set soundVolume(vol:Number):void{
			_soundVolume = vol;
			for each(var channel:Channel in soundArray){
				channel.volume = vol;
			}
		}
		public static function get soundVolume():Number{
			return _soundVolume;
		}
		
		
		
		
		public static function set musicMute(mute:Boolean):void{
			_musicMute = mute;
			for each(var channel:Channel in musicArray){
				if(mute){
					channel.volume = 0;
				} else {
					channel.volume = _musicVolume;
				}
			}
		}
		public static function get musicMute():Boolean{
			return _musicMute;
		}
		
		public static function set soundMute(mute:Boolean):void{
			_soundMute = mute;
			for each(var channel:Channel in soundArray){
				if(mute){
					channel.volume = 0;
				} else {
					channel.volume = _soundVolume;
				}
			}
		}
		public static function get soundMute():Boolean{
			return _soundMute;
		}
		
		
		
		
		public static function playSound(sound:*, volume:Number = 1, multiple:Boolean = true):void {//trace("playSound:",sound, soundFX, soundVolume)
			var newSound:Sound;
			var newName:String;
			if(sound is Sound) {
				newSound = sound;
				newName = getQualifiedClassName(sound);
			} else {
				newSound = soundFX[sound];
				newName = sound;
			}
			if(!multiple) for each(var channel:Channel in soundArray){
				if(channel.name == newName) return;
			}
			if(!newSound) throw new Error("ClassName::SoundFX(static); Function::playSound @param sound must be an initialized Sound object or a string name from sound_collection.")
			var newChannel:Channel = new Channel(newSound, newName, volume, (_soundMute)? 0 : _soundVolume, soundCompleted);
			soundArray.push(newChannel);
		}
		
		public static function playMusic(music:*, volume:Number = 1, on_music_complete:String = null, fadeDuration:uint = 0):void {
			if(on_music_complete) onMusicComplete = on_music_complete;
			var newMusic:Sound;
			var newName:String;
			if(music is Sound) {
				newMusic = music;
				newName = getQualifiedClassName(music);
			} else {
				newMusic = soundFX[music];
				newName = music;
			}
			musicID = musicCollection.indexOf(newMusic);
			if(!newMusic) throw new Error("ClassName::SoundFX(static); Function::playMusic @param music must be an initialized Sound object or a string name from music_collection.")
			var newChannel:Channel = new Channel(newMusic, newName, volume, (_musicMute)? 0 : _musicVolume, musicCompleted, fadeDuration);
			musicArray.push(newChannel);
		}
		
		public static function isNowPlaying(nm:String):Channel{
			for each(var channel:Channel in musicArray) {
				if(channel.name == nm) return channel;
			}
			return null;
		}
		public static function isNowSounding(nm:String):Channel{
			for each(var channel:Channel in soundArray) {
				if(channel.name == nm) return channel;
			}
			return null;
		}
		public static function skipMusic(newMusic:* = null, _vol:Number = 1, duration:uint = 0):void {
			for each(var channel:Channel in musicArray) {
				musicArray.splice(musicArray.indexOf(channel),1);
				channel.fadeOut(duration);
			}
			if(newMusic){
				playMusic(newMusic, _vol, onMusicComplete, duration);
			}
		}
		
		public static function soundCompleted(evt:Event):void{
			removeFromMixer(evt.target as SoundChannel);
		}
		
		public static function musicCompleted(evt:Event):void{
			var _channel:Channel = removeFromJukebox(evt.target as SoundChannel);
			if(onMusicComplete == REPLAY){
				playMusic(musicCollection[musicID], _channel.baseVolume, onMusicComplete);
			} else if(onMusicComplete == NEXT){
				musicID ++;
				if(musicID >= musicCollection.length){
					musicID = 0;
				}
				playMusic(musicCollection[musicID], _channel.baseVolume, onMusicComplete);
			}
		}
		
		public static function removeFromMixer(channel:SoundChannel):Channel {
			for(var i:int = 0; i < soundArray.length; i++) {
				if(soundArray[i].channel == channel) {
					return soundArray.splice(i,1)[0];
					break;
				}
			}
			return null;
		}
		
		public static function removeFromJukebox(channel:SoundChannel):Channel {
			for(var i:int = 0; i < musicArray.length; i++) {
				if(musicArray[i].channel == channel) {
					return musicArray.splice(i,1)[0];
					break;
				}
			}
			return null;
		}
		
		public function SoundFX(sound_collection:* = null, music_collection:Array = null) {
			if(sound_collection is SoundCheck) {
				trace("SoundFX::Initialized as Singleton");
				isStatic = true;
				_timeout = setTimeout(
					function():void{
						init(sound_collection, sound_collection.soundCollection, sound_collection.musicCollection);
					}, 1
				);
			} else if(isStatic){
				trace("SoundFX::Initialized as static Object");
				init(sound_collection, sound_collection.soundCollection, sound_collection.musicCollection);
			} else {
				trace("SoundFX::Initialized as dynamic Object");
				init(null, sound_collection, music_collection);
			}
		}
		
		
		
		
		public function init(sound_object:* = null, sound_collection:Array = null, music_collection:Array = null):void{//trace("init:",sound_object,sounds_collection);
			if(sound_object is SoundCheck) {
				soundCollection = sound_collection;
				musicCollection = music_collection;
			} else {
				soundCollection = sound_collection;
				musicCollection = music_collection;
			}
			musicID = 0;
			soundFX = {};
			soundArray = [];
			musicArray = [];
			
			for each(var fx:Sound in soundCollection){
				soundFX[getQualifiedClassName(fx)] = fx;
			}
			for each(var song:Sound in musicCollection){
				soundFX[getQualifiedClassName(song)] = song;
			}
			initialized = true;
			if(sound_object is SoundCheck) onInit();
		}
	}
}

internal class SoundCheck{
	
	public var soundCollection:Array;
	public var musicCollection:Array;
	
	public function SoundCheck(	_soundCollection:Array, _musicCollection:Array ) {
		soundCollection = _soundCollection;
		musicCollection = _musicCollection;
	}
}
