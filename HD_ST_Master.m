function [] = HD_ST_Master()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Clear variable space
clear all
clc

%% Load tsv spot table
st_spot_table = readtable('CN13_D2_filtered_red_ut.csv','Delimiter','\t');
%st_spot_table = readtable('CN21_E2_filtered_red_ut.csv','Delimiter','\t');

%% Load mask
st_sc_mask_raw = imread('CN13_D2_HE_Probabilities_mask.tiff');
st_sc_mask= flipud(st_sc_mask_raw);
%st_sc_mask = imread('CN21_E2_HE_Probabilities_mask.tiff');

% Extract x and y from regionprops
mask_centroid = regionprops(st_sc_mask,'centroid');
for i=1:length(mask_centroid)
    x_centroid(i) = mask_centroid(i).Centroid(1)';
    y_centroid(i) = mask_centroid(i).Centroid(2)';
end

%% Extract all CellID's for the spot location
% Flip centroid to align with spots
%y_centroid=-(y_centroid-min(y_centroid))+(max(y_centroid));

% Extract unique values
[unique_spots,unique_value_location,ic] = unique(st_spot_table.bc,'stable');

% Extract only the unique values
unique_x = round(st_spot_table.spot_px_x(unique_value_location));
unique_y = round(st_spot_table.spot_px_y(unique_value_location));
unique_bc = st_spot_table.bc(unique_value_location);

% Extract the overlap with the mask
for i=1:size(unique_spots,1)
    unique_bc{i,2} = st_sc_mask(unique_y(i,1),unique_x(i,1));
    if unique_bc{i,2} == 0
        continue
    else
    unique_bc{i,3} = x_centroid(1,unique_bc{i,2});
    unique_bc{i,4} = y_centroid(1,unique_bc{i,2});
    end
end

export_table = cell2table(unique_bc,'VariableNames',...
    {'bc','cell_id','x_centroid','y_centroid'});

%% Plot for QC
% Plot image for unique barcodes
figure()
scatter(cell2mat(unique_bc(:,3)),cell2mat(unique_bc(:,4)));
% Plot mask centroids
figure()
scatter(x_centroid,y_centroid);
% Plot barcode beads
figure()
scatter(st_spot_table.spot_px_x,st_spot_table.spot_px_y);

%% Export CSV
writetable(export_table,'CellID_Spot_Position_CN21_E2_filtered_red_ut.csv');

end

