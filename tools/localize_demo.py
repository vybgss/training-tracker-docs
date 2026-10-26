"""Writes the demo training log with exercise names in one app language.

usage: python3 tools/localize_demo.py <demo.dat> <Localizable.xcstrings> <lang>

The demo log from the app repo's Design/AppStore/demo_data.py names its
exercises with suggested-exercise catalog keys ("Squat", "Bench Press"). Someone
who picks those suggestions in another language gets the translated names, so
the screenshots for that language use them too.
"""
import json
import sys

data_path, catalog_path, lang = sys.argv[1:4]
data = json.load(open(data_path))
strings = json.load(open(catalog_path))["strings"]

if lang != "en":
    for workout in data["workouts"]:
        unit = strings.get(workout["name"], {}).get("localizations", {}).get(lang, {}).get("stringUnit")
        if unit:
            workout["name"] = unit["value"]

json.dump(data, sys.stdout)
