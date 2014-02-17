package com.events
{
	import flash.events.Event;
	
	public class ResultEvents extends Event
	{
		
		public static const MICROPHONE_ACCESS:String 	 = "microphoneAccess";	
		public static const PLAY_DONE:String 	 = "playDone";
		public static const RECORD_DONE:String 	 = "saveRecordingDone";		
		public static const SHOW_MICSETTING:String = "userClickRecord";		
		public static const STARTUP:String = "flashLoaded";	
		public static const START_RECORD_JS:String = "startRecordingJs";
		public static const STOP_RECORD_JS:String = "stopRecordingJS";			
		public static const MIC_NUMBER:String = "micNumber";
		public static const CALLBACK_FUNCTION:String = "playbackProgress";
		public static const SET_PARAMETERS:String = "setParameters";
		public static const RECORDING_TIMEOUT:String = "recordingTimeout";
		public static var PUSH_SOUND:String = "pushSounds";
		public static const GET_PARAMETERS:String = "getParameters";
		public static const START_RECORD:String = "startRecording";	
		public static const STOP_RECORD:String = "stopRecording";	
		public var micAccess:Object;
		public var name:Object;
		public var time:Object;
		
		public var url:Object;
		public var micNum:Object;
		public function ResultEvents(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}