function eeg_viewer(data,fs)
    % 1. DATA LOADING
    % ---------------------------------------------------------
    % data = EEG data
    % fs = Sampling Frequency
    loaded = load(data);
    eeg_data = loaded.EEG;
    [num_samples, num_channels]  = size(eeg_data);  % Samples and channels number
    total_seconds = num_samples/fs;             % Total duration
    t_total = (0:1/fs:total_seconds-1/fs)';     % Time vector
    
    % 2. INITIAL PARAMETERS
    % ---------------------------------------------------------
    win_size = 20;          % 20 second window
    current_start_t = 0;    % Initial start time
    scale_factor = 1;       % Initial magnitude scaling

    % Calculate an offset to separate the channels vertically
    channel_offset = max(std(eeg_data)) * 5;

    % Offset vector to add to each channel
    offsets_vec = (0:num_channels-1) * channel_offset;

    % 3. CREATE FIGURE AND INITIAL PLOT
    % ---------------------------------------------------------
    hFig = figure('Name', 'Interactive EEG Viewer', ...
        'NumberTitle','off', 'Color', 'w', 'KeyPressFcn', ...
        @keyboardinteraction); % Assign callback

    hAx = axes('Parent', hFig); % Creates cartesian axis
    idx_end = round(win_size * fs);
    t_init = t_total(1:idx_end);
    data_init = (eeg_data(1:idx_end,:) * scale_factor) + offsets_vec;

    % Store the handle 'hLines' so we can modify it later
    hLines = plot(hAx, t_init, data_init, 'k');

    % Axis Labels and Title
    xlabel('Time (s)');
    ylabel('Channels');
    title('EEG viewer');

    % Adjust visualization limits
    xlim(hAx, [current_start_t, current_start_t + win_size]);
    ylim(hAx, [min(offsets_vec)-channel_offset, max(offsets_vec)+channel_offset]);

    set(hAx, 'YTick', offsets_vec); % Space channels appart
    set(hAx, 'YTickLabel', loaded.channelNameArray); % Label channels
    grid on;

    % 4. UPDATE LOGIC
    % ---------------------------------------------------------
    function updatePlot()
        % Calculate indices
        idx_start = round(current_start_t * fs) + 1;
        idx_end = round(current_start_t + win_size) * fs;

        % Try limits
        if idx_start < 1, idx_start = 1; end
        if idx_end > size(eeg_data, 1), idx_end = size(eeg_data, 1); end
        
        % Extract data segments
        t_segment = t_total(idx_start:idx_end);
        data_segment = eeg_data(idx_start:idx_end,:);
        
        % APPLY SCALE AND OFFSET
        % Formula: (Data * Scale) + (Vertical Position)
        data_to_plot = (data_segment * scale_factor) + repmat(offsets_vec, size(data_segment,1), 1);
        
        % PLOT
        % Convert matrix columns to a cell array
        y_cell = num2cell(data_to_plot, 1); 
        set(hLines, {'YData'}, y_cell'); % Update all lines at once
        set(hLines, 'XData', t_segment); % Update time

        % Adjust visualization limits
        xlim(hAx, [current_start_t, current_start_t + win_size]);
        ylim(hAx, [min(offsets_vec)-channel_offset, max(offsets_vec)+channel_offset]);
        
        drawnow limitrate;
    end

    % 5. KEYBOARD CALLBACK
    % ---------------------------------------------------------
    function keyboardinteraction(~, event)
        switch event.Key
            case 'rightarrow'
                % Advance 20 seconds
                if (current_start_t + win_size) < total_seconds
                    current_start_t = current_start_t + 20;
                    updatePlot();
                end
                
            case 'leftarrow'
                % Go back 20 seconds
                if current_start_t >= 20
                    current_start_t = current_start_t - 20;
                    updatePlot();
                elseif current_start_t > 0
                     current_start_t = 0; % 
                     updatePlot();
                end
                
            case 'uparrow'
                % Increase magnitude (Gain)
                scale_factor = scale_factor * 1.5; % Increase by 50%
                updatePlot();
                title(hAx, sprintf('Scale: %.2f', scale_factor));
                
            case 'downarrow'
                % Reduce magnitude (Gain)
                scale_factor = scale_factor / 1.5; % Reduce
                updatePlot();
                title(hAx, sprintf('Scale: %.2f', scale_factor));
        end
    end
end