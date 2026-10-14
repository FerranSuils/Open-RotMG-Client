package {
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.geom.Rectangle;
import flash.text.engine.*;

public class Test extends Sprite {
    [Embed(source="../textline_metrics/TestFont.ttf", fontName="TestFont", embedAsCFF="true", unicodeRange="U+0020,U+0061-U+0064")]
    private var TestFont:Class;

    public function Test() {
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        for each (var size:Number in [10, 20, 40]) {
            var line:TextLine = makeLine(size);
            line.x = 30;
            line.y = 130;
            addChild(line);
            var bounds:Rectangle = line.getBounds(this);
            trace("size=" + size + " y=" + line.y + " top=" + bounds.top + " bottom=" + bounds.bottom + " height=" + line.height);
            trace("above=" + line.hitTestPoint(31, 129) + " below=" + line.hitTestPoint(31, 131 + line.descent));
        }
        var scaled:Sprite = new Sprite();
        scaled.y = 20;
        scaled.scaleY = 2;
        addChild(scaled);
        line = makeLine(20);
        line.y = 130;
        scaled.addChild(line);
        bounds = line.getBounds(this);
        trace("scaled top=" + bounds.top + " bottom=" + bounds.bottom);

        var chat:Sprite = new Sprite();
        addChild(chat);
        var used:Number = 0;
        for (var i:int = 0; i < 3; i++) {
            line = makeLine(20);
            line.y = line.ascent + used;
            used += Math.max(16, line.height);
            if (i < 2) used += 4;
            chat.addChild(line);
        }
        chat.y = 600 - 4 - used;
        bounds = chat.getBounds(this);
        trace("chat top=" + bounds.top + " bottom=" + bounds.bottom + " height=" + used);
    }

    private function makeLine(size:Number):TextLine {
        var description:FontDescription = new FontDescription();
        description.fontName = "TestFont";
        description.fontLookup = FontLookup.EMBEDDED_CFF;
        return new TextBlock(new TextElement("abcd", new ElementFormat(description, size))).createTextLine(null, 580);
    }
}
}
