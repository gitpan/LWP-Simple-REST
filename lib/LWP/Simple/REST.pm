package LWP::Simple::REST;

use strict;
use warnings FATAL => 'all';

use Exporter qw( import );
our @EXPORT_OK = qw/http_get http_post http_delete url/;

use LWP::UserAgent;
use HTTP::Request;
use Try::Tiny;
use JSON;

=head1 NAME

LWP::Simple::REST - A simple procedural interface do http verbs

=head1 SYNOPSIS

This module is a simple wrapper for simple http requests.

This is a classical example, to post a information to a server.

    use LWP::Simple::REST qw/http_post/;

    my $foo = http_post( "http://example.org", { example => "1", show => "all" } );
    ...

=head1 SUBROUTINES/METHODS

=head2 http_get

Sends a http get to an url on parameters

=cut

sub http_get {
    my ( $url, %arguments ) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->agent('RESTClient');

    # Pass a url sanitazier
    my @parameters;
    while ( my ( $key, $value ) = each %arguments ) {
        push @parameters, "$key=$value";
    }
    my $parameters_for_url = join "&", @parameters;
    
    my $response = $ua->get( $url . "?$parameters_for_url" );
    
    return $response;
}

=head2 http_post

Sends a http post to an url on parameters

=cut

sub http_post {
    my ( $url, %arguments ) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->agent('RESTClient');

    #wrong to do fix interface
    if ( exists $arguments{ json } ){
        my $request = HTTP::Request->new( 'POST', $url );
        $request->header( 'Content-Type' => 'application/json' );
        $request->content( encode_json( $arguments{ json } ));

        return  answer( $ua->request( $request ) );
    }else{

        my $response = $ua->post( $url,
            \%arguments,
        );

        return $response;
    }
}

=head2 http_delete

Sends a delete request for the url

=cut

sub http_delete {
    my ( $url, %arguments ) = @_;
    
    my $ua = LWP::UserAgent->new;
    $ua->agent('RESTClient');

    my @parameters;
    while ( my ( $key, $value ) = each %arguments ) {
        push @parameters, "$key=$value";
    }

    my $parameters_for_url = join "&", @parameters;

    my $response = $ua->delete( $url . "?$parameters_for_url" );

    return $response;

}

=head2 http_upload

Sends an Upload to url

=cut

# this interface is just plain terrible
sub http_upload {
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


=head2 answer

If you expects a JSON encoded response, this decode the response

=cut

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


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=LWP-Simple-REST>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/LWP-Simple-REST>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/LWP-Simple-REST>

=item * Search CPAN

L<http://search.cpan.org/dist/LWP-Simple-REST/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2014 GONCALES
Copyright 2014 RECSKY

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of LWP::Simple::REST
