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
	import com.coltware.airxmail.imap.IMAP4Event;
	import com.coltware.airxmail.imap.IMAP4Folder;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.StringUtil;

	public class NamespaceCommand extends IMAP4Command
	{
		private static const log:ILogger = Log.getLogger("com.coltware.airxmail.imap.command.NamespaceCommand");
		
		/**
		 *  My Space
		 */
		private var myspace:Array;
		private var otherspace:Array;
		private var publicspace:Array;
		
		public function NamespaceCommand()
		{
			super();
			this.key = "NAMESPACE";
			myspace = new Array();
			otherspace = new Array();
			publicspace = new Array();
		}
		
		public function getMyspaceFolders():Array{
			return this.myspace;
		}
		
		override protected function parseResult(reader:StringLineReader):void{
			var line:String;
			while(line = reader.next()){
				if(line.substr(0,1) == "*"){
					line = StringUtil.trim(line);
					log.debug("namespace:[" + line + "]");
					var pos:int = line.indexOf(this.key);
					if(pos > 0){
						var value:String = line.substr(pos+ this.key.length);
						var rest:String;
					
						rest = this.parse_ns_value(value,myspace);
						rest = this.parse_ns_value(rest,otherspace);
						this.parse_ns_value(rest,publicspace);
					
					}
				}
			}
		}
		
		/**
		 *  parse result
		 *  ex)
		 *  "(("" ".")) NIL NIL"
		 */
		private function parse_ns_value(line:String,folders:Array):String{
			
			var npos:int = line.indexOf("NIL");
			var pos:int   = line.indexOf("(");
			
			if(npos > -1 && ( pos > -1 && pos > npos)){
				return line.substr(npos + "NIL".length);
			}
			
			var next:Boolean = true;
			var i:int = pos + 1;
			var depth:int = 1;
			var val:String = "";
			var append:Boolean = false;
			while(next){
				var ch:String = line.charAt(i);
				if(ch == "("){
					depth++;
					append = true;
				}
				else if(ch == ")"){
					append = false;
					depth--;
					if(depth > 0){
						this.split_space(val,folders);
					}
					val = "";
				}
				else{
					if(append)
						val += ch;
				}
				
				i++;
				if(depth == 0 || i > line.length){
					next = false;
				}
			}
			return line.substr(i);
		}
		
		private function split_space(value:String,folders:Array):void{
			var pos1:int = value.indexOf('"');
			var pos2:int = value.indexOf('"',pos1 + 1);
			
			var val1:String = value.substring(pos1 + 1,pos2);
			
			var pos3:int = value.indexOf('"',pos2 + 1);
			var pos4:int = value.indexOf('"',pos3 + 1);
			
			var val2:String = value.substring(pos3 + 1,pos4);
			
			log.debug("name:[" + val1 + "] , delim:[" + val2 + "]");
			var folder:IMAP4Folder = new IMAP4Folder(val1,val2,null);
			folders.push(folder);
		}
	}
}