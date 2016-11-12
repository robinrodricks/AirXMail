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
	public class IMAP4Flag
	{
		/**  既読 **/
		public static const SEEN:String 			= "\\Seen";
		/**  返信済み **/
		public static const ANSWERED:String 	= "\\Answered";
		/**  何らか注意のフラグ **/
		public static const FLAGGED:String 		= "\\Flagged";
		/** 削除予定 **/
		public static const DELETED:String 		= "\\Deleted";
		public static const DRAFT:String 			= "\\Draft";
		public static const RECENT:String 		= "\\Recent";
		
		public function IMAP4Flag()
		{
		}
	}
}