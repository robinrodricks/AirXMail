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
	public class RenameCommand extends IMAP4Command
	{
		public function RenameCommand(oldmailbox:String,newmailbox:String)
		{
			super();
			this.key = "RENAME";
			this.value = oldmailbox + " " + newmailbox;
		}
	}
}