%Ratchet
%Input: Material Props, force of pawl
%Output: Safety factors
%Written by: Sharon Tam
%Last update: October 19, 2019

classdef Ratchet < handle
    properties
        %Material Properties%
        ratchet_Su;
        ratchet_Sy;
        ratchet_SnPrime;
        ratchet_Sn;

        %Dimensions and Properties%
        r_ratchetOuter;
        r_ratchetInner;
        t_ratchet;
        
        %Stresses%
        sigma_ratchetBending;
        sigma_ratcheta;
        sigma_ratchetm;
        
        %Safety Factors%
        n_ratchet_bending;
        n_ratchet_fatigue;
        
        %Constants%
        C_L;
        C_G;
        C_S;
        C_T;
        C_R;
    end
    
    methods
        function obj = Ratchet(mat_Sy, mat_Su, Cs,width,thickness) 
            %Intialization of all variables
            obj.ratchet_Su = mat_Su; %Pa
            obj.ratchet_Sy = mat_Sy; %Pa
            obj.ratchet_SnPrime = 0.5*mat_Su;
            obj.C_L = 1; %axial load
            obj.C_G = 0.8; %dia. < 10mm
            obj.C_S = Cs; %forged surface finish, determine from fig 8.13 p323 in Juvinall and Marshek
            obj.C_T = 1; %room temp.
            obj.C_R = 0.753; %99.9% reliability
            obj.ratchet_Sn = obj.ratchet_SnPrime*obj.C_L*obj.C_G*obj.C_S*obj.C_T*obj.C_R; %Pa
            obj.r_ratchetOuter = width/2; %m
            obj.r_ratchetInner = obj.r_ratchetOuter-0.005; %m
            obj.t_ratchet = (thickness - 0.005)/2; %m
            obj.sigma_ratchetBending = NaN;
            obj.sigma_ratcheta = NaN;
            obj.sigma_ratchetm = NaN;
            obj.n_ratchet_bending = NaN;
            obj.n_ratchet_fatigue = NaN;
        end
        
        %Ratchet will fail by bending stress of the tooth.
        %Use the bending strength formula KHK Gears has on their ratchets.
        function n_bending = ratchet_bendingSF(obj, F_pawl)
            obj.sigma_ratchetBending = 6*abs(F_pawl)*(obj.r_ratchetOuter-obj.r_ratchetInner)/obj.t_ratchet/((obj.r_ratchetOuter-obj.r_ratchetInner)*tand(60-(360/1)))^2; %Pa
            obj.n_ratchet_bending = obj.ratchet_Sy/obj.sigma_ratchetBending;
            n_bending = obj.n_ratchet_bending;
        end
        
        function n_fatigue = ratchet_fatigueSF(obj, F_pawl)
            obj.sigma_ratchetBending = 6*F_pawl*(obj.r_ratchetOuter-obj.r_ratchetInner)/obj.t_ratchet/((obj.r_ratchetOuter-obj.r_ratchetInner)*tand(60-(360/1)))^2; %Pa
            obj.sigma_ratcheta = obj.sigma_ratchetBending/2; %Pa
            obj.sigma_ratchetm = obj.sigma_ratchetBending/2; %Pa
            obj.n_ratchet_fatigue = ((obj.sigma_ratcheta/obj.ratchet_Sn)+(obj.sigma_ratchetm/obj.ratchet_Su))^(-1);
            %Modified Goodman
            n_fatigue = obj.n_ratchet_fatigue;
        end
    end
end