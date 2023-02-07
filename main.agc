
// Project: Polygon Triangulation 
// Created: 20-11-29

#include "core.agc"
#include "contour tracing.agc"
#include "douglas peucker.agc"
#include "triangulation.agc"

// show all errors
SetErrorMode(2)

// set window properties
SetWindowTitle( "Polygon Triangulation" )
SetWindowSize( 1024, 768, 0 )
SetWindowAllowResize( 1 ) // allow the user to resize the window

// set display properties
SetVirtualResolution( 100, 100 ) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
SetSyncRate( 30, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 ) // use the maximum available screen space, no black borders
UseNewDefaultFonts( 1 )
SetDefaultMinFilter(0)
SetDefaultMagFilter(0)
SetViewZoomMode(1)

#Constant KEY_1 49
#Constant KEY_2 50
#Constant KEY_3 51
#Constant KEY_4 52

type WidgedData
	SpriteID as integer
	PointID as integer
	TextID as integer
endtype

global WidgedImageID
WidgedImageID=CreateImageColor(0,255,0,64)

WidgedList as WidgedData[]

Outline as Core_Int2Data[]
PointList as Core_Int2Data[]
IndexList as integer[]

ImageID=LoadImage("penguin.png")
SpriteID=CreateSprite(ImageID)
SetSpriteCategoryBit(SpriteID,1,0)
SetVirtualResolution(GetImageWidth(ImageID),GetImageHeight(ImageID))

//[IDEGUIADD],header,Polygon Triangulation Tool
global File$ = "penguin.png" //[IDEGUIADD],selectfile,Image File Selection
//~global File$ = "penguin.png" //[IDEGUIADD],selectfile,Image File Selection
//[IDEGUIADD],message,Select an image file to work on:
//[IDEGUIADD],separator,
global AlphaThreshold = 128 //[IDEGUIADD],integer,Alpha
//~global AlphaThreshold = 128 //[IDEGUIADD],integer,Alpha
//[IDEGUIADD],message,The alpha value is used to control the minimum level of transparency for which a pixel is considered to be part of a contour.
//[IDEGUIADD],message,This threshold determines the level of detail in the traced contour and helps to remove noise or unwanted features.
//[IDEGUIADD],separator,
global EpsilonThreshold# = 1.000000 //[IDEGUIADD],float,Epsilon
//~global EpsilonThreshold## = 1.0 //[IDEGUIADD],float,Epsilon
//[IDEGUIADD],message,This threshold value that determines the maximum permissible deviation from the original curve
//[IDEGUIADD],message,The smaller the value of epsilon, the more aggressive the simplification process and the fewer points that remain on the simplified curve.


ViewZoom#=1.0
do
	print("Press 1, 2, 3 for the different Algorithm steps and Press 4 to remove it all again")
	print("Outline: "+str(Outline.length))
	print("Points: "+str(PointList.length))
	print("Indices: "+str(IndexList.length))
	print("Alpha: "+str(AlphaThreshold))
	print("Epsilon: "+str(EpsilonThreshold#,2))
    PointerX#=GetPointerX()
    PointerY#=GetPointerY()
    WorldPointerX#=ScreenToWorldX(PointerX#)
    WorldPointerY#=ScreenToWorldY(PointerY#)
    
    if GetFileExists(File$)
    	DeleteImage(ImageID)
	    ImageID=LoadImage(File$)
	    if GetImageExists(ImageID)
			SetSpriteImage(SpriteID,ImageID)
			SetVirtualResolution(GetImageWidth(ImageID),GetImageHeight(ImageID))
		endif
		 File$=""
	endif
    
	if GetRawKeyPressed(KEY_1) then CT_CreateOutline(ImageID, Outline, AlphaThreshold)
	if GetRawKeyPressed(KEY_2)
		DP_CreatePolyline(Outline, PointList, EpsilonThreshold#)
		CreatePointWidgeds(PointList, WidgedList)
	endif
	if GetRawKeyPressed(KEY_3) then PT_Triangulate(PointList, IndexList)
	if GetRawKeyPressed(KEY_4)
		CT_DeleteOutline(Outline)
		DP_DeletePolyline(PointList)
		PT_DeleteTriangles(IndexList)
		
		DeleteWidgets(WidgedList)
	endif
	
	HitSpriteID=GetSpriteHitCategory(1,WorldPointerX#,WorldPointerY#)
    if GetPointerPressed()=1 then WidgedSpriteID=HitSpriteID
    if GetPointerState()=1 then MovePoint(PointList, WidgedList, WidgedSpriteID, WorldPointerX#, WorldPointerY#)
    if GetPointerReleased()=1 then WidgedSpriteID=-1
    
	if GetSpriteExists(WidgedSpriteID)=0
		ViewZoom#=Core_Clamp(ViewZoom#+GetRawMouseWheelDelta()/30.0,0.1,10)
		print(ViewZoom#)
		SetViewZoom(ViewZoom#)
		if GetPointerPressed()=1
			DragX#=PointerX#+ViewX#
			DragY#=PointerY#+ViewY#
		endif
		if GetPointerState()=1
			ViewX#=DragX#-PointerX#
			ViewY#=DragY#-PointerY#
			SetViewOffset(ViewX#,ViewY#)
		endif
   	endif
	
	CT_DrawOutline(Outline,255,0,0)
	DP_DrawLines(PointList,0,255,0)
	PT_DrawTriangles(PointList,IndexList,0,0,255)
	
    Sync()
loop

function CreatePointWidgeds(PointList ref as Core_Int2Data[], WidgedList ref as WidgedData[])	
	DeleteWidgets(WidgedList)
	
	TempWidged as WidgedData
	for ID=0 to PointList.length
		TempWidged.SpriteID=CreateSprite(WidgedImageID)
		TempWidged.PointID=ID
		SetSpriteScale(TempWidged.SpriteID,4,4)
		SetSpritePositionByOffset(TempWidged.SpriteID,PointList[ID].X,PointList[ID].Y)
		SetSpriteCategoryBit(TempWidged.SpriteID,1,1)
		TempWidged.TextID=CreateText(str(ID))
		SetTextPosition(TempWidged.TextID,GetSpriteXByOffset(TempWidged.SpriteID),GetSpriteYByOffset(TempWidged.SpriteID)-GetSpriteHeight(TempWidged.SpriteID)*0.5)
		SetTextAlignment(TempWidged.TextID,1)
		SetTextColor(TempWidged.TextID,255,255,255,255)
		WidgedList.insertsorted(TempWidged)
	next ID
endfunction

function DeleteWidgets(WidgedList ref as WidgedData[])
	for WidgetID=0 to WidgedList.length
		if GetSpriteExists(WidgedList[WidgetID].SpriteID)=1 then DeleteSprite(WidgedList[WidgetID].SpriteID)
		if GetTextExists(WidgedList[WidgetID].TextID)=1 then DeleteText(WidgedList[WidgetID].TextID)
	next WidgetID
	WidgedList.length=-1
endfunction

function MovePoint(PointList ref as Core_Int2Data[], WidgedList ref as WidgedData[], SpriteID, PosX#, PosY#)
	if GetSpriteExists(SpriteID)=1
		WidgetID=WidgedList.find(SpriteID)
		if WidgetID>0 and WidgetID<WidgedList.length
			PointID=WidgedList[WidgetID].PointID
			PointList[PointID].X=PosX#
			PointList[PointID].Y=PosY#
			SetSpritePositionByOffset(SpriteID,PosX#,PosY#)
			TextHeight#=GetSpriteHeight(SpriteID)*0.5
			SetTextPosition(WidgedList[WidgetID].TextID,PosX#,PosY#-TextHeight#)
		endif
	endif
endfunction