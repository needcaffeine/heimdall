# Readme

This is a script that allows you to programmatically connect to different AWS EC2 hosts via a Bastion/Jump host.

## Pre-requisites
You will need two external packages to get this thing to work.  
- [aws cli](https://github.com/aws/aws-cli)
- [jq](https://stedolan.github.io/jq/)

Installation instructions for these are on their respective pages, but on a Mac, you can install these simply as `brew install awscli jq` (assuming you have Homebrew).  

When you're done with that, follow the instructions to [configure the aws cli](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html). **Important: Enter `json` for your output format.**

## Configuration
You will need to copy the `heimdall.sample.conf` file to `heimdall.conf`, then add options specific to your organization.

## Usage

    $ ./heimdall
    usage:
    heimdall                     -   Usage information  
    heimdall list                -   List all available hosts  
    heimdall grant|revoke        -   Grants/Revokes your IP access to the bastion security group.  
    heimdall bastion             -   Logs you into the bastion itself.
    heimdall <host>              -   Logs you into host via the bastion and the default user.  
    heimdall <user>@<host>       -   Logs you into host via the bastion and the specified user.
    heimdall <service>#<cluster> -   Logs you into a specific service on the specified cluster. Uses bash by default. Supply your own command if you wish as another parameter.
