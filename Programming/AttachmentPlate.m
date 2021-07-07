classdef AttachmentPlate<handle
    
    
    properties
        yield_Strength;
        
        force_CasingScrewX;
        force_CasingScrewY;
        
        shear_AttachmentPlate;
        
        %Dimensions%
        t_attachmentPlate;
        d_casingScrew;
        theta;
        r_OD;
        h_plate;
        
        %Forces%
        W_plungerCasing;
        F_wall;
        
        %Stress%
        sigma_ruptureCasingScrew;
        
        %Safety Factor%
        n_attachPlate;
    end
    
    methods
        function obj = AttachmentPlate(ys,t_attPlate,d_casingScrew,R_outer,h_plate)
            obj.yield_Strength = ys;
            
            obj.force_CasingScrewX = NaN;
            obj.force_CasingScrewY = NaN;
            
            obj.shear_AttachmentPlate;
            
            obj.t_attachmentPlate = t_attPlate; %m
            obj.d_casingScrew = d_casingScrew; %m
            obj.theta = NaN;
            obj.r_OD = R_outer; %m
            obj.h_plate = h_plate; %m
            obj.W_plungerCasing = NaN;
            obj.F_wall = NaN;
            obj.sigma_ruptureCasingScrew = NaN;
            obj.n_attachPlate = NaN;
            obj.shear_AttachmentPlate;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Failure Analysis%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function out = calculateShearAttachmentPlate(obj,weightplungercasing,forcewall,theta)
            obj.shear_AttachmentPlate = (weightplungercasing - (forcewall*dsin(theta)))/(pi*obj.d_casingScrew^2);
            out = obj.shear_AttachmentPlate;
        end
        function n_attachment = hipAttachPlate_ruptureSF(obj, W_plungerCasing, F_wall, theta)
            obj.theta = theta; %degrees
            obj.W_plungerCasing = W_plungerCasing; %N
            obj.F_wall = F_wall; %N
            obj.sigma_ruptureCasingScrew = abs((W_plungerCasing-(F_wall*sind(theta))))/(obj.t_attachmentPlate*(sqrt(obj.h_plate*((2*obj.r_OD)-obj.h_plate))-obj.d_casingScrew)); %Pa
            obj.n_attachPlate = obj.yield_Strength/obj.sigma_ruptureCasingScrew;
            n_attachment = obj.n_attachPlate;
        end
    end
end

