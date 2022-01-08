#!/bin/bash
countHardShUrl="https://gitee.com/yan-fei/count-hard/attach_files/938721/download/countHard.sh"
which wget &> /dev/null

if [ $? -eq 0 ]; then
    wget ${countHardShUrl}  -P /tmp  &> /dev/null && bash /tmp/countHard.sh && rm /tmp/countHard.sh
else
    which curl &> /dev/null
        if [ $? -eq 0 ]; then
        curl -L ${countHardShUrl} -o /tmp/countHard.sh &> /dev/null && bash /tmp/countHard.sh && rm /tmp/countHard.sh
        else 
            apt install curl &> /dev/null
                if [ $? -eq 0 ]; then
                curl -L ${countHardShUrl} -o /tmp/countHard.sh &> /dev/null && bash /tmp/countHard.sh && rm /tmp/countHard.sh
                else
                    echo "No wget and curl commands"
                    exit 1
                fi
        fi
fi
