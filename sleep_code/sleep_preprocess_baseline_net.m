function abc_preprocess_baseline_net(i)
eeglab
%     dbstop if all error
group_dir = '/sleep/polysomnography/edfs/baseline/_step1';     % 此处路径需要设置为自己的文件目录
group_files = dir([group_dir, filesep, '*.set']);
subj_fn = group_files(i).name;
EEG = pop_loadset('filename',subj_fn,'filepath',strcat(group_dir, filesep));

group_dir2 = '/sleep/polysomnography/annotations-events-profusion/baseline';     % 此处路径需要设置为自己的文件目录
group_files = dir([group_dir2, filesep, '*.xml']);
subj_fn = group_files(i).name;
[tree, RootName, DOMnode] = xml_read(strcat(group_dir2, filesep, subj_fn));
%Event
T = tree.ScoredEvents.ScoredEvent;
TT = Events(T);
% cut first and last 10 min
stage = cell2mat(tree.SleepStages.SleepStage);
N = length(stage)*30;
nn = 10*60; %600/30=20
EEG = pop_select( EEG, 'time',[nn N]);
nnn = N-2*nn;
EEG = pop_select( EEG, 'time',[0 nnn]);
stage = stage(21:end-20);
% net
step = 30;
x1 = 0:step:length(stage)*step-step;
x2 = x1+step;

j_count = 1;
for j = 1:length(stage)
    try
        EEG_temp = pop_select( EEG, 'time',[x1(j) x2(j)] );
        EEG_temp = pop_clean_rawdata(EEG_temp, 'FlatlineCriterion',5,'ChannelCriterion','off','LineNoiseCriterion',4,'Highpass','off','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] );
        [hang,lie] = size(EEG_temp.data);
        
        if lie > x2(1)*0.9 && hang==6%build net
            
            EEG_temp = pop_runica(EEG_temp, 'icatype', 'runica', 'extended',1,'interrupt','on');   % 跑ICA
            EEG_temp = pop_iclabel(EEG_temp, 'default');
            EEG_temp = pop_icflag(EEG_temp, [NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]); % 标记伪迹成分。这里可以自定义设定阈值，依次为Brain, Muscle, Eye, Heart, Line Noise, Channel Noise, Other.
            EEG_temp = pop_subcomp( EEG_temp, [], 0);   %去除上述伪迹成分
            [hang,lie] = size(EEG_temp.data);
            
            if lie > x2(1)*0.9 && hang==6%build net
                data = EEG_temp.data;
                
                fs = 256;
                % filter
                data_new = [];
                for jj = 1:6
                    data_temp1 = bandpass(data(jj,:),[0.5 3.5],fs);
                    data_temp2 = bandpass(data(jj,:),[4 7.5],fs);
                    data_temp3 = bandpass(data(jj,:),[8 11.5],fs);
                    data_temp4 = bandpass(data(jj,:),[12 15.5],fs);
                    data_temp5 = bandpass(data(jj,:),[16 19.5],fs);
                    
                    data_new = [data_new data_temp1' data_temp2' data_temp3' data_temp4' data_temp5'];
                end
                [map_c,map_w] = trynew_callmaplineonetime(data_new);
                [maps_c,maps_w] = trynew_callmaplineonetime_shuffle(data_new);
                sleep_stage = stage(j);
                Event = TT(TT(:,2)==j,1);
                if ~isempty(Event)
                    Event = unique(Event);
                end
                index = j;
                
                name1 = '/sleep/results/base/';
                name = [name1 subj_fn(1:19) '_' num2str(j_count) '.mat'];
                save(name,'map_c','map_w','sleep_stage','Event','index')
                
                name1 = '/sleep/results/base_s/';
                name = [name1 subj_fn(1:19) '_' num2str(j_count) '.mat'];
                save(name,'maps_c','maps_w')
                
                j_count = j_count+1;
            end
        end
    catch
        j
    end
end
end


function TT = Events(T)
[a,~] = size(T);
count =1;
for i = 1:a
    if strcmp(T(i).Name,'Hypopnea')
        temp_s = T(i).Start;
        temp_t = T(i).Duration;
        start = fix(temp_s/30)-20;
        to = fix((temp_t+temp_s)/30)-20;
        duration = to-start;
        jj = 0;
        for j = duration:-1:0
            TT(count,1) = 0;
            TT(count,2) = start+jj;
            jj = jj+1;
            count = count+1;
        end
        
    elseif strcmp(T(i).Name,'Obstructive Apnea')
        temp_s = T(i).Start;
        temp_t = T(i).Duration;
        start = fix(temp_s/30)-20;
        to = fix((temp_t+temp_s)/30)-20;
        duration = to-start;
        jj = 0;
        for j = duration:-1:0
            TT(count,1) = 1;
            TT(count,2) = start+jj;
            jj = jj+1;
            count = count+1;
        end
        
    elseif strcmp(T(i).Name,'Central Apnea')
        temp_s = T(i).Start;
        temp_t = T(i).Duration;
        start = fix(temp_s/30)-20;
        to = fix((temp_t+temp_s)/30)-20;
        duration = to-start;
        jj = 0;
        for j = duration:-1:0
            TT(count,1) = 2;
            TT(count,2) = start+jj;
            jj = jj+1;
            count = count+1;
        end
    end
end
end