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
    Connect to different AWS EC2 hosts via a Bastion/Jump host.

    USAGE
      ./heimdall <command> <target> [flags]

    CORE COMMANDS
      list:                       List all available hosts.
      grant:                      Grants access to your IP to the bastion security group.
      revoke:                     Revokes access to your IP to the bastion security group.
      bastion:                    Logs you into the bastion itself.

    TARGETS
      host:                       Logs you into host via the bastion and the current user.
      user@host:                  Logs you into host via the bastion and the specified user.
      service#cluster:            Logs you into a specific service on the specified cluster.

    FLAGS
      --awscli-profile <profile>  Switches your AWSCLI profile to a different one in your .aws/config file.

    EXAMPLES
      $ ./heimdall list
      $ ./heimdall ec2-user@Prod1
      $ ./heimdall backend#production
