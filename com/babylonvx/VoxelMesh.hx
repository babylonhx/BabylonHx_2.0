package com.babylonvx;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.MultiMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.mesh.SubMesh;
import com.babylonvx.utility.Utils;
import com.babylonvx.meshers.GreedyMesh;
import com.babylonhx.mesh.VertexData;
import com.babylonhx.math.Matrix;
import com.babylonhx.Scene;
import com.babylonhx.Node;




@:expose('BABYLONVX.VoxelMesh') class VoxelMesh extends Mesh{

	private var root:VoxelMesh;
	private var transparentMesh:Dynamic;
	private var scene:Scene;
	public var voxelData:Dynamic;
	public var _vertexData:Dynamic;
	public var coloringFunction:Dynamic;
	public var evaluateFunction:Dynamic;
	public var subMeshMaterials:Dynamic;
	public var noVoxels:Bool;
	public var mesher:GreedyMesh;
	public var oldVisibility:Bool;
	public var hasTransparency:Bool = false;	
	
	

	public function new(name:String, scene:Scene, parent:Node = null, ?source:Mesh, doNotCloneChildren:Bool = false):Void
	{
		super(name, scene, parent, source, doNotCloneChildren);	
		this.noVoxels = true;
		this.oldVisibility = true;
		this.scene = scene;
		//Set up transparent mesh
		this.transparentMesh = new Mesh(name+'-tsp', scene, this);
		this.transparentMesh.noVoxels = true;
		this.transparentMesh.oldVisibility = true;
		this.transparentMesh.hasVertexAlpha = true;
		this.transparentMesh.parent = this;
		this.root = this;

		this.voxelData = {
			voxels: null,
			dimensions:null
		}

		this.coloringFunction = function(id:Int):Array<Int>{
			return [Math.round(id/5), Math.round(id/5), Math.round(id/5)];
		}

		this.evaluateFunction =  function(id:Int, meta:Int):Bool{
			return (id!=0);
		}

		this.subMeshMaterials = function():Dynamic{
			var materialPlane = new StandardMaterial("texturePlane", scene);
			materialPlane.diffuseTexture = new Texture("assets/img/grass.jpg", scene);
			//materialPlane.diffuseTexture.uScale = 5.0;//Repeat 5 times on the Vertical Axes
			//materialPlane.diffuseTexture.vScale = 5.0;//Repeat 5 times on the Horizontal Axes
			materialPlane.backFaceCulling = false;//Allways show the front and the back of an element

			var material0 = new StandardMaterial("mat0", this.scene);
		    material0.diffuseColor = new Color3(1, 0, 0);
		    material0.bumpTexture = new Texture("assets/img/normalMap.jpg", this.scene);

		    
		    var material1 = new StandardMaterial("mat1", this.scene);
		    material1.diffuseColor = new Color3(0, 0, 1);

		    
		    var material2 = new StandardMaterial("mat2", this.scene);
		    material2.diffuseColor = new Color3(0, 1, 1);
		    //material2.emissiveColor = new Color3(0.4, 0, 0.4);

		    var multimat = new MultiMaterial("multi", this.scene);
			multimat.subMaterials.push(material0);
			multimat.subMaterials.push(material1);
			multimat.subMaterials.push(material2);




			var verticesCount = this.getTotalVertices();
			//this.subMeshes.push(new SubMesh(0, 0, verticesCount, 0, verticesCount, this));

			this.subMeshes.push(new SubMesh(0, 0, verticesCount, 0, Math.round(verticesCount/3), this));
			this.subMeshes.push(new SubMesh(1, 0, verticesCount, Math.round(verticesCount/3), Math.round(verticesCount/3), this));
			this.subMeshes.push(new SubMesh(2, 0, verticesCount, (Math.round(verticesCount/3)*2), Math.round(verticesCount/3), this));
			
			this.material = multimat;
			trace(verticesCount);
			return verticesCount;
		};
		//var vertCount = this.subMeshMaterials(this, scene);


	}

	public function setVoxelAt(pos:Array<Int>, id:Int, meta:Int):Bool{
		if(this.voxelData.voxels != null) {
			this.voxelData.voxels[this.positionToIndex(pos)] = [id,meta];
			return true;
		}
	trace('Error: please set the dimensions of the voxelData first!');
	return false;
	}

	public function setMetaAt(pos:Array<Int>, meta:Int):Bool{
		if(this.voxelData.voxels != null) {
			//if(Std.is(x, Array)){
				var index = this.positionToIndex(pos);
				if(Std.is(this.voxelData.voxels[index], Array)) {
					this.voxelData.voxels[this.positionToIndex(pos)][1] = meta;
					return true;
				}
			//}
		}
		trace('Error: please set the dimensions of the voxelData first!');
		return false;
	}

	public function setVoxelBatch(voxels:Array<Int>, id:Int, meta:Int=null){
		for(i in 0...voxels.length) {
			var voxel = voxels[i];
			trace('todo');
			if(voxels.length < 4 && meta != null) {
				this.setVoxelAt(voxels, id, meta);
			} else if (voxels.length < 5 && meta != null) {
				this.setVoxelAt(voxels, voxels[3], meta);
			} else {
				this.setVoxelAt(voxels, voxels[3], voxels[4]);
			}
		}
	}

	public function getVoxelAt(pos:Array<Int>):Array<Float>{
		if(this.voxelData.voxels != null) {
			return this.voxelData.voxels[this.positionToIndex(pos)];
		} else {
			trace('Error: please set the dimensions of the voxelData first!');
			return [0];
		}

	}

	public function setVoxelData(voxelData:Dynamic){
		this.voxelData = voxelData;
	}

	public function getVoxelData():Dynamic{
		return this.voxelData;
	}

	public function setDimensions(dims:Array<Int>){
		if (dims.length == 3) {
			if(this.voxelData == null) {
				this.voxelData = {};
			}
			
			this.voxelData.dimensions = dims;
			if(this.voxelData.voxels == null) {
				this.voxelData.voxels = new haxe.ds.Vector(dims[0]*dims[1]*dims[2]);
			}
		} else {
			trace('Error: dimensions must be an array [x,y,z]');
		}
	}

	public function indexToPosition(i:Int):Array<Float>{
		return [i % this.voxelData.dimensions[0], Math.floor((i / this.voxelData.dimensions[0]) % this.voxelData.dimensions[1]), Math.floor(i / (this.voxelData.dimensions[1] * this.voxelData.dimensions[0]))];
	}

	public function positionToIndex(pos:Array<Int>):Int{
		return Math.round(pos[0]+(pos[1]*this.voxelData.dimensions[0])+(pos[2]*this.voxelData.dimensions[0]*this.voxelData.dimensions[1]));
	}

	public function updateMesh(passID:Int = null){
		if(passID == null){
			passID = 0;
		}
		this.mesher = new GreedyMesh(this.voxelData.voxels, this.voxelData.dimensions, this.evaluateFunction, passID);
		var rawMesh:Dynamic = this.mesher.getData();
		
		var indices = [];
		var colors = [];
		//var uvs = [];
		for(i in 0...rawMesh.faces.length) {
			var q = rawMesh.faces[i];
			indices.push(q[2]);
			indices.push(q[1]);
			indices.push(q[0]);

			//uvs.push(1.0);	
			//uvs.push(0.0);	
			
			//Get the color for this voxel
			var color:Array<Int> = this.coloringFunction(q[3], q[4]);
			if(color == null || color.length < 3) {
				color = [300,75,300,255];
			} else if (color.length == 3) {
				color.push(255);
			}
			for(i2 in 0...3) {
				colors[q[i2]*4] = color[0]/255;
				colors[(q[i2]*4)+1] = color[1]/255;
				colors[(q[i2]*4)+2] = color[2]/255;
				colors[(q[i2]*4)+3] = color[3]/255;
				continue;
			}
		}
					
		var vertexData = new VertexData();
		vertexData.positions = rawMesh.vertices;
		vertexData.indices = indices;
		vertexData.normals = rawMesh.normals;
		vertexData.colors = colors;
		vertexData.uvs = rawMesh.uvs;
		vertexData.applyToMesh(this);
		this._vertexData = vertexData;


		//vertexData.uv2s = rawMesh.uv2s;
		//vertexData.uv3s = rawMesh.uv3s;
		//vertexData.uv4s = rawMesh.uv4s;
		//vertexData.uvs = uvs;

		//VertexData.ComputeNormals(rawMesh.vertices, indices, rawMesh.normals);

		//VertexData._ComputeSides(Mesh.DEFAULTSIDE, rawMesh.vertices, indices, rawMesh.normals, rawMesh.uvs);
		
		if(passID == 0) {
			if(vertexData.positions.length > 0) {
				if(this.noVoxels = true) {
					this.isVisible = this.oldVisibility;
					this.noVoxels = false;
				}
				
				vertexData.applyToMesh(this, true);
				this._updateBoundingInfo();
				
				if(this.hasTransparency) {
					this.updateMesh(1);
				}
			} else {
				this.noVoxels = true;
				this.oldVisibility = this.isVisible;
				this.isVisible = false;
			}
		} else if (passID == 1) {
			if(vertexData.positions.length > 0) {
				if(this.transparentMesh.noVoxels = true) {
					this.transparentMesh.isVisible = this.transparentMesh.oldVisibility;
					this.transparentMesh.noVoxels = false;
				}
				vertexData.applyToMesh(this.transparentMesh, true);
				this.transparentMesh._updateBoundingInfo();
			} else {
				this.transparentMesh.noVoxels = true;
				this.transparentMesh.oldVisibility = this.transparentMesh.isVisible;
				this.transparentMesh.isVisible = false;
			}
		}

		//super.convertToFlatShadedMesh();
	}

	public function originToCenterOfBounds(ignoreY:Bool){
		var pivot = [
		-this.voxelData.dimensions[0]/2,
		-this.voxelData.dimensions[1]/2,
		-this.voxelData.dimensions[2]/2
		];
		
		if(ignoreY) {
			pivot[1] = 0;
		}
	
		this.setPivot(pivot);
	}

	public function setPivot(pivot:Array<Float>){
		var pivot = Matrix.Translation(pivot[0],pivot[1],pivot[2]);
	
		this.setPivotMatrix(pivot);
	}

	/*Exports the voxel data to a more portable form which is dimension-independent and can be more compact.
format:
{
	dimensions: [x,y,z],
	voxels: [
		[0,0,0, id, meta], //x,y,z coordinates, then the voxel id, then metadata.
		[1,1,0, id, meta],
	],
}
*/

	public function exportVoxelData():Dynamic{
		var convertedVoxels = [];
		for (i in 0...this.voxelData.voxels.length) {
			var voxel = this.voxelData.voxels[i];
			if (voxel != null) {
				var pos = this.indexToPosition(i);
				pos.push(voxel[0]);
				pos.push(voxel[1]);
				convertedVoxels.push(pos);
			}
		}
	return {dimensions: this.voxelData.dimensions, voxels: convertedVoxels};
	}

	public function importZoxel(zoxelData:Dynamic){
		var dataVX:Dynamic = {};
		dataVX.dimensions = [zoxelData.width, zoxelData.height, zoxelData.depth];
		
		dataVX.voxels = haxe.Json.parse(haxe.Json.stringify(zoxelData.frame1));
		
		for(i in 0...dataVX.voxels.length) {
			dataVX.voxels[i][3] = dataVX.voxels[i][3]/100;
		}
		
		this.coloringFunction = function(id):Dynamic {
			return Utils.hex2rgb(cast(id*100));
		}
		
		this.setDimensions(dataVX.dimensions);
		this.setVoxelBatch(dataVX.voxels, 0xFFFFFF, 0);
	}

	public function exportZoxel(){
		var dataVX = this.exportVoxelData();
		var zoxelData:Dynamic = {};
		zoxelData.creator = "dataVX Exporter";
		zoxelData.width = dataVX.dimensions[0];
		zoxelData.height = dataVX.dimensions[1];
		zoxelData.depth = dataVX.dimensions[2];
		
		zoxelData.version = 1;
		zoxelData.frames = 1;
		
		zoxelData.frame1 = dataVX.voxels;
		
		for(i in 0...zoxelData.frame1.length) {
			var hexColor:Dynamic = Utils.rgb2hex(this.coloringFunction(zoxelData.frame1[i][3], zoxelData.frame1[i][4]));
			if(hexColor.length <= 6) {
				zoxelData.frame1[i][3] = Std.parseInt(hexColor+'FF');
			} else {
				zoxelData.frame1[i][3] = Std.parseInt(hexColor);
			}
		}
		
		return zoxelData;
	}

	public function makeVoxels(l:Array<Int>, h:Array<Int>, f:Dynamic):Dynamic {
	    var d = [ h[0]-l[0], h[1]-l[1], h[2]-l[2] ]
	      , v = new  haxe.io.Int32Array(d[0]*d[1]*d[2])
	      , n = 0;
	    var k=l[2];
	    while(k<h[2]){
	    	var j=l[1];
	    	while(j<h[1]){
	    		var i=l[0];
	    		while(i<h[0]){
	    			v[n] = f(i,j,k);
	    			i++; n++;
	    		}
	    		j++;
	    	}
	    	k++;
	    }
	    this.voxelData.voxels = v;
	    this.voxelData.dimensions = d;
	    return {voxels:v, dims:d};
	  }


	public function handlePick(pickResult:Dynamic):Dynamic{
		var mesh = pickResult.pickedMesh.root;
		var point = pickResult.pickedPoint;
		
		var m = new Matrix();
		mesh.getWorldMatrix().invertToRef(m);
		var v = Vector3.TransformCoordinates(point, m);
		var x:Int, z:Float,y:Float,z:Float, voxel1:Array<Float> = [], voxel2:Array<Float> = [];
		trace('optimize this');
		//var offsetX = (v.x-v.x.toFixed(0)).toFixed(4);
		//https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/toFixed
		var offsetX = (v.x-v.x);
		var offsetY = (v.y-v.y);
		var offsetZ = (v.z-v.z);
		
		if(offsetX == 0) {
			x = Math.round(v.x);
			y = Math.floor(v.y);
			z = Math.floor(v.z);
			if(x>=mesh.voxelData.dimensions[0]) x=mesh.voxelData.dimensions[0]-1;

			voxel1 = [x,y,z];
			voxel2 = [x-1,y,z];
		} else if (offsetY == 0) {
			x = Math.floor(v.x);
			y = Math.round(v.y);
			z = Math.floor(v.z);
			if(y>=mesh.voxelData.dimensions[1]) y=mesh.voxelData.dimensions[1]-1;

			voxel1 = [x,y,z];
			voxel2 = [x,y-1,z];
		} else if (offsetZ == 0) {
			x = Math.floor(v.x);
			y = Math.floor(v.y);
			z = Math.round(v.z);
			if(z>=mesh.voxelData.dimensions[2]) z=mesh.voxelData.dimensions[2]-1;

			voxel1 = [x,y,z];
			voxel2 = [x,y,z-1];
		}
		
		if(!mesh.getVoxelAt(voxel1)) {
			pickResult.over = voxel1;
			pickResult.under = voxel2;
			return pickResult;
		} else {
			pickResult.over = voxel2;
			pickResult.under = voxel1;
			return pickResult;
		}
	}

}
 