#!/bin/bash

# 定义脚本路径
SCRIPT_NAME="one_click_script.sh"

# 写入脚本内容
cat > $SCRIPT_NAME << 'EOF'
#!/bin/bash

# 一键执行脚本

# 定义每个命令和对应的输入
commands=(
  "bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) rel_nodeclient \"-o -t 9ea7c5c8-8942-4a18-b10e-8df69f999e25 -u https://zumo.moe\""
  "bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) rel_nodeclient \"-o -t 7962b5dd-f3d6-40bc-999b-39b90598b7b0 -u https://zumo.moe\""
  "bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) rel_nodeclient \"-o -t 0fcbf7ec-a000-45f7-88c8-d3e1a299248f -u https://ny.hiccupc.xyz\""
)

# 定义每个命令的输入
inputs=(
  "zumo\ny\n\n"
  "a\n\n\n"
  "z\n\n\n"
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
sysctl -w net.ipv4.tcp_notsent_lowat=196608  
sysctl -w net.ipv4.tcp_limit_output_bytes=262144
sysctl -w net.core.wmem_max=16777216     
sysctl -w net.ipv4.tcp_wmem="4096 131072 16777216"
sysctl -w net.core.rmem_max=16777216  
sysctl -w net.ipv4.tcp_rmem="4096 262144 16777216"
sysctl -w net.ipv4.tcp_early_retrans=2   
sysctl -w net.ipv4.tcp_recovery=1       
sysctl -w net.ipv4.tcp_retries2=5       
sysctl -w net.ipv4.tcp_frto=2     
sysctl -w net.ipv4.tcp_reordering=30    
sysctl -w net.ipv4.tcp_dsack=1        
sysctl -w net.ipv4.tcp_timestamps=1
sysctl -w net.ipv4.tcp_rfc1337=1
sysctl -w net.ipv4.tcp_sack=1
tc qdisc replace dev ens5 root fq
tc qdisc del dev ens5 root
tc -s qdisc show dev ens5

bash <(curl -fLSs https://file.hiccupc.xyz/hy2/sb-auto.sh) "json" "yml"  

# 下载并执行 ddns.sh 到 /root 目录，并写入日志
echo "开始下载 ddns.sh 到 /root 目录..." | tee -a /root/ddns.log

curl -fLSs https://file.hiccupc.xyz/hy2/ddns.sh -o /root/ddns.sh 2>> /root/ddns.log

if [[ -f /root/ddns.sh ]]; then
  chmod +x /root/ddns.sh
  echo "执行 /root/ddns.sh ..." | tee -a /root/ddns.log
  bash /root/ddns.sh >> /root/ddns.log 2>&1
  echo "✅ ddns.sh 执行完毕，日志位于 /root/ddns.log" | tee -a /root/ddns.log
else
  echo "❌ 下载 ddns.sh 失败，未找到 /root/ddns.sh" | tee -a /root/ddns.log
  exit 1
fi
