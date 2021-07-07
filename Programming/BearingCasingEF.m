classdef BearingCasingEF < handle
    
    properties
        bearingCasingEF_Volume;
        bearingCasingEF_Density;
        bearingCasingEF_Mass; 
        bearingCasingScrew_Diameter;
        yield_Strength;
        
        force_BearingCasingScrewY;
        
        shear_BearingCasingScrew;
        safety_FactorShear;
        stress_BearingCasingScrew;
        safety_FactorBending;
    end
    
    methods
        function obj = BearingCasingEF(density,diameter,ys)
            obj.bearingCasingEF_Volume = ((pi/4)*(diameter^2)*0.02)-((0.000031)+(0.0000094));
            obj.bearingCasingEF_Density = density;
            obj.bearingCasingEF_Mass = obj.bearingCasingEF_Volume*obj.bearingCasingEF_Density; %%keyword
            obj.bearingCasingScrew_Diameter = diameter;
            obj.yield_Strength = ys;
            
            obj.force_BearingCasingScrewY = NaN;
            
            obj.shear_BearingCasingScrew = NaN;
            obj.safety_FactorShear = NaN;
            obj.stress_BearingCasingScrew = NaN;
            obj.safety_FactorBending = NaN;
        end
        
        function out = calculateForceBearingCasingScrewY(obj,accel_y,forceBearing,plungerWeight,plungerCasingWeight)
            obj.force_BearingCasingScrewY = (obj.bearingCasingEF_Mass*accel_y) + forceBearing + (obj.bearingCasingEF_Mass*9.81)...
                + plungerWeight +plungerCasingWeight;
            out = obj.force_BearingCasingScrewY;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Failure Analysis%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function out = calculateSafetyFactor(obj,forcebearing,weightplunger,weightplungercasing,bearingcasingth)
            obj.shear_BearingCasingScrew = abs((obj.bearingCasingEF_Mass*9.81 + weightplunger + forcebearing + weightplungercasing))/...
                (2*obj.bearingCasingScrew_Diameter^2*pi);
            Ssy = 0.577*obj.yield_Strength;
            obj.safety_FactorShear =  Ssy/ obj.shear_BearingCasingScrew;
            
            obj.stress_BearingCasingScrew = (bearingcasingth*abs((weightplunger+weightplungercasing+forcebearing))*obj.bearingCasingScrew_Diameter)...
                /(pi*obj.bearingCasingScrew_Diameter^4);
            obj.safety_FactorBending = obj.yield_Strength / obj.stress_BearingCasingScrew;
            
            out = min([obj.safety_FactorShear obj.safety_FactorBending]);
        end
    end
end

