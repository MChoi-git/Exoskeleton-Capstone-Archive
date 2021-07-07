%Hip Flex/Ex Shaft Bearing
%Input: Bearing forces, life required, capacity of selected bearing
%Output: Safety factor
%Written by: Sharon Tam
%Last update: October 24, 2019

classdef HipFlexExBearing < handle
    properties
        %Bearing Properties%
        C_selected;
        C_required;

        %Forces%
        F_r;
        
        %Safety Factor%
        n_bearingCap;
        
        %Constants%
        Ka;
        Kr;
        Lr;
        L;
    end
    
    methods
        function obj = HipFlexExBearing(C_selected) 
            obj.C_selected = C_selected;
            obj.C_required = NaN;
            obj.F_r = NaN;
            obj.Ka = 1.35; %light impact
            obj.Kr = 0.21; %99% reliability
            obj.Lr = 90*10^6;
            obj.L = 14*10^3 * 120 * 60; %Life = operating hours*max cadence (cadence is the cycle freq)*converting cadence from /min to/hr
            obj.n_bearingCap = NaN;
        end
        
        function n_capacity =  hipFlexExBearing_SF(obj, F_bearing_y)
            obj.F_r = abs(F_bearing_y);
            obj.C_required = obj.F_r*obj.Ka*(obj.L/(obj.Kr*obj.Lr))^0.3;
            obj.n_bearingCap = obj.C_selected/obj.C_required;
            n_capacity = obj.n_bearingCap;
        end
    end
end