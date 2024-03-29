﻿////////////////////////////////////////////
// Project: Flash 10 Coverflow
// Date: 10/3/09
// Author: Stephen Weber
////////////////////////////////////////////
package {
	
	////////////////////////////////////////////
	// IMPORTS
	////////////////////////////////////////////
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.display.Bitmap;

	//TweenLite - Tweening Engine - SOURCE: http://blog.greensock.com/tweenliteas3/
	import com.greensock.*;
	import com.greensock.easing.*;

	public class CoverflowItem extends Sprite {

		////////////////////////////////////////////
		// VARIABLES
		////////////////////////////////////////////

		
		private var _data:Object = new Object();

		private var _loader:Loader = new Loader();

		private var _padding:uint;
		
		private var _holder:MovieClip = new MovieClip();
		
		//Reflection Properties
		private var _alpha:Number = 35;
		
		private var _ratio:Number = 50;
		
		private var _distance:Number = 0;
		
		private var _updateTime:Number = -1;
		
		private var _reflectionDropoff:Number = 1;
		
		////////////////////////////////////////////
		// CONSTRUCTOR - INITIAL ACTIONS
		////////////////////////////////////////////
		public function CoverflowItem(__data:Object):void {
			_data=__data;
			addChild(_holder)
			_holder.buttonMode=true;
			_holder.addEventListener(MouseEvent.CLICK, click);
			//var sha:Shadow = new Shadow();
			//sha.x = this.x + sha.width/2;
			//sha.y = this.y + 200;
			//sha.scaleX = this.width/ sha.width;
			//addChild(sha);
			//this._bg.alpha = 2;
			
			
		}
		////////////////////////////////////////////
		// GETTERS/SETTERS
		////////////////////////////////////////////
		public function set image(_input:String):void {

			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imageIOError);
			_loader.load(new URLRequest(_input));

		}
		public function set padding(_input:uint):void {
			_padding=_input;
			_loader.x=_loader.y=_input;
		}
		public function set imageWidth(_input:Number):void {
			this._bg.width=_input+_padding*2;
		}
		public function set imageHeight(_input:Number):void {
			this._bg.height=_input+_padding*2;
		}
		////////////////////////////////////////////
		// FUNCTIONS
		////////////////////////////////////////////
		public function setReflection(__alpha:Number, __ratio:Number, __distance:Number, __updateTime:Number, __reflectionDropoff:Number) {
			_alpha = __alpha;
			_ratio = __ratio;
			_distance = __distance;
			_updateTime = __updateTime;
			_reflectionDropoff = __reflectionDropoff;
		}
		private function imageComplete(e:Event):void {
			
			if(_loader.width != 550){
				_loader.width = 550;
			}
			if(_loader.height != 270){
				_loader.height = 270;
			}
			this.loading.alpha= 0;
			_holder.addChild(_loader);
			var reflection:Reflect=new Reflect({target:this,alpha:_alpha,ratio:_ratio,distance:_distance,updateTime:_updateTime,reflectionDropoff:_reflectionDropoff});
		}
		private function imageIOError(e:IOErrorEvent):void {
			trace("CoverflowItem - Error Loading");
		}
		private function click(e:MouseEvent):void {

			dispatchEvent(new CoverflowItemEvent(CoverflowItemEvent.COVERFLOWITEM_SELECTED, _data));

		}
	}
}