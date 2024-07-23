clc;clear;
% eeglab
% set(gcf,'HandleVisibility','off');%隐藏eeglab窗口
group_dir = '/sleep/polysomnography/edfs/baseline';     % 此处路径需要设置为自己的文件目录
group_files = dir([group_dir, filesep, '*.edf']);  %filesep是\的意思
ii=[6 8 11 16 21 27 28 31];
for it=1:length(group_files)
    i=ii(it);
    subj_fn = group_files(i).name;
    EEG = pop_biosig(strcat(group_dir, filesep, subj_fn), 'importevent','off');
    EEG = pop_chanedit(EEG, 'lookup','/sleep/tool/eeglab/plugins/dipfit/standard_BEM/elec/standard_1005.elc');
    EEG = pop_select( EEG,'channel', 1:6);  %去除无关电极
    EEG = pop_reref( EEG, []);    %全脑平均重参考
    %     EEG = pop_resample( EEG, 500);   %降采样
%     EEG = pop_eegfiltnew(EEG, 'locutoff',0.1,'hicutoff',48);   %带通滤波
    EEG = pop_eegfiltnew(EEG, 'locutoff',0.1,'plotfreqz',1);
    EEG = pop_eegfiltnew(EEG, 'hicutoff',48,'plotfreqz',1);
    %     EEG = pop_eegfiltnew(EEG, 'locutoff',48,'hicutoff',52,'revfilt',1);    %陷波滤波
    EEG = pop_saveset( EEG, 'filename',strcat(group_files(i).name(1:end-4), '.set'), 'filepath',strcat(group_dir, filesep, '_step1'));   %注意需要在运行代码之前，文件目录下建一个_resam_remch的文件夹，以下雷同
% end


%%   运行 ICA
group1_dir = '/sleep/polysomnography/edfs/baseline';     % 此处路径需要设置为自己的文件目录
group1_dir1 = '/sleep/polysomnography/edfs/baseline/_step1';     % 此处路径需要设置为自己的文件目录
group1_files = dir([group1_dir1, filesep, '*.set']);  %filesep是\的意思
% for i=1%:length(group1_files)
    subj_fn = group1_files(i).name;
    EEG = pop_loadset('filename',strcat(subj_fn(1:end-4), '.set'), 'filepath', strcat(group1_dir, filesep, '_step1')); %导入数据
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');   % 跑ICA
    EEG = pop_saveset( EEG, 'filename',strcat(group1_files(i).name(1:end-4), '.set'), 'filepath',strcat(group1_dir, filesep, '_ica'));  %保存数据

% end

%% 使用ICLabel自动去除ICA成分
group1_dir = '/sleep/polysomnography/edfs/baseline';     % 此处路径需要设置为自己的文件目录
group1_dir2 = '/sleep/polysomnography/edfs/baseline/_ica';
group1_files = dir([group1_dir2, filesep, '*.set']);  %filesep是\的意思
% for i=1%:length(group1_files)
    subj_fn = group1_files(i).name;
    EEG = pop_loadset('filename',strcat(subj_fn(1:end-4), '.set'), 'filepath', group1_dir2);
    EEG = pop_iclabel(EEG, 'default');
    EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]); % 标记伪迹成分。这里可以自定义设定阈值，依次为Brain, Muscle, Eye, Heart, Line Noise, Channel Noise, Other.
    EEG = pop_subcomp( EEG, [], 0);   %去除上述伪迹成分
    
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',strcat(group1_files(i).name(1:end-4), '.set'), 'filepath',strcat(group1_dir, filesep, '_rm_ica'));

end