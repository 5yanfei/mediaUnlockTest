#!/bin/bash
mediaUnlockTest="https://github.com/5yanfei/mediaUnlockTest/raw/main/mediaUnlockTest.sh"
proxyUrl="127.0.0.1:1080"

if [ ! -f "./ip.txt" ]; then
  echo "Please generate "ip.txt" file..."
  exit
fi

read -p "请输入远程端服务器统一ssh端口：" sshPort
curl -sSL "${mediaUnlockTest}" | grep ^"# \*" | cut -d "*" -f 2 | tr "\n" ","|sed -e 's/,$/\n/'

if ! curl ${proxyUrl} > /dev/null 2>&1; then
    curl -sSL "${mediaUnlockTest}" | grep ^"# \*" | cut -d "*" -f 2 | tr "\n" ","|sed -e 's/,$/\n/' > output.csv
    for serverIP in $(cat ip.txt)
    do
        ssh -p ${sshPort} root@${serverIP} "bash <(curl -sSL "${mediaUnlockTest}")" | tr "\n" ","|sed -e 's/,$/\n/' >> output.csv       
    done
else
    curl -x ${proxyUrl} -sSL "${mediaUnlockTest}" | grep ^"# \*" | cut -d "*" -f 2 | tr "\n" ","|sed -e 's/,$/\n/' > output.csv
    for serverIP in $(cat ip.txt)
    do
        ssh -p ${sshPort} -o "ProxyCommand=nc --proxy ${proxyUrl} --proxy-type=socks5 %h %p" root@${serverIP} "bash <(curl -sSL "${mediaUnlockTest}")"|tr "\n" ","|sed -e 's/,$/\n/' >> output.csv
            if [ $? -ne 0 ]; then
                echo "ssh root@${serverIP} failed"
            fi
    done
fi
