#!/bin/bash

# 定义脚本路径
SCRIPT_NAME="one_click_script.sh"

# 写入脚本内容
cat > $SCRIPT_NAME << 'EOF'
#!/bin/bash

# 一键执行脚本

# 定义每个命令和对应的输入
commands=(
  "bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) rel_nodeclient \"-o -t 1086bd2d-909e-415a-a974-096e6155c827 -u https://ny.hiccupc.xyz\""
  "bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) rel_nodeclient \"-o -t 83ddd531-619d-40da-ba78-2759d99c3b2a -u https://zumo.moe\""
)

# 定义每个命令的输入
inputs=(
  "nyanpass\ny\n\n"
  "zumo\n\n\n"
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
sysctl -w net.ipv4.tcp_limit_output_bytes=1048576 
sysctl -w net.core.rmem_max=33554432
sysctl -w net.core.wmem_max=33554432
sysctl -w net.ipv4.tcp_rmem="8192 262144 33554432"
sysctl -w net.ipv4.tcp_wmem="4096 262144 33554432"
sysctl -w net.ipv4.tcp_early_retrans=2
sysctl -w net.ipv4.tcp_recovery=3      
sysctl -w net.ipv4.tcp_retries1=2
sysctl -w net.ipv4.tcp_retries2=5
sysctl -w net.ipv4.tcp_syn_retries=3
sysctl -w net.ipv4.tcp_frto=0
sysctl -w net.ipv4.tcp_reordering=30  
sysctl -w net.ipv4.tcp_dsack=1           
sysctl -w net.ipv4.tcp_timestamps=1
sysctl -w net.ipv4.tcp_rfc1337=1
sysctl -w net.ipv4.tcp_sack=1  
tc qdisc replace dev ens5 root fq
tc qdisc del dev ens5 root
tc -s qdisc show dev ens5

