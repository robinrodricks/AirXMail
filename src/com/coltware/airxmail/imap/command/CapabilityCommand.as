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
	import com.coltware.airxlib.utils.StringLineReader;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.StringUtil;

	public class CapabilityCommand extends IMAP4Command
	{
		private static const log:ILogger = Log.getLogger("com.coltware.airxmail.imap.command.CapabilityCommand");
		private static const reg:RegExp = /\s+/;
		
		private var map:Object;
		
		public function CapabilityCommand()
		{
			super();
			this.key = "CAPABILITY";
			map = new Object();
		}
		
		public function has(command:String):Boolean{
			var _cmd:String = command.toUpperCase();
			if(map.hasOwnProperty(_cmd)){
				return true;
			}
			else{
				return false;
			}
		}
		
		public function list(command:String):Array{
			var _cmd:String = command.toUpperCase();
			if(map.hasOwnProperty(_cmd)){
				return map[_cmd];
			}
			else{
				return null;
			}
		}
		
		override protected function parseResult(reader:StringLineReader):void{
			var line:String;
			while(line = reader.next()){
				line = StringUtil.trim(line);
				var arr:Array = line.split(reg);
				for each(var item:String in arr){
					this.parse_each_item(item);
				}
			}
			this.resultBytes = null;
		}
		
		private function parse_each_item(val:String):void{
			if(val != "*"){
				val = val.toUpperCase();
				var pos:int = val.indexOf("=");
				if(pos < 0 ){
					if(map.hasOwnProperty(val)){
						
					}
					else{
						map[val] = [];
					}
				}
				else{
					var _key:String = val.substr(0,pos);
					var _val:String = val.substr(pos + 1);
					if(map.hasOwnProperty(_key)){
						(map[_key] as Array).push(_val);
					}
					else{
						map[_key] = [_val];
					}
				}
			}
		}
	}
}