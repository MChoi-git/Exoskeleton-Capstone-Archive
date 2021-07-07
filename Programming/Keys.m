classdef Keys<handle
    
    properties
        %Material Properties%
        key_Sy;
        key_Ssy;

        %Dimensions and Properties%
        l_key;
        t_key;
        h_key;
        r_shaft;
        
        %Force%
        torque_BearingAbd;
        
        %Stress%
        tau_keyCompressive;
        tau_keyShear;
        
        %Safety Factors%
        n_keyCompressive;
        n_keyShear;
        
    end
    
    methods
        function obj = Keys(mat_Sy, l_Key, t_Key, h_Key, r_shaft)
            obj.key_Sy = mat_Sy;
            obj.key_Ssy = 0.577*mat_Sy; %distortion energy theory of failure
            obj.l_key = l_Key;
            obj.t_key = t_Key;
            obj.h_key = h_Key;
            obj.r_shaft = r_shaft;
            obj.torque_BearingAbd = NaN;
            obj.tau_keyCompressive = NaN;
            obj.tau_keyShear = NaN;
            obj.n_keyCompressive = NaN;
            obj.n_keyShear = NaN;
        end
        
        function n_stress = Keys_SF(obj, torque_BearingAbd)
            obj.tau_keyCompressive = abs(torque_BearingAbd)/(obj.r_shaft)/(obj.l_key*obj.h_key/2);
            obj.n_keyCompressive = obj.key_Sy/obj.tau_keyCompressive;
        
            obj.tau_keyShear = abs(torque_BearingAbd)/(obj.r_shaft)/(obj.l_key*obj.t_key);
            obj.n_keyShear = obj.key_Ssy/obj.tau_keyShear;
            n_stress = min([obj.n_keyShear obj.n_keyCompressive]);
        end
    end
end

