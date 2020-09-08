classdef ConfigWrapper
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id string
        name string
        configs Config
    end
    
    methods
        function obj = ConfigWrapper(name)
            %UNTITLED3 Construct an instance of this class
            %   Detailed explanation goes here
            obj.name = name;       
            obj.id = java.util.UUID.randomUUID.toString;
        end     
        
        function obj = addConfig(obj, config)
           obj.configs = [obj.configs config];
        end
        
        function con = getConfig(obj,material,classification)
            flag = 0;
            for i = 1:length(obj.configs)
               if(obj.configs(i).material == material)&&(obj.configs(i).classification == classification)
                  con =  obj.configs(i);
                  flag = 1;
                  break;                  
               end
            end
            if flag == 0
               disp("Config not found: " + material + " - " + classification); 
            end
        end
        
    end
end

