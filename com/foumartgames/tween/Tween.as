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

package com.foumartgames.tween {
	
	/*
	*
	* Tween - a very basic tweener, capable of linear (non-easing) tweens and delays. It's frame based only.
	*
	* @langversion ActionScript 3.0
	* @playerversion Flash 9.0
	* @tiptext
	*/
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class Tween {
		
		public static var delays:Array;
		public static var timer:Timer;
		
		public static function from(mc:DisplayObject, object:Object = null, duration:uint = 1, ease:Function = null, callback:Function = null, args:Array = null):void{
			var i:uint;
			var count:int = 0;
			var obj:String;
			var tweenObj:Array = [];
			for(obj in object){
				if(obj == "delay"){
					count = - object[obj];
				} else {
					tweenObj.push({property:obj, start:object[obj], end:mc[obj]});
					if(obj == "alpha"){
						if(!mc.visible) {
							mc.alpha = 0;
							mc.visible = true;
						}
					}
				}
			}
			if(tweenObj.length) {
				if(mc.hasEventListener(Event.ENTER_FRAME)){trace("WARNING:Tween.from("+mc.name+") - "+mc+" is already being tweened !");
					mc.removeEventListener(Event.ENTER_FRAME, tween);
				}// else {
					mc.addEventListener(Event.ENTER_FRAME, tween);
					tween(null);
				//}
			}
			function tween(evt:Event):void{
				count += 1;
				if(count > 0){
					for(i = 0; i < tweenObj.length; i++){
						if(tweenObj[i].start > tweenObj[i].end){
							mc[tweenObj[i].property] = tweenObj[i].end + (tweenObj[i].start - tweenObj[i].end) / duration * (duration-count);
						} else {
							mc[tweenObj[i].property] = tweenObj[i].start + (tweenObj[i].end - tweenObj[i].start) / duration * count;
						}
					}
					if(count >= duration){
						if(!mc.alpha)mc.visible = false;
						mc.removeEventListener(Event.ENTER_FRAME, tween);
						if(callback != null) {
							if(args != null){
								callback(args);
							} else {
								callback();
							}
						}
					}
				}
			}
		}
		
		
		
		public static function to(mc:DisplayObject, object:Object = null, duration:uint = 1, ease:Object = null, callback:Function = null, args:Array = null):void{
			var i:uint;
			var count:int = 0;
			var obj:String;
			var tweenObj:Array = [];
			for(obj in object){
				if(obj == "delay"){
					count = - object[obj];
				} else {
					tweenObj.push({property:obj, start:mc[obj], end:object[obj]});
					if(obj == "alpha"){
						if(object[obj] > 0 && !mc.visible) {
							mc.visible = true;
							mc.alpha = 0;
						}
					}
				}
			}
			if(tweenObj.length) {
				if(mc.hasEventListener(Event.ENTER_FRAME)){trace("WARNING:Tween.to("+mc.name+") - "+mc+" is already being tweened !");
					mc.removeEventListener(Event.ENTER_FRAME, tween);
				}// else {
					mc.addEventListener(Event.ENTER_FRAME, tween);
					tween(null);
				//}
			}
			function tween(evt:Event):void{
				count += 1;
				if(count > 0){
					for(i = 0; i < tweenObj.length; i++){
						if(tweenObj[i].start > tweenObj[i].end){
							if(ease){//temporary
								if(ease.ease) {
									mc[tweenObj[i].property] = tweenObj[i].end + (tweenObj[i].start - tweenObj[i].end) / duration * (duration-count);
								}
							} else {
								mc[tweenObj[i].property] = tweenObj[i].end + (tweenObj[i].start - tweenObj[i].end) / duration * (duration-count);
							}
						} else {
							if(ease){
								if(ease.ease) {
									if(ease.ease) mc[tweenObj[i].property] = tweenObj[i].start - (tweenObj[i].start - tweenObj[i].end) / duration * count;
								}
							} else {
								mc[tweenObj[i].property] = tweenObj[i].start - (tweenObj[i].start - tweenObj[i].end) / duration * count;
							}
						}
					}
					if(count >= duration){
						if(!mc.alpha) mc.visible = false;
						mc.removeEventListener(Event.ENTER_FRAME, tween);
						if(callback != null) {
							if(args != null){
								callback(args);
							} else {
								callback();
							}
						}
					}
				}
			}
		}
		
		public static function clearDelays():void{
			if(delays){
				delays.length = 0;
				delays = null;
			}
			if(timer){
				timer.removeEventListener(TimerEvent.TIMER, delayTween);
				timer.stop();
			}
		}
		
		public static function checkDelay(callback:Function):int{
			for(var i:uint = 0; i < delays.length; i++){
				if(callback == delays[i].callback){
					return i;
				}
			}
			return -1;
		}
		public static function delay(duration:uint = 0, callback:Function = null, ...args ):void{
			if(duration > 0) {
				if(delays == null){
					delays = [];
					timer = new Timer(18);
					timer.start();
					timer.addEventListener(TimerEvent.TIMER, delayTween);
				}
				var delayer:Object = {count:-duration, duration:duration, callback:callback, args:args};
				if(checkDelay(delayer.callback) == -1){
					delays.push(delayer);
				} else {
					delays[checkDelay(delayer.callback)].count -= duration;
				}
			}
		}
		
		public static function delayTween(evt:TimerEvent):void{
			for(var i:uint = 0; i < delays.length; i++){
				delays[i].count += 1;
				if(delays[i].count >= 0){
					if(delays[i].callback != null) {
						if(delays[i].args != null){
							delays[i].callback.apply(null, delays[i].args);
						} else {
							delays[i].callback();
						}
					}
					delays.splice(checkDelay(delays[i].callback), 1);
					if(!delays.length){
						delays = null;
						timer.removeEventListener(TimerEvent.TIMER, delayTween);
						timer.stop();
						return;
					}
				}
			}
		}
	}
}
