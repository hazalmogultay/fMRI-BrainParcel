

function second_layer_clustering(info)


    datadir = info.datapath 
    dur = 's4/';

    all_files = dir(datadir);
    subjs = {};
    for i = 3: size(all_files,1)
       subjs{i-2} = all_files(i).name;
    end

    

    for subj_= subjs%{'subj6','subj7'}
        subj = subj_{1};
        load([datadir, subj,'/', info.datafilename]);
        data = trData;
        num_voxels = size(trData,1);
        
        k = load([info.labelspath,subj,'/',info.labelsfilename],info.attr_labels);
        k = struct2cell(k);
        labels = k{1,1};
        
        tic
        mkdir([info.dir,subj,'/']);
        if info.folded == 0 & info.voxel_selection == 0
            savedir = [info.dir,subj,'/'];
            if info.cluster == 1
                idx = clustering(info.clustering_type, data,vXYZ,info.second_layer_number_of_clusters, info.is_segmentation,info.nncl);
                save([savedir,info.flidx],'idx');
            else 
                idx = aal98';
                save([savedir,info.flidx_aal],'idx');
                save([savedir, info.fl],'data','vXYZ','labels');
            end
            %save([savedir, info.fl],'data','vXYZ','labels');
        elseif info.folded == 1 & info.voxel_selection == 0
            tmp_data2 = data;
            tmp_labels2 = labels;
            tmp_vXYZ = vXYZ;
            for fold_ = info.skf
                fold = fold_{1};
                mkdir([info.dir,subj,'/',fold.name,'/']);
                savedir = [info.dir,subj,'/',fold.name,'/'];
                
                tmp_data = tmp_data2;
                tmp_labels = tmp_labels2;
                vXYZ = tmp_vXYZ;
                
                step = info.run_length * info.duration;
                step2 = info.run_length;
                data2 = [];
                labels2 = [];
                for i = fold.tr
                    data2 = [data2, tmp_data(:,(i-1)*step+1 : (i-1)*step+step)];
                    labels2 = [labels2; tmp_labels((i-1)*step2+1 : (i-1)*step2+step2)];
                end
                data_te=[];
                labels_te = [];
                for i = fold.te
                    data_te = [data_te, tmp_data(:,(i-1)*step+1 : (i-1)*step+step)];
                    labels_te = [labels_te; tmp_labels((i-1)*step2+1 : (i-1)*step2+step2)];
                end
                data = data2;
                labels = labels2;
                if info.cluster == 1
                    if exist([savedir,info.flidx],'file') == 2
                        load([savedir,info.flidx])
                        
                    elseif info.base_layer_memberships <2
                        idx = clustering(info.clustering_type, data,vXYZ,info.second_layer_number_of_clusters, info.is_segmentation,[],[info.get_first_layer,subj,'/',fold.name,'/'],info.p,info.lambda);
                        save([savedir,info.flidx],'idx');
                    end
                else 
                    
                    idx = aal98';
                    idx28 = aal28';
                    save([savedir,info.flidx_aal],'idx','idx28');
                    save([savedir, info.fl],'data','vXYZ','labels','data_te','labels_te');
                end
                %save([savedir, info.fl],'data','vXYZ','labels','data_te','labels_te');
                
                
                [data, data_te, vXYZ] = get_upper_layer_data(data,data_te,vXYZ, idx,[info.dir, subj,'/',fold.name,'/', info.sl],info.averaging);
                
                if info.cluster == 1
                    if info.base_layer_memberships <2
                        save([info.dir, subj,'/',fold.name,'/', info.sl],'data','vXYZ','data_te', 'labels','labels_te');
                    end
                else
                    save([info.dir,subj,'/', fold.name,'/', info.slaal],'data','vXYZ','data_te','labels','labels_te');
                end
                
                
                
            end
        elseif info.folded == 1 & info.voxel_selection == 1
            tmp_data = data;
            tmp_labels = labels;
            tmp_vxyz = vXYZ;
            indx = 1;
            for fold_ = info.skf
                fold = fold_{1};
                mkdir([info.dir,subj,'/',fold.name,'/'])
                savedir = [info.dir,subj,'/',fold.name,'/'];
                
                f = f_scores(indx,:);
                [f_sorted, sorted_indx ] = sort(f);
                select = f_scores_selection(indx);
                indx = indx+1;
                asd = find(isnan(f_sorted))
                tmp_data2 = tmp_data(sorted_indx(select:end-size(asd,2)),:);
                vXYZ = tmp_vxyz(:,sorted_indx(select:end-size(asd,2)));
                
                
                step = info.run_length * info.duration;
                step2 = info.run_length;
                data2 = [];
                labels2 = [];
                for i = fold.tr
                    data2 = [data2, tmp_data2(:,(i-1)*step+1 : (i-1)*step+step)];
                    labels2 = [labels2; tmp_labels((i-1)*step2+1 : (i-1)*step2+step2)];
                end
                data_te=[];
                labels_te = [];
                for i = fold.te
                    data_te = [data_te, tmp_data2(:,(i-1)*step+1 : (i-1)*step+step)];
                    labels_te = [labels_te; tmp_labels((i-1)*step2+1 : (i-1)*step2+step2)];
                end
                data = data2;
                labels = labels2;
                if info.cluster == 1
                     if exist([savedir,info.flidx],'file') == 2
                        load([savedir,info.flidx])
                     elseif info.base_layer_memberships <2
                        idx = clustering(info.clustering_type, data,vXYZ,info.second_layer_number_of_clusters, info.is_segmentation);
                        save([savedir,info.flidx],'idx');
                    end
                else 
                    idx = aal98(sorted_indx(select:end-size(asd,2)))';
                    idx28 = aal28(sorted_indx(select:end-size(asd,2)))';
                    save([savedir,info.flidx_aal],'idx','idx28');
                    save([savedir, info.fl],'data','vXYZ','labels','data_te','labels_te');
                end
                %save([savedir, info.fl],'data','vXYZ','labels','data_te','labels_te');
                [data, data_te, vXYZ] = get_upper_layer_data(data,data_te,vXYZ, idx,[info.dir, subj,'/',fold.name,'/', info.sl],info.averaging);
                
                if info.cluster == 1
                    if info.base_layer_memberships <2
                        save([info.dir, subj,'/',fold.name,'/', info.sl],'data','vXYZ','data_te', 'labels','labels_te');
                    end
                else
                save([info.dir,subj,'/', fold.name,'/', info.slaal],'data','vXYZ','data_te','labels','labels_te');
                end
                
             
            end
        elseif info.folded == 0 & info.voxel_selection == 1
            tmp_data = data;
            tmp_vxyz = vXYZ;
            indx = 1;
            
            f = f_scores(indx,:);
            [f_sorted, sorted_indx ] = sort(f);
            select = f_scores_selection(indx);
            indx = indx+1
            data = tmp_data(sorted_indx(select:end),:);
            vXYZ = tmp_vxyz(:,sorted_indx(select:end));
                
           
            
            if info.cluster == 1
                if info.base_layer_memberships <2
                    idx = clustering(info.clustering_type, data,vXYZ,info.second_layer_number_of_clusters, info.is_segmentation,info.nncl);
                    save([savedir,info.flidx],'idx');
                end
            else 
                idx = aal98(sorted_indx(select:end))';
                idx28 = aal28(sorted_indx(select:end))';
                save([savedir,info.flidx_aal],'idx','idx28');
                save([savedir, info.fl],'data','vXYZ','labels');
            end
                %save([savedir, info.fl],'data','vXYZ','labels');
            
                
                
                [data, data_te, vXYZ] = get_upper_layer_data(data,data_te,vXYZ, idx,[info.dir, subj,'/',fold.name,'/', info.sl],info.averaging)  ;  
                
                if info.cluster == 1
                    if info.base_layer_memberships <2
                        save([info.dir, subj,'/',fold.name,'/', info.sl],'data','vXYZ','data_te', 'labels','labels_te');
                    end
                else
                save([info.dir,subj,'/', fold.name,'/', info.slaal],'data','vXYZ','data_te','labels','labels_te');
                end
                
                
                
        end
        toc    
    end

end




