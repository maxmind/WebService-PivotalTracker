package WebService::PivotalTracker;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '0.01';

use Params::CheckCompiler qw( compile );
use WebService::PivotalTracker::Client;
use WebService::PivotalTracker::Story;
use WebService::PivotalTracker::Types qw( MD5 Uri );

use Moo;

has token => (
    is       => 'ro',
    isa      => MD5,
    required => 1,
);

has base_uri => (
    is      => 'ro',
    isa     => Uri,
    coerce  => 1,
    default => 'https://www.pivotaltracker.com/services/v5/',
);

has client => (
    is      => 'ro',
    isa     => ClientObject,
    lazy    => 1,
    builder => '_build_client',
);

{
    my $check = compile(
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

        my $uri = $self->_client->build_uri(
            "/projects/$args{project_id}/stories",
            \%args,
        );

        my $stories = $self->_client->get($uri);
        return [
            map {
                WebService::PivotalTracker::Story->new(
                    raw_content => $_,
                    client      => $self->_client,
                    )
            } @{$stories}
        ];
    }
}

{
    my $check = compile(
        params => {
            story_id => PositiveInt,
        }
    );

    sub story {
        my $self = shift;
        my %args = $check->(@_);

        WebService::PivotalTracker::Story->new(
            raw_content => $self->_client->get(
                $self->_client->extend_uri("/stories/$args{story_id}"),
            ),
            client => $self->_client,
        );
    }
}

sub _build_client {
    my $self = shift;

    return WebService::PivotalTracker::Client->new(
        token    => $self->token,
        base_uri => $self->base_uri,
    );
}

1;
