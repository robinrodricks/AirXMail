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
	import com.coltware.airxmail_internal;

	/**
	 *  IDLEコマンドを実行したときに、その結果イベントクラス
	 * 
	 */
	public class IMAP4PushEvent extends IMAP4Event
	{
		public static const IMAP4_PUSH_RESULT:String = "imap4PushResult";
		
		private var _name:String;
		private var _value:Number;
		
		public function IMAP4PushEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function set result(obj:Object):void{
			super.result = obj;
			_value = obj as Number;
		}
		
		airxmail_internal function setName(name:String):void{
			this._name = name;
		}
		
		public function getName():String{
			return _name;
		}
		public function getSize():Number{
			return _value;
		}
	}
}