#!/bin/bash


if [ $# -ne 1 ]
then
    echo "This Program Takes One File As Input And Tranlates It."
    echo "Specify your text file."
    exit 1
fi

if [ -f $1 ]
then
    FILE=$1
    CURRENTDIR=`pwd`
    FILEPATH="$CURRENTDIR/`dirname $1`/"
    FILE=`echo $1 | rev | cut -d'/' -f1 | rev`
    FILENAME=`echo $FILE | cut -d'.' -f1`
    FILEEXTENTION=`echo $FILE | cut -d'.' -f2`

    TRANSLATED_FILE="$FILEPATH$FILENAME-Tanslated.$FILEEXTENTION"
    cp $FILEPATH$FILE $TRANSLATED_FILE

    foreign=(`grep -P "[^\x00-\x7F]+" -o $FILEPATH$FILE  | sort | uniq`)

    for index in ${!foreign[@]}
    do
        translated[$index]+=`python $CURRENTDIR/translate.py ${foreign[$index]}`
    done

    for index in ${!translated[@]}
    do
        replace "${foreign[$index]}" "${translated[$index]}" -- $TRANSLATED_FILE
    #    sed $FILEPATH$FILE -i 's/${foreign[$index]}/${translated[$index]}/g' $TRANSLATED_FILE
    done
elif [ -d $1 ]
then
    DIR=`echo $1 | sed 's/\.\///g' | sed 's/\/$//g'`
    CURRENTDIR=`pwd`
    DIRPATH="$CURRENTDIR/$DIR"
    FOREIGN_WORDS_FILE='Foreign-Words.txt'
    UNIQ_FOREIGN_WORDS_FILE='Uniq-Foreign-Words.txt'
    TRANSLATED_WORDS_FILE='Translated-Words.txt'
    TRANSLATED_DIR="$DIRPATH-Tanslated"
    #cp -r $DIRPATH $TRANSLATED_DIR
    cd $TRANSLATED_DIR
    
    # AVAILABLE_VPNS=(`nmcli -t -f NAME,TYPE c show | grep ":vpn" | cut -d":" -f1 | sort`)
    # VPN_COUNT=`echo "${#AVAILABLE_VPNS[@]}"`

    # Grep Chinese Characters
    # grep -rnwI -P "[\p{Han}]+" -o . > $CURRENTDIR/$FOREIGN_WORDS_FILE
    # Or grep non-English Characters
    # grep -rnwI -P "[^\x00-\x7F]+" -o . > $CURRENTDIR/$FOREIGN_WORDS_FILE

    # Find Uniq foreign sentences and words
    # cat $CURRENTDIR/$FOREIGN_WORDS_FILE | rev | cut -d':' -f1 | rev | sort | uniq > $CURRENTDIR/$UNIQ_FOREIGN_WORDS_FILE
    # UNIQ_FOREIGN=(`cat $CURRENTDIR/$UNIQ_FOREIGN_WORDS_FILE`)
    
    # for i in ${!UNIQ_FOREIGN[@]}
    # do
    #     TRANSLATED_LINE=`python $CURRENTDIR/translate.py ${UNIQ_FOREIGN[$i]}`
    #     if [ "${UNIQ_FOREIGN[$i]}" != "$TRANSLATED_LINE" ]
    #     then
    #         echo $TRANSLATED_LINE >> $CURRENTDIR/$TRANSLATED_WORDS_FILE
    #     else
    #         echo "Refused to Translate."
    #         # Check if there is an Active VPN, And Switch Networks
    #         n=0
    #         ACTIVE_VPN=`nmcli -t -f NAME,TYPE c show --active | grep ":vpn" | cut -d":" -f1`
    #         if [ $(echo $ACTIVE_VPN | wc -c) -gt 1 ]
    #         then
    #             for i in ${AVAILABLE_VPNS[@]}; do
    #                 if [ $i = $ACTIVE_VPN ]
    #                 then
    #                     echo "Disconnecting From VPN in Use."
    #                     nmcli con down $ACTIVE_VPN > /dev/null
    #                     ((n++))
    #                     break
    #                 fi
    #                 ((n++))
    #             done
    #         fi
    #         n=`expr $n % $VPN_COUNT`
    #         echo "Connecting To The next VPN"
    #         nmcli con up ${AVAILABLE_VPNS[$n]} > /dev/null
    #         echo "Waiting For 1 minute."
    #         sleep 1m
    #         TRANSLATED_LINE=`python $CURRENTDIR/translate.py ${UNIQ_FOREIGN[$i]}`

    #         while [ "${UNIQ_FOREIGN[$i]}" = "$TRANSLATED_LINE" ]
    #         do
    #             echo "Does Not Translate From VPN. Waiting for 6 minutes."
    #             sleep 6m
    #             TRANSLATED_LINE=`python $CURRENTDIR/translate.py ${UNIQ_FOREIGN[$i]}`
    #         done
    #         echo $TRANSLATED_LINE >> $CURRENTDIR/$TRANSLATED_WORDS_FILE
    #     fi
    # done
    FILES=(`find . -type f`)
    TRANSLATED=(`cat $CURRENTDIR/$TRANSLATED_WORDS_FILE`)
    UNIQ_FOREIGN=(`cat $CURRENTDIR/$UNIQ_FOREIGN_WORDS_FILE`)

    for index in ${!FILES[@]}
    do
        echo "Translating... [${FILES[$index]}]"
        for i in ${!UNIQ_FOREIGN[@]}
        do
            replace "${UNIQ_FOREIGN[$i]}" "${TRANSLATED[$i]}" -- ${FILES[$index]}
        done
    done
fi