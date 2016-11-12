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
	import com.coltware.airxmail.imap.IMAP4ListEvent;
	import com.coltware.airxlib.job.IBlockable;
	import com.coltware.airxlib.utils.StringLineReader;
	
	import mx.utils.StringUtil;

	public class SearchCommand extends IMAP4Command implements IBlockable
	{
		private var _useUid:Boolean = false;
		
		/**
		 *   useUid: true ( UID SEARCH )
		 */
		public function SearchCommand(args:String,useUid:Boolean = true)
		{
			super();
			if(useUid){
				this.key = "UID SEARCH";
			}
			else{
				this.key = "SEARCH";
			}
			_useUid = useUid;
			this.value = args;
		}
		
		public function isBlock():Boolean{
			return true;
		}
		
		override protected function parseResult(reader:StringLineReader):void{
			var line:String;
			while(line = reader.next()){
				
				if(line.substr(0,1) == "*"){
				
					log.debug("line>" + line);
					if(!this._useUid){
						log.debug(line);
					}
					
					var pos:int = line.indexOf("SEARCH");
					if(pos > 0){
						var value:String = line.substr(pos + "SEARCH".length);
						value = StringUtil.trim(value);
						var list:Array;
						
						if(value.length > 0){
							var reg:RegExp = /\s+/;
							list = value.split(reg);
						}
						else{
							list = new Array();
						}
						var event:IMAP4ListEvent;
						if(_useUid){
							event = new IMAP4ListEvent(IMAP4ListEvent.IMAP4_RESULT_UID_LIST);
						}
						else{
							event = new IMAP4ListEvent(IMAP4ListEvent.IMAP4_RESULT_LIST);
						}
						event.result = list;
						client.dispatchEvent(event);
					}
				}
			}
		}
	}
}