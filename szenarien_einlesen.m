function [szenarien, status] = szenarien_einlesen(datei,sheet)

try
    szenarien_input = readtable(datei, 'Sheet', sheet,'Format','auto');
    szenarien_input(szenarien_input.Flag==0,:)=[]; %löschen von Szenarien nicht zu betrachtenden Szenarien
    AnzSzen = size(szenarien_input,1);
    %Initialisierung Szenarien
    for i = 1:AnzSzen
        szenarien.(['Szen' num2str(i)]) = [];
    end
    ok = true; % Flag zur Prüfung auf NaN in Szenarien.Properties
    
    for i = 1:AnzSzen
        SzenData.Tsample = szenarien_input{i,'Tsample'};
        SzenData.Tsim = szenarien_input{i,'Tsim'}; 
        
        SzenData.Pl_Uns = strInput2double(szenarien_input{i,'Pl_Uns'},';');
        SzenData.Ql_ind_Uns = strInput2double(szenarien_input{i,'Ql_ind_Uns'},';');
        SzenData.Ql_kap_Uns = strInput2double(szenarien_input{i,'Ql_kap_Uns'},';');
        
        SzenData.Uns_L1_on_off_Zeitpunkte = strInput2double(szenarien_input{i,'Uns_L1_on_off_Zeitpunkte'},',');
        SzenData.Uns_L2_on_off_Zeitpunkte = strInput2double(szenarien_input{i,'Uns_L2_on_off_Zeitpunkte'},',');
        SzenData.Uns_L3_on_off_Zeitpunkte = strInput2double(szenarien_input{i,'Uns_L3_on_off_Zeitpunkte'},',');
        
        SzenData.RVC_L1_on_off_Zeitpunkte = strInput2double(szenarien_input{i,'RVC_L1_on_off_Zeitpunkte'},',');
        SzenData.RVC_L2_on_off_Zeitpunkte = strInput2double(szenarien_input{i,'RVC_L2_on_off_Zeitpunkte'},',');
        SzenData.RVC_L3_on_off_Zeitpunkte = strInput2double(szenarien_input{i,'RVC_L3_on_off_Zeitpunkte'},',');
        
        SzenData.Pl_RVC = strInput2double(szenarien_input{i,'Pl_RVC'},';');
        SzenData.QLL_RVC = strInput2double(szenarien_input{i,'Ql_ind_RVC'},';');                % Blindleistung L1, L2, L3 [Var]
        SzenData.QCL_RVC = strInput2double(szenarien_input{i,'Ql_kap_RVC'},';');

        SzenData.fak_RVC = strInput2double(szenarien_input{i,'fak_RVC'},','); 
        SzenData.I_Basis_Ober = strInput2double(szenarien_input{i,'I_Basis_Ober'},';');
        
        SzenData.I_relativ_Ober_L1 = strInput2double(szenarien_input{i,'I_relativ_Ober_L1'},' ');    % relativer Anteil von Basisstrom L1 [%] weitere Erklärung siehe S.
        SzenData.I_relativ_Ober_L2 = strInput2double(szenarien_input{i,'I_relativ_Ober_L2'},' ');    % relativer Anteil von Basisstrom L2 [%] weitere Erklärung siehe S.
        SzenData.I_relativ_Ober_L3 = strInput2double(szenarien_input{i,'I_relativ_Ober_L3'},' ');    % relativer Anteil von Basisstrom L3 [%] weitere Erklärung siehe S.

        SzenData.Vielfache_Ober_L1 = strInput2double(szenarien_input{i,'Vielfache_Ober_L1'},' '); %Vielfache auf 50Hz normiert L1[] weitere Erklärung siehe S.
        SzenData.Vielfache_Ober_L2 = strInput2double(szenarien_input{i,'Vielfache_Ober_L2'},' '); %Vielfache auf 50Hz normiert L2[] weitere Erklärung siehe S.
        SzenData.Vielfache_Ober_L3 = strInput2double(szenarien_input{i,'Vielfache_Ober_L3'},' '); %Vielfache auf 50Hz normiert L3[] weitere Erklärung siehe S.

        SzenData.Phi_Ober = strInput2double(szenarien_input{i,'Phi_Ober'},' ');
        SzenData.I_Basis_Flick = strInput2double(szenarien_input{i,'I_Basis_Flick'},' ');
        SzenData.Pl_Grund = strInput2double(szenarien_input{i,'Pl_Grund'},';');
        
        SzenData.Speicherpfad = cell2mat(szenarien_input{i,'Speicherpfad'});
        SzenData.User_ID = cell2mat(szenarien_input{i,'User_ID'});
        SzenData.Szenario_ID = szenarien_input{i,'Szenario_ID'};

        akt_Szenario = Szenario(SzenData);
        akt_Szenario = checkPropertiesForNaN(akt_Szenario);
        if akt_Szenario.Status == false
            ok = false;
        end
        szenarien.(['Szen' num2str(i)]) = akt_Szenario;
    end

    if ok
        status = 1;
    else
        status = 0; 
    end
catch err
    disp(err.message);
    status = -1;
    szenarien = [];
end

    disp('test');
end