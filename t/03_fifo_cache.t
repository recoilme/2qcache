use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Data::Dumper;

use RLP::CacheFIFO;

my $cache = RLP::CacheFIFO->new(2);

is $cache->max_size, 2;

is $cache->size, 0;
is $cache->add_cut(1,a),undef;
is $cache->add_cut(2,b),undef;
is $cache->add_cut(3,c),1;
is $cache->add_cut(4,4),2;
$cache->print;

#is $cache->get(b),undef;
#is $cache->add_cut(b), undef;
#is $cache->size, 2;
#is $cache->add_cut(c), a;
# a - evicted by fifo key: order b,c now
#is $cache->size, 2;
#is $cache->add_cut(d), b;
# b - evicted

done_testing;
