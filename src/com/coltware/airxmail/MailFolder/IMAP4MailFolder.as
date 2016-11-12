package com.coltware.airxmail.MailFolder
{
	import com.coltware.airxmail.IMailFolder;
	
	import flash.events.Event;
	
	public class IMAP4MailFolder implements IMailFolder
	{
		public function IMAP4MailFolder()
		{
		}
		
		public function setParameter(key:String, value:Object):void
		{
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return false;
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return false;
		}
		
		public function willTrigger(type:String):Boolean
		{
			return false;
		}
	}
}