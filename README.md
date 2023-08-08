# termux-miunlock
A program that can be used to retrieve the bootloader unlock token for Xiaomi devices. (and unlock the bootloader) using Termux

**Note: This tool cannot bypass the 7, 14, 30 day unlock time.**


## Usage
```console
Usage: termux-miunlock [OPTIONS] DATA
A program that can be used to retrieve the bootloader unlock token for Xiaomi
devices. (and unlock the bootloader) using Termux.
*     DATA                Install account.apk from repo, login and copypaste
                            the response.
      --debug             Output messages about what the tool is doing
      --help              Display a help message
*     --product=PRODUCT   Used to verify device product
      --region=REGION     Tool server host regions: india, global, china,
                            russia, europe
                            Default: india
*     --token=TOKEN       Used to verify device token
      --version           Version information
      
```


## Instructions
* Install required apps [termux](https://github.com/termux/termux-app), [termux-api](https://github.com/termux/termux-api) and ```account.apk``` from repo.

* Clone this repo.
```console
git clone https://github.com/RohitVerma882/termux-miunlock.git && cd termux-miunlock
```

* Run ```setup.sh``` to install required packages.
```console
chmod +x setup.sh && ./setup.sh
```

* Get device ```product```
```console
mi-fastboot getvar product
```

* Get device ```token```
```console
mi-fastboot getvar token
```

* Get device ```token``` for mtk device.
```console
mi-fastboot oem get_token
```

* Run ```get_token.sh``` script with required arguments.
```console
chmod +x get_token.sh && ./get_token.sh --product=PRODUCT --token=TOKEN DATA
```
if the code succeeds it will give you a really long string which is the unlock token.

* Type:
```console
mi-fastboot oem-unlock "UNLOCK_TOKEN"
```

The device will factory reset and unlock successfully.
