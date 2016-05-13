package com.babylonvx;
import com.babylonhx.mesh.primitives.Box;
import com.babylonvx.World;
import com.babylonvx.Block;


@:expose('BABYLONVX.Chunk') class Chunk{

	@:isVar public var _sizeX(get, never):Int = 12;
	@:isVar public var _sizeY(get, never):Int = 12;
	@:isVar public var _sizeZ(get, never):Int = 12;
	public function get__sizeX(){return _sizeX;}
	public function get__sizeY(){return this._sizeY;}
	public function get__sizeZ(){return this._sizeZ;}
	public inline static var SizeX:Int = 12;
	public inline static var SizeY:Int = 12;
	public inline static var SizeZ:Int = 12;
	//public function SizeX():Int { return this.get__sizeX(); }
	//public function SizeY():Int { return this.get__sizeY(); }
	//public function SizeZ():Int { return this.get__sizeZ(); }

	
	private  var _worldRef:World;
	
    private var _blocks:Dynamic;
 	private var _wx:Int = 0;
 	private var _wy:Int = 0;
 	private var _wz:Int = 0;
	
	@:isVar private var _chunkObject(get, set):ChunkObject;

	public function get__chunkObject():ChunkObject{ return this._chunkObject; } 
	public function set__chunkObject(value:ChunkObject):ChunkObject{  _chunkObject = value; _chunkObject.SetChunk(this); return this._chunkObject; } 


	public var ChunkObject:Dynamic = function(_Chunk:Chunk):Dynamic
	{ 
		var get_chunkObject = _Chunk.get__chunkObject;
		var set_chunkObject = _Chunk.set__chunkObject; 
		return {
			get_chunkObject:get_chunkObject,
			set_chunkObject:set_chunkObject
		} 
	}
	
	public function new(world:World, x:Int = null, y:Int = null, z:Int = null)
	{
		_worldRef = world;
		if(x != null && y != null && z != null){
			this._blocks = Vector3D.create(_sizeX, _sizeY, _sizeZ);
			
			_wx = x * _sizeX;
			_wy = y * _sizeY;
			_wz = z * _sizeZ;
		}
	}
	
	public function SetDirty():Void
	{
		if (_chunkObject != null)
			_chunkObject.SetDirty();
	}
	
	public function RefreshChunkMesh():Void
	{
		//_chunkObject.ChunkMesh.mesh.Clear();
		//_chunkObject.ChunkMesh.mesh = ChunkRenderer.Render(this);
		//_chunkObject.ChunkCollider.sharedMesh = _chunkObject.ChunkMesh.mesh;
	}

    // Get the block using chunk coordinates. 0,0,0 is the first block in the chunk
    //http://haxe.org/manual/types-abstract-array-access.html
    public var Block:Dynamic = function(_Chunk:Chunk, _world:World):Dynamic
    {
        var get:Dynamic = function(lx:Int, ly:Int, lz:Int):Dynamic
		{
			if (lx >= 0 && lx < _Chunk._sizeX && ly >= 0 && ly < _Chunk._sizeY && lz >= 0 && lz < _Chunk._sizeZ)
			{
				if(_Chunk._blocks[lx][ly][lz] != null)
					_Chunk._blocks[lx][ly][lz].Chunk = _Chunk;
            	return _Chunk._blocks[lx][ly][lz];
			}
			else
			{
				// Fallback if the block is not inside this chunk
				//return _Chunk._worldRef._chunks.get(_wx+lx).get(_wy+ly).get(_wz+lz);
				return _Chunk._worldRef._chunks[_Chunk._wx+lx][_Chunk._wy+ly][_Chunk._wz+lz];

				//return _Chunk._worldRef.Block.get(_wx+lx, _wy+ly, _wz+lz, _world);

			}
        }               
        var set:Dynamic = function(lx:Int, ly:Int, lz:Int, value:Block) 
		{
			if (lx < _Chunk._sizeX && ly < _Chunk._sizeY && lz < _Chunk._sizeZ)
			{
            	_Chunk._blocks[lx][ly][lz] = value;
				_Chunk._blocks[lx][ly][lz].Chunk = _Chunk;
			}
        }
        return {
        	get:get,
        	set:set
        }

    }
 
}
