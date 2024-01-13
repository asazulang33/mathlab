clear all; 
clc; 
close all;

%% 한국의 경제성장률, 인플레이션률, 실업률, 고용보조지표3

korea_raw   = readmatrix('korea_data','Sheet','Quarterly_Data','Range','B5:D251');
u4_m_raw    = readmatrix('korea_data','Sheet','Monthly_Data','Range','B2:B226');

date_quart  = datenum(datetime(1959,10,1)+calquarters(1:247))';
date_month  = datenum(datetime(2002,12,1)+calmonths(1:225))';

gdp_start   = find(date_quart(:,1)==datenum('01-Jan-1960'));
cpi_start   = find(date_quart(:,1)==datenum('01-Jan-1965'));
uem_start   = find(date_quart(:,1)==datenum('01-Jul-1999'));
d_end       = find(date_quart(:,1)==datenum('01-Jul-2021'));

ggdp_q      = [date_quart(gdp_start+4:d_end,1)    100*(log(korea_raw(gdp_start+4:d_end,1))- log(korea_raw(gdp_start:d_end-4,1)) )]; 
inf_q       = [date_quart(cpi_start+4:d_end,1)    100*(log(korea_raw(cpi_start+4:d_end,2))- log(korea_raw(cpi_start:d_end-4,2)) )]; 
uem_q       = [date_quart(uem_start  :d_end,1)    korea_raw(uem_start:d_end,3)];

u4_m        = [date_month u4_m_raw];
u4_q        = [u4_m(1:3:end,1) mean(reshape(u4_m(:,2),3,size(u4_m,1)/3),1)'];

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
    elseif jj == 4
        xa = u4_q;
    end
        
    subplot(4,1,jj);
    title(string(s0_name(jj)),'FontSize',20); hold on;
    plot(xa(:,1),xa(:,2),'k','LineWidth',2);
    xlabel('연도'); ylabel('%'); datetick('x','yyyy','keeplimits');          
    ax = gca; ax.XAxis.FontSize = 17; ax.YAxis.FontSize = 17;                     

end
cutoff      = find(inf_q(:,1)==datenum('01-Oct-1983'));
inf_q_a     = inf_q(1:cutoff,2);
inf_q_b     = inf_q(cutoff+1:end,2);

std_ab      = [std(inf_q_a); std(inf_q_b)];
mean_ab0    = [mean(inf_q_a); mean(inf_q_b)];

dummy0      = [ zeros(cutoff,1);   
                ones(length(inf_q(:,2))-cutoff,1)];

Table0      = table(dummy0,inf_q(:,2),...
    'VariableNames',{'1984_Dummy','Inflation Rate'});
OLS0        = fitlm(Table0);

set(groot,'currentfigure',fig1);
subplot(4,1,2); hold on;
plot(inf_q(1:cutoff,1),OLS0.Fitted(1:cutoff,:),'r','LineWidth',2);                      hold on;
plot(inf_q(cutoff+1:end,1),OLS0.Fitted(cutoff+1:end,:),'r','LineWidth',2);              hold on;
plot(inf_q(1:cutoff,1),OLS0.Fitted(1:cutoff,:)+std_ab(1),'b.','LineWidth',1.5);         hold on;
plot(inf_q(cutoff+1:end,1),OLS0.Fitted(cutoff+1:end,:)+std_ab(2),'b.','LineWidth',1.5); hold on;
plot(inf_q(1:cutoff,1),OLS0.Fitted(1:cutoff,:)-std_ab(1),'b.','LineWidth',1.5);         hold on;
plot(inf_q(cutoff+1:end,1),OLS0.Fitted(cutoff+1:end,:)-std_ab(2),'b.','LineWidth',1.5);


disp('-----------------------------------');
disp('1984년 전후 인플레이션률 평균 비교')
disp(OLS0);
disp('-----------------------------------');

% figure
% plot(OLS0);

%% 2003-2021년 자료 추출(고용보조지표3 자료 기준으로 통일)

x_start     = datenum('01-Jan-2003');
x_end       = datenum('01-Jul-2021');
ggdp_q2     = ggdp_q(find(ggdp_q(:,1)==x_start):find(ggdp_q(:,1)==x_end),:);
inf_q2      = inf_q (find(inf_q(:,1) ==x_start):find(inf_q(:,1) ==x_end),:);
uem_q2      = uem_q (find(uem_q(:,1) ==x_start):find(uem_q(:,1) ==x_end),:);

cutoff1     = find(uem_q2(:,1)==datenum('01-Oct-2010'));

dummy1      = [ zeros(cutoff1,1); 
                ones(length(inf_q2(:,2))-cutoff1,1)];
            
mean_ab     = [mean(uem_q2(:,2)); mean(u4_q(:,2))];
disp('-----------------------------------');
disp('공식실업률과 고용보조지표 평균 비교')
disp(mean_ab);
disp('-----------------------------------');


%% 그림 2 : 필립스 커브 
%  그림 3 : 오쿤의 법칙

fig2 = figure('Name','Phillips Curve');
fig3 = figure('Name','Okun''s Law');
fig4 = figure('Name','Phillips Curve : Dummy');
fig5 = figure('Name','Okun''s Law : Dummy');

s1_name = {'2003-2010 공식실업률기준','2011-2021 공식실업률기준','2003-2021 공식실업률기준',...
           '2003-2010 고용보조지표기준','2011-2021 고용보조지표기준','2003-2021 고용보조지표기준'};                
s2_name = {' : 필립스커브',' : 오쿤의 법칙'};
s3_name = {', 더미상수',', 더미 교차항'};

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
    zz      = u4_q(xx_start:xx_end,2);
    
    corr_tab1(ii,1)     = corr(xx,pp);
    corr_tab1(ii+3,1)   = corr(zz,pp);
    corr_tab2(ii,1)     = corr(xx,yy);
    corr_tab2(ii+3,1)   = corr(zz,yy);    
    
    Table1  = table(xx,zz,yy,pp,'VariableNames',{'U1','U4','GDP_Growth','Inflation'});
    
    OLS1    = fitlm(Table1,'Inflation~U1');
    OLS2    = fitlm(Table1,'Inflation~U4');
    OLS3    = fitlm(Table1,'GDP_Growth~U1');
    OLS4    = fitlm(Table1,'GDP_Growth~U4'); 
      
    disp('---------------------------------------------------------');
    disp(strcat(string(s1_name(ii)),string(s2_name(1)) ));
    disp(OLS1);        
    
    disp('---------------------------------------------------------');
    disp(strcat(string(s1_name(ii+3)),string(s2_name(1)) ));
    disp(OLS2);        
    
    disp('---------------------------------------------------------');
    disp(strcat(string(s1_name(ii)),string(s2_name(2)) ));
    disp(OLS3);        
    
    disp('---------------------------------------------------------');
    disp(strcat(string(s1_name(ii+3)),string(s2_name(2)) ));
    disp(OLS4);        
    
    if ii == 3
        Table2   = table(xx,zz,yy,pp,dummy1,'VariableNames',{'U1','U4','GDP_Growth','Inflation','Dummy_2010'});
        OLS5a    = fitlm(Table2,'Inflation~Dummy_2010+U1');
        OLS5b    = fitlm(Table2,'Inflation~Dummy_2010+U1+U1:Dummy_2010');
        OLS6a    = fitlm(Table2,'Inflation~Dummy_2010+U4');
        OLS6b    = fitlm(Table2,'Inflation~Dummy_2010+U4+U4:Dummy_2010');
        OLS7a    = fitlm(Table2,'GDP_Growth~Dummy_2010+U1');
        OLS7b    = fitlm(Table2,'GDP_Growth~Dummy_2010+U1+U1:Dummy_2010');
        OLS8a    = fitlm(Table2,'GDP_Growth~Dummy_2010+U4');
        OLS8b    = fitlm(Table2,'GDP_Growth~Dummy_2010+U4+U4:Dummy_2010');
        
        disp('---------------------------------------------------------');
        disp(strcat(string(s1_name(ii)),string(s2_name(1)),string(s3_name(1)) ));
        disp(OLS5a);        
        disp('---------------------------------------------------------');
        disp(strcat(string(s1_name(ii)),string(s2_name(1)),string(s3_name(2)) ));
        disp(OLS5b);
        disp('---------------------------------------------------------');
        disp(strcat(string(s1_name(ii+3)),string(s2_name(1)),string(s3_name(1)) ));
        disp(OLS6a);        
        disp('---------------------------------------------------------');
        disp(strcat(string(s1_name(ii+3)),string(s2_name(1)),string(s3_name(2)) ));
        disp(OLS6b);        
        disp('---------------------------------------------------------');
        disp(strcat(string(s1_name(ii)),string(s2_name(2)),string(s3_name(1)) ));
        disp(OLS7a);        
        disp('---------------------------------------------------------');
        disp(strcat(string(s1_name(ii)),string(s2_name(2)),string(s3_name(2)) ));
        disp(OLS7b);
        disp('---------------------------------------------------------');
        disp(strcat(string(s1_name(ii+3)),string(s2_name(2)),string(s3_name(1)) ));
        disp(OLS8a);        
        disp('---------------------------------------------------------');
        disp(strcat(string(s1_name(ii+3)),string(s2_name(2)),string(s3_name(2)) ));
        disp(OLS8b);       
        
        set(groot,'currentfigure',fig4);
        subplot(2,2,1);
        scatter(xx(1:cutoff1),pp(1:cutoff1),'b.'); hold on;
        plot(xx(1:cutoff1),OLS5a.Fitted(1:cutoff1),'b'); hold on;
        scatter(xx(cutoff1+1:end),pp(cutoff1+1:end),'r.'); hold on;
        plot(xx(cutoff1+1:end),OLS5a.Fitted(cutoff1+1:end),'r'); hold on;       
        axis([3 5 -1 5]); title(strcat( string(s1_name(ii)), string(s3_name(1)) ),'FontSize',15); 
        xlabel('실업률(%)','FontSize',15); ylabel('인플레이션율(%)','FontSize',15);
        
        subplot(2,2,2); 
        scatter(xx(1:cutoff1),pp(1:cutoff1),'b.'); hold on;
        plot(xx(1:cutoff1),OLS5b.Fitted(1:cutoff1),'b'); hold on;
        scatter(xx(cutoff1+1:end),pp(cutoff1+1:end),'r.'); hold on;
        plot(xx(cutoff1+1:end),OLS5b.Fitted(cutoff1+1:end),'r'); hold on;
        axis([3 5 -1 5]); title(strcat(string(s1_name(ii)),string(s3_name(2)) ),'FontSize',15); 
        xlabel('실업률(%)','FontSize',15); ylabel('인플레이션율(%)','FontSize',15);
        
        subplot(2,2,3); 
        scatter(zz(1:cutoff1),pp(1:cutoff1),'b.'); hold on;
        plot(zz(1:cutoff1),OLS6a.Fitted(1:cutoff1),'b'); hold on;
        scatter(zz(cutoff1+1:end),pp(cutoff1+1:end),'r.'); hold on;
        plot(zz(cutoff1+1:end),OLS6a.Fitted(cutoff1+1:end),'r'); hold on;
        axis([9 15 -1 5]); title(strcat(string(s1_name(ii+3)),string(s3_name(1)) ),'FontSize',15); 
        xlabel('실업률(%)','FontSize',15); ylabel('인플레이션율(%)','FontSize',15);
        
        subplot(2,2,4); 
        scatter(zz(1:cutoff1),pp(1:cutoff1),'b.'); hold on;
        plot(zz(1:cutoff1),OLS6b.Fitted(1:cutoff1),'b'); hold on;
        scatter(zz(cutoff1+1:end),pp(cutoff1+1:end),'r.'); hold on;
        plot(zz(cutoff1+1:end),OLS6b.Fitted(cutoff1+1:end),'r'); hold on;
        axis([9 15 -1 5]); title(strcat(string(s1_name(ii+3)),string(s3_name(2)) ),'FontSize',15); 
        xlabel('실업률(%)','FontSize',15); ylabel('인플레이션율(%)','FontSize',15);
        
        set(groot,'currentfigure',fig5);
        subplot(2,2,1);
        scatter(xx(1:cutoff1),yy(1:cutoff1),'b.'); hold on;
        plot(xx(1:cutoff1),OLS7a.Fitted(1:cutoff1),'b'); hold on;
        scatter(xx(cutoff1+1:end),yy(cutoff1+1:end),'r.'); hold on;
        plot(xx(cutoff1+1:end),OLS7a.Fitted(cutoff1+1:end),'r'); hold on;       
        axis([3 5 -2 12]); title(strcat(string(s1_name(ii)),string(s3_name(1)) ),'FontSize',15); 
        xlabel('실업률(%)','FontSize',15); ylabel('GDP성장률(%)','FontSize',15);
        
        subplot(2,2,2); 
        scatter(xx(1:cutoff1),yy(1:cutoff1),'b.'); hold on;
        plot(xx(1:cutoff1),OLS7b.Fitted(1:cutoff1),'b'); hold on;
        scatter(xx(cutoff1+1:end),yy(cutoff1+1:end),'r.'); hold on;
        plot(xx(cutoff1+1:end),OLS7b.Fitted(cutoff1+1:end),'r'); hold on;
        axis([3 5 -2 12]); title(strcat(string(s1_name(ii)),string(s3_name(2)) ),'FontSize',15); 
        xlabel('실업률(%)','FontSize',15); ylabel('GDP성장률(%)','FontSize',15);
        
        subplot(2,2,3); 
        scatter(zz(1:cutoff1),yy(1:cutoff1),'b.'); hold on;
        plot(zz(1:cutoff1),OLS8a.Fitted(1:cutoff1),'b'); hold on;
        scatter(zz(cutoff1+1:end),yy(cutoff1+1:end),'r.'); hold on;
        plot(zz(cutoff1+1:end),OLS8a.Fitted(cutoff1+1:end),'r'); hold on;
        axis([9 15 -2 12]); title(strcat(string(s1_name(ii+3)),string(s3_name(1)) ),'FontSize',15); 
        xlabel('실업률(%)','FontSize',15); ylabel('GDP성장률(%)','FontSize',15);
        
        subplot(2,2,4); 
        scatter(zz(1:cutoff1),yy(1:cutoff1),'b.'); hold on;
        plot(zz(1:cutoff1),OLS8b.Fitted(1:cutoff1),'b'); hold on;
        scatter(zz(cutoff1+1:end),yy(cutoff1+1:end),'r.'); hold on;
        plot(zz(cutoff1+1:end),OLS8b.Fitted(cutoff1+1:end),'r'); hold on;
        axis([9 15 -2 12]); title(strcat(string(s1_name(ii+3)),string(s3_name(2)) ),'FontSize',15); 
        xlabel('실업률(%)','FontSize',15); ylabel('GDP성장률(%)','FontSize',15);
    end
    
    
    set(groot,'currentfigure',fig2);
    
    subplot(2,3,ii);            
    plot(OLS1);     
    axis([3 5 -1 5]); title(string(s1_name(ii)),'FontSize',15); 
    xlabel('실업률(%)','FontSize',15); ylabel('인플레이션율(%)','FontSize',15);
        
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
