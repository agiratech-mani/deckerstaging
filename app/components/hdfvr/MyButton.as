package
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.*;
	
	public class MyButton extends Sprite
	{
		//private variables
		private var _width:Number;
		private var _height:Number;
		private var _backgroundColor:uint = 0xFFFFFF;
		private var _label:TextField;
		private var _icon:DisplayObject;
		private var _roundCorners:Number = 0;
		private var  _enabled:Boolean = true;
        private var _tooltipTimer:Number = 100;
    	
		private var _filterNormal:DropShadowFilter;
		private var _filterOver:DropShadowFilter;
		private var _color:uint = 0x333333;
		private var _overColor:uint = 0xdf8f90;
		private var _recOrStop:Shape;
		private var _initX:Number;
		private var _initY:Number;
		
		//public variables
		public var spreadMethod:String = "pad";
    	public var interpolationMethod:String = "RGB";
		public var focalPointRatio:int = 1;
		public var lab:TextField;
		public var clickEventName:String; 
		public var position:String = "left";
		public var canBeUsed:Boolean = true
			
		private var bgSprite:Sprite;
				
		//only for cam or mic settings button
		public var type:String = "";
		
		public function MyButton(nm:String="",bgColor:uint=0xFFFFFF,w:Number=30 , h:Number =30, color:uint = 0x333333, overColor:uint = 0xdf8f90){
			super();

			_backgroundColor= bgColor

			_color = color;
			_overColor = overColor;
			_width=w;
			_height=h;
			
			//button mode
			this.buttonMode = true;
			
			//background
			bgSprite= new Sprite()
			bgSprite.graphics.beginFill(_backgroundColor);
			bgSprite.mouseEnabled=false
			bgSprite.graphics.drawRoundRect(0, 0, this._width, this._height,this._roundCorners,this._roundCorners);
			bgSprite.graphics.endFill();
			addChild (bgSprite);
						
			_filterNormal = new DropShadowFilter(30,0,_color,1,0,0,1,1,true);
			_filterOver = new DropShadowFilter(30,0,_overColor,1,0,0,1,1,true);
			
			_recOrStop = new Shape();
			_initX = _recOrStop.x = (this.width - this._recOrStop.width)/2;
			_initY = _recOrStop.y = (this.height - this._recOrStop.height)/2;
			
			this.addListners();
		}
		
		public function addListners():void{
			this.addEventListener(MouseEvent.MOUSE_OVER, btOver);
		    this.addEventListener(MouseEvent.MOUSE_OUT,  btOut);
		    this.addEventListener(MouseEvent.MOUSE_DOWN, btDown);
		    this.addEventListener(MouseEvent.CLICK, btUp);
		}
		
		public function setClickEventName(eventName:String):void{
			this.clickEventName = eventName;
		}
		/*public function setClickEvent(event):void{
			this.clickEvent = event;
			if(!this.hasEventListener(MouseEvent.MOUSE_DOWN) && this._enabled){
			 this.addEventListener(MouseEvent.MOUSE_DOWN, this.clickEvent); 
			}
		}*/
        
        public function removeListeners():void{
        	this.removeEventListener(MouseEvent.MOUSE_OVER, btOver);
		    this.removeEventListener(MouseEvent.MOUSE_OUT,  btOut);
		    this.removeEventListener(MouseEvent.MOUSE_DOWN, btDown);
		    this.removeEventListener(MouseEvent.CLICK, btUp);
        }
		
        public function btOver(e:MouseEvent):void{
			this._icon.filters = [_filterOver];
        }
        
        public function btOut(e:MouseEvent):void{
			this._icon.filters = [_filterNormal];
        }
        
        public function btDown(e:MouseEvent):void{
			
        }
        
        public function btUp(e:MouseEvent):void{
			this._icon.filters = [_filterNormal];
			if(this.clickEventName){
				dispatchEvent(new Event(this.clickEventName,true));
			}
        }
        
        public function setIcon(className:Class, type:String = "default"):void{
        	if(this._icon && contains(this._icon)){
        		this.removeChild(this._icon);
        		this._icon = null;
        	}
        	this._icon = new className();
        	this.addChild(this._icon);
        	this._icon.x = (this.width - this._icon.width)/2
        	this._icon.y = (this.height - this._icon.height)/2
        	if(this._enabled == false){
        		this._icon.alpha = 0.5;
        	}
			
			this._icon.filters = [_filterNormal];
			
			if(type == "rec"){
				
				_recOrStop.graphics.clear();
				_recOrStop.graphics.beginFill(0xf53333,1);
				_recOrStop.graphics.drawCircle(0,0,8);
				_recOrStop.graphics.endFill();
				_recOrStop.x = _initX;
				_recOrStop.y = _initY;
				this.addChild(_recOrStop);	
				
			}else if(type == "stop"){
				
				_recOrStop.graphics.clear();
				_recOrStop.graphics.beginFill(0xf53333,1);
				_recOrStop.graphics.drawRoundRect(0,0,12,12,4);
				_recOrStop.graphics.endFill();
				_recOrStop.x = (this.width - this._recOrStop.width)/2;
				_recOrStop.y = (this.height - this._recOrStop.height)/2;
				this.addChild(_recOrStop);
			}
			
        } 
       
        public function setWidth(width:Number):void{
        	this._width = width;
        }
        
        public function setHeight(height:Number):void{
        	this._height = height; 
        }
		
		public function setSize(w:Number, h:Number):void{
		
		}
        
        public function resize():void{
        	
        }
		
		public function get enabled():Boolean{
		 return this._enabled;
		}

		public function set enabled(e:Boolean):void{

			if(e == false && this._enabled){
				this._enabled = false;
				if(this._icon){
					this._icon.alpha = 0.1;
				}
				
				if(this._recOrStop){
					this._recOrStop.alpha = 0.3;
				}
				
				this.useHandCursor = false;
				this.buttonMode = false;
				this.removeListeners();
			}
			if(e == true && !this._enabled){
				this._enabled = true;
				this.addListners();
				if(this._icon){
					this._icon.alpha = 1;
				}
				
				if(this._recOrStop){
					this._recOrStop.alpha = 1;
				}
				
				this.buttonMode = true;
				this.useHandCursor = true;
				this.mouseEnabled = true;
				this.addListners(); 
			}			
		}
		
		public function hideBg():void{
			this.removeChild(bgSprite);
		}
	}
}