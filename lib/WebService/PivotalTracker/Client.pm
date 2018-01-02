package WebService::PivotalTracker::Client;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '0.08';

use Cpanel::JSON::XS qw( decode_json encode_json );
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

    my $content = decode_json( $response->content );
    return $content unless wantarray;

    return ($content, $self->_pt_headers($response));
}

sub _pt_headers {
    my $self     = shift;
    my $response = shift;

    my %h;
    for my $name ( grep {/^X-Tracker-/i} $response->header_field_names ) {
        ( my $short = lc $name ) =~ s/X-Tracker-//i;
        $short =~ s/-/_/g;
        $h{$short} = $response->get($name);
    }

    return \%h;
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
