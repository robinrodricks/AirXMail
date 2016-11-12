package com.coltware.airxmail
{
	import com.coltware.airxmail_internal;
	
	import flash.events.Event;
	
	use namespace airxmail_internal;

	public class MailEvent extends Event
	{
		public static var MAIL_WRITE_FLUSH:String = "mailWriteFlush";
		
		airxmail_internal var $message:String = "";
		
		public function MailEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function get message():String{
			return $message;
		}
		
	}
}