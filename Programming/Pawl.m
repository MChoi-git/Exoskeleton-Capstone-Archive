%Pawl
%Input: Material Props, force of ratchet tooth on pawl, force of spring
%Output: Safety factors
%Written by: Sharon Tam
%Last update: October 19, 2019

classdef Pawl < handle
    properties
        %Material Properties%
        pawl_Su;
        pawl_Sy;
        pawl_SnPrime;
        pawl_Sn;

        %Dimensions and Properties%
        r_pawlOuter; 
        r_pawlPin;
        l_pawlOverall;
        t_pawl;
        d_pawl2string; %m
        d_pawl2spring; %m
        A_pawl;
        
        %Forces%
        F_pawlPin_x;
        F_pawlPin_y;
        F_string;
        
        %Stresses%
        sigma_pawlAxial;
        sigma_pawla;
        sigma_pawlm;
        
        %Safety Factors%
        n_pawl_yield;
        n_pawl_fatigue;
        
        %Constants%
        C_L;
        C_G;
        C_S;
        C_T;
        C_R;
    end
    
    methods
        function obj = Pawl(mat_Sy, mat_Su, Cs) 
            %Intialization of all variables
            obj.pawl_Su = mat_Su; %Pa
            obj.pawl_Sy = mat_Sy; %Pa
            obj.pawl_SnPrime = 0.5*mat_Su;
            obj.C_L = 1; %axial load
            obj.C_G = 0.8; %dia. < 10mm
            obj.C_S = Cs; %forged surface finish, determine from fig 8.13 p323 in Juvinall and Marshek
            obj.C_T = 1; %room temp.
            obj.C_R = 0.753; %99.9% reliability
            obj.pawl_Sn = obj.pawl_SnPrime*obj.C_L*obj.C_G*obj.C_S*obj.C_T*obj.C_R; %Pa
            obj.r_pawlOuter = 0.004; %m
            obj.r_pawlPin = 0.002; %m
            obj.l_pawlOverall = 0.015; %m
            obj.t_pawl = 0.005; %m - note might need to change to parametrize things later
            obj.d_pawl2string = 0.009; %m
            obj.d_pawl2spring = 0.004; %m
            obj.A_pawl = 2*obj.r_pawlOuter*obj.t_pawl; %m^2
            obj.F_pawlPin_x = NaN;
            obj.F_pawlPin_y = NaN;
            obj.F_string = NaN;
            obj.sigma_pawlAxial = NaN;
            obj.sigma_pawla = NaN;
            obj.sigma_pawlm = NaN;
            obj.n_pawl_yield = NaN;
            obj.n_pawl_fatigue = NaN;
        end
        
        %Assume mass of the pawl is negligible so all the calculations on 
        %the pawl can be static calcs despite the shank moving.
        function FpawlX = getF_pawlPinX(obj, F_pawl)
            obj.F_pawlPin_x = F_pawl; %N
            FpawlX = obj.F_pawlPin_x;
        end
        
        function FpawlY = getF_pawlPinY(obj, F_spring)
            obj.F_string = F_spring*obj.d_pawl2spring/obj.d_pawl2string; %N
            obj.F_pawlPin_y = obj.F_string-F_spring; %N
            FpawlY = obj.F_pawlPin_y;
        end
        
        function Fstring = getF_string(obj, F_spring)
            obj.F_string = F_spring*obj.d_pawl2spring/obj.d_pawl2string; %N
            Fstring = obj.F_string;
        end
        
        %Assume that since it is so short and not super rounded, that axial 
        %force will be the biggest loading force in this scenario. 
        %Assume that the cross-section of the pawl is more or less uniform.
        %Pawl will fail either by yielding or from fatigue.
        function n_yield = pawl_yieldSF(obj,F_pawlPin_x)
            obj.sigma_pawlAxial = abs(F_pawlPin_x)/obj.A_pawl; %Pa
            obj.n_pawl_yield = obj.pawl_Sy/obj.sigma_pawlAxial;
            n_yield = obj.n_pawl_yield;
        end
        
        function n_fatigue = pawl_fatigueSF(obj,F_pawlPin_x)
            obj.sigma_pawlAxial = abs(F_pawlPin_x)/obj.A_pawl; %Pa
            obj.sigma_pawla = obj.sigma_pawlAxial/2; %Pa
            obj.sigma_pawlm = obj.sigma_pawlAxial/2; %Pa
            obj.n_pawl_fatigue = ((obj.sigma_pawla/obj.pawl_Sn)+(obj.sigma_pawlm/obj.pawl_Su))^(-1);
            %Modified Goodman
            n_fatigue = obj.n_pawl_fatigue;
        end
    end
end