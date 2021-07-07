classdef BearingAA < handle
    properties
        %Bearing Properties%
        C_selected;
        C_required;

        %Forces%
        force_CasingAbdY;
        
        %Safety Factor%
        n_bearingCap;
        
        %Constants%
        Ka;
        Kr;
        Lr;
        L;
    end
    
    methods
        function obj = BearingAA(C_selected)
            obj.force_CasingAbdY = NaN;
            obj.C_selected = C_selected;
            obj.C_required = NaN;
            obj.Ka = 1.35;
            obj.Kr = 1; %99% reliability
            obj.Lr = 90*10^6;
            obj.L = 14*10^3 * 120 * 60; %Life = operating hours*max cadence (cadence is the cycle freq)*converting cadence from /min to/hr
            obj.n_bearingCap = NaN;
        end
        
        function out = calculateForceCasingAbdY(obj, forceBearingAbdY)
            obj.force_CasingAbdY = forceBearingAbdY;
            out = obj.force_CasingAbdY;
        end
        
        %Failure Analysis%
        function n_capacity = BearingAA_SF(obj,force_CasingAbdY)
            obj.C_required = abs(force_CasingAbdY)/1000*obj.Ka*(obj.L/(obj.Kr*obj.Lr))^0.3;
            obj.n_bearingCap = obj.C_selected/obj.C_required;
            n_capacity = obj.n_bearingCap;
        end
    end
end

