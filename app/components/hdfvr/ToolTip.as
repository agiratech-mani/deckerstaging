package 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class ToolTip extends Sprite
	{
		var bg:Shape
		var label:TextField
		public function ToolTip(s:String="",arrowposition:String ="left",textcolor:uint = 0x333333, bgColor:uint = 0xb4e0e3, cornerRadius:Number = 8)
		{
			bg = new Shape()
			addChild(bg)
			
			label= new TextField
			label.defaultTextFormat = new TextFormat("Tahoma",11,textcolor);
			label.autoSize = "left"
			label.text=" "+s+" "
			label.selectable = false
			label.y=2
			addChild(label)
			
			
			bg.graphics.beginFill(bgColor,1);
			bg.graphics.drawRoundRect(0,0,label.width,22,cornerRadius);
			
			if (arrowposition=="left"){
				bg.graphics.moveTo(5,22);
				bg.graphics.lineTo(10,27)
				bg.graphics.lineTo(15,22)
			}else{
				bg.graphics.moveTo(label.width-17,22);
				bg.graphics.lineTo(label.width-10,27);
				bg.graphics.lineTo(label.width-5,22);
				
				bg.x=label.x= -(label.width-15)
			}
			//bg.graphics.d
			//bg.graphics.drawRect(0,0,label.width,22)
			
			
		}

	}
}