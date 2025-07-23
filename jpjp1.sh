#!/bin/bash

# 定义脚本路径
SCRIPT_NAME="one_click_script.sh"

# 写入脚本内容
cat > $SCRIPT_NAME << 'EOF'
#!/bin/bash

# 一键执行脚本

apt update -y 
apt install -y curl wget nano vim unzip sudo git iptables

# 定义每个命令和对应的输入
commands=(
  "bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) rel_nodeclient \"-o -t 14088747-463d-4545-9134-fc3c555c9afd -u https://zumo.moe\""
  "bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) rel_nodeclient \"-o -t 7962b5dd-f3d6-40bc-999b-39b90598b7b0 -u https://zumo.moe\""
  "bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) rel_nodeclient \"-o -t 143d235b-313b-457e-9278-858294082457 -u https://ny.hiccupc.xyz\""
  "bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) rel_nodeclient \"-o -t 8c7882c6-3fcb-4cd3-81a1-b4937d550b5f -u https://zumo.moe\""
)

# 定义每个命令的输入
inputs=(
  "zumo\ny\n\n"
  "a\n\n\n"
  "z\n\n\n"
  "e\n\n\n"
)

# 遍历执行命令
for i in "${!commands[@]}"; do
  echo "正在执行: ${commands[$i]}"
  # 用 echo 模拟输入，通过管道传递到命令
  echo -e "${inputs[$i]}" | eval "${commands[$i]}"
done
EOF

# 赋予脚本可执行权限
chmod +x $SCRIPT_NAME

# 执行生成的脚本
./$SCRIPT_NAME
sysctl -w net.core.default_qdisc=fq
sysctl -w net.ipv4.tcp_congestion_control=bbr
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
tc qdisc replace dev ens5 root fq
tc qdisc del dev ens5 root
tc -s qdisc show dev ens5

bash <(curl -fLSs https://file.hiccupc.xyz/hy2/sb-auto.sh) "json" "jpv1"

echo "开始下载 jpddns1.sh 到 /root 目录..." | tee -a /root/ddns.log
curl -fLSs https://file.hiccupc.xyz/hy2/jpddns1.sh -o /root/jpddns1.sh 2>> /root/ddns.log

if [[ -f /root/jpddns1.sh ]]; then
  chmod +x /root/jpddns1.sh
  echo "执行 /root/jpddns1.sh ..." | tee -a /root/ddns.log
  bash /root/jpddns1.sh >> /root/ddns.log 2>&1
  echo "✅ jpddns1.sh 执行完毕" | tee -a /root/ddns.log
else
  echo "❌ 下载 jpddns1.sh 失败，未找到 /root/jpddns1.sh" | tee -a /root/ddns.log
  exit 1
fi
