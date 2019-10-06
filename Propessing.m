%数据预处理，去噪

DirStr = 'F:\hf_round1_testA\testA\'; %数据位置
namelist = dir(DirStr); %运行出错后强行停止重启matlab

for i = 3:length(namelist)   %前两个为./ 和 ../

%读取文件
[I, II, V1, V2, V3, V4, V5, V6] = textread(strcat(DirStr,namelist(i).name),'%n%n%n%n%n%n%n%n','headerlines',1);

%计算III, aVR, aVF, aVL
III=II-I;
aVR=-(I+II)/2;
aVL=I-II/2;
aVF=II-I/2;
M=[I, II, III, V1, V2, V3, V4, V5, V6, aVR, aVL, aVF];


%去噪、归一化
for j=1:length(M(1,:))
Denois = Denoising(M(:,j));
%Denois_normal = (mapminmax(Denois'))';   %转为列向量
%M(:,j) = Denois_normal;

end


%创建文件、写入文件
dirFile = strsplit(namelist(i).name,'.');

txtDir = dirFile(1,1);   %文件名的数字
f_out = fopen(char(strcat('I:\hf_testA_Denoising\',txtDir)),'w');  %生成新文件
[row, col] = size(M);
for m=1:row
    for n=1:col
      fprintf(f_out, '%.8f ', M(m,n));
    end
    fprintf(f_out, '\r\n');
end
fclose(f_out);

end

