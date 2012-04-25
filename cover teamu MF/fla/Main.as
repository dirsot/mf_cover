package {
	import flash.display.*;
	import flash.events.*;

	public class Main extends Sprite {
		private var coverflow:Coverflow;
		public function Main() {
			setupStage();
			stage.addEventListener(Event.RESIZE, resizeHandler);
			resizeMe();
			init();
		}
		
		public function setupStage():void {
			stage.quality = StageQuality.HIGH;
			//stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
		}
		
		private function resizeHandler(event:Event):void {
			resizeMe();
		}
		private function resizeMe():void {
		}
		private function init():void {	
			coverflow = new Coverflow(stage.stageWidth, stage.stageHeight, stage);
			addChild(coverflow);
		}
	}
}