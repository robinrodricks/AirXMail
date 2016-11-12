/**
 *  Copyright (c)  2009 coltware.com
 *  http://www.coltware.com 
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxmail.pop3
{
	import com.coltware.airxmail.IMessageEvent;
	import com.coltware.airxmail.MimeMessage;
	
	import flash.utils.ByteArray;
	
	public class POP3MessageEvent extends POP3Event implements IMessageEvent
	{
		public static const POP3_MESSAGE:String = "pop3Message";
		
		public var octets:int = 0;
		private var _source:ByteArray;
		
		public function POP3MessageEvent(type:String)
		{
			super(type);
		}
		
		public function getMimeMessage():MimeMessage{
			var msg:MimeMessage = _result as MimeMessage;
			return msg;
		}
		
		public function get source():ByteArray{
			return this._source;
		}
		
		public function set source(src:ByteArray):void{
			this._source = src;
		}
	}
}