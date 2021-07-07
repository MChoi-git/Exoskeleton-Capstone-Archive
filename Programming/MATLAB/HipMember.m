classdef HipMember < handle
    %Hip member 1, written by Matt and Megan.
    properties
        hipMember_Weight;
        hipMember_RadiusGS2_L1;
        hipMember_RadiusHinge_L1;
        hipMember_RadiusGS1_L1;
        hipMember_RadiusL2_L1;
        
        hipMember_T; %of sheet metal
        hipMember_L_Small; %not total length just the length of the wider part on the bottom
        YS;
        n_stress;
        
        force_Load1;
        force_Load2;
        CORabd;
        width1;
    end
    
    methods
        function obj = HipMember(density, hipMember_T, height1, height2, width2, bearingD, heightUser, YS)
            obj.CORabd = (0.191*heightUser)/200;
            obj.width1 = ((0.191*heightUser)/100) + 0.0658;
            volume = ((obj.width1*height1)+(height2*width2))*hipMember_T - 2*(pi*((bearingD/2)^2)*0.015);
            obj.hipMember_Weight = density*volume*9.81; 
            obj.hipMember_RadiusGS2_L1 = obj.CORabd-0.088;
            obj.hipMember_RadiusHinge_L1 = obj.width1/2;
            obj.hipMember_RadiusGS1_L1 = obj.CORabd+0.088;
            obj.hipMember_RadiusL2_L1 = 2*obj.CORabd;
            
            obj.force_Load1 = NaN;
            obj.force_Load2 = NaN;
            
            obj.hipMember_T = hipMember_T;
            obj.hipMember_L_Small = height1; 
            obj.YS=YS;
            obj.n_stress = NaN;
            
        end
        
        function [fl1,fl2] = calculateForceLoads(obj,forceGS1,forceGS2)
            obj.force_Load2 = ((forceGS2*obj.hipMember_RadiusGS2_L1)+...
                (forceGS1*obj.hipMember_RadiusGS1_L1)+((obj.hipMember_Weight)*...
                obj.hipMember_RadiusHinge_L1))/obj.hipMember_RadiusL2_L1;
            obj.force_Load1 = obj.hipMember_Weight-obj.force_Load2+forceGS1+forceGS2;
            fl1 = obj.force_Load1;
            fl2 = obj.force_Load2;
        end
        
        %Calculate minimum safety factor
        %Parameters: HipMember Object
        %Return: minimum safety factor
        function n_stress = getn_stress(obj,force_Load1,force_Load2)
            holder = [force_Load1 force_Load2];
            V = max(holder);
            tau = 1.5*V/(obj.hipMember_T*obj.hipMember_L_Small);
            Ssy = 0.577*obj.YS;
            obj.n_stress = Ssy/tau;
            n_stress = obj.n_stress;
        end
    end
end

