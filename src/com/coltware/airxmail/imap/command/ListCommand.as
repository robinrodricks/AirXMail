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
	import com.coltware.airxlib.job.IBlockable;
	import com.coltware.airxlib.utils.StringLineReader;
	import com.coltware.airxmail.imap.IMAP4Event;
	import com.coltware.airxmail.imap.IMAP4Folder;
	import com.coltware.airxmail_internal;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.StringUtil;
	
	use namespace airxmail_internal;

	public class ListCommand extends IMAP4Command implements IBlockable
	{
		private static const log:ILogger = Log.getLogger("com.coltware.airxmail.imap.command.ListCommand");
		
		private var _basename:String;
		private var _mailbox:String;
		
		private var _folders:Array;
		
		private var _isBlock:Boolean = false;
		
		
		
		public static const NOINFERORS:String 	= "\Noinferiors";
		public static const NOSELECT:String 		= "\Noselect";
		public static const MARKED:String 			= "\Marked";
		public static const UNMARKED:String 		= "\Unmarked";
		public static const HAS_CHILDREN:String = "\HasChildren";
		public static const HAS_NO_CHILDREN:String = "\HasNoChildren";
		
		airxmail_internal var namespaceCommand:NamespaceCommand;
		
		
		public function ListCommand(basename:String = "",mailbox:String = "*")
		{
			super();
			this.key = "LIST";
			this._basename = basename;
			this._mailbox = mailbox;
			_folders = new Array();
		}
		
		public function isBlock():Boolean{
			return _isBlock;
		}
		
		public function block(val:Boolean):void{
			this._isBlock = val;
		}
		
		override public function createCommand(tag:String,capability:CapabilityCommand = null):String{
			this.tag = tag;
			var cmd:String = tag + " " + key + " \"" + this._basename + "\" \"" + this._mailbox + "\"";
			return cmd;
		}
		
		public function getResultFolders():Array{
			return this._folders;
		}
		
		override protected function parseResult(reader:StringLineReader):void{
			var line:String;
			while(line = reader.next()){
				if(line.substr(0,1) == "*"){
					var pos:int = line.indexOf(this.key);
					if(pos > 0 ){
						var value:String = line.substr(pos + this.key.length);
						value = StringUtil.trim(value);
						this._parse_list_line(value);
					}
				}
			}
		}
		
		
		
		private function _parse_list_line(line:String):void{
			var pos1:int = line.indexOf("(");
			var pos2:int = line.indexOf(")");
			if(pos1 > -1 && pos2 > pos1 ){
				var attrs_str:String = line.substr(pos1 + 1,pos2 - pos1 -1);
				var attrs:Array = attrs_str.split(/\s+/);
					
				var rest:String = line.substr(pos2 + 1);
				
				var ret:Array = this._parse_quato_value(rest);
				if(ret){
					var ret2:Array = this._parse_quato_value(ret[1]);
					var folder:IMAP4Folder = new IMAP4Folder(ret2[0],ret[0],attrs);
					
					var event:IMAP4Event = new IMAP4Event(IMAP4Event.IMAP4_FOLDER_RESULT);
					event.client = this.client;
					event.$command = this;
					event.result = folder;
					
					_folders.push(folder);
					
					client.dispatchEvent(event);
				}
			}
		}
		/**
		 *   "." "INBOX" のような感じの文字列をパースする
		 */
		private function _parse_quato_value(value:String):Array{
			var pos1:int = value.indexOf('"');
			if(pos1 > -1){
				var pos2:int = value.indexOf('"',pos1+1);
				var str:String = value.substr(pos1 + 1,pos2 - pos1 -1);
				var rest:String = value.substr(pos2+1);
				var ret:Array = [str,rest];
				return ret;
			}
			return null;
		}
		
	}
}