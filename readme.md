# Project Setup (No‑Code Friendly Guide)

This app shows movie data using The Movie Database (TMDB). Follow the steps below to install everything and run the app on your Mac, even if you’ve never coded before.

## What you need

- A Mac running macOS
- Xcode (Apple’s free developer app)
- A free TMDB account and token (instructions below)

---

## 1) Install Xcode

1. Open the App Store on your Mac.
2. Search for “Xcode”.
3. Click Get (or Install). This can take a while due to the large download.
4. When finished, open Xcode once so it can complete setup.

Tip: If prompted to install additional components, click “Install”.

---

## 2) Get a TMDB Account and Token

1. Go to https://www.themoviedb.org/documentation/api
2. Sign in or create a free TMDB account.
3. Apply for an API key (approval can be instant or take a short time).
4. After approval, go to your TMDB API settings and copy:
   - Read Access Token (v4)

You will paste this token into the project in the next step.

Important: Treat this token like a password. Do not share it publicly.

---

## 3) Add Your Token to the Project

1. Open the project in Xcode (double‑click the .xcodeproj or .xcworkspace file).
2. In the Xcode left sidebar (Project Navigator), find:
   - Networking/AccessKeys
3. Open the file inside “AccessKeys” that mentions API keys/tokens.
4. Paste your TMDB Read Access Token (v4) where indicated.


Never commit or upload your real token to public websites.

---

## 4) Select a Simulator (to run the app)

1. At the top of Xcode, near the Run button (a ▶ triangle), click the device menu.
2. Choose an iOS Simulator, for example:
   - iPhone 15 Pro (or any available iPhone)
3. If you prefer to run on your own iPhone:
   - Connect your iPhone with a cable and select it from the same device menu.
   - You may need to trust your Mac on the device and follow on‑screen prompts.

Tip: Using the Simulator is the easiest way to start.

---

## 5) Build and Run the App

1. Click the Run button (▶) in the top toolbar.
2. The Simulator will open automatically and launch the app.
3. On first run, Xcode may ask for permissions or to enable signing—accept defaults if prompted.

If the app shows movie lists without errors, your setup is complete.

---

## 6) Troubleshooting

- If you see an authentication or 401 error:
  - Double‑check that you pasted the TMDB Read Access Token (v4) correctly.
  - Make sure you put it in the correct file under Networking/AccessKeys.
  - Confirm that your TMDB API key request was approved and is active.

- If the build fails:
  - Make sure Xcode finished installing additional components.
  - Try Product > Clean Build Folder in the Xcode menu, then Run again.
  - Quit and reopen Xcode if needed.

- If you don’t see the Simulator:
  - In Xcode, go to Xcode > Settings > Platforms and ensure iOS Simulator is installed.
  - Or choose Xcode > Window > Devices and Simulators to confirm available simulators.

---

## 7) Where to Learn More

- TMDB API Docs: https://www.themoviedb.org/documentation/api
- Apple’s Xcode Help: https://developer.apple.com/support/xcode/

---

## Quick Checklist

- [ ] Xcode installed and opened once
- [ ] TMDB Read Access Token (v4) copied
- [ ] Token pasted into Networking/AccessKeys file
- [ ] iPhone Simulator selected in Xcode
- [ ] App runs without authentication errors

Enjoy exploring movies!
