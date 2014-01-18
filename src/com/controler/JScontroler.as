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
				ExternalInterface.addCallback(ButtonEvents.RECORD_CLICK, recordClick);
				ExternalInterface.addCallback(ButtonEvents.RECORD_DONE_CLICK, recordDoneClick);
				ExternalInterface.addCallback(ButtonEvents.REPLAY_CLICK, replayClick);
								
				// Invisible events
				ExternalInterface.addCallback(MainEvents.PLAY_URL, playURL);
				ExternalInterface.addCallback(MainEvents.RECORD_SOUND, recordSound);
				ExternalInterface.addCallback(MainEvents.DONE_STEP, doneStep);
				ExternalInterface.addCallback(MainEvents.UPLOAD_URL, uploadURL);
				
				// flash call js
				addEventListener(MainEvents.MICROPHONE_ACCESS, microphoneAccess);
				addEventListener(MainEvents.PLAY_DONE,playDone);
				addEventListener(MainEvents.RECORD_DONE, recordDone);
				addEventListener(MainEvents.UPLOAD_PROGESS, uploadProgess);
				addEventListener(MainEvents.SHOW_MICSETTING, startAction);
			}
			enableAll();
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
			ExternalInterface.call(Variables.eventHanlers,MainEvents.RECORD_DONE,event.name);
		}
		
		protected function playDone(event:MainEvents):void
		{
			ExternalInterface.call(Variables.eventHanlers,MainEvents.PLAY_DONE);
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
			var mainEvent:MainEvents = new MainEvents(MainEvents.RECORD_SOUND,true);
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
		
		private function replayClick():void
		{
			if(!replay_click)
				return;
				
			dispatchEvent(new ButtonEvents(ButtonEvents.REPLAY_CLICK,true));
		}
		
		private function recordDoneClick():void
		{
			if(!recordDone_click)
				return;
			dispatchEvent(new ButtonEvents(ButtonEvents.RECORD_DONE_CLICK,true));
		}
		
		private function recordClick():void
		{
			if(!record_click)
				return;
			dispatchEvent(new ButtonEvents(ButtonEvents.RECORD_CLICK,true));
		}
		
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