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
			_recorder.addCallBack(stopRecord, startRecord);
			// startup
			JScontroler.getInstance().dispatchEvent(new MainEvents(MainEvents.STARTUP,true));
		}
		private function stopRecord() :void {
			JScontroler.getInstance().dispatchEvent(new MainEvents(MainEvents.STOP_RECORD,true));
		}
		private function startRecord() : void {
			JScontroler.getInstance().dispatchEvent(new MainEvents(MainEvents.START_RECORD,true));
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
		
		private function addCurrentRecordToPlaylist():void {			
			playlist.AddWavSound((encoders[curEncoderIndex] as IEncoder).getByteArray());
			PLAY();
			JScontroler.getInstance().dispatchEvent(new MainEvents(MainEvents.RECORD_DONE,true));
			trace("user record done");
		}
		
		protected function user_record_done(event:Event):void
		{
			if(this.status == Variables.RECORDDONE){
				this.status = Variables.READY;
				addCurrentRecordToPlaylist();
			} 
			
			if (this.status == Variables.RECORD) {
				// use tmp sound
				playlist.AddWaveSoundAndPlay((encoders[curEncoderIndex] as IEncoder).getByteArray());
			}
			
			if (this.status == Variables.RE_RECORD) {
				_recorder.record();
				this.status = Variables.RECORD;
			}
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
			}
			trace("replay record");
		}
		
		protected function recordDoneClick(event:ButtonEvents):void
		{
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE,record_timeout);
			try {
				var isStoping:Boolean = _recorder.stop();
				if(!isStoping) {					
					this.status = Variables.READY;
					addCurrentRecordToPlaylist();
				}
				else // wait to done					
					this.status = Variables.RECORDDONE;
			}catch (e:Error)
			{
				this.status = Variables.READY;
			}
			trace("record done");
		}
		
		protected function recordClick(event:ButtonEvents):void
		{
			if(status == Variables.INITIAL){
				_main.stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);	
				addEventListener(MainEvents.RESIZED, showSetting);
			}
			
			if(status == Variables.RECORD )
			{
				try{
					var isStoping:Boolean = _recorder.stop();
					if(!isStoping) {	
						_recorder.record();
					}else
						status = Variables.RE_RECORD;
					playlist.STOPALL();
				} catch (e:Error) {}
				_recorder.record();
			}
			trace("Record click");
		}
		
		protected function onStageResize(event:Event):void
		{
			_main.stage.removeEventListener(Event.RESIZE, onStageResize);
			dispatchEvent(new MainEvents(MainEvents.RESIZED,true));
		}
		
		protected function showSetting(event:Event):void
		{
			removeEventListener(MainEvents.RESIZED, showSetting);
			JScontroler.getInstance().dispatchEvent(new MainEvents(MainEvents.SHOW_MICSETTING,true));
			var tmp:Mp3Encoder = new Mp3Encoder;
			_recorder.startup(tmp,_mic);
			_recorder.record();			
			_recorder.microphone.addEventListener(StatusEvent.STATUS, this.userAccessMicEvent); 			
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