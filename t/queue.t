use strict;
use warnings;
use utf8;
use File::Basename 'dirname';
use File::Spec::Functions qw{catdir splitdir rel2abs canonpath};
use lib catdir(dirname(__FILE__), '../lib');
use lib catdir(dirname(__FILE__), 'lib');
use Test::More;
use WWW::Crawler::Mojo;
use WWW::Crawler::Mojo::Queue;

use Test::More tests => 11;

my $queue = WWW::Crawler::Mojo::Queue->new(resolved_uri => 'foo');
$queue->add_props(add_baz => 'add_baz_value');
my $queue2 = $queue->clone;
is $queue2->resolved_uri, 'foo', 'right result';
is $queue2->additional_props->{add_baz}, 'add_baz_value', 'right prop';
isnt $queue->additional_props, $queue2->additional_props, 'deep cloned';

my $bot = WWW::Crawler::Mojo->new;
$bot->enqueue('http://example.com/');
is ref $bot->queues->[0], 'WWW::Crawler::Mojo::Queue';
is $bot->queues->[0]->resolved_uri, 'http://example.com/';
is @{$bot->queues}, 1, 'right number';
$bot->enqueue(Mojo::URL->new('http://example.com/2'));
is ref $bot->queues->[1], 'WWW::Crawler::Mojo::Queue';
is $bot->queues->[1]->resolved_uri, 'http://example.com/2';
is @{$bot->queues}, 2, 'right number';

my $queue3 = shift @{$bot->queues};
$bot->enqueue($queue3);
is @{$bot->queues}, 1, 'right number';
$bot->requeue($queue3);
is @{$bot->queues}, 2, 'right number';

1;

__END__
