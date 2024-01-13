clear all; 
clc; 
close all;

%% 한국의 경제성장률, 인플레이션률, 실업률, 고용보조지표3

korea_raw   = readmatrix('20211203_iipdata','Sheet','Sheet1','Range','B27:G259');

date_month  = datenum(datetime(2003,1,1)+calmonths(1:220))';

g_iip       = 100 * ( log(korea_raw(14:end  ,1))-log(korea_raw(2:end-12,1)) ) ;
g_iip_bac   = 100 * ( log(korea_raw(13:end-1,1))-log(korea_raw(1:end-13,1)) ) ;
d_cal       =             korea_raw(14:end  ,2) -    korea_raw(2:end-12,2)    ;
g_exp       = 100 * ( log(korea_raw(14:end  ,3))-log(korea_raw(2:end-12,3)) ) ;
g_exp2      = 100 * ( log(korea_raw(14:end  ,4))-log(korea_raw(2:end-12,4)) ) ;
g_kospi     = 100 * ( log(korea_raw(14:end  ,5))-log(korea_raw(2:end-12,5)) ) ;
bsi         =             korea_raw(14:end  ,6);

%% 그림 1 : 시계열 자료

fig1 = figure('Name','Time Series');
s0_name = { '광공업생산지수(원계열, 전년동기대비 증가율), 기준연도=2015)',...
            '총수출액(경상기준, 전년동기대비 증가율)',...
            '총수출액 선박석유제외(경상기준, 전년동기대비 증가율)',...
            'KOSPI 지수(전년동기대비 증가율)',...
            'BSI 지수(전년동기대비 증가율)'};
var_name= {'g_iip','g_exp','g_exp2','g_kospi','bsi'};        
for jj = 1:5    
    subplot(5,1,jj);
    title(string(s0_name(jj)),'FontSize',20); hold on;
    plot(date_month(:,1),eval(string(var_name(jj))),'k','LineWidth',2);
    xlabel('연도'); ylabel('%'); datetick('x','yyyy','keeplimits');          
    ax = gca; ax.XAxis.FontSize = 17; ax.YAxis.FontSize = 17;                     
end
fig1.OuterPosition = [250 500 1000 1000];

corr_tab        = [ corr(g_iip,g_exp);
                    corr(g_iip,g_exp2);
                    corr(g_iip,d_cal);
                    corr(g_iip,g_kospi);
                    corr(g_iip,bsi) ];
s1_name         = {'광공업생산지수,','총수출액','총수출액 선박석유제외','조업일수','KOSPI','BSI','Fitted 광공업생산지수'};                
Corr_Table      = table(corr_tab,...
                        'VariableNames',{'광공업생산지수 vs. X'},...
                        'RowNames',s1_name(2:end-1));
disp('---------------------------------------------------------');
disp('상관계수 비교 표');    
disp(Corr_Table);
disp('---------------------------------------------------------');

s2_name         = {'IIP','IIP_bac','EXP','EXP2','CAL','KOSPI','BSI'};
Table1          = table(g_iip,g_iip_bac,g_exp,g_exp2,d_cal,g_kospi,bsi,'VariableNames',s2_name);

OLS0            = fitlm(Table1,'IIP~IIP_bac');
OLS1a           = fitlm(Table1,'IIP~IIP_bac+EXP');
OLS2a           = fitlm(Table1,'IIP~IIP_bac+EXP+CAL');
OLS3a           = fitlm(Table1,'IIP~IIP_bac+EXP+CAL+KOSPI');
OLS4a           = fitlm(Table1,'IIP~IIP_bac+EXP+CAL+KOSPI+BSI');
OLS1b           = fitlm(Table1,'IIP~IIP_bac+EXP2');
OLS2b           = fitlm(Table1,'IIP~IIP_bac+EXP2+CAL');
OLS3b           = fitlm(Table1,'IIP~IIP_bac+EXP2+CAL+KOSPI');
OLS4b           = fitlm(Table1,'IIP~IIP_bac+EXP2+CAL+KOSPI+BSI');

disp('---------------------------------------------------------');
disp(OLS0);    
disp('---------------------------------------------------------');
for ww = 1:4
    disp('---------------------------------------------------------');
    disp(eval(strcat('OLS',num2str(ww),'a')));    
    disp('------------------------------------');
    disp(eval(strcat('OLS',num2str(ww),'b')));
    disp('---------------------------------------------------------');
end

var_name2       = {'g_exp','g_exp2','d_cal','g_kospi','bsi'};  
x_label         = {' 증가율 %',' 증가율 %',' 증감',' 증가율 %',' 지수 Level'};
fig2            = figure('Name','산점도');
for jj = 1:5
    subplot(3,2,jj); 
    title(strcat('광공업생산지수 vs. ',s1_name(jj+1)),'FontSize',20); hold on;
    xx = eval(string(var_name2(jj)));    
    scatter(xx,g_iip,300,'k.');
    xlabel(strcat(s1_name(jj+1),x_label(jj)));
    ylabel('광업생산지수 증가율 %');                    
end
fig2.OuterPosition = [500 500 1000 1000];

fig3            = figure('Name','IIP Models');
yy0 = [1 4];
for yy = 1:2
    subplot(2,2,2*(yy-1)+1); title(strcat('OLS',num2str(yy0(yy)),'a'),'FontSize',12); hold on;
    xx = eval(strcat('OLS',num2str(yy0(yy)),'a.Fitted'));
    plot(date_month(:,1),g_iip,'k','LineWidth',1.2); hold on;
    plot(date_month(:,1),xx,'b','LineWidth',2);
    xlabel('연도'); ylabel('%'); datetick('x','yyyy','keeplimits');          
    ax = gca; ax.XAxis.FontSize = 17; ax.YAxis.FontSize = 17;                     
    
    subplot(2,2,2*(yy-1)+2); title(strcat('OLS',num2str(yy0(yy)),'b'),'FontSize',12); hold on;
    xx = eval(strcat('OLS',num2str(yy0(yy)),'b.Fitted'));
    plot(date_month(:,1),g_iip,'k','LineWidth',1.2); hold on;
    plot(date_month(:,1),xx,'b','LineWidth',2);
    xlabel('연도'); ylabel('%'); datetick('x','yyyy','keeplimits');          
    ax = gca; ax.XAxis.FontSize = 17; ax.YAxis.FontSize = 17;                     
end
legend(['관측치';'적합치']);
fig3.OuterPosition = [750 500 1500 800];