classdef PlungerEF < handle
    
    properties
        rubberthickness;
        thigh_holderthickness;
        plunger_Volume;
        plunger_Density;%temp
        plunger_Mass;
        moment_Inertia;
        plunger_SpringConstant;
        
        radius_Member2Ext;
        radius_CounterWeightExt;
        radius_WeightExt;
        radius_PlungerX;
        radius_PlungerY;
        
        torque_BearingExt;
        force_BearingExtX;
        force_Plunger;
        force_Wall;
        force_PlungerScrew_y;
        
        %Failure
        thickness; %of the sheet metal
        height; %in the y direction when aligned with the global coordinate system
        width; %neglecting the arm portion the width of the rectangular portion in the x direct when aligned with the global coordinate system
        T_PlungerHousing; %in the z direction when aligned with the global coordinate system
        n_bm_z;
        YS;
        n_bm_x;
        n_nor;
        sigma_bm_z;
        sigma_bm_x;
        sigma_ext;
        sigma_a;
        sigma_m;
        S_n_prime;
        S_n;
        n_fatigue;
    end
    
    methods
        function obj = PlungerEF(density,member2ext,counterweightext,weightext,plungerx,plungery,thickness,...
                height,YS,T_PlungerHousing,springConstant,width, t_thigh) %springConstant is new
            obj.plunger_Volume = ((0.01^2)*pi*0.03)+(0.04*0.05*0.005)+(0.005*0.05*(t_thigh+0.0005)*2)+(0.02*0.005*0.03); 
            
            obj.rubberthickness = t_thigh;
            obj.thigh_holderthickness= t_thigh +0.005;
            
            obj.plunger_Density = density;
            obj.plunger_Mass = obj.plunger_Volume*obj.plunger_Density;
            obj.moment_Inertia = (((pi/4)*(0.03^2)*0.03*obj.plunger_Density)/48)*(3*(0.03^2)+(4*(0.03^2)))+...
                (((0.04*0.05*0.005*obj.plunger_Density)/12)*((0.04^2)+(0.05^2)))+2*(((0.005*0.05*(t_thigh+0.0005)...
                *obj.plunger_Density)/12)*((0.05^2)+((t_thigh+0.0005)^2)))+(((0.02*0.005*0.03*obj.plunger_Density)/12)*((0.02^2)+(0.03^2)));
            
            obj.plunger_SpringConstant = springConstant;
            
            obj.radius_Member2Ext = member2ext;
            obj.radius_CounterWeightExt = counterweightext;
            obj.radius_WeightExt = weightext;
            obj.radius_PlungerX = plungerx;
            obj.radius_PlungerY = plungery;
            
            obj.torque_BearingExt = NaN;
            obj.force_BearingExtX = NaN;
            obj.force_Plunger = NaN;
            obj.force_Wall = NaN;
            
            obj.thickness = thickness;
            obj.height = height;
            obj.width = width;
            obj.n_bm_z = NaN;
            obj.YS = YS;
            obj.T_PlungerHousing = T_PlungerHousing;
            obj.n_bm_x = NaN;
            obj.n_nor = NaN;
            obj.sigma_bm_z = NaN;
            obj.sigma_bm_x = NaN;
            obj.sigma_ext = NaN;
            obj.sigma_a = NaN;
            obj.sigma_m = NaN;
        end
        function out = calculateBearingExtX(obj,accel_x,theta)
            obj.force_BearingExtX = obj.plunger_Mass*accel_x + obj.force_Plunger*cosd(theta);
            out = obj.force_BearingExtX;
        end
        function out = calculateForcePlunger(obj,theta)%%NEW%%
            t = (24.1 - theta)*pi/180;
            c = 2*0.1158*sin(t/2); %Same as delta x
            obj.force_Plunger = obj.plunger_SpringConstant*c;
            out = obj.force_Plunger;
        end
        function out = calculateTorqueBearing(obj,alpha) %%%NEW%%%
            obj.torque_BearingExt = (-obj.moment_Inertia*alpha)  + (obj.force_Plunger*sind(15)*obj.radius_PlungerX)...
                + (obj.force_Plunger*cosd(15)*obj.radius_PlungerY);
            out = obj.torque_BearingExt;
        end
        function out = calculateForceWall(obj)
            obj.force_Wall = obj.force_Plunger;
            out = obj.force_Plunger;
        end
        
        
        %Calculate minimum safety factor for non-fatigue failure modes
        %Parameters: Plunger Object, F_bearing, theta of forcePlunger,
        %forcePlunger
        %Return: none
        function n_stress = getn_stress (obj,F_bearingY, theta, forcePlunger,torque_BearingExt)
           obj.sigma_bm_z = (abs(torque_BearingExt)*6)/(obj.thickness*(obj.height)^2);
           obj.n_bm_z = obj.YS/obj.sigma_bm_z;
           
           M_bearing = F_bearingY*((0.5*obj.thickness)+(0.5*obj.T_PlungerHousing));
           obj.sigma_bm_x = abs((M_bearing*6)/(obj.width*(obj.height)^2));
           obj.n_bm_x = obj.YS/obj.sigma_bm_x;
           
           obj.sigma_ext = abs((forcePlunger*cosd(theta))/(obj.thickness*obj.height));
           obj.n_nor = obj.YS/obj.sigma_ext;
           
           holder = [obj.n_bm_z obj.n_bm_x obj.n_nor];
           n_stress = min(holder);
        end
        
        %Calculate fatigue safety factor
        %Parameters: Plunger Object, Surface factor, ultimate tensile
        %strength, forcePlunger_max
        %Return: none
        function n_fatigue = getn_fatigue (obj, UTS,forcePlunger_max,forcePlunger_min,theta)
            sigma_max =(forcePlunger_max*cosd(theta))/(obj.thickness*obj.height);
            sigma_min =(forcePlunger_min*cosd(theta))/(obj.thickness*obj.height);
            obj.sigma_m = (sigma_max+sigma_min)/2; 
            obj.sigma_a = (sigma_max-sigma_min)/2; 
            
            obj.S_n_prime = 0.5*UTS;
            Cl = 1;
            Cg = 0.9;
            Ct = 1;
            Cr = 0.814;
            Cs = 0.829;
            obj.S_n = obj.S_n_prime*Cl*Cg*Ct*Cr*Cs;
            
            obj.n_fatigue = 1/((obj.sigma_a/obj.S_n)+(obj.sigma_m/UTS));
            
            n_fatigue = obj.n_fatigue;
        end
    end
end

