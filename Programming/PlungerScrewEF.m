classdef PlungerScrewEF < handle
    
    properties
        diameter;
        plunger_Thickness;
        rubber_Thickness;
        bar_Width;
        
        force_PlungerScrew_y;
        force_BearingExt_y;
        
        shear_HipPin;   
        yield_Strength;
        safety_FactorShear;
        moment_Plunger;
        safety_FactorBending;
        stress_HipPin;
        
    end
    
    methods
        function obj = PlungerScrewEF(diameter,ys,plungerth,rubberth,barwidth)
            obj.diameter = diameter;
            obj.plunger_Thickness = plungerth;
            obj.rubber_Thickness = rubberth;
            obj.bar_Width = barwidth;
            
            obj.force_PlungerScrew_y = NaN;
            obj.force_BearingExt_y = NaN;
            
            obj.shear_HipPin = NaN;
            obj.yield_Strength = ys;
            obj.safety_FactorShear = NaN;
            obj.moment_Plunger = NaN;
            obj.safety_FactorBending = NaN;
            obj.stress_HipPin = NaN;
        end
        
        function out = calculateForcePlungerScrewY(obj,forceHip, forcePlunger, plungerMass,accel_y)
            obj.force_PlungerScrew_y = plungerMass*accel_y + forceHip + plungerMass*9.81 + forcePlunger*sind(15);
            out = obj.force_PlungerScrew_y;
        end
        function out = calculateForceBearingExtY(obj,theta,forcePlunger,weightPlunger)
            obj.force_BearingExt_y = obj.force_PlungerScrew_y-(forcePlunger*sind(theta))-weightPlunger;
            out = obj.force_BearingExt_y;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%Failure%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function out = calculateSafetyFactor(obj,force_PlungerScrew_y)
            obj.shear_HipPin= (2*abs(force_PlungerScrew_y))/(pi*obj.diameter^2);
            Ssy = 0.577*obj.yield_Strength;
            obj.safety_FactorShear = Ssy/obj.shear_HipPin;
            
            obj.moment_Plunger = (0.5*abs(force_PlungerScrew_y)*(obj.plunger_Thickness+obj.rubber_Thickness))+((0.5*abs(force_PlungerScrew_y)...
                *obj.bar_Width/2)/2);
            obj.stress_HipPin = (obj.moment_Plunger * obj.diameter / 2)/((pi*obj.diameter^4)/64);
            obj.safety_FactorBending = obj.yield_Strength / obj.stress_HipPin;
            out = min([obj.safety_FactorShear obj.safety_FactorBending]);
        end
    end
end

