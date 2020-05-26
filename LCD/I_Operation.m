classdef I_Operation
    %I_Part class
    
   properties
       name
       parent       
    end
    
    methods
       function obj = I_Operation(name,parent)
            %constructor
            obj.name = name;
            obj.parent = parent;            
       end     
    end
end

