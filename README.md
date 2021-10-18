## 描述：
>`mediaUnlockTest.sh` ：在海外服务器上执行可输出是否支持解锁各类流媒体；不过输出做了修改，仅输出结果（Yes or No ...）。
>`start_MediaUnlockTest.sh` ：通过ssh远程批量测试远端服务器是否支持解锁各类流媒体；通过 ssh 远程执行 mediaUnlockTest.sh脚本，需要在本地先建立 ip.txt 文件（每行一个IP），然后收集对应的结果，追加到output.csv文件。
## 使用方法：  
    bash <(curl -sSL "https://github.com/wyf010530/mediaUnlockTest/raw/main/start_MediaUnlockTest.sh")   
## 参考：
https://github.com/CoiaPrant/MediaUnlock_Test

https://github.com/LovelyHaochi/StreamUnlockTest
