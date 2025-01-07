#!/bin/bash

# 定义脚本路径
SCRIPT_NAME="one_click_script.sh"

# 写入脚本内容
cat > $SCRIPT_NAME << 'EOF'
#!/bin/bash

# 一键执行脚本

# 定义每个命令和对应的输入
commands=(
  "bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) rel_nodeclient \"-o -t 14088747-463d-4545-9134-fc3c555c9afd -u https://zumo.moe\""
  "bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) rel_nodeclient \"-o -t 7962b5dd-f3d6-40bc-999b-39b90598b7b0 -u https://zumo.moe\""
  "bash <(curl -fLSs https://dl.nyafw.com/download/nyanpass-install.sh) rel_nodeclient \"-o -t 143d235b-313b-457e-9278-858294082457 -u https://ny.hiccupc.xyz\""
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
sysctl -w net.ipv4.tcp_adv_win_scale=-1
sysctl -w net.ipv4.tcp_reordering=50
sysctl -w net.ipv4.tcp_max_reordering=300
sysctl -w net.ipv4.tcp_notsent_lowat=32767
sysctl -w net.ipv4.tcp_retries1=3
sysctl -w net.ipv4.tcp_retries2=3
sysctl -w net.core.rmem_max=33554432
sysctl -w net.core.wmem_max=33554432
sysctl -w net.ipv4.tcp_rmem="8192 262144 33554432"
sysctl -w net.ipv4.tcp_wmem="8192 262144 33554432"
sysctl -w net.ipv4.tcp_mem="31457280 39321600 47185920"
tc qdisc replace dev ens5 root fq
tc qdisc del dev ens5 root
