/**
 *  Copyright (c)  2009 coltware.com
 *  http://www.coltware.com 
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxmail.imap
{
	import com.coltware.airxmail.imap.utils.IMAPUTF7Decoder;
	import com.coltware.airxmail.imap.utils.IMAPUTF7Encoder;
	import com.coltware.airxmail_internal;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	use namespace airxmail_internal;

	public class IMAP4Folder
	{
		private static const log:ILogger = Log.getLogger("com.coltware.airxmail.imap.IMAP4Folder");
		
		public static const HAS_NO_CHILDREN:String = "\\HasNoChildren";
		public static const HAS_CHILDREN:String		= "\\HasChildren";
		public static const NO_SELECT:String				= "\\Noselect";
		
		private var _name:String;
		private var _nameUTF8:String;
		
		private var _delim:String;
		
		private var _attrs:Array;
		
		airxmail_internal var $numExists:int;
		airxmail_internal var $numRecent:int;
		airxmail_internal var $uidvalidity:String;
		
		public function IMAP4Folder(name:String = "",delim:String = "/" ,attrs:Array = null)
		{
			this._name = name;
			this._delim = delim;
			if(attrs == null){
				attrs = new Array();
			}
			this._attrs = attrs;
		}
		
		public function get delim():String{
			return this._delim;
		}
		
		public function get name():String{
			return _name;
		}
		
		public function set nameUTF8(value:String):void{
			var enc:IMAPUTF7Encoder = new IMAPUTF7Encoder();
			this._name = enc.encode(value);
		}
		
		public function get nameUTF8():String{
			if(_nameUTF8){
				return _nameUTF8;
			}
			var dec:IMAPUTF7Decoder = new IMAPUTF7Decoder();
			_nameUTF8 = dec.decode(this._name);
			return _nameUTF8;
		}
		
		public function get noselect():Boolean{
			if(_attrs.indexOf(NO_SELECT) === -1){
				return false;
			}
			else{
				return true;
			}
		}
		
		/**
		 *   Need select command
		 */
		public function numExists():int{
			return this.$numExists;
		}
		
		
	}
}