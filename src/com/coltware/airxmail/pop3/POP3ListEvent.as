package com.coltware.airxmail.pop3
{
	import com.coltware.airxmail.IListEvent;
	
	import flash.events.Event;

	public class POP3ListEvent extends POP3Event implements IListEvent
	{
		
		public static const POP3_RESULT_UIDL:String = "pop3ResultUidl";
		public static const POP3_RESULT_LIST:String = "pop3ResultList";
		
		private var _listArray:Array;
		
		public function POP3ListEvent(type:String)
		{
			super(type);
		}
		
		override public function set result(obj:Object):void{
			super.result = obj;
			_listArray = obj as Array;
		}
		
		public function reverseList():void{
			this._listArray = this._listArray.reverse();
		}
		
		public function get length():int{
			return _listArray.length;
		}
		
		public function getNumber(i:int):int{
			var item:Object = _listArray[i];
			return item.number;
		}
		
		public function getValue(i:int):String{
			var item:Object = _listArray[i];
			return item.value;
		}
		
		
		
	}
}