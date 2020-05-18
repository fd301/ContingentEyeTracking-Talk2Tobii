function DrawSacFix(store_all, win, imgsize, num, k)
% number of characteristics to display
for i=1:num
    
    if (k-i>0)
        store = store_all(k-i);
    else
        continue;
    end

    if( strcmp(store.type,'nan') )
        continue;
    end

    Screen('BlendFunction', win );
    if( strcmp(store.type,'sac') )
        lx = [store.from(1) store.to(1)]*imgsize(1);
        ly = [store.from(2) store.to(2)]*imgsize(2);
        Screen('DrawLines', win, [lx; ly], 1, [85 85 85 0.5] )
        continue;
    end

    if( strcmp(store.type,'fix') )
        r = store.radius*5;
        if( r>64)
            disp(r);
            r = 64;
        end
        Screen('DrawDots', win, [store.meanpos(1)*imgsize(1) store.meanpos(2)*imgsize(2)], r, [85 85 85 0.5], [], 1 );
        continue;
    end

end
