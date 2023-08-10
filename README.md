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
1) Install required apps [termux](https://github.com/termux/termux-app), [termux-api](https://github.com/termux/termux-api) and ```account.apk``` from repo.

2) Clone this repo.
```console
git clone https://github.com/RohitVerma882/termux-miunlock.git && cd termux-miunlock
```

3) Run ```setup.sh``` to install required packages.
```console
chmod +x setup.sh && ./setup.sh
```

4) Get device ```product```
```console
mi-fastboot getvar product
```

5) Get device ```token```
```console
mi-fastboot getvar token
```

6) Get device ```token``` for mtk device.
```console
mi-fastboot oem get_token
```

7) Run ```get_token.sh``` script with required arguments.
```console
chmod +x get_token.sh && ./get_token.sh --product=PRODUCT --token=TOKEN DATA
```
if the code succeeds it will give you a really long string which is the unlock token.

8) Convert unlock token string to binary token.
  ```console
  echo "UNLOCK_TOKEN" | xxd -r -p > token.bin
  ```

9) Type:
```console
fastboot stage token.bin && fastboot oem unlock
```
Or (skip step 8):
```console
mi-fastboot oem-unlock "UNLOCK_TOKEN"
```

The device will factory reset and unlock successfully.
