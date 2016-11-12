/**
 *  Copyright (c)  2009 coltware.com
 *  http://www.coltware.com 
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxmail.smtp
{
	import com.coltware.airxmail.MailEvent;
	import com.coltware.airxmail_internal;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	use namespace airxmail_internal;

	/**
	 *  SMTPClientで発生するイベントクラス
	 * 
	 * @see com.coltware.airxmail.smtp.SMTPClient
	 */
	public class SMTPEvent extends MailEvent
	{
		private static var log:ILogger = Log.getLogger("com.coltware.airxmail.smtp.SMTPEvent");
		
		/**
		 * DATAコマンドによってデータを受信できる状態になったとき
		 */
		public static var SMTP_ACCEPT_DATA:String = "smtpAcceptData";
		/**
		 * 接続エラーとなったとき
		 */
		public static var SMTP_CONNECTION_FAILED:String = "smtpConnectionFailed";
		
		/**
		 *  ESMTPの接続が失敗したとき
		 */
		public static var SMTP_NOT_SUPPORT_ESMTP:String = "smtpNotSupportEsmtp";
		
		public static var SMTP_AUTH_NG:String = "smtpAuthNg";
		public static var SMTP_AUTH_OK:String = "smtpAuthOk";
		
		public static var SMTP_SENT_OK:String = "smtpSentOk";
		
		/**
		 *  NOOPコマンドがきちんと返ってきたとき
		 * 
		 */
		public static var SMTP_NOOP_OK:String = "smtpNoopOk";
		
		public static var SMTP_START_TLS:String = "smtpStartTls";
		
		/**
		 * コマンドの結果エラーが帰ってきたとき
		 */
		public static var SMTP_COMMAND_ERROR:String = "smtpCommandError";
		
		
		airxmail_internal var $sock:Object;
		
		public function SMTPEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function get socket():Object{
			return $sock;
		}
		
		/**
		 *  acceptDataのイベントのときに使えます。
		 * 
		 *  Object型となっていますが、これは、TLSSocketに対する対応のためです。
		 */
		public function getSocket():Object{
			return $sock;
		}
		
	}
}