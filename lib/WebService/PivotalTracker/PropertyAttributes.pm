package WebService::PivotalTracker::PropertyAttributes;

use strict;
use warnings;

our $VERSION = '0.01';

use Scalar::Util qw( reftype );

use Exporter qw( import );

## no critic (Modules::ProhibitAutomaticExportation)
our @EXPORT = 'props_to_attributes';

sub props_to_attributes {
    my %props = @_;

    return map { [ $_ => _attr_for( $_, $props{$_} ) ] } keys %props;
}

sub _attr_for {
    my $name = shift;
    my $prop = shift;

    my ( $inflator, $type )
        = reftype $prop eq 'ARRAY'
        ? @{$prop}
        : ( undef, $prop );

    my $default
        = $inflator
        ? sub { $_[0]->$inflator( $_[0]->raw_content->{$name} ) }
        : sub { $_[0]->raw_content->{$name} };

    return (
        is       => 'ro',
        isa      => $type,
        init_arg => undef,
        lazy     => 1,
        default  => $default,
    );
}

1;
