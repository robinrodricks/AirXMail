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
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.StringUtil;

	public class ExpungeCommand extends IMAP4Command
	{
		private static const log:ILogger = Log.getLogger("com.coltware.airxmail.imap.command.ExpungeCommand");
		
		public function ExpungeCommand()
		{
			super();
			this.key = "EXPUNGE";
		}
		
		override protected function parseResult(reader:StringLineReader):void{
			var line:String;
			while(line = reader.next()){
				line = StringUtil.trim(line);
				log.debug(line);
			}
		}
	}
}