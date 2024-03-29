﻿////////////////////////////////////////////
// Project: Flash 10 Coverflow
// Date: 10/3/09
// Author: Stephen Weber
////////////////////////////////////////////
package {
	
	////////////////////////////////////////////
	// IMPORTS
	////////////////////////////////////////////
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;

	public class Reflect extends MovieClip {
		////////////////////////////////////////////
		// VARIABLES
		////////////////////////////////////////////
		
		//reference to the movie clip we are reflecting
		private var _reflectionSprite:Sprite;
		
		//the BitmapData object that will hold a visual copy of the mc
		private var _bitmapData:BitmapData;
		
		//the BitmapData object that will hold the reflected image
		private var _reflectionBitmap:Bitmap;
		
		//the clip that will act as out gradient mask
		private var _gradientMask:MovieClip;
		
		//how often the reflection should update (if it is video or animated)
		private var _updateTime:Number;
		
		//the size the reflection is allowed to reflect within
		private var _bounds:Object;
		
		//the distance the reflection is vertically from the mc
		private var _distance:Number=0;

		function Reflect(args:Object) {
			
			_reflectionSprite=args.target;
			
			//the alpha level of the reflection clip
			var alpha:Number=args.alpha/100;
			
			//the ratio opaque color used in the gradient mask
			var ratio:Number=args.ratio;
			
			//update time interval
			var _updateTime:Number=args._updateTime;
			
			//the distance at which the reflection visually drops off at
			var reflectionDropoff:Number=args.reflectionDropoff;
			
			//the distance the reflection starts from the bottom of the mc
			var _distance:Number=args.distance;

			//store width and height of the clip
			var spriteHeight=_reflectionSprite.height;
			var spriteWidth=_reflectionSprite.width;

			//store the _bounds of the reflection
			_bounds = new Object();
			_bounds.width=spriteWidth;
			_bounds.height=spriteHeight;

			if (_bounds.width>0) {
				//create the BitmapData that will hold a snapshot of the movie clip
				_bitmapData=new BitmapData(_bounds.width,_bounds.height,true,0xFFFFFF);
				_bitmapData.draw(_reflectionSprite);

				//create the BitmapData the will hold the reflection
				_reflectionBitmap=new Bitmap(_bitmapData);
				//flip the reflection upside down
				_reflectionBitmap.scaleY=-1;
				//move the reflection to the bottom of the movie clip
				_reflectionBitmap.y = (_bounds.height*2) + _distance;

				//add the reflection to the movie clip's Display Stack
				var _reflectionBitmapRef:DisplayObject=_reflectionSprite.addChild(_reflectionBitmap);
				
				
				var sha:Shadow = new Shadow();
				sha.scaleX = _bounds.width/sha.width;
			sha.x = 0;
			sha.y = _bounds.height ;
			
			
			//sha.scaleX = this.width/ sha.width;
			//addChild(sha);
				//add the reflection to the movie clip's Display Stack
				var _reflectionBitmapRef2:DisplayObject=_reflectionSprite.addChild(sha);
				
				
				_reflectionBitmapRef.name="_reflectionBitmap";

				//add a blank movie clip to hold our gradient mask
				var gradientMaskRef:DisplayObject = _reflectionSprite.addChild(new MovieClip());
				gradientMaskRef.name="_gradientMask";

				//get a reference to the movie clip - cast the DisplayObject that is returned as a MovieClip
				_gradientMask=_reflectionSprite.getChildByName("_gradientMask") as MovieClip;
				//set the values for the gradient fill
				var fillType:String=GradientType.LINEAR;
				var colors:Array=[0xFFFFFF,0x000000];
				var alphas:Array=[alpha-0.6,0];
				var ratios:Array=[0,ratio];
				var spreadMethod:String=SpreadMethod.PAD;
				//create the Matrix and create the gradient box
				var matr:Matrix = new Matrix();
				//set the height of the Matrix used for the gradient mask
				var matrixHeight:Number;
				if (reflectionDropoff<=0) {
					matrixHeight=_bounds.height;
				} else {
					matrixHeight=_bounds.height/reflectionDropoff;
				}
				matr.createGradientBox(_bounds.width, matrixHeight, (90/180)*Math.PI, 0, 0);
				//create the gradient fill
				_gradientMask.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);
				_gradientMask.graphics.drawRect(0,0,_bounds.width,_bounds.height);
				//position the mask over the reflection clip
				_gradientMask.y=_reflectionSprite.getChildByName("_reflectionBitmap").y-_reflectionSprite.getChildByName("_reflectionBitmap").height;
				//cache clip as a bitmap so that the gradient mask will function
				_gradientMask.cacheAsBitmap=true;
				_reflectionSprite.getChildByName("_reflectionBitmap").cacheAsBitmap=true;
				//set the mask for the reflection as the gradient mask
				_reflectionSprite.getChildByName("_reflectionBitmap").mask=_gradientMask;

				//if we are updating the reflection for a video or animation do so here
				if (_updateTime>-1) {
					_updateTime=setInterval(update,_updateTime,_reflectionSprite);
				}
			}
			
		}


		public function setBounds(w:Number,h:Number):void {
			//allows the user to set the area that the reflection is allowed
			//this is useful for clips that move within themselves
			_bounds.width=w;
			_bounds.height=h;
			_gradientMask.width=_bounds.width;
			redrawBMP(_reflectionSprite);
		}
		public function redrawBMP(_target:Sprite):void {
			// redraws the bitmap reflection - Mim Gamiet [2006]
			_bitmapData.dispose();
			_bitmapData=new BitmapData(_bounds.width,_bounds.height,true,0xFFFFFF);
			_bitmapData.draw(_target);
		}
		private function update(_target:Sprite):void {
			//updates the reflection to visually match the movie clip
			_bitmapData=new BitmapData(_bounds.width,_bounds.height,true,0xFFFFFF);
			_bitmapData.draw(_target);
			_reflectionBitmap.bitmapData=_bitmapData;
		}
		public function destroy():void {
			//provides a method to remove the reflection
			_reflectionSprite.removeChild(_reflectionSprite.getChildByName("_reflectionBitmap"));
			_reflectionBitmap=null;
			_bitmapData.dispose();
			clearInterval(_updateTime);
			_reflectionSprite.removeChild(_reflectionSprite.getChildByName("_gradientMask"));
		}
	}
}