%Knee Pin
%Input: Material Props, knee forces
%Output: Safety factors
%Written by: Sharon Tam
%Last update: October 19, 2019

classdef KneePin < handle
    properties
        %Material Properties%
        pin_Su;
        pin_Sy;
        pin_Ssy;

        %Dimensions and Properties%
        l_pin;
        r_pin;
        A_pin;
        
        %Forces%
        V_shearMax;
        
        %Stresses%
        tau_pinMax;
        
        %Safety Factors%
        n_pin_shear;
    end
    
    methods
        function obj = KneePin(mat_Sy, mat_Su, thickness) 
            %Intialization of all variables
            obj.pin_Su = mat_Su; %Pa
            obj.pin_Sy = mat_Sy; %Pa
            obj.pin_Ssy = 0.5*mat_Sy;
            obj.l_pin = thickness + 0.002; %m - does not include the pin head that prevents axial motion but includes extra needed for circlip
            obj.r_pin = 0.003; %m - will likely need to parametrize l_pin and r_pin later
            obj.A_pin = pi*obj.r_pin^2; %m^2 
            obj.V_shearMax = NaN;
            obj.tau_pinMax = NaN;
            obj.n_pin_shear = NaN;
        end
        
        %Pin will fail in only shear because the clearance between the
        %thigh/shank and the bushing and the bushing and the pin is small 
        %so it will prevent bending. Its a double lap joint.
        function n_shear = kneePin_shearSF(obj, F_kneeX, F_kneeY)
            obj.V_shearMax = sqrt((F_kneeX/2)^2+(F_kneeY/2)^2); %N
            obj.tau_pinMax = (4/3)*obj.V_shearMax/obj.A_pin; %Pa
            obj.n_pin_shear = obj.pin_Ssy/obj.tau_pinMax;
            n_shear = obj.n_pin_shear;
        end
    end
end