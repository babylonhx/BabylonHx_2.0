package com.babylonvx;
import com.babylonvx.Block;
import com.babylonhx.Scene;
import haxe.ds.Vector;
/// <summary>
/// This class is heavily based on this tutorial: http://www.blockstory.net/node/58
/// As the tutorial suggests, there is many optimizations that could be applied, 
/// but for the sake of simplicity I'm distributing the source without it.
/// </summary>

class Vector3D {
    public static function create(x: Int, y: Int, z: Int) {
        var v = new Vector(x);

        for (iy in 0...x) {
            v[iy] = new Vector(y);
            for (iz in 0...y) {
                v[iy][iz] = new Vector(z);
            }
        }
        for (iz in 0...z) {
            v[0][0][iz] = null;
            for (iy in 0...y) {
                v[0][iy][iz] = null;
                for (ix in 1...x) {
                    v[ix][iy][iz] = null;
                }
            }
        }

        return v;
    }
}



@:expose('BABYLONVX.World') class World
{
    // How far the player can see
    @:isVar public var _visibleX(get, never):Int = 2;
    @:isVar public var _visibleY(get, never):Int = 1;
    @:isVar public var _visibleZ(get, never):Int = 2;
    public var _scene:Scene;

    @:isVar private var _worldVisibleSizeX(get, set):Int;
	@:isVar private var _worldVisibleSizeY(get, set):Int;
	@:isVar private var _worldVisibleSizeZ(get, set):Int;

	public function get__worldVisibleSizeX(){return this._worldVisibleSizeX;}
    public function get__worldVisibleSizeY(){return this._worldVisibleSizeY;}
    public function get__worldVisibleSizeZ(){return this._worldVisibleSizeZ;}
    public function set__worldVisibleSizeX(value:Int){this._worldVisibleSizeX = value; return this._worldVisibleSizeX;}
    public function set__worldVisibleSizeY(value:Int){this._worldVisibleSizeY = value; return this._worldVisibleSizeY;}
    public function set__worldVisibleSizeZ(value:Int){this._worldVisibleSizeZ = value; return this._worldVisibleSizeZ;}


    //@:isVar public var _chunks:Map<Int,Map<Int,Map<Int,Chunk>>>;
    @:isVar public var _chunks:Dynamic;



    //public function get__chunks(){return this._chunks;}

	public var Chunks:Dynamic = function(_world:World):Dynamic{
		var get_chunks = _world._chunks;
		return{
			get_chunks: get_chunks
		}
	} 

	@:isVar private var _lightAttenuation(get, set):Bool;
	public function set__lightAttenuation(value:Bool):Bool{this._lightAttenuation = value;return this._lightAttenuation;}
	public function get__lightAttenuation():Bool{return this._lightAttenuation;}
	/*public var LightAttenuation:Dynamic = function(_world:World):Dynamic{
		this.set_lightAttenuation = _world.set__worldVisibleSizeX;
		
	}*/


    public function get__visibleX(){return this._visibleX;}
    public function get__visibleY(){return this._visibleY;}
    public function get__visibleZ(){return this._visibleZ;}

	public var WorldVisibleSizeX:Dynamic = function(_world:World):Dynamic{
		var get_worldVisibleSizeX = _world.get__worldVisibleSizeX;
		return{
			get_worldVisibleSizeX: get_worldVisibleSizeX
		}
	} 

	public var WorldVisibleSizeY:Dynamic = function(_world:World):Dynamic{
		var get_worldVisibleSizeY = _world.get__worldVisibleSizeY;
		return{
			get_worldVisibleSizeY: get_worldVisibleSizeY
		}
	} 

	public var WorldVisibleSizeZ:Dynamic = function(_world:World):Dynamic{
		var get_worldVisibleSizeZ = _world.get__worldVisibleSizeZ;
		return{
			get_worldVisibleSizeZ: get_worldVisibleSizeZ
		}
	} 

	public var VisibleX:Dynamic = function(_world:World):Dynamic{
		var get_visibleX = _world.get__visibleX;
		return{
			get_visibleX: get_visibleX
		}
	} 

	public var VisibleY:Dynamic = function(_world:World):Dynamic{
		var get_visibleY = _world.get__visibleY;
		return{
			get_visibleY: get_visibleY
		}
	} 

	public var VisibleZ:Dynamic = function(_world:World):Dynamic{
		var get_visibleZ = _world.get__visibleZ;
		return{
			get_visibleZ: get_visibleZ
		}
	} 

	public function new(scene:Scene)
	{
		this._scene = scene;
		trace(this._visibleX);
		this._chunks = Vector3D.create(_visibleX, _visibleY, _visibleZ);
		for (x in 0...this._visibleX) {
			for (y in 0...this._visibleY) {
				for (z in 0...this._visibleZ) {
					this._chunks[x][y][z] = new Chunk(this,x,y,z);
				}
			}
		}

		//_worldVisibleSizeX = _worldVisibleSizeY = _worldVisibleSizeZ = 12;
		
		_worldVisibleSizeX = _visibleX * Chunk.SizeX;
		_worldVisibleSizeY = _visibleY * Chunk.SizeY;
		_worldVisibleSizeZ = _visibleZ * Chunk.SizeZ;
		
		trace('passed3');
	}

	// Create a chunk
	public function CreateChunkMesh(x:Int, y:Int, z:Int, chunkObject:ChunkObject):Void
	{
		//chunkObject.ChunkMesh.mesh = ChunkRenderer.Render(_chunks[x,y,z]);
		//chunkObject.ChunkCollider.sharedMesh = chunkObject.ChunkMesh.mesh;
		_chunks[x][y][z].ChunkObject = chunkObject;
	}
	
	// Refresh chunk and neighbors mesh by a given world position IEnumerator
	public function RefreshChunkMesh(worldPos:Vector3i, async:Bool = false)
	{
		//ChunkRenderer.UpdateHeightMap(this, worldPos, _worldVisibleSizeY);
		
		if (_lightAttenuation == true){
			//ChunkRenderer.LightningFloodArea(this, worldPos, _worldVisibleSizeY);
		}
	
		var blockPosInsideChunk:Vector3i = WorldToChunkPosition(worldPos);
		
		// Refresh Main Chunk (the chunk that contains the worldPosition)
		var chunkIndex:Vector3i = GetChunkIndex(worldPos);
		RefreshChunkMeshByIndex( chunkIndex );
		//if (async) yield return null;

		// Refresh chunk neighbors if needed
		//#region RefreshChunkNeighbors
		if (blockPosInsideChunk.y >= Chunk.SizeY-1)
		{
			var neighborChunkIndex:Vector3i = chunkIndex;
			neighborChunkIndex.y++;
			RefreshChunkMeshByIndex(neighborChunkIndex);
			//if (async) yield return null;
		}
		if (blockPosInsideChunk.y <= 0)
		{
			var neighborChunkIndex:Vector3i = chunkIndex;
			neighborChunkIndex.y--;
			RefreshChunkMeshByIndex(neighborChunkIndex);
			//if (async) yield return null;
		}
		
		if (blockPosInsideChunk.x >= Chunk.SizeX-1)
		{
			var neighborChunkIndex:Vector3i = chunkIndex;
			neighborChunkIndex.x++;
			RefreshChunkMeshByIndex(neighborChunkIndex);
			//if (async) yield return null;
		}
		if (blockPosInsideChunk.x <= 0)
		{
			var neighborChunkIndex:Vector3i = chunkIndex;
			neighborChunkIndex.x--;
			RefreshChunkMeshByIndex(neighborChunkIndex);	
			//if (async) yield return null;
		}
	
		if (blockPosInsideChunk.z >= Chunk.SizeZ-1)
		{
			var neighborChunkIndex:Vector3i = chunkIndex;
			neighborChunkIndex.z++;
			RefreshChunkMeshByIndex(neighborChunkIndex);
			//if (async) yield return null;
		}
		if (blockPosInsideChunk.z <= 0)
		{
			var neighborChunkIndex:Vector3i = chunkIndex;
			neighborChunkIndex.z--;
			RefreshChunkMeshByIndex(neighborChunkIndex);	
			//if (async) yield return null;
		}
		//#endregion
	}
	
	// Refresh chunk mesh by chunk index
	public function RefreshChunkMeshByIndex(chunkIndex:Vector3i)
	{
		var x:Int = Math.round(chunkIndex.x);
		var y:Int = Math.round(chunkIndex.y);
		var z:Int = Math.round(chunkIndex.z);
		
		if ( (x >= 0 && x < _visibleX) && (y >= 0 && y < _visibleY) && (z >= 0 && z < _visibleZ) )
		{
			_chunks[x][y][z].SetDirty();
		}
	}
	
	// Convert world to chunk position
	public function WorldToChunkPosition(worldPos:Vector3i):Vector3i
    {
		var cPos:Vector3i = GetChunkIndex(worldPos);
		
		cPos.x = worldPos.x % Chunk.SizeX;
        cPos.y = worldPos.y % Chunk.SizeY;
        cPos.z = worldPos.z % Chunk.SizeZ;
			
		return cPos;
    }    
	
	// Get chunk index based on world position
	public function GetChunkIndex(worldPos:Vector3i):Vector3i
    {
		var wx:Int = Math.round(worldPos.x);
		var wy:Int = Math.round(worldPos.y);
		var wz:Int = Math.round(worldPos.z);
		
		if (wx < 0 || wy < 0 || wz < 0)
			return Vector3i.zero;

		if (wx >= _worldVisibleSizeX || wy >= _worldVisibleSizeY || wz >= _worldVisibleSizeZ)
			return Vector3i.zero;
		
        // first calculate which chunk we are talking about:
		var cx:Int = Math.round((wx / Chunk.SizeX));
		var cy:Int = Math.round((wy / Chunk.SizeY));
		var cz:Int = Math.round((wz / Chunk.SizeZ));
		
        // request can be out of range, then return a Unknown block type
        if (cx < 0 || cy < 0 || cz < 0)
            return Vector3i.zero;
        if (cx >= _visibleX || cy >= _visibleY || cz >= _visibleZ)
            return Vector3i.zero;

        return new Vector3i(cx, cy, cz);
    }    

    // Get the block at position (wx,wy,wz) where these are the world coordinates
    //public Block this[int wx, int wy, int wz]
    public var Block:Dynamic = function():Dynamic
    {
    	var get:Dynamic = function(wx:Int, wy:Int, wz:Int, _world:World):Dynamic {
			if (wx < 0 || wy < 0 || wz < 0)
			
			return new Block(_world,  untyped BABYLONVX.BlockType.GetBlockType(0));
				//return new Block( untyped BABYLONVX.BlockType.WorldBound);

			if (wx >= _world._worldVisibleSizeX || wy >= _world._worldVisibleSizeY || wz >= _world._worldVisibleSizeZ)
				return new Block(_world, untyped BABYLONVX.BlockType.WorldBound);
			
            // first calculate which chunk we are talking about:
			var cx:Int = Math.round((wx / Chunk.SizeX) );
			var cy:Int = Math.round((wy / Chunk.SizeY) );
			var cz:Int = Math.round((wz / Chunk.SizeZ) );
			
            // request can be out of range, then return a Unknown block type
            if (cx < 0 || cy < 0 || cz < 0)
                return new Block(_world, untyped BABYLONVX.BlockType.Unknown);
            if (cx >= _world._visibleX || cy >= _world._visibleY || cz >= _world._visibleZ)
                return new Block(_world, untyped BABYLONVX.BlockType.Unknown);

            var chunk = _world._chunks[cx][cy][cz];
            //var chunk:Chunk = new Chunk(_world, cx, cy, cz);
            //var block = _chunks.get(cx,cy,cz);
            //var chunk:Chunk = block.Block.get(cx, cy, cz);

 
            // this figures out the coordinate of the block relative to chunk origin.
            var lx:Int = wx % Chunk.SizeX;
            var ly:Int = wy % Chunk.SizeY;
            var lz:Int = wz % Chunk.SizeZ;
 			
            return untyped chunk.Block(chunk, _world).get(lx,ly,lz);
        }               
        var set:Dynamic = function(wx:Int, wy:Int, wz:Int, _world:World, value:Block):Void {
            // first calculate which chunk we are talking about:
			var cx:Int = Math.round((wx / Chunk.SizeX) );
			var cy:Int = Math.round((wy / Chunk.SizeY) );
			var cz:Int = Math.round((wz / Chunk.SizeZ) );

            // cannot modify _chunks that are not within the visible area
			var insideVisibleBounds:Bool = true;
			
            if (cx < 0 || cx >= _world._visibleX)
               insideVisibleBounds = false;
            if (cy < 0 || cy >= _world._visibleY)
               insideVisibleBounds = false;
            if (cz < 0 || cz >= _world._visibleZ)
               insideVisibleBounds = false;
			
			if (insideVisibleBounds == true)
			{
				//var chunk:Chunk = new Chunk(_world, cx, cy, cz);
	            var chunk:Chunk = _world._chunks[cx][cy][cz];
	            // this figures out the coordinate of the block relative to chunk origin.
				var lx:Int = wx % Chunk.SizeX;
				var ly:Int = wy % Chunk.SizeY;
				var lz:Int = wz % Chunk.SizeZ;
	            //chunk[lx][ly][lz] = value;
	            chunk.Block(chunk, _world).set(lx,ly,lz, value);
			}
        }


    	return{
    		get:get,
    		set:set
    	}
    }
        
	

}