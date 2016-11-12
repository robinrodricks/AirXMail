/**
 *  Copyright (c)  2009 coltware.com
 *  http://www.coltware.com 
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxmail
{
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.StringUtil;
	
	public class MimeHeader
	{
		private static var log:ILogger = Log.getLogger("com.coltware.airxmail.MimeHeader");
		
		private var _keyName:String;
		private var _value:String;
		private var _org:String;
		
		protected var _params:Object;
		
		public function MimeHeader()
		{
			_params = new Object();
		}
		public function get key():String{
			return _keyName;
		}
		public function set key(v:String):void{
			this._keyName = StringUtil.trim(v);
		}
		public function get value():String{
			return this._value;
		}
		
		public function set value(v:String):void{
			this._value = v;
		}
		
		public function getParameter(_key:String):String{
			if(_params[_key]){
				return _params[_key];
			}
			else{
				return "";
			}
		}
		
		public function setParameter(key:String,val:String):void{
			_params[key] = val;
		}
		
		public function parse(str:String):void{
			_org = str;
			str = StringUtil.trim(str);
			var p:Array = str.split(";");
			for(var i:int = 0; i<p.length; i++){
				if(i == 0){
					this.value = p[0];
				}
				else{
					var str2:String = p[i];
					var pos2:int = str2.indexOf("=");
					var key2:String;
					if(pos2){
						key2 = str2.substring(0,pos2);
						key2 = StringUtil.trim(key2);
						var val2:String = str2.substring(pos2+1);
						var fc:String = val2.charAt(0);
						if(fc == "\"" || fc == "'"){
							_params[key2] = val2.substring(1,val2.length - 1);
						}
						else{
							_params[key2] = StringUtil.trim(val2);
						}
					}
				}
			}
		}
		
		public function toString():String{
			var ret:String = key + ": " + value + ";\r\n";
			for(var _k:String in _params){
				if(_params[_k])
					ret += "\t" + _k + "=\"" + _params[_k] + "\"\r\n";
			}
			return ret;
		}
		
		public function dumpLog():void{
			log.debug(_org + " -> header is [" + key + "]=" + value);
			for(var key:String in _params){
				log.debug(key + "=>" + MimeUtils.decodeMimeHeader(_params[key]));
			}
		}
	}
}