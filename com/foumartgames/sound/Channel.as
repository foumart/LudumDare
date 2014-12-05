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
	
	import flash.events.Event;
	import flash.media.SoundChannel;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.Regular;

	public class Channel{
		
		public var sound:Sound;
		public var name:String;
		public var channel:SoundChannel;
		public var soundTransform:SoundTransform;
		public var onComplete:Function;
		public var baseVolume:Number;
		private var _volume:Number;
		
		private var tweenIn:Tween;
		private var tweenOut:Tween;
		
		public function Channel(_sound:Sound, _name:String, _baseVolume:Number, _currentVolume:Number, _completed:Function, _fadeIn:Number = 0) {
			sound = _sound;
			name = _name;
			baseVolume = _baseVolume;
			_volume = _currentVolume;
			onComplete = _completed;
			
			channel = new SoundChannel();
			soundTransform = new SoundTransform(_volume*baseVolume);
			
			channel = sound.play();
			
			if(_fadeIn){
				fadeIn(_fadeIn, _volume);
			} else {
				volume = _volume;
			}
			channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
		}
		
		public function stop(evt:TweenEvent = null):void{
			removeTweens();
			channel.stop();
			if(channel.hasEventListener(Event.SOUND_COMPLETE)) channel.removeEventListener(Event.SOUND_COMPLETE, onComplete);
			onComplete = null;
		}
		public function removeTweens():void{
			if(tweenOut){
				tweenOut.stop();
				if(tweenOut.hasEventListener(TweenEvent.MOTION_FINISH)) tweenOut.removeEventListener(TweenEvent.MOTION_FINISH, stop);
			}
			if(tweenIn){
				tweenIn.stop();
				if(tweenIn.hasEventListener(TweenEvent.MOTION_FINISH)) tweenIn.removeEventListener(TweenEvent.MOTION_FINISH, faded);
			}
		}
		
		public function fadeOut(duration:uint):void{
			channel.removeEventListener(Event.SOUND_COMPLETE, onComplete);
			removeTweens();
			tweenOut = new Tween(this, "volume", Regular.easeInOut, soundTransform.volume, 0, duration, false);
			tweenOut.addEventListener(TweenEvent.MOTION_FINISH, stop);
		}
		
		public function fadeIn(duration:uint, _vol:Number):void{
			removeTweens();
			tweenIn = new Tween(this, "volume", Regular.easeInOut, 0, _vol, duration, false);
			tweenIn.addEventListener(TweenEvent.MOTION_FINISH, faded);
		}
		
		private function faded(evt:TweenEvent = null):void{
			removeTweens();
		}
		
		public function get volume():Number{
			return _volume;
		}
		public function set volume(_vol:Number):void{
			soundTransform.volume = _vol * baseVolume;
			channel.soundTransform = soundTransform;
			_volume = _vol;
		}
	}
}
