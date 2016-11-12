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
	import mx.utils.Base64Encoder;
	
	/**
	 *  以下のような変換を行う
	 * 
	 *   [&MLcw5zDDMNQw8zCw-]=>[ショッピング]
	 *   [&MNcw6TCkMNkw,DDI-]=>[プライベート]
	 *   [[Gmail]/&kAFP4W4IMH8w4TD8MOs-]=>[[Gmail]/送信済みメール]
	 *   [[Gmail]/&j,dg0TDhMPww6w-]=>[[Gmail]/迷惑メール]
	 * 
	 */
	public class IMAPUTF7Encoder
	{
		private static const log:ILogger = Log.getLogger("com.coltware.airxmail.imap.utils.IMAPUTF7Encoder");
		private static const keymap:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+,";
		
		private static const ST_NORMAL:int = 0;
		private static const ST_ENCODE:int = 1;
		
		
		public function IMAPUTF7Encoder()
		{
		}
		
		private function base64n(num:int):int{
			var n:int  = num & 63;
			return keymap.charCodeAt(n);
		}
		
		public function encode(value:String):String{
			
			var bytes:ByteArray = new ByteArray();
			var enc:ByteArray = new ByteArray();
			
			var work:Array = [0,0,0];
			
			var stat:int = ST_NORMAL;
			var cnt:int = 0;
			
			var length:int = value.length;
			
			var i:int = 0;
			var num:int;
			while(i<length && stat == ST_NORMAL){
				var ch:String = value.charAt(i);
				num = value.charCodeAt(i);
				
				if(stat == ST_NORMAL){
					if(this.isSpecialChar(num)){
						enc.writeUTFBytes("&");
						stat = ST_ENCODE;
						ch = value.substring(i);
						bytes.writeMultiByte(ch,"unicodeFFFE");
					}
					else{
						enc.writeUTFBytes(value.charAt(i));
					}
				}
				i++;
			}
			length = bytes.length;
			
			for(i = 0; i<length; i++){
				num = bytes[i];
				work[cnt] = num;
				cnt++;
				if(cnt == 3){
					this._enc(work,enc);
					work = [0,0,0];
					cnt = 0;
				}
			}
			
			if(cnt != 0){
				this._enc(work,enc);
			}
			if(stat == ST_ENCODE){
				enc.writeUTFBytes("-");
			}
			
			enc.position = 0;

			return enc.readUTFBytes(enc.bytesAvailable);
		}
		
		private function isSpecialChar(num:int):Boolean{
			
			if(num <= 31 || num >= 127){
				return true;
			}
			else{
				return false;
			}
		}
		
		
		private function _enc(_work:Array, bytes:ByteArray):void{
			
			var n:int = -1;
			n = base64n((_work[0] & 0xFF) >> 2);
			bytes.writeByte(n);
			
			n = base64n((_work[0] & 0x03) << 4 | ( (_work[1] & 0xF0) >> 4 ));
			bytes.writeByte(n);
			
			if(_work[1] == 0){
				return;
			}
			n = base64n(((_work[1] & 0x0F)  << 2 ) | (( _work[2] & 0xC0 ) >> 6));
			bytes.writeByte(n);
			
			if(_work[2] == 0){
				return;
			}
			n = base64n(_work[2]  & 0x3F);
			bytes.writeByte(n);
		}
	}
}