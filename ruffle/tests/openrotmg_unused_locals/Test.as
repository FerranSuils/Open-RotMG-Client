package {
    import flash.display.Sprite;
    public class Test extends Sprite {
        public function Test() {
            effects();
            retained();
            enumerate();
            var assigned:int;
            trace("assignment", assigned = 9);
            trace("COMPLETE");
        }
        private function produce():Object {
            trace("producer");
            return {valueOf: function():Number {trace("coercion"); return 7;}};
        }
        private function effects():void {
            var unused:Object = produce();
            var converted:int = produce();
            try {
                var throwing:int = {valueOf: function():Number {throw new Error("conversion threw");}};
            } catch (error:Error) {trace(error.message);}
        }
        private function retained():void {
            var later:int = 12;
            try {throw new Error("handler");}
            catch (error:Error) {trace("handler read", later);}
        }
        private function enumerate():void {
            var keys:Array = [];
            for (var key:String in {alpha:1,beta:2}) {keys.push(key);}
            trace("keys", keys.sort().join(","));
        }
    }
}
