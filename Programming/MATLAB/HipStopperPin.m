%Hip Stopper Pin
%Input: Material Props, dimensions, angular acceleration of stopper, mass of
%stopper, distance between stopper tip and shaft
%Output: Safety factors
%Written by: Sharon Tam
%Last update: October 19, 2019

classdef HipStopperPin < handle
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
        F_pinStopper;
        
        %Stresses%
        tau_pinMax;
        
        %Safety Factors%
        n_pin_shear;
    end
    
    methods
        function obj = HipStopperPin(mat_Sy, mat_Su, L_pin, R_pin) 
            %Intialization of all variables
            obj.pin_Su = mat_Su; %Pa
            obj.pin_Sy = mat_Sy; %Pa
            obj.pin_Ssy = 0.5*mat_Sy;
            obj.l_pin = L_pin; %m - does not include the pin head that prevents axial motion but includes extra needed for circlip
            obj.r_pin = R_pin; %m - will likely need to parametrize l_pin and r_pin later
            obj.A_pin = pi*obj.r_pin^2; %m^2 
            obj.F_pinStopper = NaN;
            obj.tau_pinMax = NaN;
            obj.n_pin_shear = NaN;
        end
        
        %Pin will fail in shear.
        function n_shear = hipStopperPin_shearSF(obj, r_stopperShaft, alpha_stopper)
            obj.F_pinStopper = 0.22*r_stopperShaft^2*alpha_stopper^2; %N
            obj.tau_pinMax = (4/3)*obj.F_pinStopper/obj.A_pin; %Pa
            obj.n_pin_shear = obj.pin_Ssy/obj.tau_pinMax;
            n_shear = obj.n_pin_shear;
        end
    end
end