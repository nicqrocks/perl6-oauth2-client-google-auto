#!/usr/bin/env perl6

use OAuth2::Client::Google;
use JSON::Fast;
use HTTP::UserAgent;

sub auto-auth(
    Str $scope,
    IO::Path :$with = 'client_id.json'.IO,
    Callable :$no-browser;
) is export {
    #Get the browser.
    my $browser = %*ENV<BROWSER>    ||
    qx{which xdg-open}          ||
    qx{which x-www-browser}     ||
    qx{which open};
    $browser .= chomp;

    #Get the config from the JSON file.
    my $config = from-json $with.slurp;

    #Get the URI, port, and path.
    my $uri = $config<web><redirect_uris>.first({/localhost/}) ||
        die "A localhost is not listed as a redirection URI, please add one.";
    $uri ~~ /'http://localhost' (':' $<port>=(<[0..9]>+)? $<path>=('/'\N+)?)? $/ ||
        die "Can't parse $uri";
    my $port = $<port> // 80;
    my $path = $<path> // '/';

    #Make OAuth2 object.
    my $oauth = OAuth2::Client::Google.new: :$config, :$scope,
        redirect-uri => $uri;

    #Open the browser or run the code that was passed.
    if $no-browser.defined { $no-browser($oauth.auth-uri); }
    else { run $browser, $oauth.auth-uri; }

    #Listen to the socket.
    my $res = q:to/END/.encode("UTF-8");
    HTTP/1.1 200 OK
    Content-Length: 6
    Connection: close
    Content-Type:text/plain

    Got it
    END

    my $in;
    my $done;
    my $sock = IO::Socket::Async.listen('localhost', $port);
    $sock.tap( -> $connection {
        $connection.Supply.tap( -> $str {
            $in ~= $str;
            if $str ~~ /\r\n\r\n/ {
                $connection.write($res);
                $connection.close;
                $done = True;
            }
          });
    });
    loop { last if $done; };

    say "Alive1";
    #Get the code that was returned.
    $in ~~ / 'GET' .* 'code=' $<code>=(<-[&]>+) /;
    my $code = $<code> or die "No code given";

    say "Alive2";
    #Get the identity and return the access token hash.
    my $token = $oauth.code-to-token(:$code);
    my $id = $oauth.verify-id: id-token => $token<id_token>;

    say "Alive3";
    return $token;
}
