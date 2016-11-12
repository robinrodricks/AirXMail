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
	import flash.utils.*;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	
	public class MimeUtils {
		
		private static const log:ILogger = Log.getLogger("com.coltware.airxmail.MimeUtils");
		
		/**
		 * Decode MIME Header (=?[charset]?[encode]?[data]?=).
		 * 
		 */
		static public function decodeMimeHeader(input:String):String{
			
			if(input == null){
				return "";
			}
			
			var ret:String = "";
			
			var size:int = input.length;
			var pch:String = "";
			var ch:String = "";
			var val:String = "";
			var encStr:String = "";
			var inEnc:Boolean = false;
			for(var i:int = 0; i<size; i++){
				pch = ch;
				ch 	= input.charAt(i);
				
				if(inEnc){
					//  エンコード対象内の場合
					if(ch == "=" && pch == "?"){
						inEnc = false;
						var target:String = encStr.substr(1);
						var targets:Array = target.split("?");
						if(targets.length == 3){
							var title:String = targets[2];
							var charset:String = targets[0].toLowerCase();
							var tranType:String = targets[1].toLowerCase();
							if(tranType == "b"){
								var decorder:Base64Decoder  = new Base64Decoder();
								decorder.decode(title);
								var bytes:ByteArray = decorder.toByteArray();
								bytes.position = 0;
								ret += bytes.readMultiByte(bytes.bytesAvailable,charset);
							}
							else if(tranType == "q"){
								ret += decode_q(title,charset);
							}
						}
						else{
							ret += target;
						}
						
						encStr = "";
					}
					else{
						encStr += pch;
					}
				}
				else{
					if(ch == "?" && pch == "="){
						inEnc = true;
						val = val.substring(0,val.length -1);
						ret += val;
						val = "";
					}
					else{
						
						val += ch;
						
					}
				}			
			}
			if(val.length > 0){
				ret += val;
			}
			return ret;
		}
	
		/**
	 	 * 指定された文字列をMIME形式でエンコードする.
	 	 * 
	 	 * B形式のみ対応
	 	 * 
	 	 * 
	 	 */ 
		public static function encodeMimeHeader(input:String,charset:String,insertNewLines:Boolean = true):String{
			var ret:String = "";
			var bytes:ByteArray = new ByteArray();
			if(charset){
				var start:String = "=?" + charset +"?B?";
				bytes.writeMultiByte(input,charset.toLowerCase());
				var encoder:Base64Encoder = new Base64Encoder();
				encoder.insertNewLines = insertNewLines;
				encoder.encodeBytes(bytes);
				ret = encoder.toString();
				var end:String = "?=";
				
				if(insertNewLines == true){
					var p:Array = ret.split(String.fromCharCode(Base64Encoder.newLine));
					var join:Array = new Array();
					var i:int = 0;
					for(i = 0; i<p.length; i++){
						if(i==0){
							join.push(start + p[i] + end);
						}
						else{
							join.push("\t" + start + p[i] + end);
						}
					}
					ret = join.join("\r\n");
				}
				else{
					ret = start + ret + end;	
				}
			}
			else{
				ret += input;
			}
			return ret;
		}
		
		public static function decode_q(text:String,charset:String):String{
			var ret:ByteArray = new ByteArray();
			var len:int = text.length;
			var ch:String;
			var i:int = 0;
			while(i < len){
				ch = text.charAt(i);
				if(ch == "="){
					var numStr:String = text.substr(i+1,2);
					var num:Number = parseInt(numStr,16);
					ret.writeByte(num);
					i+=3;
				}
				else if( ch == "_"){
					ret.writeUTFBytes(" ");
					i++;
				}
				else{
					ret.writeUTFBytes(ch);
					i++;
				}
			}
			ret.position = 0;
			return ret.readMultiByte(ret.bytesAvailable,charset);
		}
	}
}