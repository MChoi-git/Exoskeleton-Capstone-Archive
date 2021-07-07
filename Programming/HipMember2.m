classdef HipMember2 < handle
   
    properties
        counterWeight_B;
        counterWeight_H;
        counterWeight_W;%define in the z direction when aligned with the global coordinate system
        counterWeight_Rho;
        counterWeight_Weight;
        
        hipMember2_Mass;
        hipMember2_Weight; 
        
        COREF;
        
        force_Hip;
        
        hipMember2_T; %thickness of sheet metal
        hipMember2_W;%nominal dimension in the y direction when aligned with the global coordinate system
        hipMember2_D_hole;
        YS;
        n_sh;
        n_bm;
        M;
        n_MG;
    end
    
    methods
        function obj = HipMember2(cb,ch,cw,crho,thickness,width,diameter,YS,waistdepth)
            obj.counterWeight_B = cb;
            obj.counterWeight_H = ch;
            obj.counterWeight_W = cw;
            obj.counterWeight_Rho = crho;
            obj.counterWeight_Weight = cb*ch*cw*crho*9.81;
            
            obj.hipMember2_Mass = (((0.1*thickness)+(0.45*thickness))*0.1 - (((diameter/2)^2)*pi))*2690; 
            obj.hipMember2_Weight = obj.hipMember2_Mass*9.81;
            
            obj.force_Hip = NaN;
            
            obj.hipMember2_T = thickness; 
            obj.hipMember2_W = width; %Defined as the height of the member
            obj.hipMember2_D_hole = diameter;
            obj.COREF = (0.6*waistdepth)+0.065;
            obj.YS = YS;
            obj.n_sh = NaN;
            obj.n_bm = NaN;
            obj.M = NaN;
        end
        
        function out = calculateForceHip(obj,forceMember2,accel_y,weightplunger,weightbearingcasing)
            obj.force_Hip = (obj.hipMember2_Mass*accel_y)+forceMember2+obj.hipMember2_Weight+...
                obj.counterWeight_Weight+(weightplunger+weightbearingcasing);
            out = obj.force_Hip;
        end
        
        %Calculate minimum safety factor for non-fatigue failure modes
        %Parameters: HipMember2 Object, forceMember2, weightplunger,weightbearingcasing, M_bearing_abd, z2, Kt
        % ~where z2 is defined on Jenns Dimensioned Drawing
        %Return: minimum safety factor
        function n_stress = getn_stress(obj, forceMember2, weightplunger,weightbearingcasing, M_bearing_abd, z2, Kt,force_Hip)
            %ASSUMPTION = weight of hip member 2 is small compared to other
            %forces so resultant moment from moving force in line with
            %others will be small
            holder = [abs(forceMember2) abs((obj.hipMember2_Mass*9.81)) abs(weightplunger) abs(weightbearingcasing)...
                abs(force_Hip) abs(obj.counterWeight_Weight)];
            V=max(holder);
            Tau = 1.5*(V/2)/(obj.hipMember2_T*obj.hipMember2_W);
            Ssy = 0.577*obj.YS;
            obj.n_sh = Ssy/Tau;
            
            holder = [abs(M_bearing_abd) abs((forceMember2*(z2-(0.5*obj.hipMember2_T))))...
                abs((obj.counterWeight_Weight*((obj.hipMember2_T*0.5)+(obj.counterWeight_W*0.5))))...
                abs(forceMember2*obj.COREF) abs(obj.counterWeight_Weight*0.273)];
            obj.M = max(holder);
            sigma = ((Kt*obj.M*(0.5*obj.hipMember2_W))/(obj.hipMember2_T*(obj.hipMember2_W^3)))/12;
            obj.n_bm = obj.YS/sigma;
            
            n_stress = min([obj.n_sh obj.n_bm]);
        end
        
        %Calculate minimum safety factor for fatigue
        %Parameters: HipMember2 Object, surface factor, q, Kt, Ultimate tensile strength, M_bearing_abd_max
        %Return: fatigue safety factor 
        function n_MG = getn_MG(obj,Cs, q, Kt, UTS, M_bearing_abd_max, M_bearing_abd_min, forceHipMax,   forceHipMin)
            M_Max = max([M_bearing_abd_max (forceHipMax*obj.COREF)]);
            M_Min = max([M_bearing_abd_min (forceHipMin*obj.COREF)]);
            sigma_max = (12*M_Max*0.5*obj.hipMember2_W)/(obj.hipMember2_T*obj.hipMember2_W^3);
            sigma_min = (12*M_Min*0.5*obj.hipMember2_W)/(obj.hipMember2_T*obj.hipMember2_W^3);
            Kf = 1+q*(Kt-1);
            sigma_m = Kf*(sigma_max+sigma_min)/2; 
            sigma_a = Kf*(sigma_max-sigma_min)/2; 
            
            S_n_prime = 0.5*UTS;
            Cl = 1;
            Cg = 0.9;
            Ct = 1;
            Cr = 0.814;
            S_n = S_n_prime*Cl*Cg*Ct*Cr*Cs;
            
            obj.n_MG = 1/((sigma_a/S_n)+(sigma_m/UTS));
            
            n_MG = obj.n_MG;
            
        end
    end
end

