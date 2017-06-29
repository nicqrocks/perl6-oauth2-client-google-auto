# OAuth2::Client::Google::Auto

[![Build Status](https://travis-ci.org/nicqrocks/perl6-oauth2-client-google-auto.svg?branch=master)](https://travis-ci.org/nicqrocks/perl6-oauth2-client-google-auto)

Google's authentication takes a while to write, so why not automate it? This module will try to make the setup as easy as possible by wrapping around the [`OAuth2::Client::Google`](https://github.com/bduggan/p6-oauth2-client-google) module and setting it up for you.

## How it Works

The module is primarily designed to be easy to use (that was the whole point of making it). To do so, this module will write a file called `gauth.json` in the current directory. So the simplest way to get it to work, is like this:

    use GAuth:Auto;
    use JSON::Fast;
    my $oauth = OAuth2::Client::Google.new: |from-json("gauth.json".IO.slurp);

This expects that the `client_id.json` file is in the `$*CWD` and that the machine this is running on has a web browser available. For more complex examples, please see the [`examples`](/example) directory.

## Restrictions

There are a few restrictions that need to be addressed about this module:

### `client_id.json`

In order for this or the `OAuth2::Client::Google` module to work, a JSON file of the OAuth2 client ID must exist. Please see [Google's Developer Console](http://console.developers.google.com/) to set up the credentials and get the file.

### No Web Browser

Due to Google being so web based, the authentication page for the user is a link returned by the request. This is a module however, and there is no guarantee that the machine has a web browser. So to get around this, a link to the authentication page will be returned instead.
