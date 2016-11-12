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
	import com.coltware.airxlib.utils.DateUtils;
	import com.coltware.airxlib.utils.StringLineReader;
	import com.coltware.airxmail_internal;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.IDataInput;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.StringUtil;
	
	use namespace airxmail_internal;
	
	/**
	 *  パースしてMimeMessageオブジェクトを構築する
	 * 
	 */
	public class MailParser extends EventDispatcher
	{
		private var $__debug__:Boolean = AirxMailConfig.DEBUG;
		
		private static const CR:int 	= 0x0D;
		private static const LF:int 	= 0x0A;
		
		private static var _rootMessage:MimeMessage;
		
		private var _isBody:Boolean = false;
		private var _isMulti:Boolean = false;
		
		private var _curMimeMessage:MimeBodyPart;
		private var _curContentType:ContentType;
		private var _curPartMessage:MimeBodyPart;
		private var _boundary:String;
		private var _headers:Array;
		
		private var _bodyPartClass:Class;
		
		private var _parentPart:MimeMultiPart;
		private var _childParser:MailParser;
		
		
		
		private var _childStart:Boolean = false;
		
		private var _uid:String;
				
		private static var log:ILogger = Log.getLogger("com.coltware.airxmail.MailParser");
		
		//  Debug時にログを出力する
		airxmail_internal var $_debug:Boolean = false;
		airxmail_internal var $_parentParser:MailParser;
		
		public function MailParser(target:IEventDispatcher=null)
		{
			super(target);
			_headers = new Array();
		}
		
		/**
		 *  parse from stream like FileStream ... etc...
		 */
		public function parseStream(stream:IDataInput, messageId:String = null):MimeMessage{
			var _reader:StringLineReader = new StringLineReader();
			_reader.source = stream;
			
			var line:String;
			this.parseStart(messageId);
			while(line = _reader.next()){
				var _tmp:String = StringUtil.trim(line);
				if(_tmp != "."){
					this.parseLine(line,_reader);
				}
			}
			var msg:MimeMessage = this.parseEnd() as MimeMessage;
			return msg;
		}
		
		/**
		 * パースを処理するときに始めるときの初期化処理
		 * 
		 */
		public function parseStart(uid:String,parent:MimeMultiPart = null):void{
			if($_debug) log.debug("parser start :" + uid);
			
			//  初期化
			_isBody = false;
			_isMulti = false;
						
			_curMimeMessage = null;
			_curContentType = null;
			_curPartMessage = null;
			_headers.length = 0;
			_parentPart = parent;
			
			if(uid){
				this._uid = uid;
			}
		}
		
		/**
		 *  1行ごとに読み込んだものをパースする
		 * 
		 */
		public function parseLine(line:String,reader:StringLineReader):Boolean{
			
			if(_isBody){
				
				if(_curContentType.isMultipart()){
					//  マルチパートの場合
					this.parseMultipartBody(line,reader);
				}
				else{
					//  シングルパートの場合
					//log.debug("this is single part");
					_curMimeMessage.addRawContent(reader.lastBytearray());
				}
			}
			else{
				var trimLine:String = StringUtil.trim(line);
				
				//  何も行がないとき：つまりヘッダの終了のとき
				if(trimLine.length == 0 ){
					_isBody = true;
					//  ヘッダをパースする
					this.parseHeaderEnd();
				}
				else{
					//  通常のヘッダ部分
					var fc:String = trimLine.substr(0,1);
					if(line.indexOf(fc) == 0 ){
						//  １行目
						_headers.push(trimLine);
					}
					else{
						//  2行目以降
						var cl:int = _headers.length - 1;
						_headers[cl] += trimLine;
					}
				}
			}
			return true;
		}
		
		/**
		 *  パースが終わったときにMimeMessageを取得する
		 * 
		 */
		public function parseEnd():MimeBodyPart{
			var mimeMsg:MimeBodyPart = this._curMimeMessage;
			return mimeMsg;
		}
		
		private function parseMultipartBody(line:String,reader:StringLineReader):void{
			var lr:String = StringUtil.trim(line);
			var multiPart:MimeMultiPart;
			var part:MimeBodyPart;
			if(lr == _boundary){
				if($_debug) log.debug("boundary match " + lr);
				//
				multiPart = _curMimeMessage as MimeMultiPart;
				if(_childStart){
					//  すでにはじまっているという事は、次に子が始まった
					part = _childParser.parseEnd();
					multiPart.addChildPart(part);
					
					if($_debug) log.debug("add child :" + multiPart.numChildren + " - " + multiPart.uid + "<-- " + part.uid);
					
					_childParser.parseStart(null,multiPart);
				}
				else{
					_childParser = new MailParser();
					_childParser.parseStart(null,multiPart);
					_childStart = true;
					_childParser.$_parentParser = this;
				}
			}
			else if(lr == _boundary + "--"){
				//  コンテンツの終了
				if($_debug) log.debug("boundary match end " + lr);
				
				multiPart = _curMimeMessage as MimeMultiPart;
				part = _childParser.parseEnd();
				if($_debug) log.debug("add child :" + multiPart.numChildren + " - " + multiPart.uid + "<-- " + part.uid);
				multiPart.addChildPart(part);
				_childStart = false;
			}
			else{
				if(_childStart){
					_childParser.parseLine(line,reader);
				}
				else{
					_curMimeMessage.addRawContent(reader.lastBytearray());
				}
			}
		}
		
		private function parseHeaderEnd():void{
			var len:int = _headers.length;
					
			var i:int = 0;
			var _line:String;
			var _cp:int;
			var _key:String;
			var _val:String;
					
			//  まず自分を格納するオブジェクトを作るためにContent-Typeを調べる
			if(_parentPart == null){
				var msg:MimeMessage = new MimeMessage();
				_rootMessage = msg;
				msg.setStoreId(this._uid);
				_curMimeMessage = msg;
				
				//log.debug("check1 " + _curMimeMessage);
			}
			else{
				for(i = 0; i<len; i++){
					
					_line = _headers[i];
					_cp  = _line.indexOf(":");
					_key = _line.substr(0,_cp);
					_key = _key.toLowerCase();
					_val = _line.substr(_cp + 1);
					//log.debug("header parse ...[" + _key + "]" + _val);
					if(_key == "content-type"){
						var ct:ContentType = ContentType.parseValue(_val);
						if(ct.isMultipart()){
							//log.debug("curB is MimeMultPart");
							var part:MimeMultiPart = new MimeMultiPart(ct);
							part.contentType = ct;
							//_parentPart.addChildPart(part);
							_curMimeMessage = part;
							_curContentType = ct;
						}
						else{
							var spart:MimeBodyPart;
							if(ct.getMainType() == MimeBodyPart.BODY_TYPE_TEXT){
								spart = new MimeTextPart();
							}
							else if(ct.getMainType() == MimeBodyPart.BODY_TYPE_IMAGE){
								spart = new MimeImagePart(ct);
							}
							else{
							 	spart = new MimeBodyPart(ct);
							}
							spart.contentType = ct;
							//_parentPart.addChildPart(spart);
							_curMimeMessage = spart;
							_curContentType = ct;
						}
						break;
					}
				}
			}
					
			var mimeHeader:MimeHeader;
			
			for(i=0; i<len; i++){
				_line = _headers[i];
				_cp  = _line.indexOf(":");
				_key = _line.substr(0,_cp);
				_key = _key.toLowerCase();
				_key = StringUtil.trim(_key);
				_val = _line.substring(_cp+1);
				if(_key == "content-type"){
					if($_debug) log.debug("content type value is " + _val);
					_curMimeMessage.contentType = ContentType.parseValue(_val);
					_curMimeMessage.contentType.dumpLog();
					_curContentType = _curMimeMessage.contentType;
				}
				else{
					if(_curMimeMessage is MimeMessage){
						var mimeMsg:MimeMessage = _curMimeMessage as MimeMessage;	
						if(_key == "to"){
							mimeMsg.setRecps(RecipientType.TO,INetAddress.parseMimeStringList(_val));
						}
						else if(_key == "cc"){
							mimeMsg.setRecps(RecipientType.CC,INetAddress.parseMimeStringList(_val));
						}
						else if(_key == "from"){
							var fromAddr:INetAddress = INetAddress.parseMimeString(_val);
							mimeMsg.setFrom(fromAddr);
						}
						else if(_key == "date"){
							mimeMsg.setDate(new Date(DateUtils.strToTime(_val,"r")));
						}
						
						mimeHeader = new MimeHeader();
						mimeHeader.key = _key;
						mimeHeader.parse(_val);
						mimeMsg.addHeader(mimeHeader);
						
					}
					else{
						mimeHeader = new MimeHeader();
						mimeHeader.key = _key;
						mimeHeader.parse(_val);
						_curMimeMessage.addHeader(mimeHeader);
					}
				}
				
				//  たまにContentTypeがないものもあるので
				if(_curMimeMessage.contentType == null){
					_curMimeMessage.contentType = ContentType.parseValue("text/plain");
					_curContentType = _curMimeMessage.contentType;
				}
				
				//  ContentType が multipartの場合には・・・・
				if(_curMimeMessage.contentType.isMultipart()){
					_curPartMessage = _curMimeMessage;
					_boundary = "--" + _curPartMessage.contentType.getParameter("boundary");
				}
			} //  End of for
			
			// attachment files process
			var contentDisposition:MimeHeader = _curMimeMessage.getHeader("Content-Disposition");
			
			if(contentDisposition){
				if(_curMimeMessage is MimeBinaryPart){
					MimeBinaryPart(_curMimeMessage).contentDisposition = contentDisposition;
				}
				
				if(contentDisposition.value == "attachment"){
					if(_rootMessage){
						_rootMessage.$attachements.push(_curMimeMessage);
					}
					else{
						// maybe bug ?
						log.warn("Root message container (MimeMessage) is NULL !?"); 
					}
				}
			}
		}
	}
}