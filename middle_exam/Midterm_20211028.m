clear all; 
clc; 
close all;

%% 한국의 경제성장률, 인플레이션률, 실업률, 고용보조지표3

korea_raw   = readmatrix('korea_data','Sheet','Quarterly_Data','Range','B5:D251');
% 문제 : line 7 을 참고하여 같은 엑셀 파일 내 "Monthly_Data" 시트에서 고용보조지표3 시계열을 추출하시오.
korea_uem   = readmatrix('korea_data','Sheet','Monthly_Data','Range','A2:B226');

date_quart  = datenum(datetime(1959,10,1)+calquarters(1:247))';
date_month  = datenum(datetime(2002,12,1)+calmonths(1:225))';  % 월별 날짜 인덱스 생성함 2003:M01 - 2021:M09

gdp_start   = find(date_quart(:,1)==datenum('01-Jan-1960'));
cpi_start   = find(date_quart(:,1)==datenum('01-Jan-1965'));
uem_start   = find(date_quart(:,1)==datenum('01-Jul-1999'));
d_end       = find(date_quart(:,1)==datenum('01-Jul-2021'));

ggdp_q      = [date_quart(gdp_start+4:d_end,1)    100*(log(korea_raw(gdp_start+4:d_end,1))- log(korea_raw(gdp_start:d_end-4,1)) )]; 
inf_q       = [date_quart(cpi_start+4:d_end,1)    100*(log(korea_raw(cpi_start+4:d_end,2))- log(korea_raw(cpi_start:d_end-4,2)) )]; 
uem_q       = [date_quart(uem_start  :d_end,1)    korea_raw(uem_start:d_end,3)];
u4_m_start  = find(date_month(:,1)==datenum('01-Jan-2003')); u4_m_end    = find(date_month(:,1)==datenum('01-Sep-2021'));
% 문제 : 앞서 엑셀에서 추출된 고용보조지표3을 날짜 인덱스와 함께 "u4_m"로 저장하시오. 1열 날짜, 2열 시계열
u4_m        = [date_month(u4_m_start:u4_m_end,1)    (korea_uem(u4_m_start:u4_m_end,2))];
% 문제 : 고용보조지표3 월별자료를 분기별자료로 전환하시오. 1분기는 1,2,3월 평균 등 "u4_q"로 저장(1열 분기별 날짜 인덱스 포함)
u4_q        = [ u4_m(1:3:end,1) mean(reshape(u4_m(:,2),3,size(u4_m,1)/3),1)'];

%% 그림 1 : 시계열 자료

fig1 = figure('Name','Time Series');

s0_name = { '전년동기대비 경제성장률(실질GDP SA, 기준연도=2015)',...
            '전년동기대비 인플레이션률(CPI NSA , 2015=100)',...
            '공식실업률 SA',...
            '고용보조지표3 SA'};
for jj = 1:4
    if jj == 1
        xa = ggdp_q;
    elseif jj == 2
        xa = inf_q;
    elseif jj == 3
        xa = uem_q;
    % 문제 : 조건부 "elseif"를 이용하여 네번째 Loop에서는 고용보조지표3(분기별자료)를 불러오도록 설정하시오.    
    elseif jj == 4
        xa = u4_q;
    end
        
    subplot(4,1,jj);
    title(string(s0_name(jj)),'FontSize',20); hold on;
    plot(xa(:,1),xa(:,2),'k','LineWidth',2);
    xlabel('연도'); ylabel('%'); datetick('x','yyyy','keeplimits');          
    ax = gca; ax.XAxis.FontSize = 17; ax.YAxis.FontSize = 17;                     

end

cutoff      = find(inf_q(:,1)==datenum('01-Oct-1983'));     % 1984년 전후 cutoff 날짜 인덱스 저장
% 문제 : inf_q(:,2) 시계열 상에서 바로 위의 날짜 cutoff를 이용하여 각각 다른 이름으로 저장하시오. 
% 이름 예시 : "inf_q_a" 와 "inf_q_b"
inf_q_a     = inf_q(1:cutoff,2);
inf_q_b     = inf_q(cutoff:end,2);
% 문제 : 둘로 나눈 각각의 기간 동안 인플레이션률의 표준편차를 구하시오.
inf_q_a_std = std(inf_q_a(:,1))';
inf_q_b_std = std(inf_q_b(:,1))';
disp('-----------------------------------');
disp('1984년 전후 인플레이션률 변동성 비교')
% 문제 : disp 명령어를 이용하여 계산된 각 기간의 표준편차를 명령창에 보여주시오.
disp(inf_q_a_std);
disp('-----------------------------------');                 
disp(inf_q_b_std);
%% 2003-2021년 자료 추출(고용보조지표3 자료 기준 2003:Q1-2021:Q3 로 통일)

x_start     = datenum('01-Jan-2003');
x_end       = datenum('01-Jul-2021');
ggdp_q2     = ggdp_q(find(ggdp_q(:,1)==x_start):find(ggdp_q(:,1)==x_end),:);
inf_q2      = inf_q (find(inf_q(:,1) ==x_start):find(inf_q(:,1) ==x_end),:);
uem_q2      = uem_q (find(uem_q(:,1) ==x_start):find(uem_q(:,1) ==x_end),:);

% 문제 : uem_q2 와 u4_q 각각의 평균을 구하고 저장하시오.
uem_q2_m   = mean(uem_q2(:,2))'; u4_q_m   = mean(u4_q(:,2))';
disp('-----------------------------------');
disp('공식실업률과 고용보조지표 평균 비교')
% 문제 : disp 명령어를 통해 명령창에 각각의 평균값을 보여주시오.
disp(uem_q2_m);
disp('-----------------------------------');
disp(u4_q_m);

%% 그림 2 : 필립스 커브 
%  그림 3 : 오쿤의 법칙

fig2 = figure('Name','Phillips Curve');
fig3 = figure('Name','Okun''s Law');

s1_name = {'2003-2010 공식실업률기준','2011-2021 공식실업률기준','2003-2021 공식실업률기준',...
           '2003-2010 고용보조지표기준','2011-2021 고용보조지표기준','2003-2021 고용보조지표기준'};                
s2_name = {' : 필립스커브',' : 오쿤의 법칙'};

for ii = 1:3
    
    if ii == 1   
        xx_start = find(uem_q2(:,1)==datenum('01-Jan-2003'));
        xx_end   = find(uem_q2(:,1)==datenum('01-Oct-2010'));   
    elseif ii == 2 
        xx_start = find(uem_q2(:,1)==datenum('01-Jan-2011'));
        xx_end   = find(uem_q2(:,1)==datenum('01-Jul-2021'));   
    elseif ii == 3 
        xx_start = find(uem_q2(:,1)==datenum('01-Jan-2003'));
        xx_end   = find(uem_q2(:,1)==datenum('01-Jul-2021'));   
    end
    xx      = uem_q2(xx_start:xx_end,2);
    pp      = inf_q2(xx_start:xx_end,2);
    yy      = ggdp_q2(xx_start:xx_end,2);
    % 문제 : 바로 위 세 줄처럼 Loop 안에서 추출된 기간의 고용보조지표3를 "zz"로 저장하시오
    zz      = u4_q(xx_start:xx_end,2);
    
    corr_tab1(ii,1)     = corr(xx,pp);
    % 문제 : 고용보조지표3,"zz",와 인플레이션률,"pp", 간의 상관계수를 corr_tab1의 ii+3번째 행에 저장하시오.
    corr_tab1(ii+3,1)   = corr(zz,pp);
    corr_tab2(ii,1)     = corr(xx,yy);
    % 문제 : 고용보조지표3,"zz",와 경제성장률,"yy", 간의 상관계수를 corr_tab2의 ii+3번째 행에 저장하시오.
    corr_tab2(ii+3,1)   = corr(zz,yy);
    
    OLS1    = fitlm(xx,pp);
    % 문제 : 고용보조지표3을 설명변수로 필립스커브에 대한 회귀방정식을 추정하시오. "OLS2"로 저장
    OLS2    = fitlm(zz,pp);
    OLS3    = fitlm(xx,yy);
    % 문제 : 고용보조지표3을 설명변수로 오쿤의 법칙에 대한 회귀방정식을 추정하시오. "OLS4"로 저장
    OLS4    = fitlm(zz,yy);
    disp('---------------------------------------------------------');
    disp(strcat(string(s1_name(ii)),string(s2_name(1)) ));
    disp(OLS1);        
    
    disp('---------------------------------------------------------');
    disp(strcat(string(s1_name(ii+3)),string(s2_name(1)) ));
    % 문제 : "disp" 명령어를 사용하여 고용보조지표3 기준 필립스커브 회귀추정결과를 명령창에 보여주시오
    disp(OLS2);    
    
    disp('---------------------------------------------------------');
    disp(strcat(string(s1_name(ii)),string(s2_name(2)) ));
    disp(OLS3);        
    
    disp('---------------------------------------------------------');
    disp(strcat(string(s1_name(ii+3)),string(s2_name(2)) ));
    % 문제 : "disp" 명령어를 사용하여 고용보조지표3 기준 오쿤의 법칙 회귀추정결과를 명령창에 보여주시오
    disp(OLS4);
    
    set(groot,'currentfigure',fig2);
    
    subplot(2,3,ii);            
    plot(OLS1);     
    axis([3 5 -1 5]); title(string(s1_name(ii)),'FontSize',15); 
    xlabel('실업률(%)','FontSize',15); ylabel('인플레이션율(%)','FontSize',15);
    
    % 문제 : subplot 명령어를 이용하여 ii+3 번째 panel에 OLS2를 plot 하시오
    subplot(2,3,ii+3);
    plot(OLS2);
    axis([9 15 -1 5]); title(string(s1_name(ii+3)),'FontSize',15); 
    xlabel('고용보조지표(%)','FontSize',15); ylabel('인플레이션율(%)','FontSize',15);
    
    
    set(groot,'currentfigure',fig3);    
    
    subplot(2,3,ii);                    
    plot(OLS3);     
    axis([3 5 -2 12]);             
    title(string(s1_name(ii)),'FontSize',15); 
    xlabel('실업률(%)','FontSize',15); ylabel('GDP성장률(%)','FontSize',15);
        
    % 문제 : subplot 명령어를 이용하여 ii+3 번째 panel에 OLS4를 plot 하시오
    subplot(2,3,ii+3);
    plot(OLS4);
    axis([9 15 -2 12]); title(string(s1_name(ii+3)),'FontSize',15); 
    xlabel('고용보조지표(%)','FontSize',15); ylabel('GDP성장률(%)','FontSize',15);
    
end

Corr_Table = table(corr_tab1,corr_tab2,...
        'VariableNames',{'인플레이션률 vs. 실업률지표','GDP성장률 vs. 실업률지표'},...
        'RowNames',s1_name);
disp('---------------------------------------------------------');
disp('상관계수 비교 표');
disp(Corr_Table);
