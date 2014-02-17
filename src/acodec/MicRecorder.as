package acodec
{
	
	import acodec.events.RecordingEvent;
	
	import com.common.Variables;
	import com.controler.JScontroler;
	import com.events.ResultEvents;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SampleDataEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.media.Microphone;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import flashx.textLayout.formats.Float;
	
	
	/**
	 * Dispatched during the recording of the audio stream coming from the microphone.
	 *
	 * @eventType org.bytearray.micrecorder.RecordingEvent.RECORDING
	 *
	 * * @example
	 * This example shows how to listen for such an event :
	 * <div class="listing">
	 * <pre>
	 *
	 * recorder.addEventListener ( RecordingEvent.RECORDING, onRecording );
	 * </pre>
	 * </div>
	 */
	[Event(name='recording', type='org.bytearray.micrecorder.RecordingEvent')]
	
	/**
	 * Dispatched when the creation of the output file is done.
	 *
	 * @eventType flash.events.Event.COMPLETE
	 *
	 * @example
	 * This example shows how to listen for such an event :
	 * <div class="listing">
	 * <pre>
	 *
	 * recorder.addEventListener ( Event.COMPLETE, onRecordComplete );
	 * </pre>
	 * </div>
	 */
	[Event(name='complete', type='flash.events.Event')]

	/**
	 * This tiny helper class allows you to quickly record the audio stream coming from the Microphone and save this as a physical file.
	 * A WavEncoder is bundled to save the audio stream as a WAV file
	 * @author Thibault Imbert - bytearray.org
	 * @version 1.2
	 * 
	 */	
	public final class MicRecorder extends EventDispatcher
	{
		private var _gain:uint;	
		private var _rate:uint;
		private var _silenceLevel:uint;
		private var _timeOut:uint;
		private var _difference:uint;
		private var _microphone:Microphone;
		private var _buffer:ByteArray = new ByteArray();
		private var _output:ByteArray;
		private var _encoder:IEncoder;
		private var _completeEvent:Event = new Event ( Event.COMPLETE );
		private var _recordingEvent:RecordingEvent = new RecordingEvent( RecordingEvent.RECORDING, 0 );
		private var _isRecording:Boolean = false;
		private var _startAlert:Function;
		private var _stopAlert:Function;
		private var _micNum:int;
		private var _alowMic:Boolean;
		/**
		 * 
		 * @param encoder The audio encoder to use
		 * @param microphone The microphone device to use
		 * @param gain The gain
		 * @param rate Audio rate
		 * @param silenceLevel The silence level
		 * @param timeOut The timeout
		 * 
		 */		
		public function MicRecorder()
		{
		}
		
		
		public function startup(encoder:IEncoder, gain:uint, microphone:Microphone ,micNum:Number, rate:uint=44, silenceLevel:uint=0, timeOut:uint=4000) :void
		{
			_encoder = encoder;
			_microphone = microphone;
			_gain = gain;
			_rate = rate;
			_silenceLevel = silenceLevel;
			_timeOut = timeOut;
			_micNum = micNum;
			_alowMic = false;
		}
		
		public function check():void {
			
			if ( _microphone == null ) {
				_microphone = Microphone.getMicrophone(_micNum);
				Security.showSettings(SecurityPanel.DEFAULT);
			}
			
			_alowMic = false;
			if(_isRecording)
				return;
			
			_difference = getTimer();
					
			_microphone.setSilenceLevel(_silenceLevel, _timeOut);
			_microphone.gain = _gain;
			_microphone.rate = _rate;
			_buffer.length = 0;
			
			_microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData1);
			_microphone.addEventListener(StatusEvent.STATUS, onStatus1);
		}
		
		protected function onSampleData1(event:SampleDataEvent):void
		{
			if(!_alowMic)
			{
					var e:ResultEvents = new ResultEvents(ResultEvents.MICROPHONE_ACCESS,true);
					e.micAccess = true;
					JScontroler.getInstance().dispatchEvent(e);
					_alowMic = true;
			}
			_microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData1);	
		}
		
		protected function onStatus1(event:StatusEvent):void
		{
			// TODO Auto-generated method stub
			
		}		
		
		/**
		 * Starts recording from the default or specified microphone.
		 * The first time the record() method is called the settings manager may pop-up to request access to the Microphone.
		 */		
		public function record(check:Boolean = false):void
		{
			if ( _microphone == null ) {
				_microphone = Microphone.getMicrophone(_micNum);
			}
			
			//_alowMic = false;
			if(_isRecording)
				return;
			
			 
			_difference = getTimer();
			
			_microphone.setSilenceLevel(_silenceLevel, _timeOut);
			_microphone.gain = _gain;
			_microphone.rate = _rate;
			_buffer.length = 0;
			
			_microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			_microphone.addEventListener(StatusEvent.STATUS, onStatus);
			
			_isRecording = true;
			if(!check)
				_startAlert();
			
			var t:Timer = new Timer(1000,3);
			t.addEventListener(TimerEvent.TIMER_COMPLETE, twosecondwithnodata);
			t.start();
		}
		
		protected function twosecondwithnodata(event:TimerEvent):void
		{
			if(_alowMic)
				return;
			var e:ResultEvents = new ResultEvents(ResultEvents.MICROPHONE_ACCESS,true);
			e.micAccess = false;
			JScontroler.getInstance().dispatchEvent(e);
			
		}
		
		
		private function onStatus(event:StatusEvent):void
		{
			_difference = getTimer();
		}
		
		/**
		 * Dispatched during the recording.
		 * @param event
		 */		
		private function onSampleData(event:SampleDataEvent):void
		{
			if(!_alowMic)
			{
				var e:ResultEvents = new ResultEvents(ResultEvents.MICROPHONE_ACCESS,true);
				e.micAccess = true;
				JScontroler.getInstance().dispatchEvent(e);
				_alowMic = true;
			}
			_recordingEvent.time = getTimer() - _difference;
			
			dispatchEvent( _recordingEvent );
			
			while(event.data.bytesAvailable > 0)
				_buffer.writeFloat(event.data.readFloat());
		}
		
		/**
		 * Stop recording the audio stream and automatically starts the packaging of the output file.
		 */		
		public function stop(check:Boolean = false):Boolean
		{
			if(!_isRecording)
				return false;
			try{
			_microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);		
			_encoder.addEventListener(Event.COMPLETE, completeHandler);	
			_buffer.position = 0;		
			_encoder.encode(_buffer, 1);
			trace(_buffer.length);
			_isRecording = false;	
			if(!check)
				_stopAlert();
			} catch (e:Error)
			{
				trace(e);
				return false;
			}
			return true;
		}
		
		private function completeHandler(e:Event):void
		{
			_encoder.removeEventListener(Event.COMPLETE, completeHandler);
			//_output = _encoder.getByteArray();			
			dispatchEvent( _completeEvent );
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get gain():uint
		{
			return _gain;
		}

		/**
		 * 
		 * @param value
		 * 
		 */		
		public function set gain(value:uint):void
		{
			_gain = value;
		}

		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get rate():uint
		{
			return _rate;
		}

		/**
		 * 
		 * @param value
		 * 
		 */		
		public function set rate(value:uint):void
		{
			_rate = value;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get silenceLevel():uint
		{
			return _silenceLevel;
		}

		/**
		 * 
		 * @param value
		 * 
		 */		
		public function set silenceLevel(value:uint):void
		{
			_silenceLevel = value;
		}


		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get microphone():Microphone
		{
			return _microphone;
		}

		/**
		 * 
		 * @param value
		 * 
		 */		
		public function set microphone(value:Microphone):void
		{
			_microphone = value;
		}

		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get output():ByteArray
		{
			return _output;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public override function toString():String
		{
			return "[MicRecorder gain=" + _gain + " rate=" + _rate + " silenceLevel=" + _silenceLevel + " timeOut=" + _timeOut + " microphone:" + _microphone + "]";
		}
		
		public function addCallBack(stopRecord:Function, startRecord:Function):void
		{
			_startAlert = startRecord;
			_stopAlert = stopRecord;
		}
	}
}