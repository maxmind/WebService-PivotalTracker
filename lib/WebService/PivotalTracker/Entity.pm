package WebService::PivotalTracker::Entity;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '0.01';

use DateTime::Format::RFC3339;
use URI;

use WebService::PivotalTracker::Types qw( ClientObject HashRef );

use Moo::Role;

requires '_self_uri';

has client => (
    is       => 'ro',
    isa      => ClientObject,
    required => 1,
);

has raw_content => (
    is       => 'rw',
    writer   => '_set_raw_content',
    isa      => HashRef,
    required => 1,
);

# The PT docs specify ISO8601 but the examples all seem to be RFC3339
# compliant.
sub _inflate_iso8601_datetime {
    return DateTime::Format::RFC3339->parse_datetime( $_[1] );
}

sub _inflate_uri {
    return URI->new( $_[1] );
}

sub _refresh_raw_content {
    my $self = shift;

    $self->_set_raw_content( $self->_client->get( $self->_self_uri ) );

    return;
}

1;
