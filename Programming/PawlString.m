%Pawl String
%Input: Material Props, relative ankle angle fron Winter's Data
%Output: String displacement, string angle relative to the vertical, safety factor
%Written by: Sharon Tam
%Last update: Nov 3, 2019

classdef PawlString < handle
    properties
        %Material Properties%
        string_breakingLoad;

        %Dimensions and Properties%
        %True max load = 1.904N, min loaded height = 3mm
        x_ankle2anchor0;
        y_ankle2anchor0;
        r_ankle2anchor;
        y_ankle2box;
        y_box
        ankle_angle0;
        rel_ankle_angle;
        ankle_angle;
        string_angle;
        string0;
        string_new;
        string_displacement;
        
        z_shank2box;
        y_box2anchor;
        z_box2anchor;
        y_shank2box;
        
        %Forces%
        F_string;
        
        %Safety Factors%
        n_rupture;
    end
    
    methods                                 
        function obj = PawlString(breakLoad, y_ankle, thigh, shank, cBoot,uBar) 
            %Intialization of all variables
            obj.string_breakingLoad = breakLoad; %N https://www.armare.it/en/linee-prodotti/rigging-line/prodotto/dyneema-sewing-thread
            obj.x_ankle2anchor0 = 0.0724808; %m
            obj.y_ankle2anchor0 = y_ankle; %m
            obj.r_ankle2anchor = sqrt((obj.x_ankle2anchor0)^2+(obj.y_ankle2anchor0)^2); %m
            obj.y_ankle2box = 0.05; %m
            obj.y_box = NaN;
            obj.ankle_angle0 = atand((obj.x_ankle2anchor0)/(obj.y_ankle2anchor0)); %degrees
            obj.rel_ankle_angle = NaN;
            obj.ankle_angle = NaN;
            obj.string_angle = NaN;
            obj.string0 = sqrt((obj.x_ankle2anchor0)^2+(obj.y_ankle2anchor0+obj.y_ankle2box)^2);
            obj.string_new = NaN;
            obj.string_displacement = NaN;
            
            obj.z_shank2box = (thigh.t_thigh/2) + 0.0163;
            obj.y_box2anchor = (0.5*cBoot.CBoot_L_nominal) - cBoot.CBoot_L_shoe + uBar.Ubar_L_nominal - uBar.Ubar_T_nominal + 0.0318;
            obj.z_box2anchor = thigh.t_thigh - (0.5*(cBoot.CBoot_T_nominal - cBoot.CBoot_T_shoe)) + 0.015;
            obj.y_shank2box = shank.L_lowerShank + 0.0872004;
            
            obj.F_string = NaN;
            obj.n_rupture = NaN;
        end
        
        function xstring = getXString(obj, ankleAngle)
            obj.rel_ankle_angle = ankleAngle;
            obj.ankle_angle = obj.ankle_angle0 + obj.rel_ankle_angle;
            obj.string_new = sqrt((obj.r_ankle2anchor*sind(obj.ankle_angle))^2+(obj.r_ankle2anchor*cosd(obj.ankle_angle)+obj.y_ankle2box)^2);
            obj.string_displacement = obj.string_new - obj.string0;
            xstring = obj.string_displacement;
        end
        
        function n_rupture = string_ruptureSF(obj, Fstring)
            obj.F_string = Fstring;
            obj.n_rupture = obj.string_breakingLoad/abs(obj.F_string);
            n_rupture = obj.n_rupture;
        end
    end
end