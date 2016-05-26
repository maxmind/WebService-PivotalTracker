# NAME

WebService::PivotalTracker - Perl library for the Pivotal Tracker REST API

# VERSION

version 0.01

# SYNOPSIS

    my $pt =  WebService::PivotalTracker->new(
        token => '...',
    );
    my $story = $pt->story( story_id => 1234 );
    my $me = $pt->me;

    for my $label ( $story->labels ) { ... }

    for my $comment ( $story->comments ) { ... }

# DESCRIPTION

**This is very alpha (and as of yet mostly undocumented) software**.

This module provides a Perl interface to the [Pivotal
Tracker](https://www.pivotaltracker.com/) REST API.

# AUTHOR

Dave Rolsky <autarch@urth.org>

# CONTRIBUTOR

Dave Rolsky <drolsky@maxmind.com>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2016 by Dave Rolsky.

This is free software, licensed under:

    The Artistic License 2.0 (GPL Compatible)
