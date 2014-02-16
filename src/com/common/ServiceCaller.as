package com.common
{
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;

	public class ServiceCaller extends EventDispatcher
	{
		private static var s__instance:ServiceCaller;
		
		private var m__netConnection:NetConnection;
		
		public function ServiceCaller() 
		{
			var l__tempConnection:NetConnection = new NetConnection();
			l__tempConnection.objectEncoding = ObjectEncoding.AMF3;
			m__netConnection = new NetConnection();
			m__netConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			m__netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			m__netConnection.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);       
		}
		
		public function connect(i__url:String):void
		{           
			m__netConnection.connect(i__url); 
		}
		
		private function netStatusHandler(i__event:NetStatusEvent):void 
		{
			trace(i__event.info.code);
		}
		
		private function statusHandler(i__object:Object):void
		{
			for (var l__key:String in i__object)
				trace(l__key, i__object[l__key]);
			trace("CursorManage.removeBusyCursor()");
		}
		
		private function securityErrorHandler(i__event:SecurityErrorEvent):void 
		{
			throw new Error("securityErrorHandler: " + i__event.toString());
		}
		
		private function ioErrorHandler(i__event:IOErrorEvent):void 
		{
			throw new Error("ioErrorHandler: " + i__event.toString());
		}
		
		public function callService(i__name:String, i__listener:Function, ...arguments):void
		{
			m__netConnection.call.apply(m__netConnection, [i__name, new Responder(i__listener, statusHandler)].concat(arguments));
		}
		
		
		static public function get instance():ServiceCaller 
		{           
			if (!s__instance)
				s__instance = new ServiceCaller();
			return s__instance; 
		}
		
		static public function set instance(value:ServiceCaller):void 
		{
			s__instance = value;
		}
		
	}
}