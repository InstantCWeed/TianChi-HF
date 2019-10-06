%����Ԥ����ȥ��

DirStr = 'F:\hf_round1_testA\testA\'; %����λ��
namelist = dir(DirStr); %���г����ǿ��ֹͣ����matlab

for i = 3:length(namelist)   %ǰ����Ϊ./ �� ../

%��ȡ�ļ�
[I, II, V1, V2, V3, V4, V5, V6] = textread(strcat(DirStr,namelist(i).name),'%n%n%n%n%n%n%n%n','headerlines',1);

%����III, aVR, aVF, aVL
III=II-I;
aVR=-(I+II)/2;
aVL=I-II/2;
aVF=II-I/2;
M=[I, II, III, V1, V2, V3, V4, V5, V6, aVR, aVL, aVF];


%ȥ�롢��һ��
for j=1:length(M(1,:))
Denois = Denoising(M(:,j));
%Denois_normal = (mapminmax(Denois'))';   %תΪ������
%M(:,j) = Denois_normal;

end


%�����ļ���д���ļ�
dirFile = strsplit(namelist(i).name,'.');

txtDir = dirFile(1,1);   %�ļ���������
f_out = fopen(char(strcat('I:\hf_testA_Denoising\',txtDir)),'w');  %�������ļ�
[row, col] = size(M);
for m=1:row
    for n=1:col
      fprintf(f_out, '%.8f ', M(m,n));
    end
    fprintf(f_out, '\r\n');
end
fclose(f_out);

end

