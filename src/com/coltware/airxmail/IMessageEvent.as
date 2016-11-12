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
	import flash.utils.ByteArray;

	public interface IMessageEvent
	{
		function getMimeMessage():MimeMessage;
		/**
		 *  mail source bytearray
		 */
		function get source():ByteArray;
	}
}