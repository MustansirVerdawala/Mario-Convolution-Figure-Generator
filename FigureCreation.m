clear, clc, close force all;

load('MarioRGB.mat')

% Create the figure
figure;
set(gcf, 'Color', 'black', 'Position', [0, 0, 1512, 982]);
axis off;
hold on;

% Desired cell size (perfect square)
cell_size = 50; % Size of each cell (50x50 units)

% Number of rows and columns in each grid
[n_rows, n_cols, ~] = size(RGB);

% Gap between the two grids
gap = 500; % Gap in units

RGB = flipud(RGB);

% Left grid (starting at x = 0)
left_grid_x = 0;

% Right grid (starting after the gap)
right_grid_x = n_cols * cell_size + gap;

ka_size = 3; % 3x3 kernel

% Initialize a 3x3 kernel with random values
kernel = ([1 0 -1; 2, 0, -2; 1, 0, -1]);
sobx=[1 0 -1; 2 0 -2; 1 0 -1];
soby=[1 2 1; 0 0 0; -1 -2 -1];

% edge_enhance = [1 0 -1; 2, 0, -2; 1, 0, -1];
% edge_enhance = [-1 -1 -1; -1 9 -1; -1 -1 -1];
edge_enhance = [0 -1 0; -1 9 -1; 0 -1 0];

% Pad the RGB matrix with zeros (to handle edge cases)
padded_matrix = padarray(rgb2gray(RGB), [1, 1], 0, 'both'); % Zero-padding

% Create the left grid
for row = 1:n_rows
    for col = 1:n_cols
        % Calculate the position of each cell
        x_start = left_grid_x + (col - 1) * cell_size;
        y_start = (row - 1) * cell_size;
        
        % Extract color and normalize
        color = double(squeeze(RGB(row, col, :)))' / 255;

        % Draw cell
        rectangle('Position', [x_start, y_start, cell_size, cell_size], ...
                  'EdgeColor', 'w', 'LineWidth', 1, 'FaceColor', color);
    end
end

% Create the right grid (initially black)
for row = 1:n_rows
    for col = 1:n_cols
        x_start = right_grid_x + (col - 1) * cell_size;
        y_start = (row - 1) * cell_size;
        rectangle('Position', [x_start, y_start, cell_size, cell_size], ...
                  'EdgeColor', 'w', 'LineWidth', 1, 'FaceColor', [0 0 0]);
    end
end



% Initialize the kernel rectangle
h_kernel = rectangle('Position', [0, 0, ka_size * cell_size, ka_size * cell_size], ...
                     'EdgeColor', 'w', 'LineWidth', 4);

axis equal;
xlim([left_grid_x-50, right_grid_x + n_cols * cell_size]); % Fix x-axis limits
ylim([-50, n_rows * cell_size+50]); % Fix y-axis limits
set(gca, 'XColor', 'none', 'YColor', 'none'); % Hide axis lines

% Convolution operation
convolved_matrix = zeros(n_rows, n_cols); % Store RGB convolved values

pause(3);

for i = n_rows:-1:1
    for j = 1:n_cols
        % Extract the 3x3 region for each color channel
        if i + 2 <= size(padded_matrix, 1) && j + 2 <= size(padded_matrix, 2)
            sub_matrix = padded_matrix(i:(i+2), j:(j+2));
            
            % Apply kernel to each channel separately
            convolved_matrix(i, j) = sum(sum(double(sub_matrix(:,:)) .* edge_enhance));
        end
        
        % Normalize convolved value
        convolved_value_norm = (convolved_matrix(i, j) - min(convolved_matrix(:))) / (max(convolved_matrix(:)) - min(convolved_matrix(:)));

        if convolved_value_norm == inf
            convolved_value_norm = 1;
        end

        if isnan(convolved_value_norm)
            convolved_value_norm = 0;
        end

        % Convert to grayscale
        color = [convolved_value_norm, convolved_value_norm, convolved_value_norm];
        
        % Update right grid with highlighted boundary
        x_start_right = right_grid_x + (j - 1) * cell_size;
        y_start_right = (i - 1) * cell_size;
        
        % Highlight cell with thick border
        h_highlight = rectangle('Position', [x_start_right, y_start_right, cell_size, cell_size], ...
                  'EdgeColor', 'y', 'LineWidth', 4, 'FaceColor', 1-color);

        % Pause briefly for visualization
        pause(0.000000005);

        % Update the cell with the normal boundary
        delete(h_highlight);
        rectangle('Position', [x_start_right, y_start_right, cell_size, cell_size], ...
                  'EdgeColor', 'w', 'LineWidth', 1, 'FaceColor', 1-color);

        % Update kernel position
        x_start = left_grid_x + (j - 2) * cell_size;
        y_start = (i - 2) * cell_size;
        set(h_kernel, 'Position', [x_start, y_start, ka_size * cell_size, ka_size * cell_size]);

        % Clear previous kernel texts
        delete(findall(gcf, 'Type', 'text'));
        
        % Overlay kernel values on the left grid
        for k = -1:1
            for l = -1:1
                if (i + k) >= 1 && (i + k) <= n_rows && (j + l) >= 1 && (j + l) <= n_cols
                    x_text = left_grid_x + (j + l - 1) * cell_size + cell_size / 2;
                    y_text = (i + k - 1) * cell_size + cell_size / 2;
                    kernel_value = edge_enhance(k+2, l+2);
                    
                    text(x_text, y_text, num2str(round(kernel_value, 2)), ...
                         'FontSize', 12, 'FontWeight', 'bold', ...
                         'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                         'Color', 'w');
                end
            end
        end

        pause(0.0000001); % Animation
    end
end

pause(2); % Final pause
