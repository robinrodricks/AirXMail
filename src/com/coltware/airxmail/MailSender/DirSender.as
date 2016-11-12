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
	import com.coltware.airxmail.IMailSender;
	import com.coltware.airxmail.MimeMessage;
	import com.coltware.airxmail_internal;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.IDataOutput;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	use namespace airxmail_internal;

	public class DirSender extends EventDispatcher implements IMailSender
	{
		private static const log:ILogger = Log.getLogger("com.coltware.airxmail.MailSender.SMTPSender.DirSender");	
		public static const DIR:String = "dir";
		public static const EXT:String = "ext";
		
		private var _dir:File;
		private var _ext:String = "eml";
		
		public function DirSender(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function send(message:MimeMessage, ...rest):void
		{
			log.info("[start] msg send ");
			if(_dir == null){
				_dir = File.userDirectory.resolvePath("airxmail");
				if(!_dir.isDirectory){
					_dir.createDirectory();
				}
			}
			var filename:String = message.uid + "." + _ext;
			var writefile:File = _dir.resolvePath(filename);
			log.info("write file..." + writefile.nativePath);
			var fs:FileStream = new FileStream();
			fs.open(writefile,FileMode.WRITE);
			log.info("file opened");
			message.writeHeaderSource(fs);
			fs.writeUTFBytes("\r\n");
			message.writeBodySource(fs);
			fs.close();
			
			log.info("message sent");
		}
		
		public function setParameter(key:String, value:Object):void
		{
			key = key.toLowerCase();
			switch(key){
				case DIR:
					var filename:String = value as String;
					if(filename){
						var file:File = new File(filename);
						if(file.isDirectory){
							_dir = file;
						}
					}
					break;
				case EXT:
					_ext = value as String;
					break;
			}
		}
		
		public function close():void
		{
			if(_dir != null){
				_dir = null;
			}
		}
		
	}
}