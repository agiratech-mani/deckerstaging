package {
	
	import com.adobe.images.JPGEncoder;
	
	import fl.controls.Button;
	import fl.controls.TextInput;
	import fl.lang.Locale;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.AsyncErrorEvent;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SampleDataEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.H264Level;
	import flash.media.H264Profile;
	import flash.media.H264VideoStreamSettings;
	import flash.media.Microphone;
	import flash.media.SoundCodec;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.navigateToURL;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import net.avchat.ui.SoundLevelDisplay;
	import net.avchat.utils.ApplicationData;
	import net.avchat.utils.CustomEvent;
	import net.avchat.utils.Strings;
	
	[SWF(width=320, height=240, backgroundColor="0xeeeeee", frameRate="30")]
	
	public class VideoRecorder extends Sprite
	{
		//embedding some external images
		[Embed(source="../assets/icons/outer-ring.png")]
		public var icon_record:Class;
		
		[Embed(source="../assets/icons/play_small.png")]
		public var icon_play:Class;
		
		[Embed(source="../assets/icons/outer-ring.png")]
		public var icon_stop:Class;
		
		[Embed(source="../assets/icons/pause_small.png")]
		public var icon_pause:Class;
		
		[Embed(source="../assets/icons/save_small.png")]
		public var icon_disk:Class;
		
		[Embed(source="../assets/icons/webcam_small.png")]
		public var icon_cam:Class;
		
		[Embed(source="../assets/icons/mic_small.png")]
		public var icon_mic:Class;
		
		[Embed(source="../assets/icons/audioOnly.png")]
		public var icon_audioOnly:Class;
		
		//wether or not the user is allowed to use HD video
		private var _hdAcces:Boolean = false;
		
		//text format objects
		public var tfNormal:TextFormat;
		public var tfHeader:TextFormat;
		public var tfLabel:TextFormat;
		
		//lots of other vars
		public var qualityurl:String; //the path to the xml file containing audio video quality settings, if specified via flashvar
		public var nc:NetConnection;//net connection to the media server
		public var nc2:NetConnection;//net connection to the media server
		
		public var ns:NetStream; //net stream through which the recording and playback is done
		public var nss:NetStream; //net stream through which the playback for wowza+transcoder is done
		public var xmlStreamSettings:XML;
		private var languageXMLIsLoaded:Boolean = false;
		public var didTheConnEverSucceed:Boolean = false;
		public var wasTheConnectionRejected:Boolean = false;
		private var responder:Responder;
		private var deleteUnsavedFlv:Boolean = true;
		private var recordAgain:Boolean = true;
		private var buffering:Boolean = false;
		private var camTimerCount:Number = 0;
		private var _intialBufferLength:Number = 0;
		private var _timeElapsed:Number = 0; 
		private var _snapshotEnabled:Boolean = true;
		private var _userPrefix:String = "";
		private var _streamPrefix:String = "";
		private var _disableMicrophoneRecording:Boolean = false;
		private var _chmodStream:String = "";
		private var estimatedTimeAux:Number = 9999999999999; 
		private var _playBackBuffer:Number = 10;
		private var _lastDuration:Number = 0;
		private var _snapShotSec:Number = 0;
		private var _curentSnapshots:Number = 0;
		private var _limitDuration:Number = 120;
		private var _minDuration:Number = 0;
		public var nextStep:String=""
		public var _state:String ="idle"
		public var _previousState:String="";
		private var lastOnStatusEventCode:String;
		private var _streamName:String="";
		private var _fixedName:Boolean = false;
		private var _timer:Timer
		private var recorderId:String=""
		private var _actualStreamTime:Number = 0;
		private var _lastStreamTime:Number = 0;
		private var _streamSettingsLoaded:Boolean = false;
		private var _hdfvrStarted:Boolean = false;
		private var _cm:ContextMenu;
		private var _payload:String = "";
		private var _autoSave:Boolean = false;
		private var _auth_token:String = "";
		public var bringupFPPrivacyHelper:Boolean = false;
		public var fpPrivacyDialogWasShown:Boolean = false;
		private var bringUpDeviceSelector:Boolean;
		private var _isPPAPIonOSX:Boolean = false;
		private var _skipInitialScreen:Boolean = false;
		//private var _justDuplicateMicrophone:Boolean = false;
		private var _langFilePath:String;
		private var _hideDeviceSettingsButtons:Boolean = false;
		private var _showPipeCopyright:Boolean = false;
		private var _showPipeAd:Boolean = false;
		private var _maintenance:Boolean = false;
				
		//UI data
		private var showFps:Boolean= false;
		private var autoPlay:Boolean = false;
		private var _ratio:Number;
		private var _nrOfRows:Number=1;
		private var _nrOfColumns:Number=1;	
		private var _menuColor:uint = 0x666666;
		private var roundedCorner:Number = 30;
		private var bgColor:uint = 0xdddddd;
		private var _normalColor:uint = 0x333333;
		private var _overColor:uint = 0xdf8f90;
				
		//UI elements
		private var _spSuperMask:Sprite;
		private var _glowFilter:GlowFilter;
		private var _watermarkLoader:Loader; //the loader for the watermark
		private var _video:Video; //the main vide area used for recording. We use a second video area for playback to keep the Camera always active. With one video area the Camera is released during playback and then if the user records another video it will take a few seconds to acess the Camera gaina resulting in a black video lasting for 1-2 seconds. 
		private var _videoPlayback:Video; //the second video area , used for playback
		private var _lastFrame:Bitmap;
		private var _alertBox:AlertBox;
		private var _sVideoArea:Sprite; //surface behind video
		private var _recorderContainer:Sprite; //container for all elements 
		private var _videoArray:Array;
		private var _fpsCounter:TextField;
		private var _txTime:TextField;
		private var _btRecordAndStop:MyButton;
		private var _btStop:MyButton;
		private var _btPlay:MyButton;
		private var _btSave:MyButton;
		private var _btCamSettings:MyButton;
		private var _btMicSettings:MyButton;
		private var _spMenuContainer:Sprite;
		private var _sld:SoundLevelDisplay;
		private var _spBg:Sprite;
		private var _recSprite:Sprite;		
		private var _scrubBar:ScrubBar;
		private var _tt:ToolTip
		private var _FSDeviceSelector:AVSettings;
		private var _h264Enabled:Boolean = false;
		private var _mediaServer :Number = 1;
		private var _audioCodec:String = "ASAO";
		private var _showTimer:Boolean = true;
		private var _showSoundBar:Boolean = true;
		private var _mirrorVideoStreamDuringRecording:Boolean = false;
		private var _allowAudioOnlyRecording:Boolean = false;
		private var _hasCam:Boolean = true;
		private var audioOnlyIcon:Bitmap;
		private var _enableFFMPEGConverting:Boolean = false;
		private var _ffmpegCmd:String = "";
		private var _accountHash:String = "";
		private var _environmentId:Number = 1;
		private var _showMenu:Boolean = true;
		private var _startingBgColor:Sprite;
		private var _spriteFPPrivacyHelper:Sprite;
		private var _initRecordBtn:CustomButton;
		private var _txtPrivacy1:TextField;
		private var _txtPrivacy2:TextField;
		private var _txtPrivacy3:TextField;
		private var _lines:Sprite;
		private var _fpsTracker:Sprite;
		private var _camOrMicSettings:SettingsBox;
		private var _byPipeText:TextField;
		private var _pipeAd:TextField;
		private var _maintenanceText:TextField;
		private var _proxyType:String = "none";
		
		//cam and mic
		private var _camera:Camera;
		private var _cameraSelected:Boolean = false;
		private var _mic:Microphone;
		private var _micSelected:Boolean = false;
		
		private var PADDING:Number   = 0;
		private const DEFAULT_VIDEO_HEIGHT:Number 	= 240;
		private const DEFAULT_VIDEO_WIDTH  :Number	= 320;
		private const DEFAULT_AUDIO_HEIGHT:Number 	= 100;
		private const DEFAULT_AUDIO_WIDTH:Number  	= 250;
		private const BUTTON_HEIGHT :Number		= 30;
		private const BUTTON_WIDTH  :Number		= 30;
		private const BUTTON_PADDING :Number	= 1;
		
		//media server variables
		private const FMS:int 	= 1;
		private const WOWZA:int = 2;
		private const RED5:int  = 3;
		private const WOWZA_TRANSCODER:int = 4;
		
		//snapshot variables
		private var jpgSource:BitmapData ;
		private var jpgEncoder:JPGEncoder;
	    private var jpgStream:ByteArray ;
		private var mySharedObject:SharedObject
		
		//Flash Player version & build number
		private var majorVersion:Number ;
		private var minorVersion:Number ;
		private var buildNumber:Number ;
		
		public function VideoRecorder()
		{
			
			//videorecorder extends sprite so we call the super function
			super();
			
			//get local shared object
			mySharedObject = SharedObject.getLocal("cammicsettings");
			
			//we find out the Flash Player version
			var versionNumber:String = Capabilities.version;
			
			// The version number is a list of items divided by “,”
			var versionArray:Array = versionNumber.split(",");
			var length:Number = versionArray.length;
			
			// The main version contains the OS type too so we split it in two
			// and we’ll have the OS type and the major version number separately.
			var platformAndVersion:Array = versionArray[0].split(" ");
			
			majorVersion = parseInt(platformAndVersion[1]);
			minorVersion = parseInt(versionArray[1]);
			buildNumber = parseInt(versionArray[2]);
			
			//setting up a new text format
			tfNormal = new TextFormat();
			tfNormal.font = "_sans";
			tfNormal.color = 0x666666;
			tfNormal.size = 12;
			tfNormal.bold = true;
			tfNormal.align = "center"
			
			//setup a new header label text format
			tfHeader = new TextFormat();
			tfHeader.font = "_sans";
			tfHeader.color = 0x000000;
			tfHeader.size = 16;
			tfHeader.bold = true;
			tfHeader.align = "center"
			
			//setup a new label format
			tfLabel = new TextFormat();
			tfLabel.font = "_sans";
			tfLabel.color = 0x000000;
			tfLabel.size = 12;
			tfLabel.bold = true;
			tfLabel.italic = true;
			tfLabel.align = "center"
			
			//we hide some of the items in the context menu
			_cm = new ContextMenu();
			_cm.hideBuiltInItems();
			
			//we add the build number to the context menu
            var cmi:ContextMenuItem = new ContextMenuItem("HDFVR v2.2");
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, openLink);
            _cm.customItems.push(cmi);
            contextMenu = _cm;
            
			//scaling and size, no scale align top left
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.HIGH;
			
			//glow filter, used later
            _glowFilter = new GlowFilter(0x000000,1,2,2,3,1);
            
            //some variables can be sent via flash vars:
			
			//the qualityurl flash var specifies the path to the XML file containing video quality settings
            if(LoaderInfo(root.loaderInfo).parameters.qualityurl){
            	qualityurl = LoaderInfo(root.loaderInfo).parameters.qualityurl;
            }
            
			//check if we need to switch to ASP or ASPX or anything else
            if (LoaderInfo(root.loaderInfo).parameters.sscode!=null && LoaderInfo(root.loaderInfo).parameters.sscode!=undefined && LoaderInfo(root.loaderInfo).parameters.sscode!=""){
            	ApplicationData.getInstance().sscode=LoaderInfo(root.loaderInfo).parameters.sscode;
            }
			
			//check if we have a recorderId
			if (LoaderInfo(root.loaderInfo).parameters.recorderId!=null && LoaderInfo(root.loaderInfo).parameters.recorderId!=undefined && LoaderInfo(root.loaderInfo).parameters.recorderId!=""){
				recorderId=LoaderInfo(root.loaderInfo).parameters.recorderId;
			}
			
			//the default "Loading..." text can also be changed
			var loadingSettingsText:String = "Loading...";
			if (LoaderInfo(root.loaderInfo).parameters.lstext!=null && LoaderInfo(root.loaderInfo).parameters.lstext!=undefined && LoaderInfo(root.loaderInfo).parameters.lstext!=""){
				loadingSettingsText=LoaderInfo(root.loaderInfo).parameters.lstext;
			}
			
			//accountHash is used by some HDFVR integrations
			if(LoaderInfo(root.loaderInfo).parameters.accountHash){
				_accountHash = LoaderInfo(root.loaderInfo).parameters.accountHash;
			}
			
			//eid is used by some HDFVR integrations
			if(LoaderInfo(root.loaderInfo).parameters.eid){
				_environmentId = LoaderInfo(root.loaderInfo).parameters.eid;
			}
			
			//authenticity_token is used in some Ruby on Rails integrations
			if(LoaderInfo(root.loaderInfo).parameters.authenticity_token && LoaderInfo(root.loaderInfo).parameters.authenticity_token != undefined){
				_auth_token = LoaderInfo(root.loaderInfo).parameters.authenticity_token;
			}
			
            //new alert box showing the loading message
            _alertBox =  new AlertBox();
            _alertBox.setTextLabel(loadingSettingsText,true);
          	positionAlertBox();
         	addChild(_alertBox);
            
            //load the avc_settings.xxx file
			loadGeneralSettings();
			
			//disconnectAndRemove is used to prevent the web-cam remaining active on Internet Explorer
			if( ExternalInterface.available ){
				ExternalInterface.addCallback("disconnectAndRemove", disconnectAndRemove);  
			}
			
			//verify is Flash Player is of PPAPI variety on Mac
			if(ExternalInterface.available){
				if(Capabilities.os.indexOf("Mac") != -1){
					_isPPAPIonOSX = ExternalInterface.call("getFlashPlayerType");
					trace("Is PPAPI Flash Player on macOS " + _isPPAPIonOSX);
				}
			}
		}
		
		public function loadGeneralSettings():void {
			trace("HDFVR.loadGeneralSettings()")
			
			//build request for avc_settings.xxx
			var request:URLRequest;
			if(_accountHash != ""){
				request = new URLRequest("avc_settings."+ApplicationData.getInstance().sscode+"?r="+Math.random()+"&recorderId="+recorderId+"&accountHash="+_accountHash);	
			}else{
				request = new URLRequest("avc_settings."+ApplicationData.getInstance().sscode+"?r="+Math.random()+"&recorderId="+recorderId);
			}
			request.method = URLRequestMethod.GET;
			
			//load the settings file
			var settingsLoader:URLLoader = new URLLoader();
			settingsLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
			settingsLoader.addEventListener(Event.COMPLETE, onGeneralSettingsLoaded);
			settingsLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus)
			settingsLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			settingsLoader.load(request);
			
		}
		
		//this function is called after avc_settings.xxx executes and the result is loaded by HDFVR
		private function onGeneralSettingsLoaded(event:Event):void{
			trace("HDFVR.onGeneralSettingsLoaded("+event+")");
			for (var i:* in event.target.data) {
				ApplicationData.getInstance().avc_settings[i] = event.target.data[i];
			}
			
			//userId can be sent via flashvars or via avc_settings
			if (ApplicationData.getInstance().avc_settings["userId"]=="" || ApplicationData.getInstance().avc_settings["userId"]==undefined || ApplicationData.getInstance().avc_settings["userId"]==null){
				ApplicationData.getInstance().avc_settings["userId"]=""
				if (LoaderInfo(root.loaderInfo).parameters.userId!=null && LoaderInfo(root.loaderInfo).parameters.userId!=undefined && LoaderInfo(root.loaderInfo).parameters.userId!=""){
					ApplicationData.getInstance().avc_settings["userId"]=LoaderInfo(root.loaderInfo).parameters.userId
				}
			}
			
			//at which second should we take the snapshot
			if(ApplicationData.getInstance().avc_settings["snapshotSec"]){
				_snapShotSec = ApplicationData.getInstance().avc_settings["snapshotSec"];
			}
			
			//bg color
			if(LoaderInfo(root.loaderInfo).parameters.bgCol && LoaderInfo(root.loaderInfo).parameters.bgCol !="" && LoaderInfo(root.loaderInfo).parameters.bgCol !=undefined){
				bgColor = uint(LoaderInfo(root.loaderInfo).parameters.bgCol);
			}else if(ApplicationData.getInstance().avc_settings["backgroundColor"]){
				//setBgColor(ApplicationData.getInstance().avc_settings["backgroundColor"]);
				bgColor = uint(ApplicationData.getInstance().avc_settings["backgroundColor"]);
			}
			
			//text color
			if(LoaderInfo(root.loaderInfo).parameters.normalCol && LoaderInfo(root.loaderInfo).parameters.normalCol !="" && LoaderInfo(root.loaderInfo).parameters.normalCol !=undefined){
				_normalColor = uint(LoaderInfo(root.loaderInfo).parameters.normalCol);
			}else if(ApplicationData.getInstance().avc_settings["normalColor"]){
				_normalColor = uint(ApplicationData.getInstance().avc_settings["normalColor"]);
			}
			
			//over color
			if(LoaderInfo(root.loaderInfo).parameters.overCol && LoaderInfo(root.loaderInfo).parameters.overCol !="" && LoaderInfo(root.loaderInfo).parameters.overCol !=undefined){
				_overColor = uint(LoaderInfo(root.loaderInfo).parameters.overCol);
			}else if(ApplicationData.getInstance().avc_settings["backgroundColor"]){
				_overColor = uint(ApplicationData.getInstance().avc_settings["overColor"]);
			}
			
			//corner radius
			if(LoaderInfo(root.loaderInfo).parameters.cornerradius && LoaderInfo(root.loaderInfo).parameters.cornerradius != undefined && LoaderInfo(root.loaderInfo).parameters.cornerradius != ""){
				setRoundedCorner(Number(LoaderInfo(root.loaderInfo).parameters.cornerradius));
			}else if(ApplicationData.getInstance().avc_settings["radiusCorner"]){
				setRoundedCorner(ApplicationData.getInstance().avc_settings["radiusCorner"]);
			}
			
			//should we show the FPS or not
			if(ApplicationData.getInstance().avc_settings["showFps"]){
				if(ApplicationData.getInstance().avc_settings["showFps"] == "true"){
					showFps = true;
				}
			}
			
			//should we show the timer or not
			if(ApplicationData.getInstance().avc_settings["showTimer"]){
				if(ApplicationData.getInstance().avc_settings["showTimer"] == "false"){
					this._showTimer = false;
				}
			}
			
			//should we show the sound bar or not
			if(ApplicationData.getInstance().avc_settings["showSoundBar"]){
				if(ApplicationData.getInstance().avc_settings["showSoundBar"] == "false"){
					this._showSoundBar = false;
				}
			}
			
			//playback buffr
			if(ApplicationData.getInstance().avc_settings["playbackBuffer"]){
				_playBackBuffer = Number(ApplicationData.getInstance().avc_settings["playbackBuffer"]);
			}
			
			//auto play?
			if(ApplicationData.getInstance().avc_settings["autoPlay"]){
				if(ApplicationData.getInstance().avc_settings["autoPlay"] == "true"){
					autoPlay = true;
				}
			}
			
			//if deleteUnsavedFlv exists and its false
			if(ApplicationData.getInstance().avc_settings["deleteUnsavedFlv"]){
				if(ApplicationData.getInstance().avc_settings["deleteUnsavedFlv"] == "false"){
					deleteUnsavedFlv = false;
				}
			}
			
			//if snapshotEnable exists and it's false
			if(ApplicationData.getInstance().avc_settings["snapshotEnable"]){		
				if(ApplicationData.getInstance().avc_settings["snapshotEnable"] == "false"){
					_snapshotEnabled = false;
				}
			}
			
			if(ApplicationData.getInstance().avc_settings["disableAudio"]){
				if(ApplicationData.getInstance().avc_settings["disableAudio"] == "true"){
					_disableMicrophoneRecording = true;
				}
			}
			
			if(ApplicationData.getInstance().avc_settings["recordAgain"]){
				setRecAgain(ApplicationData.getInstance().avc_settings["recordAgain"]);
			}
			
			if(ApplicationData.getInstance().avc_settings["maxRecordingTime"]){
				if(ApplicationData.getInstance().avc_settings["maxRecordingTime"] != -1){
					_limitDuration = ApplicationData.getInstance().avc_settings["maxRecordingTime"];
				}else{
					if(LoaderInfo(root.loaderInfo).parameters.mrt){
						_limitDuration = LoaderInfo(root.loaderInfo).parameters.mrt;
					}	
				}
			}
			
			if(ApplicationData.getInstance().avc_settings["minRecordTime"]){
				_minDuration = ApplicationData.getInstance().avc_settings["minRecordTime"];
				if( _minDuration > _limitDuration){
					_minDuration = _limitDuration;
				}
			}
			if(LoaderInfo(root.loaderInfo).parameters.menuCol && LoaderInfo(root.loaderInfo).parameters.menuCol !="" && LoaderInfo(root.loaderInfo).parameters.menuCol !=undefined){
				_menuColor = uint(LoaderInfo(root.loaderInfo).parameters.menuCol);
			}else if(ApplicationData.getInstance().avc_settings["menuColor"]){
				_menuColor = uint(ApplicationData.getInstance().avc_settings["menuColor"]);
			}
			
			if(ApplicationData.getInstance().avc_settings["chmodStreams"]){
				_chmodStream = ApplicationData.getInstance().avc_settings["chmodStreams"];
			}
			
			if(ApplicationData.getInstance().avc_settings["useUserId"]){
				if(ApplicationData.getInstance().avc_settings["useUserId"] == "true"){
					_userPrefix = ApplicationData.getInstance().avc_settings["userId"]+"_";
				}
			}
			
			if (ApplicationData.getInstance().avc_settings["streamPrefix"]!="" && ApplicationData.getInstance().avc_settings["streamPrefix"]!=undefined && ApplicationData.getInstance().avc_settings["streamPrefix"]!=null){
				_streamPrefix = ApplicationData.getInstance().avc_settings["streamPrefix"];
			}
			
			if (ApplicationData.getInstance().avc_settings["streamName"]!=""){
				_streamName = ApplicationData.getInstance().avc_settings["streamName"];
				_fixedName=true;
			}
			
			//trigger simultaneous loading of language file and video quality settings 
			loadLanguageFile();
			loadStreamSettings();
			
			if(ApplicationData.getInstance().avc_settings["contextMenu"] && ApplicationData.getInstance().avc_settings["contextMenu"] != "" && ApplicationData.getInstance().avc_settings["contextMenu"] != undefined){
				
					_cm = new ContextMenu();
					_cm.hideBuiltInItems();
					var cmi:ContextMenuItem = new ContextMenuItem(ApplicationData.getInstance().avc_settings["contextMenu"]);
					_cm.customItems.push(cmi);
					contextMenu = _cm;
			}
			
			if(ApplicationData.getInstance().avc_settings["allowDomain"]){
				if(ApplicationData.getInstance().avc_settings["allowDomain"] == "true"){
					Security.allowDomain("*");
					//Security.allowInsecureDomain("*");	
				}
			}
			
			if(ApplicationData.getInstance().avc_settings["payload"] && ApplicationData.getInstance().avc_settings["payload"] != "" && ApplicationData.getInstance().avc_settings["payload"] != undefined){
				_payload = ApplicationData.getInstance().avc_settings["payload"];
			}else{
				if(LoaderInfo(root.loaderInfo).parameters.payload){
					_payload = LoaderInfo(root.loaderInfo).parameters.payload;
				}
			}
			
			//should we flip the image or not?
			if(ApplicationData.getInstance().avc_settings["flipImageHorizontally"]){
				if(ApplicationData.getInstance().avc_settings["flipImageHorizontally"] == "true"){
					this._mirrorVideoStreamDuringRecording = true;
				}
			}
			
			if(ApplicationData.getInstance().avc_settings["allowAudioOnlyRecording"] == 1){
				_allowAudioOnlyRecording = true;
			}
			
			if(ApplicationData.getInstance().avc_settings["enableFFMPEGConverting"] == 1){
				_enableFFMPEGConverting = true;
			}
			
			if(ApplicationData.getInstance().avc_settings["ffmpegCommand"] != ""){
				_ffmpegCmd = ApplicationData.getInstance().avc_settings["ffmpegCommand"];
			}
			
			if(ApplicationData.getInstance().avc_settings["showMenu"]){
				if(ApplicationData.getInstance().avc_settings["showMenu"] == "false"){
					_showMenu = false;
				}
			}

			//if show menu is set in flash vars prioritize this value 
			if(LoaderInfo(root.loaderInfo).parameters.showMenu){
				if(LoaderInfo(root.loaderInfo).parameters.showMenu == "false"){
					_showMenu = false;
				}
			}
			
			if(LoaderInfo(root.loaderInfo).parameters.sis){
				if(LoaderInfo(root.loaderInfo).parameters.sis == 1){
					_skipInitialScreen = true;
				}
			}else{
				if(ApplicationData.getInstance().avc_settings["skipInitialScreen"] == 1){
					_skipInitialScreen = true;
				}	
			}
									
			if(ApplicationData.getInstance().avc_settings["hideDeviceSettingsButtons"] == 1){
				_hideDeviceSettingsButtons = true;
			}
			
			if(ApplicationData.getInstance().avc_settings["showPipeCopyright"]){
				if(ApplicationData.getInstance().avc_settings["showPipeCopyright"] == 1){
					_showPipeCopyright = true;	
				}
			}
			
			if(ApplicationData.getInstance().avc_settings["showPipeAd"]){
				if(ApplicationData.getInstance().avc_settings["showPipeAd"] == 1){
					_skipInitialScreen = false;
					_showPipeAd = true;	
				}
			}
			
			if(ApplicationData.getInstance().avc_settings["maintenance"]){
				if(ApplicationData.getInstance().avc_settings["maintenance"] == 1){
					_skipInitialScreen = false;
					_maintenance = true;	
				}
			}
						
			if(ApplicationData.getInstance().avc_settings["proxyType"] != ""){
				_proxyType = ApplicationData.getInstance().avc_settings["proxyType"];
			}
						
		}
		
		private function onHTTPStatus(event:Event):void{
			trace("HDFVR.onHTTPStatus("+event+")")
		}
		
		private function onIOError(event:Event):void{
			trace("HDFVR.onIOError("+event+")")
			_alertBox.setTextLabel(Locale.loadString("IDS_TXT_LOADERR") + ApplicationData.getInstance().sscode + Locale.loadString("IDS_TXT_LOADERR2") + " <u><a href='avc_settings." + ApplicationData.getInstance().sscode + "'>" + Locale.loadString("IDS_TXT_LOADERR3") + "</a></u>!");
			_alertBox.setTextLabel("Could not load settings")
			addChild(_alertBox);
		}
		
		private function loadLanguageFile():void{
			trace("HDFVR.loadLanguageFile file="+ApplicationData.getInstance().avc_settings["languagefile"]);
			
			_langFilePath = "translations/en.xml";
			
			if(ApplicationData.getInstance().avc_settings["languagefile"] != ""){
				_langFilePath = ApplicationData.getInstance().avc_settings["languagefile"];
			}
			
			if(LoaderInfo(root.loaderInfo).parameters.lang && LoaderInfo(root.loaderInfo).parameters.lang != ""){
				_langFilePath = LoaderInfo(root.loaderInfo).parameters.lang;
			}
			
			Locale.addXMLPath("en", _langFilePath);
			Locale.loadLanguageXML("en", onLanguageXMLLoaded);
			
		}
		
		private function onLanguageXMLLoaded(succes:Boolean):void{
			trace("HDFVR.onLanguageXMLLoaded succes="+succes)
			languageXMLIsLoaded = succes;
			if(_streamSettingsLoaded && languageXMLIsLoaded){
				if(_hdfvrStarted == false){
					if(_skipInitialScreen){
						start();
					}else{
						drawInitScreen();
					}	
				}
			}
		}
		
		private function loadStreamSettings():void {
			trace("HDFVR.loadStreamSettings("+ApplicationData.getInstance().avc_settings["qualityurl"]+") ")
			var streamSettingsLoader:URLLoader = new URLLoader();
			if(ApplicationData.getInstance().avc_settings["qualityurl"]){
				qualityurl = ApplicationData.getInstance().avc_settings["qualityurl"]+"?r="+Math.random();
			}
			if (qualityurl!="" && qualityurl!="undefined"){
				streamSettingsLoader.load(new URLRequest(qualityurl));
				streamSettingsLoader.addEventListener(Event.COMPLETE, onStreamSettingsLoaded);
			}else{
				_alertBox.setTextLabel("No quality profile specified, check the qualityurl config in avc_settings."+ApplicationData.getInstance().sscode+".");
				addChild(_alertBox);
			}
		}
		
		private function onStreamSettingsLoaded(event:Event):void {
			trace("HDFVR.onStreamSettingsLoaded()");
			xmlStreamSettings = XML(event.target.data);
			ApplicationData.getInstance().xmlStreamSettings = xmlStreamSettings;
			
			if(ApplicationData.getInstance().xmlStreamSettings.item.vcodec != null && 
				ApplicationData.getInstance().xmlStreamSettings.item.vcodec != "undefined" && 
				ApplicationData.getInstance().xmlStreamSettings.item.vcodec.text().toString().length > 2 ){
				
				
				if(ApplicationData.getInstance().xmlStreamSettings.item.vcodec.text()[0].indexOf("h264_f") == 0){
					this._h264Enabled = true;
					this._mediaServer = this.FMS;
				}
				if(ApplicationData.getInstance().xmlStreamSettings.item.vcodec.text()[0].indexOf("h264_w") == 0){
					this._h264Enabled = true;
					this._mediaServer = this.WOWZA;
				}
				if(ApplicationData.getInstance().xmlStreamSettings.item.vcodec.text()[0].indexOf("h264_w_t") == 0){
					this._h264Enabled = true;
					this._mediaServer = this.WOWZA_TRANSCODER;
				}
				if(ApplicationData.getInstance().xmlStreamSettings.item.vcodec.text()[0].indexOf("h264_r") == 0){
					this._h264Enabled = true;
					this._mediaServer = this.RED5;
				}
			}
			//TODO altertbox needs to extend Sprite
			if (contains(_alertBox)){
				removeChild(_alertBox)
			}
			
			_streamSettingsLoaded = true;
			
			if(_streamSettingsLoaded && languageXMLIsLoaded){
				if(_hdfvrStarted == false){
					if(_skipInitialScreen){
						start();
					}else{
						drawInitScreen();
					}	
				}
			}
		}
		
		
		private function drawInitScreen():void{
			
			_hdfvrStarted = true;
			
			_startingBgColor = new Sprite();
			_startingBgColor.graphics.beginFill(bgColor, 1);
			_startingBgColor.graphics.drawRoundRect(0,0,stage.stageWidth, stage.stageHeight,roundedCorner);
			_startingBgColor.graphics.endFill();
			this.addChild(_startingBgColor);
			
			if(_showPipeAd == false && _maintenance == false){
				var recText:String = "";
				if(Locale.loadString("IDS_RECORD_INIT")){
					recText = Locale.loadString("IDS_RECORD_INIT");
				}else{
					recText = "Record Video";
				}
				
				_initRecordBtn = new CustomButton(recText,_normalColor, _overColor);
				_initRecordBtn.x = (stage.stageWidth - _initRecordBtn.width)/2;
				_initRecordBtn.y = (stage.stageHeight - _initRecordBtn.height)/2;
				_startingBgColor.addChild(_initRecordBtn);
				
				if(_showPipeCopyright){
					_byPipeText = new TextField();
					_byPipeText.htmlText="<a href='https://addpipe.com?ref=embed' target='_blank'><u>Powered by Pipe</u></a>";
					_byPipeText.setTextFormat(new TextFormat("_sans",10,_normalColor,null,null,null,null,null,TextFormatAlign.CENTER,0,0,0,0));
					_byPipeText.autoSize = "center";
					_byPipeText.selectable = false;
					
					_byPipeText.x = (stage.stageWidth - _byPipeText.width)/2;
					_byPipeText.y = stage.stageHeight - _byPipeText.height - 5;
					_startingBgColor.addChild(_byPipeText);
				}
				
				//we add the event listener to the main button that starts the recorder
				_initRecordBtn.addEventListener(MouseEvent.CLICK, onClickStartRecorder);
				
				//we make the same function available through thhe startRecorder JS Control API function
				if(ExternalInterface.available){
					ExternalInterface.addCallback("startRecorder", onClickStartRecorder);	
				}
			}else{
				
				if(_showPipeAd == true){
					
					_pipeAd = new TextField();
					_pipeAd.htmlText="<a href='https://addpipe.com?ref=expired' target='_blank'><u>Add video recording to your website using Pipe</u></a>";
					_pipeAd.setTextFormat(new TextFormat("_sans",18,_normalColor,null,null,null,null,null,TextFormatAlign.CENTER,0,0,0,0));
					_pipeAd.width = 300;
					_pipeAd.wordWrap = true;
					_pipeAd.autoSize = "center";
					_pipeAd.selectable = false;
					
					_pipeAd.x = (stage.stageWidth - _pipeAd.width)/2;
					_pipeAd.y = (stage.stageHeight - _pipeAd.height)/2;
					_startingBgColor.addChild(_pipeAd);
					
				}else if(_maintenance == true){
					
					_maintenanceText = new TextField();
					
					if(Locale.loadString("IDS_OFFLINE")){
						_maintenanceText.text = Locale.loadString("IDS_OFFLINE");
					}else{
						_maintenanceText.text="Video recording is in maintenance. Try again in a few minutes.";	
					}
					_maintenanceText.setTextFormat(new TextFormat("_sans",18,_normalColor,null,null,null,null,null,TextFormatAlign.CENTER,0,0,0,0));
					_maintenanceText.width = 300;
					_maintenanceText.wordWrap = true;
					_maintenanceText.autoSize = "center";
					_maintenanceText.selectable = false;
					
					_maintenanceText.x = (stage.stageWidth - _maintenanceText.width)/2;
					_maintenanceText.y = (stage.stageHeight - _maintenanceText.height)/2;
					_startingBgColor.addChild(_maintenanceText);
					
				}
			}
			
			//reposition and resize the elements on the stage when the stage is resized
			stage.addEventListener(Event.RESIZE,onStageResize);
			
			//new JS Events API call in 2.2 to let the browser know when the init screen is ready
			if(ExternalInterface.available){
				ExternalInterface.call("onRecorderInit",recorderId);
			}
		}
		
		private function onResizeInitScreen():void{
			trace("HDFVR.onResizeInitScreen()")
			if(_startingBgColor && contains(_startingBgColor)){
				_startingBgColor.graphics.clear();
				_startingBgColor.graphics.beginFill(bgColor, 1);
				_startingBgColor.graphics.drawRoundRect(0,0,stage.stageWidth, stage.stageHeight,roundedCorner);
				_startingBgColor.graphics.endFill();
				
				_initRecordBtn.x = (stage.stageWidth - _initRecordBtn.width)/2;
				_initRecordBtn.y = (stage.stageHeight - _initRecordBtn.height)/2;
				
				if(_showPipeCopyright){
					_byPipeText.x = (stage.stageWidth - _byPipeText.width)/2;
					_byPipeText.y = stage.stageHeight - _byPipeText.height - 5;	
				}
				
				if(_showPipeAd){
					_pipeAd.x = (stage.stageWidth - _pipeAd.width)/2;
					_pipeAd.y = (stage.stageHeight - _pipeAd.height)/2;
				}
				
				if(_maintenance){
					_maintenanceText.x = (stage.stageWidth - _maintenanceText.width)/2;
					_maintenanceText.y = (stage.stageHeight - _maintenanceText.height)/2;
				}
			}
		}
		
		private function removeInitScreen():void{
			trace("HDFVR.removeInitScreen()")
			_initRecordBtn.removeEventListener(MouseEvent.CLICK, onClickStartRecorder);
			_startingBgColor.removeChild(_initRecordBtn);
			_initRecordBtn = null;
			
			if(_showPipeCopyright){
				_startingBgColor.removeChild(_byPipeText);
				_byPipeText = null;
			}
			
			if(_showPipeAd){
				_startingBgColor.removeChild(_pipeAd);
				_pipeAd = null;
			}
			
			if(_maintenance){
				_startingBgColor.removeChild(_maintenanceText);
				_maintenanceText = null;
			}
			
			this.removeChild(_startingBgColor);
			_startingBgColor = null;

		}
		
		
		private function onClickStartRecorder(e:MouseEvent = null):void{
			trace("HDFVR.onClickStartRecorder()")
			if(_initRecordBtn && contains(_initRecordBtn)){
				this.removeInitScreen();
				start();	
			}
		}
		
		public function start():void{
			trace("HDFVR.start()")
			
			if(_skipInitialScreen){
				_hdfvrStarted = true;
			}
			
			bringUpDeviceSelector = false;
			ExternalInterface.call( "userHasCamMic",Camera.names.length,Microphone.names.length,recorderId);
			trace("HDFVR.userHasCamMic("+Camera.names.length+","+Microphone.names.length+") _isPPAPIonOSX="+_isPPAPIonOSX)
			if(Camera.names.length == 0){
				//if no webcam is detected on the computer
				if(_allowAudioOnlyRecording){
					//if recording only the audio is allowed
					_hasCam = false;
					//init just the mic
					if (!_disableMicrophoneRecording){
						//if audio recording is not disabled
						if (Microphone.names.length== 0){
							//if there is no microphone or sound card
							addChild(_alertBox)
							_alertBox.setTextLabel(Locale.loadString("IDS_TXT_NO_MIC"));
							_disableMicrophoneRecording=true;
						}else {
							//if there are one or more mics
							if (_isPPAPIonOSX || Microphone.names.length == 1){
								//if there is only one mic or we're on PPAPI on macOSx where there's only 1 option anyway
								//bringUpDeviceSelector remains false
								_mic = Microphone.getMicrophone()
								micSetup();
							}else if (Microphone.names.length > 1){
								//if there are more mics
								if (mySharedObject.data != null && mySharedObject.data.mic_index != null){
									//if we have a sved cookie about the preferred mic
									if (mySharedObject.data.mic_index > Microphone.names.length-1){
										//if the mic obj does not exist anymore force the user to select one
										bringUpDeviceSelector=true;
									}else{
										//we use the preferred saved microphone
										//bringUpDeviceSelector remains false
										_mic = Microphone.getMicrophone(mySharedObject.data.mic_index)
										micSetup();
									}
								}else{
									//but we might have to still trigger the  privacy screen so we init the default microphone
									_mic = Microphone.getMicrophone();
									micSetup();
									
									//if there is no saved preferred mic index we'll ask the user to select a mic
									bringUpDeviceSelector=true;
								}
							}
							
							//trace("Camera.names.length == 0, bringupFPPrivacyHelper="+bringupFPPrivacyHelper+", bringUpDeviceSelector="+bringUpDeviceSelector)
							
							if (bringupFPPrivacyHelper && bringUpDeviceSelector){
								//if we need to show both, the FP Privacy Widnow + Helper will be shown 1st
							}
							
							if (!bringupFPPrivacyHelper && bringUpDeviceSelector){
								//if we only need to show the device selector go ahead
								showFullScreenDevicesSelector();	
							}
							
							if (!bringupFPPrivacyHelper && !bringUpDeviceSelector){
								//if we need to show none, we need to build the UI directly
								buildInterface()
							}
						}
					}else{
						//recording audio is disabled in the settings file, show error
						addChild(_alertBox)
						_alertBox.setTextLabel("Audio recording is disabled from the settings file (disableAudio option).");
					}
				}else{
					//falling back to recording ONLY audio when there are no webcams is not allowed, show error
					addChild(_alertBox)
					_alertBox.setTextLabel(Locale.loadString("IDS_TXT_ICAMERA"));
				}
			} else {
				//the user has at least a webcam
				if (Camera.names.length ==1){
					//if the user has one webcam
					//bringUpDeviceSelector remains false

					//we init the default webamera
					_camera = Camera.getCamera();
					//we setup the cam with resolution, etc...
					cameraSetup();

				} else if (Camera.names.length >1){
					//if the user has more than one cam
					trace("Camera mySharedObject.data="+mySharedObject.data)
					trace("Camera mySharedObject.data.cam_index="+mySharedObject.data.cam_index)
					if(mySharedObject.data != null && mySharedObject.data.cam_index != null){
						//if there is already a camera index object saved, we try to get that Camera
						if (mySharedObject.data.cam_index>Camera.names.length-1){
							//if the camera obj does not exist anymore we ask the user to select a webcam
							bringUpDeviceSelector=true;
						}else{
							//bringUpDeviceSelector remains false
							//we init the preferred webamera
							_camera = Camera.getCamera(mySharedObject.data.cam_index);
							//we setup the cam with resolution, etc...
							cameraSetup();

						}
					}else{							
						//but we might have to still trigger the webcam privacy screen so we init the default webamera
						_camera = Camera.getCamera();
						//we setup the cam with resolution, etc...
						cameraSetup();
						
						//if there is no saved preferred webcam index we'll ask the user to select a webcam
						bringUpDeviceSelector=true
					}
				}
				
				if (!_disableMicrophoneRecording){
					if (Microphone.names.length== 0){
						//there is no microphone
						_disableMicrophoneRecording=true;
					}else {
						if (_isPPAPIonOSX==true || Microphone.names.length == 1){
							trace("Case 1");
							//if there is only one mic or we're on PPAPI on macOSX where there's only 1 option anyway
							//bringUpDeviceSelector remains as before (true or false)
							_mic = Microphone.getMicrophone()
							micSetup();
						}else if (Microphone.names.length > 1){
							trace("Case 2");
							trace("Mic mySharedObject.data="+mySharedObject.data)
							trace("Mic mySharedObject.data.mic_index="+mySharedObject.data.mic_index)
							if (mySharedObject.data != null && mySharedObject.data.mic_index != null){
								
								//if there is some saved data
								if (mySharedObject.data.mic_index>Microphone.names.length-1){
									//if the saved mic index does not exist anymore we definitely need to choose one
									bringUpDeviceSelector=true;
								}else{
									//we use the saved data
									//bringUpDeviceSelector remains as before (true or false)
									_mic = Microphone.getMicrophone(mySharedObject.data.mic_index)
									micSetup();
								}
							}else{
								//if there is no saved preferred device we definitely need to choose one
								bringUpDeviceSelector=true
							}
						}
					}
				}
				
				if (bringupFPPrivacyHelper && bringUpDeviceSelector){
					//if we need to show both, the FP Privacy Widnow + Helper will be shown 1st
				}
				
				if (!bringupFPPrivacyHelper && bringUpDeviceSelector){
					//if we only need to show the device selector go ahead
					showFullScreenDevicesSelector();	
				}
				
				if (!bringupFPPrivacyHelper && !bringUpDeviceSelector){
					//if we need to show none, we need to build the UI directly
					buildInterface()
				}
			}
			
			positionAlertBox();
		}
		
		private function onCamStatus(e:StatusEvent):void{
			trace("HDFVR.onCamStatus"+e.code)
			if (e.code == "Camera.Muted") {
				ExternalInterface.call( "onCamAccess",false,recorderId);
			}else{
				ExternalInterface.call( "onCamAccess", true,recorderId);
			}
		}
		
		private function buildInterface():void{
			trace("HDFVR.buildInterface()");	
			
			//container for everything
			if (!_recorderContainer){
				_recorderContainer = new Sprite();
				addChild(_recorderContainer);
				
				//video background area
				_sVideoArea= new Sprite();
				_recorderContainer.addChild(_sVideoArea);
				
				if(_hasCam){
					
					_videoPlayback =  new Video(_camera.width,_camera.height);
					_videoPlayback.visible = false;
					
					_sVideoArea.addChild(_video);
					_sVideoArea.addChild(_videoPlayback);
				}else{
					
					audioOnlyIcon = new icon_audioOnly();
					_sVideoArea.addChild(audioOnlyIcon);
					audioOnlyIcon.x = (stage.stageWidth -audioOnlyIcon.width)/2;
					audioOnlyIcon.y = (stage.stageHeight -audioOnlyIcon.height)/2;
				}
				
				//menu container
				_spMenuContainer = new Sprite();
				
				//record btn
				_btRecordAndStop= new MyButton(Locale.loadString("IDS_TXT_RECORD"),_menuColor,BUTTON_WIDTH,BUTTON_HEIGHT,_normalColor,_overColor);
				_btRecordAndStop.setIcon(icon_record,"rec");
				_btRecordAndStop.name = Locale.loadString("IDS_TXT_RECORD");
				addToolTip(_btRecordAndStop)
				_btRecordAndStop.setClickEventName("ON_RECORD_PRESS");
				addEventListener("ON_RECORD_PRESS",onClickRecordAndStop);
				
				//play btn
				_btPlay= new MyButton(Locale.loadString("IDS_TXT_PLAY"),_menuColor,BUTTON_WIDTH,BUTTON_HEIGHT,_normalColor, _overColor);
				_btPlay.setIcon(icon_play);
				_btPlay.name = Locale.loadString("IDS_TXT_PLAY");
				_btPlay.enabled = false
				_btPlay.setClickEventName("ON_PLAY_PRESS");
				addEventListener("ON_PLAY_PRESS",onClickPlay);
				addToolTip(_btPlay)
				
				//save btn
				_btSave = new MyButton(Locale.loadString("IDS_TXT_SAVE"),_menuColor,BUTTON_WIDTH,BUTTON_HEIGHT, _normalColor, _overColor);
				if(Locale.loadString("IDS_TXT_SAVE")){
					_btSave.name = Locale.loadString("IDS_TXT_SAVE");
				}else{
					_btSave.name = "Save";
				}
				_btSave.setIcon(icon_disk);
				_btSave.setClickEventName("ON_SAVE_PRESS");
				addEventListener("ON_SAVE_PRESS",onClickSave);
				addToolTip(_btSave)
				_btSave.enabled = false
				
				//hide save btn
				if (Number(ApplicationData.getInstance().avc_settings["hideSaveButton"])==1){
					_btSave.visible = false
				}
				
				if(LoaderInfo(root.loaderInfo).parameters.asv){
					if(LoaderInfo(root.loaderInfo).parameters.asv == 1){
						_autoSave = true;
						_btSave.visible = false;
						ApplicationData.getInstance().avc_settings["hideSaveButton"] = 1
					}
				}else if (Number(ApplicationData.getInstance().avc_settings["autoSave"])==1){
					_autoSave = true;
					_btSave.visible = false;
					ApplicationData.getInstance().avc_settings["hideSaveButton"] = 1;
				}
				
				//hide play btn
				if (Number(ApplicationData.getInstance().avc_settings["hidePlayButton"])==1){
					_btPlay.visible = false;
				}
				
				
				//settings buttons
				
				var micText:String = "Microphone settings";
				if(Locale.loadString("IDS_MIC_SETTINGS")){
					micText = Locale.loadString("IDS_MIC_SETTINGS");
				}
				_btMicSettings = new MyButton(micText,_menuColor,BUTTON_WIDTH,BUTTON_HEIGHT, _normalColor, _overColor);
				_btMicSettings.name = micText;
				_btMicSettings.type = "mic";
				_btMicSettings.setIcon(icon_mic);
				_btMicSettings.position = "right";
				_btMicSettings.setClickEventName("ON_MIC_SETTINGS_PRESS");
				addEventListener("ON_MIC_SETTINGS_PRESS",onClickCamOrMicSettings);
				addToolTip(_btMicSettings)
								
				var camText:String = "Webcam settings";
				if(Locale.loadString("IDS_WEBCAM_SETTINGS")){
					camText = Locale.loadString("IDS_WEBCAM_SETTINGS");
				}
				_btCamSettings = new MyButton(camText,_menuColor,BUTTON_WIDTH,BUTTON_HEIGHT, _normalColor, _overColor);
				_btCamSettings.name = camText;
				_btCamSettings.type = "cam";
				_btCamSettings.setIcon(icon_cam);
				_btCamSettings.position = "right";
				_btCamSettings.setClickEventName("ON_CAM_SETTINGS_PRESS");
				addEventListener("ON_CAM_SETTINGS_PRESS",onClickCamOrMicSettings);
				addToolTip(_btCamSettings)
				
				if(_hasCam == false){
					_btCamSettings.enabled = false;
				}
				
				_fpsTracker = new Sprite();
				_fpsTracker.graphics.beginFill(0x00FF00,1);
				_fpsTracker.graphics.drawRect(0,0,4,3);
				_fpsTracker.graphics.endFill();
				_fpsTracker.mouseEnabled =false;
				_fpsTracker.x = 8;
				_fpsTracker.y = 11;
				_btCamSettings.addChild(_fpsTracker);
				
				//scrub bar
				_scrubBar = new ScrubBar(_menuColor,_normalColor, _overColor);
				_scrubBar.setMax(_limitDuration);
				
				//add elements				
				_spMenuContainer.addChild(_btRecordAndStop);
				_spMenuContainer.addChild(_btPlay);
				_spMenuContainer.addChild(_btSave);
				_spMenuContainer.addChild(_scrubBar);
				_spMenuContainer.addChild(_btCamSettings);
				
				//do not add the mic icon if audio recording is disabled
				if(!_disableMicrophoneRecording){
					_spMenuContainer.addChild(_btMicSettings);
				}
				
				//do not add the sound level display if audio recording is disabled
				_sld = new SoundLevelDisplay();
				_sld.name = "sld";
				if(!_disableMicrophoneRecording){
					_spMenuContainer.addChild(_sld);
				}
				
				//add container
				if (_showMenu){
					//menu is visible
					_recorderContainer.addChild(_spMenuContainer);
					//if(bringUpDeviceSelector){
					//	_spMenuContainer.visible = false;
					//}
				}else{
					//menu is hidden
					if(_hideDeviceSettingsButtons == false){
						//mic and cam icons are NOT hidden (in kiosk scenarios they could be) so we add them direclty to _recorderContainer
						_recorderContainer.addChild(_btCamSettings);
						if(!_disableMicrophoneRecording){
							_recorderContainer.addChild(_btMicSettings);
						}
						_recorderContainer.addChild(_sld);
						//but hide thier backgrounds so that only the icon itself is visible
						_btCamSettings.hideBg();
						_btMicSettings.hideBg();
					}
				}
				
				//add fps
				_fpsCounter = new TextField();
				_fpsCounter.defaultTextFormat = new TextFormat("_sans",10,_normalColor,null,null,null,null,null,"left");
				_fpsCounter.autoSize = TextFieldAutoSize.LEFT;
				_fpsCounter.textColor = 0xffffff;
				_fpsCounter.text="0fps"
				//_fpsCounter.border = true;
				//_fpsCounter.borderColor = 0xffffff
				_fpsCounter.selectable = false;
				//_fpsCounter.filters = [_glowFilter]
				if(showFps){
					_recorderContainer.addChild(_fpsCounter);	
					
				}
				
				
				//add timer
				_txTime = new TextField();
				_txTime.autoSize = TextFieldAutoSize.RIGHT;
				_txTime.defaultTextFormat = new TextFormat("_sans",10,_normalColor,null,null,null,null,null,"left");
				_txTime.selectable = false;
				_txTime.alpha = 0.1;
				if(ApplicationData.getInstance().avc_settings["countdownTimer"]=="true"){
					_txTime.text = Strings.digits(_limitDuration)
				}else{
					_txTime.text = "00:00 / "+Strings.digits(_limitDuration)
				}
				//_txTime.filters = [_glowFilter]
				_recorderContainer.addChild (_txTime)
				_txTime.visible = this._showTimer;
				
					
				if(_showPipeCopyright){
					_byPipeText = new TextField();
					_byPipeText.htmlText="<a href='https://addpipe.com?ref=embed' target='_blank'><u>Powered by Pipe</u></a>";
					_byPipeText.setTextFormat(new TextFormat("_sans",10,0xFFFFFF,null,null,null,null,null,TextFormatAlign.CENTER,0,0,0,0));
					_byPipeText.autoSize = "center";
					_byPipeText.selectable = false;
					
					
					_byPipeText.x = (stage.stageWidth - _byPipeText.width)/2;
					if(_showMenu == true){
						_byPipeText.y = stage.stageHeight - _byPipeText.height - 35;	
					}else{
						_byPipeText.y = stage.stageHeight - _byPipeText.height - 15;
					}
					_recorderContainer.addChild(_byPipeText);
				}
				
				//we add the background to the stage/root element so that it does not get hiddn under the mask applied to _recorderContainer
				_spBg = new Sprite;
				addChildAt(_spBg,0);
				//drawBackground();
				
				//create the mask
				_spSuperMask = new Sprite()
				resizeMask()
				_recorderContainer.mask =  _spSuperMask
					
				resizeVideoArea();
				resizeVideoSurface();
				positionVideoAreaAndSurface();
				positionControls();
				positionFps();
				positionTimer();
				positionSLD();
				
				if(_hasCam){
					//set the focus on the video area so that it can take KEY input
					_sVideoArea.focusRect = false;
					//stage.stageFocusRect = false;
					stage.focus = _sVideoArea;
				}
				
				
				//timed function for displaying the fps, upload status, etc...
				_timer = new Timer(100);
				_timer.addEventListener("timer", timedFunction);
				_timer.start()
				
				//disable th scrubbar until we start recording
				_scrubBar.enabled = false;
				
				//overlay
				if (ApplicationData.getInstance().avc_settings["overlayPath"] && ApplicationData.getInstance().avc_settings["overlayPath"]!=""){
					_watermarkLoader = new Loader();
					_watermarkLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,onWatermarkLoadComplete);
					if (ApplicationData.getInstance().avc_settings["overlayPath"]!=""){
						_watermarkLoader.load(new URLRequest(ApplicationData.getInstance().avc_settings["overlayPath"]));
					}
				}
				
				//setup the external JS interface
				ExternalInterface.addCallback("record", onClickRecordJS);
				ExternalInterface.addCallback("pauseRecording", onClickPauseRecJS);
				ExternalInterface.addCallback("resumeRecording", onClickResumeRecJS);
				ExternalInterface.addCallback("stopVideo", onClickStopJS);
				ExternalInterface.addCallback("playVideo", onClickPlayJS);
				ExternalInterface.addCallback("pause", onClickPauseJS);
				ExternalInterface.addCallback("save", onClickSaveJS);
				ExternalInterface.addCallback("getStreamName", onGetStreamNameJS);
				ExternalInterface.addCallback("getStreamTime", onGetStreamTimeJS);
				ExternalInterface.addCallback("getPlaybackTime", onGetPlaybackTimeJS);
				
				//onFlashReady is depreceated since HDFVR 2.2 but we still call it to allow for backwrds compatibility
				if(ExternalInterface.available){
					ExternalInterface.call("onFlashReady",recorderId);
				}
				//onRecorderReady is preferred JS Events API call since HDFVR 2.2
				if(ExternalInterface.available){
					ExternalInterface.call("onRecorderReady",recorderId);
				}
				
				//event for when resizing the video recorder area
				stage.addEventListener(Event.RESIZE,onStageResize);
			}
		}
		
		public function positionAlertBox():void{
			
			if(stage.stageWidth == 0 && stage.stageHeight == 0){
				_alertBox.x = 0;
				_alertBox.y = 0;
			}else{
				_alertBox.x=(stage.stageWidth-_alertBox.width)/2
				_alertBox.y=(stage.stageHeight-_alertBox.height)/2
			}
			//trace("AlertBox Positioning " + _alertBox.x + " " + _alertBox.y + " " + stage.stageWidth + " " + stage.stageHeight + " " + _alertBox.width + " " + _alertBox.height);	
		}
		
		public function setRecAgain(rec:String):void{
			if(rec == "false"){
				recordAgain = false;
			}
		}
		
		public function setRoundedCorner(radius:Number):void{
			roundedCorner = radius;
		}

		private function resizeMask():void{
			if (_spSuperMask){
				_spSuperMask.graphics.clear();
				_spSuperMask.graphics.beginFill(bgColor)
				_spSuperMask.graphics.drawRoundRect(PADDING,PADDING,stage.stageWidth-2*PADDING, stage.stageHeight -2*PADDING,roundedCorner,roundedCorner)
				_spSuperMask.graphics.endFill();
			}
		}
		
		
		private function drawBackground():void{
			 _spBg.graphics.clear();
		     _spBg.graphics.beginFill(bgColor,1);
		     _spBg.graphics.drawRoundRect(0,0, stage.stageWidth ,stage.stageHeight, roundedCorner,roundedCorner);
		     _spBg.graphics.endFill();
		}
		
		
		//FUNCTION CALLED BY THE MEDIA SERVER, IT NEEDS TO BE PUBLIC
		public function verifyLicenceKey():void{
			trace("HDFVR.verifyLicenceKey()")
			nextStep="asklicensekey"
			nextStepAfterConnection()
		}
		
		
		private function VLK():void{
			trace("HDFVR.VLK()")
			//we remove the alert box if any
			if (contains(_alertBox)){
				removeChild(_alertBox)
			}
			
			//we disable som buttons
			if(_btRecordAndStop){
				_btRecordAndStop.enabled = false;
			}
			
			//we crate the new sprite with the license key request
			var verifyBoxC:Sprite = new Sprite();
			verifyBoxC.name = "verify_box";
			var verifyBox:Sprite = new Sprite();
			verifyBox.graphics.beginFill(0xffffff,1);
			verifyBox.graphics.drawRect(0,0,300,100);
			verifyBox.graphics.endFill();
			
			//apply some shadow to the box
			var ds:DropShadowFilter = new DropShadowFilter(4,45,0,0.5,4,4)
			verifyBox.filters = [ds]; 
			verifyBoxC.addChild(verifyBox);
			
			//add some text input to it
			var textInput:TextInput = new TextInput();
			textInput.name = "key_code";
			textInput.width = verifyBoxC.width*7/10;
			textInput.y = 100/2- textInput.height/2;
			textInput.x = verifyBoxC.width/2 - textInput.width/2; 
			textInput.maxChars = 2555;
			verifyBoxC.addChild(textInput);
			
			
			var label:TextField  = new TextField();
			label.defaultTextFormat = tfNormal;
			label.text = Locale.loadString("IDS_TXT_IPKEY");
			label.width = verifyBoxC.width*7/10;
			label.height= 30;
			label.x = verifyBoxC.width/2 -  label.width/2;
			label.selectable = false;
			verifyBoxC.addChild(label);
			
			
			var btnAccept:Button = new Button();
			btnAccept.name = "btn_accept";
			btnAccept.label = Locale.loadString("IDS_BT_OK");
			btnAccept.x = verifyBoxC.width/2 - btnAccept.width -5;
			btnAccept.y = 90 - btnAccept.height;
			btnAccept.addEventListener(MouseEvent.CLICK, onClickInsertKey);
			verifyBoxC.addChild(btnAccept);
			
			var btnBuy:Button = new Button();
			btnBuy.name = "btn_buy";
			btnBuy.x = btnAccept.x + btnAccept.width + 5;
			btnBuy.y = btnAccept.y ;
			btnBuy.label = Locale.loadString("IDS_BT_BUY");
			btnBuy.addEventListener(MouseEvent.CLICK, onClickBuyButton);
			verifyBoxC.addChild(btnBuy);
			verifyBoxC.x = stage.stageWidth/2 - verifyBoxC.width/2;
			verifyBoxC.y = stage.stageHeight/2 - verifyBoxC.height/2;
			addChild(verifyBoxC);	
		}
		
		private function onClickInsertKey(e:MouseEvent = null):void{
			trace("HDFVR.onClickInsertKey()")
			var btn:Object = e.currentTarget;
			var parent:Object = btn.parent;
			var textInput:TextInput = parent.getChildByName("key_code");
			var mess:TextField = parent.getChildByName("err");
			if(mess && parent.contains(mess)){
				parent.removeChild(mess);
			}
			if(textInput && textInput is TextInput){
				if(textInput.text.length < 20){
				 	textInput.text = "";
					mess =  new TextField();
					mess.defaultTextFormat = tfNormal;
					mess.textColor = 0xff0000;
					mess.name = "err";
					mess.width = parent.width*7/10;
					mess.x = parent.width/2 -mess.width/2;
					mess.y = 100;
					mess.multiline = true;
					mess.wordWrap = true;
					mess.text = Locale.loadString("IDS_TXT_SPKEY");				
					DisplayObjectContainer(parent).addChild(mess);
				 
				}else{
					responder = new Responder(onResponderKeyReply);
					nc.call("verifyLicenseKey", responder, textInput.text);		
				}
				textInput.text = "";
			}else{
				//something strange is goin on
			}
		}
		
		//when the user clicks the buy button in the license key window
		private function onClickBuyButton(e:MouseEvent = null):void{
			trace("HDFVR.onClickBuyButton()")
			var url:URLRequest = new URLRequest("http://www.hdfvr.com/buy-now");
			navigateToURL(url,"_blank");
		}
		
		//this function needs to be public cause its called by the media server
		public function onResponderKeyReply(params:Object):void{
		    trace("HDFVR.onResponderKeyReply:"+params);
		    var  vbox:DisplayObject = getChildByName("verify_box");
			if(params['status'] == "fail"){
				if(vbox){
					var mess:TextField;
				    mess =  new TextField();
					mess.defaultTextFormat = tfNormal;
					mess.textColor = 0xff0000;
					mess.name = "err";
					mess.width = vbox.width*7/10;
				    mess.x = vbox.width/2 -mess.width/2;
				    mess.y = 100;
				    mess.multiline = true;
				    mess.wordWrap = true;
					mess.text = params['message'];				
				    DisplayObjectContainer(vbox).addChild(mess);
				}
			}else if(params['status'] == "success"){
				trace("here");
				if(vbox && contains(vbox)){
					removeChild(vbox);
					_recorderContainer.visible = true;
				}
				//if(recordAgain){
				_btRecordAndStop.enabled = true;
				//}
			}
		}
		
		
		
		
		private function establishNetConnection():void {
			trace("HDFVR.establishNetConnection("+ApplicationData.getInstance().avc_settings["connectionstring"]+")");
			//we reset the rejected var
			wasTheConnectionRejected = false;
			
			//show the connecting message
			_alertBox.setTextLabel(Locale.loadString("IDS_TXT_CONNECT"),true);
			addChild(_alertBox)
			
			//estabilsh the connn
			if (ApplicationData.getInstance().avc_settings["connectionstring"] == ""){
			    _alertBox.setTextLabel(Locale.loadString("IDS_TXT_CONNECTSTR_ERR")+ApplicationData.getInstance().sscode+" "+Locale.loadString("IDS_TXT_CONNECTSTR_ERR2"));
			}else{
				nc = new NetConnection();
				nc.objectEncoding = ObjectEncoding.AMF0;
				nc.client = this
				nc.proxyType = _proxyType;	
				nc.addEventListener(NetStatusEvent.NET_STATUS,ncStatusHandler);
				nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncError);
				nc.connect(ApplicationData.getInstance().avc_settings["connectionstring"]);				
			}
		}
		
		private function asyncError(e:AsyncErrorEvent):void{
			trace("HDFVR.asyncError("+e+")")
		}
		
		private function ncStatusHandler(event:NetStatusEvent):void {
			trace("HDFVR.ncStatusHandler("+event.info.code+")");
			for (var i:String in event.info) {
				trace("HDFVR.ncStatusHandler("+i+" : "+event.info[i]+")");
			}
			
			if(ExternalInterface.available){
				ExternalInterface.call( "onConnectionStatus", event.info.code, recorderId);
			}
			
			if (event.info.code == "NetConnection.Connect.Failed"){
				_alertBox.setTextLabel(Locale.loadString("IDS_TXT_CFAIL"));
				addChild(_alertBox)
			} else if (event.info.code == "NetConnection.Connect.Rejected") {
				
				if(event.info.application && event.info.application is String){
					_alertBox.setTextLabel(Locale.loadString("IDS_TXT_CREJECT")+": " +event.info.application);
				} else if (event.info.application && event.info.application["message"] && event.info.application["message"] is String){
					//thrown by FMS when applciation is missing from applications folder
					_alertBox.setTextLabel(Locale.loadString("IDS_TXT_CREJECT")+": " +event.info.application["message"]);
				}else if(event.info.description){
					_alertBox.setTextLabel(Locale.loadString("IDS_TXT_CREJECT")+": "+event.info.description);
				}else{
					_alertBox.setTextLabel(Locale.loadString("IDS_TXT_CREJECT"));
				}
				addChild(_alertBox)
				wasTheConnectionRejected = true;
			} else if (event.info.code == "NetConnection.Connect.Success") {
				didTheConnEverSucceed=true;
				if(this._mediaServer == this.WOWZA_TRANSCODER){
					nc2 = new NetConnection();
					nc2.objectEncoding = ObjectEncoding.AMF0;
					nc2.client = this;
					var connection_prefix:String = ApplicationData.getInstance().avc_settings["connectionstring"];
					connection_prefix = connection_prefix.substr(0, connection_prefix.indexOf("hdfvr"));
					nc2.connect(connection_prefix+"hdfvr_play/_definst_");
				}
				
				nextStepAfterConnection();
			} else if (event.info.code == "NetConnection.Connect.InvalidApp") {
				 _alertBox.setTextLabel(Locale.loadString("IDS_TXT_IAPP"));
				addChild(_alertBox)
			} else if (event.info.code == "NetConnection.Connect.Closed") {
				if (didTheConnEverSucceed){
					_alertBox.setTextLabel(Locale.loadString("IDS_TXT_CCLOSED"));
					addChild(_alertBox)
					
					if(ExternalInterface.available){
						ExternalInterface.call("onConnectionClosed",recorderId);
					}
					
				}else if(!wasTheConnectionRejected){
					if(event.info.application && event.info.application["message"]){
						_alertBox.setTextLabel("Connection Rejected: " +event.info.application["message"])
					}else{
						_alertBox.setTextLabel(Locale.loadString("IDS_TXT_CUNKNOWN"))
					}
					addChild(_alertBox)
				}
				clearInterface();	
			}
		}
		
		/**
		* disconnectAndRemove is used to prevent the web-cam 
		* from remaining active on Internet Explorer
		*/
		
		private function disconnectAndRemove():void {
			if(nc){
				nc.close();	
			}
			if(nc2){
				nc2.close();
			}
			clearInterface();
		}
		
		//this clears all the elements on the stage
		private function clearInterface():void{
			trace("HDFVR.clearInterface()")
		    stage.removeEventListener(Event.RESIZE,onStageResize);
			if(_timer){
		    	_timer.stop();
		    	_timer.removeEventListener("timer", timedFunction);
		    	_timer =  null;
			}
			_camera=null
			_mic=null
			
			if(_video){
				_video.attachCamera(null);
				_video.clear();
			}
						
			if(_recorderContainer && contains(DisplayObject(_recorderContainer))){
				removeChild(DisplayObject(_recorderContainer));
				_recorderContainer = null;
			}
			
			if (_video && contains(_video)){
				removeChild(_video)
			}
			_video = null;
			
			if (_videoPlayback && contains(_videoPlayback)){
				removeChild(_videoPlayback)
			}
			_videoPlayback = null;
			
			
			if (_fpsCounter && contains(_fpsCounter)){
				removeChild(_fpsCounter)	
			}
			_fpsCounter = null
			
			if (_txTime && contains(_txTime)){
				removeChild(_txTime)
			}
			_txTime = null
				
			if(_byPipeText && contains(_byPipeText)){
				removeChild(_byPipeText);
			}
			_byPipeText = null;
			
			if (_btRecordAndStop && contains(_btRecordAndStop)){
				removeChild(_btRecordAndStop)
			}
			_btRecordAndStop = null
			
			if (_btPlay && contains(_btPlay)){
				removeChild(_btPlay)
			}
			_btPlay = null
			
			if (_btSave && contains(_btSave)){
				removeChild(_btSave)
			}
			_btSave = null
			
			if (_sld && contains(_sld)){
				removeChild(_sld)
			}
			
			_sld = null
			
			var vBox:Object = getChildByName("verify_box");
			if(vBox && contains(DisplayObject(vBox))){
				removeChild(DisplayObject(vBox));
			}
		}
		
		public function onStageResize(e:Event = null):void{
			trace("HDFVR.onStageResize()")
			onResizeInitScreen();
			resizeVideoArea();
			resizeVideoSurface();
			positionVideoAreaAndSurface();
			resizeMask();
			positionControls();
			positionFps();
			positionTimer();
			positionSLD();
			alignRecSprite();
			positionAlertBox();
			onResizePermissionScreen();
			positionWatermark()
			
			//redraw the device selector screen if it's on stage
			if(_FSDeviceSelector && contains(_FSDeviceSelector)){
				_FSDeviceSelector.onResize();
			}
			
			//position the audio only icon if present
			if(audioOnlyIcon){
				audioOnlyIcon.x = (stage.stageWidth -audioOnlyIcon.width)/2;
				audioOnlyIcon.y = (stage.stageHeight -audioOnlyIcon.height)/2;	
			}
			
		}
		
		private function resizeVideoArea():void{
			trace("HDFVR.resizeVideoArea()")
			if (_sVideoArea){
				_sVideoArea.graphics.clear();
				_sVideoArea.graphics.beginFill(0x000000,1);
				if(_showMenu){
					_sVideoArea.graphics.drawRect(0,0,stage.stageWidth-2*PADDING,stage.stageHeight-3*PADDING-BUTTON_HEIGHT);	
				}else{
					_sVideoArea.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
				}
				_sVideoArea.graphics.endFill();
			}
		}
		
		private function resizeVideoSurface():void{
			trace("HDFVR.resizeVideoSurface()")
			if (_video){
				if (_showMenu){
					_video.width = stage.stageWidth-2*PADDING
					_video.height = stage.stageHeight-3*PADDING-BUTTON_HEIGHT
				}else{
					_video.width = stage.stageWidth;
					_video.height = stage.stageHeight;
				}
				if ( _video.scaleX < _video.scaleY ) { _video.scaleY = _video.scaleX }else{ _video.scaleX = _video.scaleY;}
				if (_mirrorVideoStreamDuringRecording){
					if (_video.scaleX>=0){
						_video.scaleX *=-1;
					}
				}
			}
			
			if (_videoPlayback){
				if (_showMenu){
					_videoPlayback.width = stage.stageWidth-2*PADDING
					_videoPlayback.height = stage.stageHeight-3*PADDING-BUTTON_HEIGHT
				}else{
					_videoPlayback.width = stage.stageWidth;
					_videoPlayback.height = stage.stageHeight;
				}
				if ( _videoPlayback.scaleX < _videoPlayback.scaleY ) { _videoPlayback.scaleY = _videoPlayback.scaleX }else{ _videoPlayback.scaleX = _videoPlayback.scaleY;}
				/*
				if (_flipImageHorizontally){
					if (_videoPlayback.scaleX>=0){
						_videoPlayback.scaleX *=-1;
					}
				}*/
			}
		}
		
		private function positionVideoAreaAndSurface():void{
			trace("HDFVR.positionVideoAreaAndSurface()")
			if (_sVideoArea){
				_sVideoArea.y = PADDING
				_sVideoArea.x = PADDING
			}
			
			if (_video && _sVideoArea){
				_video.x=(_sVideoArea.width-_video.width)/2
				_video.y=(_sVideoArea.height-_video.height)/2	

				if (_mirrorVideoStreamDuringRecording){
					_video.x = (_video.width + stage.stageWidth)/2;
				}
			}
			
			if (_videoPlayback){
				_videoPlayback.x=(_sVideoArea.width-_videoPlayback.width)/2
				_videoPlayback.y=(_sVideoArea.height-_videoPlayback.height)/2
			}
			
			if(_lastFrame){
				_lastFrame.width = _video.width;
				_lastFrame.height = _video.height;
				
				_lastFrame.x = _video.x;
				_lastFrame.y = _video.y;
				
				if (_mirrorVideoStreamDuringRecording){
					if (_lastFrame.scaleX>=0){
						_lastFrame.scaleX *=-1;
					}
					//_lastFrame.x+=_lastFrame.width
				}
			}
		}
		
		private function getCustomDimension(elements:Number):Number{
			trace("HDFVR.getCustomDimension()")
            if(elements < 4){
            	_nrOfRows = 1;
            	_nrOfColumns = elements;
            }else if(elements < 7){
            	_nrOfRows = 2;
            	_nrOfColumns = 3;
            }else{
            	_nrOfRows = 3;
            	_nrOfColumns = 3;
            }
            
			var max_height:Number =(stage.stageHeight)/_nrOfRows - 25;
			var width:Number = Math.round(stage.stageWidth/_nrOfColumns);
			width = Math.floor(width/16) * 16;
			while(width * _ratio >= max_height){
				width = width - width/100;
			}
			width = Math.round(width*8/160) * 16; 
			return width;
		}
		
		private function cameraSetup():void{
			trace("HDFVR.cameraSetup()")
			
			_camera.addEventListener(StatusEvent.STATUS,onCamStatus);
			if(_camera.muted /*&& Microphone.names.length == 1*/){//commented code may help to solve an issue with the help screen not showing correctly in an instance
				Security.showSettings(SecurityPanel.PRIVACY);
				bringupFPPrivacyHelper = true;
			}else{
				ExternalInterface.call( "onCamAccess", true,recorderId);
			}
			_ratio = Math.min(ApplicationData.getInstance().xmlStreamSettings.item.w.text()[0],ApplicationData.getInstance().xmlStreamSettings.item.h.text()[0])/Math.max(ApplicationData.getInstance().xmlStreamSettings.item.w.text()[0],ApplicationData.getInstance().xmlStreamSettings.item.h.text()[0]);
			_camera.setMode(ApplicationData.getInstance().xmlStreamSettings.item.w.text()[0], ApplicationData.getInstance().xmlStreamSettings.item.h.text()[0], ApplicationData.getInstance().xmlStreamSettings.item.fps.text()[0])
			_camera.setQuality( ApplicationData.getInstance().xmlStreamSettings.item.bytes.text()[0] ,ApplicationData.getInstance().xmlStreamSettings.item.q.text()[0]);	
			_camera.setKeyFrameInterval(ApplicationData.getInstance().xmlStreamSettings.item.kfps.text()[0]);
			
			//video area
			if (!_video){
				_video = new Video(_camera.width,_camera.height);
				_video.attachCamera(_camera);
			}
			
			if(bringupFPPrivacyHelper && fpPrivacyDialogWasShown == false){
				showFPPrivacyHelper();
			}
		}
		
		
		private function micSetup():void{
			trace("HDFVR.micSetup()")
			
			if(_mic.muted){
				Security.showSettings(SecurityPanel.PRIVACY);
				bringupFPPrivacyHelper = true;
			}
			
			if(ApplicationData.getInstance().xmlStreamSettings.item.sndSilencelevel.text()[0]){
				_mic.setSilenceLevel(ApplicationData.getInstance().xmlStreamSettings.item.sndSilencelevel.text()[0]);
			}
			if (ApplicationData.getInstance().xmlStreamSettings.item.snd.text()[0].indexOf("speex")==0){
				_mic.codec = SoundCodec.SPEEX;
				_mic["encodeQuality"]=Number(ApplicationData.getInstance().xmlStreamSettings.item.snd.text()[0].toString().substr(5));
				_audioCodec = "Speex";
			}else{
				_mic.rate=Number(ApplicationData.getInstance().xmlStreamSettings.item.snd.text()[0])
			}
			
			
			if(ApplicationData.getInstance().avc_settings["microphoneGain"] && ApplicationData.getInstance().avc_settings["microphoneGain"]){
				_mic.gain = ApplicationData.getInstance().avc_settings["microphoneGain"];	
			}else{
				_mic.gain = 50;
			}
			
			//we attach a dummy sample data event listener, so that mic activity level gets triggered even though it is not yet attached to any a NetStream
			_mic.addEventListener(SampleDataEvent.SAMPLE_DATA, dummyMicSampleEvent);

			if(bringupFPPrivacyHelper && fpPrivacyDialogWasShown == false){
				trace("HDFVR.micSetup() calling showFPPrivacyHelper")
				showFPPrivacyHelper();
			}
		}
		
		
		public function makeBorder(_target:Sprite, _thicknes:Number,_color:uint):void{
			trace("HDFVR.makeBorder()")
			if(_target is Sprite){
				var width:Number = _target.width;
				var height:Number = _target.height;
				_target.graphics.beginFill(_color ,0.1);
				_target.graphics.drawRoundRect(0,0,_target.width,_target.height,45,45);
				_target.graphics.endFill();
				_target.width = width ;
				_target.height = height;
			}
		}
		
		private function onWatermarkLoadComplete(event:Event):void{
			trace("HDFVR.onWatermarkLoadComplete()");
			addChild(_watermarkLoader);
			positionWatermark();
		}
		
		private function positionWatermark():void{
			trace("HDFVR.positionWatermark()");
			if (_watermarkLoader){
			_watermarkLoader.y=4
				if (ApplicationData.getInstance().avc_settings["overlayPosition"]=="tr"){
					//top right
					_watermarkLoader.x=stage.stageWidth - _watermarkLoader.width- 4
				}else if(ApplicationData.getInstance().avc_settings["overlayPosition"]=="tl"){
					//top left
					_watermarkLoader.x=4
				}else{
					//centered (face overlay)
					_watermarkLoader.x = (stage.stageWidth - _watermarkLoader.width)/2;
					if(_hasCam){
						_watermarkLoader.y = (_video.height - _watermarkLoader.height)/2;	
					}else{
						_watermarkLoader.y = (-stage.stageHeight - _watermarkLoader.height)/2;
					}
				}
			}
		}
		
		public function positionSLD():void{
			if(_sld){
				_sld.x = _btMicSettings.x + _btMicSettings.width - 5;
				_sld.rotation = -90;
				_sld.y = _btMicSettings.y + 25;
				_sld.visible = this._showSoundBar;
			}
		}
		
		//[+] the JS CONTROL API
		public function onClickSaveJS():void{
			trace("HDFVR.onClickSaveJS() _btSave.enabled="+_btSave.enabled)
			if(_btSave.enabled == true){
				onClickSave();
			}
		}
		
		public function onClickRecordJS():void{
			if(_btRecordAndStop.enabled == true){
				if(_state !="recording"){
					onClickRecordAndStop();
					if(_FSDeviceSelector && contains(_FSDeviceSelector)){
						_FSDeviceSelector.onSubmit();
					}
				}
			}
		}
		
		public function onClickPauseRecJS():void{
			if(ApplicationData.getInstance().avc_settings["enablePauseWhileRecording"] == 1){
				if(_state =="recording"){
					onPauseRecording();
				}
			}	
		}
		
		public function onClickResumeRecJS():void{
			if(_state =="paused_rec"){
				onResumeRecording();
			}
		}
		
		public function onClickStopJS():void{
			if(_btRecordAndStop.enabled == true){
				if(_state !="idle" && _state !="paused" && _state !="played"){
					onClickRecordAndStop();	
				}
			}
		}
		
		public function onClickPlayJS():void{
			if(_btPlay.enabled == true){
				if(_state != "playing"){
					onClickPlay();	
				}
			}
		}
		
		public function onClickPauseJS():void{
			if(_btPlay.enabled == true){
				if(_state != "paused" && _state != "played"){
					onClickPlay();	
				}
			}
		}
		
		public function onGetStreamNameJS():String{
			if(_streamName && _streamName != ""){
				return _streamName;
			}
			return "";
		}
		
		public function onGetStreamTimeJS():Number{
			return _lastStreamTime;
		}
		
		public function onGetPlaybackTimeJS():Number{
			if((_state=="playing" || _state=="paused" || _state == "played") && nss != null){
				return nss.time;
			}else{
				return 0;
			}
		}
		//[-] the JS CONTROL API
		
		private function onSelectDevicesFSClosed(e:Event=null):void{
			trace("HDFVR.onSelectDevicesFSClosed()");
			if(contains(_FSDeviceSelector)){
				removeChild(_FSDeviceSelector);
			}
			_FSDeviceSelector = null;
		}
		
		private function onSelectDevicesFS(e:CustomEvent):void{
			trace("HDFVR.onSelectDevicesFS( "+e.data["camIndex"]+", "+e.data["micIndex"]+")")
			
			if(contains(_FSDeviceSelector)){
				removeChild(_FSDeviceSelector);
				_FSDeviceSelector = null;
			}
			
			setCameraAndMicrophone(e.data["camIndex"], e.data["micIndex"]);
			
			//we might have to build the recording UI if the fullscreen device selector screen has just been closed
			buildInterface();
			
		}
		
		private function camOrMicSettingsSubmited(e:CustomEvent):void{
			trace("HDFVR.camOrMicSettingsSubmited()");
			
			if(contains(_camOrMicSettings)){
				removeChild(_camOrMicSettings);
				_camOrMicSettings = null;
			}
			if(e.data["type"] == "cam"){
				setCamera(e.data["camIndex"]);	
			}else{
				setMicrophone(e.data["micIndex"]);	
			}
			
		}
		
		private function setCameraAndMicrophone(camIndex:String, micIndex:String):void{	
			trace("setCameraAndMicrophone("+arguments.join(",")+")")
			
			if(_hasCam){
				if(camIndex && camIndex!=mySharedObject.data.cam_index){
					mySharedObject.data.cam_index = camIndex;
					_camera = Camera.getCamera(camIndex);
					cameraSetup();
					//_video.attachCamera(null);
					//_video.clear();
					
					_video.attachCamera(_camera);	
					
					if(ns){
						//ns.attachCamera(null);
						if(_hasCam){
							ns.attachCamera(_camera);	
						}
					}
				}
			}
			
			if(micIndex && micIndex!=mySharedObject.data.mic_index){
				mySharedObject.data.mic_index= micIndex;
				if(!_disableMicrophoneRecording){
					_mic = Microphone.getMicrophone(int(micIndex));
					micSetup();
					if(ns){
						ns.attachAudio(null);
						ns.attachAudio(Microphone.getMicrophone(int(micIndex)));
					}
				}
			}
			
			//flush fails when user denied local storage in Flash Player's settings
			try{
				mySharedObject.flush();
			}catch(error:Error){
				trace("Error saving selected devices, user might have denied local storage")
			}
		}
		
		private function setCamera(camIndex:String):void{
			trace("setCamera " + camIndex);
			if(_hasCam){
				if(camIndex && camIndex!=mySharedObject.data.cam_index){
					mySharedObject.data.cam_index = camIndex;
					_camera = Camera.getCamera(camIndex);
					cameraSetup();
					_video.attachCamera(_camera);	
					if(ns){
						if(_hasCam){
							ns.attachCamera(_camera);	
						}
					}
				}
			}
			//flush fails when user denied local storage in Flash Player's settings
			try{
				mySharedObject.flush();
			}catch(error:Error){
				trace("Error saving selected devices, user might have denied local storage")
			}
		}
		
		private function setMicrophone(micIndex:String):void{
			trace("setMicrophone " + micIndex);
			if(micIndex && micIndex!=mySharedObject.data.mic_index){
				mySharedObject.data.mic_index= micIndex;
				if(!_disableMicrophoneRecording){
					_mic = Microphone.getMicrophone(int(micIndex));
					micSetup();
					if(ns){
						ns.attachAudio(null);
						ns.attachAudio(Microphone.getMicrophone(int(micIndex)));
					}
				}
			}
			//flush fails when user denied local storage in Flash Player's settings
			try{
				mySharedObject.flush();
			}catch(error:Error){
				trace("Error saving selected devices, user might have denied local storage")
			}
			_sld.micHasSound = false;
		}
		
		private function addToolTip(o:Object):void{
			o.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverBt);
			o.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutBt);
		}
		
		private function onMouseOverBt(e:MouseEvent):void{
			var pos:String ="left";
			if(e.target.position){
				pos = e.target.position;
			}
			if (e.target.name!=null && e.target.name!="" && e.target.enabled == true){
				_tt = new ToolTip(e.target.name, pos,_normalColor, bgColor, roundedCorner);
				if(pos == "left"){
					_tt.x= e.target.x + e.target.width/2 - 10;
				}else{
					_tt.x= e.target.x + e.target.width/2 - 5;	
				}
				_tt.y= _spMenuContainer.y + e.target.y-_tt.height + 2;
				addChild(_tt);
			}	
		}
		
		private function onMouseOutBt(e:MouseEvent):void{
			if (_tt && contains(_tt)){
				removeChild(_tt)
			}
		}
		
		private function keyHandler( e:KeyboardEvent ):void {
			trace("HDFVR.keyHandler "+e.keyCode);
			if (_btRecordAndStop != null && _btRecordAndStop.enabled == true && e.keyCode == 32) {// the space bar was realesed
				onClickRecordAndStop();
			}
		}
		
		private function positionControls():void{
			trace("HDFVR.positionControls("+stage.stageHeight+")")
			
			if(_showMenu){
				if (_btPlay){
					_btPlay.x = _btRecordAndStop.x + _btRecordAndStop.width;
				}
				if (_btSave){
					_btSave.x = _btPlay.x + _btPlay.width;
				}
				
				if (_scrubBar){
				var spaces:int =5;
				if (Number(ApplicationData.getInstance().avc_settings["hideSaveButton"])==1){
					spaces--;
				}
				if (Number(ApplicationData.getInstance().avc_settings["hidePlayButton"])==1){
					spaces--;
				}
				if(_disableMicrophoneRecording){
					spaces--;
				}
				
				if(Number(ApplicationData.getInstance().avc_settings["hideSaveButton"])==1 && Number(ApplicationData.getInstance().avc_settings["hidePlayButton"])==1){	
					_scrubBar.setWidth(stage.stageWidth - 2*PADDING- BUTTON_WIDTH * spaces);
					_scrubBar.x = _btRecordAndStop.x + BUTTON_WIDTH;
				} else if (Number(ApplicationData.getInstance().avc_settings["hideSaveButton"])==1){
					_scrubBar.setWidth(stage.stageWidth - 2*PADDING- BUTTON_WIDTH * spaces );
					_scrubBar.x = _btPlay.x + BUTTON_WIDTH;
				} else if (Number(ApplicationData.getInstance().avc_settings["hidePlayButton"])==1){
					_scrubBar.setWidth(stage.stageWidth - 2*PADDING- BUTTON_WIDTH * spaces);
					_btSave.x = _btPlay.x;
					_scrubBar.x = _btSave.x + BUTTON_WIDTH;
				} else{
					_scrubBar.setWidth(stage.stageWidth - BUTTON_WIDTH * spaces);
					_scrubBar.x = _btSave.x + BUTTON_WIDTH;
				}
				}
				if (_spMenuContainer){
					_spMenuContainer.y = stage.stageHeight-PADDING- _spMenuContainer.height;
					_spMenuContainer.x = PADDING;
				}
			}else{
				if (_btCamSettings && _sVideoArea){
					_btCamSettings.y = _sVideoArea.y+_sVideoArea.height -_btCamSettings.height;
					_btMicSettings.y = _btCamSettings.y;
				}
			}
			if (_btCamSettings && _btMicSettings){
				_btCamSettings.x = stage.stageWidth-2*PADDING-_btCamSettings.width;
				_btMicSettings.x = _btCamSettings.x - _btMicSettings.width;
			}
		}
		
		private function positionFps():void{
			trace("HDFVR.positionFps()")
			if (_fpsCounter){
				if(_showMenu){
					_fpsCounter.y = _spMenuContainer.y - _txTime.height - PADDING;	
				}else{
					_fpsCounter.y = _sVideoArea.y+_sVideoArea.height - PADDING-_fpsCounter.height;
				}
				_fpsCounter.x = _sVideoArea.x+PADDING;
			}
		}
		
		private function positionTimer():void{
			trace("HDFVR.positionTimer()")
			
			//position the timer
			if (_txTime){
				if(_showMenu){
					_txTime.y = _spMenuContainer.y;	
				}else{
					_txTime.y = _sVideoArea.y + _sVideoArea.height - PADDING - _txTime.height;
				}
				_txTime.x = _sVideoArea.x+(_sVideoArea.width - _txTime.width)/2;
			}
						
			//here we also reposition the Pipe copyright
			if(_showPipeCopyright){
				_byPipeText.x = (stage.stageWidth - _byPipeText.width)/2;
				if(_showMenu == true){
					_byPipeText.y = stage.stageHeight - _byPipeText.height - 35;	
				}else{
					_byPipeText.y = stage.stageHeight - _byPipeText.height - 15;
				}
			}
		}
		
		private function uploadFinished():void{
			trace("HDFVR.uploadFinished()")
			//_video.attachCamera(null);
			if(showFps){
				_fpsCounter.visible = true;
			}
			_state="idle";
			
			//reseting the play button if the video was paused during recording
			_btPlay.setIcon(icon_play);
			_btPlay.name = Locale.loadString("IDS_TXT_PLAY");
			_btPlay.enabled = true;
			_btPlay.setClickEventName("ON_PLAY_PRESS");
			addEventListener("ON_PLAY_PRESS",onClickPlay);
			addToolTip(_btPlay);
			
			if(recordAgain){
				//_btRecord.label = Locale.loadString("IDS_BT_RECORD_AGAIN");
				_btRecordAndStop.setIcon(icon_record,"rec");
				_btRecordAndStop.name = Locale.loadString("IDS_BT_RECORD_AGAIN");
				_btRecordAndStop.enabled = true;
			}else{
				//            		_btRecord.label = Locale.loadString("IDS_BT_RECORD");
				_btRecordAndStop.enabled = false;
				_btRecordAndStop.setIcon(icon_record,"rec");
				_btRecordAndStop.name = Locale.loadString("IDS_TXT_RECORD");;
			}
			_btPlay.enabled = true
			enableSaveButton();
			//we save the snapshot
			if(jpgSource){
				//_jpgName = _streamName;
				saveSnapshot();
			}else{
				
				if(_autoSave){
					var text:String ="Saving...";
					if(Locale.loadString("IDS_TXT_SAVING")){
						text = Locale.loadString("IDS_TXT_SAVING");
					}
					addChild(_alertBox);
					_alertBox.setTextLabel(text);
					
					onClickSave();
				}else{
					if(_alertBox && contains(_alertBox)){
						setTimeout(removeChild,1000,_alertBox);	
					}
				}
				
			}
			
			
			if(_chmodStream != ""){
				//se set the permissions on the new flv file
				nc.call("chmodStream",null,_streamName,_chmodStream);
			}
			
			_lastDuration = _lastStreamTime;
			_intialBufferLength = 0;
			_timeElapsed = 0;
			
			//detect filetype and video codec	
			var videoCodec:String = "Sorenson";	
			var fileType:String = "flv";
			
			if(_h264Enabled){
				videoCodec = "H.264";
			}
			
			if(_mediaServer == 1){
				if(_h264Enabled){
					fileType = "f4v";
				}
			}else if(_mediaServer == 4){
				if(_h264Enabled){
					fileType = "mp4";
				}
			}
			
			ExternalInterface.call( "onUploadDone",_streamName,_lastDuration,ApplicationData.getInstance().avc_settings["userId"],recorderId,_audioCodec, videoCodec, fileType);
			
			_scrubBar.reset();
			_scrubBar.addListeners();
			_scrubBar.setMax(_lastDuration);
			if(ApplicationData.getInstance().avc_settings["countdownTimer"]=="true"){
				_txTime.text = Strings.digits(_limitDuration-_lastDuration)
			}else{
				_txTime.text = Strings.digits(_lastDuration)+" / "+Strings.digits(_limitDuration)
			}
			_txTime.text = "00:00 / "+Strings.digits(_lastDuration)
			if(autoPlay){
				onClickPlay();
			}else{
				ns.close()
			}
						
			_actualStreamTime = 0;
			
			//delaying the call to make sure the FLV is finalized, otherwise FFmpeg won't be able to convert it to MP4.
			setTimeout(convertFLV,3000);
		}
		
		private function convertFLV():void{
			if(_enableFFMPEGConverting){
				nc.call("convertFLV",null,_streamName, _ffmpegCmd, _accountHash);	
			}
		}
		
		private function timedFunction(e:TimerEvent):void{	
			//trace("timedFunction " + _state);	
			if (_state=="idle"){
				    //alertBox.fadeAlertBox(_recorderContainer);
					if(_camera){
				 	  _fpsCounter.text = Math.round(_camera.currentFPS)+" fps"; 
				 	}
			}else if (_state=="recording"){
				_txTime.visible= this._showTimer;
				
				if(ApplicationData.getInstance().avc_settings["enablePauseWhileRecording"] == 1){
					_lastStreamTime = _actualStreamTime + ns.time;
				}else{
					_lastStreamTime = ns.time;
				}
				
				
				if (ns){
					//if the recording has gone past the max recording time
					if (_lastStreamTime>=Number(_limitDuration)){
						onClickRecordAndStop()
					}
					
					//we enable the stop button when the minimum duration has passed
					if(_lastStreamTime >= Number(_minDuration)){
						_btRecordAndStop.enabled = true;
					}
					
					//we position the scrub button
					_scrubBar.scrubTo(_lastStreamTime);
					
					//we take a snapshot if it passed the snapshot point
					if(_lastStreamTime >= _snapShotSec && _curentSnapshots == 0){
						if(_hasCam){
							takeSnapshot();	
						}
					}
					
					//update the shown timer
					if(ApplicationData.getInstance().avc_settings["countdownTimer"]=="true"){
						_txTime.text = Strings.digits(_limitDuration-_lastStreamTime)
					}else{
						_txTime.text = Strings.digits(_lastStreamTime) +" / "+Strings.digits(_limitDuration)
					}
					
					if(showFps){
						_fpsCounter.visible=true
					}
					_fpsCounter.text = Math.round(ns.currentFPS)+" fps";
					
					//if the buffer fills more than 90% of the available buffer we double the available buffer
					if (ns.bufferLength>=(ns.bufferTime/10)*9){
						ns.bufferTime*=2;
					}
				}else{
					if(ApplicationData.getInstance().avc_settings["countdownTimer"]=="true"){
						_txTime.text = Strings.digits(_limitDuration)
					}else{
						_txTime.text = "00:00 / "+Strings.digits(_limitDuration)
					}
					
					if(showFps){
						_fpsCounter.visible=false
					}
				}
			}else if(_state=="paused_rec"){				
				if (ns){
					_scrubBar.scrubTo(_actualStreamTime);
					
					if(ApplicationData.getInstance().avc_settings["countdownTimer"]=="true"){
						_txTime.text = Strings.digits(_limitDuration-_actualStreamTime)
					}else{
						_txTime.text = Strings.digits(_actualStreamTime) +" / "+Strings.digits(_limitDuration)
					}
					
					if(showFps){
						_fpsCounter.visible=true
					}
					_fpsCounter.text = Math.round(ns.currentFPS)+" fps";
					
					if (ns.bufferLength>=(ns.bufferTime/10)*9){
						ns.bufferTime*=2;
					}
					
				}else{
					if(ApplicationData.getInstance().avc_settings["countdownTimer"]=="true"){
						_txTime.text = Strings.digits(_limitDuration)
					}else{
						_txTime.text = "00:00 / "+Strings.digits(_limitDuration)
					}
					
					if(showFps){
						_fpsCounter.visible=false
					}
				}
				
			}else if (_state == "uploading"){
				if(_intialBufferLength == 0){
				 	_intialBufferLength  = ns.bufferLength; 
				}
				_timeElapsed += 1/10;
				trace("time elapsed "+_timeElapsed);
				trace("time buffer length "+ns.bufferLength);
				if(showFps){
					_fpsCounter.visible=false
				}
				var estimatedTime:Number = 0;
				
				if(_intialBufferLength - ns.bufferLength >= 0){
					estimatedTime = 100 - Math.round((ns.bufferLength /_lastStreamTime * 100));
				}else if(_intialBufferLength - ns.bufferLength < 0){
					estimatedTime = 0;
				}
				
				addChild(_alertBox)
				_alertBox.setTextLabel(Locale.loadString("IDS_TXT_UPLOAD") + estimatedTime + "%",true);
			
				if(ns.bufferLength == 0 && this.majorVersion == 11 && this.minorVersion > 1){
					
					this.uploadFinished();
		
				}
			
			}else if (_state=="playing" || _state=="paused" ){
				_scrubBar.scrubTo(nss.time);
				if(showFps){
					_fpsCounter.visible=true
				}
				
				_fpsCounter.text = Math.round(nss.currentFPS)+" fps";
				
				_txTime.visible= this._showTimer;
			
				_txTime.text = Strings.digits(nss.time) +" / "+Strings.digits(_lastDuration)

				
			}else if (_state=="saving"){
				if(showFps){
					_fpsCounter.visible=false
				}
			}
			//trace("SOUND LEVEL " + _mic.activityLevel);
			if (_sld && _mic){
				if(_mic.activityLevel >= 0 || _sld.micHasSound == true){
					_sld.stopWarning();
					_sld.micHasSound = true;
					_sld.level = _mic.activityLevel;		
				}else if(_sld.micHasSound == false){
					_sld.noSound();	
				}
					
				if(ExternalInterface.available){
					ExternalInterface.call("onMicActivityLevel",recorderId, _mic.activityLevel);
				}
			}
			if(ExternalInterface.available){
				ExternalInterface.call("onFPSChange",recorderId, _fpsCounter.text.replace(" fps",""));
			}
			
			if(_camera){
				if(_camera.currentFPS <= Number(ApplicationData.getInstance().xmlStreamSettings.item.fps.text()[0]) * 75/100 && _state != "playing" && _btCamSettings.contains(_fpsTracker)){
					_fpsTracker.graphics.clear();
					_fpsTracker.graphics.beginFill(0xFFAE00,1);
					_fpsTracker.graphics.drawRect(0,0,4,3);
					_fpsTracker.graphics.endFill();
					
					if(_fpsTracker.visible){
						_fpsTracker.visible = false;
					}else{
						_fpsTracker.visible = true;
					}
					
				}else{
					_fpsTracker.graphics.clear();
					_fpsTracker.graphics.beginFill(0x00FF00,1);
					_fpsTracker.graphics.drawRect(0,0,4,3);
					_fpsTracker.graphics.endFill();
					
					_fpsTracker.visible = true;
				}
			}else{
				_fpsTracker.graphics.clear();
				if(_btCamSettings.contains(_fpsTracker)){
					_btCamSettings.removeChild(_fpsTracker);	
				}
			}
		}
		
		private function onResponderReply(result:Object):void{
			trace("HDFVR.onResponderReply("+result+")")
		}
		
		private function onClickRecordAndStop(e:Event=null):void{
			trace("HDFVR.onClickRecordAndStop() _state="+_state)
			if (_state=="idle" || _state=="playing" || _state=="paused" || _state=="played"){ 					
				_btRecordAndStop.enabled = false;
				if(!nc || !nc.connected){
					//if its not connected we try to connect first
					_scrubBar.enabled = false;
					establishNetConnection();
				}else{
					//if it is connected we jump the connection step, this happens when you record the second time
				 	startRecording()
				}
			}else if (_state=="recording"){
				//stop recording and switch to uploading
				_state="uploading"
				
				if(_video){
					_video.smoothing = true;
				}
				
				//dont loopback the mic anymore
				if(_mic){
					_mic.setLoopBack(false);
					_mic.setUseEchoSuppression(false);
				}
				
				//show the last frame
				//var lf:BitmapData = new BitmapData(_video.videoWidth,_video.videoHeight);
				//lf.draw(_video);
				
				if(_hasCam){
					_lastFrame=new Bitmap(jpgSource);
					
					_lastFrame.width = _video.width;
					_lastFrame.height = _video.height;
					
					_lastFrame.x = _video.x;
					_lastFrame.y = _video.y;
					
					if (_mirrorVideoStreamDuringRecording){
						trace("_lastFrame.scaleX="+_lastFrame.scaleX)
						if (_lastFrame.scaleX>=0){
							_lastFrame.scaleX *=-1;
						}
						trace("_lastFrame.scaleX="+_lastFrame.scaleX)
						//_lastFrame.x-=_lastFrame.width/2
					}
					
					//we add the last frame above the _video
					//if(_mirrorVideoStreamDuringRecording == false){
						_sVideoArea.addChild(_lastFrame);	
					//}
					
					//we add the playback video area over the frame
					_sVideoArea.addChild(_videoPlayback);
				}
				
				_btRecordAndStop.enabled = false
				
				var recSprite:Object = _recorderContainer.getChildByName("rec_sprite");
				if(recSprite){
					_recorderContainer.removeChild(Sprite(recSprite));
					recSprite = null;
				}
				
				//we attach no data to the net stream so that all data is sent to the media server		
				if(ns){
					trace("HDFVR::video publish");
					ns.attachAudio(null);
					ns.attachCamera(null);
					
				}else{
					trace("WARNING: no ns object when Stop Recording pressed")
				}
				
				ExternalInterface.call( "btStopRecordingPressed",recorderId);
				
				if(_btCamSettings.contains(_fpsTracker)){
					_btCamSettings.removeChild(_fpsTracker);	
				}
			}
		}
		
		public function setHD():void{
			trace("HDFVR.setHD()")
			_hdAcces = true;
		}
		
		//called by the media server after conversion with FFMPEG finished
		public function conversionFinished(status:String, streamName:String):void{
			trace("HDFVR.conversionFinished()" + status + " " + streamName);
			if(ExternalInterface.available){
				ExternalInterface.call( "onFFMPEGConversionFinished",recorderId,status, streamName);
			}
		}
		
		
		private function conversionResponse(event:Event):void{
			trace("HDFVR.conversionResponse("+event.target.data+")");
			
			if(ExternalInterface.available){
				ExternalInterface.call( "onFFMPEGConversionFinished",recorderId,"success", _streamName);
			}
		}
				
		private function conversionError(event:Event):void{
			trace("HDFVR.conversionError()");
		}
		
		
		//this function is called by the media server after it checks everything related to the key,licensed domain, expiration logic
		public function afterKeyCheck():void{
			trace("HDFVR.afterkeyCheck()")
			nextStep="record" 
			nextStepAfterConnection()
		}
		
		//wowza and red5 call some functions in the client before the Connect.Success onStatus message arrives thus sucha  function is needed 
		public function nextStepAfterConnection():void{
			trace("HDFVR.nextStepAfterConnection() nextStep="+nextStep+", connection="+nc.connected)
			if (nc.connected){
				if (nextStep=="record"){
					startRecording()
				}else if (nextStep=="asklicensekey"){
				    VLK();
				}
			}
		}
		
		private function startRecording(isResumedRecording:Boolean = false):void{
			trace("HDFVR.startRecording() _hdAcces="+_hdAcces)
						
			_state="recording"
			
			//we loopback the mic if needed
			if (ApplicationData.getInstance().avc_settings["loopbackMic"]=="true"){
				_mic.setLoopBack(true);
				_mic.setUseEchoSuppression(true);
			}
				
			//we reset the save button
			_btSave.canBeUsed=true;
			_scrubBar.enabled = true;
			_txTime.alpha = 1;
			
			if(_lastDuration != 0 && isResumedRecording == false){
				//another recording erase the old one
				ns.close();
				
				//we hide the playback area
				if(_videoPlayback){
					_videoPlayback.visible = false;	
				}
				
				//we remove the last frame
				if (_lastFrame && _sVideoArea.contains(_lastFrame) /*&& _mirrorVideoStreamDuringRecording == false*/){
					_sVideoArea.removeChild(_lastFrame);
				}
				
				//_video.clear();
				//_video.attachCamera(_camera);
				_scrubBar.setMax(_limitDuration);
				responder = new Responder(onResponderReply);
				if(_streamName != "" && deleteUnsavedFlv && isResumedRecording == false){
					nc.call("removeOldFiles", responder, _streamName);
				}
				if (_fixedName==false){
					if(isResumedRecording == false){
						_streamName = "";	
					}else{
						//streamname stays the same;
					}
					
				}
				_curentSnapshots=0;
			}
			
			
			if(!_hdAcces && (ApplicationData.getInstance().xmlStreamSettings.item.w.text()[0] > 640 || ApplicationData.getInstance().xmlStreamSettings.item.h.text()[0] > 480)){
				if(_hasCam){
					_camera.setMode(640,480,ApplicationData.getInstance().xmlStreamSettings.item.fps.text()[0]);
				}					
				_ratio = 480/640;
				onStageResize();
				_alertBox.setTextLabel(Locale.loadString("IDS_TXT_SD"));
				addChild(_alertBox)
				setTimeout(removeChild,4000,_alertBox);
			}else{
				if (contains(_alertBox)){
					removeChild(_alertBox)
				}
			}
			
			//we change the record button to STOP
			_btRecordAndStop.setIcon(icon_stop,"stop");
			_btRecordAndStop.name = Locale.loadString("IDS_TXT_STOP");
			
			//call external interface
			if(!isResumedRecording){
				ExternalInterface.call( "btRecordPressed",recorderId);	
			}
			
			//disable the save and play buttons
			_btSave.enabled = false;
			_btPlay.enabled=false;
			
			//make the sound lvel display visible
			if(_sld){
				_sld.visible = this._showSoundBar;
			}
			//create a new stream
			ns =  new NetStream(nc);
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			ns.client = this;
			
			ns.attachAudio(_mic);
			
			if(_hasCam){
				ns.attachCamera(_camera);	
			}
			
			if(this._h264Enabled == true){
		    	var h264Settings:H264VideoStreamSettings = new H264VideoStreamSettings();
		    	h264Settings.setProfileLevel(H264Profile.MAIN, H264Level.LEVEL_4);
				ns.videoStreamSettings = h264Settings;
			}
			
			ns.bufferTime = Number(ApplicationData.getInstance().avc_settings["outgoingBuffer"])
			if(_streamName == "" && isResumedRecording == false){
				_streamName = _streamPrefix+_userPrefix+new Date().getTime()+'_'+Math.round(Math.random()*1000);
			}
			//if the file is to be deleted if unsaved...
			if(deleteUnsavedFlv && isResumedRecording == false){
				responder = new Responder(onResponderReply);
				nc.call("setStreamName", responder,_streamName);
			}
			
			//we publish the stream. If it's Wowza or FMS we use the mp4: prefix. Red5 does not know how to record to mp4.
			
			var publishType:String = "record";
			if(ApplicationData.getInstance().avc_settings["enablePauseWhileRecording"] == 1){
				publishType = "append";
			}
			
			if(this._h264Enabled == true){
				if (this._mediaServer == this.FMS){
					ns.publish("mp4:"+_streamName+".f4v",publishType);
				}else if (this._mediaServer == this.WOWZA || this._mediaServer == this.WOWZA_TRANSCODER){
					//Wowza will add automatically the mp4 extension if we publish with mp4: but for now we'll let Wowza create .flv files
					ns.publish(_streamName,publishType);
				}else{
					//Red5 does not know how to record top mp4 so we record to .flv
					ns.publish(_streamName,publishType);
				}
				
			}else{
				ns.publish(_streamName,publishType);	
			}
			
			if(isResumedRecording == false){
				if(ExternalInterface.available){
					ExternalInterface.call( "onRecordingStarted",recorderId);
				}
			}
			
			//we add the recording logo
			if(ApplicationData.getInstance().avc_settings["enableBlinkingRec"] == 1){
				addRecSprite(_recorderContainer);	
			}
			
			//we take the snapshot if needed
			if(_snapShotSec <= 0){
				if(_hasCam){
					takeSnapshot();	
				}
			}
			
			
			if(ApplicationData.getInstance().avc_settings["enablePauseWhileRecording"] == 1){
				_btPlay.setIcon(icon_pause);
				_btPlay.name = Locale.loadString("IDS_TXT_PAUSE_RECORDING");
				_btPlay.enabled = true;
				_btPlay.setClickEventName("ON_PAUSE_RECORDING");
				addEventListener("ON_PAUSE_RECORDING",onPauseRecording);
				addToolTip(_btPlay);
			}
			
			//we re-add the tracker
			_btCamSettings.addChild(_fpsTracker);
		}
		
		public function onPauseRecording(e:Event=null):void{
			trace("HDFVR.onPauseRecording");
			
			_state ="paused_rec";
			
			_btPlay.enabled = false;
			
			_btRecordAndStop.setIcon(icon_record,"rec");
			_btRecordAndStop.name = Locale.loadString("IDS_TXT_RESUME_RECORDING");
			_btRecordAndStop.enabled = true;
			_btRecordAndStop.setClickEventName("ON_RESUME_RECORDING");
			addEventListener("ON_RESUME_RECORDING",onResumeRecording);
			addToolTip(_btRecordAndStop);
			
			var recSprite:Object = _recorderContainer.getChildByName("rec_sprite");
			if(recSprite){
				_recorderContainer.removeChild(Sprite(recSprite));
				recSprite = null;
			}
			
			_actualStreamTime = _lastStreamTime;
						
			ns.attachAudio(null);
			ns.attachCamera(null);
			
			if(ExternalInterface.available){
				ExternalInterface.call( "btPauseRecordingPressed",recorderId);
			}
		}
		
		public function onResumeRecording(e:Event=null):void{
			trace("HDFVR.onResumeRecording");
			
			_btRecordAndStop.setIcon(icon_stop,"stop");
			_btRecordAndStop.name = Locale.loadString("IDS_TXT_STOP");
			
			if(_lastStreamTime >= Number(_minDuration)){
				_btRecordAndStop.enabled = true;
			}else{
				_btRecordAndStop.enabled = false;
			}
			
			_btRecordAndStop.setClickEventName("ON_RECORD_PRESS");
			addEventListener("ON_RECORD_PRESS",onClickRecordAndStop);
			addToolTip(_btRecordAndStop);
			
			_btPlay.setIcon(icon_pause);
			_btPlay.name = Locale.loadString("IDS_TXT_PAUSE_RECORDING");
			_btPlay.enabled = true;
			_btPlay.setClickEventName("ON_PAUSE_RECORDING");
			addEventListener("ON_PAUSE_RECORDING",onPauseRecording);
			addToolTip(_btPlay);
			
			if(ExternalInterface.available){
				ExternalInterface.call( "btResumeRecordingPressed",recorderId);
			}
			
			startRecording(true);
		}
		
		//this function seems to be used by FMS when playing/recording h264 video
		public function onTimeCoordInfo(info:Object):void {	
		}
		
		private function recAgainTimer(e:TimerEvent):void{
			trace("HDFVR.recAgainTimer()")
			if(_camera && _camera.currentFPS != 0){
				trace("start rec again");
				e.target.removeEventListener(TimerEvent.TIMER,recAgainTimer);
				e.target.stop();
				startRecording();
			}
		}
		
		private function addRecSprite(parent:Object):void{
			trace("HDFVR.addRecSprite()")
			_recSprite = new Sprite();
			_recSprite.name = "rec_sprite";
			
			
			var recRound :Sprite = new Sprite(); 
			recRound.name = "rec_round"
			recRound.graphics.beginFill(0xf53333,1);
			recRound.graphics.drawCircle(0,0,5);
			recRound.graphics.endFill();
			//recRound.filters = [_glowFilter]
			
			var recText :TextField = new TextField();
			recText.defaultTextFormat = new TextFormat("_sans",10,0xFFFFFF,null,null,null,null,null,"left");
			recText.text = "REC";
			recText.selectable = false;
			//recText.filters = [_glowFilter]
			
			var recSpriteTimer :Timer = new Timer(500);
			recSpriteTimer.addEventListener(TimerEvent.TIMER,recFlashTimer);
			recSpriteTimer.start();
			
			
			_recSprite.addChild(recText);
			_recSprite.addChild(recRound);
			
			recText.x = 10;
			recText.y = -9;
			parent.addChild(_recSprite);
			alignRecSprite()
		}
		
		private function alignRecSprite():void{
			trace("HDFVR.alignRecSprite()")
			if(_recSprite){
				_recSprite.x = _sVideoArea.x + 15;
				_recSprite.y = _sVideoArea.y + 15;
			}
		}
		
		private function recFlashTimer(e:TimerEvent):void{
			trace("HDFVR.recFlashTimer()")
			var target:Object = e.currentTarget; 
			if(_recorderContainer){
				var recSprite:Object = _recorderContainer.getChildByName("rec_sprite");
				if(recSprite is DisplayObjectContainer){
								recSprite.visible = (recSprite.visible == true)?false:true; 
				}else{
					target.removeEventListener(TimerEvent.TIMER,recFlashTimer);
				}
			} 
		}
		
		private function takeSnapshot(e:MouseEvent = null):void{
			trace("HDFVR.takeSnapshot()")
			if(_snapshotEnabled ){
				ExternalInterface.call( "onSnapshotTaken",recorderId);
				
				jpgSource = new BitmapData(_video.videoWidth,_video.videoHeight);
				jpgSource.draw(_video);
				jpgEncoder = new JPGEncoder(90);
				
				_curentSnapshots += 1;
			}
		}
		
		private function downContainerSnapshot(e:MouseEvent):void{
			trace("HDFVR.downContainerSnapshot()");
			Sprite(e.currentTarget).startDrag(false,new Rectangle(0,0,stage.stageWidth,stage.stageHeight));
		} 
		
		private function upContainerSnapshot(e:MouseEvent):void{
			trace("HDFVR.upContainerSnapshot()");
			Sprite(e.currentTarget).stopDrag();
		}
		
		private function saveSnapshot():void{
			trace("HDFVR.saveSnapshot()");
			var header:URLRequestHeader = new URLRequestHeader("Content-type", "application/octet-stream");
			var jpgURLRequest:URLRequest = new URLRequest("jpg_encoder_download."+ApplicationData.getInstance().sscode+"?name="+_streamName+".jpg"+"&recorderId="+recorderId + "&authenticity_token=" + _auth_token);
			jpgURLRequest.requestHeaders.push(header);
			jpgURLRequest.method = URLRequestMethod.POST;
			jpgStream = jpgEncoder.encode(jpgSource);
			jpgURLRequest.data = jpgStream;
			var scriptLoader:URLLoader = new URLLoader();
			scriptLoader.dataFormat = URLLoaderDataFormat.BINARY;
			scriptLoader.addEventListener(Event.COMPLETE, snapshotLoadSuccessful);
			scriptLoader.addEventListener(IOErrorEvent.IO_ERROR, snapshotLoadError);
			scriptLoader.load(jpgURLRequest);
						
			if(_autoSave){
				var text:String ="Saving...";
				if(Locale.loadString("IDS_TXT_SAVING")){
					text = Locale.loadString("IDS_TXT_SAVING");
				}
				addChild(_alertBox);
				_alertBox.setTextLabel(text);
			}
			
		}
		
		private function snapshotLoadSuccessful(event:Event):void{
			trace("HDFVR.snapshotLoadSuccessful()")
			if (event.target.data == "save=ok"){
				ExternalInterface.call( "onSaveJpgOk", _streamName, ApplicationData.getInstance().avc_settings["userId"],recorderId);
			}else{
				ExternalInterface.call( "onSaveJpgFailed",_streamName, ApplicationData.getInstance().avc_settings["userId"],recorderId);
			}
			
			if(_autoSave){
				onClickSave();
			}else{
				if(_alertBox && contains(_alertBox)){
					setTimeout(removeChild,1000,_alertBox);	
				}
			}
		}
		
		private function snapshotLoadError(event:Event):void{
			trace("HDFVR.onSaveJpgFailed()");
			ExternalInterface.call( "onSaveJpgFailed",_streamName, ApplicationData.getInstance().avc_settings["userId"],recorderId);
		}
		
		public function onClickPlay(e:Event=null):void{
			trace("HDFVR.onClickPlay() _state="+_state);
			if 	(_state=="idle" || _state=="played"){
				//from idle we go into play
				//_video.attachCamera(null);
				//_video.clear();
				if(_sld){
					_sld.visible = false;
				}
				ns.bufferTime = _playBackBuffer;
				_scrubBar.setNetstream(ns);
				_btSave.enabled = false
				_btPlay.setIcon(icon_pause);
				_btPlay.name = Locale.loadString("IDS_TXT_PAUSE");
				_state="playing";
				
				_btRecordAndStop.enabled = false
				
				if(this._mediaServer == this.WOWZA_TRANSCODER && nc2 != null && nc2.connected == true){	
					nss =  new NetStream(nc2)
					nss.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
					nss.client = this;
					//nss.attachAudio(_mic);
					//nss.attachCamera(_camera);
					nss.bufferTime = _playBackBuffer;
					_scrubBar.setNetstream(nss);
				}else{
					nss = ns;
				}	
				
				if(_hasCam){
					_videoPlayback.attachNetStream(nss);
					_videoPlayback.visible = true;	
				}
				
				if(this._h264Enabled == true){
					if (this._mediaServer == this.FMS){
						nss.play("mp4:"+_streamName+".f4v");
					}else if (this._mediaServer == this.WOWZA || this._mediaServer == this.WOWZA_TRANSCODER){
						nss.play(_streamName);
					}else{
						//Red5 does not know how to record top mp4 so we record to .flv
						nss.play(_streamName);
					}
				}else{
					nss.play(_streamName);
				}
				
				ExternalInterface.call( "btPlayPressed",recorderId);
			}else if (_state=="playing"){
				//from play we go into pause
				enableSaveButton();
				//_btPlay.label ="Play"
				_btPlay.name = Locale.loadString("IDS_TXT_PLAY");
				_btPlay.setIcon(icon_play)
				_state="paused"
				if(recordAgain == true){
					_btRecordAndStop.enabled =true
				}
				if(this._mediaServer == this.WOWZA_TRANSCODER && nc2 != null && nc2.connected == true){	
					nss.togglePause() 
				}else{
					ns.togglePause() 
				}
				ExternalInterface.call( "btPausePressed",recorderId);
			}else if (_state=="paused"){
				//from puase we go into play
				_btSave.enabled = false
				//_btPlay.label ="Pause"
				_btPlay.setIcon(icon_pause)
				_state="playing"
				_btRecordAndStop.enabled =false
				if(this._mediaServer == this.WOWZA_TRANSCODER && nc2 != null && nc2.connected == true){	
					nss.togglePause() 
				}else{
					ns.togglePause() 
				}
				ExternalInterface.call( "btPlayPressed",recorderId);
			}
		}
		
		private function onClickSave(e:Event = null):void{
			trace("HDFVR.onClickSave(), _state="+_state);
			
			if(_state == "idle" || _state == "paused" || _state=="played"){
				_previousState=_state;
				_state="saving";
				
				//disable all buttons
				_btSave.enabled = false
				_btRecordAndStop.enabled = false
				_btPlay.enabled = false
				
				//detect filetype and video codec, assume Sorenson and .flv
				var videoCodec:String = "Sorenson";	
				var fileType:String = "flv";
				
				if(_h264Enabled){
					videoCodec = "H.264";
				}
				
				if(_mediaServer == 1){
					if(_h264Enabled){
						fileType = "f4v";
					}
				}else if(_mediaServer == 4){
					if(_h264Enabled){
						fileType = "mp4";
					}
				}
				
				var micName:String = "";
				if(_mic){
					micName = _mic.name;
				}
				
				var camName:String = "";
				if(_camera){
					camName = _camera.name;
				}
				
				var httpReferer:String = ExternalInterface.call("function(){ return document.location.href.toString();}");
				
				var request:URLRequest = new URLRequest("save_video_to_db."+ApplicationData.getInstance().sscode+"?r="+Math.random()+"&streamName="+_streamName+"&streamDuration="+_lastDuration+"&userId="+ApplicationData.getInstance().avc_settings["userId"]+"&recorderId="+recorderId + "&audioCodec=" + encodeURIComponent(_audioCodec) + "&videoCodec=" + encodeURIComponent(videoCodec) + "&fileType=" + fileType + "&accountHash=" + _accountHash + "&payload=" + encodeURIComponent(_payload) + "&authenticity_token=" + _auth_token + "&cameraName=" + encodeURIComponent(camName) + "&microphoneName=" + encodeURIComponent(micName) + "&httpReferer=" + encodeURIComponent(httpReferer) + "&environmentId=" + _environmentId);
				request.method = URLRequestMethod.GET;
				
				//load the request
				var saveRequestLoader:URLLoader = new URLLoader();
				saveRequestLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
				saveRequestLoader.addEventListener(Event.COMPLETE, saveVTDBResponseLoaded);
				saveRequestLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus)
				saveRequestLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				saveRequestLoader.load(request);
				
			}
		}
		
		private function saveVTDBResponseLoaded(event:Event):void{
			trace("HDFVR.saveVTDBResponseLoaded("+event.target.data+")");
			_state=_previousState;
			_previousState="";
			
			var saveResponse:Array = new Array();
			for (var i:* in event.target.data) {
				//trace(i + ":" + event.target.data[i])
				saveResponse[i] = event.target.data[i];
			}
			
			//enable record & play
			if(recordAgain){
				_btRecordAndStop.enabled = true
			}
			_btPlay.enabled = true
			
			if (event.target.data.toString().indexOf("save=failed") != -1 || event.target.data == ""){
				//if the response form the server side script is a negative or empty one
				ExternalInterface.call( "onSaveFailed",_streamName,_lastDuration,ApplicationData.getInstance().avc_settings["userId"],recorderId);
				//enable the save button again
				enableSaveButton();
				//show error box
				addChild(_alertBox)
				//set the label on the alert box
				if(Locale.loadString("IDS_TXT_SAVEFAILED")){
					_alertBox.setTextLabel(Locale.loadString("IDS_TXT_SAVEFAILED"));
				}else{
					_alertBox.setTextLabel("Save failed!");
				}
			}else {
				//if the response form the server side script is NOT a negative or empty one
				
				//the save button can be clicked only once per recording
				_btSave.canBeUsed=false

				//microphone name
				var micname:String = "";
				if(_mic){
					micname = _mic.name;
				}
				
				//detect filetype and video codec, assume Sorenson and .flv
				var videoCodec:String = "Sorenson";	
				var fileType:String = "flv";
				
				if(_h264Enabled){
					videoCodec = "H.264";
				}
				if(_mediaServer == 1){
					if(_h264Enabled){
						fileType = "f4v";
					}
				}else if(_mediaServer == 4){
					if(_h264Enabled){
						fileType = "mp4";
					}
				}
				
				//videoId is used by Pipe
				var videoId:String = "";
				if(event.target.data.toString().indexOf("videoId=") != -1){
					videoId = saveResponse["videoId"];
				}
				
				//call the onSaveOk JS Events API function
				if(_hasCam){
					if(videoId != ""){
						ExternalInterface.call( "onSaveOk",_streamName,_lastDuration,ApplicationData.getInstance().avc_settings["userId"],_camera.name, micname,recorderId,_audioCodec,videoCodec,fileType,videoId);
					}else{
						ExternalInterface.call( "onSaveOk",_streamName,_lastDuration,ApplicationData.getInstance().avc_settings["userId"],_camera.name, micname,recorderId,_audioCodec,videoCodec,fileType);
					}	
				}else{
					if(videoId != ""){
						ExternalInterface.call( "onSaveOk",_streamName,_lastDuration,ApplicationData.getInstance().avc_settings["userId"],"No Camera", micname,recorderId,_audioCodec,videoCodec,fileType,videoId);
					}else{
						ExternalInterface.call( "onSaveOk",_streamName,_lastDuration,ApplicationData.getInstance().avc_settings["userId"],"No Camera", micname,recorderId,_audioCodec,videoCodec,fileType);	
					}
				}
				
				if(deleteUnsavedFlv){
					//we set the stream name on the server back to "" so that it is not deleted when the user exits
					responder = new Responder(onResponderReply);
					nc.call("setStreamName", responder,"");
				}

				//adding the ok alert box on stage
				 addChild(_alertBox)
				 if(Locale.loadString("IDS_TXT_SAVEOK")){
					 _alertBox.setTextLabel(Locale.loadString("IDS_TXT_SAVEOK"));
				 }else{
					 _alertBox.setTextLabel("Save ok!");
				 }
				setTimeout(removeChild,1000,_alertBox);
				
				//redirect the user if needed or enable the record again button
				if(ApplicationData.getInstance().avc_settings["onSaveSuccessURL"]!=""){
					navigateToURL(new URLRequest(ApplicationData.getInstance().avc_settings["onSaveSuccessURL"]), '_self');
				}else{
					if(recordAgain){
						_btRecordAndStop.enabled = true
					}
				}
			}
		}
		
		private function showFullScreenDevicesSelector(e:Event = null):void{
			trace("HDFVR.showFullScreenDevicesSelector() settingsBox="+_FSDeviceSelector);
			if (!_FSDeviceSelector){
				_FSDeviceSelector =  new AVSettings(mySharedObject.data.cam_index,mySharedObject.data.mic_index,_normalColor,bgColor,_overColor,roundedCorner,_isPPAPIonOSX,_disableMicrophoneRecording);
				_FSDeviceSelector.addEventListener("SETTINGS_SUBMITED", onSelectDevicesFS);
				_FSDeviceSelector.addEventListener("SETTINGS_CLOSED", onSelectDevicesFSClosed);
			}
			addChild(_FSDeviceSelector);
		}
		
		private function onClickCamOrMicSettings(e:Event = null):void{
			trace("HDFVR.onClickCamOrMicSettings()");
				
				if(_camOrMicSettings && contains(_camOrMicSettings)){
					removeChild(_camOrMicSettings);
					_camOrMicSettings = null;
				}
				
				if(e.target.type == "cam"){
					_camOrMicSettings =  new SettingsBox("cam", mySharedObject.data.cam_index, _normalColor, bgColor, roundedCorner);	
				}else{
					_camOrMicSettings =  new SettingsBox("mic", mySharedObject.data.mic_index, _normalColor, bgColor, roundedCorner, _isPPAPIonOSX);
				}
				
				_camOrMicSettings.addEventListener("CAM_SETTINGS_SUBMITED", camOrMicSettingsSubmited);
				_camOrMicSettings.addEventListener("MIC_SETTINGS_SUBMITED", camOrMicSettingsSubmited);
				_sVideoArea.addEventListener(MouseEvent.CLICK, onClickOutside);
				_camOrMicSettings.x= e.target.x + e.target.width/2 - 5;
				_camOrMicSettings.y= _spMenuContainer.y + e.target.y-_camOrMicSettings.height + 2;
				addChild(_camOrMicSettings);
				
				if(_tt && contains(_tt)){
					removeChild(_tt);
				}
		}
		
		private function onClickOutside(e:MouseEvent):void{
			trace("HDFVR.onClickOutside()");
			if(_camOrMicSettings && contains(_camOrMicSettings)){
				removeChild(_camOrMicSettings);
				_camOrMicSettings = null;
			}
		}

		private function netStatusHandler(event:NetStatusEvent):void {
            trace("HDFVR.netStatusHandler("+event.info.code+") _state="+_state);
            if ( _state == 'uploading'){
	            if ((event.info.code == 'NetStream.Buffer.Empty' || event.info.code == 'NetStream.Record.Stop') && ns.bufferLength == 0) {
	            	this.uploadFinished();
	            }
            }
			
			if (_state == 'playing'){
				if(event.info.code == "NetStream.Buffer.Empty" && ns.time < _lastDuration){
					addChild(_alertBox)
					_alertBox.setTextLabel(Locale.loadString("IDS_TXT_BUFFERING"),true);
					buffering = true;
				}
				if(event.info.code == "NetStream.Buffer.Full" && buffering){
					buffering = false;
					if (contains(_alertBox)){
						removeChild(_alertBox)
					}
				}
			}
			lastOnStatusEventCode = event.info.code;
		}
		
		public function onMetaData(info:Object):void {
			trace("HDFVR.onMetaData()  duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
			_lastDuration = info.duration
			_scrubBar.setMax(_lastDuration);
		}
		
		public function onCuePoint(info:Object):void {
			trace("HDFVR.onCuePoint() time=" + info.time + " name=" + info.name + " type=" + info.type);
		}
		
		public function onPlayStatus(info:Object):void{ 
			trace("HDFVR.onPlayStatus() "+info.code );
			if (info.code=="NetStream.Play.Complete"){
				if (contains(_alertBox)){
					removeChild(_alertBox)
				}
				_scrubBar.posCorrectlyAtEnd();
				_state= "played"
				enableSaveButton()
				_btPlay.setIcon(icon_play);
				_btPlay.name = Locale.loadString("IDS_TXT_PLAY");;
				if(recordAgain){
					_btRecordAndStop.enabled =true
				}
				ExternalInterface.call("onPlaybackComplete",recorderId);
			}
		}
		
		public function enableSaveButton():void{
			trace("HDFVR.enableSaveButton()");
			if(ApplicationData.getInstance().avc_settings["hideSaveButton"] == 0 ){
				if (_btSave.canBeUsed){
					_btSave.enabled = true
				}
			}
		}
		
		private function openLink(e:ContextMenuEvent):void{
			trace("HDFVR.openLink()");
			navigateToURL(new URLRequest("https://hdfvr.com?ref=product"));
		}
		
		public function showFPPrivacyHelper():void{
			trace("HDFVR.showFPPrivacyHelper()");
			
			var step1Text:String = "① Select [Allow]";
			var step2Text:String = "② Check Remember";
			var step3Text:String = "③ Click [Close]";
			
			if(Locale.loadString("IDS_SELECT_ALLOW")){
				step1Text = Locale.loadString("IDS_SELECT_ALLOW");
			}
			
			if(Locale.loadString("IDS_CHECK_REMEMBER")){
				step2Text = Locale.loadString("IDS_CHECK_REMEMBER");
			}
			
			if(Locale.loadString("IDS_CLICK_CLOSE")){
				step3Text = Locale.loadString("IDS_CLICK_CLOSE");
			}
			
			_spriteFPPrivacyHelper = new Sprite();
			_spriteFPPrivacyHelper.graphics.beginFill(bgColor, 1);
			_spriteFPPrivacyHelper.graphics.drawRoundRect(0,0,stage.stageWidth, stage.stageHeight,roundedCorner);
			_spriteFPPrivacyHelper.graphics.endFill();
			addChild(_spriteFPPrivacyHelper);
			
			_txtPrivacy1 = new TextField();
			_txtPrivacy1.text = step1Text;
			_txtPrivacy1.selectable = false;
			_txtPrivacy1.setTextFormat(new TextFormat("_sans",14,_normalColor,null,null,null,null,null,TextFormatAlign.LEFT,0,0,0,0));
			_txtPrivacy1.autoSize = "left";
			_txtPrivacy1.x = stage.stageWidth/2 - 135;
			_txtPrivacy1.y = stage.stageHeight/2 - 100;
			_spriteFPPrivacyHelper.addChild(_txtPrivacy1);
			
			_txtPrivacy2 = new TextField();
			_txtPrivacy2.text = step2Text;
			_txtPrivacy2.selectable = false;
			_txtPrivacy2.setTextFormat(new TextFormat("_sans",14,_normalColor,null,null,null,null,null,TextFormatAlign.LEFT,0,0,0,0));
			_txtPrivacy2.autoSize = "left";
			_txtPrivacy2.x = stage.stageWidth/2 - 135;
			_txtPrivacy2.y =  stage.stageHeight/2 + 80;
			_spriteFPPrivacyHelper.addChild(_txtPrivacy2);
			
			_txtPrivacy3 = new TextField();
			_txtPrivacy3.text = step3Text;
			_txtPrivacy3.selectable = false;
			_txtPrivacy3.setTextFormat(new TextFormat("_sans",14,_normalColor,null,null,null,null,null,TextFormatAlign.LEFT,0,0,0,0));
			_txtPrivacy3.autoSize = "left";
			_txtPrivacy3.x = stage.stageWidth/2 + 35;
			_txtPrivacy3.y = _txtPrivacy2.y;
			_spriteFPPrivacyHelper.addChild(_txtPrivacy3);
			
			_lines = new Sprite();
			_spriteFPPrivacyHelper.addChild(_lines);
			_lines.graphics.lineStyle(1,_normalColor,1);
			_lines.graphics.moveTo(stage.stageWidth/2, stage.stageHeight/2 + 10);
			_lines.graphics.lineTo(stage.stageWidth/2 - 127 , stage.stageHeight/2 + 10);
			_lines.graphics.lineTo(stage.stageWidth/2 - 127 , stage.stageHeight/2 - 85);
			
			
			_lines.graphics.moveTo(stage.stageWidth/2, stage.stageHeight/2 + 25);
			_lines.graphics.lineTo(stage.stageWidth/2 - 127 , stage.stageHeight/2 + 25);
			_lines.graphics.lineTo(stage.stageWidth/2 - 127 , stage.stageHeight/2 + 85);
			
			_lines.graphics.moveTo(stage.stageWidth/2 + 43, stage.stageHeight/2);
			_lines.graphics.lineTo(stage.stageWidth/2 + 43, stage.stageHeight/2 + 85);

			fpPrivacyDialogWasShown = true;
			
			//we delay this event assignment since it takes a few ms for FP to show the privacy panel and block onMouseOver events
			setTimeout(assignOnMouseOverEvent,50);
		}
		
		private function assignOnMouseOverEvent():void{
			trace("HDFVR.assignOnMouseOverEvent()");
			//when onMouseOver triggers it means the webcam privacy screen is closed.
			stage.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		}
		
		private function removeFPPrivacyHelper():void{
			trace("HDFVR.removeFPPrivacyHelper()");
			_spriteFPPrivacyHelper.removeChild(_txtPrivacy1);
			_spriteFPPrivacyHelper.removeChild(_txtPrivacy2);
			_spriteFPPrivacyHelper.removeChild(_txtPrivacy3);
			_spriteFPPrivacyHelper.removeChild(_lines);
			_txtPrivacy1 = null;
			_txtPrivacy2 = null;
			_txtPrivacy3 = null;
			_lines = null;
			this.removeChild(_spriteFPPrivacyHelper);
			_spriteFPPrivacyHelper = null;
			
			if (bringUpDeviceSelector){
				//if we need to select between different devices we'll show that next
				showFullScreenDevicesSelector();
			}else if (!_recorderContainer){
				//if there is only one webcam and microphone (or the preferred devices are used) we'll build the interface
				buildInterface();
			}
		}
		
		/**  
		* According to stackoverflow.com/questions/6945055/flash-security-settings-panel-listening-for-close-event
		* when the webcam privacy screen is shown, mouse events are disabled.
		* Which is why this function will trigger when the webcam privacy screen is closed.
		*/

		private function onMouseOver(e:MouseEvent):void{
			trace("HDFVR.onMouseOver()");
			//extra check if the mouse cursor is in the Flash content area
			if (e.stageX >= 0 && e.stageX < stage.stageWidth && e.stageY >= 0 && e.stageY < stage.stageHeight){

				//we remove the onMouseOver listener
				stage.removeEventListener(MouseEvent.MOUSE_OVER,onMouseOver);

				//remove the privacy helper
				removeFPPrivacyHelper();
			}
		}
		
		private function onResizePermissionScreen():void{
			
			if(_spriteFPPrivacyHelper && contains(_spriteFPPrivacyHelper)){
				_spriteFPPrivacyHelper.graphics.clear();
				_spriteFPPrivacyHelper.graphics.beginFill(bgColor, 1);
				_spriteFPPrivacyHelper.graphics.drawRoundRect(0,0,stage.stageWidth, stage.stageHeight,roundedCorner);
				_spriteFPPrivacyHelper.graphics.endFill();
				
				_txtPrivacy1.x = stage.stageWidth/2 - 135;
				_txtPrivacy1.y = stage.stageHeight/2 - 100;
				
				_txtPrivacy2.x = stage.stageWidth/2 - 135;
				_txtPrivacy2.y =  stage.stageHeight/2 + 80;
				
				_txtPrivacy3.x = stage.stageWidth/2 + 35;
				_txtPrivacy3.y = _txtPrivacy2.y;
				
				_lines.graphics.clear();
				_lines.graphics.lineStyle(1,_normalColor,1);
				_lines.graphics.moveTo(stage.stageWidth/2, stage.stageHeight/2 + 10);
				_lines.graphics.lineTo(stage.stageWidth/2 - 127 , stage.stageHeight/2 + 10);
				_lines.graphics.lineTo(stage.stageWidth/2 - 127 , stage.stageHeight/2 - 85);
				
				
				_lines.graphics.moveTo(stage.stageWidth/2, stage.stageHeight/2 + 25);
				_lines.graphics.lineTo(stage.stageWidth/2 - 127 , stage.stageHeight/2 + 25);
				_lines.graphics.lineTo(stage.stageWidth/2 - 127 , stage.stageHeight/2 + 85);
				
				_lines.graphics.moveTo(stage.stageWidth/2 + 43, stage.stageHeight/2);
				_lines.graphics.lineTo(stage.stageWidth/2 + 43, stage.stageHeight/2 + 85);
			}
		}
		
		private function dummyMicSampleEvent(e:SampleDataEvent):void{
			//it's a dummy, dummy
		}
	}
}