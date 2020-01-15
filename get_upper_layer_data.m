function [data, data_te, vXYZ] = get_upper_layer_data(data,data_te,vXYZ, idx,fname,averaging)
if nargin < 5
    averaging = 0;
end

     averaged_data = [];
     averaged_data_te = [];
     averaged_data_vXYZ = [];    
     for i = 1:max(idx)
          if sum(idx==i)>1
                        averaged_data = [averaged_data;mean(data(idx==i,:))];
                        averaged_data_te = [averaged_data_te;mean(data_te(idx==i,:))];
                        averaged_data_vXYZ = [averaged_data_vXYZ, mean(vXYZ(:,idx==i)')'];
          else
                        averaged_data = [averaged_data;data(idx==i,:)];
                        averaged_data_te = [averaged_data_te;data_te(idx==i,:)];
                        averaged_data_vXYZ = [averaged_data_vXYZ, vXYZ(:,idx==i)];
          end

     end
      if averaging == 1
%             th = 0.30;
%             asd = corr(averaged_data');
% 
%             eliminated = [];
% 
%             for i = 1:size(asd(1,:),2)
%             %     for j =1:max(idx)
%                     if sum(abs(asd(i,:))<th) < size(asd(1,:),2)/2
%                         eliminated = [eliminated,i];
%                     end
%             %     end
%             end
%             
%             
%             
%             
%           data = averaged_data(eliminated,:);
%           data_te = averaged_data_te(eliminated,:);


            
          data = averaged_data;
          data_te = averaged_data_te;
      else
          [data, data_te] = call_cca(data,data_te, idx,fname);
%           [data, data_te] = call_cca(averaged_data,averaged_data_te, [1:1:max(idx)]);
      end
      vXYZ = averaged_data_vXYZ;
end