

function mesh_for_second_layer(info)
    'if data is not folded do not use this function'

    datadir = info.datapath %'/data/EDA/data/';

    all_files = dir(datadir);
    subjs = {};
    for i = 3: size(all_files,1)
       subjs{i-2} = all_files(i).name;
    end

%     mkdir(info.dir);

    for subj_= subjs
        subj = subj_{1};
        tic
        if info.folded == 1
            for fold_ = info.skf
                fold = fold_{1};
                
                if info.cluster == 1
                    load( [info.get_first_layer,subj,'/', fold.name, '/', info.fl] );
                    load([info.get_second_layer,subj,'/', fold.name,'/', info.flidx]);
                else
                    load( [info.dir,subj,'/', fold.name, '/', info.fl] );
                    
                    load([info.dir, subj,'/',fold.name,'/', info.flidx_aal]);
                end
%                 if info.base_layer_memberships == 0
%                     asdf = who([info.dir, subj,'/',fold.name, '/', info.fl])
%                     if sum(ismember(asdf, 'a_tr'))==0
%                     [a_tr, a_te, tr_error, te_error]=temporal_ridge_fc_tr_te(corr(data'),10,data',data_te',10,6);
%                     a_tr = a_tr';
%                     a_te = a_te';
%                     'calculatin fl weights'
%                     save([info.dir, subj,'/',fold.name, '/', info.fl],'a_tr','a_te','-append');
%                     end
%                 end

                if info.cluster == 1
                load([info.get_second_layer, subj,'/',fold.name,'/', info.sl]);
                else
                load([info.get_second_layer,subj,'/', fold.name,'/', info.slaal]);
                end
                cc = corr(data');
                cc(isnan(cc)) = 0;
                if info.ismesh < 2 & info.base_layer_memberships <2 & info.ismesh > 0
                    [a_tr, a_te, tr_error, te_error]=temporal_ridge_fc_tr_te(cc,size(data,1)-1,data',data_te',10,6);
                    a_tr = a_tr';
                    a_te = a_te';

                    if info.cluster == 1
                    save([info.dir, subj,'/',fold.name,'/p_',num2str(p),'_', info.sl],'data','vXYZ','data_te','a_tr', 'a_te', 'labels','labels_te');
                    else
                    save([info.dir,subj,'/', fold.name,'/p_',num2str(p),'_', info.slaal],'data','vXYZ','data_te','a_tr', 'a_te', 'labels','labels_te');
                    end
                elseif info.ismesh == 2 & info.base_layer_memberships <2  & info.ismesh > 0
                    p = 26;%(info.ismesh - 1) * 10;
                    [a_tr, a_te, tr_error, te_error]=temporal_ridge_fc_tr_te(cc,p,data',data_te',10,6);
                    a_tr = a_tr';
                    a_te = a_te';

                    if info.cluster == 1
                    save([info.dir, subj,'/',fold.name,'/p_',num2str(p),'_', info.sl],'data','vXYZ','data_te','a_tr', 'a_te', 'labels','labels_te');
                    else
                    save([info.dir,subj,'/', fold.name,'/p_',num2str(p),'_', info.slaal],'data','vXYZ','data_te','a_tr', 'a_te', 'labels','labels_te');
                    end
                elseif info.ismesh < 0
                    p = -1;%(info.ismesh - 1) * 10;
                    if info.cluster == 1
                        savedir = [info.dir, subj,'/',fold.name,'/p_',num2str(p),'_', info.sl];
                    else
                        savedir = [info.dir,subj,'/', fold.name,'/p_',num2str(p),'_', info.slaal];
                    end
                    asd = who(savedir,'a_tr');
                    if exist(savedir) ~= 2 | length(asd) == 0
                        
                        [a_tr, a_te, tr_error, te_error]=temporal_fc([],p,data',data_te',10,6);
                        a_tr = a_tr';
                        a_te = a_te';

                        if info.cluster == 1
                        save(savedir,'vXYZ','a_tr', 'a_te', 'labels','labels_te','-v7.3');
                        else
                        save(savedir,'vXYZ','a_tr', 'a_te', 'labels','labels_te','-v7.3');
                        end
                    end
                elseif info.ismesh==0
                    mkdir([info.dir, subj,'/',fold.name,'/arc_weights/'])
                    [data, data_te, shift, scale] = standardize(data, data_te);
                    csd = corr(data');
                    csd(isnan(csd)) = 0;
                    for p = [10, 25, 50]%, 60, 70, 80, 90, 100 ]
                        for lambda = [0.1,0.01,1,10]%, 20, 30, 40, 50, 60, 70, 80, 90, 100]
                            if info.cluster == 1
                                save_asd = [info.dir, subj,'/',fold.name,'/arc_weights/','/p_',num2str(p),'_lambda_',num2str(lambda), '_', info.sl];
                            else 
                                save_asd = [info.dir,subj,'/', fold.name,'/arc_weights/','/p_',num2str(p),'_lambda_',num2str(lambda),'_', info.sl];
                            end
                            if exist(save_asd) ~= 2
                                if size(data,1) > p+1
                                    [a_tr, a_te, tr_error, te_error]=temporal_ridge_fc_tr_te(csd,p,data',data_te',lambda,6);
                                    a_tr = a_tr';
                                    a_te = a_te';

                                   
                                    save(save_asd,'vXYZ','a_tr', 'a_te', 'labels','labels_te');
                                    
                                end
                            end
                        end
                    end
                    
                end
            end
        end
        toc
    end

    
end



