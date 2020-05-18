function [w, Epnts, Bpnts ]= findMorphAreas(vpos,mx,my,framecount)

Top = vpos(5,1:2);
Bot = mean( vpos(6:end,1:2), 1);

pntsV = vpos(1:4,1:2);
[dist, pntInt, pntReal] = distance2DPntFromLine( pntsV, Top, Bot );


%define areas of interest
C = (pntInt + pntsV)/2;
aa = dist/2;
cc = aa/2;
bb = sqrt(aa.^2-cc.^2);


for i=1:length(C)
    Epnts{i} = CalcEllipse( C(i,:),aa(i),bb(i),pntsV(i,:),pntInt(i,:), 8 );
end

CB = { Bot+(Top-Bot)*5/6  Bot+(Top-Bot)/2 Bot+(Top-Bot)/6};

for i=1:length(CB)
    Bpnts{i} = CalcEllipse(CB{i},150,80,Top, Bot, 20, 1);
end

for i=1:length(C)
    tmp = contourInOut( [mx my], Epnts{i} );
    EInOut(i) = double(tmp);
end

for i=1:length(CB)
    tmp = contourInOut( [mx my], Bpnts{i} );
    BInOut(i) = double(tmp);
end

Eindex = find(EInOut);
Bindex = find(BInOut);

w = zeros( 1, length(C)+length(CB) );

if( isempty(Eindex) && isempty(Bindex) )
    w(1) = 1;
else
    
    if( ~isempty(Eindex) )
        w(1+Eindex) = (sin(framecount / 20 * 3.1415 * 2) )/2; 
    end
    
    if( ~isempty(Bindex) )
        w(1+length(C)+Bindex) = (cos(framecount / 10 * 3.1415 * 2) )/2; 
    end
    
    tmp = sum(w(2:end));
    w(1) = 1-tmp;
    
end



