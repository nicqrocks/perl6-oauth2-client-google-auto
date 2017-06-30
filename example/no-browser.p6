#!/usr/bin/env perl6

use JSON::Fast;
use lib 'lib';

#This example assumes that the machine this runs on has an available web browser
#to use.

#Saved JSON file of last auth.
my $last = "gauth.json".IO;

#Check if the file exists. Otherwise it will be created.
unless $last.e {
    use GAuth::Auto;
    #Must give a space delimited list of scopes.
    my $t = auto-auth "email",
        #File to use other than "client_id.json".
        with => "client_id.json".IO,
        #Thing to do when given the URL. This replaces trying to open the
        #browser.
        :no-browser( -> $l {
            say "Open this URL: $l";
        } );

    $last.spurt: to-json $t;
}

#Load the saved authentication file into an object;
my $gauth = from-json($last.slurp);

#Use $gauth as normal.
my $token = $gauth<access_token>;
