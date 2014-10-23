#!/usr/bin/perl

use strict;
use warnings;

use LWP::Simple::REST qw/http_post/;
use Test::More;
use Test::Exception;

my $answer = "argument1=one";

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
    $string = http_post( "http://localhost:3024", { argument1 => "one" } );
} 'Request sent';

ok( $answer eq $string, "Answer should be a string" );

done_testing();

my $cnt = kill 9, $server;

