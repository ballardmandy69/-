#!/bin/bash

# 定义脚本路径
SCRIPT_NAME="one_click_script.sh"

# 写入脚本内容
cat > $SCRIPT_NAME << 'EOF'
#!/bin/bash

# 一键执行脚本

S=ee OPTIMIZE=1 bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) rel_nodeclient "-t 5b026a25-e256-4047-9e92-be8a1e6c45b1 -u https://ny.hiccupc.xyz"
S=zumo bash <(curl -fLSs https://dispatch.nyafw.com/download/nyanpass-install.sh) rel_nodeclient "-t f96ba212-3920-4160-a5bc-f5b2f218c50e -u https://zumo.moe"
EOF
# 赋予脚本可执行权限
chmod +x $SCRIPT_NAME

# 执行生成的脚本
./$SCRIPT_NAME
sysctl -w net.core.default_qdisc=fq
sysctl -w net.ipv4.tcp_mem="31457280 39321600 47185920"
sysctl -w net.ipv4.tcp_slow_start_after_idle=0
sysctl -w net.ipv4.tcp_notsent_lowat=98304
sysctl -w net.ipv4.tcp_limit_output_bytes=2097152 
sysctl -w net.core.rmem_max=33554432
sysctl -w net.core.wmem_max=33554432
sysctl -w net.ipv4.tcp_rmem="8192 262144 33554432"
sysctl -w net.ipv4.tcp_wmem="4096 262144 33554432"
sysctl -w net.ipv4.tcp_early_retrans=2
sysctl -w net.ipv4.tcp_recovery=3      
sysctl -w net.ipv4.tcp_retries1=2
sysctl -w net.ipv4.tcp_retries2=5
sysctl -w net.ipv4.tcp_syn_retries=3
sysctl -w net.ipv4.tcp_frto=2
sysctl -w net.ipv4.tcp_reordering=10 
sysctl -w net.ipv4.tcp_dsack=1           
sysctl -w net.ipv4.tcp_timestamps=1
sysctl -w net.ipv4.tcp_rfc1337=1
sysctl -w net.ipv4.tcp_sack=1  
sysctl -w net.ipv4.tcp_pacing_ss_ratio=300
sysctl -w net.ipv4.tcp_pacing_ca_ratio=150
sysctl -w net.core.netdev_budget=3000
tc qdisc replace dev ens5 root fq
tc qdisc del dev ens5 root
tc -s qdisc show dev ens5

wget -qO- https://raw.githubusercontent.com/uk0/lotspeed/main/install.sh | sudo bash
lotspeed preset aggressive
lotspeed set lotserver_adaptive 0
lotspeed set lotserver_rate 125000000
lotspeed set lotserver_gain 40
lotspeed set lotserver_beta 896
lotspeed set lotserver_max_cwnd 8000
lotspeed set lotserver_min_cwnd 64
sysctl -w net.ipv4.tcp_no_metrics_save=1



# 下载并执行 ddns.sh 到 /root 目录，并写入日志
echo "开始下载 ddns.sh 到 /root 目录..." | tee -a /root/ddns.log

curl -fLSs https://file.hiccupc.xyz/hy2/ddns2.sh -o /root/ddns.sh 2>> /root/ddns.log

if [[ -f /root/ddns.sh ]]; then
  chmod +x /root/ddns.sh
  echo "执行 /root/ddns.sh ..." | tee -a /root/ddns.log
  bash /root/ddns.sh >> /root/ddns.log 2>&1
  echo "✅ ddns.sh 执行完毕，日志位于 /root/ddns.log" | tee -a /root/ddns.log
else
  echo "❌ 下载 ddns.sh 失败，未找到 /root/ddns.sh" | tee -a /root/ddns.log
  exit 1
fi
