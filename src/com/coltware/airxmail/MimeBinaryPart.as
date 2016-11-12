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
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.utils.*;
	
	use namespace airxmail_internal;
	
	public class MimeBinaryPart extends MimeBodyPart
	{
		private var _contentDisposition:MimeHeader;
		
		public function MimeBinaryPart(ct:ContentType=null)
		{
			super(ct);
			if(ct == null){
				this.contentType = new ContentType();
				this.contentType.setMainType("application");
				this.contentType.setSubType("octet-stream");
			}
			this.transferEncoding = "base64";
			_contentDisposition = new MimeHeader();
			_contentDisposition.key = "Content-Disposition";
			_contentDisposition.value = "attachment";
			this.addHeader(_contentDisposition);
		}
		
		public function get contentDisposition():MimeHeader{
			return this._contentDisposition;
		}
		
		public function set contentDisposition(header:MimeHeader):void{
			this._contentDisposition = header;
		}
		
		public function setAttachementFile(file:File,filename:String = null):void{
			var fs:FileStream = new FileStream();
			fs.open(file,FileMode.READ);
			$bodySource = new ByteArray();
			fs.readBytes($bodySource,0,fs.bytesAvailable);
			fs.close();
			fs = null;
			
			if(filename != null){
				var header:MimeHeader = new MimeHeader();
				var charset:String = AirxMailConfig.DEFAULT_HEADER_CHARSET;
				if(charset){
					filename = MimeUtils.encodeMimeHeader(filename,charset);
				}
				this.contentType.setParameter("name",filename);
				this.contentDisposition.setParameter("filename",filename);
			}
		}
	}
}