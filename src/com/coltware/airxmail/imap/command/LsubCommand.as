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
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class LsubCommand extends ListCommand
	{
		private static const log:ILogger = Log.getLogger("com.coltware.airxmail.imap.command.LsubCommand");
		
		public function LsubCommand(basename:String,mailbox:String = "*")
		{
			super(basename,mailbox);
			this.key = "LSUB";
		}
		
	}
}