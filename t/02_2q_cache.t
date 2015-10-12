use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use RLP::Cache2Q;

my $cache = RLP::Cache2Q->new(2);

is $cache->max_size, 2;
is $cache->set(a => 1), 1;
is $cache->size, 1;
is $cache->get(a),1;
is $cache->get(b),undef;
is $cache->set(b => 2), 2;
is $cache->size, 2;
is $cache->set(c => 3), 3;
$cache->print();
is $cache->size, 2;

$cache = RLP::Cache2Q->new(10);

my ($hit, $miss) = (0, 0);

for (1 .. 2000) {
    my $key = 1 + int rand 8;
    if ($cache->get($key)) {
        $hit++;
    } else {
        $miss++;
        $cache->set($key => $key);
    }
}

cmp_ok($hit, '>=', $miss, "more cache hits than misses during random access of small sigma ($hit >= $miss)");

($hit, $miss) = (0, 0);

for (1 .. 100) {
    foreach my $key (1 .. 10) {
        if ($cache->get($key)) {
            $hit++;
        } else {
            $miss++;
            $cache->set($key => $key);
        }
    }
}
print "hit:".$hit." miss:".$miss." size:".$cache->size()."\n";
cmp_ok($hit, '>=', $miss, "no significant hits during linear scans ($hit)");

done_testing;
