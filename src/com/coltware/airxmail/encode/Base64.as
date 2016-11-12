package com.coltware.airxmail.encode
{
	import com.coltware.airxmail.MailEvent;
	
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.IDataOutput;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;

	public class Base64 extends EventDispatcher implements IEncoder
	{
		private static const log:ILogger = Log.getLogger("com.coltware.airxmail.encode.Base64");
		
		private var enc:Base64Encoder;
		
		public function Base64()
		{
			enc = new Base64Encoder();
		}
		
		public function encodeBytes(bytes:ByteArray,output:IDataOutput):void
		{
			log.debug("encode start");
			enc.reset();
			enc.encodeBytes(bytes,0,bytes.bytesAvailable);
			var dataStr:String = enc.toString();
			var fromChar:String = String.fromCharCode(Base64Encoder.newLine);
			var lines:Array = dataStr.split(fromChar);
			
			var len:int = lines.length;
			for(var i:int=0; i<len; i++){
				output.writeUTFBytes(lines[i]);
				if(i < len -1 ){ 
					output.writeUTFBytes("\r\n");
				}
				if(i % 2000 == 0){
					var evt:MailEvent = new MailEvent(MailEvent.MAIL_WRITE_FLUSH,true);
					this.dispatchEvent(evt);
				}
			}
			log.debug("encode end");
		}
		
		public function clear():void{
			enc.reset();
		}
	}
}