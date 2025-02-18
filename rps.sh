#!/bin/bash

# 确保 bc 已安装
command -v bc >/dev/null 2>&1 || yum install bc -y || apt install bc -y

# 设置 RPS sock flow entries
sysctl -w net.core.rps_sock_flow_entries=65536

# 获取 CPU 核心数
cc=$(grep -c processor /proc/cpuinfo)

# 计算每个核心的 flow count
rfc=$(echo 65536/$cc | bc)
for fileRfc in $(find /sys/class/net -type f -path "*/queues/rx-*/rps_flow_cnt" 2>/dev/null)
do
    echo $rfc > "$fileRfc"
done

# 计算 CPU 掩码
c=$(bc -l -q << EOF
a1=l($cc)
a2=l(2)
scale=2
a1/a2
EOF
)

cpus=$(printf "%0${c}x" 0 | tr '0' 'f')
cpuss=$(printf "%0${c}x" 0 | tr '0' 'f')
cpusss=$(printf "%0${c}x" 0 | tr '0' 'f')
cpussss=$(printf "%0${c}x" 0 | tr '0' 'f')

# 应用 RPS CPU 掩码
for fileRps in $(find /sys/class/net -type f -path "*/queues/rx-*/rps_cpus" 2>/dev/null)
do
    echo $cpus > "$fileRps"
    echo $cpuss > "$fileRps"
    echo $cpusss > "$fileRps"
    echo $cpussss > "$fileRps"
done


bash /root/rps.sh
sed -i '/bash \/root\/rps.sh/d' /etc/rc.local
echo "bash /root/rps.sh" >> /etc/rc.local

echo "rps已开启"
