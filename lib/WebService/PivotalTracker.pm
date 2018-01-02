package WebService::PivotalTracker;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '0.08';

use DateTime::Format::RFC3339;
use Params::ValidationCompiler qw( validation_for );
use Scalar::Util qw( blessed );
use WebService::PivotalTracker::Client;
use WebService::PivotalTracker::Iterator;
use WebService::PivotalTracker::Me;
use WebService::PivotalTracker::Project;
use WebService::PivotalTracker::ProjectIteration;
use WebService::PivotalTracker::Story;
use WebService::PivotalTracker::Types
    qw( ArrayRef ClientObject IterationScope LWPObject MD5Hex NonEmptyStr PositiveInt Uri );

use Moo;

has token => (
    is       => 'ro',
    isa      => MD5Hex,
    required => 1,
);

has base_uri => (
    is      => 'ro',
    isa     => Uri,
    coerce  => 1,
    default => 'https://www.pivotaltracker.com/services/v5',
);

has _ua => (
    is        => 'ro',
    isa       => LWPObject,
    init_arg  => 'ua',
    predicate => '_has_ua',
);

has client => (
    is      => 'ro',
    isa     => ClientObject,
    lazy    => 1,
    builder => '_build_client',
);

sub projects {
    my $self = shift;

    my $uri = $self->client->build_uri('/projects');

    return [
        map {
            WebService::PivotalTracker::Project->new(
                raw_content => $_,
                pt_api      => $self,
                )
        } @{ $self->client->get($uri) }
    ];
}

{
    my $check = validation_for(
        params => {
            project_id => { type => PositiveInt },
            filter     => {
                type     => NonEmptyStr,
                optional => 1
            },
        }
    );

    sub project_stories_where {
        my $self = shift;
        my %args = $check->(@_);

        my $uri = $self->client->build_uri(
            "/projects/$args{project_id}/stories",
            \%args,
        );

        return $self->_iterator_for(
            'WebService::PivotalTracker::Story',
            'get',
            $uri
        );
    }
}

sub _iterator_for {
    my $self  = shift;
    my $class = shift;
    my $uri   = shift;

    my ( $content, $pt_headers ) = $self->client->get($uri);
    return WebService::PivotalTracker::Iterator->new(
        pt_api     => $self,
        uri        => $uri,
        class      => $class,
        content    => $content,
        pt_headers => $pt_headers,
    );
}

{
    my $check = validation_for(
        params => {
            story_id => { type => PositiveInt },
        }
    );

    sub story {
        my $self = shift;
        my %args = $check->(@_);

        WebService::PivotalTracker::Story->new(
            raw_content => $self->_client->get(
                $self->_client->build_uri("/stories/$args{story_id}"),
            ),
            pt_api => $self,
        );
    }
}

{
    my $check = validation_for(
        params => {
            project_id => { type => PositiveInt },
            label      => {
                type     => NonEmptyStr,
                optional => 1
            },
            limit => {
                type    => PositiveInt,
                default => 1,
            },
            offset => {
                type     => PositiveInt,
                optional => 1,
            },
            scope => {
                type     => IterationScope,
                optional => 1
            },
        },
    );

    sub project_iterations {
        my $self = shift;
        my %args = $check->(@_);

        my $uri = $self->client->build_uri(
            "/projects/$args{project_id}/iterations",
            \%args,
        );

        return [
            map {
                WebService::PivotalTracker::ProjectIteration->new(
                    raw_content => $_,
                    pt_api      => $self,
                    )
            } @{ $self->client->get($uri) }
        ];
    }
}

# XXX - if we want to add more create_X methods we should find a way to
# streamline & simplify this code so we don't have to repeat this sort of
# boilerplate over and over. Maybe each entity class should provide more
# detail about the properties, including type, coercions (like DateTime ->
# RFC3339 string), required for create/update, etc.
{
    ## no critic (Subroutines::ProtectPrivateSubs)
    my %props  = WebService::PivotalTracker::Story->_properties;
    my %params = map {
        $_ => blessed $props{$_}
            ? { type => $props{$_} }
            : { type => $props{$_}{type} }
    } keys %props;

    my %required = map { $_ => 1 } qw( project_id name );
    $params{$_}{optional} = 1 for grep { !$required{$_} } keys %props;

    %params = (
        %params,
        before_id => {
            type     => PositiveInt,
            optional => 1,
        },
        after_id => {
            type     => PositiveInt,
            optional => 1,
        },
        labels => {
            type => ArrayRef [NonEmptyStr],
            optional => 1
        },
    );

    my $check = validation_for(
        params => \%params,
    );

    sub create_story {
        my $self = shift;
        my %args = $check->(@_);

        $self->_deflate_datetime_values( \%args );

        my $project_id  = delete $args{project_id};
        my $raw_content = $self->client->post(
            $self->client->build_uri("/projects/$project_id/stories"),
            \%args,
        );

        return WebService::PivotalTracker::Story->new(
            raw_content => $raw_content,
            pt_api      => $self,
        );
    }
}

sub me {
    my $self = shift;

    return WebService::PivotalTracker::Me->new(
        raw_content =>
            $self->client->get( $self->client->build_uri('/me') ),
        pt_api => $self,
    );
}

sub _build_client {
    my $self = shift;

    return WebService::PivotalTracker::Client->new(
        token    => $self->token,
        base_uri => $self->base_uri,
        ( $self->_has_ua ? ( ua => $self->_ua ) : () ),
    );
}

sub _deflate_datetime_values {
    my $self = shift;
    my $args = shift;

    for my $key ( keys %{$args} ) {
        next unless blessed $args->{$key} && $args->{$key}->isa('DateTime');
        $args->{$key}
            = DateTime::Format::RFC3339->format_datetime( $args->{$key} );
    }

    return;
}

1;

# ABSTRACT: Perl library for the Pivotal Tracker REST API

__END__

=pod

=for Pod::Coverage project_iterations

=head1 SYNOPSIS

    my $pt =  WebService::PivotalTracker->new(
        token => '...',
    );
    my $story = $pt->story( story_id => 1234 );
    my $me = $pt->me;

    for my $label ( $story->labels ) { }

    for my $comment ( $story->comments ) { }

=head1 DESCRIPTION

B<This is fairly alpha software. The API is likely to change in breaking ways
in the future.>

This module provides a Perl interface to the L<REST API
V5|https://www.pivotaltracker.com/help/api/rest/v5> for L<Pivotal
Tracker|https://www.pivotaltracker.com/>. You will need to refer to the L<REST
API docs|https://www.pivotaltracker.com/help/api/rest/v5> for some details, as
this documentation does not reproduce the details of every attribute available
for a resource.

This class, C<WebService::PivotalTracker>, provides the main entry point for
all API calls.

=head1 METHODS

All web requests which return anything other than a success status result in a
call to C<die> with a simple string error message. This will probably change
to something more useful in the future.

This class provides the following methods:

=head2 WebService::PivotalTracker->new(...)

This creates a new object of this class. It accepts the following arguments:

=over 4

=item * token

An MD5 access token for Pivotal Tracker.

This is required.

=item * base_uri

The base URI against which all requests will be made. This defaults to
C<https://www.pivotaltracker.com/services/v5>.

=back

=head2 $pt->projects

This method returns an array reference of
L<WebService::PivotalTracker::Project> objects, one for each project to which
the token provides access.

=head2 $pt->project_stories_where(...)

This method accepts the following arguments:

=over 4

=item * story_id

The id of the project you are querying.

This is required.

=item * filter

A search filter. This is the same syntax as you would use in the PT
application for searching. See
L<https://www.pivotaltracker.com/help/articles/advanced_search/> for details.

=back

=head2 $pt->story(...)

This method returns a single L<WebService::PivotalTracker::Story> object, if
one exists for the given id.

This method accepts the following arguments:

=over 4

=item * story_id

The id of the story you are querying.

This is required.

=back

=head2 $pt->create_story(...)

This creates a new story. This method accepts every attribute of a
L<WebService::PivotalTracker::Story> object. The C<project_id> and C<name>
parameters are required.

It also accepts two additional optional parameters:

=over 4

=item * before_id

A story ID before which this story should be added.

=item * after_id

A story ID after which this story should be added.

=back

By default the story will be added as the last story in the icebox.

=head2 $pt->me

This returns a L<WebService::PivotalTracker::Me> object for the user to which
the token belongs.

=cut
