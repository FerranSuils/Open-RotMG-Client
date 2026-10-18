package {
 import flash.display.Sprite;import flash.utils.getTimer;
 public class Test extends Sprite {
  public static var reads:String="";public static var coercions:int=0;private var seed:uint=12351;
  private function random():uint{seed=seed*1664525+1013904223;return seed;}
  private function digest(values:Array):uint{var h:uint=0;for each(var o:Object in values)h=h*131+o.id+17;return h;}
  public function Test(){
   var checksum:uint=0;var samples:Array=[NaN,Infinity,-Infinity,-0,0,0.25,-3.5,2.25];
   for(var pass:int=0;pass<32;pass++){
    var a:Array=[];for(var n:int=0;n<64;n++){var key:Number=samples[random()%samples.length];var tie:int=(random()%5==0)?268435456:int(random()%15)-7;a.push(new SortRecord(key,tie,n));}
    a.sortOn(["key","tie"],[Array.NUMERIC|(pass%2==0?0:Array.DESCENDING),Array.NUMERIC|(pass%3==0?Array.DESCENDING:0)]);checksum=checksum*131+digest(a);
   }
   trace("numeric-slots "+checksum);
   a=[new SortRecord(3,0,0),new SortRecord(1,0,1),new SortRecord(2,0,2)];var indices:Array=a.sortOn("key",Array.NUMERIC|Array.RETURNINDEXEDARRAY);trace("indexed "+indices.join(",")+" original "+digest(a));
   a=[new SortRecord(1,0,0),new SortRecord(1,0,1),new SortRecord(2,0,2)];var unique:*=a.sortOn("key",Array.NUMERIC|Array.UNIQUESORT);trace("unique "+unique+" original "+digest(a));
   a=[new GetterRecord(3,0),new GetterRecord(1,1),new GetterRecord(4,2),new GetterRecord(2,3)];a.sortOn("key",Array.NUMERIC);trace("getters "+digest(a)+" reads "+reads);
   a=[];for(n=0;n<4;n++){var value:Object={n:3-n,valueOf:function():Number{Test.coercions++;return this.n;}};a.push({key:value,id:n});}a.sortOn("key",Array.NUMERIC);trace("coercions "+digest(a)+" calls "+coercions);
   a=[];for(n=0;n<2048;n++)a.push(new SortRecord(random()%1024,n,n));var start:int=getTimer();for(n=0;n<20;n++)a.sortOn(["key","tie"],[Array.NUMERIC,Array.NUMERIC]);trace("bench-digest "+digest(a));trace("COMPLETE");
  }
 }
}
class SortRecord {public var key:Number;public var tie:int;public var id:int;public function SortRecord(k:Number,t:int,i:int){key=k;tie=t;id=i;}}
class GetterRecord {private var value:Number;public var id:int;public function GetterRecord(k:Number,i:int){value=k;id=i;}public function get key():Number{Test.reads+=id+",";return value;}}
