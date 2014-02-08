package com.events
{
	import flash.events.Event;
	
	public class ButtonEvents extends Event
	{
		public static const PLAY_CLICK:String 	 = "playClick";
		public static const RECORD_CLICK:String 	 = "recordClick";
		public static const RECORD_DONE_CLICK:String 	 = "stopRecordClick";
		public static const REPLAY_CLICK:String 	 = "replayClick";
		public static var SHOW_MICROPHONE:String = "showMicrophone";
		public function ButtonEvents(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}