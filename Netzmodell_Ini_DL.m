% Skript zur Initialisierung und Steuerung des Netzmodells und der
% Simulationen
%1) Wahl der Simulationszeit/parameter
%2) Ein-/Auskommentieren der Lasten
%3) Wahl der Regler und Filter
%4) Wahl/Einschalten der runner
%5) Netzmodellparameter


clearvars -except Szenario Netzmodell_oeffnen iterSzen itdelF fig event d berechne_fields berechne_field app

Last_Unsymmetrie = 0;
Last_Grundlast = 0;
Last_Flicker = 0;
Last_Oberschwingung = 0;
Last_RVC = 0;

%Einheitenvorsaetze
k = 1e3;
m = 1e-3;
u = 1e-6;
try
    %% 1) Simulationsparameter
    Tsample = Szenario.Tsample;                                % Rechenraster in s
    Tsim =  Szenario.Tsim;                                     % Simulationszeit in s
    
   % noch 3) UPQC Filter Auswahl
   %aktuell (27.06.2022 nur L-Filter (Wert=0) möglich, weil keine Parameterwerte für LCL vorhanden)
    UPQC_Filter_Shunt = 2;                          % UPQC Filter Auswahl 0=L; 1=LC; 2=LCL
    UPQC_Filter_Series = 2;                         % UPQC Filter Auswahl 0=L; 1=LC; 2=LCL
    
  %% Änderungen für OS-Regler durch SaSi
    %%!!!!
    RateTransitionForFFTSampleTime = 1/200000;
    OutputBufferSizeForFFT = 4000;
    OverlapBufferForFFT = 3999;
    
  %%
    OS_on = 1;
    OS_off = 6;
    
  %%
    
    R_ZK_Belastung = 20;
    ZK_Belastung_on = 100;
    ZK_Belastung_off = 100;
    
    
    %% 5) Netzmodell
    %Netz
    Us_LL = 400;                                % LeiterLeiter-Spannung nominal
    Us_Amp = sqrt(2)*400/sqrt(3);                       % Leiter-Erde-Spannung nominal
    f_nom = 50;                                 % 50 Hertz Netzfrequenz
    
    %Spannungsquelle
    Us = [Us_Amp; Us_Amp; Us_Amp];              % Amplitude der Quellenspannung [V]
    Phis = [0; -120; 120];                      % Phase L1, L2, L3 [°]
    fs = [f_nom; f_nom; f_nom];                 % Frequenz L1, L2, L3 [Hz]
    
    Rs_in = 5.2*m/10; %8.23*m;                     % Innenwiderstand Spg-Q in Ohm
    Ls_in = 52.2*u/10; %77.056*u;                  % Inneninduktivitaet Spq-Q in H
    % /10 zur Erhöhung der KS Leistung an der Quelle
    % R/X = 0,47 % 0,34  --> sehr induktiv
    
    %Umrechnung in p.u.
    Vpu = 1/(Us_LL*sqrt(2)/sqrt(3));
    
    %% Leitungsnachbildung
    Rtrans = Szenario.Rtrans;                   % Widerstandsbelag in Ohm/km
    Ltrans = Szenario.Ltrans*m;                 % Induktivitaetsbelag in H/km
    strans = Szenario.strans;                   % Leitungslaenge in km
    
    %% zu 3) UPQC-Control
    fsw = Szenario.fsw*k;                       % Schaltfrequenz
    % Ts_Control = 1/(10*fsw);          Gibt es nicht mehr 15.03.2022 Joachim
    % Ts_PWM = 2/fsw;                             % Sampling PWM
    
    Zwischenkreisspannung = 700;                % Zwischenkreisspannung
       
    %% zu 5) Trafo Parameter
    %aktuell (27.06.2022 Trafo mit festen Werten im Modell, Variablen für
    %Trafomodell(Wechsel notwendig), numerisch nur bei sehr kleiner
    %Schrittweite nutzbar
    %mod SaSi. Auf 0 gesetzt 25.11.2021
    %mod SaSi. 0 funktioniert nicht, da sehr hohe einschaltströme. 0.14
    %besser
%     trafo_power = Szenario.trafo_power; %Three-phase rated power(VA)
    %trafo_f = f_nom;%Frequency
    
    %     %Winding 1: phase voltage(Vrms); R(pu); X(pu);
    %     phase_voltage_1 = Szenario.phase_voltage_1;
    %     R_pu_1 = Szenario.R_pu_1;
    %     X_pu_1 = Szenario.X_pu_1;
    %
    %     %Winding 2: phase voltage(Vrms); R(pu); X(pu);
    %     phase_voltage_2 = Szenario.phase_voltage_2;
    %     R_pu_2 = Szenario.R_pu_2;
    %     X_pu_2 = Szenario.X_pu_2;
    %
    %     %Average length and section of core limbs; L1(m); A1(m^2)
    %     L1_limbs = Szenario.L1_limbs;
    %     A1_limbs = Szenario.A1_limbs;
    %
    %     %Average length and ssection of yokes;  L2(m); A2(m^2)
    %     L2_yokes = Szenario.L2_yokes;
    %     A2_yokes = Szenario.A2_yokes;
    %
    %     %Average length and section of air path for zero-sequence flux return;L0(m); A0(m^2)
    %     L0_flux = Szenario.L0_flux;
    %     A0_flux = Szenario.A0_flux;
    %
    %     winding1 = Szenario.winding1; %Number of turns of winding 1
    %     BH = Szenario.BH;%B-H characteristic of iron core [H1(A/m) B1(T); ...]
    %
    %     active_power_losses_trafo = Szenario.active_power_losses_trafo;%Active power losses in iron @ 1pu voltage (W)
    %     flux_initialization = Szenario.flux_initialization;%Voltages for flux initialization [VmagA VmagB VmagC (pu) VangleA VangleB VangleC (deg)]
    %
    %     trafo_time_constant = Szenario.trafo_time_constant;%Time constant to break algebraic loop Td(S)
    
    %% zu 2) Lasten Parameter
    
    %Last Unsymmetrie (Uns)
    Pl_Uns=Szenario.Pl_Uns;
    Ql_ind_Uns=Szenario.Ql_ind_Uns;
    Ql_kap_Uns=Szenario.Ql_kap_Uns;
    Uns_L1_on_off_Zeitpunkte = Szenario.Uns_L1_on_off_Zeitpunkte;
    Uns_L2_on_off_Zeitpunkte = Szenario.Uns_L2_on_off_Zeitpunkte;
    Uns_L3_on_off_Zeitpunkte = Szenario.Uns_L3_on_off_Zeitpunkte;
    
    if( ~isempty(Uns_L1_on_off_Zeitpunkte)&&~isempty(Uns_L2_on_off_Zeitpunkte)&&~isempty(Uns_L3_on_off_Zeitpunkte)&&~isempty(Pl_Uns) )
        
        Last_Unsymmetrie=1;
        %     cosphi_Uns = 0.9;                                 %Leistungsfaktor
        %     Aenderung der Blindleistung auf fixe Werte und nicht durch Umrechnung
        %     mit cosphi_Uns - Ermöglicht reinen "Phasenschieberbetrieb"
        
        Pl_Uns = Pl_Uns*k;                                  % Wirkleistung L1, L2, L3 [kW]
        Ql_ind_Uns = Ql_ind_Uns*k;                          % induktive Blindleistung L1, L2, L3 [kvar]
        Ql_kap_Uns = Ql_kap_Uns*k;                          % kapazitive Blindleistung L1, L2, L3 [kvar]
        Ql_abs_Uns = Ql_ind_Uns - Ql_kap_Uns;
        cosphi_Uns = 1;
        
        if ~isempty(Ql_abs_Uns)
            Sl_Uns = sqrt(Pl_Uns.^2 + Ql_abs_Uns.^2);
            cosphi_Uns = Pl_Uns ./ Sl_Uns;
        end
        
        fak_Uns = [1; 1; 1];                                % Faktor fuer Lasterhoehung L1, L2, L3
    end
    
    %% Quelle RVC
    %RVC einstellbar an der Quelle 
    RVC_on = 20; %Startzeit
    RVC_off = 20.5;%Stopp
    RVC_val = [0.8,0.8,0.8]; %Sprung auf diese Prozentzahl => z.B. 80% 0.8= 400/Wurzel(3)*0.8
    
    %% Last RVC (RVC)
    RVC_L1_on_off_Zeitpunkte = Szenario.RVC_L1_on_off_Zeitpunkte;
    RVC_L2_on_off_Zeitpunkte = Szenario.RVC_L2_on_off_Zeitpunkte;
    RVC_L3_on_off_Zeitpunkte = Szenario.RVC_L3_on_off_Zeitpunkte;
    Pl_RVC = Szenario.Pl_RVC;
    Ql_ind_RVC = Szenario.Ql_ind_RVC;
    Ql_kap_RVC = Szenario.Ql_kap_RVC;
    fak_RVC = Szenario.fak_RVC;   % Faktor fuer Lasterhoehung L1, L2, L3
    
    if( ~isempty(RVC_L1_on_off_Zeitpunkte)&&~isempty(RVC_L2_on_off_Zeitpunkte)&&~isempty(RVC_L3_on_off_Zeitpunkte)&&~isempty(Pl_RVC)&&~isempty(Ql_ind_RVC)&&~isempty(Ql_kap_RVC) )
        Last_RVC = 1;
        
        %     cosphi_RVC_ind = 0.9;                               %Leistungsfaktor
        %     cosphi_RVC_kap = 1;
        
        Pl_RVC = Pl_RVC*k;                           % Wirkleistung L1, L2, L3 [kW]
        Ql_ind_RVC = Szenario.Ql_ind_RVC*k;                % Blindleistung L1, L2, L3 [Var]
        Ql_kap_RVC = Szenario.Ql_kap_RVC*k;
        fak_RVC = Szenario.fak_RVC;                            % Faktor fuer Lasterhoehung L1, L2, L3
    end
    
    %% Last Oberschwingung (Ober)
    I_Basis_Ober=Szenario.I_Basis_Ober;
    if ~isempty(I_Basis_Ober)
        Last_Oberschwingung = 1;
        I_Basis_Ober_L1 = I_Basis_Ober(1);                  %Basisstrom_Amp L1 [A]
        I_Basis_Ober_L2 = I_Basis_Ober(2);                  %Basisstrom_Amp L2 [A]
        I_Basis_Ober_L3 = I_Basis_Ober(3);                  %Basisstrom_Amp L3 [A]
        
        I_relativ_Ober_L1 = Szenario.I_relativ_Ober_L1;     % relativer Anteil von Basisstrom L1 [%] weitere Erklärung siehe S.
        I_relativ_Ober_L2 = Szenario.I_relativ_Ober_L2;     % relativer Anteil von Basisstrom L2 [%] weitere Erklärung siehe S.
        I_relativ_Ober_L3 = Szenario.I_relativ_Ober_L3;     % relativer Anteil von Basisstrom L3 [%] weitere Erklärung siehe S.
        
        Vielfache_Ober_L1 = Szenario.Vielfache_Ober_L1;     %Vielfache auf 50Hz normiert L1[] weitere Erklärung siehe S.
        Vielfache_Ober_L2 = Szenario.Vielfache_Ober_L2;     %Vielfache auf 50Hz normiert L2[] weitere Erklärung siehe S.
        Vielfache_Ober_L3 = Szenario.Vielfache_Ober_L3;     %Vielfache auf 50Hz normiert L3[] weitere Erklärung siehe S.
        
        Phi_Ober = Szenario.Phi_Ober;
        Phi_Ober_L1 = Phi_Ober(1);                          %Phase L1 [°]
        Phi_Ober_L2 = Phi_Ober(2);                          %Phase L2 [°]
        Phi_Ober_L3 = Phi_Ober(3);                          %Phase L3 [°]
    end
    
    %% Last Flicker (Flick)
    
    Flicker_Frequenz = Szenario.Flicker_Frequenz';
    Flicker_Start=Szenario.Flicker_Start';
    Flicker_Dauer = Szenario.Flicker_Dauer';
    Pl_Flicker = Szenario.Pl_Flicker;
    Ql_ind_Flicker = Szenario.Ql_ind_Flicker;                % Blindleistung L1, L2, L3 [Var]
    Ql_kap_Flicker = Szenario.Ql_kap_Flicker;
    
    if(~isempty(Flicker_Frequenz)&&~isempty(Flicker_Dauer)&&~isempty(Pl_Flicker)&&~isempty(Ql_ind_Flicker)&&~isempty(Ql_kap_Flicker))
        Last_Flicker = 1;
        
        %     cosphi_Flicker_ind = 0.9;                               %Leistungsfaktor
        %     cosphi_Flicker_kap = 1;
        
        Pl_Flicker = Pl_Flicker*k;                           % Wirkleistung L1, L2, L3 [kW]
        Ql_ind_Flicker = Ql_ind_Flicker*k;                % Blindleistung L1, L2, L3 [Var]
        Ql_kap_Flicker = Ql_kap_Flicker*k;
        
        % Schaltzeitpunkte Flickerlast aus Frequenz und Dauer bestimmen
        Zuschaltzeitpunkt = Flicker_Start;
        Schaltinterval = 1./Flicker_Frequenz;
        Abschaltzeitpunkt = min(Zuschaltzeitpunkt+Flicker_Dauer,Tsim);
        Schaltzeitpunkte = Zuschaltzeitpunkt;
        t = Zuschaltzeitpunkt;
        while t+Schaltinterval < Abschaltzeitpunkt 
            Schaltzeitpunkte = [Schaltzeitpunkte t+Schaltinterval];
            t = t + Schaltinterval;
        end
    
    Flicker_Schaltzeitpunkte_L1 = Schaltzeitpunkte(1,:);
    Flicker_Schaltzeitpunkte_L2 = Schaltzeitpunkte(2,:);
    Flicker_Schaltzeitpunkte_L3 = Schaltzeitpunkte(3,:);
    end
    %% Last Grundlast (Grund)
    Pl_Grund = Szenario.Pl_Grund *k;
    
    if ~isempty(Pl_Grund)
        Last_Grundlast = 1;
        
        Ql_ind_Grund = Szenario.Ql_ind_Grund*k;                % Blindleistung L1, L2, L3 [kVar]
        Ql_kap_Grund = Szenario.Ql_kap_Grund*k;
    end
    
    %% zu 3) Filterparameter Shunt
    
    L_Eingang_Shunt=zeros(1,4);
    L_Ausgang_Shunt=zeros(1,4);
    R_Eingang_Shunt=zeros(1,4);
    R_Ausgang_Shunt=zeros(1,4);
    C_parallel_Shunt=zeros(1,4);
    R_parallel_Shunt=zeros(1,4);
    
    %L1
    L_Eingang_Shunt(1,1) = Szenario.L_Eingang_Shunt_L1_L2_L3_N(1)*m;                                    % L UPQC Seite  für L, LC, LCL-Filter Parameter setzen [H]
    R_Eingang_Shunt(1,1) = Szenario.R_Eingang_Shunt_L1_L2_L3_N(1);                                    % R UPQC Seite  für L, LC, LCL-Filter Parameter setzen [Ohm]
    
    L_Ausgang_Shunt(1,1) = Szenario.L_Ausgang_Shunt_L1_L2_L3_N(1)*m;                                    % L Netz Seite  für LCL-Filter Parameter setzen [H]
    R_Ausgang_Shunt(1,1) = Szenario.R_Ausgang_Shunt_L1_L2_L3_N(1);                                    % R Netz Seite  für LCL-Filter Parameter setzen [Ohm]
    
    C_parallel_Shunt(1,1) = Szenario.C_parallel_Shunt_L1_L2_L3(1)*u;                                 % C zwischen UPQC und Netz parallel für LC, LCL-Filter Parameter setzen [H]
    R_parallel_Shunt(1,1) = Szenario.R_parallel_Shunt_L1_L2_L3(1);                                     % R zwischen UPQC und Netz parallel für LC, LCL-Filter Parameter setzen [Ohm]
    
    %L2
    L_Eingang_Shunt(1,2) = Szenario.L_Eingang_Shunt_L1_L2_L3_N(2)*m;                                    % L UPQC Seite  für L, LC, LCL-Filter Parameter setzen [H]
    R_Eingang_Shunt(1,2) = Szenario.R_Eingang_Shunt_L1_L2_L3_N(2);                                   % R UPQC Seite  für L, LC, LCL-Filter Parameter setzen [Ohm]
    
    L_Ausgang_Shunt(1,2) = Szenario.L_Ausgang_Shunt_L1_L2_L3_N(2)*m;                                   % L Netz Seite  für LCL-Filter Parameter setzen [H]
    R_Ausgang_Shunt(1,2) = Szenario.R_Ausgang_Shunt_L1_L2_L3_N(2);                                    % R Netz Seite  für LCL-Filter Parameter setzen [Ohm]
    
    C_parallel_Shunt(1,2) = Szenario.C_parallel_Shunt_L1_L2_L3(2)*u;                                 % C zwischen UPQC und Netz parallel für LC, LCL-Filter Parameter setzen [H]
    R_parallel_Shunt(1,2) = Szenario.R_parallel_Shunt_L1_L2_L3(2);                                     % R zwischen UPQC und Netz parallel für LC, LCL-Filter Parameter setzen [Ohm]
    
    %L3
    L_Eingang_Shunt(1,3) = Szenario.L_Eingang_Shunt_L1_L2_L3_N(3)*m;                                    % L UPQC Seite  für L, LC, LCL-Filter Parameter setzen [H]
    R_Eingang_Shunt(1,3) = Szenario.R_Eingang_Shunt_L1_L2_L3_N(3);                                    % R UPQC Seite  für L, LC, LCL-Filter Parameter setzen [Ohm]
    
    L_Ausgang_Shunt(1,3) = Szenario.L_Ausgang_Shunt_L1_L2_L3_N(3)*m;                                    % L Netz Seite  für LCL-Filter Parameter setzen [H]
    R_Ausgang_Shunt(1,3) = Szenario.R_Ausgang_Shunt_L1_L2_L3_N(3);                                   % R Netz Seite  für LCL-Filter Parameter setzen [Ohm]
    
    C_parallel_Shunt(1,3) = Szenario.C_parallel_Shunt_L1_L2_L3(3)*u;                                 % C zwischen UPQC und Netz parallel für LC, LCL-Filter Parameter setzen [H]
    R_parallel_Shunt(1,3) = Szenario.R_parallel_Shunt_L1_L2_L3(3);                                     % R zwischen UPQC und Netz parallel für LC, LCL-Filter Parameter setzen [Ohm]
    
    %N
    L_Eingang_Shunt(1,4) = Szenario.L_Eingang_Shunt_L1_L2_L3_N(4)*m;                                     % L UPQC Seite  für L, LC, LCL-Filter Parameter setzen [H]
    R_Eingang_Shunt(1,4) = Szenario.R_Eingang_Shunt_L1_L2_L3_N(4);                                    % R UPQC Seite  für L, LC, LCL-Filter Parameter setzen [Ohm]
    
    L_Ausgang_Shunt(1,4) = Szenario.L_Ausgang_Shunt_L1_L2_L3_N(4)*m;                                     % L Netz Seite  für LCL-Filter Parameter setzen [H]
    R_Ausgang_Shunt(1,4) = Szenario.R_Ausgang_Shunt_L1_L2_L3_N(4);                                     % R Netz Seite  für LCL-Filter Parameter setzen [Ohm]
    
    
    %% zu 3) Filterparameter Series
    
    L_Eingang_Series=zeros(1,4);
    L_Ausgang_Series=zeros(1,4);
    R_Eingang_Series=zeros(1,4);
    R_Ausgang_Series=zeros(1,4);
    C_parallel_Series=zeros(1,4);
    R_parallel_Series=zeros(1,4);
    
    %L1
    L_Eingang_Series(1,1) = Szenario.L_Eingang_Series_L1_L2_L3_N(1)*m;                                    % L UPQC Seite  für L, LC, LCL-Filter Parameter setzen [H]
    R_Eingang_Series(1,1) = Szenario.R_Eingang_Series_L1_L2_L3_N(1);                                    % R UPQC Seite  für L, LC, LCL-Filter Parameter setzen [Ohm]
    
    L_Ausgang_Series(1,1) = Szenario.L_Ausgang_Series_L1_L2_L3_N(1)*m;                                    % L Netz Seite  für LCL-Filter Parameter setzen [H]
    R_Ausgang_Series(1,1) = Szenario.R_Ausgang_Series_L1_L2_L3_N(1);                                    % R Netz Seite  für LCL-Filter Parameter setzen [Ohm]
    
    C_parallel_Series(1,1) = Szenario.C_parallel_Series_L1_L2_L3(1)*u;                                 % C zwischen UPQC und Netz parallel für LC, LCL-Filter Parameter setzen [H]
    R_parallel_Series(1,1) = Szenario.R_parallel_Series_L1_L2_L3(1);                                     % R zwischen UPQC und Netz parallel für LC, LCL-Filter Parameter setzen [Ohm]
    
    %L2
    L_Eingang_Series(1,2) = Szenario.L_Eingang_Series_L1_L2_L3_N(2)*m;                                    % L UPQC Seite  für L, LC, LCL-Filter Parameter setzen [H]
    R_Eingang_Series(1,2) = Szenario.R_Eingang_Series_L1_L2_L3_N(2);                                    % R UPQC Seite  für L, LC, LCL-Filter Parameter setzen [Ohm]
    
    L_Ausgang_Series(1,2) = Szenario.L_Ausgang_Series_L1_L2_L3_N(2)*m;                                    % L Netz Seite  für LCL-Filter Parameter setzen [H]
    R_Ausgang_Series(1,2) = Szenario.R_Ausgang_Series_L1_L2_L3_N(2);                                    % R Netz Seite  für LCL-Filter Parameter setzen [Ohm]
    
    C_parallel_Series(1,2) = Szenario.C_parallel_Series_L1_L2_L3(2)*u;                                 % C zwischen UPQC und Netz parallel für LC, LCL-Filter Parameter setzen [H]
    R_parallel_Series(1,2) = Szenario.R_parallel_Series_L1_L2_L3(2);                                     % R zwischen UPQC und Netz parallel für LC, LCL-Filter Parameter setzen [Ohm]
    
    %L3
    L_Eingang_Series(1,3) = Szenario.L_Eingang_Series_L1_L2_L3_N(3)*m;                                    % L UPQC Seite  für L, LC, LCL-Filter Parameter setzen [H]
    R_Eingang_Series(1,3) = Szenario.R_Eingang_Series_L1_L2_L3_N(3);                                    % R UPQC Seite  für L, LC, LCL-Filter Parameter setzen [Ohm]
    
    L_Ausgang_Series(1,3) = Szenario.L_Ausgang_Series_L1_L2_L3_N(3)*m;                                    % L Netz Seite  für LCL-Filter Parameter setzen [H]
    R_Ausgang_Series(1,3) = Szenario.R_Ausgang_Series_L1_L2_L3_N(3);                                    % R Netz Seite  für LCL-Filter Parameter setzen [Ohm]
    
    C_parallel_Series(1,3) = Szenario.C_parallel_Series_L1_L2_L3(3)*u;                                 % C zwischen UPQC und Netz parallel für LC, LCL-Filter Parameter setzen [H]
    R_parallel_Series(1,3) = Szenario.R_parallel_Series_L1_L2_L3(3);                                     % R zwischen UPQC und Netz parallel für LC, LCL-Filter Parameter setzen [Ohm]
    
    %N
    L_Eingang_Series(1,4) = Szenario.L_Eingang_Series_L1_L2_L3_N(4)*m;                                    % L UPQC Seite  für L, LC, LCL-Filter Parameter setzen [H]
    R_Eingang_Series(1,4) = Szenario.R_Eingang_Series_L1_L2_L3_N(4);                                    % R UPQC Seite  für L, LC, LCL-Filter Parameter setzen [Ohm]
    
    L_Ausgang_Series(1,4) = Szenario.L_Ausgang_Series_L1_L2_L3_N(4)*m;                                    % L Netz Seite  für LCL-Filter Parameter setzen [H]
    R_Ausgang_Series(1,4) = Szenario.R_Ausgang_Series_L1_L2_L3_N(4);                                    % R Netz Seite  für LCL-Filter Parameter setzen [Ohm]
    
    %% Simulinkmodell öffnen/laden
    if ~Netzmodell_oeffnen
        load_system('UPQC_model'); % lädt Simulink Modell
        disp('Simulink Netzmodell laden')
    else
        open_system('UPQC_model');  % öffnet Simulink Modell, ggf. to-do: prüfen, ob im Hintergrund zu öffnen
        disp('Simulink Netzmodell öffnen')                                  % Rückmeldung in Konsole
    end
    %% zu 2) Lasten aus/ein-kommentieren
    if(Last_Unsymmetrie == 1)                                           % Last Unsymmetrie on/off
        set_param('UPQC_model/Unsymmetrie Last','commented','off');
    else
        set_param('UPQC_model/Unsymmetrie Last','commented','on');
    end
    
    if(Last_Oberschwingung == 1)                                        % Last Oberschwingunge on/off
        set_param('UPQC_model/Oberschwingung Last','commented','off');
    else
        set_param('UPQC_model/Oberschwingung Last','commented','on');
    end
    
    if(Last_RVC == 1)                                                   % Last RVC on/off
        set_param('UPQC_model/RVC Last','commented','off');
    else
        set_param('UPQC_model/RVC Last','commented','on');
    end
    
    if(Last_Flicker == 1)                                               % Last Flicker on/off
        set_param('UPQC_model/Flicker Last','commented','off');
    else
        set_param('UPQC_model/Flicker Last','commented','on');
    end
    
    if(Last_Grundlast == 1)                                             % Last Grundlast on/off
        set_param('UPQC_model/Grundlast','commented','off');
    else
        set_param('UPQC_model/Grundlast','commented','on');
    end
    
    %% zu 3) Filter aus/ein-kommentieren Shunt
    
    if(UPQC_Filter_Shunt == 0)                                              % 0 = L-Filter
        set_param('UPQC_model/L Filter Shunt','commented','off');               % Schalte L Filter ein
        set_param('UPQC_model/LC Filter Shunt','commented','on');               % kommentiere LC Filter aus
        set_param('UPQC_model/LCL Filter Shunt','commented','on');              % kommentiere LCL Filter aus
    elseif (UPQC_Filter_Shunt == 1)                                         % 1 = LC-Filter
        set_param('UPQC_model/LC Filter Shunt','commented','off');              % Schalte LC Filter ein
        set_param('UPQC_model/L Filter Shunt','commented','on');                % kommentiere L Filter aus
        set_param('UPQC_model/LCL Filter Shunt','commented','on');              % kommentiere LCL Filter aus
    elseif (UPQC_Filter_Shunt == 2)                                         % 2 = L-Filter
        set_param('UPQC_model/LCL Filter Shunt','commented','off');             % Schalte LCL Filter ein
        set_param('UPQC_model/LC Filter Shunt','commented','on');               % kommentiere LC Filter aus
        set_param('UPQC_model/L Filter Shunt','commented','on');                % kommentiere L Filter aus
    end
    
    %% zu 3) Filter aus/ein-kommentieren Series
    
    if(UPQC_Filter_Series == 0)                                              % 0 = L-Filter
        set_param('UPQC_model/L Filter Series','commented','off');               % Schalte L Filter ein
        set_param('UPQC_model/LC Filter Series','commented','on');               % kommentiere LC Filter aus
        set_param('UPQC_model/LCL Filter Series','commented','on');              % kommentiere LCL Filter aus
    elseif (UPQC_Filter_Series == 1)                                         % 1 = LC-Filter
        set_param('UPQC_model/LC Filter Series','commented','off');              % Schalte LC Filter ein
        set_param('UPQC_model/L Filter Series','commented','on');                % kommentiere L Filter aus
        set_param('UPQC_model/LCL Filter Series','commented','on');              % kommentiere LCL Filter aus
    elseif (UPQC_Filter_Series == 2)                                         % 2 = L-Filter
        set_param('UPQC_model/LCL Filter Series','commented','off');             % Schalte LCL Filter ein
        set_param('UPQC_model/LC Filter Series','commented','on');               % kommentiere LC Filter aus
        set_param('UPQC_model/L Filter Series','commented','on');                % kommentiere L Filter aus
    end
    
    %% zu 3) UPQC Shunt on/off
    set_param('UPQC_model/Three-Phase Breaker Shunt','InitialState','open')
    set_param('UPQC_model/N Breaker Shunt','InitialState','0') %hier aller erstes Mal, wenn modell lebt, Breaker o
    
    %% zu 3) UPQC Series on/off
    set_param('UPQC_model/L1 Breaker Series','InitialState','1')
    set_param('UPQC_model/L2 Breaker Series','InitialState','1')
    set_param('UPQC_model/L3 Breaker Series','InitialState','1')
    
    %     set_param('UPQC_model/L1a Breaker Series','InitialState','0')
    %     set_param('UPQC_model/L2a Breaker Series','InitialState','0')
    %     set_param('UPQC_model/L3a Breaker Series','InitialState','0')
    
    %% Oberschwingungsregler
    if( Szenario.OS_Regler == 0)  
        set_param('UPQC_model/Shunt UPQC/Shuntkompensator/FFT_OS_Regler_L1','commented','on');               
        set_param('UPQC_model/Shunt UPQC/Shuntkompensator/FFT_OS_Regler_L2','commented','on');               
        set_param('UPQC_model/Shunt UPQC/Shuntkompensator/FFT_OS_Regler_L3','commented','on'); 
       
    elseif(Szenario.OS_Regler == 1)                                              
        set_param('UPQC_model/Shunt UPQC/Shuntkompensator/FFT_OS_Regler_L1','commented','on');               
        set_param('UPQC_model/Shunt UPQC/Shuntkompensator/FFT_OS_Regler_L2','commented','on');               
        set_param('UPQC_model/Shunt UPQC/Shuntkompensator/FFT_OS_Regler_L3','commented','on'); 
      
    elseif (Szenario.OS_Regler == 2)                                         
        set_param('UPQC_model/Shunt UPQC/Shuntkompensator/FFT_OS_Regler_L1','commented','off');            
        set_param('UPQC_model/Shunt UPQC/Shuntkompensator/FFT_OS_Regler_L2','commented','off');              
        set_param('UPQC_model/Shunt UPQC/Shuntkompensator/FFT_OS_Regler_L3','commented','off');  
    end
    
    
    
    %% Simulationsparameter bzgl. Regler
    tact_QU = 10;
    tact = Szenario.tact;                           % Einschaltzeitpunkt Shuntkompensator
    tact_Amp = Szenario.tact_Amp;                   % Amplitude muss bei AN 1 und bei AUS 0 sein!!
    tacts = Szenario.tacts;                         % Einschaltzeitpunkt Serienkompensator
    tacts_Amp = Szenario.tacts_Amp;                 % Amplitude muss bei AN 1 und bei AUS 0 sein!!
    tact_OS_Regler = Szenario.tact_OS_Regler;
    t_breaker_series = tacts;    % Zuschaltung Serientrafo 0 heißt breaker machen bei 0s auf - Trafo ist zugeschaltet
    t_breaker_shunt = tact;    % Zuschaltzeitpunkt in s wenn nicht zugeschaltet werden soll t größer als Simulationszeit machen

    
    % mode = 0;                Gibt es nicht mehr 15.03.22 Joachim                       % Sollwerte: 1 für P0, Q0, Ps2, Pc2, 0 für P0, Q0, Qs2, Qc2
    QU_actv = Szenario.QU_possibleON_OFF;           % 1 für Max-Auswahl zwischen QLast und Q(U), 0 für QLast
    
    % Anlagendimensionierung
%     Pnom = 50*k;      gibt es nicht mehr 15.03.22 Joachim                              % nominale Leistung des UPQC
%     Unom_sek = 400;                                 % nominale VSC-Ausgangsspannung (LL)
    % Ipu = sqrt(3)*Us_LL/sqrt(2)/Pnom;               % --> 1 pu = 102 A
    % peak, 72 A Nennstrom, Auskommentiert 20.10.2021 was macht dieser
    % Parameter?
    
    % Zwischenkreisspannung
    Udc = 700;%XXX aufräumen
    Udc_init = 0;                                   % Initialwert
    UDC_Soll = Udc;                                 % Soll-Zwischenkreisspannung
    
    % Kondensator:
    Czk = Szenario.Czk*u;                           % Zwischenkreiskapazität
    
    %%Series_Regler
    Unom = 400*sqrt(2)/sqrt(3);                     % Sollspannungsamplitude
    
    %Stromregelung-PI-Regler Shunt
    CC_Ki=5; %50  % Geht für Stromquellenmodell und WR Modell 10.08.22 von 500 auf 50
    CC_Kp=10; %  Geht für Stromquellenmodell und WR Modell
    
    CC_Ki_geg=5;%50 %noch zu bestimmen auch für Stromquellenmodell | 11.08. ->50
    CC_Kp_geg=10; %noch zu bestimmen
    
    % Stromregelung PI-Regler Shunt OS
    % Stromregelung PI-Regler Shunt OS
    CC_OS.Kp1=200;
    CC_OS.Ki1=300;
    CC_OS.Kp3=200;
    CC_OS.Ki3=300;
    CC_OS.Kp2=10; %200; % Fuer Stromquellenmodell Kp4 = 50
    CC_OS.Ki2=20;%300; % Fuer Stromquellenmodell Ki4 = 30    
    CC_OS.Kp4=10; %200; % Fuer Stromquellenmodell Kp4 = 50
    CC_OS.Ki4=20;%300; % Fuer Stromquellenmodell Ki4 = 30
    CC_OS.Kp5=10;%200; % Fuer Stromquellenmodell Kp5 = 50 
    CC_OS.Ki5=20;%300; % Fuer Stromquellenmodell Kp5 = 30    
    CC_OS.Kp7=10;
    CC_OS.Ki7=20;
    CC_OS.Kp8=10;
    CC_OS.Ki8=20;    
    CC_OS.Kp19=10;
    CC_OS.Ki19=20;     
    %Spannungsregelung PI-Regler Series
    VC_Ki_mit=5;   % Zwischenstand 16.08.: vor allen Veränderungen 50
    VC_Kp_mit=10;    % Zwischenstand 16.08.: vor allen Veränderungen 5
    
%     VC_Ki_mit=2;    %langsam
%     VC_Kp_mit=0.3; %langsam
    VC_Ki_gegen=30; % Vor Änderungen am 16.08.: Ki 50 Kp 5.... ki 10, kp 1
    VC_Kp_gegen=5;
    %Spannungsregelung PI-Regler Zwischenkreis
    VC_ZK_Ki=5;
    VC_ZK_Kp=0.5;
    
    % Spannungsregelung Unsymmetrie Shunt
    VC_Kp_gegen_shunt = 2;
    VC_Ki_gegen_shunt = 15;
%     alt: 15.03.22 Joachim  
%     Kpu = 5;                                       % 10 für Darstellung des ü-Verhältnis, 20 für besser Performance aber höhere Rückwirkung im Einschaltmmoment
%     Kiu = 15;                                      % manuelle Kalibration
%     
%      Kpug = 5;
%      Kiug = 15;%10;
    

    
    %% Shunt-Regler
    
    % PWM+Stromrichtermodell: e^(-Tu*s) approximiert durch PT1
    % Tu = 0.5*Ts_PWM;                     % 1.5*1/fsw
    
    %    Vorzeichen:   Id pos = VSC gibt P ab
    %                  Iq neg = VSC generiert Blindleistung (Q pos; kapazitiv)
    
    % Zbase = Us_LL^2/Pnom
    % Lstat=Lstat_pu*Zbase/(2*pi*Fnom);
    % Rstat=Rstat_pu*Zbase;
    
    Refrate = 250/2;  %XXX                              % Gradientlimitierung Sollwert in A/s; 250 entspricht 5 A pro Netzperiode
    
    %% Scopes
    % jetzt die Scopes initialisieren
    % zunaechst alle Scopes im Netzmodell finden und auskommentieren
    scope_list_netzmodell = find_system('UPQC_model','LookUnderMasks','on','IncludeCommented','on',...
        'AllBlocks','on','BlockType','Scope','DefaultConfigurationName',...
        'Simulink.scopes.TimeScopeBlockCfg');
    for its_mdl = 1:size(scope_list_netzmodell,1)
        set_param(char(scope_list_netzmodell{its_mdl}),'commented','on');
    end
    % danach nur explizit zu betrachtenden Scopes aus Liste "Scopes.csv"
    % (aktiv == 1) wieder einkommentieren
    Scopes = app.get_Scopes();
    for its = 1:size(Scopes,1)
        if Scopes{its,'aktiv'}==1
            set_param(char(Scopes{its,'BlockName'}),'commented','off');
        end
    end
    
    %---------------------------
    
%         h = find_system('UPQC_model','BlockType','Scope');
%         for k = 1:length(h)
%             set_param(h{k},'SaveToWorkspace','off'); % switch logging on/off by replacing 'on' by 'off' and vice versa, use this passage manually
%         end
    
    %----------------------------
    
catch err
    disp(err.message);
    disp(['Na toll, ein Fehler in Zeile ' num2str(err.stack(1).line) ' von ' err.stack(1).name '!']);
    close(fig);
    error('!!!Alles kaputt!!!');
end

%% Workspace nach Durchlauf Netzmodell_Ini speichern
loeschen=[]; % pre-allocation Variable für zu löschende Variablen (damit bei 'who' bekannt)
wsvars = who; % alle Variablen des WS holen
loeschen = false(size(wsvars,1),1); % mit 'nicht-löschen' initialisieren
for it = 1:size(wsvars,1) % Variablen auswählen die nicht gespeichert werden sollen
    if (strcmp(wsvars{it},'app') || strcmp(wsvars{it},'d') || strcmp(wsvars{it},'event')||...
            strcmp(wsvars{it},'fig')|| strcmp(wsvars{it},'iterSzen')|| strcmp(wsvars{it},'Netzmodell_oeffnen')||...
            strcmp(wsvars{it},'Szenario')||strcmp(wsvars{it},'S')|| strcmp(wsvars{it},'loeschen')|| strcmp(wsvars{it},'wsvars'))
        loeschen(it) = true;
    else
        loeschen(it) = false;
    end
end
vars = wsvars;
vars(loeschen) = [];
save('workspace_Ini.mat', vars{:});
save_system('UPQC_model',[],'OverwriteIfChangedOnDisk',true);

%% Ende Ini
disp('Ini Script lief durch');                                         % Ende Script keine Fehler Ausgabe
clear(vars{:});

