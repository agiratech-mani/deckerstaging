package
{
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class CustomButton extends Sprite
	{
		private var _label:TextField;
		private var _color:uint;
		private var _overColor:uint;
		private var _hitArea:Sprite;
		private var _smallDot:Sprite;
		private var _filterNormal:DropShadowFilter;
		private var _filterOver:DropShadowFilter;
		
		[Embed(source="../assets/icons/webcam_big.png")]
		private var record:Class;
		private var record_icon:Bitmap;
		
		public function CustomButton(text:String, color:uint, overColor:uint)
		{
			
			_color = color;
			_overColor = overColor;
			this.buttonMode = true;
			this.mouseChildren = false;
			
			_label = new TextField();
			_label.text = text;
			_label.selectable = false;
			_label.setTextFormat(new TextFormat("_sans",18,_color,null,null,null,null,null,TextFormatAlign.CENTER,0,0,0,0));
			_label.autoSize = "center";
			
			this.addChild(_label);
			
			record_icon = new record();
			this.addChild(record_icon);
			record_icon.x = 0;
			record_icon.y = 0;
			
			_filterNormal = new DropShadowFilter(30,0,_color,1,0,0,1,1,true);
			_filterOver = new DropShadowFilter(30,0,_overColor,1,0,0,1,1,true);
			
			record_icon.filters = [_filterNormal];
			
			_label.x = record_icon.x + record_icon.width + 5;
			_label.y = record_icon.y + 3;
			
			_hitArea = new Sprite();
			_hitArea.graphics.beginFill(0x00FF00,1);
			_hitArea.graphics.drawRect(0,0,record_icon.width + _label.textWidth + 10,_label.textHeight + 10);
			_hitArea.graphics.endFill();
			this.addChild(_hitArea);
			this._hitArea.visible = false;
			this.hitArea = _hitArea;
			
			_smallDot = new Sprite();
			_smallDot.graphics.beginFill(0xFF0000,1);
			_smallDot.graphics.drawRoundRect(0,0,6,4,2);
			_smallDot.graphics.endFill();
			
			_smallDot.x = 4;
			_smallDot.y = 10;
			this.addChild(_smallDot);
			
			this.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, onOut);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			
		}
		
		
		private function onOver(e:MouseEvent):void{
			_label.setTextFormat(new TextFormat("_sans",18,_overColor,null,null,null,null,null,TextFormatAlign.CENTER,0,0,0,0));
			record_icon.filters = [_filterOver];
			
		}
		
		private function onOut(e:MouseEvent):void{
			_label.setTextFormat(new TextFormat("_sans",18,_color,null,null,null,null,null,TextFormatAlign.CENTER,0,0,0,0));
			record_icon.filters = [_filterNormal];
		}
		
		private function onDown(e:MouseEvent):void{
			_label.setTextFormat(new TextFormat("_sans",18,_overColor,null,null,null,null,null,TextFormatAlign.CENTER,0,0,0,0));
		}
		
	}
}