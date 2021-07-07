%Pawl Pin
%Input: Material Props, force of ratchet tooth on pawl (from pawl), force 
%of string (from pawl), force of spring (from pawlSpring)
%Output: Safety factors
%Written by: Sharon Tam
%Last update: October 19, 2019

classdef PawlPin < handle
    properties
        %Material Properties%
        pawlPin_Su;
        pawlPin_Sy;
        pawlPin_Ssy;

        %Dimensions and Properties%
        r_pawlPin;
        l_pawlPin;
        
        %Forces%
        V_pawlPinMax;
        
        %Stresses%
        tau_pawlPinMax;
        
        %Safety Factors%
        n_pawlPin_shear;
    end
    
    methods
        function obj = PawlPin(mat_Sy, mat_Su) 
            %Intialization of all variables
            obj.pawlPin_Su = mat_Su; %Pa
            obj.pawlPin_Sy = mat_Sy; %Pa
            obj.pawlPin_Ssy = 0.5*mat_Su;
            obj.r_pawlPin = 0.002; %m
            obj.l_pawlPin = 0.005; %m
            obj.V_pawlPinMax = NaN;
            obj.tau_pawlPinMax = NaN;
            obj.n_pawlPin_shear = NaN;
        end
        
        function n_shear = pawlPin_shearSF(obj, F_pawlPin_X, F_pawlPin_Y)
            obj.V_pawlPinMax = sqrt((F_pawlPin_X)^2+(F_pawlPin_Y)^2); %N
            obj.tau_pawlPinMax = (4/3)*obj.V_pawlPinMax/(pi*obj.r_pawlPin^2); %Pa
            obj.n_pawlPin_shear = obj.pawlPin_Ssy/obj.tau_pawlPinMax;
            n_shear = obj.n_pawlPin_shear;
        end
    end
end