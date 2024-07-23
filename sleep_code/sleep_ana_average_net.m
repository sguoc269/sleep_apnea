clear
clc
group_dir = "/sleep/results/base";%base m09 m18
group_files = dir(strcat(group_dir, filesep, '*.mat'));

%% 01235-> WK N1 N2 N3 REM
pool=[0,1,2,3,5];
wth=3.5;
for ii=1:length(group_files)
    ii
    subj_fn = group_files(ii).name;
    
    name1 = '/sleep/results/base/';
    name = [name1 subj_fn];
    load(name)
    temp=group_files(ii).name;
    temp=strsplit(temp,'-');
    temp=temp(3);
    temp=strsplit(cell2mat(temp),'_');
    who=str2num(cell2mat(temp(1)));
    mapc=map_c.*(map_w>wth);
    if ismember(sleep_stage,pool)
        if isempty(Event)
            temp=strcat('non_stage',num2str(sleep_stage));
        else
            temp=strcat('event_stage',num2str(sleep_stage));
        end
        mapname = strcat('/sleep/results/average_map/mapc_', num2str(who),'_',temp,'_base_w_',num2str(wth),'.mat');
        save_map(mapc,mapname);
    end
end

%%
function save_map(mapcc,mapname)
if exist(mapname,'file')
    load(mapname)
    mapc=mapc+mapcc;
    flag=flag+1;
    save(mapname,'mapc','flag')
else
    mapc=mapcc;
    flag=1;
    save(mapname,'mapc','flag')
end
end