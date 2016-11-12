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
	public class CreateCommand extends IMAP4Command
	{
		public function CreateCommand(mailbox:String)
		{
			super();
			this.key 	= "CREATE";
			this.value 	= mailbox;
		}
	}
}