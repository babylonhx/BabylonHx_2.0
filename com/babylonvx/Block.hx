package com.babylonvx;
import com.babylonhx.mesh.primitives.Box;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Geometry;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.math.Color3;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;


enum BlockType 
{
	Grass;
	Dirt;
	Stone;
	Lava;
	Air;
	Height;
	Unknown;
	WorldBound; 
}

// Height-Type: is the first non-solid block over the highest block of its collumn
// Unknown-Type: is used as return type of some methods instead of just return Null
// WorldBound-Type: are the edge of the world. You know, there is no such thing like REAL infinite world...
//http://actionsnippet.com/?p=475


@:expose('BABYLONVX.BlockTypes') class BlockTypes{
    private static var  _types:Array<BlockBase> = [
		new GrassType(), new DirtType(), new StoneType(), new LavaType(), new AirType(), new HeightType(), new UnknownType(), new WorldBoundType() ];
     
    public static function GetBlockType(type:Dynamic):BlockBase
    {
         return _types[cast(type, Int)];
    }
}

// Note: This class should be a struct to use less memory per block, like the following article points out:
// http://www.blockstory.net/node/59
// But unfortunatly some bad decisions during this project made me change back to a class
@:expose('BABYLONVX.Block') class Block{
	public var Chunk:Chunk;
	public var material:StandardMaterial;
	@:isVar private var _minLight(get, never):Int = 51;
	@:isVar private var _maxLight(get, never):Int = 255;
	public function get__minLight() { return this._minLight; }
	public function get__maxLight() { return this._maxLight; } 
	@:isVar private var _type(get, set):BlockType; 
	public function get__type() { return this._type; }
	public function set__type(_type:BlockType):BlockType { this._type = _type; return this._type; } 
	@:isVar private var _light(get, set):Int;
	public function get__light() { return this._light; }
	public function set__light(_Light:Int):Int{ this._light = _Light;return this._light; } 
	@:isVar private var _chunk(get, set):Chunk;
	public function get__chunk(){ return this._chunk; } 
	public function set__chunk(value:Chunk):Chunk{ _chunk = value;return this._chunk; }
	public var _wx:Int = 0;
	public var _wy:Int = 0;
	public var _wz:Int = 0;

	//todo omoioPhysics
	public var _chunkMesh:Array<Mesh>;
	public var _mesh:Mesh;

	public var MinLight:Dynamic = function(_Block:Block):Dynamic
	{ 
		var get__minLight = _Block.get__minLight;
		{ return get__minLight; } 
	
	}
	public var MaxLight:Dynamic = function(_Block:Block):Dynamic
	{ 
		var get__maxLight = _Block.get__maxLight;
		{ return get__maxLight; } 
	}

	//double check this one
	public var _Type:Dynamic = function(_Block:Block):Dynamic{ 
		var get_type:Dynamic = _Block.get__type;
		var set__type:Dynamic = _Block.set__type;
		return{
			get_type:get_type,
			set__type:set__type
		}
	}

	public function clamp(value:Float, min:Float, max:Float):Int {
	  var c = Math.max(min,Math.min(max,value));
	  return Math.round(c);
	}
	

	public var Light:Dynamic = function(_Block:Block):Dynamic
	{ 
		var get__light:Dynamic =  _Block.get__light;
		var set__light:Dynamic = function(value:Float)
		{ 
			function clamp(value:Float, min:Float, max:Float):Int {
			  var c = Math.max(min,Math.min(max,value));
			  return Math.round(c);
			}
			var light =  clamp(value, _Block._minLight, _Block._maxLight);
			if (_Block._light != light)
			{
				_Block._light = light;
				if (_Block._chunk != null)
					_Block._chunk.SetDirty();
			}
		}
		return{
			get_light:get__light,
			set_light:set__light
		}
	}
	
	/*
	public var Chunk:Dynamic = function(_Block:Block):Dynamic
	{ 
		var get__chunk:Dynamic = _Block.get__chunk;
		var set__chunk:Dynamic = _Block.set__chunk;

		return{
			get_chunk:get__chunk,
			set_chunk:set__chunk
		}
	}*/

	//Block
	public function new( _world:World, type:BlockType, wx:Int = 0, wy:Int = 0, wz:Int = 0):Void
	{
		//material = new StandardMaterial("materail", _world._scene);
		//material9.diffuseColor = new Color3(1, 0, 1);
		//this.material = material9;

		this._mesh = Mesh.CreateBox(('x:'+_wx+'y:'+_wy+'z:'+_wz), 1, _world._scene);
		//this._mesh.material = material;

		_wx = wx;
		_wy = wy;
		_wz = wz;
		_type = type;

		this._mesh.scaling = new Vector3(12, 12, 12);
		this._mesh.position = new Vector3(_wx*12, _wy*12, _wy*12);
		var block = Block.BlockTypes.GetBlockType(untyped this._type[1]);
		if(block.materialImg != null){
			var _material = new StandardMaterial("material", _world._scene);
			_material.diffuseTexture = new Texture(block.materialImg, _world._scene);
			this._mesh.material = _material;
		}

		
		if (_type == BlockType.Height)
		{
			_light = _maxLight;	
		}
		else
		{
			_light = _minLight;
		}	
	}
	
    // Those methods looks up what class should serve this request, and forwards it
	// Note: remember this was supposed  to be a struct...
    public function IsSolid():Bool 
	{
       return BlockTypes.GetBlockType(_type).IsSolid(this);
    }
	
	public function TextureBottomUV():Vector2
	{
		return BlockTypes.GetBlockType(_type).TextureBottomUV(this);
	}
	
	public function TextureTopUV():Vector2
	{
		return BlockTypes.GetBlockType(_type).TextureTopUV(this);
	}

	public function TextureSideUV():Vector2
	{
		return BlockTypes.GetBlockType(_type).TextureSideUV(this);
	}
	
	public function TextureUV():Vector2
	{
		return BlockTypes.GetBlockType(_type).TextureUV(this);
	}
	
	public function Destroy():Bool
	{
		return BlockTypes.GetBlockType(_type).Destroy(this);
	}
	
	public function Create(type:BlockType):Bool
	{
		return BlockTypes.GetBlockType(_type).Create(this, type);
	}
}
 
// Base class for all type of blocks
@:expose('BABYLONVX.BlockBase') class BlockBase
{
	public var materialImg:String;

	public function new(){

	}

    public function IsSolid(block:Block):Bool
	{
		return false;
	}

	public function TextureBottomUV(block:Block):Vector2
	{
		 return Vector2.Zero();
	}
	
	public function TextureTopUV(block:Block):Vector2
	{
		 return Vector2.Zero();
	}
	
	public function TextureSideUV(block:Block):Vector2
	{
		 return Vector2.Zero();
	}
	
	public function TextureUV(block:Block):Vector2
	{
		 return Vector2.Zero();
	}
	
	public function Destroy(block:Block):Bool
	{
		if (IsSolid(block) == false)
		{
			return false;
		}

		if (block.Chunk != null)
		{
			block.Chunk.SetDirty();
		}
		block._Type = BlockType.Air;
		return true;
	}
	
	public function Create(block:Block, type:BlockType):Bool
	{
		if (IsSolid(block) == true)
		{
			return false;
		}
		
		if (block.Chunk != null)
		{
			block.Chunk.SetDirty();
		}
		block._Type = type;
		return true;
	}
}
 
//region DirtBlock
@:expose('BABYLONVX.DirtType') class DirtType extends BlockBase
{
	public function new(){
		super();
		materialImg = "assets/img/materialspack/dirty.png";
	}
    override public function IsSolid(block:Block):Bool
    {
        return true;
    }
	
    override public function TextureBottomUV(block:Block):Vector2
    {
        return new Vector2(0.00, 0.25);
    }
	
    override public function TextureTopUV(block:Block):Vector2
    {
        return new Vector2(0.00, 0.75);
    }

    override public function TextureSideUV(block:Block):Vector2
    {
        return new Vector2(0.00, 0.0);
    }
	
    override public function TextureUV(block:Block):Vector2
    {
        return new Vector2(0.00, 0.50);
    }
}
//#endregion

//#region StoneBlock
@:expose('BABYLONVX.StoneType') class StoneType extends BlockBase
{
	public function new(){
		super();
		materialImg = "assets/img/materialspack/stone.png";
	}

    override public function IsSolid(block:Block):Bool
    {
        return true;
    }

    override public function TextureBottomUV(block:Block):Vector2
    {
        return new Vector2(0.50, 0.25);
    }
	
    override public function TextureTopUV(block:Block):Vector2
    {
        return new Vector2(0.50, 0.75);
    }

    override public function TextureSideUV(block:Block):Vector2
    {
        return new Vector2(0.50, 0.0);
    }
	
    override public function TextureUV(block:Block):Vector2
    {
        return new Vector2(0.50, 0.50);
    }
}
//#endregion

//#region GrassBlock
@:expose('BABYLONVX.GrassType') class GrassType extends BlockBase
{
	public function new(){
		super();
		materialImg = "assets/img/materialspack/grassTop.jpg";
	}

    override public function IsSolid(block:Block):Bool
    {
        return true;
    }
	
    override public function TextureBottomUV(block:Block):Vector2
    {
         return new Vector2(0.25, 0.25);
    }
	
    override public function TextureTopUV(block:Block):Vector2
    {
         return new Vector2(0.25, 0.75);
    }

    override public function TextureSideUV(block:Block):Vector2
    {
         return new Vector2(0.25, 0.0);
	}
    
    override public function TextureUV(block:Block):Vector2
    {
         return new Vector2(0.25, 0.50);
    }
}
//#endregion

//#region LavaBlock
@:expose('BABYLONVX.LavaType') class LavaType extends BlockBase
{
	public function new(){
		super();
		materialImg = "assets/img/materialspack/lava.gif";
	}

    override public function IsSolid(block:Block):Bool
    {
        return true;
    }

    override public function TextureBottomUV(block:Block):Vector2
    {
		return new Vector2(0.75, 0.25);
    }
	
    override public function TextureTopUV(block:Block):Vector2
    {
		return new Vector2(0.75, 0.75);
    }

    override public function TextureSideUV(block:Block):Vector2
    {
		return new Vector2(0.75, 0.0);
    }
	
    override public function TextureUV(block:Block):Vector2
    {
		return new Vector2(0.75, 0.50);
    }
}
//#endregion

//#region Non-solidBlocks
@:expose('BABYLONVX.AirType') class AirType extends BlockBase
{
    override public function IsSolid(block:Block):Bool
    {
        return false;
    }
}
 
@:expose('BABYLONVX.HeightType') class HeightType extends BlockBase
{
    override public function IsSolid(block:Block):Bool
    {
        return false;
    }
}

@:expose('BABYLONVX.WorldBoundType') class WorldBoundType extends BlockBase
{
    override public function IsSolid(block:Block):Bool
    {
        return false;
    }
}

@:expose('BABYLONVX.UnknownType') class UnknownType extends BlockBase
{
    override public function IsSolid(block:Block):Bool
    {
        return false;
    }
}
//#endregion
 