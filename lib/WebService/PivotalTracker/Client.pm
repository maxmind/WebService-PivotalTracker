package WebService::PivotalTracker::Client;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '0.08';

use Cpanel::JSON::XS qw( encode_json );
use HTTP::Request;
use LWP::UserAgent;
use URI;
use WebService::PivotalTracker::Types qw( LWPObject MD5Hex Uri );

use Moo;

has token => (
    is       => 'ro',
    isa      => MD5Hex,
    required => 1,
);

has base_uri => (
    is       => 'ro',
    isa      => Uri,
    required => 1,
);

has _ua => (
    is       => 'ro',
    isa      => LWPObject,
    init_arg => 'ua',
    lazy     => 1,
    default  => sub { LWP::UserAgent->new },
);

sub build_uri {
    my $self  = shift;
    my $path  = shift;
    my $query = shift;

    my $uri = URI->new( $self->base_uri . $path );
    $uri->query_form( %{$query} ) if $query;

    return $uri;
}

sub get {
    my $self = shift;
    return $self->_process_request( 'GET', @_ );
}

sub put {
    my $self = shift;
    return $self->_process_request( 'PUT', @_ );
}

sub post {
    my $self = shift;
    return $self->_process_request( 'POST', @_ );
}

## no critic (Subroutines::ProhibitBuiltinHomonyms)
sub delete {
    my $self = shift;
    return $self->_process_request( 'DELETE', @_ );
}
## use critic

sub _process_request {
    my $self = shift;

    my $request  = $self->_make_request(@_);
    my $response = $self->_ua->request($request);

    unless ( $response->is_success ) {
        die 'Error response:' . "\n\n"
            . $response->as_string
            . "\nFor the request:\n\n"
            . $request->as_string;
    }

    # The content we get back from PT has already been decoded into a UTF-8
    # string internally. If we call decode_json then Cpanel::JSON::XS _may_
    # try to decide it _again_, leading to breakage in some cases, notable
    # characters in the 128-255 range. See GH
    # https://github.com/maxmind/App-GHPT/issues/16 for an example.
    my $json = Cpanel::JSON::XS->new;
    return $json->decode( $response->content );
}

sub _make_request {
    my $self    = shift;
    my $method  = shift;
    my $uri     = shift;
    my $content = shift;

    return HTTP::Request->new(
        $method => $uri,
        [
            'X-TrackerToken' => $self->token,
            'Content-Type'   => 'application/json',
        ],
        ( $content ? encode_json($content) : () ),
    );
}

1;

# ABSTRACT: The API client

__END__

=pod

=head1 DESCRIPTION

This class has no user-facing parts.

=for Pod::Coverage *EVERYTHING*

=cut
