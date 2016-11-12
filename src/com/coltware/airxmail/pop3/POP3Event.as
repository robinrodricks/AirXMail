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
	
	import com.coltware.airxmail.MailEvent;
	
	import flash.events.*;
	
	public class POP3Event extends MailEvent {
		
		public static const POP3_CONNECT_OK:String = "pop3ConnectOk";
		public static const POP3_CONNECT_NG:String = "pop3ConnectNg";
		
		public static const POP3_AUTH_OK:String = "pop3AuthOk";
		public static const POP3_AUTH_NG:String = "pop3AuthNg";
		public static const POP3_RESULT_STAT:String = "pop3ResultStat";
		public static const POP3_RESULT_RETR:String = "pop3ResultRetr";
		public static const POP3_RESULT_UIDL:String = "pop3ResultUidl";
		public static const POP3_RESULT_LIST:String = "pop3ResultList";
		public static const POP3_DELETE_OK:String = "pop3DeleteOk";
		public static const POP3_NOOP_OK:String = "pop3NoopOK";
		public static const RESULT_QUIT:String = "QUIT";
		
		public static const POP3_COMMAND_ERROR:String = "pop3CommandError";
		
		public var client:POP3Client;
		protected var _result:Object;
		
		
		public function POP3Event(type:String) {
			super(type);
		}
		
		public function set result(obj:Object):void{
			_result = obj;
		}
	}

}