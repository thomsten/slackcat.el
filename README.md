# slackcat.el

## Summary

With `slackcat.el` you can easily compose and post messages to slack.
`slackcat.el` is dependent on the wonderful
[slackcat command line interface](https://github.com/rlister/slackcat).

## Installing

You will need Emacs 24+, `make` and [Cask](https://github.com/cask/cask) to
build the project.

    cd slackcat
    make && make install

You need to get a Slack API token from https://api.slack.com/ and export it as
an environmental variable

```.el
(setenv "SLACK_TOKEN" "<your api token>")
```

## Usage

Simply `(require 'slackcat)` and do `M-x slackcat` and enter `@<user-name>` or
`#<channel-name>` to select the user or channel to send the message to. A buffer
for composing the message will pop up. When done, hit `C-c C-c` to send the
message or `C-c C-k` to abort.

You may customize the `slackcat-user-list` and the `slackcat-channel-list` to
add all your default users and channels to the menu selection. For other
customizable variables, see `M-x customize-group <enter> slackcat`.


## Contributing

Yes, please do! See [CONTRIBUTING][] for guidelines.

## Other

This project was created with the
[skeletor.el](https://github.com/chrisbarrett/skeletor.el) package. You should
try it too!

## License

See [COPYING][]. Copyright (c) 2018 Thomas Stenersen.

[CONTRIBUTING]: ./CONTRIBUTING.md
[COPYING]: ./COPYING
