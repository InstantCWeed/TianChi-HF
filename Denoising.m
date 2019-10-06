%MΪ�������źţ����ź�
function Denois_M = Denoising(M)
%------------------------------��ͨ�˲����˳������ź�------------------------------
TIME=1:5000;   %�����㣬���ڻ�ͼ

%һ�������źŵ��˳�����ͨ�˲���
Fs=5000;                        %����Ƶ�ʣ���������
fp=80;fs=100;                    %ͨ����ֹƵ�ʣ������ֹƵ��
rp=1.4;rs=1.6;                    %ͨ�������˥��
wp=2*pi*fp;ws=2*pi*fs;   
[n,wn]=buttord(wp,ws,rp,rs,'s');     %'s'��ȷ��������˹ģ���˲����״κ�3dB�� ��ֹģ��Ƶ��
[z,P,k]=buttap(n);   %��ƹ�һ��������˹ģ���ͨ�˲�����zΪ���㣬pΪ����kΪ����
[bp,ap]=zp2tf(z,P,k);  %ת��ΪHa(p),bpΪ����ϵ����apΪ��ĸϵ��
[bs,as]=lp2lp(bp,ap,wp); %Ha(p)ת��Ϊ��ͨHa(s)��ȥ��һ����bsΪ����ϵ����asΪ��ĸϵ��
[hs,ws]=freqs(bs,as);         %ģ���˲����ķ�Ƶ��Ӧ
[bz,az]=bilinear(bs,as,Fs);     %��ģ���˲���˫���Ա任
[h1,w1]=freqz(bz,az);         %�����˲����ķ�Ƶ��Ӧ
m=filter(bz,az,M);    %��ͨ���˺���źţ�m=filter(bz,az,M(:,3));

%{
figure
freqz(bz,az);
title('������˹��ͨ�˲�����Ƶ����');
%}


%������Ƶ���ŵ����ƣ������˲���
%50Hz�ݲ�������һ����ͨ�˲�������һ����ͨ�˲������
%����ͨ�˲�����һ��ȫͨ�˲�����ȥһ����ͨ�˲�������
Me=100;               %�˲�������
L=100;                %���ڳ���
beta=100;             %˥��ϵ��
wc1=49/Fs*pi;     %wc1Ϊ��ͨ�˲�����ֹƵ�ʣ���Ӧ51Hz
wc2=51/Fs*pi;     %wc2Ϊ��ͨ�˲�����ֹƵ�ʣ���Ӧ49Hz
h=ideal_lp(0.132*pi,Me)-ideal_lp(wc1,Me)+ideal_lp(wc2,Me);  %hΪ�ݲ���
w=kaiser(L,beta);   %��ͨ�˲���
y=h.*rot90(w);       %yΪ50Hz�ݲ��������Ӧ����
m2=filter(y,1,m);    %m2Ϊ�����˲�����ź�


%��������Ư�Ƶľ��� : IIR�����������˲���
Wp=1.4*2/Fs;     %ͨ����ֹƵ�� 
Ws=0.6*2/Fs;     %�����ֹƵ�� 
devel=0.005;    %ͨ���Ʋ� 
Rp=20*log10((1+devel)/(1-devel));   %ͨ���Ʋ�ϵ��  
Rs=20;                          %���˥�� 
[N Wn]=ellipord(Wp,Ws,Rp,Rs,'s');   %����Բ�˲����Ľ״� 
[b a]=ellip(N,Rp,Rs,Wn,'high');        %����Բ�˲�����ϵ�� 
[hw,w]=freqz(b,a,512);   
result =filter(b,a,m2);    %IIR��������ź�

Denois_M = result;


 %{
figure
N=512
subplot(2,1,1);plot(abs(fft(m2))*2/N);
xlabel('Ƶ��(Hz)');ylabel('��ֵ');title('ԭʼ�ź�Ƶ��');grid;
subplot(2,1,2);plot(abs(fft(result))*2/N);
xlabel('Ƶ��(Hz)');ylabel('��ֵ');title('�����˲���');grid;s
ubplot(2,1,2);plot(abs(fft(result))*2/N);
xlabel('�����˲����ź�Ƶ��');ylabel('��ֵ');grid;
%}


%{
figure
subplot (4,1,1); plot(TIME,M(1:5000,1));
xlabel('t(s)');ylabel('��ֵ');title('ԭʼ�ź�');grid;
subplot (4,1,2); plot(TIME,m(1:5000));
xlabel('t(s)');ylabel('��ֵ');title('�������--��ͨ�˲�����ź�');grid;
subplot(4,1,3);plot(TIME,m2(1:5000));
xlabel('t(s)');ylabel('��ֵ');title('��Ƶ����--�����˲����ź�');grid;
subplot(4,1,4); plot(TIME,result(1:5000)); 
xlabel('t(s)');ylabel('��ֵ');title('����Ư��--�����˲����ź�');grid
%}

%{
%��ʾ�˲�ǰ���Ƶ��ͼ��
N=512;  %N�����DFT
n=0:N-1;
mf=fft(M(:,1),N);               %��N�������Ƶ�ױ任������Ҷ�任�����൱�ڽض��ź�
mag=abs(mf);
f=(0:length(mf)-1)*Fs/length(mf);  %����Ƶ�ʱ任
 
figure
subplot(2,1,1)
plot(f,mag);
axis([0,5000,1,50]);
grid;      %����Ƶ��ͼ
xlabel('Ƶ��(HZ)');
ylabel('��ֵ');
title('�ĵ��ź�Ƶ��ͼ');
 
mfa=fft(m,N);                    %����Ƶ�ױ任������Ҷ�任��
maga=abs(mfa);
fa=(0:length(mfa)-1)*Fs/length(mfa);  %����Ƶ�ʱ任
subplot(2,1,2)
plot(fa,maga);axis([0,5000,1,50]);grid;  %����Ƶ��ͼ
xlabel('Ƶ��(HZ)');ylabel('��ֵ');title('��ͨ�˲����ĵ��ź�Ƶ��ͼ');
%}
%{
wn=M(:,1);
P=10*log10(abs(fft(wn).^2)/N);
f=(0:length(P)-1)/length(P);
figure
plot(f,P);grid
xlabel('��һ��Ƶ��');ylabel('����(dB)');title('�ĵ��źŵĹ�����');
%}
end