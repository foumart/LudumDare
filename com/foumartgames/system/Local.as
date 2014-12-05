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

package com.foumartgames.system {
	
	/*
	*
	* Local - a SharedObject controller
	*
	* @langversion ActionScript 3.0
	* @playerversion Flash 9.0
	* @tiptext
	*/
	
	import flash.net.SharedObject;
	import flash.events.Event;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	
	public class Local {
		
		public static var vars:Object;
		
		public static var _name:String;
		public static var _dir:String = "/";
		public static var _size:Number = 100;
		public static var _check:Boolean;
		
		public static var _timeout:uint;
		
		public static var _so:SharedObject;
		public static var _varList:Array;// the passed list of vars
		
		public static function init(_Name:String, _Variables:Array) {
			_name = _Name;
			_so = SharedObject.getLocal(_name, _dir);
			_varList = _Variables;
			vars = {};
			if(_so.size == 0){
				trace("LOCAL: First time running on this machine. Initializing Shared Object...");
				_so.clear();
				trace((_so.flush(_size)=="flushed")?"LOCAL::initializing new shared object..."+_name : "LOCAL:An error occurred while initializing "+_name+" shared object !");
				save(true);
			} else {
				var num:uint = 0;
				trace("LOCAL::loading shared object..."+_name);
				for (var i:String in _so.data.info) {
					vars[i] = _so.data.info[i];
					trace("LOCAL::loading variable..."+i,vars[i]);
					num++;
				}
				trace("LOCAL: Shared Object loaded. variables count:"+num+"("+_varList.length+")");
				_check = true;
			}
		}
		
		public static function clear():void{
			_so.clear();
			trace((_so.flush(_size)=="flushed")?"LOCAL: "+_name+" cleared." : "LOCAL:An error occurred !");
			save(true);
		}
		
		public static function saveSO(info:Object):void{
			if(_timeout) clearTimeout(_timeout);
			_timeout = setTimeout(saveComplete, 1, info);
		}
		
		public static function saveComplete(info:Object):void{
			clearTimeout(_timeout);
			_so.clear();
			_so.data.info = {
				
			};
			for each(var i:Object in _varList) {
				_so.data.info[i.name] = info[i.name];
				vars[i.name] = info[i.name];
				trace("LOCAL::saving variable..."+i.name,info[i.name]);
			}
			_check = true;
			trace((_so.flush(_size)=="flushed")?"LOCAL: "+_name+" updated." : "LOCAL:An error occurred !");
		}
		
		public static function save(initial:Boolean = false):void{
			var soInfo:Object;
			var i:Object;
			if(initial){
				soInfo = new Object();
				for each(i in _varList) {
					soInfo[i.name] = i.value;
					trace("LOCAL::initializing variable..."+i.name,i.value);
				}
				saveSO(soInfo);
			} else {
				soInfo = new Object();
				for(var j:String in vars) {
					soInfo[j] = vars[j];
				}
				saveSO(soInfo);
			}
		}
		
		
		
		public static function get name():String{
			return _name;
		}
		
		public static function set name(nam:String):void{trace("Local:set name:"+nam);
			_name = nam;
			save();
		}
		public static function get ready():Boolean{
			return _check;
		}
		
		public static function set ready(ch:Boolean):void{
			_check = ch;
		}
	}
	
}

