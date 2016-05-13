package com.babylonvx.utility;
import com.babylonhx.math.Vector3;
/// <summary>
/// Simplex Noise 3D
/// Jeff Standen
/// https://gist.github.com/jstanden/1489447
/// </summary>



@:expose('BABYLONVX.SimplexNoise3D') class SimplexNoise3D {
    private var A:Array<Int> = ArrayMod( 1, 3 );
    private var s:Float;
    private var u:Float;
    private var v:Float;
    private var w:Float;
    private var i:Int;
    private var j:Int;
    private var k:Int;
    private var onethird:Float = 0.333333333;
    private var onesixth:Float = 0.166666667;
    private var T:Array<Int>;

    public static inline function lerp(Min:Float, Max:Float, Ratio:Float):Float
    {
        return Min + Ratio * (Max - Min);
    }


    public static inline function randomInt(from:Int = 1, to:Int = 100000):Int
    {
        return from + Math.floor(((to - from + 1) * Math.random()));
    }


    @:generic static public function ArrayMod<T>( ArrayType:T, Length:Int ):Array<T> {
        var empty:Null<T> = null;
        var newArray:Array<T> = new Array<T>();

        for ( i in 0...Length ) {
            newArray.push( empty );
        }

        return newArray;
    }

    /*
    public SimplexNoise3D() {
        if (T == null) {
            System.Random rand = new System.Random();
            T = new int[8];
            for (int q = 0; q < 8; q++)
            T[q] = rand.Next();
        }
    }*/

    public function new(seed:String = null) {
        if(seed != null){
                T = ArrayMod( 1, 8 );
                var seed_parts:Array<String> = seed.split("");
                for ( q in 0...T.length ) 
                {
                    var b:Int;
                    try 
                    {
                        b = seed_parts[q].charCodeAt(0);
                    } 
                    catch(e:Dynamic)
                    {
                        b = 0x0;
                    }
                    T[q] = b;
                }

            }else{
                if (T == null) {
                    T = ArrayMod( 1, 8 );
                    for ( q in 0...T.length ) {
                        T[q] = randomInt();
                    }
                }
            }

        }

	//? public SimplexNoise3D(int[] seed) { /* {0x16, 0x38, 0x32, 0x2c, 0x0d, 0x13, 0x07, 0x2a} */T = seed;}

public  function GetSeed():String {
  var seed:String = "";
  for ( q in 0...T.length ) {
     seed += cast(T[q], String);
     if(q < 7){
        seed += " ";
     }   
 }

 return seed;
}

public function CoherentNoise(x:Float, y:Float, z:Float, octaves:Int=2,  multiplier:Int = 25, amplitude:Float = 0.5, lacunarity:Float = 2, persistence:Float = 0.9):Float {
  var v3:Vector3 = new Vector3(x/multiplier,y/multiplier,z/multiplier);
  var val:Float = 0;
    for ( n in 0...octaves ) {
        val += Noise(v3.x,v3.y,v3.z) * amplitude;
        //v3 *= lacunarity;
        amplitude *= persistence;
    }
    return val;
}

public function GetDensity(loc:Vector3):Int {
  var val:Float = CoherentNoise(loc.x, loc.y, loc.z);
  return Math.round(lerp(0,255,val));
}

    // Simplex Noise Generator
    public function Noise(x:Float, y:Float, z:Float):Float {
        s = (x + y + z) * onethird;
        i = fastfloor(x + s);
        j = fastfloor(y + s);
        k = fastfloor(z + s);

        s = (i + j + k) * onesixth;
        u = x - i + s;
        v = y - j + s;
        w = z - k + s;

        A[0] = 0; A[1] = 0; A[2] = 0;

        var hi:Int = u >= w ? u >= v ? 0 : 1 : v >= w ? 1 : 2;
        var lo:Int = u < w ? u < v ? 0 : 1 : v < w ? 1 : 2;

        return kay(hi) + kay(3 - hi - lo) + kay(lo) + kay(0);
    }

    private function kay(a:Int):Float
    {
        s = (A[0] + A[1] + A[2]) * onesixth;
        var x:Float = u - A[0] + s;
        var y:Float = v - A[1] + s;
        var z:Float = w - A[2] + s;
        var t:Float = 0.6 - x * x - y * y - z * z;
        var h:Int = shuffle(i + A[0], j + A[1], k + A[2]);
        A[a]++;
        if (t < 0) return 0;
        var b5:Int = h >> 5 & 1;
        var b4:Int = h >> 4 & 1;
        var b3:Int = h >> 3 & 1;
        var b2:Int = h >> 2 & 1;
        var b1:Int = h & 3;

        var p:Float = b1 == 1 ? x : b1 == 2 ? y : z;
        var q:Float = b1 == 1 ? y : b1 == 2 ? z : x;
        var r:Float = b1 == 1 ? z : b1 == 2 ? x : y;

        p = b5 == b3 ? -p : p;
        q = b5 == b4 ? -q : q;
        r = b5 != (b4 ^ b3) ? -r : r;
        t *= t;
        return 8 * t * t * (p + (b1 == 0 ? q + r : b2 == 0 ? q : r));
    }

    private function shuffle( i:Int, j:Int, k:Int):Int
    {
        return b(i, j, k, 0) + b(j, k, i, 1) + b(k, i, j, 2) + b(i, j, k, 3) + b(j, k, i, 4) + b(k, i, j, 5) + b(i, j, k, 6) + b(j, k, i, 7);
    }

    private function b(i:Int, j:Int, k:Int=null, B:Int=null):Int
    {
        if(k==null && B == null){
            return k >> B & 1;
        }
        return T[b(i, B) << 2 | b(j, B) << 1 | b(k, B)];
    }
    /*
    int b(int N, int B) 
    {
        return N >> B & 1;
    }
    */
    private function fastfloor(n:Float):Int 
    {
       return n > 0 ? Math.round(n) : Math.round((n - 1));
   }
}