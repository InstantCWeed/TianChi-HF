import matplotlib.pyplot as plt
import wfdb
from wfdb import processing
import numpy as np



#将txt转为.dat .hea 文件, 以2.txt为例
signals = np.zeros((5000,8))
file = open('2','r')
line = file.readline()
i=0
while line!='':
    linex = line.strip().split()
    for j in range(0,len(linex),1):
        signals[i][j] = eval(linex[j])
    i = i+1
    line = file.readline()

file.close()
wfdb.wrsamp('2', fs = 500, units=['mV', 'mV', 'mV', 'mV', 'mV', 'mV', 'mV', 'mV'], sig_name=['I','II','V1','V2','V3','V4','V5','V6'], p_signal=signals, fmt=['16', '16', '16', '16', '16', '16', '16', '16'])  #fs是采样频率, fmt是16进制存储





#使用gqrs定位算法矫正峰值位置
def peaks_hr(sig, peak_inds, fs, title, figsize=(20,10), saveto=None):
    #这个函数是用来画出信号峰值和心律
    #计算心律
    hrs=processing.compute_hr(sig_len=sig.shape[0], qrs_inds=peak_inds, fs=fs)

    N=sig.shape[0]

    fig, ax_left=plt.subplots(figsize=figsize)
    ax_right=ax_left.twinx()

    ax_left.plot(sig, color='#3979f0', label='Signal')
    ax_left.plot(peak_inds, sig[peak_inds], 'rx', marker='x', color='#8b0000', label='Peak', markersize=12)#画出标记
    ax_right.plot(np.arange(N), hrs, label='Heart rate', color='m', linewidth=2)#画出心律，y轴在右边

    ax_left.set_title(title)

    ax_left.set_xlabel('Time (ms)')
    ax_left.set_ylabel('ECG (mV)', color='#3979f0')
    ax_right.set_ylabel('Heart rate (bpm)', color='m')
    #设置颜色使得和线条颜色一致
    ax_left.tick_params('y', colors='#3979f0')
    ax_right.tick_params('y', colors='m')
    if saveto is not None:
        plt.savefig(saveto, dpi=600)
    plt.show()
#加载ECG信号
record=wfdb.rdrecord('./2')  #.hea .dat文件名称
#help(wfdb.rdrecord)
#使用gqrs算法定位qrs波位置
qrs_inds=processing.gqrs_detect(sig=record.p_signal[:, 0], fs=record.fs)  #未矫正位置
#画出结果
#peaks_hr(sig=record.p_signal, peak_inds=qrs_inds, fs=record.fs, title='GQRS peak detection on record 100')
#修正峰值，将其设置为局部最大值
min_bpm=20
max_bpm=230
#使用可能最大的bpm作为搜索半径
search_radius=int(record.fs*60/max_bpm)
corrected_peak_inds=processing.correct_peaks(record.p_signal[:, 0], peak_inds=qrs_inds, search_radius=search_radius, smooth_window_size=150)
#输出矫正后的QRS波峰位置
print('Corrected gqrs detected peak indices:', sorted(corrected_peak_inds))




# Feature 1: 计算R波波峰
signal=record.p_signal
R_peak = -100
for x in corrected_peak_inds:
    if R_peak < max(signal[x]):
        R_peak = max(signal[x])
print(R_peak)



# Feature 2: 计算RR间隔
rr = processing.hr.calc_rr(corrected_peak_inds)
RR_interval = np.mean(rr)
print(RR_interval)



# Feature 3: 计算平均心率
HV_mean = processing.hr.calc_mean_hr(rr, 500)  #500是采样频率
print(HV_mean)







#peaks_hr(sig=record.p_signal, peak_inds=sorted(corrected_peak_inds), fs=record.fs, title='Corrected GQRS peak detection on record 100')

