function create_OMI_ECMWF_data(ROI_index,start_jahr,end_jahr,start_month,end_month)

path_input_files='input/';
load([path_input_files 'grid_definitions.mat']);
load([path_input_files 'ROI_definitions.mat']);

path_regional_files='output/';
path_OMI='/home/bijianzhao/data/OMI/NO2/DOMINO_L2Swath_v2/';

start_jahrstr=num2str(start_jahr);
end_jahrstr=num2str(end_jahr);
start_monatstr=num2str(start_month); if start_month<10 start_monatstr=['0' start_monatstr]; end;
end_monatstr=num2str(end_month); if end_month<10 end_monatstr=['0' end_monatstr]; end;
time_label = [start_jahrstr start_monatstr '_' end_jahrstr end_monatstr];
disp(['time_label' time_label]);

out_dirname=[path_regional_files '/monthly/Region_OMI_ECMWF_data_' ROI(ROI_index).name '_' start_jahrstr start_monatstr '_' end_jahrstr end_monatstr];
if ~exist(out_dirname,'dir')
    system(['mkdir -p ' out_dirname]);
end;

cell_time_acrosstrack_alongtrack=cell(end_jahr-start_jahr+1,end_month-start_month+1);
cell_U15_V15=cell(end_jahr-start_jahr+1,end_month-start_month+1);
flag_time=0;
for jahr= start_jahr:end_jahr
    for monat= start_month:end_month
        jahrstr=num2str(jahr);
        monatstr=num2str(monat); if monat<10 monatstr=['0' monatstr]; end;
        
        dirname_mapping=[path_regional_files 'Region_mapping_OMI_ECMWF_' ROI(ROI_index).name];
        load([dirname_mapping '/' 'Regionalfile_mapping_OMI_ECMWF_' ROI(ROI_index).name '_' jahrstr monatstr '.mat']);
        cell_time_acrosstrack_alongtrack{jahr-start_jahr+1,monat-start_month+1}=time_acrosstrack_alongtrack;
        
        time_list_temp=cellfun(@(x) unique(x(:,1)),time_acrosstrack_alongtrack,'UniformOutput', false);
        if flag_time==0
            time_list=unique(cat(1,time_list_temp{:}));
            flag_time=1;
        else
            time_list=[time_list;unique(cat(1,time_list_temp{:}))];
        end;
        clear time_acrosstrack_alongtrack time_list_temp;
        
        dirname_wind=[path_regional_files 'Region_mapping_OMI_ECMWF_time_' ROI(ROI_index).name '/' jahrstr];
        load([dirname_wind '/' 'Regionalfile_mapping_OMI_ECMWF_time_' ROI(ROI_index).name '_' jahrstr monatstr '.mat']);
        cell_U15_V15{jahr-start_jahr+1,monat-start_month+1}=U15_V15;
        clear U15_V15;
        
        disp(['finish loading mapping and wind files:' jahrstr monatstr]);
    end;
end;
disp('finish loading mapping and wind files');

%build the look-up table of 'time' and 'OMI data'
%load OMI data according to time_list
num_list=size(time_list,1);
%the numbers of column of input files are not the same
%TAMF_list=cell(num_list);
CF_list=cell(num_list);
CP_list=cell(num_list);
CRF_list=cell(num_list);
TVCD_list=cell(num_list);
SZA_list=cell(num_list);
%XQF_list=cell(num_list);
lat_satellite_list=cell(num_list);
lon_satellite_list=cell(num_list);
lat_corner_list=cell(num_list);
lon_corner_list=cell(num_list);
for k=1:size(time_list,1)
    jahrstr=time_list{k,1}(1:4);
    monatstr=time_list{k,1}(6:7);
    tagstr=time_list{k,1}(8:9);
    path=[path_OMI jahrstr '/' monatstr '/'];
    flist=dir([path 'OMI-Aura_L2-OMDOMINO_' time_list{k,1} '*']);
    fname=[path flist(1).name];
    disp(fname);
    if not(strcmp(fname,'/public/satellite/OMI/no2/DOMINO_S_v2/2013/10/OMI-Aura_L2-OMDOMINO_2013m1002t1854-o49025_v003-2013m1006t001124.he5'))
        if not(strcmp(fname,'/public/satellite/OMI/no2/DOMINO_S_v2/2013/10/OMI-Aura_L2-OMDOMINO_2013m1009t0548-o49119_v003-2013m1013t000457.he5'))
            if not(strcmp(fname,'/public/satellite/OMI/no2/DOMINO_S_v2/2013/12/OMI-Aura_L2-OMDOMINO_2013m1201t1555-o49897_v003-2013m1205t001125.he5'))
                if not(strcmp(fname,'/public/satellite/OMI/no2/DOMINO_S_v2/2007/09/OMI-Aura_L2-OMDOMINO_2007m0901t0002-o16641_v003-2010m1118t092107.he5'))
                    %TAMF_list{k}=double(hdf5read(fname,'/HDFEOS/SWATHS/DominoNO2/Data Fields/AirMassFactorTropospheric'));
                    CF_list{k}=double(hdf5read(fname,'/HDFEOS/SWATHS/DominoNO2/Data Fields/CloudFraction'));
                    CP_list{k}=double(hdf5read(fname,'/HDFEOS/SWATHS/DominoNO2/Data Fields/CloudPressure'));
                    CRF_list{k}=double(hdf5read(fname,'/HDFEOS/SWATHS/DominoNO2/Data Fields/CloudRadianceFraction'));
                    TVCD_list{k}=double(hdf5read(fname,'/HDFEOS/SWATHS/DominoNO2/Data Fields/TroposphericVerticalColumn'));
                    SZA_list{k}=double(hdf5read(fname,'/HDFEOS/SWATHS/DominoNO2/Geolocation Fields/SolarZenithAngle'));
                    %XQF_list{k}=double(hdf5read(fname,'/HDFEOS/SWATHS/DominoNO2/Data Fields/FitQualityFlags'));%XTrackQualityFlags
                    lat_satellite_list{k}=double(hdf5read(fname,'/HDFEOS/SWATHS/DominoNO2/Geolocation Fields/Latitude'));
                    lon_satellite_list{k}=double(hdf5read(fname,'/HDFEOS/SWATHS/DominoNO2/Geolocation Fields/Longitude'));
                    lat_corner_list{k}=double(hdf5read(fname,'/HDFEOS/SWATHS/DominoNO2/Geolocation Fields/LatitudeCornerpoints'));
                    lon_corner_list{k}=double(hdf5read(fname,'/HDFEOS/SWATHS/DominoNO2/Geolocation Fields/LongitudeCornerpoints'));
                end;
            end
        end
    end;
end;

disp('finish loading OMI files');

for j=1:length(ROI(ROI_index).latvec)
    disp(['lat' num2str(ROI(ROI_index).latvec(j))]);
    for i=1:length(ROI(ROI_index).lonvec)
        %for j=1:1
        %        for i=130:131
        location_label=['lat' num2str(ROI(ROI_index).latvec(j)) '_lon' num2str(ROI(ROI_index).lonvec(i))];
        filename=[out_dirname '/' 'Regionalfile_OMI_ECMWF_data_' ROI(ROI_index).name '_' location_label '_' time_label '.mat'];
        DATA.lat_center=ROI(ROI_index).latvec(j);
        DATA.lon_center=ROI(ROI_index).lonvec(i);
        DATA.size='0.36deg';
        
        capacity_temp=cell2mat(cellfun(@(x) size(x{j,i},1),cell_time_acrosstrack_alongtrack,'UniformOutput', false));
        capacity_j_i =sum(capacity_temp(:));
        clear capacity_temp
        DATA.time=cell(capacity_j_i,1);
        DATA.acrosstrack=cell(capacity_j_i,1);
        DATA.alongtrack=cell(capacity_j_i,1);
        DATA.wind_u=zeros(capacity_j_i,15);
        DATA.wind_v=zeros(capacity_j_i,15);
        %DATA.TAMF=zeros(capacity_j_i,1);
        DATA.CF=zeros(capacity_j_i,1);
        DATA.CP=zeros(capacity_j_i,1);
        DATA.CRF=zeros(capacity_j_i,1);
        DATA.TVCD=zeros(capacity_j_i,1);
        DATA.SZA=zeros(capacity_j_i,1);
        %DATA.XQF=zeros(capacity_j_i,1);
        DATA.lat_satellite=zeros(capacity_j_i,1);
        DATA.lon_satellite=zeros(capacity_j_i,1);
        DATA.lat_corner=zeros(capacity_j_i,4);
        DATA.lon_corner=zeros(capacity_j_i,4);
        
        start_k=1;
        for jahr= start_jahr:end_jahr
            for monat= start_month:end_month
                time_acrosstrack_alongtrack=cell_time_acrosstrack_alongtrack{jahr-start_jahr+1,monat-start_month+1};
                U15_V15=cell_U15_V15{jahr-start_jahr+1,monat-start_month+1};
                
                %find OMI data according to time_acrosstrack_alongtrack
                capacity_k=size(squeeze(time_acrosstrack_alongtrack{j,i}(:,2)),1);
                %TAMF =zeros(capacity_k,1);
                CF   =zeros(capacity_k,1);
                CP   =zeros(capacity_k,1);
                CRF  =zeros(capacity_k,1);
                TVCD =zeros(capacity_k,1);
                SZA  =zeros(capacity_k,1);
                %XQF  =zeros(capacity_k,1);
                lat_satellite=zeros(capacity_k,1);
                lon_satellite=zeros(capacity_k,1);
                lat_corner=zeros(capacity_k,4);
                lon_corner=zeros(capacity_k,4);
                for k=1:capacity_k
                    OMI_time=time_acrosstrack_alongtrack{j,i}{k,1};
                    OMI_acrosstrack=time_acrosstrack_alongtrack{j,i}{k,2};
                    OMI_alongtrack=time_acrosstrack_alongtrack{j,i}{k,3};
                    
                    ID=strmatch(OMI_time,time_list);
                    %OMI_TAMF_temp=TAMF_list{ID};
                    OMI_CF_temp=CF_list{ID};
                    OMI_CP_temp=CP_list{ID};
                    OMI_CRF_temp=CRF_list{ID};
                    OMI_TVCD_temp=TVCD_list{ID};
                    OMI_SZA_temp=SZA_list{ID};
                    %OMI_XQF_temp=XQF_list{ID};
                    OMI_lat_satellite_temp=lat_satellite_list{ID};
                    OMI_lon_satellite_temp=lon_satellite_list{ID};
                    OMI_lat_corner_temp=lat_corner_list{ID};
                    OMI_lon_corner_temp=lon_corner_list{ID};
                    
                    %OMI_TAMF=OMI_TAMF_temp(OMI_acrosstrack,OMI_alongtrack);
                    OMI_CF  =OMI_CF_temp(OMI_acrosstrack,OMI_alongtrack);
                    OMI_CP  =OMI_CP_temp(OMI_acrosstrack,OMI_alongtrack);
                    OMI_CRF =OMI_CRF_temp(OMI_acrosstrack,OMI_alongtrack);
                    OMI_TVCD=OMI_TVCD_temp(OMI_acrosstrack,OMI_alongtrack);
                    OMI_SZA =OMI_SZA_temp(OMI_acrosstrack,OMI_alongtrack);
                    %OMI_XQF =OMI_XQF_temp(OMI_acrosstrack,OMI_alongtrack);
                    OMI_lat_satellite=OMI_lat_satellite_temp(OMI_acrosstrack,OMI_alongtrack);
                    OMI_lon_satellite=OMI_lon_satellite_temp(OMI_acrosstrack,OMI_alongtrack);
                    OMI_lat_corner=OMI_lat_corner_temp(OMI_acrosstrack,OMI_alongtrack,:);
                    OMI_lon_corner=OMI_lon_corner_temp(OMI_acrosstrack,OMI_alongtrack,:);
                    
                    clear OMI_TAMF_temp OMI_CF_temp OMI_CP_temp OMI_CRF_temp OMI_TVCD_temp OMI_SZA_temp OMI_XQF_temp OMI_lat_satellite_temp OMI_lon_satellite_temp OMI_lat_corner_temp OMI_lon_corner_temp
                    
                    %TAMF(k)=OMI_TAMF;
                    CF(k)  =OMI_CF;
                    CP(k)  =OMI_CP;
                    CRF(k) =OMI_CRF;
                    TVCD(k)=OMI_TVCD;
                    SZA(k) =OMI_SZA;
                    %XQF(k) =OMI_XQF;
                    lat_satellite(k) =OMI_lat_satellite;
                    lon_satellite(k) =OMI_lon_satellite;
                    lat_corner(k,:) =OMI_lat_corner;
                    lon_corner(k,:) =OMI_lon_corner;
                end;
                
                
                DATA.time(start_k:start_k+capacity_k-1)=squeeze(time_acrosstrack_alongtrack{j,i}(:,1));
                DATA.acrosstrack(start_k:start_k+capacity_k-1)=squeeze(time_acrosstrack_alongtrack{j,i}(:,2));
                DATA.alongtrack(start_k:start_k+capacity_k-1)=squeeze(time_acrosstrack_alongtrack{j,i}(:,3));
                DATA.wind_u(start_k:start_k+capacity_k-1,:)=U15_V15{j,i}(:,:,1);
                DATA.wind_v(start_k:start_k+capacity_k-1,:)=U15_V15{j,i}(:,:,2);
                %DATA.TAMF(start_k:start_k+capacity_k-1)=TAMF;
                DATA.CF(start_k:start_k+capacity_k-1)=CF;
                DATA.CP(start_k:start_k+capacity_k-1)=CP;
                DATA.CRF(start_k:start_k+capacity_k-1)=CRF;
                DATA.TVCD(start_k:start_k+capacity_k-1)=TVCD;
                DATA.SZA(start_k:start_k+capacity_k-1)=SZA;
                %DATA.XQF(start_k:start_k+capacity_k-1)=XQF;
                DATA.lat_satellite(start_k:start_k+capacity_k-1)=lat_satellite;
                DATA.lon_satellite(start_k:start_k+capacity_k-1)=lon_satellite;
                DATA.lat_corner(start_k:start_k+capacity_k-1,:)=lat_corner;
                DATA.lon_corner(start_k:start_k+capacity_k-1,:)=lon_corner;
                
                start_k=start_k+capacity_k;
                
                clear TAMF CF CP CRF TVCD SZA XQF lat_satellite lon_satellite lat_corner lon_corner
                
            end;
        end;
        save(filename, 'DATA');
        clear DATA;
    end;
end;