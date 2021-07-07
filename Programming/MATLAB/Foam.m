%Stress, strain, deformation and safety factor calculations for foam in
%thigh and shank
classdef Foam  < handle
    properties
    %Dimensions
    foam_A        %cross-sectional area of foam
    foam_L        %original height of foam
    foam_E        %Young's modulus of material
   
    foam_F        %Compressive force on foam
    
    foam_sigma     %Stress in top section
    foam_sigma_Scy %compressive yield strength
    foam_delta_L   %Deformation
    foam_strain    %Strain
    foam_strainEnergy
    n_deformation
    end
    
    methods
        %Constructor for foam
        %Parameters: Applied force on foam, diameter of pawl string if
        %shank foam
        %Return: none
        function obj = Foam(d_hole, thickness, width)
            if d_hole ~= 0
                obj.foam_A = (width*thickness) - (pi*(d_hole^2)/4);
            else
                obj.foam_A = (width*thickness);
            end
            
            obj.foam_L = 0.05;
            obj.foam_E = 25000000;  
            obj.foam_sigma_Scy = 38210000;
        end

        %Calculate and store stress in foam
        %Parameters: Foam Object
        %Return: none
        function n = calcSF(obj, F_applied)
            obj.foam_sigma = abs(F_applied)/obj.foam_A;
            
            
            %Calculate deformation in foam section
            %Parameters: Foam Object
            %Return: none
            
            obj.foam_delta_L = (obj.foam_F*obj.foam_L)/(obj.foam_A*obj.foam_E);
            
            obj.foam_strain = obj.foam_delta_L/obj.foam_L;
            
            %Calculate and store strain energy in system
            %Parameters: Foam Object
            %Return: none
            
            obj.foam_strainEnergy = (obj.foam_F*obj.foam_delta_L)/2;
            %Calculate and store safety factor for compressive yielding
            %Parameters: Foam Object
            %Return: none
            obj.n_deformation = obj.foam_sigma_Scy/obj.foam_sigma;
            n = obj.n_deformation;
        end
    end
end