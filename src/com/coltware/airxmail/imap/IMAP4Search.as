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
	import com.coltware.airxlib.utils.DateUtils;

	public class IMAP4Search
	{
		public static const ALL:String = "ALL";
		
		/* message flag */
		public static const FLAG_ANSWERED:String 		= "ANSWERED";
		public static const FLAG_UNANSWERED:String 	= "UNANSWERED";
		public static const FLAG_NEW:String					= "NEW";
		public static const FLAG_OLD:String					= "OLD";
		public static const FLAG_RECENT:String     			= "RECENT";
		public static const FLAG_SEEN:String					= "SEEN";
		public static const FLAG_UNSEEN:String				= "UNSEEN";
		
		/* date argument */
		public static const DATE_BEFORE:String 				= "BEFORE";
		public static const DATE_ON:String 		 				= "ON";
		public static const DATE_SINCE:String					= "SINCE";
		public static const DATE_SENT_BEFORE:String 	= "SENTBEFORE";
		public static const DATE_SENT_ON:String			= "SENTON";
		public static const DATE_SENT_SINCE:String 		= "SENTSINCE";
		
		/**
		 *  DATE Format 
		 */
		private static const F_DATE:String = "j-M-Y";
		
		public function IMAP4Search()
		{
		}
		
		public static function and(...args):String{
			return args.join(" ");
		}
		
		public static function dateSentBefore(date:Object):String{
			return DATE_SENT_BEFORE + " " + toDateString(date);
		}
		
		public static function dateSentOn(date:Object):String{
			return DATE_SENT_ON + " " + toDateString(date);
		}
		
		public static function dateSentSince(date:Object):String{
			return DATE_SENT_SINCE + " " + toDateString(date);
		}
		
		public static function dateBefore(date:Object):String{
			return DATE_BEFORE + " " + toDateString(date);
		}
		
		public static function dateOn(date:Object):String{
			return DATE_ON + " " + toDateString(date);
		}
		
		public static function dateSince(date:Object):String{
			return DATE_SINCE + " " + toDateString(date);
		}
		
		private static function toDateString(stringOrDate:Object):String{
			if(stringOrDate is Date){
				return DateUtils.dateToString(F_DATE,stringOrDate);
			}
			else if(stringOrDate is String){
				var str:String = String(stringOrDate);
				var pos:int = str.indexOf("-");
				if(pos > 0){
					return str;
				}
				var num:Number = DateUtils.strToTime(String(stringOrDate));
				if(isNaN(num)){
					throw new Error("Date format exception");
				}
				return DateUtils.dateToString(F_DATE,num);
			}
			throw new Error("Date format exception");
		}
		
	}
}