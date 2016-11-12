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
	import com.coltware.airxmail.imap.IMAP4Event;
	import com.coltware.airxmail.imap.IMAP4Folder;
	import com.coltware.airxmail.imap.chain.ISearch;
	import com.coltware.airxmail_internal;
	import com.coltware.airxlib.job.IBlockable;
	import com.coltware.airxlib.utils.StringLineReader;
	
	import flash.events.Event;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.StringUtil;
	
	use namespace airxmail_internal;

	public class SelectCommand extends IMAP4Command implements IBlockable, ISearch
	{
		private static const log:ILogger = Log.getLogger("com.coltware.airxmail.imap.command.SelectCommand");
		
		private var _folder:IMAP4Folder;
		private var _exists:Number = 0;
		private var _recent:Number = 0;
		private var _uidvalidity:String;
		
		public function SelectCommand(folder_StringOrIMAP4Folder:Object = null)
		{
			super();
			this.key = "SELECT";
			if(folder_StringOrIMAP4Folder is IMAP4Folder){
				_folder = folder_StringOrIMAP4Folder as IMAP4Folder;
				this.value = '"' +  (folder_StringOrIMAP4Folder as IMAP4Folder).name + '"';
			}
			else{
				this.value = '"' + ( folder_StringOrIMAP4Folder as String) + '"';
			}
		}
		
		public function search(args:String,useUid:Boolean = true):void{
			var f:Function = function(evt:*):void{
				removeEventListener(Event.COMPLETE,f);
				client.search(args,useUid);
			};
			this.addEventListener(Event.COMPLETE,f,false,0,false);
		}
		
		public function isBlock():Boolean{
			return true;
		}
		
		public function get folder():IMAP4Folder{
			return this._folder;
		}
		
		override protected function parseResult(reader:StringLineReader):void{
			var line:String;
			while(line = reader.next()){
				var pos:int = line.indexOf("*");
				line = line.substr(pos+1);
				
				this._parse_exists(line);
				this._parse_recent(line);
				this._parse_uidvalidity(line);
			}
			
			if(_folder){
				_folder.$numExists = this._exists;
				_folder.$uidvalidity = this._uidvalidity;
				_folder.$numRecent = this._recent;
			}
			var event:Event = new Event(Event.COMPLETE);
			this.dispatchEvent(event);
		}
		
		private function _parse_exists(line:String):Boolean{
			var pos2:int = line.indexOf("EXISTS");
			if(pos2 > -1){
				var numStr:String = line.substr(0,pos2);
				numStr = StringUtil.trim(numStr);
				_exists = parseInt(numStr);
				return true;
			}
			return false;
		}
		
		private function _parse_recent(line:String):Boolean{
			var pos:int = line.indexOf("RECENT");
			if(pos > -1){
				var numStr:String = line.substr(0,pos);
				numStr = StringUtil.trim(numStr);
				_recent = parseInt(numStr);
				return true;
			}
			return false;
		}
		
		private function _parse_uidvalidity(line:String):Boolean{
			var pos:int = line.indexOf("UIDVALIDITY");
			if(pos > -1){
				var idStr:String = line.substr(pos + "UIDVALIDITY".length);
				var pos2:int = idStr.indexOf("]");
				this._uidvalidity = StringUtil.trim(idStr.substr(0,pos2));
			}
			return false;
		}
	}
}