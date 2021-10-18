#!/bin/bash
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"
UA_Dalvik="Dalvik/2.1.0 (Linux; U; Android 9; ALP-AL00 Build/HUAWEIALP-AL00)"
DisneyAuth="grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Atoken-exchange&latitude=0&longitude=0&platform=browser&subject_token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJiNDAzMjU0NS0yYmE2LTRiZGMtOGFlOS04ZWI3YTY2NzBjMTIiLCJhdWQiOiJ1cm46YmFtdGVjaDpzZXJ2aWNlOnRva2VuIiwibmJmIjoxNjIyNjM3OTE2LCJpc3MiOiJ1cm46YmFtdGVjaDpzZXJ2aWNlOmRldmljZSIsImV4cCI6MjQ4NjYzNzkxNiwiaWF0IjoxNjIyNjM3OTE2LCJqdGkiOiI0ZDUzMTIxMS0zMDJmLTQyNDctOWQ0ZC1lNDQ3MTFmMzNlZjkifQ.g-QUcXNzMJ8DwC9JqZbbkYUSKkB1p4JGW77OON5IwNUcTGTNRLyVIiR8mO6HFyShovsR38HRQGVa51b15iAmXg&subject_token_type=urn%3Abamtech%3Aparams%3Aoauth%3Atoken-type%3Adevice"
DisneyHeader="authorization: Bearer ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84"
CountryCode=`hostname | awk -F "-" '{print $3}'`
NodeID=`hostname | awk -F "-" '{print $4}'`
#tr "\n" ","|sed -e 's/,$/\n/'
function InstallJQ() {
    #安装JQ
    if [ -e "/etc/redhat-release" ];then
        yum install epel-release -y -q > /dev/null 2>&1
        yum install jq -y -q > /dev/null 2>&1
        elif [[ $(cat /etc/os-release | grep '^ID=') =~ ubuntu ]] || [[ $(cat /etc/os-release | grep '^ID=') =~ debian ]];then
        apt-get update -y > /dev/null 2>&1
        apt-get install jq -y > /dev/null 2>&1
        elif [[ $(cat /etc/issue | grep '^ID=') =~ alpine ]];then
        apk update > /dev/null 2>&1
        apk add jq > /dev/null 2>&1
    else
        echo "请手动安装jq"
        exit
    fi
}

function PharseJSON() {
    # 使用方法: PharseJSON "要解析的原JSON文本" "要解析的键值"
    # Example: PharseJSON ""Value":"123456"" "Value" [返回结果: 123456]
    echo -n $1 | jq -r .$2;
}

function Failed_Network_Connection(){
    if [[ "$result" == "curl"* ]]; then
        echo "Failed (Network Connection)"
        return
    fi
}

function GameTest_Steam(){
    # Steam Currency
    local result=`curl -${1} --user-agent "${UA_Browser}" -fsSL --max-time 30 https://store.steampowered.com/app/761830 2>&1 | grep priceCurrency | cut -d '"' -f4`   
    if [ ! -n "$result" ]; then
        echo "Failed (Network Connection)"
    else
        echo "${result}"
    fi
}

function MediaUnlockTest_Netflix() {
    # Netflix
    local result=`curl -${1} --user-agent "${UA_Browser}" -sSL "https://www.netflix.com/" 2>&1`
    Failed_Network_Connection

    if [ "$result" == "Not Available" ];then
        echo "Unsupport"
        return
    fi
    
    local result=`curl -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/80018499" 2>&1`
    if [[ "$result" == *"page-404"* ]] || [[ "$result" == *"NSEZ-403"* ]];then
        echo "No"
        return
    fi
    
    local result1=`curl  -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/70143836" 2>&1`    # 绝命毒师
    local result2=`curl  -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/80027042" 2>&1`    # 闪电侠   
    local result3=`curl  -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/70140425" 2>&1`    # 逃
    local result4=`curl  -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/70283261" 2>&1`    # 始组家族
    local result5=`curl  -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/70143860" 2>&1`    # 吸血新时代
    local result6=`curl  -${1} --user-agent "${UA_Browser}" -sL "https://www.netflix.com/title/70202589" 2>&1`    # 新世纪福尔摩斯
    
    if [[ "$result1" == *"page-404"* ]] && [[ "$result2" == *"page-404"* ]] && [[ "$result3" == *"page-404"* ]] && [[ "$result4" == *"page-404"* ]] && [[ "$result5" == *"page-404"* ]] && [[ "$result6" == *"page-404"* ]];then
        echo "Only Homemade"
        return
    fi
    
    local region=`tr [:lower:] [:upper:] <<< $(curl  --user-agent "${UA_Browser}" -fs --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/80018499" | cut -d '/' -f4 | cut -d '-' -f1)` 
    
    if [[ ! -n "$region" ]];then
        region="US"
    fi
        echo "Yes(Region: ${region})"
    return
}

function MediaUnlockTest_MyTVSuper() {
    # MyTVSuper
    local result=`curl -${1} -sSL --max-time 30 "https://www.mytvsuper.com/iptest.php" 2>&1`  
    Failed_Network_Connection
    
    if [[ "$result" == *"HK"* ]];then
        echo "Yes"
        return
    fi
    echo "No"
}

function MediaUnlockTest_YouTube_Region() {
    # YouTube Region
    local result=`curl -${1} --user-agent "${UA_Browser}" -sSL "https://www.youtube.com/" 2>&1`  
    Failed_Network_Connection
    
    local result=`curl -${1} --user-agent "${UA_Browser}" -sL "https://www.youtube.com/red" | sed 's/,/\n/g' | grep "countryCode" | cut -d '"' -f4`
    if [ -n "$result" ]; then
        echo "${result}"
        return
    fi
    
    echo "No"
    return
}

function MediaUnlockTest_HBONow() {
    # HBO Now
    local result=`curl -${1} --user-agent "${UA_Browser}" -fsSL --max-time 30 --write-out "%{url_effective}\n" --output /dev/null https://play.hbonow.com/ 2>&1`
    if [[ "$result" != "curl"* ]]; then
        if [ "${result}" = "https://play.hbonow.com" ] || [ "${result}" = "https://play.hbonow.com/" ]; then
            echo "Yes"
            elif [ "${result}" = "http://hbogeo.cust.footprint.net/hbonow/geo.html" ] || [ "${result}" = "http://geocust.hbonow.com/hbonow/geo.html" ]; then
            echo "No"
        else
            echo "Failed (Parse Json)"
        fi
    else
        echo "Failed (Network Connection)"
    fi
}

function MediaUnlockTest_BBC() {
    # BBC
    local result=`curl -${1} --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 30 http://ve-dash-uk.live.cf.md.bbci.co.uk/`
    if [ "${result}" = "000" ]; then
        echo "Failed (Network Connection)"
        elif [ "${result}" = "403" ]; then
        echo "No"
        elif [ "${result}" = "404" ]; then
        echo "404"
    else
        echo "Failed (Unexpected Result: $result)"
    fi
}

function MediaUnlockTest_NowE() {
    # Now E
    local result=$(curl -s -${1} --max-time 10 -X POST -H "Content-Type: application/json" -d '{"contentId":"202105121370235","contentType":"Vod","pin":"","deviceId":"W-60b8d30a-9294-d251-617b-c12f9d0c","deviceType":"WEB"}' "https://webtvapi.nowe.com/16/1/getVodURL" 2>&1)
	local result=$(PharseJSON "${result}" "responseCode")
    Failed_Network_Connection
	if [[ "$result" == "SUCCESS" ]]; then
		echo "Yes"
		return
    else
		echo "No"
		return
	fi
}

function MediaUnlockTest_ViuTV() {
    # Viu TV
    local result=`curl -s -${1} --max-time 10 -X POST -H "Content-Type: application/json" -d '{"callerReferenceNo":"20210603233037","productId":"202009041154906","contentId":"202009041154906","contentType":"Vod","mode":"prod","PIN":"password","cookie":"3c2c4eafe3b0d644b8","deviceId":"U5f1bf2bd8ff2ee000","deviceType":"ANDROID_WEB","format":"HLS"}' "https://api.viu.now.com/p8/3/getVodURL" 2>&1`
    Failed_Network_Connection
    
    local result=$(PharseJSON "${result}" "responseCode")
	if [[ "$result" == "SUCCESS" ]]; then
		echo "Yes"
		return
    else
		echo "No"
		return
	fi
}

function MediaUnlockTest_AbemaTV_IPTest() {
    # Abema.TV
    local result=`curl -${1} --user-agent "${UA_Dalvik}" -fsL --write-out %{http_code} --max-time 30 "https://api.abema.io/v1/ip/check?device=android" 2>&1`
    if [[ "${result}" == "000" ]]; then
        echo "Failed (Network Connection)"
        return
    fi
    
    local result=`curl -${1} --user-agent "${UA_Dalvik}" -fsL --max-time 30 "https://api.abema.io/v1/ip/check?device=android" 2>&1`
    if [ ! -n "$result" ]; then
        echo "No"
        return
    fi

    local result=$(PharseJSON "${result}" "isoCountryCode")
    if [[ "${result}" == "JP" ]];then
        Echo "Yes"
        return
    fi
    echo "Oversea Only"
}

function MediaUnlockTest_DisneyPlus() {
    # Disney Plus
    local result=`curl -${1} --user-agent "${UA_Browser}" -sSL "https://global.edge.bamgrid.com/token" 2>&1`
    Failed_Network_Connection
    
    local previewcheck=`curl -${1} -sSL -o /dev/null -L --max-time 30 -w '%{url_effective}\n' "https://disneyplus.com" 2>&1`
    if [[ "${previewcheck}" == "curl"* ]];then
        echo "Failed (Network Connection)"
        return
    fi
    
    if [[ "${previewcheck}" == *"preview"* ]];then
        echo "No"
        return
    fi
    
    local result=`curl -${1} --user-agent "${UA_Browser}" -fs --write-out '%{redirect_url}\n' --output /dev/null "https://www.disneyplus.com" 2>&1`
    if [[ "${website}" == "https://disneyplus.disney.co.jp/" ]];then
        echo "Yes(Region: JP)"
        return
    fi
    
    local result=`curl -${1} -sSL --user-agent "$UA_Browser" -H "Content-Type: application/x-www-form-urlencoded" -H "${DisneyHeader}" -d "${DisneyAuth}" -X POST  "https://global.edge.bamgrid.com/token" 2>&1`
    PharseJSON "${result}" "access_token" 2>&1 > /dev/null;
    if [[ "$?" -eq 0 ]]; then
        local region=$(curl -${1} -sSL https://www.disneyplus.com | grep 'region: ' | awk '{print $2}')
        if [ -n "$region" ];then
            echo "Yes(Region: $region)"
            return
        fi
        echo "Yes"
        return
    fi
    echo "No"
}

function MediaUnlockTest_Paravi() {
    # Paravi
    local result=`curl -${1} -sSL --max-time 30 -H "Content-Type: application/json" -d '{"meta_id":71885,"vuid":"3b64a775a4e38d90cc43ea4c7214702b","device_code":1,"app_id":1}' "https://api.paravi.jp/api/v1/playback/auth" 2>&1`
    Failed_Network_Connection
    
    if [[ "$(PharseJSON "${result}" "error.code" | awk '{print $2}' | cut -d ',' -f1)" == "2055" ]]; then
        echo "No"
        return
    fi
    
    local result=$(PharseJSON "${result}" "playback_validity_end_at")
    if [[ "${result}" != "null" ]]; then
        echo "Yes"
        return
    fi
    echo "No"
}

function MediaUnlockTest_UNext() {
    # U Next
    local result=`curl -${1} -sSL --max-time 30 "https://video-api.unext.jp/api/1/player?entity%5B%5D=playlist_url&episode_code=ED00148814&title_code=SID0028118&keyonly_flg=0&play_mode=caption&bitrate_low=1500" 2>&1`
    Failed_Network_Connection
    
    local result=$(PharseJSON "${result}" "data.entities_data.playlist_url.result_status");
    if [[ "${result}" == "475" || "${result}" == "200" ]]; then
        echo "Yes"
        return
    fi
    
    if [[ "${result}" == "467" ]]; then
        echo "No"
        return
    fi
    echo "Failed (Unexpected Result: ${result})"
}

function MediaUnlockTest_Dazn() {
    # Dazn
    local result=`curl -${1} -sSL --max-time 30 -X POST -H "Content-Type: application/json" -d '{"LandingPageKey":"generic","Languages":"zh-CN,zh,en","Platform":"web","PlatformAttributes":{},"Manufacturer":"","PromoCode":"","Version":"2"}' "https://startup.core.indazn.com/misl/v5/Startup" 2>&1`
    Failed_Network_Connection

    local region=`tr [:lower:] [:upper:] <<<$(PharseJSON "${result}" "Region.GeolocatedCountry")`
    if [ ! -n "${result}" ]; then
        echo "Unsupport"
        return
    fi

    if [[ "${region}" == "NULL" ]];then
        echo "No"
        return
    fi
    echo "Yes(Region: ${region})"
}

function MediaUnlockTest_HuluJP() {
    # Hulu Japan
    local result=`curl -${1} -sSL -o /dev/null --max-time 30 -w '%{url_effective}\n' "https://id.hulu.jp" 2>&1`
    Failed_Network_Connection
    
    if [[ "$result" == *"login"* ]];then
        echo "Yes"
        return
    fi
    echo "No"
}

function MediaUnlockTest_Kancolle() {
    # Kancolle Japan
    local result=`curl -${1} --user-agent "${UA_Dalvik}"  -fsL --write-out %{http_code} --output /dev/null --max-time 30 http://203.104.209.7/kcscontents/ 2>&1`
    case ${result} in
        000)
            echo "Failed (Network Connection)"
        ;;
        200)
            echo "Yes"
        ;;
        403)
            echo "No"
        ;;
        *)
            echo "Failed (Unexpected Result: $result)"
        ;;
    esac
}

function MediaUnlockTest_UMAJP() {
    # Pretty Derby Japan
    local result=`curl -${1} --user-agent "${UA_Dalvik}" -fsL --write-out %{http_code} --output /dev/null --max-time 30 https://api-umamusume.cygames.jp/`
    case ${result} in
        000)
            echo "Failed (Network Connection)"
        ;;
        404)
            echo "Yes"
        ;;
        403)
            echo "No"
        ;;
        *)
            echo "Failed (Unexpected Result: $result)"
        ;;
    esac
}

function MediaUnlockTest_PCRJP() {
    # Princess Connect Re:Dive Japan
    local result=`curl -${1} --user-agent "${UA_Dalvik}" -fsL --write-out %{http_code} --output /dev/null --max-time 30 https://api-priconne-redive.cygames.jp/ 2>&1`
    case ${result} in
        000)
            echo "Failed (Network Connection)"
        ;;
        404)
            echo "Yes"
        ;;
        403)
            echo "No"
        ;;
        *)
            echo "Failed (Unexpected Result: $result)"
        ;;
    esac
}

function MediaUnlockTest_BilibiliChinaMainland() {
    # BiliBili China Mainland Only
    local randsession="$(cat /dev/urandom | head -n 32 | md5sum | head -c 32)"
    local result=`curl -${1} --user-agent "${UA_Browser}" -fsSL --max-time 30 "https://api.bilibili.com/pgc/player/web/playurl?avid=82846771&qn=0&type=&otype=json&ep_id=307247&fourk=1&fnver=0&fnval=16&session=${randsession}&module=bangumi" 2>&1`
    Failed_Network_Connection
    
    local result="$(PharseJSON "${result}" "code")";
    if [ "$?" -ne "0" ]; then
        echo "Failed (Parse Json)"
        return
    fi
    
    case ${result} in
        0)
            echo "Yes"
        ;;
        -10403)
            echo "No"
        ;;
        *)
            echo "Failed"
        ;;
    esac
}

function MediaUnlockTest_BilibiliHKMCTW() {
    # BiliBili Hongkong/Macau/Taiwan
    local randsession="$(cat /dev/urandom | head -n 32 | md5sum | head -c 32)"
    local result=`curl -${1} --user-agent "${UA_Browser}" -fsSL --max-time 30 "https://api.bilibili.com/pgc/player/web/playurl?avid=18281381&cid=29892777&qn=0&type=&otype=json&ep_id=183799&fourk=1&fnver=0&fnval=16&session=${randsession}&module=bangumi" 2>&1`
    Failed_Network_Connection
    
    local result="$(PharseJSON "${result}" "code")"
    if [ "$?" -ne "0" ]; then
        echo "Failed (Parse Json)"
        return
    fi
    case ${result} in
        0)
            echo "Yes"
        ;;
        -10403)
            echo "No"
        ;;
        *)
            echo "Failed"
        ;;
    esac
}

function MediaUnlockTest_BilibiliTW() {
    # Bilibili Taiwan Only
    local randsession="$(cat /dev/urandom | head -n 32 | md5sum | head -c 32)"
    local result=`curl -${1} --user-agent "${UA_Browser}" -fsSL --max-time 30 "https://api.bilibili.com/pgc/player/web/playurl?avid=50762638&cid=100279344&qn=0&type=&otype=json&ep_id=268176&fourk=1&fnver=0&fnval=16&session=${randsession}&module=bangumi" 2>&1`
    Failed_Network_Connection
    
    local result="$(PharseJSON "${result}" "code")"
    if [ "$?" -ne "0" ]; then
        echo -n -e "\r Bilibili Taiwan Only:\t\t\t${Font_Red}Failed (Parse Json)${Font_Suffix}\n" && echo -e " Bilibili Taiwan Only:Failed (Parse Json)" >> ${LOG_FILE}
        return
    fi
    
    case ${result} in
        0)
            echo "Yes"
        ;;
        -10403)
            echo "No"
        ;;
        *)
            echo "Failed"
        ;;
    esac
}
function Start_MediaUnlockTest(){
    echo "${NodeID}";
    echo "${CountryCode}";
    GameTest_Steam ${1};
    MediaUnlockTest_Netflix ${1};
    MediaUnlockTest_MyTVSuper ${1};
    MediaUnlockTest_YouTube_Region ${1};
    MediaUnlockTest_HBONow ${1};
    MediaUnlockTest_BBC ${1};
    MediaUnlockTest_NowE ${1};
    MediaUnlockTest_ViuTV ${1};
    MediaUnlockTest_AbemaTV_IPTest ${1};
    MediaUnlockTest_DisneyPlus ${1};
    MediaUnlockTest_Paravi ${1};
    MediaUnlockTest_UNext ${1};
    MediaUnlockTest_Dazn ${1};
    MediaUnlockTest_HuluJP ${1};
    MediaUnlockTest_Kancolle ${1};
    MediaUnlockTest_UMAJP ${1};
    MediaUnlockTest_PCRJP ${1};
    MediaUnlockTest_BilibiliChinaMainland ${1};
    MediaUnlockTest_BilibiliHKMCTW ${1};
    MediaUnlockTest_BilibiliTW ${1};
}

curl -V > /dev/null 2>&1;
if [ $? -ne 0 ];then
    echo "Please install curl"
    exit
fi

jq -V > /dev/null 2>&1;
if [ $? -ne 0 ];then
    InstallJQ;
fi

# 测试流媒体解锁情况
Start_MediaUnlockTest 4;