 classdef ConfigProcess
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id string        
        activityName string
        quantity double
        loc string % default location
        locList % available locations
        correction double % if selected process doesnt fit 100%
        parameter string % used for creating quantity from material properties
        type string % ecoinvent, companyDB...
        refProduct
        alternativeProcesses ConfigProcess
    end
    
    methods
        function obj = ConfigProcess(activityName, loc, refProd)
            %Creates Process by Name 
            %Optional Inputs: Location, ReferenceProduct               
            obj.activityName = activityName;
            obj.id = java.util.UUID.randomUUID.toString;                                
            obj.loc = loc;
            obj.refProduct = refProd;
            obj.type = "ecoinvent";
            obj = obj.getInfoFromEcoinvent(activityName, refProd);            
            obj.alternativeProcesses = [obj.alternativeProcesses obj];
        end                
                
        function obj = getInfoFromEcoinvent(obj, activityName, refProd)
            T = readtable("ecoinvent 3.6_cut-off_ecoSpold02\FilenameToActivtiyLookup.csv");
            Occ = T(T.ActivityName == string(activityName),:);    
            Occ = Occ(Occ.ReferenceProduct == string(refProd),:);
            obj.locList = Occ.Location;                 
        end  
        
        function obj = addAlternative(obj, alternative)
           obj.alternativeProcesses = [obj.alternativeProcesses alternative];
        end
        
    end
    
    methods (Static)
        function list(name,varargin)
            T = readtable("ecoinvent 3.6_cut-off_ecoSpold02\FilenameToActivtiyLookup.csv");
            switch nargin
                case 1
                    Occ = T(find(contains(T.ActivityName,string(name))),:)
                case 2
                    loc = varargin{1};
                    Occ = T(find(contains(T.ActivityName,string(name))),:);
                    Occ = Occ(find(contains(Occ.Location,loc)),:)
                case 3
                    loc = varargin{1};
                    refProd = varargin{2};
                    Occ = T(find(contains(T.ActivityName,string(name))),:);
                    Occ = Occ(find(contains(Occ.Location,loc)),:);
                    Occ = Occ(find(contains(Occ.ReferenceProduct,refProd)),:)
            end                     
        end   
    end
end

