%M为待处理信号，列信号
function Denois_M = Denoising(M)
%------------------------------低通滤波器滤除肌电信号------------------------------
TIME=1:5000;   %样本点，用于绘图

%一、肌电信号的滤除：低通滤波器
Fs=5000;                        %采样频率，样本点数
fp=80;fs=100;                    %通带截止频率，阻带截止频率
rp=1.4;rs=1.6;                    %通带、阻带衰减
wp=2*pi*fp;ws=2*pi*fs;   
[n,wn]=buttord(wp,ws,rp,rs,'s');     %'s'是确定巴特沃斯模拟滤波器阶次和3dB， 截止模拟频率
[z,P,k]=buttap(n);   %设计归一化巴特沃斯模拟低通滤波器，z为极点，p为零点和k为增益
[bp,ap]=zp2tf(z,P,k);  %转换为Ha(p),bp为分子系数，ap为分母系数
[bs,as]=lp2lp(bp,ap,wp); %Ha(p)转换为低通Ha(s)并去归一化，bs为分子系数，as为分母系数
[hs,ws]=freqs(bs,as);         %模拟滤波器的幅频响应
[bz,az]=bilinear(bs,as,Fs);     %对模拟滤波器双线性变换
[h1,w1]=freqz(bz,az);         %数字滤波器的幅频响应
m=filter(bz,az,M);    %低通过滤后的信号，m=filter(bz,az,M(:,3));

%{
figure
freqz(bz,az);
title('巴特沃斯低通滤波器幅频曲线');
%}


%二、工频干扰的抑制：带陷滤波器
%50Hz陷波器：由一个低通滤波器加上一个高通滤波器组成
%而高通滤波器由一个全通滤波器减去一个低通滤波器构成
Me=100;               %滤波器阶数
L=100;                %窗口长度
beta=100;             %衰减系数
wc1=49/Fs*pi;     %wc1为高通滤波器截止频率，对应51Hz
wc2=51/Fs*pi;     %wc2为低通滤波器截止频率，对应49Hz
h=ideal_lp(0.132*pi,Me)-ideal_lp(wc1,Me)+ideal_lp(wc2,Me);  %h为陷波器
w=kaiser(L,beta);   %带通滤波器
y=h.*rot90(w);       %y为50Hz陷波器冲击响应序列
m2=filter(y,1,m);    %m2为带阻滤波后的信号


%三、基线漂移的纠正 : IIR零相移数字滤波器
Wp=1.4*2/Fs;     %通带截止频率 
Ws=0.6*2/Fs;     %阻带截止频率 
devel=0.005;    %通带纹波 
Rp=20*log10((1+devel)/(1-devel));   %通带纹波系数  
Rs=20;                          %阻带衰减 
[N Wn]=ellipord(Wp,Ws,Rp,Rs,'s');   %求椭圆滤波器的阶次 
[b a]=ellip(N,Rp,Rs,Wn,'high');        %求椭圆滤波器的系数 
[hw,w]=freqz(b,a,512);   
result =filter(b,a,m2);    %IIR矫正后的信号

Denois_M = result;


 %{
figure
N=512
subplot(2,1,1);plot(abs(fft(m2))*2/N);
xlabel('频率(Hz)');ylabel('幅值');title('原始信号频谱');grid;
subplot(2,1,2);plot(abs(fft(result))*2/N);
xlabel('频率(Hz)');ylabel('幅值');title('线性滤波后');grid;s
ubplot(2,1,2);plot(abs(fft(result))*2/N);
xlabel('线性滤波后信号频谱');ylabel('幅值');grid;
%}


%{
figure
subplot (4,1,1); plot(TIME,M(1:5000,1));
xlabel('t(s)');ylabel('幅值');title('原始信号');grid;
subplot (4,1,2); plot(TIME,m(1:5000));
xlabel('t(s)');ylabel('幅值');title('肌电干扰--低通滤波后的信号');grid;
subplot(4,1,3);plot(TIME,m2(1:5000));
xlabel('t(s)');ylabel('幅值');title('工频干扰--带阻滤波后信号');grid;
subplot(4,1,4); plot(TIME,result(1:5000)); 
xlabel('t(s)');ylabel('幅值');title('基线漂移--线性滤波后信号');grid
%}

%{
%显示滤波前后的频域图像
N=512;  %N个点的DFT
n=0:N-1;
mf=fft(M(:,1),N);               %对N个点进行频谱变换（傅里叶变换），相当于截断信号
mag=abs(mf);
f=(0:length(mf)-1)*Fs/length(mf);  %进行频率变换
 
figure
subplot(2,1,1)
plot(f,mag);
axis([0,5000,1,50]);
grid;      %画出频谱图
xlabel('频率(HZ)');
ylabel('幅值');
title('心电信号频谱图');
 
mfa=fft(m,N);                    %进行频谱变换（傅里叶变换）
maga=abs(mfa);
fa=(0:length(mfa)-1)*Fs/length(mfa);  %进行频率变换
subplot(2,1,2)
plot(fa,maga);axis([0,5000,1,50]);grid;  %画出频谱图
xlabel('频率(HZ)');ylabel('幅值');title('低通滤波后心电信号频谱图');
%}
%{
wn=M(:,1);
P=10*log10(abs(fft(wn).^2)/N);
f=(0:length(P)-1)/length(P);
figure
plot(f,P);grid
xlabel('归一化频率');ylabel('功率(dB)');title('心电信号的功率谱');
%}
end