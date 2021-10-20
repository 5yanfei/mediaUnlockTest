#!/bin/bash
mediaUnlockTest="https://github.com/5yanfei/mediaUnlockTest/raw/main/mediaUnlockTest.sh"
proxyUrl="127.0.0.1:1080"
date=`date "+%Y-%m-%d %H:%M:%S"`

if [ ! -f "./ip.txt" ]; then
  echo "Please generate "ip.txt" file..."
  exit
fi

read -p "请输入远程端服务器统一ssh端口：" sshPort

echo "当前时间：${date}，开始测试..."

if ! curl ${proxyUrl} > /dev/null 2>&1; then
  curl -sSL "${mediaUnlockTest}" | grep ^"# \*" | cut -d "*" -f 2 | tr "\n" ","|sed -e 's/,$/\n/' > output.csv
  for serverIP in $(cat ip.txt)
  do
      echo "测试 ${serverIP} 中"
      ssh -p ${sshPort} root@${serverIP} -C -q "bash <(curl -sSL "${mediaUnlockTest}") 4 ${serverIP}" | tr "\n" ","|sed -e 's/,$/\n/' >> output.csv
          if [ $? -ne 0 ]; then
              echo "ssh -p ${sshPort} root@${serverIP} failed"
          fi
  done
else
  curl -x ${proxyUrl} -sSL "${mediaUnlockTest}" | grep ^"# \*" | cut -d "*" -f 2 | tr "\n" ","|sed -e 's/,$/\n/' > output.csv
  for serverIP in $(cat ip.txt)
  do
      echo "测试 ${serverIP} 中"
      ssh -p ${sshPort} -C -q -o "ProxyCommand=nc --proxy ${proxyUrl} --proxy-type=socks5 %h %p" root@${serverIP} "bash <(curl -sSL "${mediaUnlockTest}") 4 ${serverIP}" | tr "\n" ","|sed -e 's/,$/\n/' >> output.csv
          if [ $? -ne 0 ]; then
              echo "ssh -p ${sshPort} root@${serverIP} failed"
          fi
    done
fi

echo "当前时间：${date}，测试完成..."
