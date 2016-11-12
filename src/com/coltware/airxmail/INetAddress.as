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
	import com.coltware.airxmail_internal;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.StringUtil;
	
	
	public class INetAddress
	{
		private static var log:ILogger = Log.getLogger("com.coltware.airxmail.InetAddress");
		
		private var _address:String = null;
		private var _personal:String = null;
		
		/**
		 *  E-Mail( XXXXXX &lt;xxxx@yyyy.zz&gt; ) Address class
		 *  
		 */
		public function INetAddress(addr:String = null,personal:String = null)
		{
			this._address = addr;
			this._personal = personal;
		}
		
		/**
		 *  get e-mail address
		 */
		public function get address():String{
			return _address;
		}
		/**
		 *  set e-mail address
		 */
		public function set address(addr:String):void{
			this._address = addr;
		}
		/**
		 *  get e-mail label
		 */
		public function get personal():String{
			return this._personal;
		}
		/**
		 *  set e-mail label
		 */
		public function set personal(label:String):void{
			this._personal = label;
		}
		
		/**
		 *  return Mime encoded string
		 *  
		 */
		public function toMimeString(charset:String = null):String{
			var mime:String = "";
			if(this._personal){
				if(charset == null){
					charset = AirxMailConfig.airxmail_internal::DEFAULT_HEADER_CHARSET;
				}
				if(charset){
					mime += MimeUtils.encodeMimeHeader(this._personal,charset);
				}
				else{
					mime += this._personal;
				}
				if(this._address){
					mime += " <" + this._address + ">";
				}
			}
			else{
				mime += this._address;
			}
			return mime;
		}
		
		public static function parseMimeString(mimeStrs:String):INetAddress{
			var str:String = MimeUtils.decodeMimeHeader(mimeStrs);
			var pos:int = str.indexOf("<");
			var addr:INetAddress = new INetAddress();
			if(pos > -1){
				if(pos == 0 ){
					addr.address = str.substring(1,str.length-1);
				}
				else{
					addr.personal = str.substr(0,pos);
					addr.address  = str.substring(pos+1,str.length -1);
				}
			}
			else{
				addr.address = str;
			}
			return addr;
		}
		
		
		public static function parseMimeStringList(mimeStrs:String,delim:String = ","):Array{
			var ret:Array = new Array();
			var list:Array = mimeStrs.split(delim);
			for(var i:int=0; i<list.length; i++){
				var str:String = StringUtil.trim(list[i]);
				ret.push(INetAddress.parseMimeString(str));
			}
			return ret;
		}
		
		public function toString():String{
			return this._personal + "<" + this._address + ">";
		}
		
		public function toUTF8():String{
			var ret:String = "";
			if(this._personal){
				ret += this._personal;
			}
			if(this._address){
				if(ret.length > 0){
					ret += "<" + this._address + ">";
				}
				else{
					ret += this._address;
				}
			}
			return ret;
		}
	}
}