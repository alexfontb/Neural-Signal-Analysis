% =========================================================================
% NONLINEAR PREDICTION ERROR - PARAMETER SWEEP
% =========================================================================

%% 1. LOAD AND PREPARE DATA
data = load("EEG4.mat");    
EEG = data.EEG';              
channel_names = data.channelNameArray;  
Fs = 512;                       
target_fs = Fs / 2;             
downsample_factor = Fs / target_fs;

% Anti-aliasing filter
lowpass_cutoff = 100;  
d = designfilt('lowpassiir', 'FilterOrder', 4, ...
    'HalfPowerFrequency', lowpass_cutoff/(Fs/2), 'DesignMethod', 'butter');

% Select ONLY TWO contrasting segments to see the separability clearly
segments_sweep = {
    'anti-seizure PIR2', 'PIR2', 240, 260;
    'early seizure TPPL1', 'TPPL1', 180, 200;
    'seizure TPAL6', 'TPAL6', 240, 260;
    'rythm TBAL1', 'TBAL1', 220, 240;
    'final artifact TPAR4', 'TPAR4', 360, 380;
    'rythmic activity DER01', 'DER01', 320, 340;
    'artifacts TBAL1', 'TBAL1', 340, 360;
};
num_seg = size(segments_sweep, 1);
EEG_ready = cell(num_seg, 1);

% Pre-process the 2 segments
for s = 1:num_seg
    ch_idx = find(strcmp(channel_names, segments_sweep{s,2}));
    start_samp = segments_sweep{s,3} * Fs + 1;
    end_samp   = start_samp + 20*Fs - 1;  
    
    seg_raw = EEG(ch_idx, start_samp:end_samp);
    seg_filt = filtfilt(d, seg_raw);
    seg_down = downsample(seg_filt, downsample_factor);
    seg_norm = (seg_down - mean(seg_down)) / std(seg_down);
    EEG_ready{s} = seg_norm(1:min(5120, length(seg_norm)));
end

%% 2. BASELINE PARAMETERS
% These remain fixed while we sweep one specific parameter
base_m = 6;         
base_k = 3;         
base_tc = 30;       
base_h = 2;         
base_tau = 12; % Assuming it was a good value from your previous P vs Tau plot

%% 3. PARAMETER RANGES TO TEST
m_test  = [1, 2, 4, 5, 6, 8, 10];
k_test  = [1, 10, 30, 40, 60, 100];
tc_test = [1, 2, 5, 8, 50 ];
h_test  = [1, 2, 5, 7, 9, 50];
t_test = 1:3:49;

%% 4. RUN SWEEPS AND PLOT
figure;
colors = lines(num_seg); 

% ---- SWEEP 1: Embedding Dimension (m) ----
P_m = zeros(num_seg, length(m_test));
for s = 1:num_seg
    for i = 1:length(m_test)
        P_m(s,i) = nonlinear_pred_error2(EEG_ready{s}, m_test(i), base_tau, base_tc, base_k, base_h);
    end
end

hold on;
for s = 1:num_seg
    plot(m_test, P_m(s,:), '-o', 'Color', colors(s,:), 'LineWidth', 1.5); 
end

title('Influence of Embedding Dimension (m)'); 
xlabel('m'); 
ylabel('NPE');
legend(segments_sweep(:,1),'Location','best')
grid on;
hold off

%% 
% ---- SWEEP 2: Nearest Neighbors (k) ----
figure;

P_k = zeros(num_seg, length(k_test));
for s = 1:num_seg
    for i = 1:length(k_test)
        P_k(s,i) = nonlinear_pred_error2(EEG_ready{s}, base_m, base_tau, base_tc, k_test(i), base_h);
    end
end

hold on;
for s = 1:num_seg
    plot(k_test, P_k(s,:), '-o', 'Color', colors(s,:), 'LineWidth', 1.5); 
end
title('Influence of Neighbors (k)'); 
xlabel('k'); 
ylabel('NPE'); 
legend(segments_sweep(:,1),'Location','best')
grid on;
hold off

%% 
% ---- SWEEP 3: Theiler Window (tc) ----
figure;

P_tc = zeros(num_seg, length(tc_test));
for s = 1:num_seg
    for i = 1:length(tc_test)
        P_tc(s,i) = nonlinear_pred_error2(EEG_ready{s}, base_m, base_tau, tc_test(i), base_k, base_h);
    end
end
hold on;
for s = 1:num_seg
    plot(tc_test, P_tc(s,:), '-o', 'Color', colors(s,:), 'LineWidth', 1.5); 
end
title('Influence of Theiler Window (tc)'); 
xlabel('tc'); 
ylabel('NPE'); 
legend(segments_sweep(:,1),'Location','best')
grid on;
hold off

%%
% ---- SWEEP 4: Prediction Horizon (h) ----
figure;
colors = lines(num_seg); 
P_h = zeros(num_seg, length(h_test));
for s = 1:num_seg
    for i = 1:length(h_test)
        P_h(s,i) = nonlinear_pred_error2(EEG_ready{s}, base_m, base_tau, base_tc, base_k, h_test(i));
    end
end

hold on;
for s = 1:num_seg 
    plot(h_test, P_h(s,:), '-o', 'Color', colors(s,:), 'LineWidth', 1.5); 
end
title('Influence of Prediction Horizon (h)'); 
xlabel('h'); 
ylabel('NPE'); 
legend(segments_sweep(:,1),'Location','best')
grid on;
hold off

%%
% ---- SWEEP 5: Time delay (tau) ----
t_test = 1:3:49;
figure;
colors = lines(num_seg); 
P_t = zeros(num_seg, length(t_test));
for s = 1:num_seg
    for i = 1:length(t_test)
        P_t(s,i) = nonlinear_pred_error2(EEG_ready{s}, base_m, t_test(i), base_tc, base_k, base_h);
    end
end

hold on;
for s = 1:num_seg 
    plot(t_test, P_t(s,:), '-o', 'Color', colors(s,:), 'LineWidth', 1.5); 
end
title('Influence of Prediction Horizon (h)'); 
xlabel('h'); 
ylabel('NPE'); 
legend(segments_sweep(:,1),'Location','best')
grid on;
hold off