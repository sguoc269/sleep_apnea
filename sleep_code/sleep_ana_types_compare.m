clear
clc
close all
group_dir = "/sleep/results/";
load('/sleep/results/types_base.mat')
load('/sleep/results/types_m09.mat')
load('/sleep/results/types_m18.mat')
ren=intersect(types_base(:,1),types_m09(:,1));
ren=intersect(types_m18(:,1),ren);
%% whole
[a,b]=intersect(types_base(:,1),ren);
types_base=types_base(b,:);
[a,b]=intersect(types_m09(:,1),ren);
types_m09=types_m09(b,:);
[a,b]=intersect(types_m18(:,1),ren);
types_m18=types_m18(b,:);

index=5;
bar(my_mean([types_base(:,index) types_m09(:,index) types_m18(:,index)],1))