%Pawl Spring
%Input: Material Props, displacement of pawl bc of string pulling, distance
%between pawl pin and string hole, distance between pawl pin and spring
%location
%Output: Safety factors
%Written by: Sharon Tam
%Last update: October 19, 2019

classdef PawlSpring < handle
    properties 
        %Material Properties%
        spring_Su;
        spring_Ssu;
        spring_Ssy;
        spring_SsMax;

        %Dimensions and Properties%
        %True max load = 1.904N, min loaded height = 3mm
        k_spring;
        x_spring;
        d_wire;
        d_coil;
        l_spring;
        
        %Forces%
        F_spring;
        
        %Stresses%
        tau_spring;
        tau_springa;
        tau_springm;
        
        %Safety Factors%
        n_spring_shear;
        n_spring_fatigue;
        
        %Constants%
        C_spring;
        KB_spring;      
        
        d_pawl2string
        d_pawl2spring
    end
    
    methods                                   %need to make function to calculate x_string
        function obj = PawlSpring(mat_Su, d_pawl2string, d_pawl2spring) 
            %Intialization of all variables
            obj.d_pawl2string = d_pawl2string;
            obj.d_pawl2spring = d_pawl2spring;
            obj.spring_Su = mat_Su; %Pa
            obj.spring_Ssu = 0.8*mat_Su; %Pa
            obj.spring_Ssy = 0.53*mat_Su; %Pa
            obj.spring_SsMax = 0.43*mat_Su; %Pa - Juvinall Marshek Fig 12.15
            obj.k_spring = 73; %N/m
             %m
            obj.d_wire = 0.0003; %m
            obj.d_coil = 0.004; %m
            obj.l_spring = 0.010;
            obj.F_spring = NaN;
            obj.C_spring = NaN;
            obj.KB_spring = NaN;
            obj.tau_spring = NaN;
            obj.tau_springa = NaN;
            obj.tau_springm = NaN;
            obj.n_spring_shear = NaN;
            obj.n_spring_fatigue = NaN;
        end
        
        function Fspring = getF_spring(obj,xspring)
            %Assume mass of the spring is negligible so this can be 
            %analysed as a static case.
            obj.F_spring = obj.k_spring*xspring; %N
            Fspring = obj.F_spring;
        end
        function xspring = setXSpring(obj,x_string)
            obj.x_spring = x_string/obj.d_pawl2string*obj.d_pawl2spring;
            xspring = obj.x_spring;
        end
        
        function n_shear = pawlSpring_shearSF(obj,F_spring)
            obj.C_spring = obj.d_coil/obj.d_wire;
            obj.KB_spring = (4*obj.C_spring+2)/(4*obj.C_spring-3);
            obj.tau_spring = obj.KB_spring*8*abs(F_spring)*obj.d_coil/pi/obj.d_wire^3; %Pa
            obj.n_spring_shear = obj.spring_Ssy/obj.tau_spring;
            n_shear = obj.n_spring_shear;
        end
        
        function n_fatigue = pawlSpring_fatigueSF(obj, F_spring_Max)
            obj.C_spring = obj.d_coil/obj.d_wire;
            obj.KB_spring = (4*obj.C_spring+2)/(4*obj.C_spring-3);
            obj.tau_spring = obj.KB_spring*8*abs(F_spring_Max)*obj.d_coil/pi/obj.d_wire^3; %Pa
            obj.tau_springa = obj.tau_spring/2; %Pa
            obj.tau_springm = obj.tau_spring/2; %Pa
            obj.n_spring_fatigue = ((obj.tau_springa/obj.spring_SsMax)+(obj.tau_springm/obj.spring_Ssu))^(-1);
            %Modified Goodman
            n_fatigue = obj.n_spring_fatigue;
        end
    end
end