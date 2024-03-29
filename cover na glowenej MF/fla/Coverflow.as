﻿package {
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.navigateToURL;
	import flash.display.Stage;
	import flash.utils.setTimeout;

	//TweenLite - Tweening Engine - SOURCE: http://blog.greensock.com/tweenliteas3/
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;

	public class Coverflow extends Sprite {
		// size of the stage
		private var sw:Number;
		private var sh:Number;
		
		private var background:Background;

		// padding between each cover, can be customed via xml
		private var coverflowSpacing:Number=5;
		
		private var coverflowrotationY:Number = 30;

		// transition time for movement
		private var transitionTime:Number=0.75;

		// the center of the stage
		private var centerX:Number;
		private var centerY:Number;

		// store each image cover's instance
		private var coverArray:Array=new Array();

		// title of each image
		//private var coverLabel:CoverflowTitle = new CoverflowTitle();

		// the slider under the image cover
		private var coverSlider:Scrollbar;
		
		// how many image covers
		private var coverflowItemsTotal:Number;

		// how to open the link
		private var _target:String;

		// size of the image cover
		private var coverflowImageWidth:Number;
		
		private var coverflowImageHeight:Number;

		//Holds the objects in the data array
		private var _data:Array = new Array();
		
		// the y position of the item's title
		private var coverLabelPositionY:Number;
		
		//Z Position of Current CoverflowItem
		private var centerCoverflowZPosition:Number=-15;

		// display the middle of the cover or not
		private var startIndexInCenter:Boolean=true;

		// which cover to display in the beginning
		private var startIndex:Number=0;

		// the slide's Y position
		private var coverSlidePositionY:Number;

		//Holder for current CoverflowItem
		private var _currentCover:Number;
		
		//CoverflowItem Container
		private var coverflowItemContainer:Sprite = new Sprite();

		//XML Loading
		private var coverflowXMLLoader:URLLoader;
		
		//XML
		private var coverflowXML:XML;

		// the image cover's white border padding
		private var padding:Number=4;
		
		// stage reference
		private var _stage:Stage;
		
		//reflection
		private var reflection:Reflect;

		//Reflection Properties
		private var reflectionAlpha:Number;

		private var reflectionRatio:Number;

		private var reflectionDistance:Number;

		private var reflectionUpdateTime:Number;

		private var reflectionDropoff:Number;

		public function Coverflow(_width:Number, _height:Number, __stage:Stage = null):void {
			_stage=__stage;
			sw=_width;
			sh=_height;
			centerX=_width>>1;
			centerX+=70;
			centerY=(_height>>1);
			centerY-=5;
			loadXML();
			
			//Grabs Background color passed in through FlashVars
			var backgColor:String = _stage.loaderInfo.parameters["backgroundColor"];
			
			if(backgColor == null) {
				//Black
				//backgColor = "0x000000";
				
				//White
				backgColor = "0xFFFFFF";
			}
			
			//Creates Background MovieClip
			background = new Background();
			
			//Set Background To Provided Width/Height
			background.width = _width;
			background.height = _height;
			
			//Adds background MovieClip to DisplayList
			//addChild(background);
			
			//Tints Background MovieClip with provided tint
			TweenPlugin.activate([TintPlugin]);
			//TweenLite.to(background, 0, {tint:backgColor});
			
			//Grabs Background color passed in through FlashVars
			//var labelColor:String = _stage.loaderInfo.parameters["labelColor"];
			
			//Check for value and then default
			//if(labelColor == null) {
				//Black
				//labelColor = "0x000000";
				
				//White
				//labelColor = "0xFFFFFF";
			//}
			
			//Tint Coverflow label to color provided
			//TweenLite.to(coverLabel, 0, {tint:labelColor});
			
			if (_stage) {
				_stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			}
		}
	
		private function keyDownHandler(e:KeyboardEvent):void {
			
			
			if (e.keyCode==37||e.keyCode==74) {
				clickPre();
			}
			if (e.keyCode==39||e.keyCode==75) {
				clickNext();
			}
			// 72 stand for "H" key, 191 stand for "?" key
			if (e.keyCode==72||e.keyCode==191) {

			}
		}

		// display the previous image
		private function clickPre(e:Event=null):void {
			_currentCover--;
			if (_currentCover<1) {
				_currentCover=coverflowItemsTotal-1;
			}
			coverSlider.value=_currentCover;
			gotoCoverflowItem(_currentCover);
		}

		// display the next image
		private function clickNext(e:Event=null):void {
			_currentCover++;
			if (_currentCover>coverflowItemsTotal-1) {
				_currentCover=0;
			}
			coverSlider.value=_currentCover;
			gotoCoverflowItem(_currentCover);
		}

		// loading the XML
		private function loadXML():void {
			
			//Loads XML passed through FlashVars
			var xml_source:String = _stage.loaderInfo.parameters["xmlPath"];
			
			//If XML not found through FlashVars then defaults to xml path below
			if(xml_source == null) {
				xml_source = 'xml/data.xml';
			}
			
			// loading the cover xml here
			coverflowXMLLoader = new URLLoader();
			coverflowXMLLoader.load(new URLRequest("xml/data.xml"));
			coverflowXMLLoader.addEventListener(Event.COMPLETE, coverflowXMLLoader_Complete);
			coverflowXMLLoader.addEventListener(IOErrorEvent.IO_ERROR, coverflowXMLLoader_IOError);

		}

		// parse the XML
		private function coverflowXMLLoader_Complete(e:Event):void {
	
			coverflowXML=new XML(e.target.data);
			coverflowItemsTotal=coverflowXML.cover.length();
			coverflowSpacing=36;
			coverflowImageWidth=550;
			coverflowImageHeight=270;
			coverLabelPositionY=40;
			coverSlidePositionY=27;;
			transitionTime=0.5;
			centerCoverflowZPosition=-125;

			//Image Border
			padding = 1;
			
			//Reflection Attributes
			reflectionAlpha=100;
			reflectionRatio=50;
			reflectionDistance=0;
			reflectionUpdateTime=-1;
			reflectionDropoff=0.75;

			startIndex=coverflowItemsTotal;
			startIndexInCenter = true;
			_target="_blank";
			
			for (var i=0; i<coverflowItemsTotal; i++) {
				
				//Make An Object To Hold Values
				var _obj:Object = new Object();
				
				//Set Values To Object from XML for each CoverflowItem
				_obj.image = (coverflowXML.cover[i].@img.toString());
				//_obj.title = (coverflowXML.cover[i].@title.toString());
				//_obj.link = (coverflowXML.cover[i].@link.toString());
				_data[i] = _obj;
				
			}
			loadCover();
		}

		private function coverflowXMLLoader_IOError(event:IOErrorEvent):void {
			trace("Coverflow XML Load Error: "+ event);
		}

		// load the image cover when xml is loaded
		private function loadCover():void {

			for (var i:int = 0; i < coverflowItemsTotal; i++) {
				var cover:Sprite=createCover(i,_data[i].image);
				coverArray[i]=cover;
				cover.y=centerY;
				cover.z=0;
				coverflowItemContainer.addChild(cover);
			}

			if (startIndexInCenter) {
				startIndex=coverArray.length>>1;
				gotoCoverflowItem(startIndex);

			} else {

				gotoCoverflowItem(startIndex);

			}
			_currentCover=startIndex;
			coverSlider=new Scrollbar(coverflowItemsTotal,_stage);
			coverSlider.value=startIndex;
			coverSlider.x = (_stage.stageWidth/2) - (coverSlider.width/2);
			coverSlider.y=_stage.stageHeight-0;
			coverSlider.addEventListener("UPDATE", coverSlider_Update);
			coverSlider.addEventListener("PREVIOUS", coverSlider_Previous);
			coverSlider.addEventListener("NEXT", coverSlider_Next);
			//addChild(coverSlider);

			//coverLabel.x = (sw - coverLabel.width)>>1;
			//coverLabel.x = (_stage.stageWidth/2) - (coverLabel.width/2);
			//coverLabel.y=coverLabelPositionY;
			//addChild(coverLabel);

			//addChild(coverSlider);
			//addChild(coverLabel);

		}

		private function coverSlider_Update(e:Event):void {
			var value:Number=(coverSlider.value);
			gotoCoverflowItem(value);
			e.stopPropagation();
		}

		private function coverSlider_Previous(e:Event):void {
			clickPre();
		}

		private function coverSlider_Next(e:Event):void {
			clickNext();
		}

		// move to a certain cover via number
		private function gotoCoverflowItem(n:int):void {
			if(n==0)
				n = coverflowItemsTotal-1;
			_currentCover=n;
			reOrderCover(n);
			if (coverSlider) {
				coverSlider.value=n;
			}
		}

		private function cover_Selected(event:CoverflowItemEvent):void {

			var currentCover:uint=event.data.id;

			if (coverArray[currentCover].rotationY==0) {
				try {
					// open the link if user click the cover in the middle again
					if (_data[currentCover].link!="") {
						//navigateToURL(new URLRequest(_data[currentCover].link), _target);
					}

				} catch (e:Error) {
					//
				}

			} else {
				gotoCoverflowItem(currentCover);

			}

		}

		// change each cover's position and rotation
		private function reOrderCover(currentCover:uint):void {
			for (var i:uint = 0, len:uint = coverArray.length; i < len; i++) {
				var cover:Sprite=coverArray[i];
				var distans:int = Math.abs(currentCover - i);
				
				//trace(cover.width);
				var tmpAlpha:Number = 1;
				if(distans > 2){
						tmpAlpha = 0;
						}else{
						tmpAlpha = 1- distans/5;
						}
				var sizeAll:Number= 0.4;
				
				if (i<currentCover) {
					//Left Side
					//trace((centerX - (currentCover - i) * coverflowSpacing - coverflowImageWidth)-40);
					TweenLite.to(cover, transitionTime, {scaleX:0.3,scaleY:0.3,alpha:tmpAlpha,x:(centerX+(i - currentCover)*60), z:(centerCoverflowZPosition), rotationY:-coverflowrotationY});
				} else if (i > currentCover) {
					//Right Side
					tmpAlpha = 0;
					TweenLite.to(cover, transitionTime, {scaleX:sizeAll-distans/8,scaleY:sizeAll-distans/8,alpha:tmpAlpha,x:(centerX + (i - currentCover) * coverflowSpacing + coverflowImageWidth/2), z:centerCoverflowZPosition, rotationY:coverflowrotationY});
					
				} else {
					//Center Coverflow
					trace(cover.name);
					
					TweenLite.to(cover, transitionTime, {scaleX:0.4,scaleY:0.3,alpha:1,x:centerX, z:centerCoverflowZPosition, rotationY:-coverflowrotationY});
					//trace(cover.name);
					import flash.external.ExternalInterface; //for AS2
		//			flash.system.Security.allowDomain("http://student.agh.edu.pl/");
 
//1. calling javascript function from Flash.
ExternalInterface.call("change_image_action",cover.name);
// argument 1: javascript function, argument 2: data/variables to pass out.
 

					//Label Handling
					//coverLabel._text.text=_data[i].title;
					//coverLabel.alpha=0;
					//TweenLite.to(coverLabel, 0.75, {alpha:1,delay:0.2});

				}
			}
			for (i = 0; i < currentCover; i++) {
				addChild(coverArray[i]);
			}
			for (i = coverArray.length - 1; i > currentCover; i--) {
				addChild(coverArray[i]);
			}

			addChild(coverArray[currentCover]);
			if (coverSlider) {
				//addChild(coverSlider);
				//addChild(coverLabel);
			}
		}

		//Create CoverflowItem and Set Data To It
		private function createCover(num:uint, url:String):Sprite {

			//Setup Data
			var _data:Object = new Object();
			_data.id=num;

			//Create CoverflowItem
			var cover:CoverflowItem=new CoverflowItem(_data);

			//Listen for Click
			cover.addEventListener(CoverflowItemEvent.COVERFLOWITEM_SELECTED, cover_Selected);

			//Set Some Values
			cover.name=num.toString();
			cover.image=url;
			cover.padding=padding;
			
			cover.imageWidth=coverflowImageWidth;
			cover.imageHeight=coverflowImageHeight;
			cover.setReflection(reflectionAlpha, reflectionRatio, reflectionDistance, reflectionUpdateTime, reflectionDropoff);

			//Put CoverflowItem in Sprite Container
			var coverItem:Sprite = new Sprite();
			cover.x=- coverflowImageWidth/2-padding;
			cover.y=- coverflowImageHeight/2-padding;
			coverItem.addChild(cover);
			coverItem.name=url;

			return coverItem;
		}

	}
}
/*
private function coverflowXMLLoader_Complete(e:Event):void {
			coverflowXML=new XML(e.target.data);
			coverflowItemsTotal=coverflowXML.cover.length();
			coverflowSpacing=Number(coverflowXML.@coverflowSpacing);
			coverflowImageWidth=Number(coverflowXML.@imageWidth);
			coverflowImageHeight=Number(coverflowXML.@imageHeight);
			coverLabelPositionY=Number(coverflowXML.@coverLabelPositionY);
			coverSlidePositionY=Number(coverflowXML.@coverSlidePositionY);
			transitionTime=Number(coverflowXML.@transitionTime);
			centerCoverflowZPosition=Number(coverflowXML.@centerCoverflowZPosition);

			//Image Border
			padding = Number(coverflowXML.@imagePadding)
			
			//Reflection Attributes
			reflectionAlpha=Number(coverflowXML.@reflectionAlpha);
			reflectionRatio=Number(coverflowXML.@reflectionRatio);
			reflectionDistance=Number(coverflowXML.@reflectionDistance);
			reflectionUpdateTime=Number(coverflowXML.@reflectionUpdateTime);
			reflectionDropoff=Number(coverflowXML.@reflectionDropoff);

			startIndex=Number(coverflowXML.@startIndex);
			startIndexInCenter = (coverflowXML.@startIndexInCenter.toLowerCase().toString()=="yes");
			_target=coverflowXML.@target.toString();
			
			for (var i=0; i<coverflowItemsTotal; i++) {
				
				//Make An Object To Hold Values
				var _obj:Object = new Object();
				
				//Set Values To Object from XML for each CoverflowItem
				_obj.image = (coverflowXML.cover[i].@img.toString());
				_obj.title = (coverflowXML.cover[i].@title.toString());
				_obj.link = (coverflowXML.cover[i].@link.toString());
				_data[i] = _obj;
				
			}
			loadCover();
		}
*/
