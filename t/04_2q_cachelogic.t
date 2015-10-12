use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Data::Dumper;

use RLP::Cache2Q;

my $cache = RLP::Cache2Q->new(8);

is $cache->max_size, 8;

is $cache->set(1,a),a;
is $cache->set(2,b),b;

is $cache->set(3,c),c;
is $cache->set(4,d),d;
is $cache->set(5,e),e;
is $cache->set(6,f),f;



is $cache->set(7,g),g;
is $cache->set(8,k),k;
# cache now 3 .. 8 - 1&2 - evicted
is $cache->get(3),c;
# 3 move from in to out
is $cache->get(7),g;
#7 dont move
#IN:8 ,7 ,       OUT:5 ,6 ,4 ,   HOT:3 ,

is $cache->set(9,9),9;
# IN:9 ,8 ,       OUT:7 ,5 ,6 ,4 ,        HOT:3 ,
is $cache->set(10,10),10;
# IN:10 ,9 ,      OUT:7 ,6 ,5 ,8 ,        HOT:3 ,
is $cache->get(5),e;
# IN:9 ,10 ,      OUT:7 ,6 ,8 ,   HOT:5 ,3 ,
is $cache->get(3),c;
# IN:10 ,9 ,      OUT:8 ,6 ,7 ,   HOT:5 ,3 ,
is $cache->get(8),k;
# IN:10 ,9 ,      OUT:7 ,6 ,      HOT:8 ,3 ,

$cache->print;
done_testing;
