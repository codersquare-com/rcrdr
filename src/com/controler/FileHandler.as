package com.controler
{
	import deng.fzip.FZip;
	
	import flash.utils.ByteArray;

	public class FileHandler
	{
		private var zip:FZip;
		
		public function FileHandler()
		{
			zip = new FZip;
		}
		
		public function addFile(name:String, data:Object) : void {
			zip.addFile(name,data as ByteArray);
		}
		
		public function addCallback(uploadCallback:Function):void
		{
			
		}
	}
}