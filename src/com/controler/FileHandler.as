package com.controler
{
	import deng.fzip.FZip;
	
	import flash.utils.ByteArray;

	public class FileHandler
	{
		private var _zip:FZip;
		
		private var zipByteArr:ByteArray = new ByteArray();
		public function FileHandler()
		{
			_zip = new FZip;
		}
		
		public function get zip():FZip
		{
			return _zip;
		}

		public function addFile(name:String, data:Object) : void {
			zip.addFile(name,data as ByteArray);
		}
		
		public function addCallback(uploadCallback:Function):void
		{
			
		}
		
		public function getByteArray():ByteArray
		{
			zipByteArr.length = 0;
			zip.serialize(zipByteArr);
			zipByteArr.position = 0;
			return zipByteArr;
			
		}
		
		public function getFileVO():Object
		{
			// TODO Auto Generated method stub
			return null;
		}
	}
}