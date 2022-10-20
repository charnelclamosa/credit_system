# Karota Credits Plugin

**Plugin Summary**

This plugin will add API end points to the Karota platform that can be used to get the mean of the user's credit balance.
The plugin can also be used to add credits to the credit wallets of all users, and give credit rewards based on the user's activity.

## Available End Points

- `GET /credits` - Returns the mean of the credit balance of all users.
- `PUT /credits` - Adds a specific amount to the credit wallets of all users.
  - Parameters:
    - amount: Credit amount that will be added to the credit wallets. Required.
- `PUT /credits/rewards` - Rewards the users by adding credits to the credit wallets of all users based on their activity on the platform.
  - Parameters:
    - amount: Amount that will be used in the formula for getting the activity reward. Required.
    - date: Date that will be used for looking up the user's activity.. Optional, uses `Today - 1` by default.
