/**
 *  Copyright (c)  2009-2011 coltware.com
 *  http://www.coltware.com 
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxmail.imap.command
{
	import com.coltware.airxlib.utils.StringLineReader;
	import com.coltware.airxmail.MailParser;
	import com.coltware.airxmail.imap.IMAP4MessageEvent;
	import com.coltware.airxmail_internal;
	
	import flash.utils.ByteArray;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.StringUtil;

	use namespace airxmail_internal;
	
	public class MessageCommand extends IMAP4Command
	{
		public static const log:ILogger = Log.getLogger("com.coltware.airxmail.imap.command.MessageCommand");
		
		private var _msgid:String;
		private var _flags:Array;
		
		
		
		public function MessageCommand(msgid:String,useUid:Boolean = true, option:String = "(FLAGS RFC822)")
		{
			super();
			if(useUid){
				this.key = "UID FETCH";
			}
			else{
				this.key = "FETCH";
			}
			_msgid = msgid;
			this.value = _msgid + " " + option;
		}
		
		override protected function parseResult(reader:StringLineReader):void{
			var line:String = reader.next();
			
			if(line.indexOf("FLAGS")){
				// parse flags
				var fpos:int = line.indexOf("FLAGS");
				if(fpos > 0){
					var sp:int = line.indexOf("(",fpos);
					var ep:int = line.indexOf(")",sp);
					var flag_line:String = line.substring(sp + 1,ep);
					if(flag_line){
						flag_line = StringUtil.trim(flag_line);
						_flags = flag_line.split(/\s+/);
						
					}
				}
			}
			if(_flags == null){
				// create empty array
				_flags = new Array();
			}
			
			var pos1:int = line.indexOf("{");
			var pos2:int = line.indexOf("}");
			var sizeStr:String = line.substr(pos1 + 1,pos2-pos1 -1);
			var size:Number = parseInt(sizeStr);
			
			var newReader:StringLineReader = reader.create(size);
			var parser:MailParser = new MailParser();
			parser.parseStart(this._msgid);
			while(line = newReader.next()){
				parser.parseLine(line,newReader);
			}
			var event:IMAP4MessageEvent = new IMAP4MessageEvent(IMAP4MessageEvent.IMAP4_MESSAGE);
			event.$flags = this._flags;
			event.result = parser.parseEnd();
			event.source = newReader.source as ByteArray;
			event.octets = size;
			client.dispatchEvent(event);
			
		}
	}
}