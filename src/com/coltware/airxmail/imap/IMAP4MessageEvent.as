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
	import com.coltware.airxmail.IMessageEvent;
	import com.coltware.airxmail.MimeMessage;
	import com.coltware.airxmail_internal;
	
	import flash.utils.ByteArray;
	
	use namespace airxmail_internal;
	
	public class IMAP4MessageEvent extends IMAP4Event implements IMessageEvent
	{
		public static const IMAP4_MESSAGE:String = "imap4Message";
		
		public var octets:int = 0;
		private var _source:ByteArray;
		
		airxmail_internal var $flags:Array;
		
		public function IMAP4MessageEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function getMimeMessage():MimeMessage
		{
			var msg:MimeMessage = _result as MimeMessage;
			return msg;
		}
		
		public function get flags():Array{
			return $flags;
		}
		
		public function get source():ByteArray{
			return _source;
		}
		
		public function set source(src:ByteArray):void{
			this._source = src;
		}
	}
}