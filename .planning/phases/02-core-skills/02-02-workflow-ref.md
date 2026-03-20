# 02-02 Workflow Reference

## n8n Workflow: 02-02-slack-agent-router

- **Workflow ID:** qvBiylFyeaVJCJm9
- **Status:** Active
- **Webhook URL:** https://n8n.jellespek.nl/webhook/02-02-slack-agent-router-hook
- **n8n URL:** https://n8n.jellespek.nl/workflow/qvBiylFyeaVJCJm9

## Channel → Skill Mapping

| Channel ID    | Channel Name     | Skill     |
|---------------|------------------|-----------|
| C0AMEJ5TU4S   | #agent-ceo       | ceo       |
| C0AMEJT27MY   | #agent-marketing | marketing |
| C0ALZ5QKN31   | #agent-ops       | ops       |
| C0AN8SR8XEU   | #agent-personal  | personal  |
| C0AMJ6SGLG4   | #agent-sales     | sales     |

## Credentials

- **Slack:** AgenticCompany (Slack OAuth2)
- **SSH:** SSH Claude Code (ID: OdKR4WxKZwBUMzZ5)
- **Claude CLI path:** /usr/bin/claude
- **Whitelist user:** U07HYADHB (Jelle)

## Slack App Configuration

After workflow activation, configure Slack App Event Subscriptions:
- URL: https://n8n.jellespek.nl/webhook/02-02-slack-agent-router-hook
- Events: message.channels, message.groups

## Workflow Architecture

```
Slack Trigger
  → IF: Whitelist Jelle (user === U07HYADHB)
    → TRUE: IF: Skip bot messages (bot_id is empty)
      → TRUE: Code: Channel routing (channelId → skill)
        → IF: Known skill (skip === false)
          → TRUE: Slack: Get thread context (conversations.replies)
            → Code: Build SSH command
              → SSH: Run Claude (/usr/bin/claude --no-permissions-prompt -p ...)
                → Code: Format response (truncate to 3900 chars)
                  → Slack: Reply in thread (thread_ts)
```
