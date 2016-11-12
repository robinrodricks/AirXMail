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
	import com.coltware.airxmail.IListEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class IMAP4ListEvent extends IMAP4Event implements IListEvent
	{
		public static const IMAP4_RESULT_UID_LIST:String = "imap4ResultUidList";
		public static const IMAP4_RESULT_LIST:String			= "imap4ResultList";
		
		private var _listArray:Array;
		
		public function IMAP4ListEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function set result(obj:Object):void{
			super.result = obj;
			_listArray = obj as Array;
		}
		
		public function get length():int{
			if(_listArray){
				return _listArray.length;
			}
			else{
				return 0;
			}
		}
		
		public function reverseList():void{
			this._listArray = _listArray.reverse();
		}
		
		public function getValue(i:int):String{
			return String(_listArray[i]);
		}
	}
}