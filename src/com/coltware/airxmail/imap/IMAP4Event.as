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
	import com.coltware.airxmail.MailEvent;
	import com.coltware.airxmail.imap.command.IMAP4Command;
	import com.coltware.airxmail_internal;
	
	use namespace airxmail_internal;
	
	public class IMAP4Event extends MailEvent
	{
		public static const IMAP4_CONNECT_OK:String = "imap4ConnectOk";
		public static const IMAP4_CONNECT_NG:String = "imap4ConnectNg";
		
		public static const IMAP4_COMMAND_BAD:String = "imap4CommandBad";
		public static const IMAP4_COMMAND_NO:String = "imap4CommandNo";
		public static const IMAP4_COMMAND_OK:String = "imap4CommandOk";
		
		public static const IMAP4_AUTH_OK:String = "imap4AuthOk";
		public static const IMAP4_AUTH_NG:String = "imap4AuthNg";
		
		public static const IMAP4_NAMESPACE_FOLDER:String = "imap4NamespaceFolder";
		/**
		 *  LIST command
		 */
		public static const IMAP4_FOLDER_RESULT:String = "imap4FolderResult";
		
		public static const IMAP4_MESSAGE_COPY_OK:String = "imap4MessageCopyOk";
		
		public static const IMAP4_MESSAGE_APPEND_OK:String = "imap4MessageAppendOk";
		
		public var client:IMAP4Client;
		
		protected var _result:Object;
		protected var _command:IMAP4Command;
		
		public function IMAP4Event(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		airxmail_internal function set $command(cmd:IMAP4Command):void{
			this._command = cmd;
		}
		
		public function get command():IMAP4Command{
			return this._command;
		}
		
		public function set result(obj:Object):void{
			_result = obj;
		}
		
		public function get result():Object{
			return _result;
		}
	}
}