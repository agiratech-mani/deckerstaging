package
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	
	import net.avchat.utils.CustomEvent;

	public class SettingsBox extends Sprite
	{
		private var bg:Sprite;
		private var _deviceArray:Array;
		private var _radios:Array = new Array();
		private var _deviceIndex:Number = 0;
		private var _type:String ="";
		
		public function SettingsBox(type:String, selectedDevice:String = "0", textColor:uint = 0x333333, bgColor:uint = 0xb4e0e3, cornerRadius:Number = 8, isPPAPI:Boolean = false)
		{
			bg = new Sprite();
				
			_deviceArray = new Array();
			_type = type;
			
			if(type == "cam"){
				for(var i:String in Camera.names){
					_deviceArray[i] = Camera.names[i];
				}
			}else if(type == "mic"){
	
				if(isPPAPI == false){
					for(var j:String in Microphone.names){
						_deviceArray[j] = Microphone.names[j];
						if( Microphone.names[j] == "Default"){
							_deviceArray[j] = "Default OS Input Source";
						}
					}
				}else{
					_deviceArray[0] = "Default OS Input Source";
				}
			}
			
			this.addChild(bg)
			
			var k:Number = 0;
			var nextY:Number = 10;
			for(var t:String in _deviceArray){
				_radios[k] = new CustomRadioBtn(_deviceArray[t],textColor,0,k);
				bg.addChild(_radios[k]);
				_radios[k].addEventListener(MouseEvent.CLICK, onSelect);
				_radios[k].x = 20;
				_radios[k].y = 10 + nextY;
				nextY +=20;
				k++;
			}
			
			if(_radios[int(selectedDevice)] && isPPAPI == false){
				_radios[int(selectedDevice)].selected = true;	
			}else{
				_radios[0].selected = true;
			}
			
			var theHeight:Number = _radios[_deviceArray.length - 1].y + 20;
			
			bg.graphics.beginFill(bgColor,1);
			bg.graphics.drawRoundRect(0,0,235,theHeight,cornerRadius);
			bg.graphics.moveTo(235-17,theHeight);
			bg.graphics.lineTo(235-10,theHeight + 5);
			bg.graphics.lineTo(235-5,theHeight);
			bg.x = -(235-15);
			
		}
		
		private function onSelect(e:MouseEvent):void{
			
			for(var i:Number = 0; i< _deviceArray.length; i++){
				_radios[i].selected = false;
			}
			
			e.currentTarget.selected = true;
			_deviceIndex = e.currentTarget.index;
			
			var data:Object = new Object();
			data["type"] = _type;
			
			if(_type == "cam"){
				data["camIndex"] = _deviceIndex;
				dispatchEvent(new CustomEvent("CAM_SETTINGS_SUBMITED",data));
			}else{
				data["micIndex"] = _deviceIndex;
				dispatchEvent(new CustomEvent("MIC_SETTINGS_SUBMITED",data));
			}
			
		}
		
	}
}