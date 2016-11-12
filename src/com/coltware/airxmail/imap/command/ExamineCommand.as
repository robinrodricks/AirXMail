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
	public class ExamineCommand extends SelectCommand
	{
		public function ExamineCommand(folder_StringOrIMAP4Folder:Object=null)
		{
			super(folder_StringOrIMAP4Folder);
			this.key = "EXAMINE";
		}
	}
}