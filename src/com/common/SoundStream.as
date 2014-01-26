package com.common
{
	import flash.events.IEventDispatcher;
	import flash.media.SoundTransform;
	
	public interface SoundStream extends IEventDispatcher
	{
		function startup(obj:Object):void;
		function play(startTime:Number = 0, loops:int = 0, sndTransform:SoundTransform = null):void;
		function pause():void;
		function stop():void;
		function checkStream(callback:Function):void;
		function updateVolume(vol:Number):void;
		function getName():String;
		function timeTotal():Number;
	}
}