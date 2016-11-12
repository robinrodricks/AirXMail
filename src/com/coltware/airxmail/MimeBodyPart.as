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
	import __AS3__.vec.Vector;
	
	import com.coltware.airxmail.encode.IEncoder;
	import com.coltware.airxmail_internal;
	import com.coltware.airxlib.utils.StringLineReader;
	
	import flash.events.EventDispatcher;
	import flash.utils.*;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.*;
	
	use namespace airxmail_internal;
	
	/**
	 *  MimeMessageにおける各パートを管理するクラス
	 */
	public class MimeBodyPart extends EventDispatcher{
		
		private static var log:ILogger = Log.getLogger("com.coltware.airxmail.MimeBodyPart");
		
		protected var _uid:String;
		
		protected var _contentType:ContentType;
		protected var _headers:Vector.<MimeHeader>;
		
		/**
		 *  bodyType がtextのときのみ有効
		 */
		protected var _charset:String = null;
		
		
		public var parentPart:MimeMultiPart;
		
		//  ByteArray で管理されたヘッダ
		protected var _rawHeaders:Object;
		
		protected var _headerKeys:Object = new Object();
		protected var headerSource:String;
		
		//  ログにヘッダ情報をダンプするか
		airxmail_internal var $dumpLogHeaders:Boolean = false;
		
		
		/**
		*  本文データの生データ
		*/
		airxmail_internal var $bodySource:ByteArray;
		//airxmail_internal var $contentType:String;
		airxmail_internal var $transferEncoding:String = "7bit";
		
		public static const BODY_TYPE_TEXT:String 			= "text";
		public static const BODY_TYPE_APPLICATION:String 	= "application";
		public static const BODY_TYPE_AUDIO:String 			= "audio";
		public static const BODY_TYPE_IMAGE:String 			= "image";
		public static const BODY_TYPE_MESSAGE:String 		= "message";
		public static const BODY_TYPE_MULTIPART:String 	    = "multipart";
		public static const BODY_TYPE_VIDEO:String 			= "video";
		
		
		private static const CR:int = 0x0D;
		private static const LF:int = 0x0A;
		private static const TAB:int = 0x09;
		private static const WP:int = 0x20;
		
		private var _isBody:Boolean = false;
		private var _curHeaderKey:String;
				
		public var bodyType:String = BODY_TYPE_TEXT;
		public var bodyFormat:String = "";
		
		/**
		*  コンストラクタ
		*
		*/
		public function MimeBodyPart(ct:ContentType = null) {
			_uid = UIDUtil.createUID();
			this._headers = new Vector.<MimeHeader>();
			parentPart = null;
			$bodySource = new ByteArray();
			log.debug("create part object : [" + _uid + "]"  + this);
			if(ct != null){
				this.contentType = ct;
			}
		}
		
		public function get uid():String{
			return _uid;
		}
		/**
		 *  本文を取得する
		 *  テキストデータの場合、charsetが指定されていれば、自動的に文字コード変換をしてUTF-8にて返します。
		 * 　文字データでない場合には、そのままのデータが返る  　 
		 * 
		 */
		public function get bodyText():String{
			if(_contentType.getMainType() == BODY_TYPE_TEXT){
				var buf:ByteArray = bodyByteArray;
				var charset:String = _contentType.getParameter("charset");
				
				if(!charset){
					charset = AirxMailConfig.DEFAULT_BODY_CHARSET;
				}
						
				if(charset){
					buf.position = 0;
					charset = charset.toLowerCase();
					var body:String =  buf.readMultiByte(buf.bytesAvailable,charset);
					return body;
				}
				else{
					return $bodySource.toString();
				}
			}
			else{
				return $bodySource.toString();
			}
		}
		
		/**
		*
		*  画像や、音楽などbase64エンコードされたデータをByteArray型にして返す。
		 * テキスト情報の場合には、この戻りを利用して文字コード変換などをすることができます。
		*
		*/
		public function get bodyByteArray():ByteArray{
			var header:MimeHeader = this.getHeader("Content-Transfer-Encoding");
			if(header){
				
				var enc:String = header.value;
				enc = enc.toLowerCase();
				if(enc == "base64"){
					var base64dec:Base64Decoder = new Base64Decoder();
					$bodySource.position = 0;
					var _r:StringLineReader = new StringLineReader();
					_r.source = $bodySource;
					var _l:String = null;
					while(_l = _r.next()){
						base64dec.decode(StringUtil.trim(_l));
					}
					
					try{
						return base64dec.toByteArray();
					}
					catch(e:Error){
						log.warn("base64 decode error:" + e.message);
						return base64dec.drain();
					}
				}
				else if(enc == "quoted-printable"){
					var ba:ByteArray = new ByteArray();
					$bodySource.position = 0;
					while($bodySource.bytesAvailable){
						var ch:int = $bodySource.readByte();
						if(ch == 61){
							var ch2:String = $bodySource.readUTFBytes(2);
							if(StringUtil.trim(ch2).length == 2){
								ba.writeByte(parseInt(ch2,16));
							}
							else{
								ba.writeUTFBytes(ch2);
							}
						}
						else{
							ba.writeByte(ch);
						}
					}
					ba.position = 0;
					return ba;
				}
				return $bodySource;
					
			}
			else{
				return $bodySource;
			}
		}
		
		public function set transferEncoding(enc:String):void{
			$transferEncoding = enc;
		}
		
		/**
		 * 本文データをそのままの形で追加する
		 */
		public function addRawContent(bytes:ByteArray):void{
			bytes.position = 0;
			$bodySource.writeBytes(bytes,0,bytes.bytesAvailable);
		}
		
		public function get contentType():ContentType{
			return _contentType;
		}
		
		public function set contentType(ct:ContentType):void{
			this._contentType = ct;
		}
		
		/**
		 *  ヘッダを追加する
		 * 
		 */
		public function addHeader(header:MimeHeader):void{
			var key:String = header.key.toLowerCase();
			this._headerKeys[key] = header;
			this._headers.push(header);
		}
		
		public function addHeaderKeyValue(key:String,value:String):void{
			var header:MimeHeader = new MimeHeader();
			header.key = key;
			header.value = value;
			this.addHeader(header);
		}
		
		/**
		 *  ヘッダを取得する
		 */
		public function getHeader(key:String):MimeHeader{
			key = key.toLowerCase();
			if(this._headerKeys[key]){
				return this._headerKeys[key];
			}
			else{
				return null;
			}
		}
		
		public function getHeaderKyes():Array{
			var list:Array = new Array();
			for(var key:String in this._headerKeys){
				list.push(key);
			}
			return list;
		}
		
		public function hasHeader(key:String):Boolean{
			key = key.toLowerCase();
			if(this._headerKeys[key]){
				return true;
			}
			else{
				return false;
			}
		}
		
		public function getHeaderValue(key:String):String{
			if(this._headerKeys[key]){
				var head:MimeHeader = this._headerKeys[key];
				return head.value;
			}
			else{
				return null;
			}
		}
		
		/**
		 * ヘッダ情報を作成する
		 */
		airxmail_internal function writeHeaderSource(output:IDataOutput):void{
			var line:String;
			var __ct:String = "Content-Type: " + this.contentType.getValue();
			output.writeUTFBytes(__ct + "\r\n");
			
			var cte:String = "Content-Transfer-Encoding";
			if(this.hasHeader(cte)){
				output.writeUTFBytes(this.getHeader(cte).toString());
			}
			else{
				line = cte + ": " + $transferEncoding;
				output.writeUTFBytes(line + "\r\n");
			}
			for(var key:String in _headerKeys){
				var mimeHead:MimeHeader = this.getHeader(key);
				output.writeUTFBytes(mimeHead.toString());
			}
		}
		
		airxmail_internal function writeBodySource(output:IDataOutput):void{
			$bodySource.position = 0;
			
			var encoding:String = $transferEncoding.toLowerCase();
			
			var enc:IEncoder = AirxMailConfig.getEncoder(encoding);
			
			if(enc is EventDispatcher){
				var dispacher:EventDispatcher = enc as EventDispatcher;
				dispacher.addEventListener(MailEvent.MAIL_WRITE_FLUSH,fireFlushEvent);
			}
			
			if(enc){
				enc.encodeBytes($bodySource,output);
			}
			else{
				output.writeBytes($bodySource,0,$bodySource.bytesAvailable);
			}
			this.fireFlushEvent(null);
		}
		
		protected function fireFlushEvent(evt:MailEvent):void{
			var event:MailEvent = new MailEvent(MailEvent.MAIL_WRITE_FLUSH,true,false);
			this.dispatchEvent(event);
		}
	}
}