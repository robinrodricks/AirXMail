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
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class LoginCommand extends IMAP4Command
	{
		private static const log:ILogger = Log.getLogger("com.coltware.airxmail.imap.command.LoginCommand");
		
		private var _cap:CapabilityCommand;
		private var _username:String;
		private var _password:String;
		
		public function LoginCommand(username:String,password:String)
		{
			super();
			this.key = "LOGIN";
			this._username = username;
			this._password = password;
		}
		
		override public function createCommand(tag:String,capability:CapabilityCommand = null):String{
			
			if(capability){
				var list:Array = capability.list("AUTH");
				//  TODO  enable to change auth type depends on AUTH list
			}
			
			this.tag = tag;
			var cmd:String = tag + " " + key + " " + this._username + " " + this._password;
			return cmd;
			
		} 
	}
}