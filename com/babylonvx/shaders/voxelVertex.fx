//vertex
// still rought with bugs :(

attribute vec3 position;
attribute vec4 normal;

uniform mat4 worldViewProjection;
uniform mat4 world;


uniform mat4 view;
uniform mat4 model;
uniform float tileCount;

varying vec3  _normal;
varying vec2  tileCoord;
varying vec2  texCoord;
varying float ambientOcclusion;

void main() {
  //Compute position
  vec3 position = position.xyz;
  
  //Compute ambient occlusion
  //ambientOcclusion = position.w / 255.0;
  //ambientOcclusion =  50.0 / 255.0;


  //Compute normal
  _normal = 1.0 - normal.xyz;
  
  //Compute texture coordinate
  texCoord = vec2(dot(position, vec3((1.0 - _normal.y) - _normal.z , 0, _normal.x  )),
                  dot(position, vec3(0, -abs(_normal.x+_normal.z) , _normal.y)));
  
  //Compute tile coordinate
  float tx    = normal.w / tileCount;
  //float tx    = 14.0/ 16.0;

  tileCoord.x = floor(tx);
  tileCoord.y = fract(tx) * tileCount;
  
  gl_Position = worldViewProjection * view * model * vec4(position, 1.0);
}
