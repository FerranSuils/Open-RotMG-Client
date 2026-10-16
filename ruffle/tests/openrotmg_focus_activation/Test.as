package {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.EventDispatcher;

    [SWF(width="400", height="300", frameRate="30")]
    public class Test extends Sprite {
        private var orphan:Sprite = new Sprite();
        private var dispatcher:EventDispatcher = new EventDispatcher();

        public function Test() {
            listen(stage, "stage");
            listen(orphan, "orphan");
            listen(this, "root");
            listen(dispatcher, "unexpected dispatcher");
            stage.addEventListener(Event.ACTIVATE, unexpectedCapture, true);
            stage.addEventListener(Event.DEACTIVATE, unexpectedCapture, true);
            trace("ready");
        }

        private function listen(target:EventDispatcher, label:String):void {
            var log:Function = function(event:Event):void {
                trace(label, event.type, event.target === event.currentTarget,
                      event.bubbles, event.cancelable, event.eventPhase);
            };
            target.addEventListener(Event.ACTIVATE, log);
            target.addEventListener(Event.DEACTIVATE, log);
        }

        private function unexpectedCapture(event:Event):void {
            trace("unexpected capture", event.type);
        }
    }
}
