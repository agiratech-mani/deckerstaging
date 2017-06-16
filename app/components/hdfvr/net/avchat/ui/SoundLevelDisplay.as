package net.avchat.ui{
	
	import flash.display.*;
	import flash.filters.DropShadowFilter;
	
	public class SoundLevelDisplay extends Sprite
	{
		
		private var _spGrads:Sprite;
		private var _background:Sprite;
		private var _maxLevel:Number;
		private var _blinkOn:Boolean = true;
		private var _warnFilter:DropShadowFilter = new DropShadowFilter(20,0,0xFF0000,1,0,0,1,1,true);
		public var micHasSound:Boolean = false;
		
		public function SoundLevelDisplay()
		{
			super();
			_spGrads = new Sprite();
			addChild(_spGrads)
			for (var i:int = 0; i < 7; i++) {
				var shape:Sprite = new Sprite();
				if (i < 5) {
					shape.graphics.beginFill(0x9FCF6F,1);
				} else if (i == 5) {
					shape.graphics.beginFill(0xCFC96F,1);
				} else {
					shape.graphics.beginFill(0xCF6F6F,1);
				}
				shape.graphics.drawRect(0,0,2,2);
				shape.graphics.endFill();
				_spGrads.addChild(shape);
				shape.x=i*3;
				shape.visible=false
			}
			this.makeBackgorund();
		}
		
		public function makeBackgorund():void{
			this._background = new Sprite();
			addChildAt(this._background,0);
			for (var i:int=0; i < 7; i++) {
				var shape:Shape = new Shape();
				shape.graphics.beginFill(0xefefef,1);
				shape.graphics.drawRect(0,0,2,2);
				shape.graphics.endFill();
				shape.x=i*3;
				this._background.addChild(shape);
			}
		}
		
		public function set level (n:Number):void{
			//maxLevel = (n+(5-n%5))/5
			_maxLevel = (n-n%5)/5
			for (var i:int = 0; i < 7; i++){
				if (i<_maxLevel){
					_spGrads.getChildAt(i).visible=true
				}else{
					_spGrads.getChildAt(i).visible=false
				}
			}
		}
		
		public function noSound():void{
			
			if(_spGrads.filters.length == 0){
				for (var i:int = 0; i < 7; i++){
					_spGrads.getChildAt(i).visible=true;
				}	
			}
			
			_spGrads.filters = [_warnFilter];
			
			if(_blinkOn == true){
				_spGrads.visible = true;
				_blinkOn = false;
			}else{
				_spGrads.visible = false;
				_blinkOn = true;
			}
		}
		
		public function stopWarning():void{
			_spGrads.filters = [];
			_spGrads.visible = true;
			/*for (var i:int = 0; i < 7; i++){
				_spGrads.getChildAt(i).visible=false;
			}*/
		}
	}	
}