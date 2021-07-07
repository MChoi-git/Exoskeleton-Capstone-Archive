classdef Shelf < handle
    %Backpack shelf, forces written by Matt, failure written by Megan. 
    properties
        shelf_Length;%In the x-axis direction when aligned with the global coordinate system%
        shelf_Width;%In the z-axis direction when aligned with the global coordinate system%
        shelf_Thickness;%In the y-axis direction when aligned with the global coordinate system%
        shelf_Density;
        
        gasSpring_L;
        gasSpring_C;
        
        backpack_Weight;
        shelf_Weight;
        
        force_HingeX;
        force_HingeY;
        force_GasSpringYMax;
        force_GasSpring1y;
        force_GasSpring2y;
        force_GasSpring1x;
        force_GasSpring2x;
        
        gaitPhaseCounter;  
        gaitPhaseFrame;
        theta;
        
        %Stress and Failure
        YS;
        tau_DS;
        tau_Trans;
        tau_Tor;
        
        n_DS;
        n_Trans;
        n_Tor;
        
        %Fatigue%
        sigma_m;
        sigma_a;
        n_fatigue;
    end
    
    methods
        function obj = Shelf(length,width,thickness,density,bpmass,theta,yeildSTR)%,normBPForce,lengthNormForce,perpGSLength)
            obj.shelf_Length = length;
            obj.shelf_Width = width;
            obj.shelf_Thickness = thickness;
            obj.shelf_Density = density;
            
            obj.gasSpring_L = 0.15;
            obj.gasSpring_C = 0.055;
            
            obj.backpack_Weight = bpmass * 9.81; 
            obj.shelf_Weight = obj.shelf_Length*obj.shelf_Width*obj.shelf_Thickness*obj.shelf_Density*9.81;
            
            obj.force_HingeX = 0;
            obj.force_GasSpringYMax = NaN;
            %obj.force_GasSpring = (normBPForce*lengthNormForce*1.06)/perpGSLength;
            obj.force_GasSpring1y = 0; %Left leg 
            obj.force_GasSpring2y = 0; %Right leg
            obj.force_GasSpring1x = 0;
            obj.force_GasSpring2x = 0;
            
            obj.gaitPhaseCounter = 0; %Increments by 0.7 per obj.gaitPhaseFrame, total of 100
            obj.gaitPhaseFrame = 1;   %1-70
            obj.theta = theta;
            %Stress and Failure
            obj.YS = yeildSTR;
            obj.tau_DS = NaN;
            obj.tau_Trans = NaN;
            obj.tau_Tor = NaN;
            
            obj.n_DS = NaN;
            obj.n_Trans = NaN;
            obj.n_Tor = NaN;
            
            %Fatigue%
            obj.sigma_m = NaN;
            obj.sigma_a = NaN;
            obj.n_fatigue = NaN;
        end
%Deleting hinges I believe
%         function out = calculateForceHingeY(obj,accel_y)
%             obj.force_HingeY = obj.backpack_Weight + obj.shelf_Weight - (((obj.shelf_Weight/9.81)*accel_y)/((1.06*obj.gasSpring_L...
%                 /obj.gasSpring_C*dcos(obj.theta))-1));
%             out = obj.force_HingeY;
%         end
        function out = calculateForceGSYMax(obj,accel_y)
            obj.force_GasSpringYMax = (obj.shelf_Weight/9.81)*accel_y + obj.backpack_Weight + obj.shelf_Weight;
            out = obj.force_GasSpringYMax;
        end
        function out = calculateForceHingeX(obj)
            obj.force_HingeX = ((obj.backpack_Weight + obj.shelf_Weight)*obj.gasSpring_L*1.06)/obj.gasSpring_C...
                *sind(obj.theta);
            out = obj.force_HingeX;
        end
        function [forceGS1x,forceGS2x,forceGS1y,forceGS2y,obj] = calculateForceGS(obj,i)
            obj.gaitPhaseFrame = i;
            %HCR to TOR: [frame28,frame70],TOR to HCR: [frame0,frame28].
            %TOR@f0->f28: L(100%),R(0%)                   %gaitPhaseCounter @0
                                                        %obj.gaitPhaseFrame  @0->28
            %HCR@f28->f36:L(100->50->0%),R(0->50->100%)   %gaitPhaseCounter @0->100
                                                        %obj.gaitPhaseFrame  @28-36
            %TOL@f36->f62:L(0%),R(100%)                   %gaitPhaseCounter @100
                                                        %obj.gaitPhaseFrame @36-62
            %HCL@f62->f69:L(0->50->100%),R(100->50->0%)   %gaitPhaseCounter @100->0
                                                        %obj.gaitPhaseFrame  @62-69 
            
%             if(1 <= obj.gaitPhaseFrame && obj.gaitPhaseFrame < 8)
%                 
%                 obj.force_GasSpring1y = obj.force_GasSpringYMax;
%                 obj.force_GasSpring2y = 0;
%                 
%                 obj.force_GasSpring1x = obj.force_HingeX;
%                 obj.force_GasSpring2x = 0;
%                               
%                 forceGS1x = obj.force_GasSpring1x;
%                 forceGS2x = obj.force_GasSpring2x;
%                 forceGS1y = obj.force_GasSpring1y;
%                 forceGS2y = obj.force_GasSpring2y;
%                 
%                 obj.gaitPhaseFrame = obj.gaitPhaseFrame + 1;
            if(1 <= obj.gaitPhaseFrame && obj.gaitPhaseFrame < 8)
                
                obj.force_GasSpring1y = obj.force_GasSpringYMax * (100 - obj.gaitPhaseCounter)/100;
                obj.force_GasSpring2y = obj.force_GasSpringYMax * (obj.gaitPhaseCounter)/100;
                
                obj.force_GasSpring1x = obj.force_HingeX * (100 - obj.gaitPhaseCounter)/100;
                obj.force_GasSpring2x = obj.force_HingeX * (obj.gaitPhaseCounter)/100;

                forceGS1x = obj.force_GasSpring1x;
                forceGS2x = obj.force_GasSpring2x;
                forceGS1y = obj.force_GasSpring1y;
                forceGS2y = obj.force_GasSpring2y;
                
                obj.gaitPhaseFrame = obj.gaitPhaseFrame + 1;
                obj.gaitPhaseCounter = obj.gaitPhaseCounter + (100/7); %INC by 100/7 until 100%
                
            elseif(8 <= obj.gaitPhaseFrame && obj.gaitPhaseFrame <= 32)
                
                if obj.gaitPhaseFrame == 8, obj.gaitPhaseCounter = 0; end 
                
                obj.force_GasSpring1y = 0;
                obj.force_GasSpring2y = obj.force_GasSpringYMax;
                
                obj.force_GasSpring1x = 0;
                obj.force_GasSpring2x = obj.force_HingeX;
                
                forceGS1x = obj.force_GasSpring1x;
                forceGS2x = obj.force_GasSpring2x;
                forceGS1y = obj.force_GasSpring1y;
                forceGS2y = obj.force_GasSpring2y;

                obj.gaitPhaseFrame = obj.gaitPhaseFrame + 1;
                
            elseif(32 < obj.gaitPhaseFrame && obj.gaitPhaseFrame <= 42)
                if obj.gaitPhaseFrame == 32, obj.gaitPhaseCounter = 0; end
                obj.force_GasSpring1y = obj.force_GasSpringYMax * (obj.gaitPhaseCounter)/100;
                obj.force_GasSpring2y = obj.force_GasSpringYMax * (100-obj.gaitPhaseCounter)/100;
                
                obj.force_GasSpring1x = obj.force_HingeX * (obj.gaitPhaseCounter)/100;
                obj.force_GasSpring2x = obj.force_HingeX * (100-obj.gaitPhaseCounter)/100;
                
                obj.gaitPhaseFrame = obj.gaitPhaseFrame + 1;
                obj.gaitPhaseCounter = obj.gaitPhaseCounter + 100/9; %INC by 100/9 untill 100%
                
                forceGS1x = obj.force_GasSpring1x;
                forceGS2x = obj.force_GasSpring2x;
                forceGS1y = obj.force_GasSpring1y;
                forceGS2y = obj.force_GasSpring2y;
                
            elseif(42 < obj.gaitPhaseFrame && obj.gaitPhaseFrame <= 70)
                
                obj.force_GasSpring1y = obj.force_GasSpringYMax;
                obj.force_GasSpring2y = 0;
                
                obj.force_GasSpring1x = obj.force_HingeX;
                obj.force_GasSpring2x = 0;
                              
                forceGS1x = obj.force_GasSpring1x;
                forceGS2x = obj.force_GasSpring2x;
                forceGS1y = obj.force_GasSpring1y;
                forceGS2y = obj.force_GasSpring2y;
                
                obj.gaitPhaseFrame = obj.gaitPhaseFrame + 1;
                obj.gaitPhaseCounter = 0;
            else %Cycle is finished, reset by handling NaN forces in main
                
                obj.gaitPhaseCounter = 0;
                obj.gaitPhaseFrame = 1;
                
                forceGS1x = NaN;
                forceGS2x = NaN;
                forceGS1y = NaN;
                forceGS2y = NaN;
                
            end           
        end
        
        %Determine minimum safety factor from non-fatigue failure modes
        %Parameters: Shelf Object
        %Return: minimum safety factor (n_stress)
        function n_stress = getn_stress(obj,force_GasSpring1y,force_GasSpring2y)
            %Direct Shear%
            P = (obj.shelf_Weight+obj.backpack_Weight);
            obj.tau_DS = P/(obj.shelf_Width*obj.shelf_Thickness);
            Ssy = 0.577 *obj.YS;
            obj.n_DS = Ssy/obj.tau_DS;
            
            %Torsional / Transverse Shear%
            if force_GasSpring1y == 0
                F = max([force_GasSpring2y (obj.shelf_Weight+obj.backpack_Weight)]);
                r = max([obj.shelf_Width obj.shelf_Length]);
                T = F*(0.25*r);
                obj.tau_Tor = (T*((3*0.5*r)+(1.8*obj.shelf_Thickness)))/(((r*0.5)^2)*((obj.shelf_Thickness)^2));
                obj.tau_Trans = NaN;
                obj.n_Tor = Ssy/obj.tau_Tor;
                obj.n_Trans = NaN;
            elseif force_GasSpring2y == 0
                F = max([force_GasSpring1y (obj.shelf_Weight+obj.backpack_Weight)]);
                r = max([obj.shelf_Width obj.shelf_Length]);
                T = F*(0.25*r);
                obj.tau_Tor = (T*((3*0.5*r)+(1.8*obj.shelf_Thickness)))/(((r*0.5)^2)*((obj.shelf_Thickness)^2));
                obj.tau_Trans = NaN;
                obj.n_Tor = Ssy/obj.tau_Tor;
                obj.n_Trans = NaN;
            else
                V = max([force_GasSpring1y force_GasSpring2y (obj.shelf_Weight+obj.backpack_Weight)]);
                obj.tau_Trans = ((3/4)*V)/(0.5*obj.shelf_Length*obj.shelf_Thickness);
                F = max([force_GasSpring1y force_GasSpring2y]);
                r = max([obj.shelf_Width obj.shelf_Length]);
                T = F*(.25*r);
                obj.tau_Tor = (T*((3*0.5*r)+(1.8*obj.shelf_Thickness)))/(((r*0.5)^2)*((obj.shelf_Thickness)^2));
                obj.n_Tor = Ssy/obj.tau_Tor;
                obj.n_Trans = Ssy/obj.tau_Trans;
            end
            
            n = min([obj.n_DS obj.n_Tor obj.n_Trans]);
            n_stress = n;
        end
        
        %Determine fatigue safety factor
        %Parameters: Shelf Object, Surface Factor, Ultimate Tensile Strength 
        %Return: fatigue safety factor (n_fatigue)
        function n_fatigue = getn_fatigue (obj, Cs, UTS, force_GasSpring_min)
            sigma_max = obj.force_GasSpringYMax/(obj.shelf_Width*obj.shelf_Length);
            sigma_min = force_GasSpring_min/(obj.shelf_Width*obj.shelf_Length);
            obj.sigma_m = (sigma_max+sigma_min)/2; 
            obj.sigma_a = (sigma_max-sigma_min)/2; 
            
            S_n_prime = 0.5*UTS;
            Cl = 0.58;
            Cg = 0.9;
            Ct = 1;
            Cr = 0.814;
            S_n = S_n_prime*Cl*Cg*Ct*Cr*Cs;
            
            obj.n_fatigue = 1/((obj.sigma_a/S_n)+(obj.sigma_m/UTS));
            
            n_fatigue = obj.n_fatigue;
        end
    end
end

