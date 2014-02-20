package com.controler
{
	import acodec.IEncoder;
	import acodec.MicRecorder;
	import acodec.encoder.Mp3Encoder;
	import acodec.encoder.WaveEncoder;
	
	import com.common.Uploader;
	import com.common.Variables;
	import com.events.ControlEvents;
	import com.events.MediatorEvent;
	import com.events.ResultEvents;
	import com.media.Playlist;
	
	import deng.fzip.FZip;
	
	import flash.events.ActivityEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SampleDataEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.media.Microphone;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	public class Controler extends EventDispatcher
	{
		private var _main:VietEDPlayer;
		private var status:String;
		private var _mic:Microphone;
		private var _recorder:MicRecorder;
		private var encoders:Array = new Array;
		private var playlist:Playlist;
		private var timer:Timer;
		private var _gain:Number;
		private var curEncoderIndex:Number;
		private var _micNum:Number;
		private var _interval:Number;
		private var interValProcess:uint;
		private var interValRuning:Boolean;
		
		public function Controler(main:VietEDPlayer)
		{
			_main = main;
			// control button
			JScontroler.getInstance().addEventListener(ControlEvents.PLAY_CLICK, playClick); // check ok
			JScontroler.getInstance().addEventListener(ControlEvents.STOP_RECORD, stopRecorder); // check ok
			JScontroler.getInstance().addEventListener(ControlEvents.REPLAY_CLICK, replayClick); // check ok
			JScontroler.getInstance().addEventListener(ControlEvents.PLAY_URL, playURL); // check ok
			JScontroler.getInstance().addEventListener(ControlEvents.START_RECORD, startRecording); // check 
			JScontroler.getInstance().addEventListener(ControlEvents.DONE_STEP, doneStep); // check
			JScontroler.getInstance().addEventListener(ControlEvents.VOLUME_IN, volumeIn); // check
			JScontroler.getInstance().addEventListener(ControlEvents.VOLUME_OUT, volumeOut); // check
			JScontroler.getInstance().addEventListener(ControlEvents.SHOW_MICROPHONE, showMicrophone); // check
			JScontroler.getInstance().addEventListener(ControlEvents.GET_MIC_NUM, showNumberOfMicrophone); // check
			JScontroler.getInstance().addEventListener(ControlEvents.CALLBACK_INTERVAL, showPlaybackProgress);// check
			JScontroler.getInstance().addEventListener(ControlEvents.PLAY, play); // check
			JScontroler.getInstance().addEventListener(ControlEvents.GET_SOUNDS, getSounds);// check
			JScontroler.getInstance().addEventListener(ControlEvents.UPLOAD_URL, uploadUrl); // check
			JScontroler.getInstance().addEventListener(ControlEvents.GET_PARAMETERS, getParams);// check
			JScontroler.getInstance().addEventListener(ControlEvents.START_UPLOAD, startUpload); // check
			JScontroler.getInstance().addEventListener(ControlEvents.STOP, stop); // check
			status = Variables.INITIAL;			
			playlist = new Playlist(downloadCallback);
			_recorder = new MicRecorder;
			playlist.addCallBack(soundCompleteHandler);
			_recorder.addCallBack(stopRecord, startRecord);
			// startup
			JScontroler.getInstance().dispatchEvent(new ResultEvents(ResultEvents.STARTUP,true));
			_gain = 70;
			_micNum = -1;
			interValProcess = 0;
			interValRuning = false;
		}
		
		protected function stop(event:Event):void
		{
			playlist.STOPALL();
		}
		
		private function downloadCallback(url:String, pg:Number):void {
			var rs:ResultEvents = new ResultEvents(ResultEvents.DOWNLOAD_PROGRESS,true);
			rs.url = url;
			rs.progress= pg;
			JScontroler.getInstance().dispatchEvent(rs);
			
		}
			
		protected function getSounds(event:ControlEvents):void
		{
			var fh:FileHandler = new FileHandler();
			
			var isDone:Number;//=
			var isUpload:Boolean = true;
			var j:Number = 0,i:Number = 0;
			if(event.uploadFile == null){
				isDone = encoders.length;
				for(i= 0; i< encoders.length; i++)
				{
					if((encoders[i] as Mp3Encoder).status == Variables.MP3_ENCODED_MP3) {
						fh.addFile((encoders[i] as Mp3Encoder).name,(encoders[i] as Mp3Encoder).getMp3Array(null,i));
						isDone --;
					}
					else {						
						isUpload = false;
						(encoders[i] as Mp3Encoder).getMp3Array(addJtoI,i);
					}
				}
			}
			else
			{
				isDone = event.uploadFile.length;
				
				for(i = 0; i< event.uploadFile.length; i++)
				{
					for(j  = 0; j < encoders.length;j++)
					{
						if( (encoders[j] as Mp3Encoder).name == event.uploadFile[i])
						{
							if((encoders[j] as Mp3Encoder).status == Variables.MP3_ENCODED_MP3) {
								fh.addFile(event.uploadFile[i],(encoders[j] as Mp3Encoder).getMp3Array(null,j));
								isDone --;
							}
							else
								(encoders[i] as Mp3Encoder).getMp3Array(addJtoI,j);
						}
					}
				}
			}
			
			function addJtoI(index:int):void
			{
				fh.addFile(event.uploadFile[index],(encoders[index] as Mp3Encoder).getMp3Array(null,index));
				isDone --;
				if(isDone <=0)
				{					
					var uld:Uploader = new Uploader;
					uld.sendRequest(fh);
					isUpload = false;
				}
			}
			if(isUpload){
				var uld:Uploader = new Uploader;
				uld.sendRequest(fh);
			}
		}
		
		
		
		protected function getParams(event:ControlEvents):void
		{
			var me:ResultEvents = new ResultEvents(ResultEvents.SET_PARAMETERS, true);			
			me.name = event.name;
			switch (event.name) {
				case Variables.VOLUME_OUT:
					me.url = "" +  playlist.vol *100;
					break;
				case Variables.VOLUME_IN:
					
					me.url = "" +  _gain;
					break;
			}
			
			JScontroler.getInstance().dispatchEvent(me);
		}
		
		private function uploadCallback():void {
			
		}
		
		protected function startUpload(event:ControlEvents):void
		{
			// startupload
			var fileHandler:FileHandler = new FileHandler;
			fileHandler.addCallback(uploadCallback);
			for each ( var name:String in event.uploadFile) {
				
			}
		}
		
		protected function uploadUrl(event:ControlEvents):void
		{
			Variables.UPLOAD_URL = event.url;
		}
		
		protected function play(event:ControlEvents):void
		{
			playlist.playSpecial(event.name, event.time);
		}		
		
		protected function showPlaybackProgress(event:ControlEvents):void
		{
			_interval = event.interval;
			if(interValRuning)
				clearInterval(interValProcess);
			interValRuning = false;
			if(_interval > 0) {
				interValRuning = true;
				var ac:ResultEvents = new ResultEvents(ResultEvents.CALLBACK_FUNCTION,true);
				interValProcess=setInterval(activeProcessFunction, _interval);
				function activeProcessFunction() : void{
					JScontroler.getInstance().dispatchEvent(ac);
				}
			}
		}
		
		protected function showNumberOfMicrophone(event:ControlEvents):void
		{
			var ma:ResultEvents = new ResultEvents(ResultEvents.MIC_NUMBER,true);
			ma.micNum = Microphone.names.length;
			JScontroler.getInstance().dispatchEvent(ma);
		}
		
		private var time_mic:Timer = new Timer(1000,1);
		protected function showMicrophone(event:ControlEvents):void
		{
			if(event != null)
				_micNum = event.micNum;
			JScontroler.getInstance().debug("3");
			time_mic.addEventListener(TimerEvent.TIMER_COMPLETE, showSetting_timout);
			_main.stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);				
			addEventListener(MediatorEvent.RESIZED, showSetting);
			time_mic.start();
		}
		
		protected function showSetting_timout(event:TimerEvent):void
		{				
			JScontroler.getInstance().debug("4");
			removeEventListener(MediatorEvent.RESIZED, showSetting);
			time_mic.removeEventListener(TimerEvent.TIMER_COMPLETE, showSetting_timout);
			showSetting(null);
		}
		
		protected function volumeOut(event:ControlEvents):void
		{			
			if(playlist != null)
				playlist.updateVolume(event.volume / 100);
		}
		
		protected function volumeIn(event:ControlEvents):void
		{
			if(_recorder != null) {
				_gain = event.volume;
				_recorder.gain = _gain;
			}
			
		}
		private function stopRecord() :void {
			JScontroler.getInstance().dispatchEvent(new ResultEvents(ResultEvents.STOP_RECORD_JS,true));
		}
		private function startRecord() : void {
			JScontroler.getInstance().dispatchEvent(new ResultEvents(ResultEvents.START_RECORD_JS,true));
		}
		protected function doneStep(event:ControlEvents):void
		{
			this.status = Variables.DONE;
			var isStoping:Boolean = _recorder.stop();
			if(!isStoping) {	
				addCurrentRecordToPlaylist1();
			}
		}
		
		protected function startRecording(event:ControlEvents):void
		{			
			JScontroler.getInstance().dispatchEvent(new ResultEvents(ResultEvents.SHOW_MICSETTING,true));
			if(status == Variables.INITIAL){
				showSetting(null);
				//trace(_main.stage.stageWidth, _main.stage.stageHeight);
			}
			if (encoders.length > 0 )
			{
				if((encoders[curEncoderIndex] as IEncoder).name == event.name)
				{// dang record roi
					try{
						var isStoping:Boolean = _recorder.stop();
						if(!isStoping) {	
							_recorder.record();
							status = Variables.RECORD;
						}else
							status = Variables.RE_RECORD;
						playlist.STOPALL();					
					} catch (e:Error) {}
					//_recorder.record();
					return;
				}
			}
			//trace("new record"  + event.name);
			this.status = Variables.RECORD;
			var iencoder:IEncoder = new Mp3Encoder;
			iencoder.name = event.name;
			encoders.push(iencoder);
			curEncoderIndex =  encoders.length - 1;
			_recorder.startup(iencoder,_gain,_mic,_micNum);
			_recorder.record();
			_recorder.addEventListener(Event.COMPLETE, user_record_done);
			
			timer= new Timer(1000,event.time);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, record_timeout);
			timer.start();
			
		}
		
		private function addCurrentRecordToPlaylist1():void {			
			playlist.AddWavSound((encoders[curEncoderIndex] as IEncoder).getByteArray(),encoders[curEncoderIndex].name);
			PLAY();
			var me:ResultEvents = new ResultEvents(ResultEvents.RECORD_DONE,true);
			me.time = playlist.getSoundTime(encoders[curEncoderIndex].name);
			me.name = encoders[curEncoderIndex].name;
			JScontroler.getInstance().dispatchEvent(me);
			
			(encoders[curEncoderIndex] as IEncoder).addEventListener(Event.COMPLETE, encodeMp3Done);
			(encoders[curEncoderIndex] as IEncoder).encodeMp3();
			//trace("user record done");
		}
		
		private function encodeMp3Done(e:Event):void
		{
			//trace("encode mp3 done");
		}
		
		protected function user_record_done(event:Event):void
		{	
			if (this.status == Variables.DONE)
			{
				addCurrentRecordToPlaylist1();
				JScontroler.getInstance().dispatchEvent(new ResultEvents(ResultEvents.RECORDING_TIMEOUT,true));
			}
			
			if (this.status == Variables.RECORD ||this.status== Variables.RECORDDONE) {
				// use tmp sound	
				if(event == null)
					playlist.AddWaveSoundAndPlay((encoders[curEncoderIndex] as IEncoder).getByteArray(), event == null);
			}
			
			if (this.status == Variables.RE_RECORD) {
				_recorder.record();
				this.status = Variables.RECORD;
			}
		}
		
		protected function record_timeout(event:TimerEvent):void
		{
			doneStep(null);
		}
		
		private function soundCompleteHandler(name:String):void {
			this.status= Variables.READY;
			var ms:ResultEvents = new ResultEvents(ResultEvents.PLAY_DONE, true);
			ms.name = name;
			JScontroler.getInstance().dispatchEvent(ms);
		}
		
		protected function playURL(event:ControlEvents):void
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
		
		protected function replayClick(event:ControlEvents):void
		{
			if(this.status == Variables.RECORD || status== Variables.RECORDDONE){			
				var isStoping:Boolean = _recorder.stop();
				if(!isStoping)
				{			
					// stoped
					user_record_done(null);
				}
			}
			//trace("replay record");
		}
		
		protected function stopRecorder(event:ControlEvents):void
		{
			if(timer != null)
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE,record_timeout);
			try {
				this.status = Variables.RECORDDONE;
				var isStoping:Boolean = _recorder.stop();
				if(!isStoping) {					
					this.status = Variables.READY;
					//addCurrentRecordToPlaylist();
				}
				
			}catch (e:Error)
			{
				this.status = Variables.READY;
			}
			//trace("record done");
		}
		
		//		protected function recordClick(event:ButtonEvents):void
		//		{
		//			if(status == Variables.INITIAL){
		//				if(_main.stage.stageWidth > 150 && _main.stage.stageHeight > 150)
		//					showSetting(null);
		//				else {
		//					_main.stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);				
		//					addEventListener(MainEvents.RESIZED, showSetting);
		//				}
		//				trace(_main.stage.stageWidth, _main.stage.stageHeight);
		//			}
		//			
		//			if(status == Variables.RECORD )
		//			{
		//				try{
		//					var isStoping:Boolean = _recorder.stop();
		//					if(!isStoping) {	
		//						_recorder.record();
		//						this.status = Variables.RECORD;
		//					}else
		//						status = Variables.RE_RECORD;
		//					playlist.STOPALL();					
		//				} catch (e:Error) {}
		//			}
		//			trace("Record click");
		//		}
		
		protected function onStageResize(event:Event):void
		{
			if(event != null)
				_main.stage.removeEventListener(Event.RESIZE, onStageResize);
			dispatchEvent(new MediatorEvent(MediatorEvent.RESIZED,true));
			//trace(_main.stage.stageWidth, _main.stage.stageHeight);
		}
		
		protected function showSetting(event:Event):void
		{
			if(event != null)
				removeEventListener(MediatorEvent.RESIZED, showSetting);
			
			time_mic.removeEventListener(TimerEvent.TIMER_COMPLETE, showSetting_timout);
			var tmp:Mp3Encoder = new Mp3Encoder;
			_recorder.startup(tmp,_gain, _mic,_micNum);
			_recorder.check();			
			_recorder.microphone.addEventListener(StatusEvent.STATUS, this.userAccessMicEvent, false, 0, true); 			
		}
		
		protected function userAccessMicEvent(event:StatusEvent):void
		{
			_recorder.stop();
			var e:ResultEvents = new ResultEvents(ResultEvents.MICROPHONE_ACCESS,true);
			e.micAccess = false;
			if (event.code == "Microphone.Unmuted") 
			{
				e.micAccess = true;
			}
			JScontroler.getInstance().dispatchEvent(e);
			//trace(event);
		}
		
		protected function statusHandler(event:StatusEvent):void
		{
			//trace(event);
		}
		
		protected function activityHandler(event:ActivityEvent):void
		{
			//trace(event);			
		}
		
		
		protected function playClick(event:ControlEvents):void
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