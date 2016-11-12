/**
 *  Copyright (c)  2009 coltware.com
 *  http://www.coltware.com 
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxmail.pop3.command
{
	import com.coltware.airxlib.job.IBlockable;
	
	import flash.utils.ByteArray;
	
	public class POP3Command implements IBlockable
	{
		public var uid:String;
		public var key:String;
		public var value:Object;
		
		public var result:Object;
		public var source:ByteArray;
		public var data:Object;
		public var status:Boolean = false;
		
		private var _block:Boolean = false;
		
		public function POP3Command()
		{
		}
		
		public function setBlock(val:Boolean):void{
			this._block = val;
		}
		
		public function isBlock():Boolean
		{
			return _block;
		}
	}
}