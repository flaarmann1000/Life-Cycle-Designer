classdef parserEngine
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dicNames = ["var1","var2","var3"]
        dicValues = [1,2,3]
    end
    
    %teststring "component.mass + asm.volume + 2 *3"
    methods
        function [res] = run(obj,str)                          
            
            chars = char(erase(str," ")); %get rid of spaces and convert to char array            
            opLookup = ['+','-','*','/','(',')'];
            buffer = [];            
            var = string.empty;
            operator = string.empty;
            i = 1;
            while i  <= length(chars)                   
                if sum( chars(i) == opLookup) == 0
                    buffer = [buffer chars(i)];                    
                elseif chars(i) == '('                                                                
                    open = 0;
                    for e = i+1:length(chars)                         
                        if chars(e) == '('
                            open = open + 1;
                        end
                        if chars(e) == ')'
                            if open == 0
                                last = e; 
                            else
                                open = open-1;
                            end
                        end
                    end                   
                    subexpression = chars(i+1:last-1);
                    if last+1 < length(chars)
                        i = last;
                    else
                        i = length(chars);                        
                    end                                        
                    buffer = obj.run(subexpression);                    
                else
                    operator(end+1) = string(chars(i));
                    var(end+1) = strtrim(string(buffer));                    
                    buffer = [];                    
                end
                i = i+1;
            end            
            if ~isempty(buffer)
                var(end+1) = string(buffer);                            
            end            
            if ~isempty(var)                
                res = evaluate(var,operator);                            
            end
                       
            function res = evaluate(var, ope)                
                operations = ['/','*','+','-'];
                if isempty(ope)
                   res = lookup(var(1));
                   return;
                end
                for op = 1:length(operations)                                              
                    p = 1;
                    while p <= length(ope)
                        if ope(p) == operations(op)
                            if (isa(lookup(var(p)),'double')) && (isa(lookup(var(p+1)),'double'))
                                switch op
                                    case 1
                                        subRes = lookup(var(p)) / lookup(var(p+1));
                                    case 2
                                        subRes = lookup(var(p)) * lookup(var(p+1));
                                    case 3
                                        subRes = lookup(var(p)) + lookup(var(p+1));
                                    case 4
                                        subRes = lookup(var(p)) - lookup(var(p+1));
                                end
                                ope(p) = [];
                                var(p) = num2str(subRes);
                                var(p+1) = [];
                            else
                                res = "parser error: " + str
                                return
                            end
                        else
                            p = p+1;
                        end
                    end
                    res = str2double(var(1));
                end
            end
            
            function value = lookup(name)                                 
                if ~isnan(str2double(name))
                    value = str2double(name);
                    return
                else
                    for d = 1:length(obj.dicNames)                        
                       if (obj.dicNames(d) == name)
                           value = obj.dicValues(d);                           
                           return
                       end
                    end
                end                
                value = "error"
            end
        end                     
        
        
        function [obj, parameter] = getParameter(~,str)
            str = strsplit(str,'.');
            obj = str(1);
            parameter = str(2);
        end    
    end               
end

