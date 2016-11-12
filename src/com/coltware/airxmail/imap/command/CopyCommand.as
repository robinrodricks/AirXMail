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
	import com.coltware.airxmail.imap.IMAP4Event;
	import com.coltware.airxmail.imap.IMAP4Folder;
	import com.coltware.airxmail_internal;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	use namespace airxmail_internal;

	public class CopyCommand extends IMAP4Command
	{
		private static const log:ILogger = Log.getLogger("com.coltware.airxmail.imap.command.CopyCommand");
		
		private var checkkw:String = "COPYUID";
		
		private var _fromUid:String = "";
		private var _newUid:String = "";
		private var _useUid:Boolean = true;
		
		public function CopyCommand(msgId:String,mailbox:Object,useUid:Boolean = true)
		{
			super();
			
			if(useUid){
				this.key = "UID COPY";
			}
			else{
				this.key = "COPY";
				this._useUid = false;
			}
			
			var mailBoxStr:String = "";
			if(mailbox is IMAP4Folder){
				var folder:IMAP4Folder = mailbox as IMAP4Folder;
				mailBoxStr = folder.name;
			}
			else{
				mailBoxStr = String(mailbox);
			}
			this._fromUid = msgId;
			this.value = msgId + ' "' + mailBoxStr + '"'; 
		}
		
		public function get fromUid():String{
			return this._fromUid;
		}
		
		public function get newUid():String{
			return _newUid;
		}
		/**
		 * 
		 *  ex )   [COPYUID 623752185 255 2] (Success)]
		 *           [COPYUID 38505 304,319:320 3956:3958] Done    <--  Doesn't  support because of message id is rang ( 319:320 ) 
		 *         
		 */
		override protected function parseResult(reader:StringLineReader):void{
			if(this._useUid){
				var line:String = reader.next();
				var newUidRegexp:RegExp =/[^ ]+\]/i;
				if(line.indexOf(this.checkkw)){
					var newUid:String  = newUidRegexp.exec(line);
					if(newUid){
						_newUid = newUid.substr(0,newUid.length-1);
					}
				}
			}
			var event:IMAP4Event = new IMAP4Event(IMAP4Event.IMAP4_MESSAGE_COPY_OK);
			event.$command = this;
			client.dispatchEvent(event);
		}
	}
}