package WebService::PivotalTracker::Person;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '0.11';

use WebService::PivotalTracker::PropertyAttributes;
use WebService::PivotalTracker::Types
    qw( ArrayRef Bool DateTimeObject NonEmptyStr PositiveInt );

use Moo;

has( @{$_} ) for props_to_attributes(
    id       => PositiveInt,
    name     => NonEmptyStr,
    initials => NonEmptyStr,
    username => NonEmptyStr,
    kind     => NonEmptyStr,
);

with 'WebService::PivotalTracker::Entity';

## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub _self_uri {
    die 'Me has no uri';
}
## use critic

1;

# ABSTRACT: A Person (a PT user)

__END__

=pod

=head1 SYNOPSIS

=for Test::Synopsis
my $pt;

  my $requester = $pt->story( story_id => 42 )->requested_by;

=head1 DESCRIPTION

This class represents a person.

=head1 ATTRIBUTES

This class provides the following attribute accessor methods. Each one
corresponds to a property defined by the L<PT REST API V5 me resource
docs|https://www.pivotaltracker.com/help/api/rest/v5#me_resource>.

=head2 id

=head2 name

=head2 initials

=head2 username

=head2 kind

=head2 raw_content

The raw JSON used to create this object.

=cut
