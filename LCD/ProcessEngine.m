classdef ProcessEngine
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        processes EcoinventProcess
    end
    
    methods
        function [obj, fail] = addNewProcess(obj, app, activityName, activityLoc, refProduct)
            try 
                obj.processes(length(obj.processes)+1) = EcoinventProcess(app, string(activityName), string(activityLoc), string(refProduct));
                fail = 0;
            catch 
                fail = 1;     
                disp("Could not create " + activityName)
            end
        end
        
        function saveProcesses(obj)
            data = obj.processes;
            save('Processes', 'data');
        end
        
        function obj = loadProcesses(obj)
            load('Processes', 'data');
            obj.processes = data;            
        end
        
        %(app,proConfig.activityName,proConfig.loc,proConfig.refProduct);
        function [process, fail] = getProcess(obj, app, name, location, refProduct)                                                        
           fail = 0;           
           for i = 1:length(obj.processes)
               if (strcmp(string(obj.processes(i).activityName),string(name)) && strcmp(string(obj.processes(i).activityLoc),string(location))) && strcmp(string(obj.processes(i).refProduct),string(refProduct))
               %if  obj.processes(i).activityName == string(name)
                 process = obj.processes(i); 
                 process .id = java.util.UUID.randomUUID.toString;
                 return
               end           
           end                         
           [app.processEngine, flag] = app.processEngine.addNewProcess(app,name,location, refProduct);
           if flag == 0
               process = app.processEngine.getProcess(app, name, location, refProduct);
               process.id = java.util.UUID.randomUUID.toString;
               obj.saveProcesses();
           else
               fail  = 1;
               process = 0;
               disp("Couldnt find & couldnt create process " + name);
           end                                     
        end
    end
end

