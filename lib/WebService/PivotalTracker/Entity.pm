package WebService::PivotalTracker::Entity;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '0.01';

use WebService::PivotalTracker::Types qw( ClientObject HashRef MD5Hex Uri );

use Moo::Role;

has token => (
    is       => 'ro',
    isa      => MD5Hex,
    required => 1,
);

has base_uri => (
    is      => 'ro',
    isa     => Uri,
    coerce  => 1,
    default => 'https://www.pivotaltracker.com/services/v5/',
);

has client => (
    is       => 'ro',
    isa      => ClientObject,
    required => 1,
);

has raw_content => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

1;
