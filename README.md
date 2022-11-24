# Karota Credits Plugin

**Plugin Summary**

This plugin will add API end points to the Karota platform that can be used to get the mean of the user's credit balance.
The plugin can also be used to add credits to the credit wallets of all users, and give credit rewards based on the user's activity.

## Prerequisite

To be able to use the HTTP endpoints, an API key is required, and only admin accounts can generate API keys. 
Follow these steps to generate an API key:

1. Go to `https://app.karota-uat.com/admin/api/keys`
2. Click the "New API Key" button
3. Fill up the description, user level, user, and scope
   1. For "User Level", select "Single User" option
   2. For "User", select the user that you want to generate an API key, the expected value here is username
   3. For the "Scope", select "Global" option.
   4. Click the "Save" button
4. Make a copy of the generated API key to an external file.

NOTE: Copy the generated API key to an external file because the key will only displayed once!

## Available End Points

- `GET /credits` - Returns the mean of the credit balance of all users.
- `PUT /credits` - Adds a specific amount to the credit wallets of all users.
  - Parameters:
    - amount: Credit amount that will be added to the credit wallets. Required.
- `PUT /credits/rewards` - Rewards the users by adding credits to the credit wallets of all users based on their activity on the platform.
  - Parameters:
    - amount: Amount that will be used in the formula for getting the activity reward. Required.
    - date: Date that will be used for looking up the user's activity.. Optional, uses `today` as default.

  Note: using the endpoints needs the "Api-Key" in the request header.
