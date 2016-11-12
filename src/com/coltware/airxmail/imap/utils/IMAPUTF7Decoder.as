/**
 *  Copyright (c)  2009 coltware.com
 *  http://www.coltware.com 
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxmail.imap.utils
{
	import flash.utils.ByteArray;
	
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class IMAPUTF7Decoder
	{
		private static const log:ILogger = Log.getLogger("com.coltware.airxmail.imap.utils.IMAPUTF7Decoder");
		
		public function IMAPUTF7Decoder()
		{
		}
		
		public function decode(value:String):String{
			var len:int = value.length;
			var plain:Boolean = true;
			var bytes:ByteArray = new ByteArray();
			var work:Array = [-1,-1,-1,-1];
			var cnt:int = 0;
			for(var i:int = 0; i< len; i++){
				var ch:String = value.charAt(i);
				if(ch == "&"){
					plain = false;
				}
				else{
					if(plain){
						bytes.writeMultiByte(ch,"unicodeFFFE");
					}
					else{
						var pos:int = keymap.indexOf(ch);
						if(pos > -1){
							work[cnt] = pos;
							cnt++;
						}
						
						if(cnt == 4){
							cnt = 0;
							this._dec(work,bytes);
							work = [-1,-1,-1,-1];
						}
					}
				}	
			}
			if(cnt != 4 && cnt != 0){
				this._dec(work,bytes);
			}
			bytes.position = 0;
			return bytes.readMultiByte(bytes.bytesAvailable,"unicodeFFFE");
		}
		
		private function _dec(work:Array,bytes:ByteArray):void{
			if(work[1] == -1 ){
				bytes.writeByte((work[0] << 2));
				return;
			}
			else{
				bytes.writeByte((work[0] << 2) | ((work[1] & 0xFF) >> 4));
			}
			
			if(work[2] == -1 ){
				return;
			}
			bytes.writeByte((work[1] << 4) | ((work[2] & 0xFF) >> 2));
			
			if(work[3] == -1){
				return;
			}
			bytes.writeByte((work[2] << 6) | work[3]);
		}
		
		private static const keymap:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+,";
	}
}