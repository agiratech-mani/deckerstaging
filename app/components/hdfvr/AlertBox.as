package
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.net.URLRequest;
	import flash.system.*;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import flashx.textLayout.formats.TextAlign;
	
	import net.avchat.utils.ApplicationData;
	
	public class AlertBox extends Sprite
	{
		private var _shape:Sprite;
		private var _color:uint = 0xffffff;
		private var _alpha:Number = 0.8;
		private const _width:Number = 260;
		private const _height:Number = 150;
		private var _label:TextField;
		private var _labelFormat:TextFormat;
		public var _html:Boolean = false;
		private var _cornerRadius:Number = 16;
		private var loader:Loader;
		
		public function AlertBox(){
			
			//color
			if(ApplicationData.getInstance().avc_settings["menuColor"]){
				_color = ApplicationData.getInstance().avc_settings["menuColor"]
			}else{
				_color = 0x333333;
			}
			
			if(ApplicationData.getInstance().avc_settings["radiusCorner"]){
				_cornerRadius = ApplicationData.getInstance().avc_settings["radiusCorner"]
			}else{
				_cornerRadius = 16;
			}
			
			//text format
			_labelFormat = new TextFormat();
			_labelFormat.font = "_sans";
			_labelFormat.color = 0xFFFFFF;
			_labelFormat.size = 16;
			_labelFormat.bold = true;
			_labelFormat.align = TextFieldAutoSize.CENTER;
			
			//the label
			_label = new TextField();
			_label.defaultTextFormat = this._labelFormat;
			_label.selectable = false;
			_label.multiline = true;
			_label.wordWrap = true;
			_label.addEventListener(TextEvent.LINK, linkEvent);
			
			//the bg sprite
			_shape = new Sprite();
			_shape.name = "alert_box";
			_shape.graphics.beginFill(this._color,this._alpha);   	
	    	_shape.graphics.drawRoundRect(0,0,_width,_height,_cornerRadius);
	    	_shape.graphics.endFill();
		    addChild(_shape)
		    
		    //shadow for the alert box
		   // var ds:DropShadowFilter = new DropShadowFilter(4,45,0,0.5,4,4)
		    //_shape.filters = [ds];
		    
		    
			_label.addEventListener(TextEvent.LINK, this.linkEvent);
			/*_label.width = _shape.width*9/10;
		    _label.height = _shape.height*8/10;
		    _label.x = (_shape.width - _label.width)/2;
		    _label.y = (_shape.height - _label.height)/2;*/
		    addChild(this._label);
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			addChild(loader);
			loader.visible = false;
			
			loader.load(new URLRequest("loading.swf"));
			
			
		}
		
		private function onLoadError(e:Event):void{
			trace("onLoadError("+e+")");
		}
		
		private function onLoadComplete (e:Event):void{
			trace("onLoadComplete("+e+")");
			LoaderInfo(e.target).loader.height = 40;
			LoaderInfo(e.target).loader.width = 40;
		}
		
/* 		public function addAlertBox(_parent:Object,_centered:Boolean = true,_x:Number = 0, _y:Number = 0, _width:Number = this._width , _height:Number = this._height):void{
		   trace("addAlertBox")
		    //var shape :Object = _parent.getChildByName("alert_box");
		   
		   // if(!(shape && _parent.contains(shape))){
		    	trace("addAlertBox1")
		    	//this._shape.visible = true;
		    	//this._shape.alpha = 1;
		        
		    	_parent.addChild(this._shape);
		    	if(_centered){
		    		if(_parent is Stage){
		    			this._shape.x = _parent.stageWidth/2 - this._shape.width/2;
			    		this._shape.y = _parent.stageHeight/2 - this._shape.height/2;
		    		}else{
			    		this._shape.x = _parent.width/2 - this._shape.width/2;
			    		this._shape.y = _parent.height/2 - this._shape.height/2;
		    		}
		    	}else{
		    		this._shape.x = _x;
		    		this._shape.y = _y;
		    	}
		   /*  }else{
		    	this._shape.visible = true;
		        trace("addAlertBox2")
		    } 
		    
		  
		} */
		
	/* 	public function getAlertBoxShape():Sprite{
			return Sprite(this._shape);
		} */
		
		/* public function removeAlertBoxShape(_parent:Object):void{
			try{
				if(_parent is DisplayObjectContainer){
					if(_parent.contains(this._shape)){
						_parent.removeChild(this._shape);
					}
				}
			}catch(e){
			}
		} */
		
		/* public function fadeAlertBox(_parent:Object):void{
 
			/*   if(this._timerMiliSec >0 ){  	
				if(_parent is DisplayObjectContainer){
					if(this._shape && _parent.contains(this._shape)){
					    this._shape.alpha = 1;
						var timer:Timer = new Timer(this._timerMiliSec,10);
						timer.addEventListener(TimerEvent.TIMER, fadeAway);
						timer.addEventListener(TimerEvent.TIMER_COMPLETE, fadeAwayComplete);
						timer.start();
						this._timerMiliSec = 0;
					}
				}
				
			} */
			//removeAlertBoxShape(_parent);
		
		//} */
		
		/* private function fadeAway(e:TimerEvent):void{
			trace(this._shape.alpha)
			var target:Object = e.currentTarget;
		    if(this._shape && this._shape.alpha >= 0.1){
		    	if(this._shape.alpha <= 0 ){
		    		this._shape.visible  = false;
		    	}
			    this._shape.alpha -= 0.1;
		    }	
		} */
		
/* 		private function fadeAwayComplete(e:TimerEvent):void{
			this._timerMiliSec = 100;
			if(this._shape){
			    var parent:Object = this._shape.parent;
			    if(parent && parent.contains(this._shape)){
			    	parent.removeChild(this._shape);
			    }
		    }
			
		} */
/* 		public function setTextFormat(format:TextFormat):void{
			this._label.defaultTextFormat = format;
		} */
		
		public function setTextLabel(text:String, useLoader:Boolean = false):void{
			trace("AlertBox::setTextLabel()")
			if(this._html == true){
				this._label.htmlText = text;
				trace("html label");
				this._html  = false;
			}else{
				this._label.text = text;
			}
			
			trace("NUMBER OF LINES " + _label.numLines);
			
			if(useLoader){
				loader.visible = true;
				
				_shape.graphics.clear();
				_shape.graphics.beginFill(this._color,this._alpha);   	
				_shape.graphics.drawRoundRect(0,0,_width,20 * _label.numLines + 20,_cornerRadius);
				_shape.graphics.endFill();
								
				//loader.x = (_shape.width - 40)/2;
				//loader.y = (_shape.height - 40)/2 - 20 * _label.numLines/2;
				loader.x = 10;
				loader.y = (_shape.height - 40)/2;
				
				_label.width = _shape.width - 5;
				_label.height = 20 * _label.numLines + 5;
				_label.x = loader.x + 5;
				_label.y = (_shape.height - _label.height)/2;
				
			}else{
				loader.visible = false;
				
				_shape.graphics.clear();
				_shape.graphics.beginFill(this._color,this._alpha);   	
				_shape.graphics.drawRoundRect(0,0,_width,20 * _label.numLines + 20,_cornerRadius);
				_shape.graphics.endFill();
				
				_label.width = _shape.width - 5;
				_label.height = 22 * _label.numLines;
				_label.x = (_shape.width - _label.width)/2;
				_label.y = (_shape.height - _label.height)/2;
			}
		}
		
/* 		public function setTimerMilisec(milisec:Number):void{
			this._timerMiliSec = milisec;
		} */
		
		public function linkEvent(event:TextEvent):void {
			trace("AlertBox::linkEvent()")
			this._label.removeEventListener(TextEvent.LINK, this.linkEvent);
		    if(event.text == "settings"){
		    	this._shape.visible = false;
		    	Security.showSettings(SecurityPanel.PRIVACY)
		    } // Link Clicked
		}
	}
}