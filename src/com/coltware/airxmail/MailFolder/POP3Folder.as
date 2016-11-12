package com.coltware.airxmail.MailFolder
{
	import com.coltware.airxmail.IMailFolder;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * Developing...
	 * 
	 * @private
	 *
	 */
	public class POP3Folder extends EventDispatcher implements IMailFolder
	{
		public function POP3Folder(target:IEventDispatcher=null)
		{
			super(target);
		}
		/**
		 *  パラメータを設定する
		 * 
		 */
		public function setParameter(key:String,value:Object):void{
			
		}
	}
}