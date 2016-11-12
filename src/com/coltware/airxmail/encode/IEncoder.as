/**
 *  Copyright (c)  2009 coltware.com
 *  http://www.coltware.com 
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxmail.encode
{
	import flash.utils.ByteArray;
	import flash.utils.IDataOutput;

	public interface IEncoder
	{
		function encodeBytes(bytes:ByteArray,output:IDataOutput):void;
		
		function clear():void;
	}
}