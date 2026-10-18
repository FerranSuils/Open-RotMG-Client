package {
 import flash.display.Sprite;import flash.utils.getTimer;
 public class Test extends Sprite {
  public var base:Number=1;
  private function sum(a:Node,b:Node,n:int):Number{var out:Number=0;for(var i:int=0;i<n;i++)out+=base+a.x+b.x+a.y+b.y;return out;}
  private function localReplacement(node:Node):Number{node=new Node(19,23);return node.x+node.y;}
  private function read(node:Node):Number{return node.x;}
  private function guarded(a:Node,b:Node):Number{try{return a.x;}catch(error:TypeError){return error.errorID+b.x;}}
  private function getterAndSlot(node:Node,other:Getter):Number{return node.x+other.value+node.y+other.value;}
  public function Test(){var a:Node=new Node(2.5,7),b:Node=new Node(-1.25,-3);trace('slots '+sum(a,b,20));trace('alias '+sum(a,a,20));trace('replacement '+localReplacement(a));
   for each(var absent:* in[null,undefined]){try{trace('unexpected '+read(absent));}catch(error:TypeError){trace('null '+error.errorID);}}
   trace('catch '+guarded(null,b));var getter:Getter=new Getter();trace('getter '+getterAndSlot(a,getter)+' reads '+getter.reads);a.x=8;a.y=11;trace('mutated '+sum(a,b,20));
   var start:int=getTimer(),total:Number=0;for(var i:int=0;i<10;i++)total+=sum(a,b,20000);trace('checksum '+total);trace('COMPLETE');
  }
 }
 internal class Node{public var x:Number;public var y:int;public function Node(x:Number,y:int){this.x=x;this.y=y;}}
 internal class Getter{public var reads:int=0;public function get value():Number{return ++reads;}}
}
