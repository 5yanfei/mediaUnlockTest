function curl1(){
        curl -${1} --interface ${2} cip.cc
}

function curl2(){
        curl -${1} --interface ${2} cip.cc
}

function curlTest(){
        curl1 ${1} ${2};
        curl2 ${1} ${2};
}

curlTest ${1} ${2}
