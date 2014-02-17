package com.controler
{
	import com.common.Variables;
	import com.events.ControlEvents;
	import com.events.MainEvents;
	import com.events.ResultEvents;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;

	public class JScontroler extends EventDispatcher
	{
		private static var play_click:Boolean;
		private static var record_click:Boolean;
		private static var replay_click:Boolean;
		private static var recordDone_click:Boolean;
		
		private static var instance:JScontroler = null;
		public function JScontroler()
		{
			if(ExternalInterface.available && ExternalInterface.objectID) {		
				// Visible events
				
				ExternalInterface.addCallback(MainEvents.PLAY_CLICK, playClick); // check ok
				ExternalInterface.addCallback(MainEvents.STOP_RECORD, recordDoneClick); // check ok
				ExternalInterface.addCallback(MainEvents.REPLAY_CLICK, replayRecording); // check ok
				ExternalInterface.addCallback(MainEvents.SHOW_MICROPHONE, showMicrophone);		// check ok
				ExternalInterface.addCallback(MainEvents.PLAY_URL, playURL); // check
				ExternalInterface.addCallback(MainEvents.START_RECORD, recordSound); // check
				ExternalInterface.addCallback(MainEvents.DONE_STEP, doneStep); // check
				ExternalInterface.addCallback(MainEvents.VOLUME_IN, volumeIn); // check
				ExternalInterface.addCallback(MainEvents.VOLUME_OUT, volumeOut); // check
				ExternalInterface.addCallback(MainEvents.GET_MIC_NUM,showNumberOfMicrophone); // check
				ExternalInterface.addCallback(MainEvents.CALLBACK_INTERVAL,showPlaybackProgress); // check
				ExternalInterface.addCallback(MainEvents.PLAY, play);// check
				ExternalInterface.addCallback(MainEvents.PAUSE, pause); // check
				ExternalInterface.addCallback(MainEvents.GET_PARAMETERS, getParameters);		// check	
				ExternalInterface.addCallback(MainEvents.GET_SOUNDS, getSound);				// check
				ExternalInterface.addCallback(MainEvents.UPLOAD_URL, setUploadURL); // check
				ExternalInterface.addCallback(MainEvents.START_UPLOAD, startUpload); // check
				
				
				// flash call js
				addEventListener(ResultEvents.MICROPHONE_ACCESS, microphoneAccess); // check
				addEventListener(ResultEvents.PLAY_DONE,playDone); // check
				addEventListener(ResultEvents.RECORD_DONE, recordDone); // check
				//addEventListener(MainEvents.UPLOAD_PROGESS, uploadProgess);
				addEventListener(ResultEvents.SHOW_MICSETTING, startAction); // check
				addEventListener(ResultEvents.STARTUP, flashStartup); // check
				addEventListener(ResultEvents.START_RECORD_JS, startRecord); // check
				addEventListener(ResultEvents.STOP_RECORD_JS, stopRecord);// check
				addEventListener(ResultEvents.MIC_NUMBER, micNumber); // check
				addEventListener(ResultEvents.CALLBACK_FUNCTION, callBackFunction);// check
				addEventListener(ResultEvents.SET_PARAMETERS, resultParam); // check
				addEventListener(ResultEvents.RECORDING_TIMEOUT, recordingTimeout); // check
				addEventListener(ResultEvents.DOWNLOAD_PROGRESS, downloadProgress);
			}
			enableAll();
		}
		
		protected function downloadProgress(event:ResultEvents):void
		{
			ExternalInterface.call(Variables.eventHanlers,ResultEvents.DOWNLOAD_PROGRESS,event.url, event.progress);
		}
		
		private function getSound(args:Array):void
		{
			var me:ControlEvents = new ControlEvents(ControlEvents.GET_SOUNDS,true);
			me.uploadFile = args;
			dispatchEvent(me);
			//dispatchEvent(new MainEvents(MainEvents.PUSH_SOUND, true));
		}
		
		
		public function pushSounds(b:String):void {
			ExternalInterface.call(ResultEvents.PUSH_SOUND, b);
		}
		
		protected function recordingTimeout(event:Event):void
		{
			ExternalInterface.call(Variables.eventHanlers,ResultEvents.RECORDING_TIMEOUT);
		}
		
		private function pause():void
		{
			play("",-1);
		}
		
		
		protected function resultParam(event:ResultEvents):void
		{
			ExternalInterface.call(Variables.eventHanlers,ResultEvents.GET_PARAMETERS, event.name, event.url);
		}
		
		private function getParameters(param:String):void
		{
			var me:ControlEvents = new ControlEvents(ControlEvents.GET_PARAMETERS,true);
			me.name = param;
			dispatchEvent(me);
		}
		
		public function debug(string:String):void {
			ExternalInterface.call(Variables.eventHanlers,"Debug alert", string);
		}
		
		private function startUpload(args:Array):void
		{
			var me:ControlEvents = new ControlEvents(ControlEvents.START_UPLOAD,true);
			me.uploadFile = args;
			dispatchEvent(me);
		}
		
		private function setUploadURL(url:String):void
		{
			var me:ControlEvents = new ControlEvents(ControlEvents.UPLOAD_URL,true);
			me.url = url;
			dispatchEvent(me);
		}
		
		private function play(name:String, time:Number):void
		{
			var ms:ControlEvents = new ControlEvents(ControlEvents.PLAY,true);
			ms.name = name;
			ms.time = time;
			dispatchEvent(ms);
		}
		
		protected function callBackFunction(event:Event):void
		{
			ExternalInterface.call(Variables.eventHanlers,ResultEvents.CALLBACK_FUNCTION);
		}
		
		private function showPlaybackProgress(val:Number):void
		{
			var ms:ControlEvents = new ControlEvents(ControlEvents.CALLBACK_INTERVAL,true);
			ms.interval = val;
			dispatchEvent(ms);
		}
		
		protected function micNumber(event:ResultEvents):void
		{
			ExternalInterface.call(Variables.eventHanlers,ResultEvents.MIC_NUMBER,event.micNum);
		}
		
		private function showNumberOfMicrophone():void
		{
			dispatchEvent(new ControlEvents(ControlEvents.GET_MIC_NUM, true));
		}
		
		private function showMicrophone(mnum:Number):void
		{
			var me:ControlEvents = new ControlEvents(ControlEvents.SHOW_MICROPHONE,true);
			me.micNum = mnum;
			dispatchEvent(me);
		}
		
		private function volumeOut(vol:Number):void
		{
			var me:ControlEvents = new ControlEvents(ControlEvents.VOLUME_OUT,true);
			me.volume = vol;
			dispatchEvent(me);
		}
		
		private function volumeIn(vol:Number):void
		{			
			var me:ControlEvents = new ControlEvents(ControlEvents.VOLUME_IN,true);
			me.volume = vol;
			dispatchEvent(me);			
		}
		
		protected function stopRecord(event:ResultEvents):void
		{
			ExternalInterface.call(Variables.eventHanlers,ResultEvents.STOP_RECORD);
		}
		
		protected function startRecord(event:ResultEvents):void
		{
			ExternalInterface.call(Variables.eventHanlers,ResultEvents.START_RECORD);
		}
		
		protected function flashStartup(event:ResultEvents):void
		{
			ExternalInterface.call(Variables.eventHanlers,ResultEvents.STARTUP);
		}		
		
		
		public static function getInstance():JScontroler
		{
			if(instance == null)
				instance = new JScontroler();
			return instance;
		}
		

		protected function recordDone(event:ResultEvents):void
		{
			ExternalInterface.call(Variables.eventHanlers,ResultEvents.RECORD_DONE,event.name, event.time);
		}
		
		protected function playDone(event:ResultEvents):void
		{
			ExternalInterface.call(ResultEvents.PLAY_DONE, event.name);
		}
		
		protected function microphoneAccess(event:ResultEvents):void
		{
			ExternalInterface.call(Variables.eventHanlers,ResultEvents.MICROPHONE_ACCESS, event.micAccess);
		}
		
		protected function startAction(event:ResultEvents):void
		{
			ExternalInterface.call(Variables.eventHanlers,ResultEvents.SHOW_MICSETTING);			
		}
		
		
		private function doneStep():void
		{
			dispatchEvent(new ControlEvents(ControlEvents.DONE_STEP,true));
			
		}
		
		private function recordSound(vname:String, vtime:Number):void
		{
			var mainEvent:ControlEvents = new ControlEvents(ControlEvents.START_RECORD,true);
			mainEvent.name = vname;
			mainEvent.time = vtime;
			dispatchEvent(mainEvent);
		}
		
		private function playURL(vurl:String):void
		{
			var mainEvent:ControlEvents = new ControlEvents(ControlEvents.PLAY_URL,true);
			mainEvent.url = vurl;
			dispatchEvent(mainEvent);			
		}
		
		private function replayRecording():void
		{
			if(!replay_click)
				return;
				
			dispatchEvent(new ControlEvents(ControlEvents.REPLAY_CLICK,true));
		}
		
		private function recordDoneClick():void
		{
			if(!recordDone_click)
				return;
			dispatchEvent(new ControlEvents(ControlEvents.STOP_RECORD,true));
		}
		
//		private function recordClick():void
//		{
//			if(!record_click)
//				return;
//			dispatchEvent(new MainEvents(MainEvents.START_RECORD,true));
//		}
		
		private function playClick():void
		{
			if(!play_click)
				return;
			dispatchEvent(new ControlEvents(ControlEvents.PLAY_CLICK,true));
		}
		
		public function disableAll():void
		{
			play_click = false;
			record_click = false;
			replay_click = false;
			recordDone_click = false;
		}
		
		public function enableAll():void
		{
			play_click = true;
			record_click = true;
			replay_click = true;
			recordDone_click = true;
		}
		
		public function initStatus():void
		{
			record_click = true;			
			play_click = false;
			replay_click = false;
			recordDone_click = false;
		}
		
		public function playButtonStatus(enable:Boolean):void
		{
			play_click = enable;
			
		}
		
		public function recordButtonStatus(enable:Boolean):void
		{
			record_click = enable;
		}
		
		public function recordDoneButtonStatus(enable:Boolean):void
		{
			recordDone_click = enable;
		}
		
		public function replayButtonStatus(enable:Boolean):void
		{
			replay_click = enable;		
		}
		
	}
}