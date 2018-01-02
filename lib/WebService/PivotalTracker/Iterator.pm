package WebService::PivotalTracker::Iterator;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '0.08';

use WebService::PivotalTracker::Types
    qw( ArrayRef ClassName HashRef PositiveInt PositiveOrZeroInt PTAPIObject Uri );

use Moo;

has pt_api => (
    is       => 'ro',
    isa      => PTAPIObject,
    required => 1,
);

has uri => (
    is       => 'ro',
    isa      => Uri,
    required => 1,
);

has class => (
    is       => 'ro',
    isa      => ClassName,
    required => 1,
);

has content => (
    is       => 'rw',
    isa      => ArrayRef,
    required => 1,
);

has pt_headers => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

has _counter => (
    is      => 'rw',
    isa     => PositiveOrZeroInt,
    default => 0,
);

has _total => (
    is      => 'ro',
    isa     => PositiveInt,
    lazy    => 1,
    default => sub { $_[0]->pt_headers->{pagination_total} },
);

sub next {
    my $self = shift;

    $self->_ensure_content or return;

    $self->_counter( $self->_counter + 1 );
    return $self->class->new(
        raw_content => shift @{ $self->content },
        pt_api      => $self->pt_api,
    );
}

sub _ensure_content {
    my $self = shift;

    return 1 if @{ $self->content };
    return 0 if $self->_counter >= $self->total;

    my $new_uri = $self->uri->clone;
    $new_uri->query_form(
        $new_uri->query_form,
        offset => $self->_counter,
    );

    my $content = $self->pt_api->client->get($new_uri);
    return 0 unless @{$content};

    $self->content($content);

    return 1;
}

1;
