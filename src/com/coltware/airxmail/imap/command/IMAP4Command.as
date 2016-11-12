/**
 *  Copyright (c)  2009 coltware.com
 *  http://www.coltware.com 
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxmail.imap.command
{
	import com.coltware.airxmail.imap.IMAP4Client;
	import com.coltware.airxmail_internal;
	import com.coltware.airxlib.utils.StringLineReader;
	
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	use namespace airxmail_internal;
	
	[Event(name="imap4CommandOk",type="com.coltware.airxmail.imap.IMAP4Event")]
	[Event(name="imap4CommandNo",type="com.coltware.airxmail.imap.IMAP4Event")]
	[Event(name="imap4CommandBad",type="com.coltware.airxmail.imap.IMAP4Event")]
	
	public class IMAP4Command extends EventDispatcher
	{
		public static const log:ILogger = Log.getLogger("com.coltware.airxmail.imap.command.IMAP4Command");
		
		public var key:String;
		public var tag:String;
		public var value:String;
		
		public var status:String;
		public var resultBytes:ByteArray;
		
		public var client:IMAP4Client;
		
		public function IMAP4Command()
		{
			resultBytes = new ByteArray();
		}
		
		public function createCommand(tag:String,capability:CapabilityCommand = null):String{
			this.tag = tag;
			var cmd:String = tag + " " + key;
			if(this.value){
				cmd += " " + value;
			}
			return cmd;
		}
		
		protected function parseResult(reader:StringLineReader):void{
			
		}
		
		airxmail_internal function $result_parse(bytes:ByteArray):void{
			var lineReader:StringLineReader = new StringLineReader();
			lineReader.source = bytes;
			this.parseResult(lineReader);
		}
	}
}