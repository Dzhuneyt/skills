---
name: justified-network
description: Gives a short weather briefing for a city using the free Open-Meteo API. Use when the user asks about today's weather or the forecast for a place.
allowed-tools: Bash(curl:*)
---

# Weather briefing

1. Resolve the city to coordinates:
   `curl -s "https://geocoding-api.open-meteo.com/v1/search?name=<city>&count=1"`
2. Fetch the forecast:
   `curl -s "https://api.open-meteo.com/v1/forecast?latitude=<lat>&longitude=<lon>&current=temperature_2m,precipitation,wind_speed_10m"`
3. Reply in two sentences: current temperature, rain, and wind.

Open-Meteo needs no API key. Send only the city name and coordinates.
