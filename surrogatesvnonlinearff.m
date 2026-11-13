%% ================== PARAMETERS ==================
m = 6; % Embedding dimension
k = 3; % number of nearest neighbors
Tw = 30; % Theiler window
h = 2; % Prediction horizon
tau_values = 1:3:49; % Tau values to test
num_surrogates = 6; % Several surrogates to eliminate random component
window_duration = 20; % Window duration in seconds

%% ================== LOAD EEG ==================
data = load('EEG4.mat');
EEG = data.EEG';
channel_names = data.channelNameArray;
Fs = 512;
target_fs = Fs/2;
downsample_factor = Fs/target_fs;

%% ================== CHANNELS & WINDOWS ==================
% Channels we want to analyze
channels_to_analyze = {'TPPR1', 'TPPR3', 'TBAL1'};

% Starts of the windows to analyze
window_starts = [40, 280, 300]; 
num_windows = length(window_starts);

%% ================== FILTER ==================
lowpass_cutoff = 100; 
d = designfilt('lowpassiir', ...
    'FilterOrder',4, ...
    'HalfPowerFrequency',lowpass_cutoff/(Fs/2), ...
    'DesignMethod','butter');

%% ================== MAIN LOOP ==================
tic
for c = 1:length(channels_to_analyze)
    channel_name = channels_to_analyze{c};
    channel_idx = find(strcmp(channel_names, channel_name));
    
    fprintf('Processing channel: %s\n', channel_name)
    
    %% ---- Create figure for this channel ----
    fig = figure('Name',['Channel: ' channel_name]);
    ax = axes('Parent', fig); % Create fixed axes to avoid bugs
    hold(ax, 'on');
    title(['NLPE vs \tau - Channel: ' channel_name])
    xlabel(ax, '\tau')
    ylabel(ax, 'NLPE')
    grid(ax,"on")

    colors = lines(num_windows);
    legend_entries = cell(1, num_windows*2);
    h_plots = gobjects(1,num_windows*2); % Save the lines
    
    %% ================== LOOP DE VENTANAS ==================
    for w = 1:num_windows
        t_start = window_starts(w);
        fprintf('  -> Extrayendo ventana en t = %d s\n', t_start);
        
        % Extraer ventana de 20 segundos
        start_sample = t_start * Fs + 1;
        end_sample   = start_sample + window_duration * Fs - 1;
        EEG_segment = EEG(channel_idx, start_sample:end_sample);
        
        % Filtrar + Downsample
        EEG_filtered = filtfilt(d, EEG_segment);
        EEG_ds = downsample(EEG_filtered, downsample_factor);
        
        % Normalizar
        EEG_norm = (EEG_ds - mean(EEG_ds)) / std(EEG_ds);
        EEG_final = EEG_norm; % A 256Hz, 20s son exactamente 5120 muestras
        
        %% ---- Generar Surrogates (Fuera del bucle de Tau) ----
        surrogate_signals = cell(num_surrogates, 1);
        for sur = 1:num_surrogates
            temp_surr = phase_randomized_surrogate(EEG_final);
            % Eliminar parte imaginaria residual de ifft
            temp_surr = real(temp_surr); 
            % Normalizar
            surrogate_signals{sur} = (temp_surr - mean(temp_surr)) / std(temp_surr);
        end
        
        %% ================== NPE ==================
        num_tau = length(tau_values);
        P_real = zeros(1, num_tau);
        P_surr = zeros(1, num_tau);
        
        for i = 1:num_tau
            tau = tau_values(i);
            
            % REAL 
            P_real(i) = nonlinear_pred_error2(EEG_final, m, tau, Tw, k, h);
            
            % SURROGATES
            s_errors = zeros(num_surrogates, 1);
            for sur = 1:num_surrogates
                s_errors(sur) = nonlinear_pred_error2(surrogate_signals{sur}, m, tau, Tw, k, h);
            end
            P_surr(i) = mean(s_errors);
        end
        
        %% ---- PLOT DE ESTA VENTANA ----
        h_plots(2*w-1) = plot(ax, tau_values, P_real, '-o', 'Color', colors(w,:), 'LineWidth', 1.8);
        h_plots(2*w) = plot(ax, tau_values, P_surr, '--*', 'Color', colors(w,:), 'LineWidth', 1.8);
        
        % Preparar leyenda
        legend_entries{2*w-1} = sprintf('Win %ds - Real', t_start);
        legend_entries{2*w}   = sprintf('Win %ds - Surrogate', t_start);
        drawnow 
    end
    
    legend(legend_entries, 'Location', 'northeastoutside')
    hold off
end
elapsed_time = toc;
fprintf('Total time: %.2f seconds\n', elapsed_time)