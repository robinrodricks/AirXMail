package com.coltware.airxmail
{
	import flash.filesystem.File;
	
	public class MimeImagePart extends MimeBinaryPart
	{
		public function MimeImagePart(ct:ContentType = null)
		{
			super(ct);
			this.contentType.setMainType("image");
			this.contentType.setSubType("jpeg");
		}
		
		
		override public function setAttachementFile(file:File,filename:String = null):void{
			super.setAttachementFile(file,filename);
			
			var pos:int = filename.lastIndexOf(".");
			if(pos){
				var ext:String = filename.substring(pos + 1);
				ext = ext.toLowerCase();
				if(ext == "jpg"){
					ext == "jpeg";
				}
				this.contentType.setSubType(ext);
			}
		}
	}
}