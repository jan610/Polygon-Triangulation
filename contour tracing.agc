// File: contour tracing.agc
// Created: 20-11-30

type GridData
	X as integer
	Y as integer
	Alpha as integer
endtYpe

function CT_CreateOutline(ImageID as Integer, Outline ref as Core_Int2Data[], AlphaThreshold)
	CT_DeleteOutline(Outline)
	CT_FindOutline(ImageID, Outline, AlphaThreshold)
endfunction

function CT_DeleteOutline(Outline ref as Core_Int2Data[])
	Outline.length=-1
endfunction

function CT_DrawOutline(Outline ref as Core_Int2Data[],Red,Green,Blue)
	length=Outline.length
	for PixelID=0 to length-1
		StartX#=WorldToScreenX(Outline[PixelID].X)
		StartY#=WorldToScreenY(Outline[PixelID].Y)
		EndX#=WorldToScreenX(Outline[mod(PixelID+1,length)].X)
		EndY#=WorldToScreenY(Outline[mod(PixelID+1,length)].Y)
		DrawLine(StartX#,StartY#,EndX#,EndY#,Red,Green,Blue)
	next PixelID
endfunction

function CT_FindOutline(ImageID as Integer, Outline ref as Core_Int2Data[],AlphaThreshold)
	local Pixel as Core_Int2Data
	local Grid as GridData[-1,-1]
	
	CT_WriteGridFromMemblockAlpha(ImageID,Grid)
	Pixel=CT_FindTopLeftPixel(Grid,AlphaThreshold)
//~	Pixel=CT_FindTopPixel(Grid,0,0,AlphaThreshold)
	
	CT_FindOutlineFromGrid(Outline,Grid,Pixel.X,Pixel.Y,Pixel.X,Pixel.Y,AlphaThreshold)
endfunction

function CT_FindOutlineFromGrid(Outline ref as Core_Int2Data[],Grid ref as GridData[][],X,Y,EndX,EndY,AlphaThreshold)
	if X>=0 and X<=Grid.length and Y>=0 and Y<=Grid[0].length
		if Grid[X,Y].Alpha>AlphaThreshold
			if IsOutlineCell(Grid,X,Y,AlphaThreshold)
				Grid[X,Y].X=X
				Grid[X,Y].Y=Y
				Grid[X,Y].Alpha=-1
				
				local Pixel as Core_Int2Data
				Pixel.X=X
				Pixel.Y=Y
				Outline.insert(Pixel)
				
				CT_FindOutlineFromGrid(Outline,Grid,X-1,Y,EndX,EndY,AlphaThreshold)
				CT_FindOutlineFromGrid(Outline,Grid,X,Y-1,EndX,EndY,AlphaThreshold)
				CT_FindOutlineFromGrid(Outline,Grid,X+1,Y,EndX,EndY,AlphaThreshold)
				CT_FindOutlineFromGrid(Outline,Grid,X,Y+1,EndX,EndY,AlphaThreshold)
			endif
		endif
	endif
endfunction

//~ ----------------------------
//~ ----<Itteration version>----
//~ ----------------------------
//~ 
//~function CT_FindOutlineFromGrid(Outline ref as Core_Int2Data[],Grid ref as GridData[][],StartX,StartY,AlphaThreshold)
//~	local FrontierTemp as Core_Int2Data
//~	local Frontier as Core_Int2Data[]

//~	FrontierTemp.X=StartX
//~	FrontierTemp.Y=StartY
//~	Frontier.insert(FrontierTemp)
//~	
//~	Grid[StartX,StartY].X=X
//~	Grid[StartX,StartY].Y=Y
//~	Grid[StartX,StartY].Alpha=-1
//~	
//~	Outline.insert(FrontierTemp)
//~	
//~	while Frontier.length>=0
//~		X=Frontier[0].X
//~		Y=Frontier[0].Y
//~		Frontier.remove(0)
//~		
//~		if X>1 and X<Grid.length-1 and Y>1 and Y<Grid[0].length-1
//~			for n=0 to Neighbors.length
//~				nX=X+Neighbors[n].X
//~				nY=Y+Neighbors[n].Y
//~				if Grid[nX,nY].Alpha>AlphaThreshold
//~					if IsOutlineCell(Grid,nX,nY,AlphaThreshold)
//~						FrontierTemp.X=nX
//~						FrontierTemp.Y=nY
//~						Frontier.insert(FrontierTemp)
//~						
//~						Grid[nX,nY].X=X
//~						Grid[nX,nY].Y=Y
//~						Grid[nX,nY].Alpha=-1
//~						
//~						Outline.insert(FrontierTemp)
//~					endif
//~				endif
//~			neXt n
//~		endif
//~	endwhile
//~endfunction

function IsOutlineCell(Grid ref as GridData[][],X,Y,AlphaThreshold)
	local Neighbors as Core_Int2Data[7]
	Neighbors[0].X=-1
	Neighbors[0].Y=0
	Neighbors[1].X=-1
	Neighbors[1].Y=-1
	Neighbors[2].X=0
	Neighbors[2].Y=-1
	Neighbors[3].X=1
	Neighbors[3].Y=-1
	Neighbors[4].X=1
	Neighbors[4].Y=0
	Neighbors[5].X=1
	Neighbors[5].Y=1
	Neighbors[6].X=0
	Neighbors[6].Y=1
	Neighbors[7].X=-1
	Neighbors[7].Y=1
	
	for n=0 to Neighbors.length
		nX=X+Neighbors[n].X
		nY=Y+Neighbors[n].Y
		if nX>=0 and nX<=Grid.length and nY>=0 and nY<=Grid[0].length
			if Grid[nX,nY].Alpha<=AlphaThreshold and Grid[nX,nY].Alpha>-1 then exitfunction 1
		endif
	neXt n
endfunction 0

function CT_WriteGridFromMemblockAlpha(ImageID,Grid ref as GridData[][])
	MemblockID=CreateMemblockFromImage(ImageID)
	Width=GetMemblockInt(MemblockID,0)
	Height=GetMemblockInt(MemblockID,4)
	
	Grid.length=Width
	for X=0 to Grid.length
		Grid[X].length=Height
	neXt X
	
	for Y=0 to Height-1
		for X=0 to Width-1
			Offset=(4*((Y*Width)+X))+12
			Alpha=GetMemblockBYte(MemblockID,Offset+3)
			Grid[X,Y].Alpha=Alpha
		next X
	next Y
	Deletememblock(MemblockID)
endfunction

function CT_FindTopLeftPixel(Grid ref as GridData[][],AlphaThreshold)
	local Pixel as Core_Int2Data

	Pixel.X=Grid.Length
	Pixel.Y=Grid[0].length
	for X=0 to Grid.length
		for Y=0 to Grid[0].length
			if Grid[X,Y].Alpha>AlphaThreshold and X<Pixel.X and Y<Pixel.Y
				Pixel.X=X
				Pixel.Y=Y
			endif
		next Y
	next X
endfunction Pixel

function CT_FindTopPixel(Grid ref as GridData[][],StartX,StartY,AlphaThreshold)
	local Pixel as Core_Int2Data
	
	for Y=StartY to Grid[0].length
		for X=StartX to Grid.length
			if Grid[X,Y].Alpha>AlphaThreshold
				Pixel.X=X
				Pixel.Y=Y
				exitfunction Pixel
			endif
		next X
	next Y
endfunction Pixel