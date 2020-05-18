function InOut = contourInOut( points, pointLines);

[len1,tmp] = size( points );
[len2,tmp] = size( pointLines );

for p=1:len1
    j = points(p,1);
    i = points(p,2);
    
    iOut = 1;
    jOut = len2;
    InOut(p) = 0;           %false
    while(iOut<=len2)
        cx = pointLines(iOut,1);
        cy = pointLines(iOut,2);
        bx = pointLines(jOut,1);
        by = pointLines(jOut,2);
        
        if( ( ( (cy<=i)&(i<by) ) | ( (by<=i)&(i<cy) ) ) & ( j<(bx-cx)*(i-cy)/(by-cy)+cx ) ) 
            InOut(p) = ~InOut(p);
        end
        jOut = iOut;
        iOut = iOut + 1;
    end
    
end

