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
	import com.coltware.airxmail_internal;
	import com.coltware.airxlib.utils.DateUtils;
	
	import flash.utils.*;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.*;
	
	use namespace airxmail_internal;
	
	/**
	 *   MimeMessageのクラスです。
	 */  
	public class MimeMessage extends MimeMultiPart{
		
		
		private static var log:ILogger = Log.getLogger("com.coltware.airxmail.MimeMessage");
		private var $__debug__:Boolean = AirxMailConfig.DEBUG;
		
		private static var RN:String = "\r\n";
		/**
		 * メッセージID
		 */
		private var _msgId:String = "";
		
		/******************  送信用に使用するヘッダ類 ***********************/
		/**
		 *  実際の配信先リスト
		 */
		airxmail_internal var $toRcpts:Array;
		airxmail_internal var $ccRcpts:Array;
		airxmail_internal var $bccRcpts:Array;
		airxmail_internal var $fromAddress:INetAddress;
		airxmail_internal var $keywords:Array;
		
		airxmail_internal var $date:Date;
		
		airxmail_internal var $attachements:Array;
		/**
		 * デフォルト文字コード
		 */ 
		private var _defaultCharset:String = null;
		
		public function MimeMessage(ctype:ContentType = null,headerCharset:String = null) {
			super(ctype);
			if(headerCharset){
				this._defaultCharset = headerCharset;
			}
			else{
				this._defaultCharset = AirxMailConfig.DEFAULT_HEADER_CHARSET;
			}
			//  送信用
			$toRcpts = new Array();
			$ccRcpts = new Array();
			$bccRcpts = new Array();
			
			$attachements = new Array();
		}
		/*
		* Use AirxMailConfig.setDefaultCharset()
		*
		* public function set headerCharset(v:String):void{
		*	this._defaultCharset = v;
		* }
		*/
		
		public function setStoreId(storeId:String):void{
			this._uid = storeId;
		}
		
		/**
		*  サブジェクトを返す
		*/
		public function get subject():String{
			var head:MimeHeader = this.getHeader("subject");
			var _sub:String = head.value;
			return _sub;
		}
		
		/**
		 *  MIME形式のヘッダをUTF8の文字列オブジェクトで取得する
		 */
		public function getMimeHeaderUTF8(key:String):String{
			var head:MimeHeader = this.getHeader(key);
			if(head){
				var _sub:String = head.value;
				return MimeUtils.decodeMimeHeader(_sub);
			}
			else{
				return "";
			}
		}
		
		public function get subjectUTF8():String{
			var head:MimeHeader = this.getHeader("subject");
			if(head){
				var _sub:String = head.value;
				return MimeUtils.decodeMimeHeader(_sub);
			}
			else{
				return "";
			}
		}
		
		/**
		 *  サブジェクトを設定する
		 *  サブジェクトにデフォルト文字コード以外の文字コードで設定する場合には、setSubjectをご利用ください
		 */
		public function set subject(sub:String):void{
			this.setSubject(sub,this._defaultCharset);
		}
		
		public function setSubject(sub:String,charset:String = null):void{
			var subHeader:MimeHeader = new MimeHeader();
			subHeader.key = "Subject";
			var _charset:String = charset;
			if(_charset == null){
				_charset = _defaultCharset;
			}
			if(_charset){
				var pos:int = 0;
				var _sub:String;
				subHeader.value = "";
				var unit:int = 20;
				for(var i:int = 0; i < sub.length; i++){
					if(i > 0 && i % unit == 0){
						_sub = sub.substr(pos,unit);
						if(subHeader.value.length > 0 ){
							subHeader.value += "\r\n\t";
							subHeader.value += MimeUtils.encodeMimeHeader(_sub,_charset,false);
						}
						else{
							subHeader.value += MimeUtils.encodeMimeHeader(_sub,_charset,false);
						}
						pos = pos + unit;
					}
				}
				if(i % unit != 0){
					_sub = sub.substr(pos);
					if(subHeader.value.length > 0 ){
						subHeader.value += "\r\n\t";
					}
					subHeader.value += MimeUtils.encodeMimeHeader(_sub,_charset,false);
				}
			}
			else{
				subHeader.value = MimeUtils.encodeMimeHeader(sub,_charset,false);
			}
			this.addHeader(subHeader);
		}
		
		
		public function get fromInetAddress():INetAddress{
			return $fromAddress;
		}
		
		public function get fromUTF8():String{
			if($fromAddress == null){
				return "";
			}
			return $fromAddress.toUTF8();
		}
		
		public function setFrom(addr:INetAddress):void{
			$fromAddress = addr;
		}
		
		public function setReplyTo(addr:INetAddress):void{
			var val:String = addr.toMimeString(this._defaultCharset);
			this.addHeaderKeyValue("Reply-to",val);
		}
		/*
		public function get to():String{
			var _val:String = headers['to'];
			return MimeUtils.decodeMimeHeader(_val);
		}
		*/
		public function get toUTF8():String{
			var ret:Array = new Array();
			for each(var addr:INetAddress in $toRcpts){
				ret.push(addr.toUTF8());
			}
			return ret.join(";");
		}
		
		
		/**
		 * 配信先を設定する
		 */
		public function addRcpt(type:String,addr:INetAddress):void{
			if(addr.address){
				//  実際の配信先を設定する
				if(type == RecipientType.TO){
					$toRcpts.push(addr);
				}
				else if(type == RecipientType.CC){
					$ccRcpts.push(addr);
				}
				else if(type == RecipientType.BCC){
					$bccRcpts.push(addr);
				}
			}
		}
		public function setRecps(type:String,addrs:Array):void{
			if(type == RecipientType.TO){
				$toRcpts = addrs;
			}
			else if(type == RecipientType.CC){
				$ccRcpts = addrs;
			}
			else if(type == RecipientType.BCC){
				$bccRcpts = addrs;
			}
		}
		
		public function getRecipients(type:String):Array{
			if(type == RecipientType.TO){
				return $toRcpts;
			}
			else if(type == RecipientType.CC){
				return $ccRcpts;
			}
			else if(type == RecipientType.BCC){
				return $bccRcpts;
			}
			// return empty array
			var ret:Array = new Array();
			return ret;
		}
		
		
		
		
		public function removeRcpt(type:String,addr:INetAddress):void{
			var target:Array;
			if(type == RecipientType.TO){
				target = this.$toRcpts;
			}
			else if(type == RecipientType.CC){
				target = this.$ccRcpts;
			}
			else if(type == RecipientType.BCC){
				target = this.$bccRcpts;
			}
			if(target){
				for(var i:int=0; i<target.length; i++){
					if(addr == target[i]){
						target = target.splice(i,1);
					}
				}
			}
		}
		
		public function setDate(d:Date):void{
			$date = d;
		}
		public function getDate():Date{
			return $date;
		}
		
		public function get date():Date{
			return $date;
		}
		
		public function get messageId():String{
			if(this._msgId){
				return this._msgId;
			}
			var head:MimeHeader = getHeader("message-id");
			if(head == null){
				var tempId:String = this.createMessageId();
				log.info("message id is not found , create temp message id : [" + tempId + "]");
				return tempId;
			}
			var _val:String = head.value;
			if(_val.charAt(0) == "<"){
				this._msgId =  _val.substring(1,_val.length -1);
			}
			else{
				this._msgId =  _val;
			}
			return this._msgId;
		}
		/**
		 * 添付ファイルのみ取得する
		 */
		public function get attachmentChildren():Array{
			return $attachements;
		}
		
		/**
		 * メッセージIDを作成する
		 */
		airxmail_internal function createMessageId():String{
			if(this.$fromAddress){
				var pos:int = this.$fromAddress.address.lastIndexOf("@");
				this._msgId = UIDUtil.createUID() + this.$fromAddress.address.substring(pos);
			}
			else{
				this._msgId = UIDUtil.createUID();
			}
			return this._msgId;
		}
		
		
		public function findParts(type:String):Array{
			var sub:String = null;
			var pos:int = type.indexOf("/");
			if(pos){
				sub = type.substr(pos+1);
				if(sub == "*"){
					sub = null;
				}
				type = type.substr(0,pos);
			}
			var ret:Array = new Array();
			if(this.contentType.isMultipart()){
				var len:int = partChildren.length;
				for(var i:int = 0; i<len; i++){
					var msg:MimeBodyPart = partChildren[i] as MimeBodyPart;
					if(msg.contentType.getMainType() == type){
						if(sub != null){
							if(msg.contentType.getSubStype() == sub ){
								ret.push(msg);
							}
						}
						else{
							ret.push(msg);
						}
					}
				}
			}
			return ret;
		}
		
		override public function get bodyText():String{
			var ct:ContentType = this.contentType;
			log.debug("get bodyType : " + ct.getMainType());
			var _target:MimeBodyPart = null;
			if(ct.getMainType() == BODY_TYPE_MULTIPART){
				var children:Array = partChildren;
				log.debug("get bodyText : " + children.length);
				var max:int = children.length -1;
				//  後ろから見ていく
				for(var i:int=max; i > -1; i--){
					var child:MimeBodyPart = children[i];
					ct = child.contentType;
					if(ct.isText()){
						if(ct.getSubStype() == "plain"){
							return child.bodyText;
						}
						else{
							_target = child;
						}
					}
				}
				if(_target){
					return _target.bodyText;
				}	
			}
			return super.bodyText;
		}
		
		/**
		 *  シングルパートで単純にテキストを設定する場合
		 */
		public function setTextBody(body:String):void{
			$bodySource = new ByteArray();
			var _charset:String;
			
			if($__debug__) log.debug("content-type " + this.contentType.getValue());
			
			if(this.contentType == null){
				this.contentType = this.createDefaultContentType();
			}
			
			_charset = this.contentType.getParameter("charset");
			if(_charset == null || _charset.length < 1 ){
				$bodySource.writeUTFBytes(body);
			}
			else{
				if(_charset.toLowerCase() == "utf-8"){
					this.$transferEncoding = "8bit";
				}
				$bodySource.writeMultiByte(body,_charset.toLowerCase());
			}
			if($__debug__) log.debug("setTextBody " + _charset + "/" + body.length + " " + $bodySource.length);
		}
		
		/**
		 * ヘッダ情報を作成する
		 * 
		 * 実際の送信時などで使用する
		 */
		airxmail_internal override function writeHeaderSource(output:IDataOutput):void{
			headerSource = "";
			var i:int = 0;
			var arr:Array = new Array();
			var line:String = "";
			
			line = "Message-Id: <" + this.createMessageId() + ">";
			output.writeUTFBytes(line + RN);
			
			
			line = "Date:" + DateUtils.dateToString("r");
			output.writeUTFBytes(line +RN);
			
			
			// From を記述する
			line = "From: " + $fromAddress.toMimeString(this._defaultCharset);
			if($__debug__) log.debug("SMTP - " + line);
			output.writeUTFBytes(line + RN);
			// To を記述する
			for(i=0;i<$toRcpts.length; i++){
				arr.push($toRcpts[i].toMimeString(this._defaultCharset));
			}
			line = "To: " + arr.join(",\r\n\t");
			if($__debug__) log.debug("SMTP - " + line);
			output.writeUTFBytes(line + RN);
			
			// CC を記述する
			arr.length = 0;
			if($ccRcpts.length > 0){
				for(i=0; i<$ccRcpts.length; i++){
					arr.push($ccRcpts[i].toMimeString(this._defaultCharset));
				}
				line = "CC: " + arr.join(",");
				output.writeUTFBytes(line + RN);
			}
			for(var key:String in _headerKeys){
				var mimeHead:MimeHeader = this.getHeader(key);
				line = mimeHead.key + ": " + mimeHead.value;
				output.writeUTFBytes(line + RN);
			}
			
			line = "MIME-Version: 1.0";
			output.writeUTFBytes(line + RN);
			
			var __ct:String = "Content-Type: " + this.contentType.getValue();
			output.writeUTFBytes(__ct + RN);
			
			if(this.contentType.isMultipart()){
			}
			else{
				line = "Content-Transfer-Encoding: " + $transferEncoding;
				output.writeUTFBytes(line + RN);
			}
			
		}
		
		public function debugInfo():String{
			var ret:String = "************* INFO **************\n";
			
			ret += "NUM CHILDREN :" + partChildren.length;
			
			for(var i:int = 0; i<partChildren.length; i++){
				ret += "\n ******************** " + i + "***********************\n";
			}
			/*
			ret += " \n=================================================== \n";
			ret += this.bodySource.toString() + "\n";
			ret += " =================================================== \n";
			*/
			return ret;
		}
		
		private function createDefaultContentType():ContentType{
			var ct:ContentType = new ContentType();
			ct.setMainType("text");		
			ct.setSubType("plain");		
			var _charset:String = AirxMailConfig.DEFAULT_BODY_CHARSET;		
			if(_charset){		
				ct.setParameter("charset",_charset);		
			}
			return ct;
		}
	}
}