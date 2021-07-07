classdef ExoShank < handle
    properties
        %Dimensions   
        A_shank            %cross-sectional area lower shank in x plane
        length_buckling
        
        L_shank             %length of whole shank (from top of circular section to bottom of ubar)
        w_shank             %width of straight bar portion
        r_shankUbar         %radius of ubar
        
        t1                 %thickness of circular section
        t2                 %thickness of sides adjacent to circular section 
        t_total
        shankUbar_innerDiameter
        
        %Material Properties
        shank_Sy
        shank_Ssy
        shank_Sn
        shank_Su
        shank_E
        
        %Mass
        m_shank
        m_shankCircleHead
        m_shankNeckBar
        m_Foam
        m_lowerShank
        m_shankUBar
        
        %Weight
        W_shank
        W_shankCircleHead
        W_shankNeckBar
        W_Foam
        W_lowerShank
        W_shankUBar
        
        %Positions
        COM_x;
        COM_y;
        
        r_knee_x;
        r_knee_y;
        r_ankle_x;
        r_ankle_y;
        r_pawlpin_y;
        
        %Moment of inertia 
        I_shank
        I_area
        
        %Moments
        M_shank
        
        %Pawl force
        F_pawlpin_x
        
        %Force of screws securing foam dampener to shank segment
        F_screwFoamS_x1
        F_screwFoamS_x2
        F_screwFoamS_y1
        F_screwFoamS_y2
        
        %Force ankle joint
        F_ankle_x
        F_ankle_y
        
        %Buckling force & stress
        F_cr_buckling
        sigma_cr_buckling       
        
        %Knee Forces
        F_knee_x
        F_knee_y
        
        %ubar
        shankUbar_height
        shankUbar_shearForce
        shankUbar_shearStress_max
        sigma1
        sigma2
        sigma_a
        sigma_m  
        
        Kt
        Cg
        Cs
        Cr
        q
        
        %%%LINE ADD%%%
        density
        
        %Safety factor
        n_buckling
        n_shear
        n_DE
        n_fatigue
        L_lowerShank
    end
    
    methods
        %Constructor
        %Parameters: heigh of person, shank accelerations in x and y from
        %Winter's, ExoThigh object
        %Return: none
        
        %%%LINE CHANGE ADD INPUT ARGUMENT%%%
        function obj = ExoShank(height,thickness,t3)           
            %Dimensions
           
            obj.L_shank = 0.246*height/100;
            obj.L_lowerShank = obj.L_shank - 0.155;
            obj.w_shank = 0.032;
            obj.t2 = (thickness-0.005)/2;
            obj.t1 = 0.005;
            obj.r_shankUbar =(t3+0.002)/2;
            obj.shankUbar_height = 0.04;
            obj.shankUbar_innerDiameter = t3;
            
            obj.t_total = (2*obj.t2) + obj.t1;
            ro = 0.0175;                 %outer radius of circular section
            ri = 0.003;                %inner radius of circular section (hole radius)
            A_circle = (ro^2)-(ri^2);   %surface area of circular section
            
            %Cross Section
            obj.A_shank = obj.w_shank*(obj.t_total);

            obj.length_buckling = obj.L_shank-ro-0.02;
            
            %Material Properties
            obj.shank_Sy = 379000000;
            obj.shank_Ssy = 0.577*obj.shank_Sy;
            obj.shank_Su = 448000000;
            obj.shank_E = 105000000000;
            obj.density = 4500;  
            densityEVA = 938;
            
            %Mass Calculations
            obj.m_shankCircleHead = obj.density*(pi*A_circle*obj.t1);
            obj.m_shankNeckBar = obj.density*obj.w_shank*((0.07*obj.t2)+(0.07*obj.t1)+(0.066*obj.t2));
            obj.m_Foam = densityEVA*(0.05*obj.w_shank*(obj.t_total));
            obj.m_lowerShank = obj.density*((obj.L_shank-0.195)*obj.w_shank*(obj.t_total));
            obj.m_shankUBar = obj.density*obj.w_shank*((pi*(((obj.r_shankUbar+obj.t_total)^2)-(obj.r_shankUbar^2)))/2);
            obj.m_shank = obj.m_shankCircleHead + obj.m_shankNeckBar + obj.m_Foam + obj.m_lowerShank + obj.m_shankUBar;
            
            %Weight Calculations
            obj.W_shankCircleHead = obj.m_shankCircleHead*9.81;
            obj.W_shankNeckBar = obj.m_shankNeckBar*9.81;
            obj.W_Foam = obj.m_Foam*9.81;
            obj.W_lowerShank = obj.m_lowerShank*9.81;
            obj.W_shankUBar = obj.m_shankUBar*9.81;
            obj.W_shank = obj.m_shank*9.81;

            %COMx claculations
            m1x1 = obj.m_shankCircleHead*(obj.w_shank/2);
            m2x2 = obj.m_shankNeckBar*(obj.w_shank/2);
            m3x3 = obj.m_Foam*(obj.w_shank/2);
            m4x4 = obj.m_lowerShank*(obj.w_shank/2);
            m5x5 = obj.m_shankUBar*(obj.r_shankUbar + (obj.t_total/2));
            obj.COM_x = (m1x1+m2x2+m3x3+m4x4+m5x5)/obj.m_shank;
            
            %COMy claculations
            m1y1 = obj.m_shankCircleHead*(obj.L_shank-ro);
            m2y2 = obj.m_shankNeckBar*(obj.L_shank-ro-0.035);
            m3y3 = obj.m_Foam*(obj.L_shank-ro-0.07-0.025);
            m4y4 = obj.m_lowerShank*(((obj.L_shank-0.195)/2)+0.04);
            m5y5 = obj.m_shankUBar*(0.02);
            obj.COM_y = (m1y1+m2y2+m3y3+m4y4+m5y5)/obj.m_shank;
            
            %Mass Moment of Inertia
            I_shankCircleHead = obj.m_shankCircleHead*(ro^2);
            I_shankNeckBar = (obj.m_shankNeckBar*((obj.w_shank^2)+(0.07^2)))/12;
            I_Foam = (obj.m_Foam*((obj.w_shank^2)+(0.05^2)))/12;
            I_lowerShank = (obj.m_lowerShank*((obj.w_shank^2)+((obj.L_shank-0.195)^2)))/12;
            I_shankUBar = obj.m_shankUBar*((((2*obj.r_shankUbar)+(2*obj.t_total))^2)-((2*obj.r_shankUbar)^2))/(16*2);
            obj.I_shank = I_shankCircleHead + I_shankNeckBar + I_Foam + I_lowerShank + I_shankUBar;
            obj.I_area = obj.w_shank*((obj.t_total)^3)/12;           
            
            obj.shankUbar_shearForce = obj.m_shankUBar*9.81;

            %Force position claculations
            obj.r_knee_x = obj.COM_x - (obj.w_shank/2);
            obj.r_knee_y = obj.L_shank - obj.COM_y - ro - ri;
            obj.r_ankle_x = obj.r_knee_x;
            obj.r_ankle_y = obj.COM_y - 0.017;
            obj.r_pawlpin_y = obj.L_shank - obj.COM_y - ro - 0.01 - 0.0075;   
            
            obj.Kt = 5.7;
            obj.Cg = 0.8;
            obj.Cs = 0.65;
            obj.Cr = 0.753;
            obj.q = 0.85;
            
            obj.F_pawlpin_x = NaN;
            obj.F_knee_x = NaN;
            obj.F_knee_y = NaN;
        end     
        
        %Calculate and store forces of shank component (from FBDs)
        %Parameters: ExoShank Object
        %Return: none
        function [F_screwFoamS_x1,F_screwFoamS_x2,F_screwFoamS_y1,F_screwFoamS_y2,...
                F_ankle_x,F_ankle_y]= calcShankForces(obj,alpha,a_y_shank,F_pawl_x, F_knee_x, F_knee_y,momentKnee)
            
            obj.F_pawlpin_x = F_pawl_x;
            obj.F_knee_x = F_knee_x;
            obj.F_knee_y = F_knee_y;
            
            %Force of foam screws
            obj.F_screwFoamS_x1 =  (obj.F_knee_x + obj.F_pawlpin_x)/2;
            obj.F_screwFoamS_x2 = (-1)*(obj.F_screwFoamS_x1);
            obj.F_screwFoamS_y1 = obj.F_knee_y/2;
            obj.F_screwFoamS_y2 = (-1)*(obj.F_screwFoamS_y1);
            F_screwFoamS_x1 = obj.F_screwFoamS_x1;
            F_screwFoamS_x2 = obj.F_screwFoamS_x2;
            F_screwFoamS_y1 = obj.F_screwFoamS_y1;
            F_screwFoamS_y2 = obj.F_screwFoamS_y2;     
            
            %Forces ankle joint
            obj.F_ankle_y = -obj.W_shank - (obj.m_shank*a_y_shank) - F_knee_y;
            obj.F_ankle_x = (obj.I_shank*alpha + momentKnee + (obj.F_pawlpin_x*obj.r_pawlpin_y)...
                + (F_knee_x*obj.r_knee_y) + (F_knee_y*obj.r_knee_x) + (obj.F_ankle_y*obj.r_ankle_x))/obj.r_ankle_y;
            
            F_ankle_x = obj.F_ankle_x;
            F_ankle_y = obj.F_ankle_y;
        end
        
        %Calculate and store shank moment
        %Parameters: Exo ShankObject
        %Return: none
        function out = calcShankMoment(obj,alpha_shank)
            obj.M_shank = (obj.I_shank)*alpha_shank;
            out = obj.M_shank;
        end
        
        %Fatigue
        function n_fatigue = calcFatigue(obj, F_max, F_min)
           obj.shank_Sn = (0.5*obj.shank_Su)*(obj.Cg)*(obj.Cs)*(obj.Cr);
            
            sigma_max = F_max/obj.A_shank;
            sigma_min = F_min/obj.A_shank;
            
            Kf = 1+(obj.Kt-1)*obj.q;
            
            obj.sigma_a = Kf*(sigma_max - sigma_min)/2;
            obj.sigma_m = Kf*(sigma_max + sigma_min)/2;
            
           obj.n_fatigue = ((obj.sigma_a/obj.shank_Sn) + (obj.sigma_m/obj.shank_Su))^(-1);
           n_fatigue = obj.n_fatigue; 
        end
        
        %Calculate and store critical buckling force and stress and check
        %if buckling occurs
        %Parameters: ExoShank Object
        %Return: none
        function nmin = calcSF(obj,F_ankle_x,F_ankle_y,F_knee_x,F_knee_y,F_pawlpin_x)
            obj.sigma_cr_buckling = ((pi^2)*(obj.shank_E))/((obj.length_buckling/obj.density)^2);
            
            obj.shankUbar_shearStress_max = (3/2)*(obj.shankUbar_shearForce/(obj.shankUbar_height*obj.t_total));

            %Find max shear force
            %%%LINE CHANGE%%%
            A = [abs(F_ankle_x) abs(F_knee_x) abs(F_pawlpin_x)];
            F1 = max(A);
            tau_xy = F1/obj.A_shank;
            
            %Find max y-direction force
            %%%LINE CHANGE%%%%
            B = [abs(F_ankle_y) abs(F_knee_y)];
            F2 = max(B);
            sigma_y = (F2)/(obj.A_shank); 
            %%%LINE REMOVE%%%
            
            %%%LINE CHANGE%%%
            obj.n_buckling = (obj.sigma_cr_buckling)/(sigma_y);
            obj.n_shear = obj.shank_Ssy/obj.shankUbar_shearStress_max;
            
            %%%LINE CHANGE%%%
            vonMises = sqrt((sigma_y^2)-(sigma_y)+ 3*(tau_xy^2));
            obj.n_DE = (obj.shank_Sy)/((obj.Kt)*(vonMises));
  
            nmin = min([obj.n_buckling,obj.n_shear,obj.n_DE]);
        end
    end
end