function vol = getCylinderVolume(bbox, allowance)
    %detects the most similar dimensions 
    %and assumes it as end face                    
    r12 = abs(1 - bbox(1)/bbox(2));
    r13 = abs(1 - bbox(1)/bbox(3));
    r23 = abs(1 - bbox(2)/bbox(3));

    if (r12 < r13) && (r12 < r23)
       z = bbox(3);
       d = max(bbox(1),bbox(2));
    elseif (r13 < r12) && (r13 < r23)
       z = bbox(2);
       d = max(bbox(1),bbox(3));
    elseif (r23 < r12) && (r23 < r13)
       z = bbox(1);
       d = max(bbox(2),bbox(3));
    else
       z = bbox(1);
       d = bbox(1);
    end    
    vol = pi*(d*(1+allowance/100))^2/4*(z*(1+allowance/100)); 
end