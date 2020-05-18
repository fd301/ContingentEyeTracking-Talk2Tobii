function [LookBehT, LookBehD, SacLookBeh] = ExtractTrialBefTurnRespond_Fam( FixSacS, res, IndF, TimeLine, TimeLineE,AngEvent, BreakPnt )
% Extract familiarisation and trials before turn response separately

% -2 -> look else
% -1 -> look opposite direction
%  0 -> look central object
%  1 -> look the hand of the central object
%  2 -> look same direction
%  3 -> eyes not found
% 3.5-> Nan -- non specified saccade or fixation


flagFig = 0;

%% define regions of interest
% calculate central ellipse points
Cen = [res(1)/2,res(2)/2];
a = 170;
b = 200;
f1 = [res(1)/2,res(2)/2+a/2];
f2 = [res(1)/2,res(2)/2-a/2];
steps = 10;
Epnts = CalcEllipse( Cen, a, b, f1, f2, steps, 1);

% calculate ellipse one for half hand of turning kettle -- turning right
steps = 30;
a = 100;
b = 50;
f1 = [490,492];
f2 = [349,489];
aa = ( f1(2)-f2(2) )/( f1(1)-f2(1) );
bb = f1(2) - aa*f1(1);
tmpPar = 2*( ( f1(1)-f2(1) ) + aa*( f1(2)-f2(2) ) );
tmpOnm = f1(1)^2 +f1(2)^2 - f2(1)^2 - f2(2)^2 - 2*bb*( f1(2)-f2(2) );
CenSX = tmpOnm / tmpPar;
CenSY = aa*CenSX+bb;
CenS = [CenSX CenSY];
EpntSeg1L = CalcEllipse( CenS, a, b, f1, f2, steps, 1);

% calculate ellipse one for the second half hand of turning kettle -- turning right
a = 50;
b = 80;
f1 = [349,489];
f2 = [303,402];
aa = ( f1(2)-f2(2) )/( f1(1)-f2(1) );
bb = f1(2) - aa*f1(1);
tmpPar = 2*( ( f1(1)-f2(1) ) + aa*( f1(2)-f2(2) ) );
tmpOnm = f1(1)^2 +f1(2)^2 - f2(1)^2 - f2(2)^2 - 2*bb*( f1(2)-f2(2) );
CenSX = tmpOnm / tmpPar;
CenSY = aa*CenSX+bb;
CenS = [CenSX CenSY];
EpntSeg2L = CalcEllipse( CenS, a, b, f1, f2, steps, 1);

%estimate symmetrical for turning left
EpntSeg1R = [res(1)-EpntSeg1L(:,1) EpntSeg1L(:,2)];
EpntSeg2R = [res(1)-EpntSeg2L(:,1) EpntSeg2L(:,2)];

% Right object boundaries
ObjPntsL = [ 1 467;...
    212 467;...
    317 528;...
    335 561;...
    335 767
    1 res(2)];

% Left object boundaries
ObjPntsR = [res(1)-ObjPntsL(:,1) ObjPntsL(:,2)];


%%%%%%%%%%%%%%%%%
% find when 3D object turns-- extreme position before it stops and wait for
% 5sec
% 3D object turns

% find end of familiarisation --- is not implemented yet!!
endFam = IndF{10}+1;
%endFamT = TimeLineE(endFam);


% find when turning start
theta = IndF{3};
turn = diff(theta);
turnPnts = find(turn>10);

%if you want to include the time during turning
%stTurn = [turnPnts; length(theta)];

%if you don't want to include the time during turning
stTurn = [ endFam; 1; turnPnts+1];

%find timing in event timeline
stTurnT = TimeLineE( theta(stTurn) );
%find out whether it turns left or right
DirTurn = AngEvent( theta(stTurn),2 );

%find closest eyetracking sample for each event
for i=1:length(stTurnT)
    tmpDist = abs( TimeLine - stTurnT(i) );
    [tmp indM] = min(tmpDist);
    TLEv(i) = indM;
end

%find out when object starts turning 
% stTurnS = [endFam; theta(1); theta(turnPnts+1) ];
% %find closest eyetracking sample for each event
% for i=1:length(stTurnS)
%     tmpDist = abs( TimeLine - TimeLineE( stTurnS(i) ) );
%     [tmp indM] = min(tmpDist);
%     TLESv(i) = indM;
% end


%% find out where baby looks on the screen
if( flagFig)
    figure;
    hold on;
    plot( Epnts(:,1), Epnts(:,2), '.' );
    plot( EpntSeg1(:,1), EpntSeg1(:,2), '.' );
    plot( EpntSeg2(:,1), EpntSeg2(:,2), '.' );
    plot( EpntSeg1L(:,1), EpntSeg1L(:,2), '.' );
    plot( EpntSeg2L(:,1), EpntSeg2L(:,2), '.' );
    plot( ObjPntsR(:,1), ObjPntsR(:,2), '.' );
    plot( ObjPntsL(:,1), ObjPntsL(:,2), '.' );
end

BreakPnt = [1; endFam; BreakPnt];

%find where they look for each time interval between turning and break
kk = 1;
count11 = 1;
for i=1:length(stTurnT)
    IndInit = BreakPnt(kk);
    IndFin = TLEv(i);
    while(IndFin<IndInit) %there are intermediate breaks
        kk = kk+1;
        IndFin = BreakPnt(kk);  
    end
    kk = kk+1;

    TrialSacFix = FixSacS(IndInit:IndFin);
    tmpDir = DirTurn(i);
    count = 1;
    
    if(flagFig)
        figure;
        hold on;
        axis( [-20 res(1)+20 -20 res(2)+20] );
        set(gca,'YDir','reverse');
    end
    
    count_pro = count;
    for j=1:length(TrialSacFix)  
        if(j==54)
            tmp222=1;
        end
        if(flagFig)
            plot( Epnts(:,1), Epnts(:,2), '.' );
            plot( EpntSeg1(:,1), EpntSeg1(:,2), '.' );
            plot( EpntSeg2(:,1), EpntSeg2(:,2), '.' );
            plot( EpntSeg1L(:,1), EpntSeg1L(:,2), '.' );
            plot( EpntSeg2L(:,1), EpntSeg2L(:,2), '.' );
            plot( ObjPntsR(:,1), ObjPntsR(:,2), '.' );
            plot( ObjPntsL(:,1), ObjPntsL(:,2), '.' );
            axis( [-20 res(1)+20 -20 res(2)+20] );
        end
        
        tmpFS = TrialSacFix(j);
        if( ~strcmpi(tmpFS.type,'fix') )
            %check if eyes have not found!!
            if( strcmpi( tmpFS.type, 'EyesNotFound') )
                LookBehTtmp(count) = tmpFS.t(2);
                LookBehDtmp(count) = 3;
            elseif( strcmpi(tmpFS.type,'sac') )
                % find out which objects did the baby looked
                look1 = tmpFS.from .*res;
                look2 = tmpFS.to .*res;
                FlagSC1 = contourInOut( look1, Epnts );
                FlagSR1 = contourInOut( look1, ObjPntsR );
                FlagSL1 = contourInOut( look1, ObjPntsL );
                FlagSC2 = contourInOut( look2, Epnts );
                FlagSR2 = contourInOut( look2, ObjPntsR );
                FlagSL2 = contourInOut( look2, ObjPntsL );
                if(FlagSC1)
                    sacTmp1 = 0;
                elseif(FlagSR1)
                    sacTmp = 1;     % -> 1 for right
                elseif(FlagSL1)
                    sacTmp1 = 2;     % -> 2 for left
                else
                    sacTmp1 = 3;     % -> 3 for elsewhere
                end
                if(FlagSC2)
                    sacTmp2 = 0;
                elseif(FlagSR2)
                    sacTmp2 = 1;     % -> 1 for right
                elseif(FlagSL2)
                    sacTmp2 = 2;     % -> 2 for left
                else
                    sacTmp2 = 3;     % -> 3 for elsewhere
                end
                SacLookBehtmp(count11,:) = [sacTmp1 sacTmp2 count tmpFS.t];
                count11 = count11+1;
                
                LookBehTtmp(count) = tmpFS.t(2);
                LookBehDtmp(count) = 3.5;
            else % undetermined
                LookBehTtmp(count) = tmpFS.t(2);
                LookBehDtmp(count) = 3.5;
            end
            
            count = count+1;
            continue;
        end
        
        look = tmpFS.meanpos .* res;
        if( flagFig )
            plot( look(1), look(2), '*r');
        end
        
        FlagC = contourInOut( look, Epnts );
        if( FlagC ) %it looks the central object-- 0
            LookBehTtmp(count) = tmpFS.t(2);
            LookBehDtmp(count) = 0;
            count = count+1;
        elseif(tmpDir>0) %turn right
            %check if it still looks the object turning parts
            %object doesn't turn during trial
%             FlagC1 = contourInOut( look, EpntSeg1R );
%             FlagC2 = contourInOut( look, EpntSeg2R );
%             if( FlagC1 || FlagC2 ) % still look central object but hand part
%                 LookBehTtmp(count) = tmpFS.t(2);
%                 LookBehDtmp(count) = 1;
%                 count = count+1;
%                 continue;
%             end

            %check if it looks the same-right object or the left
            FlagS = contourInOut( look, ObjPntsR );
            FlagO = contourInOut( look, ObjPntsL );
            if(FlagS) %looks the same obj -- 2
                LookBehTtmp(count) = tmpFS.t(2);
                LookBehDtmp(count) = 2;
                count = count+1;            
            elseif(FlagO) %baby looks the opposite object
                LookBehTtmp(count) = tmpFS.t(2);
                LookBehDtmp(count) = -1;
                count = count+1;            
            else %we don't know where the baby looks
                LookBehTtmp(count) = tmpFS.t(2);
                LookBehDtmp(count) = -2;
                count = count+1;            
            end
            
        else %turn left
            
            %check if it still looks the object turning parts
            %object doesn't turn during main trial
%             FlagC1 = contourInOut( look, EpntSeg1L );
%             FlagC2 = contourInOut( look, EpntSeg2L );
%             if( FlagC1 || FlagC2 ) % still look central object but hand part
%                 LookBehTtmp(count) = tmpFS.t(2);
%                 LookBehDtmp(count) = 1;
%                 count = count+1;            
%                 continue;
%             end

            %check if it looks the same-right object or the left
            FlagS = contourInOut( look, ObjPntsL );
            FlagO = contourInOut( look, ObjPntsR );
            if(FlagS) %looks the same obj -- 2
                LookBehTtmp(count) = tmpFS.t(2);
                LookBehDtmp(count) = 2;
                count = count+1;            
            elseif(FlagO) %baby looks the opposite object
                LookBehTtmp(count) = tmpFS.t(2);
                LookBehDtmp(count) = -1;
                count = count+1;            
            else %we don't know where the baby looks
                LookBehTtmp(count) = tmpFS.t(2);
                LookBehDtmp(count) = -2;
                count = count+1;            
            end
            
        end
        
    end
    
    if( exist('LookBehDtmp','var') )
        LookBehD{i} = LookBehDtmp;
        LookBehT{i} = LookBehTtmp;
        clear LookBehDtmp LookBehTtmp;
    else
        LookBehD{i} = [];
        LookBehT{i} = [];
    end
    
    if( exist('SacLookBehtmp', 'var') )
        SacLookBeh{i} = SacLookBehtmp;
        clear SacLookBehtmp;
    else
        SacLookBeh{i} = [];
    end
    
end

return;
