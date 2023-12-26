#!/usr/bin/env bash

if ! type java &> /dev/null; then
    echo "Java not detected, install java and try again"
fi

if type mi-fastboot &> /dev/null; then
    runFastboot=mi-fastboot
else
    runFastboot=fastboot
fi


# On system with zenity use graphical mode
if type zenity &> /dev/null; then

    # Show interface progress
    zenity --progress --pulsate --no-cancel --text "Waiting for any device in fastboot mode" &
    ZENITY_PID=$!

    # Detect Product
    product=$(timeout --foreground 60 $runFastboot getvar product 2>&1 | grep 'product:' | cut -d ' ' -f2)

    if [[ -n $product ]]; then
        # Detect Token if have product
        token=$($runFastboot getvar token 2>&1 | grep token:| sed 's|.*token: ||g' | sed ':a;N;$!ba;s/\n//g')

        if [[ -z $token ]]; then
            #Another way to detect Token
            token=$($runFastboot oem get_token 2>&1 | grep token:| sed 's|.*token: ||g' | sed ':a;N;$!ba;s/\n//g')
        fi
    else
        zenity --error --text="Timeout, device not detected."
    fi

    # Close interface progress
    kill "$ZENITY_PID"

    if [[ -n $token ]]; then


        region=$(zenity --height=360 --list --text="
Product: $product

Token: $token
" \
        --title="Detected device" \
        --radiolist \
        --column="Select" --column="Region" \
        TRUE "global" \
        FALSE "india" \
        FALSE "china" \
        FALSE "russia" \
        FALSE "europe")


        # Check if a choice was made
        if [ -n "$region" ]; then
            data=$(zenity --entry \
            --title="Enter DATA" \
            --text="Enter the giant code obtained from the apk used on your Xiaomi device:")

            if [[ -z $data ]]; then
                zenity --error --text="Canceled, see you next time my friend."
                exit
            fi
        else
            zenity --error --text="Canceled, see you next time my friend."
            exit
        fi

        zenity --progress --pulsate --no-cancel --text "Running java part, wait" &
        ZENITY_PID=$!

        javaOutput=$(bash get_token.sh --region=$region --product="$product" --token="$token" "$data" 2>&1 | sed 's/"/\\"/g')

        unlockToken=$(echo "$javaOutput" | grep 'Unlock device token:' | sed 's|.*Unlock device token: ||g')

        kill "$ZENITY_PID"

        if [[ -z $unlockToken ]]; then
            zenity --info \
            --text="$javaOutput" \
            --title="Done!"
            exit
        else
            zenity --progress --pulsate --no-cancel --text "Unlocking, wait" &
            ZENITY_PID=$!

            # Convert using perl to replace xxd
            mkdir -p ~/.cache
            perl -e "print pack 'H*', '$unlockToken'" > ~/.cache/token.bin

            # Unlock
            stageUnlock=$($runFastboot stage ~/.cache/token.bin 2>&1 | sed 's/"/\\"/g')
            oemUnlock=$($runFastboot oem unlock 2>&1 | sed 's/"/\\"/g')
            # oemUnlockAgain=$($runFastboot oem-unlock "$unlockToken" 2>&1 | sed 's/"/\\"/g')

            kill "$ZENITY_PID"

            zenity --info \
            --text="$stageUnlock
$oemUnlock" \
            --title="Done!"
            exit

        fi
    fi

# On system with dialog, like Termux
elif type dialog &> /dev/null; then
    (dialog --infobox "Waiting for any device in fastboot mode" 10 50) &
    DIALOG_PID=$!

    # fix mi-fastboot device detection on termux
    $runFastboot devices &>/dev/null

    product=$(timeout --foreground 60 $runFastboot getvar product 2>&1 | grep 'product:' | cut -d ' ' -f2)

    if [[ -n $product ]]; then
        token=$($runFastboot getvar token 2>&1 | grep token: | sed 's|.*token: ||g' | sed ':a;N;$!ba;s/\n//g')

        if [[ -z $token ]]; then
            token=$($runFastboot oem get_token 2>&1 | grep token: | sed 's|.*token: ||g' | sed ':a;N;$!ba;s/\n//g')
        fi
    else
        dialog --msgbox "Timeout, device not detected." 10 50
        kill "$DIALOG_PID"
        exit 1
    fi

    kill "$DIALOG_PID"

    if [[ -n $token ]]; then
        exec 3>&1
        region=$(dialog --radiolist "Detected device\n\nProduct: $product\n\nToken: $token" 15 50 5 \
        "global" "Global" on \
        "india" "India" off \
        "china" "China" off \
        "russia" "Russia" off \
        "europe" "Europe" off \
        2>&1 1>&3)
        exec 3>&-

        if [ -z "$region" ]; then
            dialog --msgbox "Canceled, see you next time my friend." 10 50
            exit
        fi

        exec 3>&1
        data=$(dialog --inputbox "Enter the giant code obtained from the apk used on your Xiaomi device:" 10 50 2>&1 1>&3)
        exec 3>&-

        if [[ -z $data ]]; then
            dialog --msgbox "Canceled, see you next time my friend." 10 50
            exit
        fi

        (dialog --infobox "Running java part, wait" 10 50) &
        DIALOG_PID=$!

        javaOutput=$(bash get_token.sh --region=$region --product="$product" --token="$token" "$data" 2>&1 | sed 's/"/\\"/g')

        unlockToken=$(echo "$javaOutput" | grep "Unlock device token:" | sed 's|.*Unlock device token: ||g')

        kill "$DIALOG_PID"

        if [[ -z $unlockToken ]]; then
            dialog --msgbox "$javaOutput" 20 60
            exit
        else
            (dialog --infobox "Unlocking, wait" 10 50) &
            DIALOG_PID=$!

            mkdir -p ~/.cache
            perl -e "print pack 'H*', '$unlockToken'" > ~/.cache/token.bin

            stageUnlock=$($runFastboot stage ~/.cache/token.bin 2>&1 | sed 's/"/\\"/g')
            oemUnlock=$($runFastboot oem unlock 2>&1 | sed 's/"/\\"/g')
            # Unlock Again commented
            # oemUnlockAgain=$($runFastboot oem-unlock "$unlockToken" 2>&1 | sed 's/"/\\"/g')

            kill "$DIALOG_PID"

            dialog --msgbox "$stageUnlock\n$oemUnlock" 20 60
            exit
        fi
    fi

# if don't have zenity or dialog
else
    exec bash get_token.sh "$@"
fi
