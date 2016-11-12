/**
 *  Copyright (c)  2009 coltware.com
 *  http://www.coltware.com 
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxmail.imap.command
{
	import com.coltware.airxlib.job.IBlockable;
	import com.coltware.airxlib.utils.StringLineReader;
	import com.coltware.airxmail.imap.IMAP4PushEvent;
	import com.coltware.airxmail_internal;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.StringUtil;
	
	use namespace airxmail_internal;

	public class IdleCommand extends IMAP4Command implements IBlockable
	{
		private static const log:ILogger = Log.getLogger("com.coltware.airxmail.imap.command.IdleCommand");
		
		public function IdleCommand()
		{
			super();
			this.key = "IDLE";
		}
		
		public function isBlock():Boolean{
			return true;
		}
		
		override protected function parseResult(reader:StringLineReader):void{
			var line:String;
			while(line = reader.next()){
				line = StringUtil.trim(line);
				if(line.substr(0,1) == "*"){
					var arr:Array = line.split(/\s+/);
					if(arr.length > 2){
						var size:Number = Number(parseInt(arr[1]));
						var name:String = arr[2];
						var evt:IMAP4PushEvent = new IMAP4PushEvent(IMAP4PushEvent.IMAP4_PUSH_RESULT);
						evt.result = size;
						evt.setName(name);
						client.dispatchEvent(evt);
					}
				}
			}
		}
	}
}