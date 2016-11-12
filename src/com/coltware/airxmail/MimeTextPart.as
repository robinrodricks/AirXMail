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
	
	import flash.utils.ByteArray;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	use namespace airxmail_internal;
	
	public class MimeTextPart extends MimeBodyPart
	{
		private static var log:ILogger = Log.getLogger("com.coltware.airxmail.MimeTextPart");
		
		public function MimeTextPart(ct:ContentType = null)
		{
			super(ct);
			if(ct == null){
				this.contentType = new ContentType();
				this.contentType.setMainType("text");
				var charset:String = AirxMailConfig.DEFAULT_BODY_CHARSET;
				if(charset){
					this.contentType.setParameter("charset",charset);
				}
			}
		}
		public function get charset():String{
			return this.contentType.getParameter("charset");
		}
		
		public function set charset(str:String):void{
			this.contentType.setParameter("charset",str);
		}
		
		public function setText(body:String):void{
			this.setBodyText(body,"plain");
		}
		
		public function setHtmlText(body:String):void{
			this.setBodyText(body,"html");
		}
		
		/**
		 *  シングルパートで単純にテキストを設定する場合
		 */
		protected function setBodyText(body:String,subtype:String):void{
			$bodySource = new ByteArray();
			log.debug("content-type " + this.contentType.getValue());
			this.contentType.setSubType(subtype);
			var _charset:String = this.contentType.getParameter("charset");
			if(_charset == null || _charset.length < 1 ){
				_charset = AirxMailConfig.DEFAULT_BODY_CHARSET;
			}
			if(charset){
				$bodySource.writeMultiByte(body,_charset.toLowerCase());
			}
			else{
				$bodySource.writeUTFBytes(body);
			}
		}
		
	}
}