package {
    import flash.display.Sprite;
    import flash.events.MouseEvent;

    [SWF(width="400", height="300", frameRate="30")]
    public class Test extends Sprite {
        public function Test() {
            graphics.beginFill(0);
            graphics.drawRect(0, 0, 400, 300);
            stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheel);
        }

        private function wheel(event:MouseEvent):void {
            trace("wheel", event.delta);
        }
    }
}
