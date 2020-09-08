classdef ConfigProcessDealer
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        processes ConfigProcess
    end
    
    methods
        function obj = addProcess(obj, process)
           obj.processes =  [obj.processes process];
        end
        
        function p = getProcessByName(obj, name)
           flag = 0;
           for i = 1:length(obj.processes)
                if obj.processes(i).activityName == name
                    p = obj.processes(i);
                    flag = 1;
                    break;
                end
           end
           if flag == 0
              disp("could not find: " + name); 
           end
        end
        
        function check(obj)
            if exist('ie','var')==0
                load LciMat;
            end
           for i = 1:length(obj.processes)
               pro = obj.processes(i);
               row = ie(string(ie.activityName) == pro.activityName & string(ie.geography) == pro.loc & string(ie.product) == pro.refProduct,:);
               if isempty(row)
                  disp("not found: " + pro.activityName + " - try:");                   
                  row = ie(string(ie.activityName) == pro.activityName,:);
                  disp(row);  
                  disp("-------------------------------------");
               end   
               for e = 1:length(obj.processes(i).alternativeProcesses)
                   pro = obj.processes(i).alternativeProcesses(e);
                   row = ie(string(ie.activityName) == pro.activityName & string(ie.geography) == pro.loc & string(ie.product) == pro.refProduct,:);
                   if isempty(row)
                      disp("not found: " + pro.activityName + " - try:");                   
                      row = ie(string(ie.activityName) == pro.activityName,:);
                      disp(row);  
                      disp("-------------------------------------");
                   end   
               end
               
           end
           disp("--- check done ---");
        end                
        
    end
        
	% ie(string(ie.activityName) == name,:)
    
end


