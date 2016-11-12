/**
 *  Copyright (c)  2009 coltware@gmail.com
 *  http://www.coltware.com 
 *  
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 * 
 */
package com.coltware.airxmail
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	public class TextSocketReaderEvent extends Event
	{
		public static const TEXT_SOCKET_LINE:String = "textSocketLine";
		public var lineBytes:ByteArray;
		
		public function TextSocketReaderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}