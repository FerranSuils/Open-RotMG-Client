package {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.filters.ColorMatrixFilter;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.geom.Rectangle;

public class Test extends Sprite {
    public function Test() {
        var icon:Bitmap = new Bitmap(new BitmapData(4, 4, true, 0xffffcc00));
        var grey:ColorMatrixFilter = new ColorMatrixFilter([
            0, 0, 0, 0, 54,
            0, 0, 0, 0, 54,
            0, 0, 0, 0, 54,
            0, 0, 0, 1, 0
        ]);
        icon.filters = [grey];
        var hud:Sprite = new Sprite();
        hud.addChild(icon);
        addChild(hud);
        var snapshot:BitmapData = new BitmapData(16, 16, true, 0);
        snapshot.draw(hud);
        trace("cold=" + snapshot.getPixel32(1, 1).toString(16));
        snapshot.draw(hud);
        trace("repeat=" + snapshot.getPixel32(1, 1).toString(16));
        snapshot.fillRect(snapshot.rect, 0);
        snapshot.draw(hud, new Matrix(2, 0, 0, 2, 0, 0), null, null, new Rectangle(0, 0, 2, 2));
        trace("transformed clip=" + snapshot.getPixel32(1, 1).toString(16));
        trace("outside clip=" + snapshot.getPixel32(3, 3).toString(16));
        grey.matrix = [
            0, 0, 0, 0, 85,
            0, 0, 0, 0, 102,
            0, 0, 0, 0, 119,
            0, 0, 0, 1, 0
        ];
        icon.filters = [grey];
        snapshot.draw(hud);
        trace("changed filter=" + snapshot.getPixel32(1, 1).toString(16));
        icon.filters = [];
        snapshot.draw(hud);
        trace("removed filter=" + snapshot.getPixel32(1, 1).toString(16));
        icon.filters = [new GlowFilter(0x00ff00, 1, 4, 4, 4)];
        snapshot.fillRect(snapshot.rect, 0);
        snapshot.draw(hud, new Matrix(1, 0, 0, 1, 4, 4));
        trace("grown bounds=" + (snapshot.getPixel32(3, 5) != 0));
        trace("outside glow=" + snapshot.getPixel32(15, 15).toString(16));
    }
}
}
