# Retail bank agent

A bedrock agent that can call lambda functions to fetch information from a dynamodb database

![Architecture](diagrams/retailBankAgent.drawio.svg)

## Setup

Follow the steps of PREREQUISITES.md.

## Create the infrastructure

    terraform init
    terraform apply -auto-approve

## Access the bot

Go to the console and ask questions using the test window

![Test bot](diagrams/testBot.png)