clear
clc
group_dir = "/sleep/results/m18";%base m09 m18
group_files = dir(strcat(group_dir, filesep, '*.mat'));
sub=[];
for ii=1:length(group_files)
   subj_fn = group_files(ii).name; 
%    sub=[sub; str2double(subj_fn(14:19))];% base
   sub=[sub; str2double(subj_fn(13:18))];% m09 m18
end
sub=unique(sub);
%% 01235-> WK N1 N2 N3 REM
pool=[0,1,2,3,5];
wth=3.5;
for ii=1:length(sub)
    eval(['map_rem_' num2str(sub(ii)) '=zeros(30,30);'])
    eval(['map_n3_' num2str(sub(ii)) '=zeros(30,30);'])
    eval(['c_rem_' num2str(sub(ii)) '=0;'])
    eval(['c_n3_' num2str(sub(ii)) '=0;'])
end
for ii=1:length(group_files)
    ii
    subj_fn = group_files(ii).name;
    who = subj_fn(14:19);
    
    name1 = '/sleep/results/m18/'; %%%%%%%%%% base m09 m18
    name = [name1 subj_fn];
    load(name)
    temp=group_files(ii).name;
    temp=strsplit(temp,'-');
    temp=temp(3);
    temp=strsplit(cell2mat(temp),'_');
    who=(cell2mat(temp(1)));
    mapc=map_c.*(map_w>wth);
    if sleep_stage==5 %REM
        if isempty(Event) % no events
            eval(['map_rem_' who '=' 'map_rem_' who '+mapc;'])
            eval(['c_rem_' who '=' 'c_rem_' who '+1;'])
        end
    end
    
    if sleep_stage==3 %N3
        if isempty(Event) % no events
            eval(['map_n3_' who '=' 'map_n3_' who '+mapc;'])
            eval(['c_n3_' who '=' 'c_n3_' who '+1;'])
        end
    end
    
end

for ii=1:length(sub)
    eval(['temp1=c_rem_' num2str(sub(ii)) ';'])
    eval(['temp2=c_n3_' num2str(sub(ii)) ';'])
    
    if temp1~=0&&temp2~=0
        eval(['map_rem_' num2str(sub(ii)) '=map_rem_' num2str(sub(ii)) './c_rem_' num2str(sub(ii)) ';'])
        eval(['map_n3_' num2str(sub(ii)) '=map_n3_' num2str(sub(ii)) './c_n3_' num2str(sub(ii)) ';'])
        eval(['ratio_remDn3_' num2str(sub(ii)) '=map_rem_' num2str(sub(ii)) './map_n3_' num2str(sub(ii)) ';'])
    else
        eval(['ratio_remDn3_' num2str(sub(ii)) '=nan(30,30);'])
    end
end