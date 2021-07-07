%Hip Spring
%Input: Material Props, forces on the spring, spring dimensions
%Output: Safety factors
%Written by: Sharon Tam
%Last update: October 24, 2019

classdef HipSpring < handle
    properties
        %Material Properties%
        spring_Su;
        spring_Ssa;
        spring_Sn;

        %Dimensions and Properties%
        d_wire;
        d_coil;
        
        %Forces%
        F_plunger;
        
        %Stresses%
        tau_spring;
        tau_springa;
        
        %Safety Factors%
        n_spring_shear;
        n_spring_fatigue;
        
        %Constants%
        C_spring;
        KW_spring;        
    end
    
    methods
        function obj = HipSpring(mat_Su, D_wire, D_coil) 
            %Intialization of all variables
            obj.spring_Su = mat_Su; %Pa, table 
            obj.spring_Ssa = 396448500; %Pa
            obj.spring_Sn = 0.29*mat_Su; %Pa - Juvinall Marshek Fig 12.15
            obj.d_wire = D_wire; %m
            obj.d_coil = D_coil; %m
            obj.F_plunger = NaN;
            obj.C_spring = NaN;
            obj.KW_spring = NaN;
            obj.tau_spring = NaN;
            obj.tau_springa = NaN;
            obj.n_spring_shear = NaN;
            obj.n_spring_fatigue = NaN;
        end
        
        function n_shear = hipSpring_shearSF(obj, F_plunger)
            obj.F_plunger = F_plunger;
            obj.C_spring = obj.d_coil/obj.d_wire;
            obj.KW_spring = ((4*obj.C_spring-1)/(4*obj.C_spring-4)) + 0.615/obj.C_spring;
            obj.tau_spring = obj.KW_spring*obj.C_spring*8*obj.F_plunger/pi/obj.d_wire^2; %Pa
            obj.n_spring_shear = obj.spring_Sn/obj.tau_spring;
            n_shear = obj.n_spring_shear;
        end
        
        function n_fatigue = hipSpring_fatigueSF(obj, F_plunger)
            obj.C_spring = obj.d_coil/obj.d_wire;
            obj.KW_spring = ((4*obj.C_spring-1)/(4*obj.C_spring-4)) + 0.615/obj.C_spring;
            obj.tau_spring = obj.KW_spring*obj.C_spring*8*F_plunger/pi/obj.d_wire^2; %Pa
            obj.tau_springa = obj.tau_spring; %Pa
            obj.n_spring_fatigue = obj.spring_Ssa/obj.tau_springa;
            %Modified Goodman
            n_fatigue = obj.n_spring_fatigue;
        end
    end
end