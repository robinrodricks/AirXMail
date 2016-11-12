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
	import com.coltware.airxmail.encode.IEncoder;
	import com.coltware.airxmail_internal;
	
	import flash.utils.*;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.Base64Encoder;

	use namespace airxmail_internal;
	
	/**
	 * MimeMessageにおけるMultipartつまり、複数の子のBodyPartを含めることができるクラスです
	 * 
	 */
	public class MimeMultiPart extends MimeBodyPart{
		
		private static var log:ILogger = Log.getLogger("com.coltware.airxmail.MimeMultiPart");
	
		protected var _partChildren:Array;
		protected var _hasChildren:Boolean = false;
		
		private var _curPart:MimeBodyPart;
		
		
		private var _boundary:String = "";
		private var _boundaryByteLen:int = 0;

		
		public function MimeMultiPart(ctype:ContentType = null) {
			super(ctype);
			_partChildren = new Array();
		}
		
		public function get partChildren():Array{
			return _partChildren;
		}
		
		public function get children():Array{
			return _partChildren;
		}
		public function get numChildren():Number{
			return _partChildren.length;
		}
		public function childrenAt(at:int):MimeBodyPart{
			return _partChildren[at];
		}
		
		/**
		 *  子パートを追加する
		 * 
		 */
		public function addChildPart(part:MimeBodyPart):void{
			part.addEventListener(MailEvent.MAIL_WRITE_FLUSH,fireFlushEvent);
			this._partChildren.push(part);
		}
		
		
		/**
		 *  create child part ( text/plain or text/html part )
		 *
		 */
		public function createTextPart(charset:String = null,transferEnc:String = "7bit"):MimeTextPart{
			var part:MimeTextPart = new MimeTextPart();
			if(charset){
				part.contentType.setParameter("charset",charset);
			}
			part.transferEncoding = transferEnc;
			this.addChildPart(part);
			return part;
		}
		
		airxmail_internal override function writeBodySource(output:IDataOutput):void{
			//  シングルパート
			$bodySource.position = 0;
			log.debug("writeBodySource [single part]" + $bodySource.bytesAvailable);
			
			var encoding:String = $transferEncoding.toLowerCase();
			var enc:IEncoder = AirxMailConfig.getEncoder(encoding);
			
			if(enc){
				enc.encodeBytes($bodySource,output);
			}
			else{
				output.writeBytes($bodySource,0,$bodySource.bytesAvailable);
			}
			/*
			if($transferEncoding == "base64"){
				var enc:Base64Encoder = new Base64Encoder();
				enc.encodeBytes($bodySource,0,$bodySource.bytesAvailable);
				output.writeUTFBytes(enc.toString());
			}
			else{
				output.writeBytes($bodySource,0,$bodySource.bytesAvailable);
			}
			*/
			
			if(this.contentType.isMultipart()){
				//  マルチパートなので、子供のパートを記述していく
				var len:int = this.numChildren;
				for(var i:int=0; i<len; i++){
					//  boundary を記述する
					output.writeUTFBytes("\r\n--");
					output.writeUTFBytes(this.contentType.getParameter("boundary"));
					output.writeUTFBytes("\r\n");
					var part:MimeBodyPart = this.childrenAt(i);
					part.writeHeaderSource(output);
					output.writeUTFBytes("\r\n");
					part.writeBodySource(output);
					output.writeUTFBytes("\r\n");
				}
				output.writeUTFBytes("\r\n--");
				output.writeUTFBytes(this.contentType.getParameter("boundary"));
				output.writeUTFBytes("--");
			}
			
		}
	}
}