package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

#if ((js || purejs || web || html5) && !emscripten) 

	typedef Float32Array = js.html.Float32Array;

#elseif snow

	typedef Float32Array = snow.api.buffers.Float32Array;
	
#elseif openfl

	typedef Float32Array = openfl.utils.Float32Array;	
	
#elseif (lime || emscripten)

	typedef Float32Array = lime.utils.Float32Array;
	
#elseif nme

	typedef Float32Array = nme.utils.Float32Array;

#elseif kha



#end
