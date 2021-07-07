classdef PlungerCasingEF < handle
    
    properties
        plungerCasing_Volume;
        plungerCasing_Density;
        plungerCasing_Mass;
        
        force_CasingScrewX;
        force_CasingScrewY;
        
    end
    
    methods
        function obj = PlungerCasingEF(volume,density)
            obj.plungerCasing_Volume = volume; 
            obj.plungerCasing_Density = density;
            obj.plungerCasing_Mass = volume*density;
            
            obj.force_CasingScrewX = NaN;
            obj.force_CasingScrewY = NaN;
        end
        
        function out = calculateForceCasingScrewX(obj,theta,accel_x,forceWall)
            obj.force_CasingScrewX = -obj.plungerCasing_Mass*accel_x + forceWall*cosd(theta);
            out = obj.force_CasingScrewX;
        end
        function out = calculateForceCasingScrewY(obj,theta,accel_y,forceWall)
            obj.force_CasingScrewY = forceWall*sind(theta) - (obj.plungerCasing_Mass*9.81) - obj.plungerCasing_Mass*accel_y;
            out = obj.force_CasingScrewY;
        end
    end
end

