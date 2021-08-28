

clear
close all
clc

addpath('./../dataset/')
addpath('./../lib/')
addpath('./../lib/operators')
addpath('./../lib/expleja/')
addpath('./../lib/export_fig-master')

%% PARAMETERS
% time domain go on till tt(end)
time         = [0 1000];
MAXITER      = 100;
printstep    = 1000;

imagenumber = [6 14 15 44];

reducecolorimage = false;

compute_osmosis  = true;
show_osmosis     = true;

flag_classic    = 1;



for imn = 1:numel(imagenumber)
    
    caseimage = imagenumber(imn);
    
    % CREATE DIRECTORIES
    dir_result = ['./results/',num2str(caseimage)];
    
    
    if ~exist(dir_result,'dir')
        mkdir(dir_result);
    end
    
    
    % READ IMAGE AND MASK + sigma,rho for structure tensor
    imagefile = ['./../dataset/shadow/',num2str(caseimage),'.png'];
    maskfile  = ['./../dataset/mask/',num2str(caseimage),'.png'];
    
    umat     = im2double(imread(imagefile));
    umask    = repmat(sum(im2double(imread(maskfile)),3)>0,[1 1 size(umat,3)]);
    
    if reducecolorimage && size(umat,3)>1
        umat = rgb2gray(umat);
    end
    
    pos_offset    = 1;
    v             = umat+pos_offset; % is the image for d=\grad\log v
    
       u_CLASSIC     = umat+pos_offset; % image to evolve in time
    
    
    
    %% SPATIAL DISCRETIZATION
    P3classic   = cell(3,1);
    
    
    
    
    
    
    
    % SPACE DISCRETISATION
    for kk=1:size(umat,3)
        
           [~, ~, P3classic{kk}] = osmosis_discretization(v(:,:,kk),umask(:,:,kk));
       
        
    end
    
    %% TIME INTEGRATION WITH  SHADOW REMOVAL METHODS
    for tt = 1:MAXITER
        
        for kk=1:size(umat,3)
            
                u_CLASSIC(:,:,kk)   = reshape(expleja(time(2),P3classic{kk}{1},reshape(u_CLASSIC(:,:,kk),[],1)),size(u_CLASSIC,1),size(u_CLASSIC,2));
            
            
        end
        
        
        %% FIGURE
        if show_osmosis
            
            [X,Y] = meshgrid(1:size(umat,2),size(umat,1):-1:1);
            
            h1=figure(1);
            
            subplot(2,4,1)
            imshow(v-pos_offset,[0,1])
            title(['T = 0'])
            
            
            
            
            
           
            
            
            subplot(2,4,5)
            imshow(u_CLASSIC-pos_offset,[0,1])
            title(['CLASSIC, T = ',num2str(tt*time(2))])
            
            
            
            truesize(h1,[300 300])
            
            pause(0.01)
            
        end
        
   
        
    end
    
    
       imshow(u_CLASSIC-pos_offset,[0,1])
       imwrite(u_CLASSIC-pos_offset,  [dir_result,'/',num2str(caseimage),'_classic.png'])
    
    
    
end


