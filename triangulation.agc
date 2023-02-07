// File: Triangulation.agc
// Created: 20-11-29

type PT_PointData
	X as integer
	Y as integer
	ID as integer
endtype

function PT_CreateTriangles(SourcePoints as Core_Int2Data[], Indices ref as integer[])
	PT_DeleteTriangles(Indices)
	PT_Triangulate(SourcePoints, Indices)
endfunction

function PT_DeleteTriangles(Indices ref as integer[])
	Indices.length=-1
endfunction

function PT_DrawLines(Points ref as Core_Int2Data[],Red,Green,Blue)
    for PointID=1 to Points.length
    	DrawLine(Points[PointID-1].X,Points[PointID-1].Y,Points[PointID].X,Points[PointID].Y,Red,Green,Blue)
    next PointID
    if Points.length>1
    	DrawLine(Points[0].X,Points[0].Y,Points[Points.length].X,Points[Points.length].Y,Red,Green,Blue)
    endif
endfunction

function PT_DrawTriangles(Points ref as Core_Int2Data[],Indices as integer[], Red,Green,Blue)
    for Index=0 to Indices.length-2
    	LeftIndex=Indices[Index]
    	MidIndex=Indices[Index+1]
    	RightIndex=Indices[Index+2]
    	DrawLine(Points[LeftIndex].X,Points[LeftIndex].Y,Points[MidIndex].X,Points[MidIndex].Y,Red,Green,Blue)
    	DrawLine(Points[MidIndex].X,Points[MidIndex].Y,Points[RightIndex].X,Points[RightIndex].Y,Red,Green,Blue)
    	DrawLine(Points[RightIndex].X,Points[RightIndex].Y,Points[LeftIndex].X,Points[LeftIndex].Y,Red,Green,Blue)
    next Index
endfunction

function PT_AddPoint(Points ref as PT_PointData[],X,Y)
	local TempPoint as PT_PointData
	
	TempPoint.X=X
	TempPoint.Y=Y
	if Points.length>-1
		TempPoint.ID=Points[Points.length].ID+1
	else
		TempPoint.ID=0
	endif
	Points.insert(TempPoint)
	
	ID=Points[Points.length].ID+1
	if GetTextExists(ID)=0
		CreateText(ID,str(Points.length))
		SetTextPosition(ID,Points[Points.length].X,Points[Points.length].Y-5)
		SetTextColor(ID,255,255,255,255)
	endif
endfunction

function PT_RemovePoint(Points ref as PT_PointData[],PointID)
	if PointID>-1
		ID=Points[PointID].ID+1
		if GetTextExists(ID)=1 then DeleteText(ID)
		Points.Remove(PointID)
	endif
endfunction

function PT_Triangulate(SourcePoints as Core_Int2Data[], Indices ref as integer[])
	local Points as PT_PointData[]
	local TempPoint as PT_PointData
	
	for Index=0 to SourcePoints.length
		TempPoint.X=SourcePoints[Index].X
		TempPoint.Y=SourcePoints[Index].Y
		TempPoint.ID=Index
		Points.insert(TempPoint)
	next Index
	
	if Points.length>1
		local Triangle as PT_PointData[2]
		Indices.length=-1
		
		if PT_TriangleCCW(Points[0].X,Points[0].Y,Points[1].X,Points[1].Y,Points[2].X,Points[2].Y)=0
			Points.reverse()
		endif
		
	    for PointID=0 to Points.length+2	    	
	    	LeftIndex=mod(PointID,Points.length+1)
	    	MidIndex=mod(PointID+1,Points.length+1)
	    	RightIndex=mod(PointID+2,Points.length+1)
	    	Triangle[0]=Points[LeftIndex]
	    	Triangle[1]=Points[MidIndex]
	    	Triangle[2]=Points[RightIndex]
	    	
//~	    	string$="Left: "+str(LeftIndex)+"-"+str(Triangle[0].ID)+chr(0)+"Mid: "+str(MidIndex)+"-"+str(Triangle[1].ID)+chr(0)+"Right: "+str(RightIndex)+"-"+str(Triangle[2].ID)
//~	    	message(string$)
	    	
	    	if PT_TriangleCCW(Triangle[0].X,Triangle[0].Y,Triangle[1].X,Triangle[1].Y,Triangle[2].X,Triangle[2].Y)=1
				if PT_PointListInTriangle(Points,Triangle)=0
					Points.remove(MidIndex)
					PointID=PointID-1
					
					Indices.insert(Triangle[0].ID)
					Indices.insert(Triangle[1].ID)
					Indices.insert(Triangle[2].ID)
				endif
			endif
	    next PointID
	endif
endfunction

function PT_ReversePointList(Points ref as PT_PointData[])
	local TempPoints as PT_PointData[]
	for PointID=Points.length to 0 step -1
		TempPoints.insert(Points[PointID])
	next PointID
	Points=TempPoints
endfunction

function PT_PointListInTriangle(Points ref as PT_PointData[],Triangle ref as PT_PointData[])
	for PointID=0 to Points.length
		if PT_PointOfTriangle(Points[PointID],Triangle)=0
			if PT_PointInTriangle(Points[PointID].X,Points[PointID].Y,Triangle[0].X,Triangle[0].Y,Triangle[1].X,Triangle[1].Y,Triangle[2].X,Triangle[2].Y)=1
				exitfunction 1
			endif
		endif
	next PointID
endfunction 0

function PT_PointOfTriangle(Point as PT_PointData,Triangle ref as PT_PointData[])
	for ID=0 to Triangle.length
		if Point.X=Triangle[ID].X and Point.Y=Triangle[ID].Y then exitfunction 1
	next ID
endfunction 0

function PT_TriangleCCW(x1,y1,x2,y2,x3,y3)
endfunction ((x1-x2)*(y3-y2))-((y1-y2)*(x3-x2))>0

function PT_PointInTriangle(PointX,PointY,x1,y1,x2,y2,x3,y3)
	AB#=((PointY-y1)*(x2-x1))-((PointX-x1)*(y2-y1))
	BC#=((PointY-y2)*(x3-x2))-((PointX-x2)*(y3-y2))
	if AB#*BC#<=0 then exitfunction 0
	
	CA#=((PointY-y3)*(x1-x3))-((PointX-x3)*(y1-y3))
	if BC#*CA#<=0 then exitfunction 0
endfunction 1