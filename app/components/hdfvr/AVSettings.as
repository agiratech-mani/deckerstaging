package
{
	import fl.lang.Locale;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import net.avchat.ui.*;
	import net.avchat.utils.*;
	
	public class AVSettings extends Sprite{
		
		private var _spBackground:Sprite;
		private var _nBgWidth:Number = 300;
		private var _nBgHeight:Number = 220;
		
		private var _cameraNames:Array;
		private var _microphoneNames:Array;
		
		private var _tfCamLabel:TextField;
		private var _tfMicLabel:TextField;
		
		private var _btContinue:CustomButton;
		
		private var _selectedCam:String = "0";
		private var _selectedMic:String = "0";
		
		private var _textFormat:TextFormat;
		private var _bgColor:uint;
		private var _cornerRadius:Number;
		private var _iconFilter:DropShadowFilter;
		
		private var _radiosCams:Array = new Array();
		private var _radiosMics:Array = new Array();
		private var _nextY:Number = 0;
		private var _cameraIndex:Number = 0;
		private var _microphoneIndex:Number = 0;
		
		[Embed(source="../assets/icons/webcam_big.png")]
		private var webcam:Class;
		private var webcam_icon:Bitmap;
		
		[Embed(source="../assets/icons/mic_big.png")]
		private var mic:Class;
		private var mic_icon:Bitmap;
		
		public function AVSettings(selectedCam:String = "0", selectedMic:String = "0", textColor:uint = 0x333333, bgColor:uint = 0xb4e0e3, overColor:uint = 0xdf8f90, cornerRadius:Number = 16, _isPPAPIonOSX:Boolean = false, disableMics:Boolean = false){
			super();
			
			_textFormat = new TextFormat("_sans",14,textColor,null,null,null,null,null,TextFormatAlign.LEFT);
			_iconFilter = new DropShadowFilter(30,0,textColor,1,0,0,1,1,true);
			_bgColor = bgColor;
			_cornerRadius = cornerRadius;
			
			_selectedCam = selectedCam;
			_selectedMic = selectedMic;
			
			_cameraNames = new Array();
			_microphoneNames = new Array(); 
			
			for(var i:String in Camera.names ){
				trace("i="+i+" = "+Camera.names[i])
				_cameraNames[i] = Camera.names[i];
			}
			
			if(_isPPAPIonOSX == true){
				//if this is the PPAPI version of Flash Player (Chrome and Opera) on macOS we only show only the default input source (it maps to the OS' input settings) since selecting any other has no effect
				_microphoneNames[0] = "Default OS Input Source";
			}else{
				for(var s:String in Microphone.names ){
					trace("s="+s+" = "+Microphone.names[s])
					_microphoneNames[s] = Microphone.names[s];
					//change the name on systems using the English language, in other languages other strings are used 
					if( Microphone.names[s] == "Default"){
						_microphoneNames[s] = "Default OS Input Source";
					}
				}
			}
			
			
			
			if(!_spBackground){
				_spBackground = new Sprite();
				addChild(_spBackground);
			}
			
			if(!_tfCamLabel &&  Camera.names.length > 0){
				_tfCamLabel = new TextField();
				_spBackground.addChild(_tfCamLabel);
				
				webcam_icon = new webcam();
				_spBackground.addChild(webcam_icon);
				webcam_icon.filters = [_iconFilter];
			}
			
			if(Camera.names.length > 0){
				_tfCamLabel.autoSize=TextFieldAutoSize.LEFT;
				_tfCamLabel.defaultTextFormat = _textFormat;
				if(Locale.loadString("IDS_TXT_CHOOSECAM")){
					_tfCamLabel.text= Locale.loadString("IDS_TXT_CHOOSECAM")
				}else{
					_tfCamLabel.text= "Select Webcam"
				}
				_tfCamLabel.selectable=false;
				_tfCamLabel.multiline=false;
			}			
			
			var k:Number = 0;
			if(Camera.names.length > 0){
				for(var t:String in _cameraNames){
					_radiosCams[k] = new CustomRadioBtn(_cameraNames[t],textColor,1,k);
					_spBackground.addChild(_radiosCams[k]);
					_radiosCams[k].addEventListener(MouseEvent.CLICK, onSelect);
					k++;
				}
				
				if(_radiosCams[int(_selectedCam)]){
					_radiosCams[int(_selectedCam)].selected = true;	
				}else{
					_radiosCams[0].selected = true;
				}
				
			}
			
			
			
			if(!_tfMicLabel){
				_tfMicLabel = new TextField();
				mic_icon = new mic();
				if (disableMics==false){
					_spBackground.addChild(_tfMicLabel);
					_spBackground.addChild(mic_icon);
				}
				mic_icon.filters = [_iconFilter];
			}
			_tfMicLabel.autoSize=TextFieldAutoSize.LEFT;
			_tfMicLabel.defaultTextFormat = _textFormat;
			if(Locale.loadString("IDS_TXT_CHOOSEMIC")){
				_tfMicLabel.text= Locale.loadString("IDS_TXT_CHOOSEMIC")
			}else{
				_tfMicLabel.text= "Select Microphone"
			}
			_tfMicLabel.selectable=false;
			_tfMicLabel.multiline=false;
			
			var u:Number = 0;
			if(Microphone.names.length > 0){
				for(var p:String in _microphoneNames){
					_radiosMics[u] = new CustomRadioBtn(_microphoneNames[p],textColor,2,u);
					if (disableMics==false){
						_spBackground.addChild(_radiosMics[u]);
					}
					_radiosMics[u].addEventListener(MouseEvent.CLICK, onSelect);
					u++;
				}
			}
			
			if(_radiosMics[int(_selectedMic)] && _isPPAPIonOSX == false){
				_radiosMics[int(_selectedMic)].selected = true;	
			}else{
				_radiosMics[0].selected = true;
			}
			
			var recText:String = "";
			if(Locale.loadString("IDS_RECORD_CONTINUE")){
				recText = Locale.loadString("IDS_RECORD_CONTINUE");
			}else{
				recText = "Continue";
			}
			
			if(!_btContinue){
				_btContinue = new CustomButton(recText,textColor, overColor);
				_spBackground.addChild(_btContinue);			
				_btContinue.addEventListener(MouseEvent.CLICK, onSubmit);
			}
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event = null):void{
			
			_spBackground.graphics.clear();
			_spBackground.graphics.beginFill(_bgColor, 1);
			_spBackground.graphics.drawRoundRect(0, 0, stage.stageWidth, stage.stageHeight,_cornerRadius);
			_spBackground.graphics.endFill();
			
			_nextY = 0;
			
			if(Camera.names.length > 0){
				
				webcam_icon.y = stage.stageHeight/2 - 115;
				webcam_icon.x = stage.stageWidth/2 - 140;
				
				_tfCamLabel.y = webcam_icon.y + 5;
				_tfCamLabel.x = webcam_icon.x + webcam_icon.width;
				
				_nextY = webcam_icon.y + webcam_icon.height + 10;
				for(var j:Number = 0; j < _radiosCams.length; j++){
					if(_radiosCams[j].getGroup() == 1){
						_radiosCams[j].x = webcam_icon.x + 15;
						_radiosCams[j].y = _nextY;
						_nextY += 20;
					}
				}
				
				mic_icon.y = _radiosCams[_radiosCams.length-1].y + 20;
				mic_icon.x = webcam_icon.x;	
			}else{
				mic_icon.y = stage.stageHeight/2 - 115;
				mic_icon.x = stage.stageWidth/2 - 140;
			}
			
			
			
			
			_tfMicLabel.y = mic_icon.y + 5;
			_tfMicLabel.x = mic_icon.x + mic_icon.width;
			
			_nextY = mic_icon.y + mic_icon.height + 10;
			for(var k:Number = 0; k < _radiosMics.length; k++){
				if(_radiosMics[k].getGroup() == 2){
					_radiosMics[k].x = mic_icon.x + 15;
					_radiosMics[k].y = _nextY;
					_nextY += 20;
				}
			}
			
			_btContinue.y = stage.stageHeight/2 + 85;
			_btContinue.x = (stage.stageWidth - _btContinue.width)/2;
			
		}
		
		
		public function setComboBoxWidth(_w:Number):void{
			_nBgWidth = _w;
		}
		
		public function setComboBoxHeight(_h:Number):void{
			_nBgHeight = _h;
		}
		
		public function onSubmit(e:Event =  null):void{
			
			var data:Object = new Object();
			if(Camera.names.length > 0){
				data["camIndex"] = _cameraIndex;
			}else{
				data["camIndex"] = 0;
			}
			data["micIndex"] = _microphoneIndex;
			dispatchEvent(new CustomEvent("SETTINGS_SUBMITED",data));
		}
		
		public function onResize():void{
			
			_spBackground.graphics.clear();
			_spBackground.graphics.beginFill(_bgColor, 1);
			_spBackground.graphics.drawRoundRect(0, 0, stage.stageWidth, stage.stageHeight,_cornerRadius);
			_spBackground.graphics.endFill();
			
			if(Camera.names.length > 0){
				
				webcam_icon.y = stage.stageHeight/2 - 115;
				webcam_icon.x = stage.stageWidth/2 - 140;
				
				_tfCamLabel.y = webcam_icon.y + 5;
				_tfCamLabel.x = webcam_icon.x + webcam_icon.width;
				
				_nextY = webcam_icon.y + webcam_icon.height + 10;
				for(var j:Number = 0; j < _radiosCams.length; j++){
					if(_radiosCams[j].getGroup() == 1){
						_radiosCams[j].x = webcam_icon.x + 15;
						_radiosCams[j].y = _nextY;
						_nextY += 20;
					}
				}
				
			}
			
			
			mic_icon.y = _radiosCams[_radiosCams.length-1].y + 20;
			mic_icon.x = webcam_icon.x;	
			
			_tfMicLabel.y = mic_icon.y + 5;
			_tfMicLabel.x = mic_icon.x + mic_icon.width;
			
			_nextY = mic_icon.y + mic_icon.height + 10;
			for(var k:Number = 0; k < _radiosMics.length; k++){
				if(_radiosMics[k].getGroup() == 2){
					_radiosMics[k].x = mic_icon.x + 15;
					_radiosMics[k].y = _nextY;
					_nextY += 20;
				}
			}
			
			_btContinue.y = stage.stageHeight/2 + 100;
			_btContinue.x = (stage.stageWidth - _btContinue.width)/2;			
			
		}
		
		private function onSelect(e:MouseEvent):void{
			trace("onSelect "  + e.currentTarget.getGroup());
					
			if(e.currentTarget.getGroup() == 1){
				for(var i:Number = 0; i< _radiosCams.length; i++){
					_radiosCams[i].selected = false;
					_cameraIndex = e.currentTarget.index;
				}
			}else if(e.currentTarget.getGroup() == 2){
				for(var j:Number = 0; j< _radiosMics.length; j++){
					_radiosMics[j].selected = false;
					_microphoneIndex = e.currentTarget.index;
				}
			}
			
			e.currentTarget.selected = true;
			
		}
	}
}