package com.babylonvx;
import com.babylonvx.Block;
import com.babylonhx.math.Vector3;
import com.babylonhx.Scene;
import com.babylonvx.utility.SimplexNoise3D;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
/// <summary>
/// This class is used to forward some cfg to other classes and create the world.
/// There is many things that I would did different now, but as a prototype I think that it's ok.
/// </summary>



@:expose('BABYLONVX.WorldController') class WorldController  
{
	public var _chunkPrefab:ChunkObject;
	public var _chunkMesh:Dynamic;
	//public Transform _worldTransform;
	//public CharacterSkills _character;
	//public CharacterSkills _characterMobile;
	//public GUIText _console;
	
	// Light Cfg
	public var _lightAttenuation:Bool = true;
	public var _smoothLight:Bool = true;
	public var cTex:String;
	public var seed:String = 'Legolas';
	public var _scene:Scene;

	public var _world:World;
	private var _simplexNoise3D:SimplexNoise3D;


	//IEnumerator Start () 
	public function new (scene:Scene) 
	{	
		_scene = scene;
		_world = new World(_scene);
		
		//ChunkRenderer.SmoothLight = _smoothLight;
		//World.LightAttenuation = _lightAttenuation;
		trace('todo');
		//ChunkRenderer.WorldHeight = new Array(_world.WorldVisibleSizeX, _world.WorldVisibleSizeZ);
		
		_simplexNoise3D = new SimplexNoise3D(seed);
		CreateWorld();
		/*
		if (Application.platform == RuntimePlatform.Android || Application.platform == RuntimePlatform.IPhonePlayer)
		{
			_characterMobile.Init(_world);
		}
		else
		{
			_character.Init(_world);
		}
		
		
		// The following code avoid the player fall before the world creation finish
		// Note: Yeah, I know... I'm a lazy bastard. 
		// Since this project is not focused on the character control I don't mind to do some ugly stuff like this
		StartCoroutine( "FreezePlayer" );
			
		yield return StartCoroutine( CreateWorld() );
		
		StopCoroutine( "FreezePlayer" );
		*/
		
	}
	
	//private IEnumerator FreezePlayer()
	private function FreezePlayer()
	{
		var pos:Vector3 = Vector3.Zero();
		{
			//pos = _character.transform.position;
			
			while (true)
			{
				//_character.transform.position = pos;
			}
		}	
		
	}
	
	// This method first create all world data using the Simplex3D Noise, and then start to build the chunks meshes.
	// Note: if you wanna to create a infinite world on the fly, you will need to do booth steps together. Something like:
	// 		 1. create the data for one chunk
	// 		 2. build its mesh
	// 		 3. iterate until all visible chunks are created
	public function CreateWorld()
	{
		var total:Int = 0;
		var count:Int = 0;

		//#region CreatingWorldData
		cTex = "Creating World Data: 0%";

		total = Math.round(_world.get__worldVisibleSizeX() * _world.get__worldVisibleSizeY() * _world.get__worldVisibleSizeZ());
		count = 0;
		
		var heightMult:Float = 50.0;
		var heightOffSet:Float = 10.0;
		
		// The following value is used to create some dirt blocks on the floor to add more randomness to the world. 
		// The random seed is based on the first character of the worldSeed used in the simplex 3D.
		//UnityEngine.Random.seed = System.Convert.ToInt32(WorldConfig.WorldSeed[0]);
		var dirtRandomHeight:Int = SimplexNoise3D.randomInt(5, 7);
		
		
		for ( x in 0..._world.get__worldVisibleSizeX() ) 
		{
			for ( y in 0..._world.get__worldVisibleSizeY() ) 
			{
				// I'm using the default values of the simplexNoise3D. 
				// For better results you will have to tune some of those parameters:
				// octaves, multiplier, amplitude, lacunarity, persistence
				// There is a good article about it at: 
				// http://www.gamedev.net/blog/33/entry-2227887-more-on-minecraft-type-world-gen/
				var height:Int =  Math.round(_simplexNoise3D.CoherentNoise( x, 0, y, 1, 50 ) * heightMult + heightOffSet);
				height = Math.round(Math.min(_world.get__worldVisibleSizeY()-1, height));
				//ChunkRenderer.WorldHeight[x,z] = height;

				for ( z in 0..._world.get__worldVisibleSizeZ() ) 
				{
					CreateCollum(x,y,z, height, dirtRandomHeight);				
					count++;
				}
			}
			LogProgress("Creating World Data: ", count, total);
			//if (_asyncWorldCreation) yield return null;
		}
		//#endregion
		
		//#region CreatingWorldMesh
		cTex = "Creating World Mesh: 0%";

		total = Math.round(_world.get__visibleX() * _world.get__visibleY() * _world.get__visibleZ());
		count = 0;

		for ( x in 0..._world.get__visibleX() )
		{
			for ( y in 0..._world.get__visibleY() )
			{
				for ( z in 0..._world.get__visibleZ() )
				{
					CreateWorldMesh(x,y,z);
					count++;
					LogProgress("Creating World Mesh: ", count, total);
				}
			}
		}
		cTex = '';
		//#endregion
	}
	
	// Define the block type basedDefine the block type based on its height
	// Note: there is many other ways to do that. This is the simplest way, but the result is very primitive...int y, int z, int height, int dirtRandomHeight)
	private function CreateCollum(x:Int, y:Int, z:Int, height:Int, dirtRandomHeight:Int)
	{
		// Base
		if (y <= 0)
		{
			//_world[x,y,z] = new Block(BlockType.Lava, x,y,z);
			_world.Block().set(x,y,z, _world, new Block(_world, Block.BlockType.Lava, x,y,z));
		}
		// Cave floor
		else if (y == 1)
		{
			_world.Block().set(x,y,z, _world, new Block(_world, Block.BlockType.Stone, x,y,z));
		}
		// Highest block of the column
		else if (y == height)
		{
			_world.Block().set(x,y,z, _world, new Block(_world, Block.BlockType.Height, x,y,z));
		}
		// Highest solid block of the column
		else if (y == (height-1) )
		{
			if (y < dirtRandomHeight )
				_world.Block().set(x,y,z, _world, new Block(_world, Block.BlockType.Dirt, x,y,z));
			else
				_world.Block().set(x,y,z, _world, new Block(_world, Block.BlockType.Grass, x,y,z));

		}
		// Dirt range
		else if (y <= (height-2) && y > (height-4) )
		{
			_world.Block().set(x,y,z, _world,  new Block( _world, Block.BlockType.Dirt, x,y,z));
		}
		// Caves
		else if (y <= (height-4))
		{
			var density:Float = _simplexNoise3D.GetDensity( new Vector3(x, y, z) );
		
			if (density > 0)
				_world.Block().set(x,y,z,_world, new Block(_world, Block.BlockType.Stone, x,y,z));
			else
				_world.Block().set(x,y,z, _world, new Block(_world, Block.BlockType.Air, x,y,z));
		}
		// Everything else
		else
		{
			_world.Block().set(x,y,z, _world, new Block(_world, Block.BlockType.Air, x,y,z));
			//_world[x,y,z].Light = Block.MaxLight;
		}		
	}
	
	private function CreateWorldMesh(x:Int, y:Int, z:Int)
	{	
		/*var _chunkMesh = this._world.Block().get(x,y,z, _world);
		_chunkMesh._mesh.scaling = new Vector3(Chunk.SizeX, Chunk.SizeY, Chunk.SizeZ);
		_chunkMesh._mesh.position = new Vector3(x*Chunk.SizeX, y*Chunk.SizeY, z*Chunk.SizeZ);
		var block = Block.BlockTypes.GetBlockType(_chunkMesh._type[1]);
		if(block.materialImg != null){
			var _material = new StandardMaterial("materail", this._scene);
			_material.diffuseTexture = new Texture(block.materialImg, this._scene);
			_chunkMesh._mesh._material = _material;
		}*/
		

	}
	
	public function LogProgress(msg:String, current:Int, total:Int)
	{
		var progress = ((current/total)*100);
		trace(msg+progress+"%");
	}

}
