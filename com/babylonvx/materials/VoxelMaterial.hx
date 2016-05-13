package com.babylonvx.materials;

import com.babylonhx.materials.ShaderMaterial;
import com.babylonhx.Engine;
import com.babylonhx.Scene;
import com.babylonhx.materials.textures.Texture;
import com.babylonvx.VoxelMesh;
/**
 * ...
 * @author Brendon Smith
 */




@:expose('BABYLON.VoxelMaterial') class VoxelMaterial extends ShaderMaterial {
	public function new(name:String, scene:Scene, shaderPath:Dynamic, chunk:VoxelMesh) {			   
		this._shaderPath = shaderPath;
		super(name, scene, shaderPath, {
 				attributes: ["position", "normal"],
 				uniforms: ["worldViewProjection", "tileSize", "tileCount", "view", "model"],
 				samplers: ["tileMap"]
 		});


 		this.setFloat("tileCount", 16.0);
        this.setFloat("tileSize", 16.0);
        this.setTexture("tileMap", new Texture("assets/img/terrain.png", scene));
        this.setMatrix("model", chunk._worldMatrix);
        this.backFaceCulling = false;
	}

	
}
