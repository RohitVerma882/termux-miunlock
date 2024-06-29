#!/usr/bin/env bash

PRG="$0"
while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done
PRGDIR=`dirname "$PRG"`

cygwin=false;
darwin=false;
case "`uname`" in
  CYGWIN*) cygwin=true
    ;;
  Darwin*) darwin=true
    if [ -z "$JAVA_VERSION" ] ; then
      JAVA_VERSION="CurrentJDK"
    else
      echo "Using Java version: $JAVA_VERSION"
    fi
    if [ -z "$JAVA_HOME" ]; then
      if [ -x "/usr/libexec/java_home" ]; then
        JAVA_HOME=`/usr/libexec/java_home`
      else
        JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Versions/${JAVA_VERSION}/Home
      fi
    fi
    ;;
esac

if [ -z "$JAVA_HOME" ] ; then
  if [ -r /etc/gentoo-release ] ; then
    JAVA_HOME=`java-config --jre-home`
  fi
fi

if $cygwin ; then
  [ -n "$JAVA_HOME" ] && JAVA_HOME=`cygpath --unix "$JAVA_HOME"`
fi

if [ -z "$JAVACMD" ] ; then
  if [ -n "$JAVA_HOME"  ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
      JAVACMD="$JAVA_HOME/jre/sh/java"
    else
      JAVACMD="$JAVA_HOME/bin/java"
    fi
  else
    JAVACMD=`which java`
  fi
fi

if [ ! -x "$JAVACMD" ] ; then
  echo "Error: JAVA_HOME is not defined correctly. We cannot execute $JAVACMD" 1>&2
  exit 1
fi

if $cygwin ; then
  [ -n "$JAVA_HOME" ] && JAVA_HOME=`cygpath --path --windows "$JAVA_HOME"`
fi

# Prompting the user for input
echo "Please enter the region (e.g., india, global, china, russia, europe):"
read -p "Region: " REGION

echo "You can get the device product by running 'fastboot getvar product'."
read -p "Please enter the device product: " DEVICE_PRODUCT

echo "You can get the fastboot token by running 'fastboot getvar token' or 'fastboot oem get_token'."
read -p "Fastboot token: " FASTBOOT_TOKEN

echo "You can get the MIUnlockAccount ID information from the MIUnlockAccount app."
read -p "MIUnlockAccount ID: " MI_UNLOCK_ACCOUNT

# Executing the Java command with user inputs
OUTPUT=$( "$JAVACMD" -jar "$PRGDIR/get_token.jar" --region="$REGION" --product="$DEVICE_PRODUCT" --token="$FASTBOOT_TOKEN" "$MI_UNLOCK_ACCOUNT" )

# Print the output
echo "$OUTPUT"

# Extract the Unlock device token from the output
UNLOCK_TOKEN=$(echo "$OUTPUT" | grep -oP 'Unlock device token: \K[0-9A-F]+')

# Save the token to a binary file
if [ -n "$UNLOCK_TOKEN" ]; then
  TOKEN_FILE="$PRGDIR/token.bin"
  echo "$UNLOCK_TOKEN" | xxd -r -p > "$TOKEN_FILE"
  echo "Unlock device token saved to $TOKEN_FILE"
  echo "Now you can unlock your Xiaomi device by running:"
  echo "fastboot stage $TOKEN_FILE && fastboot oem unlock"
else
  echo "Failed to find the Unlock device token in the output"
fi
