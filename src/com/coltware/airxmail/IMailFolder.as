/**
 *  Copyright (c)  2009 coltware.com
 *  http://www.coltware.com 
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxmail
{
	import flash.events.Event;
	
	public interface IMailFolder
	{
		/**
		 * パラメータを設定する
		 * キーには、各実装Senderに依存する
		 */
		function setParameter(key:String, value:Object):void;
		
		function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void;

		function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void;

		function dispatchEvent(event:Event):Boolean;

		function hasEventListener(type:String):Boolean;

		function willTrigger(type:String):Boolean;
		
	}
}