classdef I_Joint
    %I_Part class
    
   properties
       name
       body1
       occ1
       area1
       outline1
       
       body2
       occ2
       area2
       outline2
       
       screws
       
    end
    
    methods
        function obj = I_Joint(name,body1,occ1,area1,outline1,body2,occ2,area2,outline2)
            %constructor
            obj.name = name;
            obj.body1 = body1;
            obj.occ1 = occ1;
            obj.area1 = area1;
            obj.outline1 = outline1;
            obj.body2 = body2;
            obj.occ2 = occ2;        
            obj.area2 = area2;
            obj.outline2 = outline2;
        end          
    end
end

