
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
MaximizeWindow()

SetDefaultMinFilter(0)
SetDefaultMagFilter(0)

#Constant KEY_1 49
#Constant KEY_2 50
#Constant KEY_3 51
#Constant KEY_4 52

Outline as Core_Int2Data[]
PointList as Core_Int2Data[]
IndexList as integer[]

ImageID=LoadImage("penguin.png")
SpriteID=CreateSprite(ImageID)
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

do
	print("Press 1, 2, 3 for the different Algorithm steps and Press 4 to remove it all again")
	print("Outline: "+str(Outline.length))
	print("Points: "+str(PointList.length))
	print("Indices: "+str(IndexList.length))
	print("Alpha: "+str(AlphaThreshold))
	print("Epsilon: "+str(EpsilonThreshold#,2))
    PointerX=GetPointerX()
    PointerY=GetPointerY()
    
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
	if GetRawKeyPressed(KEY_2) then DP_CreatePolyline(Outline, PointList, EpsilonThreshold#)
	if GetRawKeyPressed(KEY_3) then PT_Triangulate(PointList, IndexList)
	if GetRawKeyPressed(KEY_4)
		CT_DeleteOutline(Outline)
		DP_DeletePolyline(PointList)
		PT_DeleteTriangles(IndexList)
	endif
	
	CT_DrawOutline(Outline,255,0,0)
	DP_DrawLines(PointList,0,255,0)
	PT_DrawTriangles(PointList,IndexList,0,0,255)
    
    Sync()
loop