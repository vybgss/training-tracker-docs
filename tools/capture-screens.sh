#!/bin/zsh
# Captures the app screenshots shown on marketing.html: the home screen, an
# exercise and the log sheet, in every app language, in light and dark mode.
#
#   tools/capture-screens.sh setup <simulator-udid> <Training Tracker.app> <training-tracker repo>
#   tools/capture-screens.sh lang <en|de|fr|uk|es|ja|pt>   seeds the demo log, launches the app
#   tools/capture-screens.sh shot <home|detail|log>        saves light and dark captures
#   tools/capture-screens.sh open <workout|log>            opens the squat (tap Open when asked)
#
# Per language: lang, shot home, open workout, shot detail, open log, shot log.
# Build the app for the simulator first (Release), e.g.
#   xcodebuild -project "Training Tracker.xcodeproj" -scheme "Training Tracker" \
#     -configuration Release -destination "id=<udid>" -derivedDataPath /tmp/tt build
# and use a fresh simulator: a language chosen in the app's settings would
# override the launch language. App 3.0 (40) shows counted strings ("1 sessions")
# in English when Japanese comes from the system language, so the Japanese
# captures were taken with 日本語 picked in the app's settings.
set -euo pipefail

DOCS=${0:A:h:h}
STATE=${TMPDIR:-/tmp}/training-tracker-screens
BUNDLE=volodymyr-sichka.training-tracker
typeset -A LOCALES=(en en_US de de_DE fr fr_FR uk uk_UA es es_ES ja ja_JP pt pt_BR)

case $1 in
setup)
  mkdir -p $STATE
  print -r -- $2 > $STATE/udid
  print -r -- $4 > $STATE/repo
  xcrun simctl boot $2 2>/dev/null || true
  xcrun simctl bootstatus $2 -b >/dev/null
  xcrun simctl install $2 $3
  xcrun simctl status_bar $2 override --time 9:41 --dataNetwork wifi --wifiMode active --wifiBars 3 \
    --cellularMode active --cellularBars 4 --batteryState discharging --batteryLevel 100
  python3 $4/Design/AppStore/demo_data.py $STATE/demo.dat >/dev/null
  ;;
lang)
  DEV=$(<$STATE/udid)
  REPO=$(<$STATE/repo)
  print -r -- $2 > $STATE/lang
  DATA=$(xcrun simctl get_app_container $DEV $BUNDLE data)
  mkdir -p $DATA/Documents
  xcrun simctl terminate $DEV $BUNDLE 2>/dev/null || true
  python3 $DOCS/tools/localize_demo.py $STATE/demo.dat "$REPO/Training Tracker/Localizable.xcstrings" $2 \
    > $DATA/Documents/training-tracker.dat
  xcrun simctl ui $DEV appearance light
  xcrun simctl launch $DEV $BUNDLE -AppleLanguages "(${2/pt/pt-BR})" -AppleLocale $LOCALES[$2] >/dev/null
  sleep 4
  ;;
shot)
  DEV=$(<$STATE/udid)
  LANG_CODE=$(<$STATE/lang)
  mkdir -p $DOCS/assets/screens/$LANG_CODE
  for mode in light dark; do
    xcrun simctl ui $DEV appearance $mode
    sleep 1.5
    xcrun simctl io $DEV screenshot --type=png $STATE/shot.png >/dev/null 2>&1
    sips --resampleWidth 590 -s format jpeg -s formatOptions 82 $STATE/shot.png \
      --out $DOCS/assets/screens/$LANG_CODE/$2-$mode.jpg >/dev/null
  done
  xcrun simctl ui $DEV appearance light
  ;;
open)
  DEV=$(<$STATE/udid)
  SQUAT=$(python3 -c 'import json,sys; print(next(w["id"] for w in json.load(open(sys.argv[1]))["workouts"] if w["name"] == "Squat"))' $STATE/demo.dat)
  xcrun simctl openurl $DEV trainingtracker://$2/$SQUAT
  ;;
esac
