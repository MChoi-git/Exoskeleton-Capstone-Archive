%Analysis of screws holding telescoping portions of thigh and shank
classdef ThighShankScrew < handle
    properties
        %Bolt Dimensions
        screw_D               %body diameter
        screw_A_shear         %Cross-section of shear area
        
        %Member Dimensions
        member_length
        member_t_min          %Thickness of thinnest member
        
        qty                   %Number of screws in member
        
        %Material Properties
        screw_Sy_bolt         %alloy steel
        screw_Sy_member       %titanium
        screw_Ssy_member

        %Forces & Stresses
        screw_shear_avg
        screw_bearing_stress
        screw_rupture_stress
        
        %Safety factors
        n_pureShear           %Safety factor from distortion theory
        n_rupture             %Rupture of thinnest plate
        n_bearing_bolt        %Bearing on the bolt
        n_bearing_member      %Bearing on the member
    end
    
    methods
        %Constructor
        %Parameters: screw diameter, member length, min thickness of members, number of screws 
        %Return: none
        function obj = ThighShankScrew(screw_D, LS_memberlength, t_min, qty)
            obj.screw_D = screw_D;
            obj.screw_A_shear = (pi*(obj.screw_D^2))/4;
            
            obj.member_length = LS_memberlength;
            obj.member_t_min = t_min;
            obj.qty = qty;

            obj.screw_Sy_bolt = 415000000;
            obj.screw_Sy_member = 500000000;
            obj.screw_Ssy_member = 0.577*obj.screw_Sy_member;
        end
        
        %Calculate and store screw forces
        %Parameters: ThighShankScrew Object, maximum vertical force in
        %current situation
        %Return: none
        function sf = calcSF(obj, F_applied)
            %Calculate and store shear stress, bearing stress and rupture stress on screw
            obj.screw_shear_avg = abs(F_applied)/(obj.screw_A_shear);
            
            obj.screw_bearing_stress = abs(F_applied)/(obj.qty*obj.member_t_min*obj.screw_D);
            obj.screw_rupture_stress = abs(F_applied)/(obj.member_t_min*(obj.member_length - (obj.screw_D*obj.qty)));
            
            %Calculate and store safety factors        
            obj.n_pureShear = obj.screw_Ssy_member/obj.screw_shear_avg;
            obj.n_rupture = obj.screw_Sy_member/obj.screw_rupture_stress;
            obj.n_bearing_bolt = obj.screw_Sy_bolt/obj.screw_bearing_stress;
            obj.n_bearing_member = obj.screw_Sy_member/obj.screw_bearing_stress;
            %sf = min([obj.n_pureShear,obj.n_rupture,obj.n_bearing_bolt,obj.n_bearing_member]);
%             sf = obj.n_pureShear;
%             sf = obj.n_rupture;
%             sf = obj.n_bearing_bolt;
            sf = obj.n_bearing_member;
        end
    end
end