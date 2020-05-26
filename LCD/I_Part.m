classdef I_Part
    %I_Part class
    
   properties
        name string
        volume double
        material string
        mass double
        solids I_Solid
        features I_Feature
        parts I_Part
    end
    
    methods
        function obj = I_Part(name,volume, material, mass)
            %constructor
            obj.name = name;
            obj.volume = volume;
            obj.material = material;
            obj.mass = mass;
        end
        function nChildren = getChildrenCount(obj)
           nChildren = 0;
           Iterate(obj);
           
            function Iterate(o)
                for i = 1:length(o.solids)
                    nChildren = nChildren + 1; 
                end
                for i = 1:length(o.parts)
                    %nChildren = nChildren +1;
                    Iterate(o.parts(i));
                end
            end
        end
    end
end

