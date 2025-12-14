# Project Setup

This project uses The Movie Database (TMDB) API for fetching movie data. To run the app, you need to create a TMDB account and add your API credentials to the project.

## Steps to obtain your TMDB API credentials

1. Visit https://www.themoviedb.org/documentation/api
2. Sign in or create a TMDB account.
3. Apply for an API key (you’ll get both a Read Access Token and an API Key).
4. Once approved, go to your API settings and copy:
   - Read Access Token (v4)

## Add your credentials to the project

- add Read Access Token to Networking/AccessKeys

Note: Never commit real API keys/tokens to version control. 

## Verifying your setup

- Build and run the app.
- Ensure requests to TMDB endpoints succeed (e.g., popular movies list loads without authentication errors).
- If you see authentication or 401 errors, double-check that:
  - You pasted the correct values.
  - The token is placed in the exact expected keys.
  - Your account has an active, approved API key.

For any issues, revisit the TMDB documentation: https://www.themoviedb.org/documentation/api
