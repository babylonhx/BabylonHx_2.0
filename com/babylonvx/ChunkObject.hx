package com.babylonvx;
import com.babylonhx.mesh.primitives.Box;
import com.babylonhx.mesh.Geometry;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;


@:expose('BABYLONVX.ChunkObject') class ChunkObject  extends Box {
	//todo omoioPhysics
	public var _chunkMesh:Array<Mesh>;
	public var _mesh:Mesh;
	public var ChunkMesh:Dynamic = function(_ChunkObject:ChunkObject):Dynamic{
		var _chunkMesh = _ChunkObject._chunkMesh;
		return{
			_chunkMesh:_chunkMesh
		}
	}
	//public  var _chunkCollider:MeshCollider;
	//public var ChunkCollider:MeshCollider { get { return _chunkCollider; } set { _chunkCollider = value; } }

	private var _chunk:Chunk;
	private var _dirty:Bool = false;
	
	public function new(id:String, scene:Scene, size:Float, ?canBeRegenerated:Bool, ?mesh:Mesh, side:Int = Mesh.DEFAULTSIDE){
		super(id, scene, size, canBeRegenerated, mesh, side);
		//this._chunkMesh = this._meshes;
		//this._mesh = Mesh.CreateBox(id, size, scene);
		//this._checkCollisions = true;
	}
	
	
	public function SetChunk(chunk:Chunk):Void
	{
		_chunk = chunk;
	}
	
	public function SetDirty():Void 
	{
		_dirty = true;
	}
	
	public function LateUpdate():Void
	{
		if (_dirty == true)
		{
			_dirty = false;
			_chunk.RefreshChunkMesh();
		}
	}
}
