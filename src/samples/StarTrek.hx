package samples;

import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lensflare.LensFlare;
import com.babylonhx.lensflare.LensFlareSystem;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.FresnelParameters;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.Scene;
import com.babylonhx.tools.EventState;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.materials.textures.procedurals.standard.StarfieldProceduralTexture;
/**
 * ...
 * @author Brendon Smith
 */

class StarTrek {
	var scene:Scene;

	public function new(scene:Scene) {
		this.scene = scene;
		var camera = new FreeCamera("Camera", new Vector3(0, 4, -20), scene);
		camera.attachControl(this, false);
		SceneLoader.ImportMesh("", "assets/models/", "enterprise.babylon", scene, this.onSuccess);


	var hemisphericLight = new HemisphericLight("hemi", new Vector3(0, 0.5, 0), scene);

	var spaceScale = 10.0;
	var space = Mesh.CreateCylinder("space", 20 * spaceScale, 0, 10 * spaceScale, 20, 20, scene);
	space.rotation.x = 1.5;
	var starfieldPT = untyped new StarfieldProceduralTexture("starfieldPT", 512, scene);
	var starfieldMaterial = new StandardMaterial("starfield", scene);
	starfieldMaterial.diffuseTexture = starfieldPT;
	starfieldMaterial.diffuseTexture.coordinatesMode = Texture.SKYBOX_MODE;
	starfieldMaterial.backFaceCulling = false;
	untyped starfieldPT.set_beta(0.1);

	space.material = starfieldMaterial;

		scene.registerBeforeRender(function(scene:Scene, es:Null<EventState>){
	    	untyped starfieldPT.set_time(starfieldPT.get_time() + scene.getAnimationRatio() * 0.8);
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});


		
	}

	public function onSuccess  (newScene:Array<AbstractMesh>, ps:Array<ParticleSystem>, sk:Array<Skeleton>):Void {
		   var _spaceShip = newScene;
		   _spaceShip[1].position.z = -9.8;
		   _spaceShip[1].position.y = 2.8;
		   _spaceShip[0].position.z = -9.8;
		   _spaceShip[0].position.y = 2.8;
		   _spaceShip[1].scaling.z = 5;
		   _spaceShip[0].scaling.z = 5;
		   this.generateParticleSystem(newScene[0]);
		   this.generateParticleSystem(newScene[1]);
	}

	public function generateParticleSystem(emitter:Dynamic){
	     // Create a particle system
	    var particleSystem = new ParticleSystem("particles", 500, this.scene);

	    //Texture of each particle
	    particleSystem.particleTexture = new Texture("assets/models/Part.jpg", this.scene);

	    // Where the particles come from
	    particleSystem.emitter = emitter; // the starting object, the emitter
	    particleSystem.minEmitBox = new Vector3(-1, 0, 0); // Starting all from
	    particleSystem.maxEmitBox = new Vector3(1, 0, 0); // To...

	    // Colors of all particles
	    particleSystem.color1 = new Color4(0.819607854, 0.239215687, 1, 1.0);
	    particleSystem.color2 = new Color4(0.819607854, 0.239215687, 1, 1.0);
	    particleSystem.colorDead = new Color4(0, 0, 0, 0.0);

	    // Size of each particle (random between...
	    particleSystem.minSize = 0.1;
	    particleSystem.maxSize = 1.5;

	    // Life time of each particle (random between...
	    particleSystem.minLifeTime = 0.0;
	    particleSystem.maxLifeTime = 0.55;

	    // Emission rate
	    particleSystem.emitRate = 4500;

	    // Blend mode : BLENDMODE_ONEONE, or BLENDMODE_STANDARD
	    particleSystem.blendMode = ParticleSystem.BLENDMODE_ONEONE;

	    // Set the gravity of all particles
	    particleSystem.gravity = new Vector3(0, -9.81, 0);

	    // Direction of each particle after it has been emitted
	    particleSystem.direction1 = new Vector3(-7, 8, 3);
	    particleSystem.direction2 = new Vector3(7, 8, -3);

	    // Angular speed, in radians
	    particleSystem.minAngularSpeed = 0;
	    particleSystem.maxAngularSpeed = Math.PI;

	    // Speed
	    particleSystem.minEmitPower = 1;
	    particleSystem.maxEmitPower = 3;
	    particleSystem.updateSpeed = 0.005;

	    // Start the particle system
	    particleSystem.start();
	} 
	
}
	