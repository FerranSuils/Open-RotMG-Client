package {
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Rectangle;
[SWF(width="16", height="16", frameRate="60", backgroundColor="#ffffff")]
public class Test extends Sprite {
    public function Test() {
        var shape:Sprite = new Sprite();
        shape.graphics.beginFill(0xff0000, 0.5);
        shape.graphics.drawRect(0, 0, 8, 8);
        shape.graphics.endFill();
        var source:BitmapData = new BitmapData(16, 16, true, 0);
        source.draw(shape);
        var cloned:BitmapData = source.clone();
        var chained:BitmapData = cloned.clone();
        var expected:uint = source.getPixel32(3, 3);
        trace("alpha pixels=" + (cloned.getPixel32(3, 3) == expected));
        trace("transparent outside=" + (cloned.getPixel32(12, 12) == 0));
        trace("metadata=" + (cloned.transparent && cloned.width == 16 && cloned.height == 16));
        shape.graphics.clear();
        shape.graphics.beginFill(0x0000ff);
        shape.graphics.drawRect(0, 0, 16, 16);
        shape.graphics.endFill();
        source.draw(shape);
        trace("source mutation independent=" + (cloned.getPixel32(3, 3) == expected));
        cloned.draw(shape);
        trace("clone mutation visible=" + (cloned.getPixel32(3, 3) == 0xff0000ff));
        trace("chain independent=" + (chained.getPixel32(3, 3) == expected));
        source.dispose();
        trace("source disposal independent=" + (chained.getPixel32(3, 3) == expected));
        var cpu:BitmapData = new BitmapData(4, 4, false, 0x123456);
        var cpuCopy:BitmapData = cpu.clone();
        cpu.fillRect(cpu.rect, 0xabcdef);
        trace("CPU clone independent=" + (cpuCopy.getPixel32(0, 0) == 0xff123456));
        var opaque:BitmapData = new BitmapData(16, 16, false, 0xabcdef);
        opaque.draw(shape);
        var opaqueCopy:BitmapData = opaque.clone();
        trace("opaque preserved=" + (!opaqueCopy.transparent && opaqueCopy.getPixel32(3, 3) == 0xff0000ff));
    }
}
}
