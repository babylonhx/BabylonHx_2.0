package com.babylonvx;
import com.babylonhx.math.Vector3;
import haxe.crypto.*;

//@:expose('BABYLONVX.Vector3i') abstract Vector3i(Vector3) {
@:expose('BABYLONVX.Vector3i') class Vector3i extends Vector3 {	
	/*
	public var x:Int;
	public var y:Int;
	public var z:Int;
	*/
	
	public static var zero:Vector3i = new Vector3i(0,0,0);
	public static var one:Vector3i = new Vector3i(1, 1, 1);
	public static var forward:Vector3i = new Vector3i(0, 0, 1);
	public static var back:Vector3i = new Vector3i(0, 0, -1);
	public static var up:Vector3i = new Vector3i(0, 1, 0);
	public static var down:Vector3i = new Vector3i(0, -1, 0);
	public static var left:Vector3i = new Vector3i(-1, 0, 0);
	public static var right:Vector3i = new Vector3i(1, 0, 0);
	
	public static var directions:Array<Vector3i> = [back, forward,down, up];
	
	public function new( x:Float = 0, y:Float = 0, z:Float = 0) {
		super(Math.round(x), Math.round(y), Math.round(z));
		/*this.x = Math.round(vector3.x);
		this.y = Math.round(vector3.y);
		this.z = Math.round(vector3.z);*/
	}
	/*
	public Vector3i(int x, int y, int z) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	public Vector3i(int x, int y) {
		this.x = x;
		this.y = y;
		this.z = 0;
	}*/

	 public  function getHashCode(?d:Dynamic = null):Int
	  {
	  		//return Adler32.make(Adler32.toString(Std.string(d)));
	  		return Adler32.make(haxe.io.Bytes.ofString(Std.string(d)));
	  }

	
	inline public function DistanceSquared(a:Vector3i, b:Vector3i):Int {
	//public static inline function DistanceSquared(?a:Vector3i = this, b:Vector3i):Int {	
		var dx:Int = cast(b.x-a.x, Int);
		var dy:Int = cast(b.y-a.y, Int);
		var dz:Int = cast(b.z-a.z, Int);
		return dx*dx + dy*dy + dz*dz;
	}
	/*
	public int DistanceSquared(v:Vector3i) {
		return DistanceSquared(this, v);
	}
	*/
	
	public function GetHashCode ():Int {
		return this.getHashCode(x) ^ this.getHashCode (y) << 2 ^ this.getHashCode(z) >> 2;
	}
	
	public function Equals(other:Dynamic):Bool {
		if (!Std.is(other, Vector3i)){
				return false;
			} 
		var vector:Vector3i = cast other;
		return x == vector.x && 
			   y == vector.y && 
			   z == vector.z;
	}
	
	public function ToString() {
		return "Vector3i("+x+" "+y+" "+z+")";
	}
	
	//@:op(a==b)
	public function isEqual(b:Vector3i){
		return this.x == b.x && 
			   this.y == b.y && 
			   this.z == b.z;
	}
	
	//@:op(a!=b)
	public function isNotEqual(b:Vector3i){
		return this.x != b.x ||
			   this.y != b.y ||
			   this.z != b.z;
	}
	
	
	//@:op(a-b)
	public function isMinus(b:Vector3i){
		return new Vector3i( this.x-b.x, this.y-b.y, this.z-b.z);
	}
	
	
	//@:op(a+b)
	public function isPlus(b:Vector3i){
		return new Vector3i( this.x+b.x, this.y+b.y, this.z+b.z);
	}
	


	public static function Vector3(v:Vector3i) {
	//public static explicit operator Vector3(Vector3i v) {
		return new Vector3(v.x, v.y, v.z);
	}
	
}
