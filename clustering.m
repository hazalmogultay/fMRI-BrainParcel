function idx = clustering(type, data, vXYZ, numcl,segmentation,old_idx,corr_path,p,lambda)
    if nargin < 5
        segmentation = 0
    end
    if nargin < 6
        old_idx = [];
    end
    if nargin < 7
        corr_path = '';
    end
    if nargin < 8
        p = 26;
    end
    if nargin < 9
        lambda = 26;
    end

    if type == 0
        idx = call_ncut(data, vXYZ, numcl,[],corr_path,p);
    
    elseif type == 11
        idx = call_kmeans(data,vXYZ, numcl, segmentation);
    elseif type == 79
        idx = FMM_n_cut_v79(data,vXYZ,numcl,corr_path,p,lambda);
    elseif type == 80
        idx = LMM_n_cut_v80(data,vXYZ,numcl,corr_path,p,lambda);
    end

    
end



function idx = call_ncut(data,vXYZ,numcl,old_idx,corr_path,nncl)
            save_selected = ['selected_corrs_p_',num2str(nncl),'.mat'];
            if exist(fullfile(corr_path,save_selected)) == 2
                load(fullfile(corr_path,save_selected))
            else
                 if exist(fullfile(corr_path,'corrs.mat')) == 2
                    load(fullfile(corr_path,'corrs.mat'))
                else
                    corrs = corr(data');
                    save(fullfile(corr_path,'corrs.mat'),'corrs','-v7.3')
                end
    %             if isempty(old_idx) 
                    distances = pdist2(vXYZ',vXYZ');
                    neighborhood_matrix = zeros(size(corrs));
                    for d = 1:size(distances,1)
                        asd = distances(:,d);
                        aa = find(0<asd&asd<=sqrt(3));
                        neighborhood_matrix(d,aa) = 1;
                        neighborhood_matrix(aa,d) = 1;
                    end
    %             else
    %                 distances = pdist2(vXYZ',vXYZ');
    %                 neighborhood_matrix = zeros(size(all_corrs));
    %                 for d = 1:size(distances,1)
    %                     [a,i] = sort(distances(:,d),'ascend');
    %                     neighborhood_matrix(d,i(1:nncl)) = 1;
    %                     neighborhood_matrix(i(1:nncl),d) = 1;
    %                 end
    %                 for i = 1: size(neighborhood_matrix,1)
    %                     for j = 1:size(neighborhood_matrix,1)
    %                         if neighborhood_matrix(i,j) ~= 0 & old_idx(i) ~= old_idx(j)
    %                             neighborhood_matrix(i,j) = 0;
    %                             neighborhood_matrix(j,i) = 0;
    %                         end
    %                     end
    %                 end
    %             end
                selected_corrs = corrs.*neighborhood_matrix;
                save(fullfile(corr_path,save_selected),'selected_corrs', '-v7.3')
            end
            selected_corrs = selected_corrs.*(selected_corrs>0);
    %         selected_corrs = abs(selected_corrs);
            [NcutDiscrete,NcutEigenvectors,NcutEigenvalues] = ncutW(selected_corrs,numcl);

            idx_ = zeros(size(data,1), 1);
            for i = 1:size(data,1)
                idx_(i) =  find(NcutDiscrete(i,:));
            end

            clusters_ = unique(sort(idx_));
            clusters_unique = [1:length(clusters_)];
            for i = 1:length(clusters_)
                idx_(idx_ == clusters_(i)) = clusters_unique(i); 
            end
            idx = idx_;

end

function idx = call_kmeans(data, vXYZ,numcl,segmentation)
    idx = kmeans(data,numcl,'Distance' , 'correlation', 'EmptyAction','drop', 'MaxIter',1000);
    if segmentation == 1
        idx = segment_clusters(vXYZ, idx, 26);
    end
end

function idx = FMM_n_cut_v79(data,vXYZ,numcl,corr_path,p_n,nncl)

            corrs = [];
            if exist(fullfile(corr_path,'corrs.mat')) == 2
                load(fullfile(corr_path,'corrs.mat'))
            else
                corrs = corr(data');
                corrs(isnan(corrs)) = 0;
                save(fullfile(corr_path,'corrs.mat'),'corrs','-v7.3')
            end
            %12600*22917
            neig_nam = ['neighborhood_matrix_',num2str(p_n),'.mat'];
            if exist(fullfile(corr_path,neig_nam)) == 2
                load(fullfile(corr_path,neig_nam))
            else
                
                neighbors = zeros(size(corrs));    
                for d = 1:size(neighbors,1)
                    aa = find_nn_corr(corrs, p_n, d);
                    aa = aa{1,1};
                    neighbors(d,aa) = 1;

                end
                save(fullfile(corr_path,neig_nam),'neighbors','-v7.3')
            end
            
            a_tr_name = ['ncut_graph_',num2str(p_n),'_',num2str(nncl),'.mat'];
            if exist(fullfile(corr_path,a_tr_name)) == 2
                load(fullfile(corr_path,a_tr_name))
            else
                a_tr = zeros(size(corrs));
                for d = 1:size(a_tr,1)
                    indices_n = find(neighbors(d,:));
                    theta = ridge(data(d,:)',data(indices_n,:)',nncl);

    %                         aa = find_nn_corr(corrs, nncl, d);
    %                         aa = aa{1,1};
    %                         theta = ridge(data(d,:)', data(aa,:)',10);
                            for tt = 1:length(theta)
                                val = (theta(tt));
                                if a_tr(d,indices_n(tt)) == 0
                                    a_tr(d,indices_n(tt))=val;
                                elseif corrs(d,indices_n(tt)) > 0 && (a_tr(d,indices_n(tt)))<(val)%abs(a_tr(d,indices_n(tt)))<abs(val)
                                    a_tr(d,indices_n(tt))=val;
                                elseif  corrs(d,indices_n(tt)) < 0 && (a_tr(d,indices_n(tt)))>(val)%abs(a_tr(d,indices_n(tt)))<abs(val)
                                    a_tr(d,indices_n(tt))=val;
                                end
                                if a_tr(indices_n(tt),d) == 0
                                    a_tr(indices_n(tt),d)=val;
                                elseif corrs(d,indices_n(tt)) > 0 && (a_tr(indices_n(tt),d))<(val)%abs(a_tr(indices_n(tt),d))<abs(val)
                                    a_tr(indices_n(tt),d)=val;
                                elseif corrs(d,indices_n(tt)) < 0 && (a_tr(indices_n(tt),d))>(val)
                                    a_tr(indices_n(tt),d)=val;
                                end
                            end


                end
                save(fullfile(corr_path,a_tr_name),'a_tr','-v7.3')
            end
%             a_tr = abs(a_tr);
            
            [NcutDiscrete,NcutEigenvectors,NcutEigenvalues] = ncutW(a_tr,numcl);

            idx_ = zeros(size(data,1), 1);
            for i = 1:size(data,1)
                idx_(i) =  find(NcutDiscrete(i,:));
            end

            clusters_ = unique(sort(idx_));
            clusters_unique = [1:length(clusters_)];
            for i = 1:length(clusters_)
                idx_(idx_ == clusters_(i)) = clusters_unique(i); 
            end
            idx = idx_;
end

function idx = LMM_n_cut_v80(data,vXYZ,numcl,corr_path,p_n,nncl)
            if exist(fullfile(corr_path,'corrs.mat')) == 2
                load(fullfile(corr_path,'corrs.mat'))
            else
                corrs = corr(data');
                save(fullfile(corr_path,'corrs.mat'),'corrs','-v7.3')
            end
            distances = [];
            if exist(fullfile(corr_path,'lmm_distances.mat')) == 2
                load(fullfile(corr_path,'lmm_distances.mat'))
            else
                distances = pdist2(vXYZ',vXYZ');
                save(fullfile(corr_path,'lmm_distances.mat'),'distances','-v7.3')
            end
            %12600*22917
            neig_nam = ['lmm_neighborhood_matrix_',num2str(p_n),'.mat'];
            if exist(fullfile(corr_path,neig_nam)) == 2
                load(fullfile(corr_path,neig_nam))
            else
                
                neighbors = zeros(size(distances));
                    
                    for d = 1:size(distances,1)
                        asd = distances(:,d);
                        aa = find(0<asd&asd<=sqrt(3));
%                         theta = ridge(data(d,:)', data(aa,:)',10);
                        neighbors(d,aa) = 1;
%                         a_tr(d,aa)=theta;
                    end
             
%                 neighbors = zeros(size(corrs));    
%                 for d = 1:size(neighbors,1)
%                     aa = find_nn_corr(corrs, p_n, d);
%                     aa = aa{1,1};
%                     neighbors(d,aa) = 1;
% 
%                 end
                save(fullfile(corr_path,neig_nam),'neighbors','-v7.3')
            end
            
            a_tr_name = ['lmm_ncut_graph_',num2str(p_n),'_',num2str(nncl),'.mat'];
            if exist(fullfile(corr_path,a_tr_name)) == 2
                load(fullfile(corr_path,a_tr_name))
            else
                a_tr = zeros(size(corrs));
                for d = 1:size(a_tr,1)
                    indices_n = find(neighbors(d,:));
                    theta = ridge(data(d,:)',data(indices_n,:)',nncl);

    %                         aa = find_nn_corr(corrs, nncl, d);
    %                         aa = aa{1,1};
    %                         theta = ridge(data(d,:)', data(aa,:)',10);
                            for tt = 1:length(theta)
                                val = (theta(tt));
                                if a_tr(d,indices_n(tt)) == 0
                                    a_tr(d,indices_n(tt))=val;
                                elseif corrs(d,indices_n(tt)) > 0 & (a_tr(d,indices_n(tt)))<(val)%abs(a_tr(d,indices_n(tt)))<abs(val)
                                    a_tr(d,indices_n(tt))=val;
                                elseif  corrs(d,indices_n(tt)) < 0 & (a_tr(d,indices_n(tt)))>(val)%abs(a_tr(d,indices_n(tt)))<abs(val)
                                    a_tr(d,indices_n(tt))=val;
                                end
                                if a_tr(indices_n(tt),d) == 0
                                    a_tr(indices_n(tt),d)=val;
                                elseif corrs(d,indices_n(tt)) > 0 & (a_tr(indices_n(tt),d))<(val)%abs(a_tr(indices_n(tt),d))<abs(val)
                                    a_tr(indices_n(tt),d)=val;
                                elseif corrs(d,indices_n(tt)) < 0 & (a_tr(indices_n(tt),d))>(val)
                                    a_tr(indices_n(tt),d)=val;
                                end
                            end


                end
                save(fullfile(corr_path,a_tr_name),'a_tr','-v7.3')
            end
%             a_tr = abs(a_tr);
            
            [NcutDiscrete,NcutEigenvectors,NcutEigenvalues] = ncutW(a_tr,numcl);

            idx_ = zeros(size(data,1), 1);
            for i = 1:size(data,1)
                idx_(i) =  find(NcutDiscrete(i,:));
            end

            clusters_ = unique(sort(idx_));
            clusters_unique = [1:length(clusters_)];
            for i = 1:length(clusters_)
                idx_(idx_ == clusters_(i)) = clusters_unique(i); 
            end
            idx = idx_;
end



