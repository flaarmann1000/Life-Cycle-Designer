classdef parserEngine
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dictionary = ["var1","var2"]
    end
    
    %teststring "component.mass + asm.volume + 2 *3"
    methods
        function [y,z] = run(~,str)
            chars = char(str);
            opLookup = ['+','-','*','/'];
            buffer = [];
            var = string.empty;
            operator = string.empty;
            for i = 1:length(chars)                    
                if sum( chars(i) == opLookup) == 0
                    buffer = [buffer chars(i)];                    
                else
                    operator(end+1) = string(chars(i));
                    var(end+1) = strtrim(string(buffer));                    
                    buffer = [];                    
                end
            end
            var(end+1) = string(buffer);
            y = var;
            z = operator;
        end                     
        
        function [obj, parameter] = getParameter(~,str)
            str = strsplit(str,'.');
            obj = str(1);
            parameter = str(2);
        end    
    end               
end

