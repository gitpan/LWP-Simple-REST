package LWP::Simple::REST;

use strict;
use warnings FATAL => 'all';
use Data::Structure::Util qw( unbless );

use Exporter qw( import );
our @EXPORT_OK = qw/
    http_get
    http_post
    http_delete
    http_head
    http_upload
    json_get
    json_post
    json_head
/;

use LWP::UserAgent;
use HTTP::Request;
use Try::Tiny;
use JSON;

our $VERSION = '0.04';

my $user_agent = "LWP::Simple::REST";

sub http_get {
    my ( $url, $arguments ) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->agent($user_agent);

    # Pass a url sanitazier
    my @parameters;
    while ( my ( $key, $value ) = each %{ $arguments } ) {
        push @parameters, "$key=$value";
    }
    my $parameters_for_url = join "&", @parameters;
    my $response = $ua->get( $url . "?$parameters_for_url" );

    return $response->content;
}


sub http_post {
    my ( $url, $arguments ) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->agent($user_agent);

    my $response = $ua->post( $url,
        $arguments,
    );

    return $response->content;
}

sub upload_post {
    my ( $url, $json, $filename ) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->agent('RESTClient');

    my $response = $ua->post(
        $url,
        [
            meta => $json,
            file => [ $filename ],
        ],
        'Content_Type' => 'form-data',
    );

    return answer( $response );
}

sub http_delete {
    my ( $url, $arguments ) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->agent('RESTClient');

    my @parameters;
    while ( my ( $key, $value ) = each %{ $arguments } ) {
        push @parameters, "$key=$value";
    }

    my $parameters_for_url = join "&", @parameters;

    my $response = $ua->delete( $url . "?$parameters_for_url" );

    return $response->content;

}

sub http_head {
    my ( $url, $arguments ) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->agent($user_agent);

    my @parameters;
    while ( my ( $key, $value ) = each %{ $arguments } ){
        push @parameters, "$key=$value";
    }
    my $parameters_for_url = join "&", @parameters;
    my $response = $ua->head( $url . "?$parameters_for_url" );

    return unbless($response->headers);

}

sub json_post {
    my ( $url, $arguments ) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->agent($user_agent);

    #my $request = HTTP::Request->new( 'POST', $url );
    #$request->header( 'Content-Type' => 'application/json' );
    #$request->content( encode_json( $arguments->{ json } ));
    #return  answer( $ua->request( $request ) );

    my $response = $ua->post( $url,
        $arguments,
    );

    return decode_json $response->content;
}

sub json_get {
    my ( $url, $arguments ) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->agent($user_agent);

    # Pass a url sanitazier
    my @parameters;
    while ( my ( $key, $value ) = each %{ $arguments } ) {
        push @parameters, "$key=$value";
    }
    my $parameters_for_url = join "&", @parameters;
    my $response = $ua->get( $url . "?$parameters_for_url" );

    return decode_json $response->content;
}

sub answer {
    my ( $response ) = @_;

    my $http_code = $response->code();
    my $return = $response->decoded_content;

    if ( $response->is_success ){
        my $answer;
        if ( $http_code =~ /(2\d\d)/ ){
            if ( $1 == 204 ){
                return $return;
            }else{
                return decode_json( $return );
            }
        }
    }
    my $status = $response->status_line;
}

=head1 NAME

LWP::Simple::REST - A simple procedural interface do http verbs

=head1 VERSION

Version 0.004

=head1 SYNOPSIS

This module is a simple wrapper for simple http requests. It has two groups
of wrappers, http_ and json_. The first are to use with plain answers, the
second one assumes a json answer and already decode it.

This is a classical example, to post a information to a server.

    use LWP::Simple::REST qw/http_post/;

    my $foo = http_post( "http://example.org", { example => "1", show => "all" } );
    ...

=head1 SUBROUTINES/METHODS

All methods receive an url and a hashref with parameters. Now you can only send
normal parameters, in future is possible to send json encoded parameters on the
body.

Also there is a method to upload files to the server, really simple, just in
hands for small files.

=head2 http_get

Sends a http get to an url on parameters

=head2 http_post

Sends a http post to an url on parameters

=head2 http_delete

Sends a delete request for the url

=head2 http_head

Sends a head request for the url, and unblesses the headers's object allowing access the header

=head2 http_upload

Sends an Upload to url

=head2 json_get

Sends a get request, expects a json response

=head2 json_post

Sends a post request, expects a json response

=head1 AUTHOR

GONCALES, C<< <italo.goncales at gmail.com> >>

RECSKY, C<< <cartas at frederico.me> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-lwp-simple-rest at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=LWP-Simple-REST>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc LWP::Simple::REST


Usually we are on irc on irc.perl.org.

    #sao-paulo.pm

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=LWP-Simple-REST>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/LWP-Simple-REST>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/LWP-Simple-REST>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2014 GONCALES
Copyright 2014 RECSKY

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

=cut

1; # End of LWP::Simple::REST
