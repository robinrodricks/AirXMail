/**
 *  Copyright (c)  2011 coltware.com
 *  http://www.coltware.com 
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxmail.imap.command
{
	import com.coltware.airxlib.utils.StringLineReader;
	import com.coltware.airxmail.MimeMessage;
	import com.coltware.airxmail.imap.IMAP4Event;
	import com.coltware.airxmail.imap.IMAP4Folder;
	import com.coltware.airxmail_internal;
	
	import flash.utils.ByteArray;
	import flash.utils.IDataOutput;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.StringUtil;
	
	use namespace airxmail_internal;

	public class AppendCommand extends IMAP4Command
	{
		private static const log:ILogger = Log.getLogger("com.coltware.airxmail.imap.command.AppendCommand");
		
		private var _message:MimeMessage;
		private var _bytes:ByteArray;
		
		private var _newUid:String;
		
		public function AppendCommand(message:MimeMessage, mailbox:Object,flags:Array = null)
		{
			super();
			this.key = "APPEND";
			_message = message;
			
			var mailboxStr:String = "";
			if(mailbox is IMAP4Folder){
				mailboxStr = IMAP4Folder(mailbox).name;
			}
			else{
				mailboxStr = mailbox as String;
			}
			this.value = '"' + mailboxStr + '"';
			if(flags){
				this.value += " (";
				this.value += flags.join(" ") + ")";
			}
			this.toBytesMessage();
			this.value += " {" + _bytes.length + "}";
		}
		
		public function get newUid():String{
			return _newUid;
		}
		
		override protected function parseResult(reader:StringLineReader):void{
			var line:String;
			while(line = reader.next()){
				line = StringUtil.trim(line);
				if(line.indexOf("APPENDUID")){
					var reg:RegExp = /[^ ]+\]/i;
					var newUid:String  = reg.exec(line);
					if(newUid){
						_newUid = newUid.substr(0,newUid.length-1);
					}
				}
			}
			
			var event:IMAP4Event = new IMAP4Event(IMAP4Event.IMAP4_MESSAGE_APPEND_OK);
			event.$command = this;
			client.dispatchEvent(event);
			
			
			//  data clear
			_bytes = null;
		}
		
		private function toBytesMessage():void{
			_bytes = new ByteArray();
			this._message.writeHeaderSource(_bytes);
			_bytes.writeUTFBytes("\r\n");
			this._message.writeBodySource(_bytes);
			this._bytes.position = 0;
		}
		
		airxmail_internal function getDataByteArray():ByteArray{
			return this._bytes;
		}
	}
}