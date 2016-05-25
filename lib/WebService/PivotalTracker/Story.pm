package WebService::PivotalTracker::Story;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '0.01';

use Params::CheckCompiler qw( compile );
use WebService::PivotalTracker::Comment;
use WebService::PivotalTracker::PropertyAttributes;
use WebService::PivotalTracker::Types
    qw( ArrayRef CommentObject DateTimeObject NonEmptyStr Num
        PositiveInt Str StoryState StoryType Uri );

use Moo;

has( @{$_} ) for props_to_attributes(
    id              => PositiveInt,
    project_id      => PositiveInt,
    name            => NonEmptyStr,
    description     => Str,
    story_type      => StoryType,
    current_state   => StoryState,
    estimate        => Num,
    accepted_at     => [ _inflate_datetime => DateTimeObject ],
    deadline        => [ _inflate_datetime => DateTimeObject ],
    requested_by_id => PositiveInt,
    owner_ids       => ArrayRef [PositiveInt],
    label_ids       => ArrayRef [PositiveInt],
    task_ids        => ArrayRef [PositiveInt],
    follower_ids    => ArrayRef [PositiveInt],
    comment_ids     => ArrayRef [PositiveInt],
    created_at      => [ _inflate_datetime => DateTimeObject ],
    updated_at      => [ _inflate_datetime => DateTimeObject ],
    before_id       => PositiveInt,
    after_id        => PositiveInt,
    integration_id  => PositiveInt,
    external_id     => Str,
    url             => [ _inflate_uri => Uri ],
    kind            => NonEmptyStr,
);

has comments => (
    is       => 'ro',
    isa      => ArrayRef [CommentObject],
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_comments',
);

with 'WebService::PivotalTracker::Entity';

# We could fetch each id in $self->comment_ids one at a time, but there's an
# endpoint to get all the comments at once, which is going to be more
# efficient.
sub _build_comments {
    my $self = shift;

    my $raw_comments = $self->_client->get( $self->_comments_uri );

    return [
        map {
            WebService::PivotalTracker::Comment->new(
                raw_content => $_,
                client      => $self->_client,
                )
        } @{$raw_comments}
    ];
}

sub _comments_uri {
    my $self = shift;

    my $path = sprintf(
        '/projects/%s/stories/%s/comments',
        $self->project_id,
        $self->id,
    );

    return $self->_client->build_uri($path);
}

{
    my $check = compile(
        params => {
            person_id => { type => PositiveInt },
            text      => { type => NonEmptyStr },
        }
    );

    sub add_comment {
        my $self = shift;
        my %args = $check->(@_);

        return WebService::PivotalTracker::Comment->new(
            raw_content =>
                $self->_client->post( $self->_comments_uri, \%args ),
            client => $self->_client,
        );
    }
}

1;
