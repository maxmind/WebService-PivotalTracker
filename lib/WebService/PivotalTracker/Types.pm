package WebService::PivotalTracker::Types;

use strict;
use warnings;

our $VERSION = '0.01';

use Type::Library
    -base,
    -declare =>
    qw( ClientObject CommentObject DateTimeObject MD5 StoryState StoryType );
use Type::Utils qw( class_type declare enum );
use Types::Common::Numeric;
use Types::Standard -types;

BEGIN {
    extends qw(
        Types::Common::Numeric
        Types::Common::String
        Types::Standard
        Types::URI
    );
}

class_type ClientObject, { class => 'WebService::PivotalTracker::Client' };

class_type CommentObject, { class => 'WebService::PivotalTracker::Comment' };

class_type DateTimeObject, { class => 'DateTime' };

declare MD5,
    as Str,
    where {m/^[0-9a-f]{32}$/i},
    inline { $_[0] . '=~ m/^[0-9a-f]{32}$/i' };

enum StoryState, [
    qw(
        accepted
        delivered
        finished
        started
        rejected
        planned
        unstarted
        unscheduled
        )
];

enum StoryType, [qw( feature bug chore release )];

1;
