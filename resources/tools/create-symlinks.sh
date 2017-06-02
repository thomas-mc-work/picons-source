#!/bin/bash

location=$1
temp=$2
style=$3

echo "#!/bin/sh" > $temp/create-symlinks.sh
chmod 755 $temp/create-symlinks.sh

trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

#####################################################
## Create symlinks for SNP & SRP using servicelist ##
#####################################################
if [[ $style = "snp" ]] || [[ $style = "srp" ]] || [[ $style = "chn" ]]; then
    cat $location/build-output/servicelist-*$style | tr -d [:blank:] | tr -d [=*=] | while read line ; do
        IFS="|"
        line_data=($line)
        
        serviceref=$(trim ${line_data[0]})
        # get the transliterated channel name in ASCII (safe characters, no spaces etc.)
        trimmed_channelname=$(trim ${line_data[1]})
        channelname=$(echo "${trimmed_channelname}" | sed "s/[?:@/%\\&\"'=*~;^()<>{}| ]/_/g")
        link_srp=$(trim ${line_data[2]})
        link_snp=$(trim ${line_data[3]})

        IFS="="
        link_srp=($link_srp)
        logo_srp=${link_srp[1]}
        link_snp=($link_snp)
        logo_snp=${link_snp[1]}
        snpname=${link_snp[0]}

        if [[ ! $logo_srp = "--------" ]]; then
            echo "ln -s -f logos/$logo_srp.png $temp/package/picon/$serviceref.png" >> $temp/create-symlinks.sh
        fi

        if [[ $style = "snp" ]] && [[ ! $logo_snp = "--------" ]]; then
            echo "ln -s -f logos/$logo_snp.png $temp/package/picon/$snpname.png" >> $temp/create-symlinks.sh
        fi
        
        if [[ $style = "chn" ]] && [[ ! $logo_snp = "--------" ]]; then
            echo "ln -s -f \"logos/$logo_snp.png\" \"$temp/package/picon/$channelname.png\"" >> $temp/create-symlinks.sh
        fi
    done
fi

##########################################
## Create symlinks using only snp-index ##
##########################################
if [[ $style = "snp-full" ]]; then
    sed '1!G;h;$!d' $location/build-source/snp-index | while read line ; do
        IFS="="
        link_snp=($line)
        logo_snp=${link_snp[1]}
        snpname=${link_snp[0]}

        if [[ $snpname == *"_"* ]]; then
            echo "ln -s -f logos/$logo_snp.png $temp/package/picon/1_0_1_"$snpname"_0_0_0.png" >> $temp/create-symlinks.sh
        else
            echo "ln -s -f logos/$logo_snp.png $temp/package/picon/$snpname.png" >> $temp/create-symlinks.sh
        fi
    done
fi

##########################################
## Create symlinks using only srp-index ##
##########################################
if [[ $style = "srp-full" ]]; then
    sed '1!G;h;$!d' $location/build-source/srp-index | while read line ; do
        IFS="="
        link_srp=($line)
        logo_srp=${link_srp[1]}
        unique_id=${link_srp[0]}

        echo "ln -s -f logos/$logo_srp.png $temp/package/picon/1_0_1_"$unique_id"_0_0_0.png" >> $temp/create-symlinks.sh
    done
fi
