package com.events
{
	import flash.events.Event;
	
	public class MediatorEvent extends Event
	{
		public static var RESIZED:String = "mediatorResize";
		public function MediatorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}