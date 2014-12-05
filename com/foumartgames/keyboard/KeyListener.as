/*
	Copyright (C) 06-DEC-2014 by Noncho Savov | Foumart Games | <http://www.foumartgames.com>
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

package com.foumartgames.keyboard {
	
	/*
	* KeyListener - Basic Keyboard Event Controller, prepared for LudumDare#31
	*
	* @langversion ActionScript 3.0
	* @playerversion Flash 9.0
	* @tiptext
	*/
	
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	
	public class KeyListener {
		
		public var up:*
		public var down:*;
		public var left:*
		public var right:*;
		public var enter:*
		public var space:*
		public var esc:*
		
		public var a:*
		public var b:*
		public var c:*
		public var d:*
		public var e:*
		public var f:*
		public var g:*
		public var h:*
		public var i:*
		public var j:*
		public var k:*
		public var l:*
		public var m:*
		public var n:*
		public var o:*
		public var p:*
		public var q:*
		public var r:*
		public var s:*
		public var t:*
		public var u:*
		public var v:*
		public var w:*
		public var x:*
		public var y:*
		public var z:*
		
		private var _stage:Stage;
		
		private var currentCode:uint = 0;
		private var codeHolder:Array = [];
		private var previousCode:uint = 0;
		
		/*
			* Usage:
			* var keyListener:KeyListener = new KeyListener(stage);
			* keyListener.space = function():void{ trace("space key was pressed"); }
			*
			* @langversion ActionScript 3.0
			* @playerversion Flash 9.0
			* @tiptext
		*/
		
		public function KeyListener(stаge:Stage) {
			_stage = stаge;
			start();
		}
		
		private function start():void{
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, detectKey, false);
			_stage.addEventListener(KeyboardEvent.KEY_UP, detectKeyUp, false);
		}
		
		/*
			* Stops the controller and clears all key references
			*
			* @langversion ActionScript 3.0
			* @playerversion Flash 9.0
			* @tiptext
		*/ 
		public function stop():void{
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, detectKey, false);
			_stage.removeEventListener(KeyboardEvent.KEY_UP, detectKeyUp, false);
			if(_stage.hasEventListener(Event.ENTER_FRAME)) _stage.removeEventListener(Event.ENTER_FRAME, hold);
			codeHolder = [];
			currentCode = 0;
			// remove functional key references
			up = null; down = null; left = null; right = null; enter = null; space = null; esc = null;
			// remove all letter key references
			for(var i:uint = 65; i <= 90; i ++) {
				this[String.fromCharCode(i).toLowerCase()] = null;
			}
		}
		
		private function detectKey(C:KeyboardEvent) {
			if(codeHolder.indexOf(C.keyCode) == -1) {
				previousCode = currentCode;
				currentCode = C.keyCode;
				if(currentCode == 32){
					if(space)space();
				} else if(currentCode == 13){
					if(enter)enter();
				} else if(currentCode == 38){
					if(up)up();
				} else if(currentCode == 40){
					if(down)down();
				} else if(currentCode == 37){
					if(left)left();
				} else if(currentCode == 39){
					if(right)right();
				} else if(currentCode == 27){
					if(esc)esc();
				} else if(currentCode >= 65 && currentCode <= 90){
					if(this[String.fromCharCode(currentCode).toLowerCase()])this[String.fromCharCode(currentCode).toLowerCase()]();
				}
				if(codeHolder.indexOf(currentCode) == -1){
					codeHolder.push(currentCode);
					_stage.addEventListener(Event.ENTER_FRAME, hold);
				}
			}
		}
		private function hold(evt:Event){
			check(currentCode);
		}
		private function check(k:uint){//trace(k)
			//...
		}
		
		private function detectKeyUp(e:KeyboardEvent) { // key release
			if(codeHolder.indexOf(e.keyCode) != -1){
				codeHolder.splice(codeHolder.indexOf(e.keyCode), 1)
			}
			if(codeHolder.length > 0){
				currentCode = codeHolder[codeHolder.length-1];
				if(codeHolder.length>=1){
					currentCode = codeHolder[codeHolder.length-1];
					check(currentCode);
				}
			} else {
				_stage.removeEventListener(Event.ENTER_FRAME, hold);
			}
		}
	}
}
