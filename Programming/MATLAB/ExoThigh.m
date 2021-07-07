
classdef ExoThigh < handle
    properties
        %Dimensions   
        L_thigh; %total length of thigh component
        w_thigh; %total width of thigh component
        t_thigh; %total thickness of thigh component
        A_thigh; %cross-sectional area in x plane
        L_buckling;
        L_upperThigh;
        
        %Positions
        COM_x;
        COM_y;
        
        r_knee_x;
        r_knee_y;
        r_hip_x;
        r_hip_y;
        r_pawl_y;
        
        %Material Properties
        thigh_Sy;
        thigh_Su;
        thigh_Sn;
        thigh_E
        densityAl;
        
        %Mass
        m_upperThigh;
        m_foam;
        m_lowerThigh;
        m_ratchet;
        m_totalThigh;
        
        %Weight
        W_upperThigh;
        W_foam;
        W_lowerThigh;
        W_ratchet;
        W_totalThigh;
        
        %Mass moment of inertia  
        I_thigh
        
        %Moment
        M_thigh
        
        %Hip Forces
        F_hip_x
        F_hip_y
        
        %Internal Force - screws securing foam dampener to thigh segment
        F_screwFoamT_y1
        F_screwFoamT_y2
        
        %Forces of knee joint
        F_knee_x
        F_knee_y
        F_pawl_x
        
        %Max and min forces of the system
        F_max
        F_min 
        
        %Stresses
        sigma_bending
        sigma1
        sigma2
        sigma_axial
        sigma_max
        sigma_min
        sigma_a
        sigma_m
        
        %Safety Factors
        n_fatigue              %Obtained using Goodman's Criteria
        n_bending
        n_DE                   %Obtained using Distortion Energy Theory + Von Mises stress
        n_axial
        
        n_buckling
    end
   
    methods
        %Constructor
        %Parameters: 
        %Return: none
        function obj = ExoThigh(height,t_thigh)
            %Dimension claculations
            obj.L_thigh = 0.245*height/100;
            obj.w_thigh = 0.02;
            obj.t_thigh = t_thigh;
            obj.L_buckling = obj.L_thigh - 0.045;
            ledge_thickness = (obj.t_thigh - 0.005)/2;
            obj.L_upperThigh = obj.L_thigh-0.163;
            
            %Cross Sectional Area
            obj.A_thigh = obj.w_thigh*obj.t_thigh;
            
            %Material Properties
            obj.thigh_Sy = 172000000; 
            obj.thigh_Su = 241000000;
            obj.densityAl = 4510;
            densityEVA = 938;
            obj.thigh_E = 105000000000;
            
            %Mass
            obj.m_upperThigh = obj.densityAl*(((obj.L_thigh-0.163)*obj.w_thigh*obj.t_thigh)-(obj.w_thigh*pi*((0.004)^2)));
            obj.m_foam = densityEVA*(0.05*obj.w_thigh*obj.t_thigh);
            obj.m_lowerThigh = obj.densityAl*((0.103*obj.w_thigh*obj.t_thigh)-(pi*(0.003^2)*ledge_thickness)-((obj.w_thigh/2)*obj.w_thigh*0.005));
            obj.m_ratchet = obj.densityAl*((pi*(((obj.w_thigh/2)-0.005)^2)*ledge_thickness)+((pi/2)*(((obj.w_thigh/2)^2)...
                -(((obj.w_thigh/2)-0.005)^2))*ledge_thickness)-(pi*(0.003^2)*ledge_thickness));
            obj.m_totalThigh = obj.m_upperThigh + obj.m_foam + obj.m_lowerThigh + obj.m_ratchet;
            
            %Weight
            obj.W_upperThigh = obj.m_upperThigh*9.81;
            obj.W_foam = obj.m_foam*9.81;
            obj.W_lowerThigh = obj.m_lowerThigh*9.81;
            obj.W_ratchet = obj.m_ratchet*9.81;
            obj.W_totalThigh = obj.m_totalThigh*9.81;
            
            %COMx claculations
            m1x1 = obj.m_upperThigh*(obj.w_thigh/2);
            m2x2 = obj.m_foam*(obj.w_thigh/2);
            m3x3 = obj.m_lowerThigh*(obj.w_thigh/2);
            m4x4 = obj.m_ratchet*(0.01375);
            obj.COM_x = (m1x1+m2x2+m3x3+m4x4)/obj.m_totalThigh;
            
            %COMy claculations
            y1 = (obj.L_thigh-0.163)/2;
            y2 = (obj.L_thigh-0.163) - 0.029;
            A1 = (obj.L_thigh-0.163)*obj.w_thigh;
            A2 = 0.08*obj.w_thigh;
            y_bar = ((y1*A1)+(y2*A2))/(A1+A2);
            
            %COMy Calcs lower thigh
            y3 = (0.103/2);
            y4 = (0.026)/2;
            A3 = 0.103*obj.t_thigh;
            A4 = 0.026*0.005;
            y_bar2 = ((y3*A3)+(y4*A4))/(A3+A4);
            
            m1y1 = obj.m_upperThigh*(y_bar + 0.163);
            m2y2 = obj.m_foam*(0.163-0.025);
            m3y3 = obj.m_lowerThigh*((obj.w_thigh/2)+y_bar2);
            m4y4 = obj.m_ratchet*(0.006536);
            obj.COM_y = (m1y1+m2y2+m3y3+m4y4)/obj.m_totalThigh;
            
            %Mass Moment of Inertia
            I_upperThigh = (obj.m_upperThigh*((obj.w_thigh^2)+((obj.L_thigh-0.163)^2)))/12;
            I_foam = (obj.m_foam*((obj.w_thigh^2)+(0.05^2)))/12;
            I_lowerThigh = (obj.m_lowerThigh*((obj.w_thigh^2)+(0.103^2)))/12;
            I_ratchet = obj.m_ratchet*((obj.w_thigh/2)^2)/2;
            obj.I_thigh = I_upperThigh + I_foam + I_lowerThigh + I_ratchet;
            
            %Force position claculations
            obj.r_knee_x = (obj.w_thigh/2) - obj.COM_x;
            obj.r_knee_y = obj.COM_y - (obj.w_thigh/2) - 0.003;
            obj.r_hip_x = obj.r_knee_x;
            obj.r_hip_y = obj.L_thigh - obj.COM_y - 0.025 - 0.008;
            obj.r_pawl_y = obj.COM_y - 0.0025;     

            %Forces
            obj.F_knee_x = NaN;
            obj.F_knee_y = NaN;
            obj.F_pawl_x = NaN;
        end
        
        %Calculate and store forces of thigh component (from FBDs)
        %Parameters: ExoThigh Object
        %Return: none
        function [F_screwFoamT_y1, F_screwFoamT_y2, F_pawl_x, F_knee_y, F_knee_x,thighMoment]=...
                calcThighForces(obj,a_x,a_y,alpha,F_hip_y,F_hip_x,momentExo,momentHip,momentKnee)
           
            obj.F_hip_x = F_hip_x;
            obj.F_hip_y = F_hip_y;
            
            %Thigh Moment
            obj.M_thigh = obj.I_thigh*alpha; 
            thighMoment = obj.M_thigh;
           
            %Y-Force of knee joint 
            obj.F_knee_y = (obj.m_totalThigh*a_y) + obj.W_totalThigh + F_hip_y;
            F_knee_y = obj.F_knee_y;
            
            %Force of pawl
            obj.F_pawl_x = (momentExo-momentHip-momentKnee-(F_hip_x*obj.r_hip_y)-(F_hip_x*obj.r_knee_y)-(obj.m_totalThigh*a_x*obj.r_knee_y)...
                -(F_hip_y*obj.r_hip_x)+(F_knee_y*obj.r_knee_x)+(obj.M_thigh))/(obj.r_knee_y - obj.r_pawl_y);
            F_pawl_x = obj.F_pawl_x;

            %X-Force of knee joint 
            obj.F_knee_x = -F_hip_x - obj.m_totalThigh*a_x - F_pawl_x;
            F_knee_x = obj.F_knee_x;
            
            %Force of foam screws
            obj.F_screwFoamT_y1 = (-1)*(F_hip_y/2);
            obj.F_screwFoamT_y2 = (-1)*(F_knee_y/2);
            
            F_screwFoamT_y1 = obj.F_screwFoamT_y1;
            F_screwFoamT_y2 = obj.F_screwFoamT_y2;
        end
        
        function n_fatigue = calcFatigue(obj, F_max, F_min)
            %Calculate and store values needed for Goodman criteria
            %Parameters: ExoThigh Object
            %Return: none
            
%             Cl = 1;
%             Cg = 0.9;
%             Cs = 1;
%             Cr = 0.753;
            obj.thigh_Sn = (0.5*obj.thigh_Su)*(0.9)*(0.82)*(0.753);
            
            obj.sigma_max = F_max/obj.A_thigh;
            obj.sigma_min = F_min/obj.A_thigh;
            
            %Stress concentration factor Kt = 1.4, q=0.72
            %Kf = 1+(Kt-1)*q
            Kf = 1+(3.7-1)*0.72;
            
            obj.sigma_a = Kf*(obj.sigma_max - obj.sigma_min)/2;
            obj.sigma_m = Kf*(obj.sigma_max + obj.sigma_min)/2;
            
            obj.n_fatigue = 1/(obj.sigma_a/obj.thigh_Sn + obj.sigma_m/obj.thigh_Su);
            
            n_fatigue = obj.n_fatigue;
        end
        
        %Calculate and store max/min normal stress values in curved portion of upper thigh
        %Parameters: ExoThigh Object
        %Return: none
        function n_stress = calcSF(obj,F_pawl_x,F_knee_x,F_knee_y,F_hip_x,F_hip_y)
            
            %Find max shear force
            A = [abs(F_pawl_x) abs(F_knee_x) abs(F_hip_x)];
            F1 = max(A);
            tau_xy = 1.5*F1/obj.A_thigh;
            
            %Find max y-direction force
            B = [abs(F_knee_y) abs(F_hip_y)];
            F2 = max(B);
            sigma_y = (F2)/(obj.A_thigh);
            
%             c = (sigma_y/2) + sqrt((-sigma_y/2)^2 + (tau_xy)^2);
%             d = (sigma_y/2) - sqrt((-sigma_y/2)^2 + (tau_xy)^2);
%             
%             obj.sigma1 = max(c,d);
%             obj.sigma2 = min(c,d);
           
            %Stress concentration factor Kt = 1.4
            vonMises = sqrt((sigma_y^2) - (sigma_y) + 3*(tau_xy^2));
            obj.n_DE = (obj.thigh_Sy)/(3.7*(vonMises));
            
            Scr = ((pi^2)*(obj.thigh_E))/((obj.L_buckling/obj.densityAl)^2);
            obj.n_buckling = Scr/sigma_y;

            n_stress = min([obj.n_DE,obj.n_buckling]);
        end
    end
    
end