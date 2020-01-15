
folds = {};
folds{1}.tr = [2,3,4,5,6]; folds{1}.te = [1]; folds{1}.name = 'fold1';
folds{2}.tr = [1,3,4,5,6]; folds{2}.te = [2]; folds{2}.name = 'fold2';
folds{3}.tr = [1,2,4,5,6]; folds{3}.te = [3]; folds{3}.name = 'fold3';
folds{4}.tr = [1,2,3,5,6]; folds{4}.te = [4]; folds{4}.name = 'fold4';
folds{5}.tr = [1,2,3,4,6]; folds{5}.te = [5]; folds{5}.name = 'fold5';
folds{6}.tr = [1,2,3,4,5]; folds{6}.te = [6]; folds{6}.name = 'fold6';


info = struct()
trial = 'TODO'; %name of the experiment
info.averaging = 1;% use 0 for cca
info.cluster = 1;
info.base_layer_memberships = 0; 


base = ['./data/',trial,'/voxel_selection']; % relative path to the data location
base2 = ['./data/',trial,'/voxel_selection_results'];%relative path to save the results

info.clustering_type = type; 
info.second_layer_number_of_clusters = 'TODO'; % Number of clusters in the second layer
info.third_layer_number_of_clusters = 'TODO'; % Number of clusters in the third layer
info.is_segmentation = 1;
info.nncl = 26; %Number of neighbors

a = num2str(info.clustering_type);
b = num2str(info.is_segmentation);
c = num2str(info.second_layer_number_of_clusters);
d = num2str(info.third_layer_number_of_clusters);
e = num2str(info.nncl);



if info.cluster == 0
    info.dir = [base,'/'];
    info.resultdir = [base2,'/'];
else
    info.dir = [base,'_',a,'_',b,'_',c,'_',d,'_',e,'/'];
    info.resultdir = [base2,'_',a,'_',b,'_',c,'_',d,'_',e,'/'];
end
mkdir(info.dir)
mkdir(info.resultdir)

info.run_length = 35; 
info.duration = 6;

info.get_base_layer_memberships = base2;
info.get_second_layer_memberships = info.resultdir;%[base2,'_',a,'_',b,'_',c,'_50/'];



info.folded = 1;
info.voxel_selection = 0;
info.skf = folds;

info.get_first_layer = [base,'/'];
info.get_second_layer = info.dir;

if info.cluster == 1 & tn > 101
    info.get_second_layer = [base,'_',a,'_',b,'_50_',d,'/'];
elseif info.cluster == 1 & tn < 101
    info.get_second_layer = info.dir;
else 
    info.get_second_layer = [base,'/'];
end


info.ismesh = 2;
info.datapath = './data/';
info.datafilename = './data/tr_data_non_zero.mat';
info.labelspath = './data/classlabels/';
info.labelsfilename = 'tr_te_labels.mat';
info.fl = 'first_layer.mat'; %includes data , mesh , memberships (File name of the first layer results)
info.sl = 'second_layer.mat'; %(File name of the second layer results)
info.slaal = 'second_layer_aal.mat'; %(File name of the seond layer AAL results)
info.tl = 'third_layer.mat'; %(File name of the third layer results)
info.tlaal = 'third_layer_aal.mat'; %(File name of the third layer AAL results)

info.flidx = 'fl_idx.mat'; %(File name of the first layer cluster idx)
info.slidx = 'sl_idx.mat'; %(File name of the second layer cluster idx)


%% Attribute names of trdata and trlabels
info.attr_data = 'trData';
info.attr_labels = 'tr_labels_four_class';


info.flidx_aal = 'fl_idx_aal.mat';
info.slidx_aal = 'sl_idx_aal.mat';



info.ismesh = 0; %whether to use meshes for second and third layer supervoxels
info.p = 10; %Number of neighbors in the mesh algorithm
info.lambda = 10; %Lambda of the mesh algorithm

save([info.resultdir,'info.mat'],'info')


%% When you create the info file, you can call the following functions

% second_layer_clustering(info);
% mesh_for_second_layer(info);
% 
% third_layer_clustering(info);
% mesh_for_third_layer(info);
