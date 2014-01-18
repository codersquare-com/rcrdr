package com.controler
{
	import acodec.IEncoder;
	import acodec.MicRecorder;
	import acodec.encoder.Mp3Encoder;
	import acodec.encoder.WaveEncoder;
	
	import com.common.Variables;
	import com.events.ButtonEvents;
	import com.events.MainEvents;
	import com.media.Playlist;
	
	import flash.events.ActivityEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SampleDataEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.media.Microphone;
	import flash.system.Security;
	import flash.utils.Timer;

	public class Controler extends EventDispatcher
	{
		private var _main:VietEDPlayer;
		private var status:String;
		private var _mic:Microphone;
		private var _recorder:MicRecorder;
		private var encoders:Array = new Array;
		private var playlist:Playlist;
		private var timer:Timer;
		private var curEncoderIndex:Number;
		private var tmp:IEncoder;
		public function Controler(main:VietEDPlayer)
		{
			_main = main;
			// control button
			JScontroler.getInstance().addEventListener(ButtonEvents.PLAY_CLICK, playClick);
			JScontroler.getInstance().addEventListener(ButtonEvents.RECORD_CLICK, recordClick);
			JScontroler.getInstance().addEventListener(ButtonEvents.RECORD_DONE_CLICK, recordDoneClick);
			JScontroler.getInstance().addEventListener(ButtonEvents.REPLAY_CLICK, replayClick);
			
			// control js auto event
			JScontroler.getInstance().addEventListener(MainEvents.PLAY_URL, playURL);
			JScontroler.getInstance().addEventListener(MainEvents.RECORD_SOUND, recordSound);
			JScontroler.getInstance().addEventListener(MainEvents.DONE_STEP, doneStep);
			status = Variables.INITIAL;			
			playlist = new Playlist;
			_recorder = new MicRecorder;
			playlist.addCallBack(soundCompleteHandler);
			
			// startup
			JScontroler.getInstance().dispatchEvent(new MainEvents(MainEvents.STARTUP,true));
		}
		
		protected function doneStep(event:Event):void
		{
			this.status = Variables.DONE;
			
		}
		
		protected function recordSound(event:MainEvents):void
		{
			if(this.status != Variables.INITIAL || this.status != Variables.READY)
				JScontroler.getInstance().dispatchEvent(new MainEvents(MainEvents.ERROR_RECORD,true));
			this.status = Variables.RECORD;
			var iencoder:IEncoder = new Mp3Encoder;
			iencoder.name = event.name;
			encoders.push(iencoder);
			curEncoderIndex =  encoders.length - 1;
			_recorder.startup(iencoder,_mic);
			_recorder.record();
			_recorder.addEventListener(Event.COMPLETE, user_record_done);
			timer= new Timer(1000,event.time);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, record_timeout);
			timer.start();
		}
		
		protected function user_record_done(event:Event):void
		{
			this.status = Variables.READY;
			playlist.AddWavSound((encoders[curEncoderIndex] as IEncoder).getByteArray());
			PLAY();
			JScontroler.getInstance().dispatchEvent(new MainEvents(MainEvents.RECORD_DONE,true));
			trace("user record done");
		}
		
		protected function record_timeout(event:TimerEvent):void
		{
			recordDoneClick(null);
		}
		
		private function soundCompleteHandler():void {
			this.status= Variables.READY;
			JScontroler.getInstance().dispatchEvent(new MainEvents(MainEvents.PLAY_DONE,true));
		}
		
		protected function playURL(event:MainEvents):void
		{
			playlist.AddSound(event.url);
			PLAY();
		}		
		
		private function PLAY():void
		{
			if(this.status == Variables.READY || this.status == Variables.INITIAL)
			{
				playlist.play();				
			}
			
		}		
		
		protected function replayClick(event:ButtonEvents):void
		{
			if(this.status == Variables.RECORD){			
				_recorder.stop();
				tmp = new Mp3Encoder;
				_recorder.startup(tmp,_mic);				
			}
			trace("replay record");
		}
		
		protected function recordDoneClick(event:ButtonEvents):void
		{
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE,record_timeout);
			_recorder.stop();
			trace("record done");
		}
		
		protected function recordClick(event:ButtonEvents):void
		{
			if(status == Variables.INITIAL){
				JScontroler.getInstance().dispatchEvent(new MainEvents(MainEvents.SHOW_MICSETTING,true));
				tmp = new Mp3Encoder;
				_recorder.startup(tmp,_mic);
				_recorder.record();
				
				_recorder.microphone.addEventListener(StatusEvent.STATUS, this.userAccessMicEvent); 
			}
			
			if(status == Variables.RECORD)
			{
				_recorder.record();
			}
			trace("Record click");
		}
		
		protected function userAccessMicEvent(event:StatusEvent):void
		{
			_recorder.stop();
			var e:MainEvents = new MainEvents(MainEvents.MICROPHONE_ACCESS,true);
			e.micAccess = false;
			if (event.code == "Microphone.Unmuted") 
			{
				e.micAccess = true;
			}
			JScontroler.getInstance().dispatchEvent(e);
			trace(event);
		}
		
		protected function statusHandler(event:StatusEvent):void
		{
			trace(event);
		}
		
		protected function activityHandler(event:ActivityEvent):void
		{
			trace(event);			
		}
		
		
		protected function playClick(event:ButtonEvents):void
		{
			if(this.status == Variables.DONE)
				playlist.PLAYALL();
			
		}
		
		public function startup():void
		{
			// TODO Auto Generated method stub
			
		}
	}
}