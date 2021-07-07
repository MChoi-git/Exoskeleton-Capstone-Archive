%Hip Abduc/Adduc Shaft Stopper
%Input: Material Props, stopper forces, part dimensions in metres
%Output: Safety factors
%Written by: Sharon Tam
%Last update: October 25, 2019

classdef HipStopper < handle
    properties
        %Material Properties%
        stopper_density;
        stopper_Su;
        stopper_Sy;
        stopper_Ssy;
        stopper_Sn;
        stopper_SnPrime;

        %Dimensions and Properties%
        l_stopper;
        w_stopper;
        t_stopper;
        r_stopperOuter;
        r_stopperInner;
        m_stopper;
        
        %Forces%
        F_pinStopper;
        
        %Stress%
        tau_stopperMax;
        sigma_stopper;
        sigmaea_stopper;
        sigmaem_stopper;
        
        %Safety Factors%
        n_stopperShear;
        n_stopperBending;
        n_stopperFatigue;
        
        %Constants%
        C_L;
        C_G;
        C_S;
        C_T;
        C_R;
    end
    
    methods
        function obj = HipStopper(density, mat_Sy, mat_Su, l_stopper, w_stopper, t_stopper, r_outer, r_inner) 
            %Intialization of all variables
            obj.stopper_density = density; %kg/m^3
            obj.stopper_Su = mat_Su; %Pa
            obj.stopper_Sy = mat_Sy; %Pa
            obj.stopper_Ssy = 0.5*mat_Sy;
            obj.stopper_SnPrime = 0.5*mat_Su;
            obj.stopper_Sn = NaN;
            obj.l_stopper = l_stopper; %length of the stopper arm
            obj.w_stopper = w_stopper;
            obj.t_stopper = t_stopper;
            obj.r_stopperOuter = r_outer;
            obj.r_stopperInner = r_inner;
            obj.m_stopper = density*((pi*(r_outer^2-r_inner^2)*t_stopper)+(l_stopper*w_stopper*t_stopper));
            obj.F_pinStopper = NaN;
            obj.tau_stopperMax = NaN;
            obj.sigma_stopper = NaN;
            obj.sigmaea_stopper = NaN;
            obj.sigmaem_stopper = NaN;
            obj.n_stopperShear = NaN;
            obj.n_stopperBending = NaN;
            obj.n_stopperFatigue = NaN;
            obj.C_L = 1.0; %bending load
            obj.C_G = 0.9;
            obj.C_S = 0.53; %machined surface finish, determine from fig 8.13 p323 in Juvinall and Marshek
            obj.C_T = 1; %room temp.
            obj.C_R = 0.814; %99% reliability
        end
        
        %Stopper will fail in shear, bending, or fatigue
        function n_stress = hipStopper_shearSF(obj, r_stopperShaft, alpha_stopper)
            obj.F_pinStopper = obj.m_stopper*r_stopperShaft^2*alpha_stopper^2; 
            obj.tau_stopperMax = obj.F_pinStopper/(obj.w_stopper*obj.t_stopper);
            obj.n_stopperShear = obj.stopper_Ssy/obj.tau_stopperMax;
           
            obj.F_pinStopper = obj.m_stopper*r_stopperShaft^2*alpha_stopper^2; 
            Mmax = abs(obj.F_pinStopper)*obj.l_stopper/2; %confirm with Jen where along the stopper arm it hits the pin
            obj.sigma_stopper = Mmax*(obj.w_stopper/2)/(obj.w_stopper*obj.t_stopper^3/12);
            obj.n_stopperBending = obj.stopper_Sy/obj.sigma_stopper;
            %Distortion energy theory
            n_stress = min([obj.n_stopperShear obj.n_stopperBending]);
        end
        
        function n_fatigue = hipStopper_fatigueSF(obj,  r_stopperShaft, alpha_stopper)
            obj.F_pinStopper = obj.m_stopper*r_stopperShaft^2*alpha_stopper^2; 
            Mmax = abs(obj.F_pinStopper)*obj.l_stopper/2;
            obj.sigma_stopper = Mmax*(obj.w_stopper/2)/(obj.w_stopper*obj.t_stopper^3/12);
            sigmaea = obj.sigma_stopper/2;
            sigmaem = obj.sigma_stopper/2;
            obj.stopper_Sn = obj.stopper_SnPrime*obj.C_L*obj.C_G*obj.C_S*obj.C_T*obj.C_R; %Pa
            obj.n_stopperFatigue = ((sigmaea/obj.stopper_Sn)+(sigmaem/obj.stopper_Su))^(-1);
            %Modified Goodman
            n_fatigue = obj.n_stopperFatigue;
        end
    end
end