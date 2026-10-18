package {
 import flash.display.*;
 import flash.geom.Matrix;
 public class Test extends Sprite {
  private function rectangle(x:Number,y:Number,w:Number,h:Number):GraphicsPath {
   return new GraphicsPath(new <int>[1,2,2,2,2],new <Number>[x,y,x+w,y,x+w,y+h,x,y+h,x,y]);
  }
  private function stamp(data:Vector.<IGraphicsData>,bitmap:BitmapData,x:Number,y:Number,reference:Boolean,smooth:Boolean=false,repeat:Boolean=false,rotation:Number=0):void {
   var matrix:Matrix=new Matrix();matrix.rotate(rotation);matrix.translate(x,y);
   // Distinct texture handles prevent batching without changing the reference pixels.
   data.push(new GraphicsBitmapFill(reference?bitmap.clone():bitmap,matrix,repeat,smooth),rectangle(x,y,24,24),new GraphicsEndFill());
  }
  private function scene(kind:int,a:BitmapData,b:BitmapData,reference:Boolean):DisplayObject {
   var data:Vector.<IGraphicsData>=new Vector.<IGraphicsData>();
   if(kind==0){stamp(data,a,4,4,reference);stamp(data,a,12,12,reference);stamp(data,a,25,8,reference,false,false,.2);}
   if(kind==1){stamp(data,a,4,4,reference);stamp(data,b,12,12,reference);stamp(data,a,20,20,reference);}
   if(kind==2){stamp(data,a,4,4,reference,true,false);stamp(data,a,12,12,reference,false,false);stamp(data,a,20,20,reference,false,true);}
   if(kind==3){stamp(data,a,4,4,reference);data.push(new GraphicsStroke(8,false,"normal","none","round",3,new GraphicsBitmapFill(reference?a.clone():a,new Matrix(),false,false)),rectangle(16,16,24,24),new GraphicsStroke());stamp(data,a,32,4,reference);}
   var shape:Sprite=new Sprite();shape.graphics.drawGraphicsData(data);
   if(kind!=3)return shape;
   var container:Sprite=new Sprite();container.addChild(shape);
   var color:Sprite=new Sprite();color.graphics.beginFill(0xff8844,.7);color.graphics.drawRect(0,0,64,64);color.graphics.endFill();container.addChild(color);color.mask=shape;
   return container;
  }
  public function Test() {
   var a:BitmapData=new BitmapData(16,16,true,0),b:BitmapData=new BitmapData(16,16,true,0);
   for(var y:int=0;y<16;y++)for(var x:int=0;x<16;x++){a.setPixel32(x,y,x%3==0?0x8040ff00:0xc0ff0040);b.setPixel32(x,y,y%2==0?0xa00040ff:0xff00ffff);}
   var names:Array=["same-texture","interleaved","samplers","fill-stroke-mask"];
   for(var kind:int=0;kind<4;kind++){
    var candidate:BitmapData=new BitmapData(64,64,true,0),reference:BitmapData=new BitmapData(64,64,true,0);
    var expected:DisplayObject=scene(kind,a,b,true),actual:DisplayObject=scene(kind,a,b,false);
    reference.draw(expected);candidate.draw(actual);var nonzero:int=0;
    for(y=0;y<64;y++)for(x=0;x<64;x++){var pixel:uint=reference.getPixel32(x,y);if(pixel!=candidate.getPixel32(x,y))throw new Error(names[kind]+" pixel mismatch "+x+","+y);if(pixel!=0)nonzero++;}
    if(nonzero<100)throw new Error("Renderer did not produce the required reference pixels");
    trace(names[kind]+" exact");
   }
   trace("COMPLETE");
  }
 }
}
