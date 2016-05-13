package com.babylonvx.meshers;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.VertexData;
import com.babylonhx.math.Matrix;


@:expose('BABYLONVX.GreedyMesh') class GreedyMesh{
	var mask = new haxe.io.Int32Array(4096);
	var meta = new haxe.ds.Vector(4096);
	var volume:Array<Int> = new Array();
	var dims:Array<Int> = new Array();
	var evaluateFunction:Dynamic;
	var passID:Int;

	public function new(volume:Array<Int>, dims:Array<Int>, evaluateFunction:Dynamic, passID:Int):Void
	{	
		this.volume = volume;
		this.dims = dims;
		this.evaluateFunction = evaluateFunction;
		this.passID = passID;
	}

	public function f(i:Int,j:Int,k:Int):Float{
    	return volume[(i + dims[0] * (j + dims[1] * k))];
  	}

  	public function subtractVec(_vec1:Dynamic, _vec2:Dynamic):Dynamic {
		var x = _vec1.x - _vec2.x;
		var y = _vec1.y - _vec2.y;
		var z = _vec1.z - _vec2.z;
		return {x:x, y:y, z:z}
	}

  	public function getData():Dynamic{
  	  var vertices = [], faces = [], normals = [], uvs = [], uv2s = [], uv3s = [], uv4s = [];
	  
	  for(d in 0...3) {
	    var i, j, k, l, w, h
	      , u = (d+1)%3
	      , v = (d+2)%3
	      , x = [0,0,0]
	      , q = [0,0,0]
	      , nm:Array<Float>;
	    if(mask.length < dims[u] * dims[v]) {
	      mask = new haxe.io.Int32Array(dims[u] * dims[v]);
	    }
	    q[d] = 1;
	    x[d] = -1;
	    while(x[d] < dims[d]) {
	      var n = 0;
	      x[v]=0;
	      w = 1;
	      while(x[v]<dims[v]) {
	      x[u]=0;
	      while(x[u]<dims[u]) {
	        var a:Dynamic = (0    <= x[d]      ? this.f(x[0],      x[1],      x[2])      : 0)
	          , b:Dynamic = (x[d] <  dims[d]-1 ? this.f(x[0]+q[0], x[1]+q[1], x[2]+q[2]) : 0);
	        var metaA:Int  = 0;
	 		var metaB:Int = 0;
	        if(Std.is(a, Array)) {metaA = a[1]; a = a[0];}
	        if(Std.is(b, Array)) {metaB = b[1]; b = b[0];}
	        if(evaluateFunction(a, metaA, passID) == evaluateFunction(b, metaB, passID)) {
	          mask.set(n, 0);
	          meta[n] = 0;
	        } else if(evaluateFunction(a, metaA, passID)) {
	          mask.set(n, a);
	          meta[n] = metaA;
	        } else {
	          mask.set(n, cast(-b));
	          meta[n] = metaB;
	        }
	        n++;
	        x[u]++;
	      }
	      	x[v]++;
	  	  }
	      x[d]++;
	      n = 0;
	      var j = 0;
	      while(j < dims[v]) {
	      var i = 0;
	      while(i < dims[u]) {
	        var c = mask[n];
	        var metaC = meta[n];
	        if(c!=0) {
	          var w = 1;
	          while(c == mask[n+w] && i+w<dims[u]){
	          	w++;
	          }
	          var done = false;
	          var h = 1;
	          while(j+h < dims[v]) {
	          	var k=0;
	          	while(k < w) {
	              if(c != mask[n+k+h*dims[u]]) {
	                done = true;
	                break;
	              }
	              k++;
	            }
	            if(done) {
	              break;
	            }
	            h++;
	          }
	          //Add quad
	          x[u] = i;  x[v] = j;

	          nm = [0,0,0];
	          //nm[d] = c > 0.0 ? 1.0 : -1.0;

	          var du = [0,0,0]
	            , dv = [0,0,0];
	          if(c > 0) {
	            dv[v] = h;
	            du[u] = w;
	          } else {
	            c = -c;
	            du[v] = h;
	            dv[u] = w;
	          }
	        

	          
	          var vertex_count = vertices.length/3;
	          vertices.push(x[0]);
	          vertices.push(x[1]);
	          vertices.push(x[2]);
	          vertices.push(x[0]+du[0]);
	          vertices.push(x[1]+du[1]);
	          vertices.push(x[2]+du[2]);
	          vertices.push(x[0]+du[0]+dv[0]);
	          vertices.push(x[1]+du[1]+dv[1]);
	          vertices.push(x[2]+du[2]+dv[2]);
	          vertices.push(x[0]+dv[0]);
	          vertices.push(x[1]+dv[1]);
	          vertices.push(x[2]+dv[2]);

	          faces.push([vertex_count, vertex_count+1, vertex_count+2, c, metaC]);
	          faces.push([vertex_count, vertex_count+2, vertex_count+3, c, metaC]);
	      	 


	          normals.push(nm[0]);
	          normals.push(nm[1]);
	          normals.push(nm[2]);
 
	          normals.push(nm[0]);
	          normals.push(nm[1]);
	          normals.push(nm[2]);
	         
	          normals.push(nm[0]);
	          normals.push(nm[1]);
	          normals.push(nm[2]);

	          normals.push(nm[0]);
	          normals.push(nm[1]);
	          normals.push(nm[2]);
			
	      
			

	          for(l in 0...h)
	          for(k in 0...w) {
	            mask[n+k+l*dims[u]] = 0;
	          }

	          i += w; n += w;
	        } else {
	          i++;    n++;
	        }
	      }
	      j++;
	  	  }
	    }
	  }
	  return { vertices: vertices, faces: faces, normals: normals, uvs: uvs, uv2s: uv2s, uv3s: uv3s};

  }


}
 