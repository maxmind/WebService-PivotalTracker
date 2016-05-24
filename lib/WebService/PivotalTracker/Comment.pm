package WebService::PivotalTracker::Comment;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '0.01';

use Params::CheckCompiler qw( compile );
use WebService::PivotalTracker::Types
    qw( ArrayRef DateTimeObject Maybe NonEmptyStr PositiveInt );
use WebService::PivotalTracker::Util;

use Moo;

props_to_attributes(
    id                    => PositiveInt,
    story_id              => Maybe [PositiveInt],
    epic_id               => Maybe [PositiveInt],
    text                  => NonEmptyStr,
    person_id             => PositiveInt,
    created_at            => [ _inflate_datetime => DateTimeObject ],
    updated_at            => [ _inflate_datetime => DateTimeObject ],
    file_attachment_ids   => ArrayRef [PositiveInt],
    google_attachment_ids => ArrayRef [PositiveInt],
    commit_identifier     => Maybe [NonEmptyStr],
    commit_type           => Maybe [NonEmptyStr],
    kind                  => NonEmptyStr,
);

with 'WebService::PivotalTracker::HasClient';

1;
