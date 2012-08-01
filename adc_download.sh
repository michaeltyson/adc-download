#!/bin/sh
# ADC downloader tool
#
# Usage:
#   adc_download.sh [download URL]
#
# Michael Tyson, A Tasty Pixel <michael@atastypixel.com>
#
# Multi-team support via Christopher Bowns (@cbowns, http://cbowns.com/)


# Fill in the following with team ID when you view source on <http://developer.apple.com/devcenter/selectTeam.action>.
# Team names are on the lines below 'select name="memberDisplayId" id="teams"'
# Use formfind at <https://raw.github.com/bagder/curl/master/perl/contrib/formfind> to reveal the form contents if you need help.
myaccountID=""
teamloginURL="http://developer.apple.com/devcenter/saveTeamSelection.action"

if [ ! "$1" ]; then
  echo "Usage:"
  echo " $0 [ADC Download URL]"
  exit 1
fi;

downloadURL=`echo "$1" | sed -E 's@http://adcdownload.apple.com|https://developer.apple.com/(iphone|ios)/download.action\?path=@https://developer.apple.com/devcenter/download.action?path=@'`

if grep -q myacinfo /tmp/adccookies.txt 2>/dev/null; then
  echo "Starting download..."
  status=`curl -L -O -C - -b /tmp/adccookies.txt "$downloadURL" --write-out '%{http_code}'`
  rc=$?
  if [ $rc = "33" ]; then
      rm /tmp/adccookies.txt
      echo "Session expired."
  elif [ $rc != "0" ]; then
    if [ "$status" != "403" ]; then
      echo "Unexpected error $status (return code $rc)"
      exit 1
    fi
    
    echo "Not logged in"
  else
    echo "Complete"
    exit 0
  fi
fi

echo "Preparing to login to ADC..."

authinfo=`security find-internet-password -s daw.apple.com -g 2>&1`
[[ $authinfo =~ \"acct\"\<blob\>=\"([^\"]+)\" ]] && acct="${BASH_REMATCH[1]}"
[[ $authinfo =~ password:\ \"([^\"]+)\" ]] &&       pass="${BASH_REMATCH[1]}"
if [ ! "$acct" -o ! "$pass" ]; then
  read -p "ADC Username: " acct
  read -s -p "Password: " pass
  echo ''
  if [ ! "$acct" -o ! "$pass" ]; then
    exit 1;
  fi
  newlogin=1
fi

echo 'Logging in...'

loginpage=`curl -s -L "$downloadURL"`
[[ $loginpage =~ form[^\>]+action=\"([^\"]+)\" ]] && loginurl="https://daw.apple.com/${BASH_REMATCH[1]}"
[[ $loginpage =~ name=\"wosid\"\ value=\"([^\"]+)\" ]] && wosid="${BASH_REMATCH[1]}"

if [ ! "$loginurl" ]; then
  echo "Unexpected response"
  exit 1
fi;

curl -s -c /tmp/adccookies.txt -L -F theAccountName="$acct" -F theAccountPW="$pass" -F 1.Continue=1 -F theAuxValue= -F wosid="$wosid" "$loginurl" -o /dev/null
if ! grep -q myacinfo /tmp/adccookies.txt 2>/dev/null; then
  echo "Login failed"
  exit 1
fi

if [ "$newlogin" ]; then
  security add-internet-password -U -a "$acct" -s daw.apple.com -w "$pass" -T "$0"
fi

if [ "$myaccountID" ]; then
  # submit $myaccountID as teams to the saveTeamSelection url
  # for some reason, adding -i here makes it all work.
  curl -i -s -b /tmp/adccookies.txt -c /tmp/adccookies.txt -F memberDisplayId="$myaccountID" -F "action:saveTeamSelection!save"="Continue" $teamloginURL -o /dev/null
fi

echo "Starting download..."
status=`curl -L -O -C - -b /tmp/adccookies.txt "$downloadURL" --write-out '%{http_code}'`
if [ $? != "0" ]; then
  if [ "$status" != "403" ]; then
    echo "Unexpected error $status"
    exit 1
  fi
  
  echo "Login failed"
  exit 1
else
  echo "Complete"
fi