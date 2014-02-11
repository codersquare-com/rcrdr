package com.controler
{
	import com.common.Variables;
	import com.events.ButtonEvents;
	import com.events.MainEvents;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;

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
				ExternalInterface.addCallback(ButtonEvents.PLAY_CLICK, playClick);
				//ExternalInterface.addCallback(ButtonEvents.S, recordClick);
				ExternalInterface.addCallback(MainEvents.STOP_RECORD, recordDoneClick);
				ExternalInterface.addCallback(ButtonEvents.REPLAY_CLICK, replayRecording);
				ExternalInterface.addCallback(ButtonEvents.SHOW_MICROPHONE, showMicrophone);				
				// Invisible events
				ExternalInterface.addCallback(MainEvents.PLAY_URL, playURL);
				ExternalInterface.addCallback(MainEvents.START_RECORD, recordSound);
				ExternalInterface.addCallback(MainEvents.DONE_STEP, doneStep);
				ExternalInterface.addCallback(MainEvents.UPLOAD_URL, uploadURL);
				ExternalInterface.addCallback(MainEvents.VOLUME_IN, volumeIn);
				ExternalInterface.addCallback(MainEvents.VOLUME_OUT, volumeOut);
				ExternalInterface.addCallback(MainEvents.GET_MIC_NUM,showNumberOfMicrophone);
				ExternalInterface.addCallback(MainEvents.CALLBACK_INTERVAL,showPlaybackProgress);
				ExternalInterface.addCallback(MainEvents.PLAY, play);
				ExternalInterface.addCallback(MainEvents.PAUSE, pause);
				ExternalInterface.addCallback(MainEvents.GET_PARAMETERS, getParameters);			
				
				
				ExternalInterface.addCallback(MainEvents.UPLOAD_URL, setUploadURL);
				ExternalInterface.addCallback(MainEvents.START_UPLOAD, startUpload);
				// flash call js
				addEventListener(MainEvents.MICROPHONE_ACCESS, microphoneAccess);
				addEventListener(MainEvents.PLAY_DONE,playDone);
				addEventListener(MainEvents.RECORD_DONE, recordDone);
				addEventListener(MainEvents.UPLOAD_PROGESS, uploadProgess);
				addEventListener(MainEvents.SHOW_MICSETTING, startAction);
				addEventListener(MainEvents.STARTUP, flashStartup);
				addEventListener(MainEvents.START_RECORD, startRecord);
				addEventListener(MainEvents.STOP_RECORD, stopRecord);
				addEventListener(MainEvents.MIC_NUMBER, micNumber);
				addEventListener(MainEvents.CALLBACK_FUNCTION, callBackFunction);
				addEventListener(MainEvents.SET_PARAMETERS, resultParam);
				addEventListener(MainEvents.RECORDING_TIMEOUT, recordingTimeout);
			}
			enableAll();
		}
		
		protected function recordingTimeout(event:Event):void
		{
			ExternalInterface.call(Variables.eventHanlers,MainEvents.RECORDING_TIMEOUT);
		}
		
		private function pause():void
		{
			play("",-1);
		}
		
		protected function resultParam(event:MainEvents):void
		{
			ExternalInterface.call(Variables.eventHanlers,MainEvents.GET_PARAMETERS, event.name, event.url);
		}
		
		private function getParameters(param:String):void
		{
			var me:MainEvents = new MainEvents(MainEvents.GET_PARAMETERS,true);
			me.name = param;
			dispatchEvent(me);
		}
		
		public function debug(string:String):void {
			ExternalInterface.call(Variables.eventHanlers,"Debug alert", string);
		}
		
		private function startUpload(args:Array):void
		{
			var me:MainEvents = new MainEvents(MainEvents.START_UPLOAD,true);
			me.uploadFile = args;
			dispatchEvent(me);
		}
		
		private function setUploadURL(url:String):void
		{
			var me:MainEvents = new MainEvents(MainEvents.UPLOAD_URL,true);
			me.url = url;
			dispatchEvent(me);
		}
		
		private function play(name:String, time:Number):void
		{
			var ms:MainEvents = new MainEvents(MainEvents.PLAY,true);
			ms.name = name;
			ms.time = time;
			dispatchEvent(ms);
		}
		
		protected function callBackFunction(event:Event):void
		{
			ExternalInterface.call(Variables.eventHanlers,MainEvents.CALLBACK_FUNCTION);
		}
		
		private function showPlaybackProgress(val:Number):void
		{
			var ms:MainEvents = new MainEvents(MainEvents.CALLBACK_INTERVAL,true);
			ms.interval = val;
			dispatchEvent(ms);
		}
		
		protected function micNumber(event:MainEvents):void
		{
			ExternalInterface.call(Variables.eventHanlers,MainEvents.MIC_NUMBER,event.micNum);
		}
		
		private function showNumberOfMicrophone():void
		{
			dispatchEvent(new MainEvents(MainEvents.GET_MIC_NUM, true));
		}
		
		private function showMicrophone(mnum:Number):void
		{
			var me:MainEvents = new MainEvents(MainEvents.SHOW_MICROPHONE,true);
			me.micNum = mnum;
			dispatchEvent(me);
		}
		
		private function volumeOut(vol:Number):void
		{
			var me:MainEvents = new MainEvents(MainEvents.VOLUME_OUT,true);
			me.volume = vol;
			dispatchEvent(me);
		}
		
		private function volumeIn(vol:Number):void
		{			
			var me:MainEvents = new MainEvents(MainEvents.VOLUME_IN,true);
			me.volume = vol;
			dispatchEvent(me);
			
		}
		
		protected function stopRecord(event:MainEvents):void
		{
			ExternalInterface.call(Variables.eventHanlers,MainEvents.STOP_RECORD);
		}
		
		protected function startRecord(event:MainEvents):void
		{
			ExternalInterface.call(Variables.eventHanlers,MainEvents.START_RECORD);
		}
		
		protected function flashStartup(event:MainEvents):void
		{
			ExternalInterface.call(Variables.eventHanlers,MainEvents.STARTUP);
		}		
		
		
		public static function getInstance():JScontroler
		{
			if(instance == null)
				instance = new JScontroler();
			return instance;
		}
		
				
		protected function uploadProgess(event:MainEvents):void
		{
			ExternalInterface.call(Variables.eventHanlers,MainEvents.UPLOAD_PROGESS,event.uploadPercent);
		}
		
		protected function recordDone(event:MainEvents):void
		{
			ExternalInterface.call(Variables.eventHanlers,MainEvents.RECORD_DONE,event.name, event.time);
		}
		
		protected function playDone(event:MainEvents):void
		{
			ExternalInterface.call(MainEvents.PLAY_DONE, event.name);
		}
		
		protected function microphoneAccess(event:MainEvents):void
		{
			ExternalInterface.call(Variables.eventHanlers,MainEvents.MICROPHONE_ACCESS, event.micAccess);
		}
		
		protected function startAction(event:Event):void
		{
			ExternalInterface.call(Variables.eventHanlers,MainEvents.SHOW_MICSETTING);			
		}
		
		private function uploadURL(vurl:String):void
		{
			var mainEvent:MainEvents = new MainEvents(MainEvents.UPLOAD_URL,true);
			mainEvent.url = vurl;
			dispatchEvent(mainEvent);
		}
		
		private function doneStep():void
		{
			dispatchEvent(new MainEvents(MainEvents.DONE_STEP,true));
			
		}
		
		private function recordSound(vname:String, vtime:Number):void
		{
			var mainEvent:MainEvents = new MainEvents(MainEvents.START_RECORD_AS3,true);
			mainEvent.name = vname;
			mainEvent.time = vtime;
			dispatchEvent(mainEvent);
		}
		
		private function playURL(vurl:String):void
		{
			var mainEvent:MainEvents = new MainEvents(MainEvents.PLAY_URL,true);
			mainEvent.url = vurl;
			dispatchEvent(mainEvent);			
		}
		
		private function replayRecording():void
		{
			if(!replay_click)
				return;
				
			dispatchEvent(new ButtonEvents(ButtonEvents.REPLAY_CLICK_AS3,true));
		}
		
		private function recordDoneClick():void
		{
			if(!recordDone_click)
				return;
			dispatchEvent(new MainEvents(MainEvents.STOP_RECORD_AS3,true));
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
			dispatchEvent(new ButtonEvents(ButtonEvents.PLAY_CLICK,true));
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