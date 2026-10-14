package {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.GraphicsBitmapFill;
import flash.display.GraphicsEndFill;
import flash.display.GraphicsPath;
import flash.display.IGraphicsData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Rectangle;

public class Test extends Sprite {
    public function Test() {
        var source:BitmapData = new BitmapData(8, 8, true, 0);
        source.fillRect(new Rectangle(2, 2, 4, 4), 0xffffffff);
        var alpha:BitmapData = new BitmapData(8, 8, true, 0xff000000);
        alpha.draw(new Bitmap(source), null, null, "alpha");
        trace("alpha transparent=" + alpha.getPixel32(0, 0).toString(16));
        trace("alpha opaque=" + alpha.getPixel32(3, 3).toString(16));
        var disposed:BitmapData = new BitmapData(8, 8, true, 0xff00ff00);
        var fill:GraphicsBitmapFill = new GraphicsBitmapFill(disposed, new Matrix(), true, false);
        disposed.dispose();
        var shape:Shape = new Shape();
        addChild(shape);
        var path:GraphicsPath = new GraphicsPath();
        path.moveTo(10, 10);
        path.lineTo(100, 10);
        path.lineTo(100, 100);
        path.lineTo(10, 100);
        path.lineTo(10, 10);
        var data:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
        data.push(fill, path, new GraphicsEndFill());
        shape.graphics.drawGraphicsData(data);
        trace("disposed bounds=" + shape.width + "x" + shape.height);
        trace("disposed hit=" + shape.hitTestPoint(50, 50, true));
        var rendered:BitmapData = new BitmapData(110, 110, true, 0);
        rendered.draw(shape);
        trace("disposed pixel=" + rendered.getPixel32(50, 50).toString(16));
        trace("COMPLETE");
    }
}
}
