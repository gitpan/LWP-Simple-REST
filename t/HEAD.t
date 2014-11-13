#!/usr/bin/perl

use strict;
use warnings;

use LWP::Simple::REST qw/http_head/;
use Test::More;
use Test::Exception;

my $answer = "text/html; charset=ISO-8859-1";

{
    package HTTPTest;
    use base qw/HTTP::Server::Simple::CGI/;

    sub handle_request{
        my $self = shift;
        my $cgi  = shift;

        print "HTTP/1.0 200 OK\r\n";
        print $cgi->header, $answer;
    }
}

my $server = HTTPTest->new(3024)->background();

my $string;
lives_ok {
    $string = http_head( "http://localhost:3024", { argument1 => "one" } );
} 'Request sent';

ok( $answer eq $string->{ 'content-type' }, "Can access header from unblessed headers." );

done_testing();

my $cnt = kill 9, $server;

