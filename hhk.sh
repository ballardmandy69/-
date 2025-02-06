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
sysctl -w net.ipv4.tcp_fastopen_key="12345678-87654321-12345678-87654321"
sysctl -w net.ipv4.tcp_fastopen=3
sysctl -w net.ipv4.tcp_ecn=0
sysctl -w net.ipv4.tcp_frto=0
sysctl -w net.core.netdev_budget=2048
sysctl -w net.core.netdev_budget_usecs=12000
sysctl -w net.core.default_qdisc=fq
sysctl -w net.ipv4.tcp_reordering=50
sysctl -w net.ipv4.tcp_max_reordering=300
sysctl -w net.ipv4.tcp_notsent_lowat=32768
sysctl -w net.ipv4.tcp_retries1=5
sysctl -w net.ipv4.tcp_retries2=5
sysctl -w net.core.rmem_max=33554432
sysctl -w net.core.wmem_max=33554432
sysctl -w net.ipv4.tcp_rmem="8192 262144  33554432"
sysctl -w net.ipv4.tcp_wmem="8192 262144  33554432"
sysctl -w net.ipv4.tcp_mem="31457280 39321600 47185920"
tc qdisc replace dev ens5 root fq
tc qdisc del dev ens5 root

