classdef I_Setup
    %I_Part class
    
   properties
       name
       operationType
       machiningTime                    
       rapidDistance       
       models I_Model
       operations I_Operation
    end
    
    methods
        function obj = I_Setup(name,operationType, machiningTime, rapidDistance)
            %constructor
            obj.name = name;
            obj.operationType = operationType;
            obj.machiningTime = machiningTime;            
            obj.rapidDistance = rapidDistance;
        end    
      
    end
end

