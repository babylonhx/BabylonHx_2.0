package com.babylonhx.actions;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.DoNothingAction') class DoNothingAction extends Action {
	
	public function new(triggerOptions:Dynamic, ?condition:Condition) {
		super(triggerOptions, condition);
	}
	
}
