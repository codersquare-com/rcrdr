package acodec
{	
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;

	public interface IEncoder extends IEventDispatcher
	{
		function encode(samples:ByteArray, channels:int=2, bits:int=16, rate:int=44100):void;
		function getByteArray():ByteArray;
		function encodeMp3():void;
		function get name():String;
		function set name(n:String):void;
	}
	
}