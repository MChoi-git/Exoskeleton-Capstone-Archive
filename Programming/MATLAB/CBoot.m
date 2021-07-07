% CBoot Written By: Megan
% Date last modified: 2019-10-18

classdef CBoot < handle
    properties 
        %Material Data%
        CBoot_density;
        CBoot_UTS;
        CBoot_YS;
        CBoot_SS;
        CBoot_E;
        
        %Dimensions%
        CBoot_m;
        CBoot_L_nominal;
        CBoot_W_nominal;
        CBoot_T_nominal; %in the z
        CBoot_L_shoe;
        CBoot_W_shoe;
        CBoot_T_shoe;
        CBoot_L_Ubar;
        CBoot_W_Ubar;
        length2;
        CBoot_COM = NaN(1,3); %Reference on the right, bottom, front corner
        CBoot_V;
        CBoot_Iz;
        
        %Forces and Moments%
        %outputs%
        F_CBoot_x;
        F_CBoot_y;
        M_CBoot;
        W_CBoot;
        %inputs.p-]=p..maybe%
        F_cf_x;
        F_cf_y;
        GRF_v;
        GRF_fa;
        GRF_vexo;
        
        
        %Stresses%
        sigma_y;

        %transverse shear stress%
        tau_yx;
        tau_xy;
        
        %Stress Concentration%
         %we might need to digitize graphs to find this 
        
        %Mohrs Circle%
        sigma_1;
        sigma_2;
        tau_1;
        
        %Distortion Energy Variables%
        sigma_e;
        n_DE;
        
        %Buckling%
        S_cr;
        n_buckling;
        
        %Fatigue%
        %Fatigue stress concentration
        Kf;
        
        %inputs
        sigma_max_fatigue;
        sigma_min_fatigue;
        sigma_m;
        sigma_a;
        S_n_prime;
        %output
        S_n;

        %Modified Goodman
        n_MG;
    end
    
    methods
        function obj = CBoot(HEIGHT, CBoot_density, CBoot_UTS, CBoot_YS, Ubarobj, length2)%Initialize this guy 
           obj.CBoot_UTS = CBoot_UTS;
           obj.CBoot_YS = CBoot_YS;
           obj.CBoot_density = CBoot_density;
           
           obj.CBoot_L_Ubar = Ubarobj.Ubar_T_nominal + 0.002;
           obj.CBoot_T_nominal = (0.055*HEIGHT)+0.021;
           obj.CBoot_W_nominal = (0.152*HEIGHT)+0.043;
           obj.CBoot_L_shoe = 0.0035;
           obj.length2 = length2;
           obj.CBoot_L_nominal = obj.CBoot_L_shoe +length2 + obj.CBoot_L_Ubar;
           obj.CBoot_W_shoe =(0.152*HEIGHT)+0.033;
           obj.CBoot_T_shoe = Ubarobj.Ubar_T_bottom + 0.002;
           obj.CBoot_W_Ubar = Ubarobj.Ubar_W_nominal + 0.002;
           obj.CBoot_V = obj.CBoot_L_nominal*obj.CBoot_W_nominal*obj.CBoot_T_nominal - (obj.CBoot_L_shoe*obj.CBoot_W_shoe*obj.CBoot_T_shoe)-(obj.CBoot_L_Ubar*obj.CBoot_W_Ubar*obj.CBoot_T_shoe);
           obj.CBoot_m = obj.CBoot_V * CBoot_density;
           
           %Calculate masses to calculate Moment of Interia
           m_no_cut = obj.CBoot_T_nominal*obj.CBoot_L_nominal*obj.CBoot_W_nominal*CBoot_density;
           m_shoe = obj.CBoot_L_shoe*obj.CBoot_W_shoe*obj.CBoot_T_shoe*CBoot_density;
           m_Ubar = obj.CBoot_L_Ubar*obj.CBoot_W_Ubar*obj.CBoot_T_shoe*CBoot_density;
           
           %Back to initializing
           obj.CBoot_Iz = ((m_no_cut/12)*((obj.CBoot_W_nominal)^2 + (obj.CBoot_L_nominal)^2))-((m_shoe/12)*((obj.CBoot_W_shoe)^2 +...
               (obj.CBoot_L_shoe)^2))+((m_Ubar/12)*((obj.CBoot_W_Ubar^2)+(obj.CBoot_L_Ubar^2)));
           
           %Calculating stuff for COM
           area_1 = 0.8*obj.CBoot_L_nominal;
           area_2 = obj.CBoot_L_shoe*0.5;
           
           %Back to initializing again
           obj.CBoot_COM(1,2) = ((area_1*0.4)+(2*area_2*(0.8+.25)))/(area_1+area_2);
           obj.CBoot_COM(1,1) = obj.CBoot_W_nominal/2;
           obj.CBoot_COM(1,3) = obj.CBoot_T_nominal/2;
           obj.F_CBoot_x = NaN;
           obj.F_CBoot_y = NaN;
           obj.M_CBoot = NaN;
           obj.W_CBoot = NaN;
           obj.F_cf_x = NaN;
           obj.F_cf_y = NaN;
           obj.GRF_v = NaN;
           obj.GRF_fa = NaN;
           obj.GRF_vexo = NaN;
           obj.sigma_y = NaN;
           obj.tau_yx = NaN;
           obj.tau_xy = NaN;
            %we might need to digitize graphs to find this
           obj.sigma_1 = NaN;
           obj.sigma_2 = NaN;
           obj.tau_1 = NaN;
           obj.sigma_e = NaN;
           obj.n_DE = NaN;
           obj.S_cr = NaN;
           obj.n_buckling = NaN;
           obj.Kf = NaN;
           obj.sigma_max_fatigue = NaN;
           obj.sigma_min_fatigue = NaN;
           obj.sigma_m = NaN;
           obj.sigma_a = NaN;
           obj.S_n_prime = NaN;
           obj.S_n = NaN;
           obj.n_MG = NaN;
        end
        
        %Calculate the Forces and Moments%
        function GRF_fa = getGRF_fa(obj, a_x, F_cf_x,frame) %Calculate forces in the X to find acceleration in the X
            %input values to the object%
            obj.F_CBoot_x = obj.CBoot_m * a_x;
            obj.F_cf_x = F_cf_x;
            if (frame >42 && frame <=70)
                obj.GRF_fa = 0;
                GRF_fa = obj.GRF_fa;
            else
                obj.GRF_fa = obj.F_CBoot_x + obj.F_cf_x;
                GRF_fa = obj.GRF_fa;
            end
            
        end
        
        function GRF_v = getGRF_v(obj, a_y, F_cf_y, MASS,frame) %Calculate forces in Y to find acceleration in the Y
            if (frame >42 && frame <=70)
                obj.GRF_v = 0;
                GRF_v = obj.GRF_v;
            else
                obj.GRF_v = obj.CBoot_m*a_y + F_cf_y + (MASS)*9.81 + obj.CBoot_m*9.81;
                GRF_v = obj.GRF_v;
            end
           
        end
        
        function GRF_vexo = getGRF_vEXO(obj, a_y, F_cf_y,frame) %Calculate forces in Y to find acceleration in the Y
            if (frame >42 && frame <=70)
                obj.GRF_vexo = 0;
                GRF_vexo = obj.GRF_vexo;
            else
                obj.GRF_vexo = obj.CBoot_m*a_y + F_cf_y  + obj.CBoot_m*9.81;
                GRF_vexo = obj.GRF_vexo;
            end
           
        end

        function n_DE = CBoot_distortionNRG(obj, MASS,GRF_v,GRF_fa,F_cf_y)
            %Find Stress and Strain%
            body_wgt = (MASS+50)*9.81;
            holder = [GRF_v body_wgt];
            P = max(holder);
            obj.sigma_y = (P/(obj.CBoot_W_nominal*obj.CBoot_T_shoe));
            
            shoe_wgt = obj.CBoot_m*9.81;
            holder = [abs(F_cf_y) abs(shoe_wgt) abs((GRF_v-body_wgt))];
            V1 = max(holder);
            %The way of doing this is pretty overkill but can re-evaluate
            %if it fails 
            obj.tau_xy = ((3/2)*(V1))/((obj.CBoot_L_nominal-obj.CBoot_L_shoe)*obj.CBoot_T_shoe);
            %Based on transverse shear diagram%
            obj.tau_yx = abs(((3/2)*(0.5*abs(GRF_fa)))/(obj.CBoot_W_nominal*obj.CBoot_T_nominal));
            
            %Mohr's Circle%
            holder = [obj.tau_yx obj.tau_xy];
            tau = max(holder);
            %Von Mises%
            obj.sigma_e = sqrt(-obj.sigma_y+(obj.sigma_y^2)+(3*(tau^2)));
            %Distortion Energy%
            obj.n_DE = obj.CBoot_YS/obj.sigma_e;
            n_DE = obj.n_DE;
        end
        
        function n_MG = CBoot_Fatigue(obj, Cs, GRF_v_Fmax)
            obj.sigma_max_fatigue = GRF_v_Fmax/(obj.CBoot_W_shoe*obj.CBoot_T_shoe);
            obj.sigma_min_fatigue = 0/(obj.CBoot_W_shoe*obj.CBoot_T_shoe);
            obj.sigma_m = (obj.sigma_max_fatigue + obj.sigma_min_fatigue)/2; 
            obj.sigma_a = (obj.sigma_max_fatigue - obj.sigma_min_fatigue)/2; 
            
            obj.S_n_prime = 0.5*obj.CBoot_UTS;
            Cl = 1;
            Cg = 1;
            Ct = 1;
            Cr = 0.814;
            obj.S_n = obj.S_n_prime*Cl*Cg*Ct*Cr*Cs;
            
            obj.n_MG = 1/((obj.sigma_a/obj.S_n)+(obj.sigma_m/obj.CBoot_UTS));
            
            n_MG = obj.n_MG;
            
        end
        
    end
end