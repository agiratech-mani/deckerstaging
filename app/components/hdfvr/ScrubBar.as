package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.NetStream;
	import flash.utils.*;
	
	public class ScrubBar extends Sprite
	{
		
		private var _min:Number = 0;
		private var _max:Number = 100;
		
		private var _backgroundColor:uint = 0x666666;
		private var _scrub:Sprite;
		private var _scrubColor:uint = 0x333333;
		private var _progress:Sprite;
		private var _progressColor:uint = 0xff0000;
		private var _scrubber:Sprite;
		private var _scrubberColor:uint = 0x333333;
		private var _buffer:Sprite;
		private var _bufferColor:uint = 0x777777;
		private var _overColor:uint = 0xdf8f90;
		private var _controlsActivated:Boolean = true;
		private var _startedDraged:Boolean = false;
		private var WIDTH:Number = 500;
		private var HEIGHT:Number = 2;
		private var ns:NetStream;
		
		public var bgSprite:Sprite;
		
		private var _overFilter:DropShadowFilter;
				
		public function ScrubBar(bgColor:uint=0x000000, scrubColor:uint = 0x333333, overColor:uint = 0xdf8f90){
			//trace("ScrubBar")
			super();
			_backgroundColor=bgColor
			_scrubColor = scrubColor;
			_scrubberColor = scrubColor;
			_overColor = overColor;
			//background
			bgSprite= new Sprite()
			bgSprite.graphics.beginFill(_backgroundColor);
			bgSprite.mouseEnabled=false
			bgSprite.graphics.drawRoundRect(0, 0, 30, 30,0,0);
			bgSprite.graphics.endFill();
			addChild (bgSprite);
			
			this._scrub = new Sprite();
			_scrub.y=15
			this._scrub.graphics.beginFill(this._scrubColor,0.5);
			this._scrub.graphics.drawRect(0,  0, this.WIDTH/2, this.HEIGHT);
			this._scrub.graphics.endFill();
			this.addChild(this._scrub);
			
			this._progress = new Sprite();
			this._progress.graphics.beginFill(this._progressColor,1);
			this._progress.graphics.drawRect(0,0,this.WIDTH/2,HEIGHT);
			this._progress.graphics.endFill();
			_progress.y=15
			_progress.visible=false
			this.addChild(this._progress);
			
			
			this._buffer = new Sprite();
			this._buffer.graphics.beginFill(this._bufferColor,1);
			this._buffer.graphics.drawRect(0, 0, this.WIDTH/2, this.HEIGHT);
			this._buffer.graphics.endFill();
			_buffer.y=15
			_buffer.visible=false
			this.addChild(this._buffer);
			
			this._scrubber = new Sprite();
			this._scrubber.graphics.beginFill(this._scrubberColor,1);
			this._scrubber.graphics.drawCircle(0,0,5);
			this._scrubber.graphics.endFill();
			this.addChild(this._scrubber);
			this._scrubber.y = _scrub.y + 1;
			
			_overFilter = new DropShadowFilter(30,0,_overColor,1,0,0,1,1,true);
			
		}
		
		public function addListeners():void{
			//this._buffer.buttonMode = true;
			//this._progress.buttonMode = true;
			this._scrubber.buttonMode = true;
			//this._buffer.addEventListener(MouseEvent.CLICK, this.clickBuffer);
			this._scrubber.addEventListener(MouseEvent.MOUSE_DOWN, this.startScrubber);
			this._scrubber.addEventListener(MouseEvent.MOUSE_UP, this.stopScrubber);
			this._scrubber.addEventListener(MouseEvent.MOUSE_OVER,onMouseOverScrubber);
			this._scrubber.addEventListener(MouseEvent.MOUSE_OUT,onMouseOutScrubber);
			//this._progress.addEventListener(MouseEvent.CLICK, this.clickProgress);
			this._controlsActivated = true;
		}
		
		public function setNetstream(ns:NetStream):void{
			this.ns = ns;
		}
		public function setMax(max:Number):void{
			//trace("ScrubBar::setMax("+max+")")
			this._max = max;
		}
		
		public function setMin(min:Number):void{
			//trace("ScrubBar::setMin("+min+")")
			this._min =  min;
		}
		
		public function setWidth(w:Number ):void{
			trace("ScrubBar.setWidth("+w+")")
			WIDTH = w;
			bgSprite.width = w
						
			_scrub.width = w-2*_scrubber.width - 6;
			_scrub.x=_scrubber.width + 6;
			_progress.x= _scrub.x
			if(ns){
				var aux:Number = WIDTH*ns.time/_max + 6;
				scrubTo(aux);
			}else{
				_scrubber.x =_scrubber.width/2 + 12;
			}
		}
		
		public function getWidth():Number{
			return this.WIDTH;
		}
		public function scrubTo(position:Number):void{
			trace("ScrubBar.scrubTo("+position+")")
			var aux:Number;
			if(position < this._min){
				position = this._min;
				_progress.visible=false
				_buffer.visible=false
				this._buffer.graphics.clear();
				this._scrubber.x = this._scrubber.width/2 + 6;
			}else if(position >= this._max){
				position = this._max;
				_progress.visible=true
				_buffer.visible=false
				_progress.width=_scrub.width
				_progress.x=_scrub.x
				_scrubber.x = this.WIDTH - this._scrubber.width/2*3;
			}else{
				_progress.visible=true
				aux =  (position/(this._max - this._min))* (_scrub.width)
				_progress.width=aux
				_progress.x=_scrub.x
				if(!this._startedDraged){
					this._scrubber.x = _scrub.x-this._scrubber.width/2+aux + 6;
				}
				
				if(this.ns && this._controlsActivated){
					_buffer.visible=true
					var bf_width:Number =_scrub.width* (ns.bufferLength/_max);
					if(bf_width > (_scrub.width-_progress.width)){
						bf_width = _scrub.width-_progress.width
					}
					_buffer.width = bf_width
					this._buffer.x = _progress.x+_progress.width
				}
			}

		}
		
		public function startScrubber(e:MouseEvent):void{
			trace("SB.startScrubber");
			var hh:Number = this._scrubber.height
			var rect:Rectangle = new Rectangle(_scrubber.width/2,_scrub.y + 1,_scrub.width,0);
			this._scrubber.startDrag(false,rect);
			stage.addEventListener(MouseEvent.MOUSE_UP,this.stopScrubber);
			this._startedDraged = true;
		}
		
		public function stopScrubber(e:MouseEvent = null):void{
			trace("SB.stopScrubber"); 
			stage.removeEventListener(MouseEvent.MOUSE_UP,this.stopScrubber)
			this._scrubber.stopDrag();
			_buffer.width=0;
			if(VideoRecorder(this.parent.parent.parent)._state && VideoRecorder(this.parent.parent.parent)._state != "playing"){
		    	VideoRecorder(this.parent.parent.parent).onClickPlay();
		    }
		    if(this.ns){
				trace("SB.stopScrubber ns.seek("+(this._max -this._min)*(this._scrubber.x/_scrub.width)+")")
				this.ns.seek((this._max -this._min)*(this._scrubber.x/_scrub.width));
			}
			this._startedDraged = false;
			this._scrubber.filters = [];
		}
		
		private function onMouseOverScrubber(e:MouseEvent):void{
			this._scrubber.filters = [_overFilter];
		}
		
		private function onMouseOutScrubber(e:MouseEvent):void{
			this._scrubber.filters = [];
		}
		
		public function reset():void{
			this.ns = null;
			this._progress.visible=false
			this._buffer.visible=false
			this._scrubber.x = this._scrubber.width/2 + 12;
		}
		
		public function posCorrectlyAtEnd():void{
			this._scrubber.x = _scrub.x + _scrub.width;
			this._progress.width = _scrub.width;
		}
		
		private var  _enabled:Boolean = true;
		public function set enabled(e:Boolean):void{
			if(e == false && this._enabled){
				this._enabled = false;
				_scrubber.alpha = 0.1
				_scrub.alpha = 0.1
			}
			if(e == true && !this._enabled){
				this._enabled = true;
				_scrubber.alpha = 1
				_scrub.alpha = 1
			}			
		}
	}
}