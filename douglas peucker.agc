// File: douglas peucker.agc
// Created: 20-11-30

function DP_CreatePolyline(Points ref as Core_Int2Data[],ResultingPoints ref as Core_Int2Data[],Epsilon#)
	DP_DeletePolyline(ResultingPoints)
	Points.insert(Points[0]) 				// insert start point
	DP_DecimatePolyline(Points,ResultingPoints,0,Points.length,Epsilon#)
//~	Points.insert(Points[Points.length]) 	// insert end point
//~	Points.remove(Points.length)
	Points.remove(Points.length)
endfunction

function DP_DeletePolyline(Points ref as Core_Int2Data[])
	Points.length=-1
endfunction

function DP_DrawLines(Points ref as Core_Int2Data[],Red,Green,Blue)
    for PointID=1 to Points.length
  		StartX#=WorldToScreenX(Points[PointID-1].X)
		StartY#=WorldToScreenY(Points[PointID-1].Y)
		EndX#=WorldToScreenX(Points[PointID].X)
		EndY#=WorldToScreenY(Points[PointID].Y)
    	DrawLine(StartX#,StartY#,EndX#,EndY#,Red,Green,Blue)
    next PointID
    if Points.length>1
  		StartX#=WorldToScreenX(Points[0].X)
		StartY#=WorldToScreenY(Points[0].Y)
		EndX#=WorldToScreenX(Points[Points.length].X)
		EndY#=WorldToScreenY(Points[Points.length].Y)
    	DrawLine(StartX#,StartY#,EndX#,EndY#,Red,Green,Blue)
    endif
endfunction

function DP_DecimatePolyline(Points ref as Core_Int2Data[],ResultingPoints ref as Core_Int2Data[],StartIndex,EndIndex,Epsilon#)
	NextIndex=DP_findFurthest(Points,StartIndex,EndIndex,Epsilon#)
	if NextIndex>0
		if StartIndex<>NextIndex
			DP_DecimatePolyline(Points,ResultingPoints,StartIndex,NextIndex,Epsilon#)
		endif
		
		ResultingPoints.insert(Points[NextIndex])
		
		if EndIndex<>NextIndex
			DP_DecimatePolyline(Points,ResultingPoints,NextIndex,EndIndex,Epsilon#)
		endif
	endif
endfunction

function DP_FindFurthest(Points as Core_Int2Data[],IndexA,IndexB,Epsilon#)
	local StartPoint as Core_Int2Data
	local EndPoint as Core_Int2Data
	local CurrentPoint as Core_Int2Data
	
	StartPoint=Points[IndexA]
	EndPoint=Points[IndexB]
	RecordDistance#=-1
	FurthestIndex=-1
	
	for i=IndexA+1 to IndexB
		CurrentPoint=Points[i]
		Dist#=DP_PointToLineDistance(CurrentPoint.X,CurrentPoint.Y,StartPoint.X,StartPoint.Y,EndPoint.X,EndPoint.Y)
		if Dist#>RecordDistance#
			RecordDistance#=Dist#
			FurthestIndex=i
		endif
	next i
	if RecordDistance#>Epsilon#
		exitfunction FurthestIndex
	endif
endfunction -1

function DP_PointToLineDistance(x#,y#,x1#,y1#,x2#,y2#)
	A#=x#-x1#
	B#=y#-y1#
	C#=x2#-x1#
	D#=y2#-y1#

	dot#=A#*C#+B#*D#
	len_sq#=C#*C#+D#*D#
	param#=dot#/len_sq#

	if param#<0 or (x1#=x2# and y1#=y2#)
		LineNearX#=x1#
		LineNearY#=y1#
	else
		if param#>1
			LineNearX#=x2#
			LineNearY#=y2#
		else
			LineNearX#=x1#+param#*C#
			LineNearY#=y1#+param#*D#
		endif
	endif

	dx#=x#-LineNearX#
	dy#=y#-LineNearY#
	dist#=sqrt(dx#*dx#+dy#*dy#)
endfunction dist#