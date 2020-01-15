# fMRI-BrainParcel

Constructs a 3 layered hierarchical brain parcellation.

In order to use this segmentation one needs to create an 'info' file. See 'create_info.m' for more details.
After that you can use second_layer_clustering and third_layer_clustering.

This code uses normalized cut segmentation:
  Shi, J., & Malik, J. (2000). Normalized cuts and image segmentation. Departmental Papers (CIS), 107.

Also uses mesh model:
  Onal, I., Ozay, M., Mizrak, E., Oztekin, I., & Vural, F. T. Y. (2017). A new representation of fMRI signal by a set of local meshes for brain decoding. IEEE Transactions on Signal and Information Processing over Networks, 3(4), 683-694.
  
  
 If you are using this code, please cite the following:
 
 Mogultay, H., & Vural, F. T. Y. (2018). BrainParcel: A Brain Parcellation Algorithm for Cognitive State Classification. In Graphs in Biomedical Image Analysis and Integrating Medical Imaging and Non-Imaging Modalities (pp. 32-42). Springer, Cham.
  
 
  
