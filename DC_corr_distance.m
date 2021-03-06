function [corr_list, p_list, dist_list, bin_bounds, bin_count, corr_bin, p_bin, p_bin_percent, p_bin_count]=DC_corr_distance(Z_data, center_data, bin_num, bin_size, bin_scale, p_corr)

        %--------INPUTS---------
        %Z_data is your Z (or F) traces of cells of interest, with each column being a seperate ROI
        %
        %center_data are your coordinates for the center of your ROI, with each column being a seperate ROI
        %   The first row is the X value, the second row is Y value. SEE CODE BELOW FOR EASY CONVERSION TO THIS FORMAT.
        %
        %p_corr is a threshold for p value you set to check if a number of pairs is significantly correlated. 0.05 is
        %   the default value if no value is entered.
        %
        %bin_num is the maximum number of bins you would like to generate. The first bin 
        %   always starts at distance 0 and the final bin has no upper bound. If the final
        %   bin would have no values in it, it is removed automatically.
        %
        %bin_size is the size of each bin in the scale you set with bin_scale
        %
        %bin_scale is the scale of your image, in um/pixel. If not set, default is 1 and bins are in terms of pixels.
        %
        %--------OUTPUTS--------
        %corr_list is a list of R values for all possible combinations
        %
        %p_list is the probability of any two pairs being randomly correlated. Same format as corr_list.
        %
        %dist_list is the distances between all possible pairs. Same format as corr_list.
        %
        %bin_bounds are the bounds of the bin, where each column is a seperate bin. The lower bound
        %   is given in the first row, and distances equal to this are used. The upper bound is given
        %   in the second row. All distances less than, but not equal to, are in this bin.
        %
        %bin_count are the number of ROIs sorted into each bin
        %
        %corr_bin are the correlations of all pairs of bins sorted by bin_bounds. Each column is a bin.
        %
        %p_bin are p_list values sorted into bins according to bin_bounds. Each column is a bin.
        %
        %p_bin_percent are the percentage of pairs in a bin that are significantly correlated with each other,
        %   using the p-value set by p_corr.
        %
        %p_bin_count are the raw counts of the number of pairs in a bin that are significantly correlated,
        %   using the p-value set by p_corr.
        %
        %===============ROI CONVERSION CODE====================================
        %Use the following code to convert ROI_list data into the appropriate format for center_data
        %THIS CODE DOES NOT AUTOMATICALLY EXCLUDE ANY ROIS!!!
        %ANY EXCLUSION CRITERIA YOU INTRODUCE MUST BE RE-APPLIED HERE!!!
        %FAILURE WILL LIKELY RESULT IN A DIMENSION MISMATCH!!!
%        
%         center_data=zeros(2,size(ROI_list,2)); %Initialize 0 matrix
%         for i=1:size(ROI_list,2) %checks every ROI generated by DC_calcium or similar code
%             center_data(1,i)=ROI_list(1,i).centerPos(2); %gets X values
%             center_data(2,i)=ROI_list(1,i).centerPos(1); %gets Y values
%         end
%        
        %=============END ROI CONVERSION CODE==================================
        
        
        
        %==============INITIALIZE DEFAULT VALUES IF NOT SET====================
        if nargin<6
            p_corr=0.05;
        end
        
        if nargin<5
            bin_scale=1;
        end
        %==============INITIALIZE DEFAULT VALUES IF NOT SET====================
        
        
        
        %===========CALCULATE AND SORT CORRELATIONS AND DISTANCES=======================
        %[Rcorr,Pcorr]=corrcoef(Z_data,'Mode','pearson','rows','all'); %this
        %version for MATLAB 2012a
        [Rcorr,Pcorr]=corrcoef(Z_data,'rows','all'); %this version for MATLAB 2009b
        
        
        %calculate distances for all pairs
        dist_calc=zeros(size(center_data,2)); %generates a zero matrix of similar size to that generated by the corrcoef function
        for i=1:size(center_data,2)
            for j=1:size(center_data,2)
                dist_calc(i,j)=sqrt((center_data(1,i)-center_data(1,j))^2+(center_data(2,i)-center_data(2,j))^2); %distance formula!
            end
        end

        
        %initiatlize variables for sorting matrices (with redundancies) into lists (without redundancies)
        Rsize=size(Rcorr,1);%calculates size
        corr_list=zeros((Rsize^2-Rsize)/2,1); %makes an empty column matrix for R values
        p_list=corr_list; %makes same 0 matrix
        p_count=corr_list; %makes 0 matrix, used in later section of code
        dist_list=corr_list; %same 0 matrix
        Rcount=1;
        
        
        %Sort matrices into lists
        for i=1:Rsize-1
            for j=i+1:Rsize
                corr_list(Rcount)=Rcorr(j,i); %puts corr data into list
                p_list(Rcount)=Pcorr(j,i); %puts p data into list
                dist_list(Rcount)=dist_calc(j,i); %puts distance data into list
                Rcount=Rcount+1;
            end
        end
        %=========END CALCULATE AND SORT CORRELATIONS AND DISTANCES=======================
        
            
        
        %===============================BIN DATA BY DISTANCES=============================
        
        %Convert distance data by bin_scale (given in um/pixel, or any other unit of ditance/pixel)
        dist_list=dist_list*bin_scale;
       
        
        %calculate p values less than threshold        
        %p_count was initialized in previous part of code. Value is set to 1 if significant value.
        for i=1:size(p_count,1)
            if p_list(i)<p_corr
                p_count(i)=1;
            end
        end
        
        
        %calculate bin bounds
        bin_bounds=zeros(2,bin_num); %initialize 0 matrix
        last_bin=0; %starts binning at 0
        for i=1:bin_num
            bin_bounds(1,i)=last_bin;
            last_bin=last_bin+bin_size;
            bin_bounds(2,i)=last_bin;
        end
        bin_bounds(end,end)=9E99; %sets last bounds to effectively infinite
        
        
        %calculates all bins except final bin position
        bin_count=zeros(1,bin_num);
        for bin=1:(bin_num) 
            for num=1:size(corr_list,1)
                if dist_list(num)>=bin_bounds(1,bin) %checks if greater than or equal to lower bound
                    if dist_list(num)<bin_bounds(2,bin) %checks if less than upper bound
                        bin_count(bin)=bin_count(bin)+1; %counts number of entries in a bin
                        corr_bin(bin_count(bin),bin)=corr_list(num,1); %bins correlations
                        p_bin(bin_count(bin),bin)=p_list(num,1); %bins p values
                        p_bin_count(bin_count(bin),bin)=p_count(num,1); %bins p counts
                    end
                end
            end
        end
   
        
        %Changes 0s in bins to NaN. Use nanmean to look at means with values containing NaN.
        for i=1:size(corr_bin,1)
            for j=1:size(corr_bin,2)
                if corr_bin(i,j)==0
                    corr_bin(i,j)=NaN;
                    p_bin(i,j)=NaN;
                end
            end
        end
                    
        
        %finds proportion of probabilistically-correlated pairs by bins
        p_bin_percent=zeros(1,bin);
        for bin=1:bin_num
            if bin_count(1,bin)==0
                p_bin_percent(bin)=NaN;
            else
                p_bin_percent(bin)=sum(p_bin_count(:,bin))/bin_count(1,bin);
            end
        end

            
        %=============================END BIN DATA BY DISTANCES=========================
        
        
        
        %==========================GRAPH FUNCTIONAL CONNECTIVITY MAP====================        
        img_width=256; % #hardcode
        img_height=128; % #hardcode
        line_weight=5; % #hardcode
        DC_draw_functional_map(Rcorr,Pcorr,center_data,p_corr,img_width,img_height,line_weight)
        
        %========================END GRAPH FUNCTIONAL CONNECTIVITY MAP==================
end
        