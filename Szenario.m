classdef Szenario
    %Szenario Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Tsample
        Tsim 
        
        tact
        tact_Amp
        tacts
        tacts_Amp
        tact_OS_Regler
        OS_Regler
        QU_possibleON_OFF
        
        Pl_Uns
        Ql_ind_Uns
        Ql_kap_Uns
        
        Uns_L1_on_off_Zeitpunkte
        Uns_L2_on_off_Zeitpunkte
        Uns_L3_on_off_Zeitpunkte
        
        RVC_L1_on_off_Zeitpunkte
        RVC_L2_on_off_Zeitpunkte
        RVC_L3_on_off_Zeitpunkte
        
        Pl_RVC
        Ql_ind_RVC                % Blindleistung L1, L2, L3 [Var]
        Ql_kap_RVC

        fak_RVC
        
        I_Basis_Ober
        I_relativ_Ober_L1   % relativer Anteil von Basisstrom L1 [%] weitere Erklärung siehe S.
        I_relativ_Ober_L2   % relativer Anteil von Basisstrom L2 [%] weitere Erklärung siehe S.
        I_relativ_Ober_L3   % relativer Anteil von Basisstrom L3 [%] weitere Erklärung siehe S.

        Vielfache_Ober_L1   % Vielfache auf 50Hz normiert L1[] weitere Erklärung siehe S.
        Vielfache_Ober_L2   % Vielfache auf 50Hz normiert L2[] weitere Erklärung siehe S.
        Vielfache_Ober_L3   % Vielfache auf 50Hz normiert L3[] weitere Erklärung siehe S.

        Phi_Ober
        
        Pl_Flicker                    % Wirkleistung der Flickerlast L1, L2, L3 [kW]
        Ql_ind_Flicker                % Blindleistung L1, L2, L3 [kVar]
        Ql_kap_Flicker
        Flicker_Frequenz              % Frequenz mit der die Flickerlast zu/abgeschaltet wird für L1, L2, L3 [Hz]
        Flicker_Start
        Flicker_Dauer
        
        Pl_Grund
        Ql_ind_Grund
        Ql_kap_Grund

        Rtrans
        Ltrans
        strans
        fsw
        Czk

        L_Eingang_Shunt_L1_L2_L3_N
        R_Eingang_Shunt_L1_L2_L3_N
        L_Ausgang_Shunt_L1_L2_L3_N
        R_Ausgang_Shunt_L1_L2_L3_N
        C_parallel_Shunt_L1_L2_L3
        R_parallel_Shunt_L1_L2_L3

        L_Eingang_Series_L1_L2_L3_N
        R_Eingang_Series_L1_L2_L3_N
        L_Ausgang_Series_L1_L2_L3_N	
        R_Ausgang_Series_L1_L2_L3_N
        C_parallel_Series_L1_L2_L3
        R_parallel_Series_L1_L2_L3

%         trafo_power
%         phase_voltage_1
%         R_pu_1
%         X_pu_1
%         phase_voltage_2
%         R_pu_2
%         X_pu_2
%         L1_limbs
%         A1_limbs
%         L2_yokes
%         A2_yokes
%         L0_flux
%         A0_flux
%         winding1
% 
%         BH
%         active_power_losses_trafo
%         flux_initialization
%         trafo_time_constant
        
        Speicherpfad
        User_ID
        Szenario_ID
        Status
        Fehlerliste
        
        Ergebnisse
        Workspace_Ini
    end
    
    methods
        function obj = Szenario(varargin)
            % Test der Zahl der uebergebenen Werte
           if(nargin == 0)
               obj = Szenario0(obj);
           elseif(nargin == 1)
               obj = Szenario1(obj,varargin{1}); % Werte im Cell-Array
           else
               errordlg('Zu viele Argumente fuer Klasse Szenario!', ...
                   'Szenario-Konstruktor');
               obj = Szenario.empty; % leeres Objekt
               error('Szenario-Konstruktor: Zu viele Argumente!');
           end
        end
        
        function obj = checkPropertiesForNaN(obj)
            props = properties(obj);
            for iprop = 1:length(props)
                thisprop = props{iprop};
                thisprop_value = obj.(thisprop);
                if isnan(thisprop_value)
                    obj.(thisprop) ='';
                    obj.Status = 0; 
                end
            end            
        end
        function obj = hole_Ergebnisse(obj, Ergebnisse)
            obj.Ergebnisse = Ergebnisse;            
        end
        function obj = set_Workspace_Ini(obj, Workspace_Ini)
            obj.Workspace_Ini = Workspace_Ini;            
        end
        function obj = errordetectionOnProperties(obj)
            errorstack = {'Fehlerliste'};
            % Tsample
            if isempty(obj.Tsample)||obj.Tsample<0
                errorstack = [errorstack; 'Wert von Tsample fehlt oder ist ungültig!'];
            end
            % Tsim
            if isempty(obj.Tsim)||obj.Tsim<0
                errorstack = [errorstack; 'Wert von Tsim fehlt oder ist ungültig!'];
            end 
            % tact
            if isempty(obj.tact)||obj.tact<0
                errorstack = [errorstack; 'Wert von tact fehlt oder ist ungültig!'];
            end 
            % tact_Amp
            if isempty(obj.tact_Amp)||~isboolean(fi(obj.tact_Amp,'DataType','Boolean'))
                errorstack = [errorstack; 'Wert von tact_Amp fehlt oder ist ungültig!'];
            end 
            % tacts
            if isempty(obj.tacts)||obj.tacts<0
                errorstack = [errorstack; 'Wert von tacts fehlt oder ist ungültig!'];
            end 
            % tacts_Amp
            if isempty(obj.tacts_Amp)||~isboolean(fi(obj.tacts_Amp,'DataType','Boolean'))
                errorstack = [errorstack; 'Wert von tacts_Amp fehlt oder ist ungültig!'];
            end 
            % Pl_Uns / Ql_ind_Uns / Ql_kap_Uns
            if ~isempty(obj.Pl_Uns)&&(isempty(obj.Ql_ind_Uns)||isempty(obj.Ql_kap_Uns))
                errorstack = [errorstack; 'Wenn Pl_Uns angegeben wird, müssen auch Ql_ind_Uns und Ql_kap_Uns angegeben werden!'];
            end   
            if ~isempty(obj.Ql_ind_Uns)&&(isempty(obj.Pl_Uns)||isempty(obj.Ql_kap_Uns))
                errorstack = [errorstack; 'Wenn Ql_ind_Uns angegeben wird, müssen auch Pl_Uns und Ql_kap_Uns angegeben werden!'];
            end  
            if ~isempty(obj.Ql_kap_Uns)&&(isempty(obj.Pl_Uns)||isempty(obj.Ql_ind_Uns))
                errorstack = [errorstack; 'Wenn Ql_kap_Uns angegeben wird, müssen auch Pl_Uns und Ql_ind_Uns angegeben werden!'];
            end 
            if sum(obj.Pl_Uns<0)>0||sum(obj.Ql_ind_Uns<0)>0||sum(obj.Ql_kap_Uns<0)>0
                errorstack = [errorstack; 'Werte für Pl_Uns, Ql_ind_Uns und Ql_kap_Uns dürfen nicht negativ sein!'];
            end
            
            % Uns_L1_on_off_Zeitpunkte / Uns_L2_on_off_Zeitpunkte / Uns_L3_on_off_Zeitpunkte
            if sum(obj.Uns_L1_on_off_Zeitpunkte<0)>0||sum(obj.Uns_L2_on_off_Zeitpunkte<0)>0||sum(obj.Uns_L3_on_off_Zeitpunkte<0)>0
                errorstack = [errorstack; 'Werte für Uns_L1_on_off_Zeitpunkte, Uns_L2_on_off_Zeitpunkte und Uns_L3_on_off_Zeitpunkte sollten nicht negativ sein!'];
            end
            % RVC_L1_on_off_Zeitpunkte / RVC_L2_on_off_Zeitpunkte / RVC_L3_on_off_Zeitpunkte
            if sum(obj.RVC_L1_on_off_Zeitpunkte<0)>0||sum(obj.RVC_L2_on_off_Zeitpunkte<0)>0||sum(obj.RVC_L3_on_off_Zeitpunkte<0)>0
                errorstack = [errorstack; 'Werte für RVC_L1_on_off_Zeitpunkte, RVC_L2_on_off_Zeitpunkte und RVC_L3_on_off_Zeitpunkte sollten nicht negativ sein!'];
            end
            % Pl_RVC / Ql_ind_RVC / Ql_kap_RVC / fak_RVC
            if sum(obj.Pl_RVC<0)>0||sum(obj.Ql_ind_RVC<0)>0||sum(obj.Ql_kap_RVC<0)>0||sum(obj.fak_RVC<0)>0
                errorstack = [errorstack; 'Werte für Pl_RVC, Ql_ind_RVC, Ql_kap_RVC und fak_RVC sollten nicht negativ sein!'];
            end
            % Pl_Grund / Ql_ind_Grund / Ql_kap_Grund
            if sum(obj.Pl_Grund<0)>0||sum(obj.Ql_ind_Grund<0)>0||sum(obj.Ql_kap_Grund<0)>0
                errorstack = [errorstack; 'Werte für Pl_Grund, Ql_ind_Grund und Ql_kap_Grund sollten nicht negativ sein!'];
            end
            % Pl_Grund / Ql_ind_Grund / Ql_kap_Grund
            if ~isempty(obj.Pl_Grund)&&(isempty(obj.Ql_ind_Grund)||isempty(obj.Ql_kap_Grund))
                errorstack = [errorstack; 'Wenn Pl_Grund angegeben wird, müssen auch Ql_ind_Grund und Ql_kap_Grund angegeben werden!'];
            end   
            % I_Basis_Ober
            if sum(obj.I_Basis_Ober<0)>0
                errorstack = [errorstack; 'Werte für I_Basis_Ober sollten nicht negativ sein!'];
            end
            % I_relativ_Ober_L1 / I_relativ_Ober_L2 / I_relativ_Ober_L3
            if sum(obj.I_relativ_Ober_L1<0)>0||sum(obj.I_relativ_Ober_L2<0)>0||sum(obj.I_relativ_Ober_L3<0)>0
                errorstack = [errorstack; 'Werte für I_relativ_Ober_L1, I_relativ_Ober_L2 und I_relativ_Ober_L3 sollten nicht negativ sein!'];
            end
            % Vielfache_Ober_L1 / Vielfache_Ober_L2 / Vielfache_Ober_L3
            if sum(obj.Vielfache_Ober_L1<0)>0||sum(obj.Vielfache_Ober_L2<0)>0||sum(obj.Vielfache_Ober_L3<0)>0
                errorstack = [errorstack; 'Werte für Vielfache_Ober_L1, Vielfache_Ober_L2 und Vielfache_Ober_L3 sollten nicht negativ sein!'];
            end
            
            % Rtrans / Ltrans / strans
            if isempty(obj.Rtrans)||isempty(obj.Ltrans)||isempty(obj.strans)
                errorstack = [errorstack; 'Werte für Rtrans, Ltrans oder strans fehlen!'];
                errorstack = [errorstack; 'Vorschlag für default-Werte für Rtrans: 0.206, Ltrans: 0.256 oder strans: 0.25.'];
            end
            if sum(obj.Rtrans<0)>0||sum(obj.Ltrans<0)>0||sum(obj.strans<0)>0
                errorstack = [errorstack; 'Werte für Rtrans, Ltrans und strans sollten nicht negativ sein!'];
            end
            
            % Phi_Ober - akt. keine Fehlerprüfung notwendig
            
            % Pl_Flicker / Ql_ind_Flicker / Ql_kap_Flicker /
            % Flicker_Frequenz / Flicker_Dauer
            if sum(obj.Pl_Flicker<0)>0||sum(obj.Ql_ind_Flicker<0)>0||sum(obj.Ql_kap_Flicker<0)>0||sum(obj.Flicker_Frequenz<0)>0||sum(obj.Flicker_Dauer<0)>0
                errorstack = [errorstack; 'Werte für Pl_Flicker, Ql_ind_Flicker, Ql_kap_Flicker, Flicker_Frequenz und Flicker_Dauer sollten nicht negativ sein!'];
            end            

            % fsw
            if isempty(obj.fsw)||obj.fsw<0
                errorstack = [errorstack; 'Wert für fsw fehlt oder ist negativ!'];
                errorstack = [errorstack; 'Vorschlag für default-Werte für fsw: 16.'];
            end
            % Czk
            if isempty(obj.Czk)||obj.Czk<0
                errorstack = [errorstack; 'Wert für Czk fehlt oder ist negativ!'];
                errorstack = [errorstack; 'Vorschlag für default-Werte für Czk: 3000.'];
            end
            % L_Eingang_Shunt_L1_L2_L3_N / R_Eingang_Shunt_L1_L2_L3_N
            if isempty(obj.L_Eingang_Shunt_L1_L2_L3_N)||isempty(obj.R_Eingang_Shunt_L1_L2_L3_N)
                errorstack = [errorstack; 'Werte für L_Eingang_Shunt_L1_L2_L3_N oder R_Eingang_Shunt_L1_L2_L3_N fehlen!'];
                errorstack = [errorstack; 'Vorschlag für default-Werte für L_Eingang_Shunt_L1_L2_L3_N: [1.78;1.78;1.78;1.78], R_Eingang_Shunt_L1_L2_L3_N: [0.2;0.2;0.2;0.2].'];
            end
            if sum(obj.L_Eingang_Shunt_L1_L2_L3_N<0)>0||sum(obj.R_Eingang_Shunt_L1_L2_L3_N<0)>0
                errorstack = [errorstack; 'Werte für L_Eingang_Shunt_L1_L2_L3_N und R_Eingang_Shunt_L1_L2_L3_N sollten nicht negativ sein!'];
            end
            % L_Ausgang_Shunt_L1_L2_L3_N / R_Ausgang_Shunt_L1_L2_L3_N
            if isempty(obj.L_Ausgang_Shunt_L1_L2_L3_N)||isempty(obj.R_Ausgang_Shunt_L1_L2_L3_N)
                errorstack = [errorstack; 'Werte für L_Ausgang_Shunt_L1_L2_L3_N oder R_Ausgang_Shunt_L1_L2_L3_N fehlen!'];
                errorstack = [errorstack; 'Vorschlag für default-Werte für L_Ausgang_Shunt_L1_L2_L3_N: [1;1;1;1], R_Ausgang_Shunt_L1_L2_L3_N: [0.1;0.1;0.1;0.1].'];
            end
            if sum(obj.L_Ausgang_Shunt_L1_L2_L3_N<0)>0||sum(obj.R_Ausgang_Shunt_L1_L2_L3_N<0)>0
                errorstack = [errorstack; 'Werte für L_Ausgang_Shunt_L1_L2_L3_N und R_Ausgang_Shunt_L1_L2_L3_N sollten nicht negativ sein!'];
            end
            % C_parallel_Shunt_L1_L2_L3 / R_parallel_Shunt_L1_L2_L3
             if isempty(obj.C_parallel_Shunt_L1_L2_L3)||isempty(obj.R_parallel_Shunt_L1_L2_L3)
                errorstack = [errorstack; 'Werte für C_parallel_Shunt_L1_L2_L3 oder R_parallel_Shunt_L1_L2_L3 fehlen!'];
                errorstack = [errorstack; 'Vorschlag für default-Werte für C_parallel_Shunt_L1_L2_L3: [100;100;100], R_parallel_Shunt_L1_L2_L3: [0;0;0].'];
            end
            if sum(obj.C_parallel_Shunt_L1_L2_L3<0)>0||sum(obj.R_parallel_Shunt_L1_L2_L3<0)>0
                errorstack = [errorstack; 'Werte für C_parallel_Shunt_L1_L2_L3 und R_parallel_Shunt_L1_L2_L3 sollten nicht negativ sein!'];
            end
            % L_Eingang_Series_L1_L2_L3_N / R_Eingang_Series_L1_L2_L3_N
            if isempty(obj.L_Eingang_Series_L1_L2_L3_N)||isempty(obj.R_Eingang_Series_L1_L2_L3_N)
                errorstack = [errorstack; 'Werte für L_Eingang_Series_L1_L2_L3_N oder R_Eingang_Series_L1_L2_L3_N fehlen!'];
                errorstack = [errorstack; 'Vorschlag für default-Werte für L_Eingang_Series_L1_L2_L3_N: [1;1;1;1], R_Eingang_Series_L1_L2_L3_N: [0.1;0.1;0.1;0.1].'];
            end
            if sum(obj.L_Eingang_Series_L1_L2_L3_N<0)>0||sum(obj.R_Eingang_Series_L1_L2_L3_N<0)>0
                errorstack = [errorstack; 'Werte für L_Eingang_Series_L1_L2_L3_N und R_Eingang_Series_L1_L2_L3_N sollten nicht negativ sein!'];
            end
            % L_Ausgang_Series_L1_L2_L3_N / R_Ausgang_Series_L1_L2_L3_N
            if isempty(obj.L_Ausgang_Series_L1_L2_L3_N)||isempty(obj.R_Ausgang_Series_L1_L2_L3_N)
                errorstack = [errorstack; 'Werte für L_Ausgang_Series_L1_L2_L3_N oder R_Ausgang_Series_L1_L2_L3_N fehlen!'];
                errorstack = [errorstack; 'Vorschlag für default-Werte für L_Ausgang_Series_L1_L2_L3_N: [1;1;1;1], R_Ausgang_Series_L1_L2_L3_N: [0.1;0.1;0.1;0.1].'];
            end
            if sum(obj.L_Ausgang_Series_L1_L2_L3_N<0)>0||sum(obj.R_Ausgang_Series_L1_L2_L3_N<0)>0
                errorstack = [errorstack; 'Werte für L_Ausgang_Series_L1_L2_L3_N und R_Ausgang_Series_L1_L2_L3_N sollten nicht negativ sein!'];
            end
            % C_parallel_Series_L1_L2_L3 / R_parallel_Series_L1_L2_L3
             if isempty(obj.C_parallel_Series_L1_L2_L3)||isempty(obj.R_parallel_Series_L1_L2_L3)
                errorstack = [errorstack; 'Werte für C_parallel_Series_L1_L2_L3 oder R_parallel_Series_L1_L2_L3 fehlen!'];
                errorstack = [errorstack; 'Vorschlag für default-Werte für C_parallel_Series_L1_L2_L3: [100;100;100], R_parallel_Series_L1_L2_L3: [0;0;0].'];
            end
            if sum(obj.C_parallel_Series_L1_L2_L3<0)>0||sum(obj.R_parallel_Series_L1_L2_L3<0)>0
                errorstack = [errorstack; 'Werte für C_parallel_Series_L1_L2_L3 und R_parallel_Series_L1_L2_L3 sollten nicht negativ sein!'];
            end

%             % trafo_power / phase_voltage_1
%             if sum(obj.trafo_power<0)>0||sum(obj.phase_voltage_1<0)>0
%                 errorstack = [errorstack; 'Werte für trafo_power und phase_voltage_1 sollten nicht negativ sein!'];
%             end            
%             % R_pu_1 / X_pu_1
%             if sum(obj.R_pu_1<0)>0||sum(obj.X_pu_1<0)>0
%                 errorstack = [errorstack; 'Werte für R_pu_1 und X_pu_1 sollten nicht negativ sein!'];
%             end
%             % phase_voltage_2 / R_pu_2 / X_pu_2
%             if sum(obj.phase_voltage_2<0)>0||sum(obj.R_pu_2<0)>0||sum(obj.X_pu_2<0)>0
%                 errorstack = [errorstack; 'Werte für phase_voltage_2, R_pu_2 und sollten nicht negativ sein!'];
%             end
%             % L1_limbs / A1_limbs
%             if sum(obj.L1_limbs<0)>0||sum(obj.A1_limbs<0)>0
%                 errorstack = [errorstack; 'Werte für L1_limbs und A1_limbs sollten nicht negativ sein!'];
%             end
%             % L2_yokes / A2_yokes
%             if sum(obj.L2_yokes<0)>0||sum(obj.A2_yokes<0)>0
%                 errorstack = [errorstack; 'Werte für L2_yokes und A2_yokes sollten nicht negativ sein!'];
%             end
%             % L0_flux / A0_flux
%             if sum(obj.L0_flux<0)>0||sum(obj.A0_flux<0)>0
%                 errorstack = [errorstack; 'Werte für L0_flux und A0_flux sollten nicht negativ sein!'];
%             end
%             % winding1
%             if sum(obj.winding1<0)>0
%                 errorstack = [errorstack; 'Werte für winding1 und R_parallel_Series_L1_L2_L3 sollten nicht negativ sein!'];
%             end
%             % BH / active_power_losses_trafo
%             if sum(sum(obj.BH<0))>0||sum(obj.active_power_losses_trafo<0)>0
%                 errorstack = [errorstack; 'Werte für BH und active_power_losses_trafo sollten nicht negativ sein!'];
%             end
%             % flux_initialization / alle Trafokenngrößen
%             if (~isempty(obj.trafo_power)||~isempty(obj.phase_voltage_1)||~isempty(obj.R_pu_1)...
%                     ||~isempty(obj.X_pu_1)||~isempty(obj.phase_voltage_2)||~isempty(obj.R_pu_2)||~isempty(obj.X_pu_2)...
%                     ||~isempty(obj.L1_limbs)||~isempty(obj.A1_limbs)||~isempty(obj.L2_yokes)||~isempty(obj.A2_yokes)...
%                     ||~isempty(obj.L0_flux)||~isempty(obj.A0_flux)||~isempty(obj.winding1)||~isempty(obj.BH)...
%                     ||~isempty(obj.active_power_losses_trafo)||~isempty(obj.flux_initialization)||~isempty(obj.trafo_time_constant))...
%                     &&(isempty(obj.trafo_power)||isempty(obj.phase_voltage_1)||isempty(obj.R_pu_1)...
%                     ||isempty(obj.X_pu_1)||isempty(obj.phase_voltage_2)||isempty(obj.R_pu_2)||isempty(obj.X_pu_2)...
%                     ||isempty(obj.L1_limbs)||isempty(obj.A1_limbs)||isempty(obj.L2_yokes)||isempty(obj.A2_yokes)...
%                     ||isempty(obj.L0_flux)||isempty(obj.A0_flux)||isempty(obj.winding1)||isempty(obj.BH)...
%                     ||isempty(obj.active_power_losses_trafo)||isempty(obj.flux_initialization)||isempty(obj.trafo_time_constant))
%                 errorstack = [errorstack; 'Wenn flux_initialization angegeben wird, müssen auch alle anderen Trafokenngrößen angegeben werden!'];
%             end
%             % trafo_time_constant       
%             if sum(obj.trafo_time_constant<0)>0
%                 errorstack = [errorstack; 'Werte für trafo_time_constant sollten nicht negativ sein!'];
%             end
            % Speicherpfad       
            if isempty(obj.Speicherpfad)
                disp('Kein Speicherpfad angegeben, default-Speicherpfad wird genutzt!');
            end
            % User_ID
            if isempty(obj.User_ID)
                errorstack = [errorstack; 'Keine User_ID angegeben!'];
            end
            % Szenario_ID
            if isempty(obj.Szenario_ID)
                errorstack = [errorstack; 'Die Angabe der Szenario_ID fehlt!'];
            end
            
            if size(errorstack,1)>1
                obj.Fehlerliste = errorstack;
                obj.Status = 0;
            else
                obj.Status = 1;
            end
        end
    end
    
    methods (Access = protected)
                
        % Konstruktor 0: ohne Argumente
        function obj = Szenario0(obj)
            
        end
        % Konstruktor 1: mit aus *.xlsx geladenen Szenariendaten als Argument
        function obj = Szenario1(obj, SzenData)   
            try
            obj.Tsample = SzenData.Tsample;
            obj.Tsim = SzenData.Tsim;
            
            obj.tact = SzenData.tact;
            obj.tact_Amp = SzenData.tact_Amp;
            obj.tacts = SzenData.tacts;
            obj.tacts_Amp = SzenData.tacts_Amp;
            obj.tact_OS_Regler = SzenData.tact_OS_Regler;
            obj.OS_Regler = SzenData.OS_Regler;
            obj.QU_possibleON_OFF = SzenData.QU_possibleON_OFF;

            obj.Pl_Uns = SzenData.Pl_Uns;
            obj.Ql_ind_Uns = SzenData.Ql_ind_Uns;
            obj.Ql_kap_Uns = SzenData.Ql_kap_Uns;

            obj.Uns_L1_on_off_Zeitpunkte = SzenData.Uns_L1_on_off_Zeitpunkte;
            obj.Uns_L2_on_off_Zeitpunkte = SzenData.Uns_L2_on_off_Zeitpunkte;
            obj.Uns_L3_on_off_Zeitpunkte = SzenData.Uns_L3_on_off_Zeitpunkte;

            obj.RVC_L1_on_off_Zeitpunkte = SzenData.RVC_L1_on_off_Zeitpunkte;
            obj.RVC_L2_on_off_Zeitpunkte = SzenData.RVC_L2_on_off_Zeitpunkte;
            obj.RVC_L3_on_off_Zeitpunkte = SzenData.RVC_L3_on_off_Zeitpunkte;

            obj.Pl_RVC = SzenData.Pl_RVC;
            obj.Ql_ind_RVC = SzenData.Ql_ind_RVC;           % Blindleistung L1, L2, L3 [Var]
            obj.Ql_kap_RVC = SzenData.Ql_kap_RVC;

            obj.fak_RVC = SzenData.fak_RVC;

            obj.I_Basis_Ober = SzenData.I_Basis_Ober;
            obj.I_relativ_Ober_L1 = SzenData.I_relativ_Ober_L1;   % relativer Anteil von Basisstrom L1 [%] weitere Erklärung siehe S.
            obj.I_relativ_Ober_L2 = SzenData.I_relativ_Ober_L2;   % relativer Anteil von Basisstrom L2 [%] weitere Erklärung siehe S.
            obj.I_relativ_Ober_L3 = SzenData.I_relativ_Ober_L3;   % relativer Anteil von Basisstrom L3 [%] weitere Erklärung siehe S.

            obj.Vielfache_Ober_L1 = SzenData.Vielfache_Ober_L1;   % Vielfache auf 50Hz normiert L1[] weitere Erklärung siehe S.
            obj.Vielfache_Ober_L2 = SzenData.Vielfache_Ober_L2;   % Vielfache auf 50Hz normiert L2[] weitere Erklärung siehe S.
            obj.Vielfache_Ober_L3 = SzenData.Vielfache_Ober_L3;   % Vielfache auf 50Hz normiert L3[] weitere Erklärung siehe S.

            obj.Phi_Ober = SzenData.Phi_Ober;
            
            obj.Pl_Flicker = SzenData.Pl_Flicker;
            obj.Ql_ind_Flicker = SzenData.Ql_ind_Flicker;                % Blindleistung L1, L2, L3 [kVar]
            obj.Ql_kap_Flicker = SzenData.Ql_kap_Flicker;
            obj.Flicker_Frequenz = SzenData.Flicker_Frequenz;
            obj.Flicker_Start = SzenData.Flicker_Start;
            obj.Flicker_Dauer = SzenData.Flicker_Dauer;
            
            obj.Pl_Grund = SzenData.Pl_Grund;
            obj.Ql_ind_Grund = SzenData.Ql_ind_Grund;
            obj.Ql_kap_Grund = SzenData.Ql_kap_Grund;
            
            obj.Rtrans = SzenData.Rtrans;
            obj.Ltrans = SzenData.Ltrans;
            obj.strans = SzenData.strans;
            obj.fsw = SzenData.fsw;
            obj.Czk = SzenData.Czk;

            obj.L_Eingang_Shunt_L1_L2_L3_N = SzenData.L_Eingang_Shunt_L1_L2_L3_N;
            obj.R_Eingang_Shunt_L1_L2_L3_N = SzenData.R_Eingang_Shunt_L1_L2_L3_N;
            obj.L_Ausgang_Shunt_L1_L2_L3_N = SzenData.L_Ausgang_Shunt_L1_L2_L3_N;
            obj.R_Ausgang_Shunt_L1_L2_L3_N = SzenData.R_Ausgang_Shunt_L1_L2_L3_N;
            obj.C_parallel_Shunt_L1_L2_L3 = SzenData.C_parallel_Shunt_L1_L2_L3;
            obj.R_parallel_Shunt_L1_L2_L3 = SzenData.R_parallel_Shunt_L1_L2_L3;

            obj.L_Eingang_Series_L1_L2_L3_N = SzenData.L_Eingang_Series_L1_L2_L3_N;	
            obj.R_Eingang_Series_L1_L2_L3_N = SzenData.R_Eingang_Series_L1_L2_L3_N;
            obj.L_Ausgang_Series_L1_L2_L3_N = SzenData.L_Ausgang_Series_L1_L2_L3_N;	
            obj.R_Ausgang_Series_L1_L2_L3_N = SzenData.R_Ausgang_Series_L1_L2_L3_N;	
            obj.C_parallel_Series_L1_L2_L3 = SzenData.C_parallel_Series_L1_L2_L3;
            obj.R_parallel_Series_L1_L2_L3 = SzenData.R_parallel_Series_L1_L2_L3;

%             obj.trafo_power = SzenData.trafo_power;
%             obj.phase_voltage_1 = SzenData.phase_voltage_1;
%             obj.R_pu_1 = SzenData.R_pu_1;
%             obj.X_pu_1 = SzenData.X_pu_1;
%             obj.phase_voltage_2 = SzenData.phase_voltage_2;
%             obj.R_pu_2 = SzenData.R_pu_2;
%             obj.X_pu_2 = SzenData.X_pu_2;
%             obj.L1_limbs = SzenData.L1_limbs;
%             obj.A1_limbs = SzenData.A1_limbs;
%             obj.L2_yokes = SzenData.L2_yokes;
%             obj.A2_yokes = SzenData.A2_yokes;
%             obj.L0_flux = SzenData.L0_flux;
%             obj.A0_flux = SzenData.A0_flux;
%             obj.winding1 = SzenData.winding1;
% 
%             obj.BH = SzenData.BH;
%             obj.active_power_losses_trafo = SzenData.active_power_losses_trafo;
%             obj.flux_initialization = SzenData.flux_initialization;
%             obj.trafo_time_constant = SzenData.trafo_time_constant;
                    

            obj.Speicherpfad = SzenData.Speicherpfad;
            if ~exist(obj.Speicherpfad,'dir')
                % relevante Ordner zum Pfad hinzufügen (U-Quality)
                oldFolder = cd('../../..'); % Zwei Ebenen hoch springen
                aktPfad = pwd; % aktuellen Ordner und alle Unterordner zum Pfad hinzufügen
                cd(oldFolder); % wieder zurück springen
                obj.Speicherpfad = [aktPfad '\Ergebnisse'];
                if ~exist(obj.Speicherpfad,'dir')
                    mkdir(obj.Speicherpfad);
                end
            end
            obj.User_ID = SzenData.User_ID;
            obj.Szenario_ID = SzenData.Szenario_ID;
            obj.Status = -1;
%             obj.Speicherpfad = '\\srv-file01\ev\Projekte\alle Projekte\2019_U-Quality\Projektbearbeitung\U-Quality-Regler\Ergebnisse\';
            catch err
                disp(err);
            end
        end
          
    end % methods (protected)
end

