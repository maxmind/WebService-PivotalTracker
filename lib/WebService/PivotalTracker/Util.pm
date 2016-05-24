package WebService::PivotalTracker::Util;

use strict;
use warnings;

our $VERSION = '0.01';

use Exporter qw( import );

## no critic (Modules::ProhibitAutomaticExportation)
our @EXPORT = 'props_to_attributes';

sub props_to_attributes {
    my $has = caller()->can('has');

    for my $name ( keys %props ) {
        my ( $inflator, $type )
            = ref $props{$name}
            ? @{ $props{$name} }
            : ( undef, $props{$name} );

        my $default
            = $inflator
            ? sub { $self->$inflator( $self->raw_content->{$name} ) }
            : sub { $self->raw_content->{$name} };

        $has->(
            $name => (
                is       => 'ro',
                isa      => $type,
                init_arg => undef,
                lazy     => 1,
                default  => $default,
            )
        );
    }
}

1;
