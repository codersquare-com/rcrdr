package com.common
{
	
	import deng.fzip.FZip;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;

	public class Uploader
	{
		private var _uploadURL:String = "http://localhost/1/upload.php";
		private var loader:URLLoader;
		
		public function Uploader()
		{
			
		}
		
		var connection:NetConnection;
		public function sendRequest(zip:FZip):void
		{
//			var variables:URLVariables = new URLVariables();
//			var zipByteArr:ByteArray = new ByteArray();
//			zip.serialize(zipByteArr);
//			zipByteArr.position = 0;
//			
//			var urlRequest:URLRequest = new URLRequest();
//			urlRequest.url = _uploadURL;
//			//urlRequest.contentType = 'multipart/form-data; boundary=' + UploadPostHelper.getBoundary();
//			urlRequest.method = URLRequestMethod.POST;
//			urlRequest.data = UploadPostHelper.getPostData("sounds.zip", zipByteArr);
//			urlRequest.requestHeaders.push( new URLRequestHeader( 'Cache-Control', 'no-cache' ) );
//			urlRequest.requestHeaders.push(new URLRequestHeader('Content-type', 'multipart/form-data'));
//			
//			loader = new URLLoader();
//			loader.dataFormat = URLLoaderDataFormat.BINARY;
//			loader.addEventListener(Event.COMPLETE, uploadComplete);
//			loader.addEventListener(IOErrorEvent.IO_ERROR, uploadFail);
//			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityHandler);
//			loader.load(urlRequest);
			connection = new NetConnection();
			connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			connection.connect("http://localhost/2/server.php");
		}
		
		protected function securityErrorHandler(event:SecurityErrorEvent):void
		{
			// TODO Auto-generated method stub
			
		}
		
		protected function netStatusHandler(event:NetStatusEvent):void
		{
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					trace("ok");
					connection.call("myCallBack", new Responder(resultCallback));
					break;
				case "NetStream.Play.StreamNotFound":
					trace("Stream not found: " );
					break;
			}
			
		}
		
		private function resultCallback(abc:Object):void
		{
			trace("XXX" + abc);
		}
		
		protected function securityHandler(event:SecurityErrorEvent):void
		{
			trace("security error");
		}
		
		protected function onProgessEvt(event:ProgressEvent):void
		{
			// TODO Auto-generated method stub
			
		}
		
		protected function onGetStatus(event:HTTPStatusEvent):void
		{
			// TODO Auto-generated method stub
			
		}
		
		protected function uploadFail(event:IOErrorEvent):void
		{
			// TODO Auto-generated method stub
			
		}
		
		private function clearMemory():void
		{
			loader.removeEventListener(Event.COMPLETE, uploadComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, uploadFail);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityHandler);
			//loader.removeEventListener(ProgressEvent.PROGRESS, onProgessEvt);
			//			this.removeEventListener(ResultEvent.RESULT, uploadBookComplete);
			//			this.removeEventListener(FaultEvent.FAULT, uploadBookFail);
		}
		
		protected function uploadComplete(event:Event):void
		{
			trace("upload complete" + event);
			clearMemory();
		}
	}
}