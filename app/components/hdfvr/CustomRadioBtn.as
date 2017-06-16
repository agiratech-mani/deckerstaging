package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class CustomRadioBtn extends Sprite
	{
		private var _label:TextField;
		private var _text:String;
		private var _color:uint;
		private var _group:Number;
		private var _radio:Sprite;
		private var _knob:Sprite;
		private var _selected:Boolean = false;
		private var _index:Number = 0;
		
		public function CustomRadioBtn(text:String, color:uint, group:Number, index:Number)
		{
			_text = text;
			_color = color;
			_group = group;
			_index = index;
			this.buttonMode = true;		
	
			_radio = new Sprite();
			_radio.graphics.lineStyle(1,_color,0.5);
			_radio.graphics.beginFill(0xFFFFFF,1);
			_radio.graphics.drawCircle(0,0,6);
			_radio.graphics.endFill();
			_radio.x = 0;
			_radio.y = 0;
			this.addChild(_radio);
			
			_knob = new Sprite();
			_knob.graphics.beginFill(0x333333,1);
			_knob.graphics.drawCircle(0,0,2);
			_knob.graphics.endFill();
			_knob.x = 0;
			_knob.y = 0;
			_knob.mouseEnabled = false;
						
			_label = new TextField();
			_label.text = text.slice(0,30);
			_label.selectable = false;
			_label.setTextFormat(new TextFormat("_sans",12,_color,null,null,null,null,null,TextFormatAlign.LEFT,0,0,0,0));
			_label.autoSize = "left";
			_label.multiline = false;
			_label.width = 200;
			
			_label.x = _radio.x + _radio.width;
			_label.y = _radio.y - 8;
			this.addChild(_label);
			
			_radio.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_radio.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			_radio.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		private function onMouseOver(e:MouseEvent):void{
			if(!_selected){
				_radio.addChild(_knob);	
			}
			
		}
		
		private function onMouseOut(e:MouseEvent):void{
			if(!_selected && _radio.contains(_knob)){
				_radio.removeChild(_knob);	
			}
		}
		
		
		private function onMouseDown(e:MouseEvent):void{
			if(!_selected){
				_selected = true;
				_radio.addChild(_knob);
			}
		}
		
		public function getGroup():Number{
			return _group;
		}
		
		public function get index():Number{
			return _index;
		}
		
		public function set selected(state:Boolean):void{
			_selected = state;
			
			if(_selected){
				_radio.addChild(_knob);
			}else if(_radio.contains(_knob)){
				_radio.removeChild(_knob);
			}
		}
		
		public function get selected():Boolean{
			return _selected;
		}
	}
}