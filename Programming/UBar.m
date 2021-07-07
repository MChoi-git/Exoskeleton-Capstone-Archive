% Ubar Written By: Megan
% Date last modified: 2019-10-17

classdef UBar < handle
    properties 
        %Material Data%
        Ubar_density;
        Ubar_UTS;
        Ubar_YS;
        Ubar_SS;
        Ubar_E;
        
        %Dimensions%
        Ubar_m;
        Ubar_L_nominal;
        Ubar_W_nominal;
        Ubar_T_nominal; %of the sheet metal
        Ubar_hole_D;
        Ubar_T_bottom; %the bottom of the upart in the Z direction
        Ubar_COM=NaN(1,3); %Reference on the right, bottom, front corner
        Ubar_V;
        Ubar_Iz;
        
        %Forces and Moments%
        %outputs%
        F_Ubar_x;
        F_Ubar_y;
        M_Ubar;
        W_Ubar;
        %inputs...maybe%
        F_cf_x;
        F_cf_y;
        F_LS_x;
        F_LS_y;
        
        %Stresses%
        sigma_y;

        %Shear stress%
        tau;
        
        %Stress Concentration%
        Kt; %we might need to digitize graphs to find this 
        
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
        function obj = UBar(HEIGHT, Ubar_density, Ubar_UTS, Ubar_YS, Ubar_T_nominal, Ubar_W_nominal, Ubar_hole_D, Ubar_E)%Initialize this guy 
           
           obj.Ubar_UTS = Ubar_UTS;
           obj.Ubar_YS = Ubar_YS;
           obj.Ubar_density = Ubar_density;
           obj.Ubar_W_nominal = Ubar_W_nominal;
           obj.Ubar_T_nominal = Ubar_T_nominal;
           obj.Ubar_T_bottom = ((HEIGHT/100)*0.055) + 0.002 + (2*obj.Ubar_T_nominal);
           obj.Ubar_hole_D = Ubar_hole_D;
           obj.Ubar_L_nominal = (0.039*HEIGHT/100) + Ubar_T_nominal+ (0.5*Ubar_hole_D)+0.005;
           obj.Ubar_V = 2*((Ubar_T_nominal*(obj.Ubar_L_nominal-obj.Ubar_T_nominal)*obj.Ubar_W_nominal)-(pi*((Ubar_hole_D/2)^2)*Ubar_T_nominal))+(obj.Ubar_T_bottom*Ubar_T_nominal*Ubar_W_nominal);
           obj.Ubar_m = obj.Ubar_V * Ubar_density;
           obj.Ubar_E = Ubar_E;
           
           %Calculate masses to calculate Moment of Interia
           m_plate_with_hole = Ubar_T_nominal*(obj.Ubar_L_nominal-obj.Ubar_T_nominal)*obj.Ubar_W_nominal*Ubar_density;
           m_hole = pi*((Ubar_hole_D/2)^2)*Ubar_T_nominal*Ubar_density;
           m_bottom = obj.Ubar_T_bottom*Ubar_T_nominal*Ubar_W_nominal*Ubar_density;
           
           %Back to initializing
           obj.Ubar_Iz = 2*((m_plate_with_hole/12)*((obj.Ubar_W_nominal)^2 + (obj.Ubar_L_nominal-obj.Ubar_T_nominal)^2)-(m_hole*(Ubar_hole_D^2)/8))+((m_bottom/12)*((Ubar_W_nominal^2)+(obj.Ubar_T_nominal^2)));
           
           %Calculating stuff for COM
           area_1 = (obj.Ubar_L_nominal - (2*obj.Ubar_T_nominal) - obj.Ubar_hole_D)*obj.Ubar_W_nominal;
           area_2 = ((2*obj.Ubar_T_nominal) + obj.Ubar_hole_D)*obj.Ubar_W_nominal;
           
           %Back to initializing again
           obj.Ubar_COM(1,2) = ((((obj.Ubar_L_nominal - (2*obj.Ubar_T_nominal) - obj.Ubar_hole_D)/2)*area_1) + (((obj.Ubar_L_nominal + obj.Ubar_T_nominal) + (obj.Ubar_hole_D/2))*area_2))/(area_1+area_2);
           obj.Ubar_COM(1,1) = obj.Ubar_W_nominal/2;
           obj.Ubar_COM(1,3) = ((2*obj.Ubar_T_nominal)+obj.Ubar_T_bottom)/2;
           obj.F_Ubar_x = NaN;
           obj.F_Ubar_y = NaN;
           obj.W_Ubar = NaN;
           obj.F_cf_x = NaN;
           obj.F_cf_y = NaN;
           obj.F_LS_x = NaN;
           obj.F_LS_y = NaN;
           obj.tau = NaN;
           obj.Kt = NaN; 
           obj.sigma_1 = NaN;
           obj.sigma_2 = NaN;
           obj.tau_1 = NaN;
           obj.sigma_e = NaN;
           obj.n_DE = NaN;
           obj.S_cr = NaN;
           obj.n_buckling
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
        function F_cf_x = getF_cf_x(obj, a_x, F_LS_x) %Calculate forces in the X to find acceleration in the X
            %input values to the object%
            obj.F_Ubar_x = obj.Ubar_m * a_x;
            obj.F_LS_x = F_LS_x;
            
            %Sum of forces = m*a%
            obj.F_cf_x = obj.F_Ubar_x + obj.F_LS_x;
            F_cf_x = obj.F_cf_x;
            
        end
        
        function F_cf_y = getF_cf_y(obj, a_y, F_LS_y) %Calculate forces in Y to find acceleration in the Y
            %input values to the object%
            obj.F_Ubar_y = a_y*obj.Ubar_m;
            obj.F_LS_y = F_LS_y;
            
            %Sum of forces = m*a%
            obj.F_cf_y = obj.F_Ubar_y - obj.F_LS_y +(obj.Ubar_m * 9.81);
            F_cf_y = obj.F_cf_y;
            
        end
        

        function n_stress = calcn_stress(obj, Kt,F_cf_x,F_cf_y,F_LS_x)
            %Find Stress and Strain%
            obj.Kt = Kt;
            obj.sigma_y = obj.Kt*(abs(F_cf_y)/(obj.Ubar_W_nominal*obj.Ubar_T_nominal));
            if F_cf_x > F_LS_x
                obj.tau = abs(F_cf_x)/(obj.Ubar_W_nominal*obj.Ubar_T_nominal);
            else 
                obj.tau = (F_LS_x)/(obj.Ubar_W_nominal*obj.Ubar_T_nominal);
            end
            %Mohr's Circle%
            obj.sigma_1 = (obj.sigma_y/2) + sqrt((obj.tau^2)+((obj.sigma_y/2))^2);
            obj.sigma_2 = (obj.sigma_y/2) - sqrt((obj.tau^2)+((obj.sigma_y/2))^2);
            obj.tau_1 = sqrt((obj.tau^2)+((obj.sigma_y/2)^2));
            %Von Mises%
            obj.sigma_e = sqrt((obj.sigma_1^2)-(obj.sigma_1*obj.sigma_2)+(obj.sigma_2^2));
            %Distortion Energy%
            obj.n_DE = obj.Ubar_YS/obj.sigma_e;
            
        
            obj.S_cr = ((pi^2)*(obj.Ubar_E))/((0.707*(obj.Ubar_L_nominal-obj.Ubar_T_nominal-obj.Ubar_hole_D)/obj.Ubar_density)^2);
            
            obj.n_buckling = obj.S_cr/obj.sigma_y;
            
            n_stress = min([obj.n_buckling obj.n_DE]);
        end
        
        function n_MG = Ubar_Fatigue(obj, F_cf_y_max,F_cf_y_min,Cs, q)
            obj.sigma_max_fatigue = F_cf_y_max/(obj.Ubar_W_nominal*obj.Ubar_T_nominal);
            obj.sigma_min_fatigue = F_cf_y_min/(obj.Ubar_W_nominal*obj.Ubar_T_nominal);
            obj.Kf = 1+q*(obj.Kt-1);
            obj.sigma_m = obj.Kf*(obj.sigma_max_fatigue + obj.sigma_min_fatigue)/2; 
            obj.sigma_a = obj.Kf*(obj.sigma_max_fatigue - obj.sigma_min_fatigue)/2; 
            
            obj.S_n_prime = 0.5*obj.Ubar_UTS;
            Cl = 1;
            Cg = 1;
            Ct = 1;
            Cr = 0.814;
            obj.S_n = obj.S_n_prime*Cl*Cg*Ct*Cr*Cs;
            
            obj.n_MG = 1/((obj.sigma_a/obj.S_n)+(obj.sigma_m/obj.Ubar_UTS));
            
            n_MG = obj.n_MG;
            
        end
        
    end
end