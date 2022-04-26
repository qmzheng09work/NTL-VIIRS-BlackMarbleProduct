%% file

clear;clc;
close all;

%% instruction
% SET parameter

% folder storing all blackmarble tiles
folder='/hpctmp/dbszhq/[BMPPA]_project/raw_data/bm_cn_2012_2020/';

% start/end year_doy of your study period
start_year_doy='2012019';
end_year_doy='2020365';

% run the entire code 
% after finished, check variable "data_info"

%% do not need to change anything below
input_folder=folder;
output_folder=[folder,'Output_fold1/'];
output_report=0;

path_files=dir([input_folder,'*','.h5']);

% variables
flag=0; % 0:no copy; 1:copy; 2:copy and remove current file
tile_list=['h00v00'];
ref_year_doy=[];

data_info.tile_name='';
data_info.year_doy=[];
data_info.miss_year_doy=[];
data_info.miss_num=0;
data_info.require_num=0;
%% build reference list and compare with each tile_list
start_year=str2num(start_year_doy(1:4));
end_year=str2num(end_year_doy(1:4));
start_doy=str2num(start_year_doy(5:end));
end_doy=str2num(end_year_doy(5:end));

for t=start_year:end_year
    k=0;
    if ((rem(t,100)~=0 && rem(t,4)==0)||(rem(t,100)==0 && rem(t,400)==0))
        k=1;
    end
    
    if t==start_year
        start_doy_temp=start_doy;
    else
        start_doy_temp=1;
    end
    
    if t==end_year
        end_doy_temp=end_doy;
    else
        end_doy_temp=365+k;
    end
    ref_year_doy=[ref_year_doy,(t*1000+start_doy_temp):(t*1000+end_doy_temp)];
end
ref_year_doy=ref_year_doy';
%% print and extract tile,year,doy
for i=1:length(path_files)
    %     i=1;
    file_name_full=path_files(i).name;
    index=strfind(file_name_full,'.');
    tile_name=file_name_full(index(2)+1:index(3)-1);
    tile_year=file_name_full(index(1)+2:index(1)+5);
    tile_doy=file_name_full(index(1)+6:index(1)+8);
       
    if ismember(tile_name,tile_list,'row')==0
        data_info(end+1).tile_name=tile_name;
        tile_list=[tile_list;tile_name];
    end
    tile_year_doy=str2num([tile_year,tile_doy]);
    s = strcmp({data_info.tile_name},tile_name);
    ind=find(s==1);
    data_info(ind).year_doy=[data_info(ind).year_doy,tile_year_doy];
    
    tile_out_folder=[output_folder,tile_name,'\'];
    if exist(tile_out_folder,'dir')==0 && flag>0
        fprintf('make new dir\n');
        mkdir(tile_out_folder);
    end
    
    if flag==1
        copyfile([input_folder,file_name_full],[tile_out_folder,file_name_full]);
    elseif flag==2
        movefile([input_folder,file_name_full],[tile_out_folder,file_name_full]);
    end
end
tile_list(1,:)=[];
data_info(1)=[];
%
for i =1: length(data_info)
    data_info(i).tile_name;
    tile_year_doy=data_info(i).year_doy';
    ind=ismember(ref_year_doy,tile_year_doy,'row');    
    data_info(i).miss_year_doy=ref_year_doy(~ind);
    data_info(i).miss_num=length(data_info(i).miss_year_doy);
    data_info(i).require_num=length(ref_year_doy);
end


