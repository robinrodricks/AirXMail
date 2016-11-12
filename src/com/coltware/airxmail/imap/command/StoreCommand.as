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
	public class StoreCommand extends IMAP4Command
	{
		public static const ADD:String 		= "+";
		public static const REMOVE:String 	= "-";
		public static const CHANGE:String 	= "";
		
		public function StoreCommand(mode:String,msgid:String,flags:Array,useUid:Boolean = true)
		{
			super();
			if(useUid){
				this.key = "UID STORE";
			}
			else{
				this.key = "STORE";
			}
			this.init_value(mode,msgid,flags);
		}
		
		private function init_value(mode:String,msgid:String,flags:Array):void{
			this.value 	  = msgid + " " + mode + "FLAGS (";
			this.value += flags.join(" ");
			this.value += ")";
		}
	}
}