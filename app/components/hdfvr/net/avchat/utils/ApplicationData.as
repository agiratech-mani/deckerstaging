package net.avchat.utils
{
	import flash.events.*;
	import flash.net.*;
	import flash.text.StyleSheet;
	   
	public class ApplicationData extends EventDispatcher
	{
		private static var instance:ApplicationData;
		private static var allowInstantiation:Boolean;
		public var css:StyleSheet
		public var avc_settings:Array = new Array;
		public var diffBetweenLocalAndRemoteTime:Number=0;
		private var loader:URLLoader;
		public var myInternalId:Number=-1;
		public var blockedUsers:Array=[];
		public var xmlStreamSettings:XML;
		public var sscode:String="php"
		private  var _currentCams:Number=0;
		public var activateAdminFunctions:Boolean = false
		public var badWordsArray:Array =[]
		
		public function set currentCams(val:Number):void{
			if (val<0){val=0}
			_currentCams=val;
		}
		public function get currentCams():Number{
			return _currentCams;
		}
      
		public function ApplicationData()
		{
			if (!allowInstantiation) {
            	throw new Error("Error: Instantiation failed: Use ApplicationData.getInstance() instead of new.");
			}
		}
		
		public function showAll(e:Event=null):void{
			dispatchEvent(new Event("SHOW_ALL"));
		}
		public function showWhoIsWatchingMe(e:Event=null):void{
			dispatchEvent(new Event("SHOW_VIEWERS"));
		}
		public function showBlockedUsers(e:Event=null):void{
			dispatchEvent(new Event("SHOW_BLOCKED"));
		}
		
		public function sortUsersListsByUsername():void{
			trace(this+".sortUsersListsByUsername()")
			dispatchEvent(new Event("SORT_BY_USERNAME"));
		}
		public function sortUsersListsByTimeOnline():void{
			trace(this+".sortUsersListsByTimeOnline()")
			dispatchEvent(new Event("SORT_BY_TIMEONLINE"));
		}
		public function sortUsersListsByCamsAndMics():void{
			trace(this+".sortUsersListsByCamsAndMics()")
			dispatchEvent(new Event("SORT_BY_CAMSANDMICS"));
		}
		
		public static function get theinstance():ApplicationData{
			if (instance == null) {
	            allowInstantiation = true;
	            instance = new ApplicationData();
	            allowInstantiation = false;
	         }
        	return instance;
		}
		
		public static function getInstance():ApplicationData {
	         if (instance == null) {
	            allowInstantiation = true;
	            instance = new ApplicationData();
	            allowInstantiation = false;
	          }
        	return instance;
		}
		
		public function loadCSSData(url:String):void{
			var req:URLRequest = new URLRequest(url);
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onCSSFileLoaded);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioCSSErrorHandler);
			loader.load(req);
		}
		
		public function onCSSFileLoaded(event:Event):void  { 
			trace("onCSSFileLoaded")
			css = new StyleSheet();
			css.parseCSS(loader.data);  
			for (var i:String in css.styleNames){
				trace("onCSSFileLoaded: "+i+"="+css.styleNames[i])
			}
			trace("onCSSFileLoaded css.getStyle('.windows').margin="+css.getStyle('.windows').margin)
			dispatchEvent(new Event("CSS_LOADED",false,false))
		} 
		public function ioCSSErrorHandler(event:Event):void  { 
			trace("ioCSSErrorHandler:"+event) 
		}
		
		public function getCSSValue(clas:String,style:String):Number{
			trace("getCSSValue("+arguments.join(",")+")")
			var obj:Object = css.getStyle("."+clas);
			//obj.setPropertyIsEnumerable(style, true);
			trace(' obj['+style+']='+ obj[style])
			var value:String= obj[style]
			if (value.indexOf("#")==0){
				return (Number(value.replace("#","0x")))
			}else{
				return Number(value)
			}
			
			
			
		}
	}
}