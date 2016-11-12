/**
 *  Copyright (c)  2009 coltware.com
 *  http://www.coltware.com 
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxmail.MailSender
{	
	import com.coltware.airxlib.job.JobEvent;
	import com.coltware.airxmail.IMailSender;
	import com.coltware.airxmail.MailEvent;
	import com.coltware.airxmail.MimeMessage;
	import com.coltware.airxmail.smtp.SMTPClient;
	import com.coltware.airxmail.smtp.SMTPEvent;
	import com.coltware.airxmail_internal;
	
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.IDataOutput;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	use namespace airxmail_internal;
	
	/**
	 *  @eventType flash.events.IOErrorEvent.IO_ERROR
	 */
	[Event(name="ioError",type="flash.events.IOErrorEvent")]
	/**
	 *  @eventType flash.events.SecurityErrorEvent.SECURITY_ERROR
	 */
	[Event (name="securityError",type="flash.events.SecurityErrorEvent")]
	
	/**
	 *  SMTPレベルで接続ができなかったときのイベント.
	 *  Can *NOT* connect SMTP Connection. ( Not TCP Connection )
	 * 
	 * メモ：Socketベースではありません。HELOもしくはEHLOを投げてエラーとなったときに発行されます。
	 * ただし、EHLOでESMTPをサポートしていないエラーはここに含まれません。
	 * 
	 * @eventType com.coltware.airxmail.smtp.SMTPEvent.SMTP_CONNECTION_FAILED
	 */
	[Event(name="smtpConnectionFailed",type="com.coltware.airxmail.smtp.SMTPEvent")]
	
	/**
	 *  SMTP-AUTHで認証が失敗したときのイベント
	 * 
	 *  @eventType com.coltware.airxmail.smtp.SMTPEvent.SMTP_AUTH_NG
	 */
	[Event(name="smtpAuthNg",type="com.coltware.airxmail.smtp.SMTPEvent")]
	
	/**
	 *  SMTP-AUTHで認証が成功したときのイベント
	 * 
	 *  @eventType com.coltware.airxmail.smtp.SMTPEvent.SMTP_AUTH_OK
	 */
	[Event(name="smtpAuthOk",type="com.coltware.airxmail.smtp.SMTPEvent")]
	/**
	 *  @eventType com.coltware.airxmail.smtp.SMTPEvent.SMTP_SENT_OK
	 */
	[Event(name="smtpSentOk",type="com.coltware.airxmail.smtp.SMTPEvent")]
	/**
	 *  @eventType com.coltware.airxmail.smtp.SMTPEvent.SMTP_START_TLS
	 */
	[Event(name="smtpStartTls",type="com.coltware.airxmail.smtp.SMTPEvent")]
	/**
	 *  @eventType com.coltware.airxmail.smtp.SMTPEvent.SMTP_COMMAND_ERROR
	 */
	[Event(name="smtpCommandError",type="com.coltware.airxmail.smtp.SMTPEvent")]
	
	/**
	 *  MimeMessageオブジェクトからSMTPでメールを送信するためのクラス
	 * 
	 */
	public class SMTPSender extends EventDispatcher implements IMailSender
	{
		private static var log:ILogger = Log.getLogger("com.coltware.airxmail.MailSender.SMTPSender");
		
		/**
		 * @see setParameter
		 */
		public static const HOST:String = "host";
		/**
		 *  SMTP Port
		 *  @see setParameter
		 */
		public static const PORT:String = "port";
		public static const AUTH:String = "auth";
		public static const USERNAME:String = "username";
		public static const PASSWORD:String = "password";
		/**
		 *  SMTP via TLS(or SSL)
		 *  @see setParameter
		 */
		public static const SSL:String = "ssl";
		public static const SOCKET_OBJECT:String = "socket";
		public static const MYHOSTNAME:String = "myhostname";
		public static const IDLE_TIMEOUT:String = "idleTimeout";
		
		public static const CONNECTION_TIMEOUT:String = "connectionTimeout";
		
		public static const BUFFER_SIZE:String = "bufferSize";
		public static const ENABLE_BUFFER:String = "enableBuffer";
		
		public static const AUTO_STARTTLS:String = "autoStartTLS";
		
		
		private var client:SMTPClient;
		private var currentMessage:MimeMessage;
		
		private var TLS_CLASSNAME:String ="com.hurlant.crypto.tls.TLSSocket";
		
		private var _smtpAuth:Boolean = false;
		private var _userName:String = null;
		private var _userPswd:String = null;
		private var _timout:int = 5000;
		
		private var _internalFlush:Boolean = false;
		
		/**
		 * 出力時にバッファーを使うか
		 */
		private var _useBuffer:Boolean = true;
		private var _bufferOutput:ByteArray;
		private var _timer:Timer;
		private var _bufferSize:uint = 16384;
		
		private var _keep_conn:Boolean = false;
		
		/**
		 * HELOするときのホスト名
		 */
		private var _myhost:String = "localhost";
		
		public function SMTPSender() 
		{
			client = new SMTPClient();
			client.addEventListener(SMTPEvent.SMTP_ACCEPT_DATA,writeData);
			//client.addEventListener(SMTPEvent.SMTP_CONNECTION_FAILED,fireConnectionFailed);
			client.addEventListener(JobEvent.JOB_IDLE_TIMEOUT,handlerIdleTimeout);
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void{
			client.addEventListener(type,listener,useCapture,priority,useWeakReference);
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void{
			client.removeEventListener(type,listener,useCapture);
		}
		
		override public function hasEventListener(type:String):Boolean{
			return client.hasEventListener(type);
		}
		
		/**
		 *  Senderに依存したパラメータの値を指定する.
		 * 
		 * <pre>
		 * host 		:  接続するSMTPのホスト名 or IP
		 * port 		:  接続するSMTPのポート番号
		 * myhostname	:  SMTPで接続する際にHELO(EHLO) myhostname となる部分。デフォルトはlocalhost
		 * </pre>
		 */
		public function setParameter(key:String,value:Object):void{
			
			var vstr:String;
			var vbool:Boolean;
			var vnum:Number;
			
			switch(key){
				case HOST:
					client.host = String(value); 
					break;
				case PORT:
					if(value is String){
						client.port = parseInt(String(value));
					}
					else{
						vnum = value as Number;
						if(vnum){
							client.port = vnum;
						}
					}
					
					break;
				case AUTH:
					vstr = value as String;
					vbool = value as Boolean;
					if(vbool || ( vstr && vstr.toLowerCase() == "true")){
						this._smtpAuth = true;
					}
					break;
				case USERNAME:
					vstr = value as String;
					if(vstr){
						this._userName = vstr;
					}
					break;
				case PASSWORD:
					vstr = value as String;
					if(vstr){
						this._userPswd = vstr;
					}
					break;
				case SSL:
					vstr = value as String;
					vbool = value as Boolean;
					if(vbool || ( vstr && vstr.toLowerCase() == "true")){
						var tlsClz:Class = getDefinitionByName(TLS_CLASSNAME) as Class;
						var tlsObj:Object = new tlsClz();
						client.socketObject = obj;
					}
					break;
				case AUTO_STARTTLS:
					vstr = value as String;
					vbool = value as Boolean;
					if(vbool || ( vstr && vstr.toLowerCase() == "true")){
						client.autoSTARTTLS = true;
					}
					else{
						client.autoSTARTTLS = false;
					}
					break;
				case SOCKET_OBJECT:
					if(value is String){
						var clz:Class = getDefinitionByName(String(value)) as Class;
						var obj:Object = new clz();
						client.socketObject = obj;
					}
					else{
						log.info("set socket object " + value);
						client.socketObject = value;
					}
					break;
				case MYHOSTNAME:
					this._myhost = String(value);
					break;
				case IDLE_TIMEOUT:
					vnum = value as Number;
					if(vnum){
						client.setIdleTimeout(vnum);
					}
					break;
				case CONNECTION_TIMEOUT:
					vnum = value as Number;
					if(vnum){
						client.connectionTimeout = vnum;
					}
					else{
						log.debug("vnum is not number : " + vnum);
					}
					break;
				case BUFFER_SIZE:
					vnum = value as Number;
					if(vnum){
						this._bufferSize = vnum;
					}
					break;
				case ENABLE_BUFFER:
					vstr = value as String;
					vbool = value as Boolean;
					if(vbool || ( vstr && vstr.toLowerCase() == "true")){
						this._useBuffer = true;
					}
					else{
						this._useBuffer = false;
					}
					break;
			}
		}
		/**
		 * send mail
		 * 
		 * 大量に送信することは想定されておらず、１回１回、接続をする
		 * 
		 */ 
		public function send(message:MimeMessage, ... args):void{
			log.info("[start] msg send"); 
			
			this.currentMessage = message;
			if(!client.isConnected){
				if(this._keep_conn == false){
					log.debug("connect ... ");
					client.connect();
					client.ehlo(this._myhost);
				
					if(_smtpAuth){
						client.setAuth(_userName,_userPswd);
					}
				}
				this._keep_conn = true;
			}
			var i:int;
			
			//  MAIL FROM:
			var envelopFrom:String = message.fromInetAddress.address;
			if(args[0] && args[0] is String){
				envelopFrom = args[0];
			}
			client.mailFrom(envelopFrom);
			
			var len:int = 0;
			//  TOを設定する
			var rcpts:Array = message.$toRcpts.concat(message.$ccRcpts,message.$bccRcpts);
			len = rcpts.length;
			for(i=0; i<len; i++){
				client.rcptTo(rcpts[i].address);
			}
			//client.data(this.writeDataStr());
			client.dataAsync();
		}
		
		
		public function close():void{
			log.info("close()..");
			this._keep_conn = false;
			client.quit();
		}
		
		/**
		 *   write data
		 */
		private function writeData(e:SMTPEvent):void{
			_internalFlush = true;
			var start:Date = new Date();
			log.debug("writeData start");
			
			
			var sock:Object = e.$sock;
			this.currentMessage.writeHeaderSource(IDataOutput(sock));
			sock.writeUTFBytes("\r\n");
			sock.flush();
			
			if(this._useBuffer){
				log.debug("enable buffer size:" + this._bufferSize);
				_bufferOutput = new ByteArray();
				this.currentMessage.writeBodySource(IDataOutput(_bufferOutput));
				internalWriteLoop();
			}
			else{
				log.debug("not use buffer");
				this.currentMessage.addEventListener(MailEvent.MAIL_WRITE_FLUSH,internalClientFlush);
				this.currentMessage.writeBodySource(IDataOutput(sock));
				sock.writeUTFBytes("\r\n.\r\n");
				this.currentMessage.removeEventListener(MailEvent.MAIL_WRITE_FLUSH,internalClientFlush);
				sock.flush();
			}
			
			var end:Date = new Date();
			var cost:Number = end.time - start.time;
			
			_internalFlush = false;
			
			log.debug("writeData end : " + cost + "msec");
			
		}
		
		private function writeDataStr():String{
			var bytes:ByteArray = new ByteArray();
			this.currentMessage.writeHeaderSource(bytes);
			bytes.writeUTFBytes("\r\n");
			this.currentMessage.writeBodySource(bytes);
			bytes.position = 0;
			return bytes.readUTFBytes(bytes.bytesAvailable);
		}
		
		private function internalWriteLoop():void{
			log.debug("client flush... loop start");
			this._bufferOutput.position = 0;
			if(_timer == null){
				_timer = new Timer(20,0);
				_timer.addEventListener(TimerEvent.TIMER,internalWrite);
			}
			_timer.start();
		}
		
		private function internalClientFlush(evt:MailEvent):void{
			client.flush();
		}
		
		private function internalWrite(evt:TimerEvent):void{
			var data:String;
			var unit:uint = this._bufferSize;
			var start:Date = new Date();
			var writeSize:int = 0;
			if(_bufferOutput.bytesAvailable > unit){
				writeSize = unit;
				data = _bufferOutput.readUTFBytes(unit);
				client.writeDate(data);
			}
			else{
				writeSize = this._bufferOutput.bytesAvailable;
				data = _bufferOutput.readUTFBytes(this._bufferOutput.bytesAvailable);
				_timer.stop();
				client.writeDate(data);
				client.writeDate("\r\n.\r\n");
				log.debug("write last data. waitting... 250 status ");
			}
			var end:Date = new Date();
			var cost:Number = end.time - start.time;
			log.debug("write data size: [" + writeSize + "] / cost [" + cost + "]msec");
		}
		
		/**
		 * @private
		 */
		protected function fireConnectionFailed(e:* = null):void{
			//  サービスの準備ができないまま、サーバからの切断なので
			var event:SMTPEvent = new SMTPEvent(SMTPEvent.SMTP_CONNECTION_FAILED,true);
			this.dispatchEvent(event);
		}
		
		/**
		 * @private
		 */
		private function handlerIdleTimeout(e:JobEvent):void{
			if(client.isConnected){
				client.quit();
			}
		}
	}
}