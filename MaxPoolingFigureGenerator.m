clear; clc; close force all;

load('MarioRGB.mat');
gray_img = flipud(rgb2gray(RGB));

% Get image size
[n_rows, n_cols] = size(gray_img);

% Pad the grayscale image
padded_image = padarray(gray_img, [1, 1], 0, 'both');

% Define kernel
kernel = int16([0 -1 0; -1 9 -1; 0 -1 0]);

% Initialize convolved matrix
convolved_matrix = zeros(n_rows, n_cols, 'int16');

% Manual convolution
for i = 1:n_rows
    for j = 1:n_cols
        patch = int16(padded_image(i:i+2, j:j+2));
        convolved_matrix(i, j) = sum(sum(patch .* kernel));
    end
end

% Normalize convolved_matrix to [0, 1]
conv_min = double(min(convolved_matrix(:)));
conv_max = double(max(convolved_matrix(:)));
normalized_convolved = (double(convolved_matrix) - conv_min) / (conv_max - conv_min);
normalized_convolved(isnan(normalized_convolved)) = 0;

%% Grid setup
cell_size = 10;
gap = 20;

left_grid_x = 0;
right_grid_x = n_cols * cell_size + gap;

figure('Color', 'k');
axis equal off
set(gcf, 'Position', [100, 100, 2 * n_cols * cell_size + 200, n_rows * cell_size + 100]);

% Draw left grid (convolved input)
for row = 1:n_rows
    for col = 1:n_cols
        val = normalized_convolved(row, col);
        rectangle('Position', [(col - 1) * cell_size, (row - 1) * cell_size, cell_size, cell_size], ...
                  'EdgeColor', 'w', 'LineWidth', 1, ...
                  'FaceColor', [val val val]);
    end
end

%% Max pooling setup
pool_size = 2;
[pool_rows, pool_cols] = deal(floor(n_rows / pool_size), floor(n_cols / pool_size));
pooled_matrix = zeros(pool_rows, pool_cols);

% Draw right grid (pooled output)
for row = 1:pool_rows
    for col = 1:pool_cols
        x = right_grid_x + (col - 1) * cell_size;
        y = (row - 1) * cell_size;
        rectangle('Position', [x+cell_size*pool_cols/2, y+cell_size*pool_rows/2, cell_size, cell_size], ...
                  'EdgeColor', 'w', 'LineWidth', 1, ...
                  'FaceColor', [0 0 0]);
    end
end

pause(2);

%% Animate max pooling
for i = pool_rows:-1:1
    for j = 1:pool_cols
        r_start = (i - 1) * pool_size + 1;
        c_start = (j - 1) * pool_size + 1;

        block = normalized_convolved(r_start:r_start+1, c_start:c_start+1);
        [max_val, max_idx] = min(block(:));
        [rel_i, rel_j] = ind2sub([2, 2], max_idx);

        % Highlight 2x2 block on left grid
        for m = 0:1
            for n = 0:1
                x = left_grid_x + (c_start + n - 1) * cell_size;
                y = (r_start + m - 1) * cell_size;
                rectangle('Position', [x, y, cell_size, cell_size], ...
                          'EdgeColor', 'y', 'LineWidth', 2);
            end
        end

        % Highlight max cell
        max_x = left_grid_x + (c_start + rel_j - 1) * cell_size;
        max_y = (r_start + rel_i - 1) * cell_size;
        rectangle('Position', [max_x-cell_size, max_y-cell_size, cell_size, cell_size], ...
                  'EdgeColor', 'g', 'LineWidth', 4);

        % Update right grid (pooled value)
        x_pool = right_grid_x + (j - 1) * cell_size;
        y_pool = (i - 1) * cell_size;
        rectangle('Position', [x_pool+cell_size*pool_cols/2, y_pool+cell_size*pool_rows/2, cell_size, cell_size], ...
                  'EdgeColor', 'g', 'LineWidth', 4, ...
                  'FaceColor', [max_val max_val max_val]);

        pause(0.1);

        % Remove highlights
        delete(findall(gcf, 'Type', 'rectangle', 'LineWidth', 2));
        delete(findall(gcf, 'Type', 'rectangle', 'LineWidth', 4));
        rectangle('Position', [x_pool+cell_size*pool_cols/2, y_pool+cell_size*pool_rows/2, cell_size, cell_size], ...
                  'EdgeColor', 'w', 'LineWidth', 1, ...
                  'FaceColor', [max_val max_val max_val]);
    end
end

pause(2);

%%
