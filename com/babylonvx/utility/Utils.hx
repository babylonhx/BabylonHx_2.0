package com.babylonvx.utility;

@:expose('BABYLONVX.Utils') class Utils{
	public static function toHex(n:Float):String{
		n = Math.max(0,Math.min(n,255));
	return "0123456789ABCDEF".charAt(Math.round((n-n%16)/16))
	+ "0123456789ABCDEF".charAt(Math.round(n%16));
	}

	public static function rgb2hex(rgba:Array<Int>):Dynamic{
		var rgb:Array<Int> = [0,0,0];
		if(rgba.length == 3) {
			return Std.parseInt(toHex(rgb[0])+toHex(rgb[1])+toHex(rgb[2]));
		}else{
			return Std.parseInt(toHex(rgb[0])+toHex(rgb[1])+toHex(rgb[2])+toHex(rgb[3]));
		}	
	}

	public static function hex2rgb(hexStr:String):Array<Int> {
	var R = Std.parseInt(hexStr.substring(0,2));
	var G = Std.parseInt(hexStr.substring(2,4));
	var B = Std.parseInt(hexStr.substring(4,6));
	
	if(hexStr.length == 8) {
		var A = Std.parseInt(hexStr.substring(6,8));
		return [R,G,B,A];
	}

	return [R,G,B];
	}


}