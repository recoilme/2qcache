use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Benchmark qw(:all);
use Cache::LRU;
use RLP::CacheLRU;
use RLP::Cache2Q;

my $size      = 1024;
my $loop_data = 100;
my $loop      = 1000;

sub cache_hit {
	my $cache = shift;
	$cache->set(a => 1);
	my $c = 0;
	$c += $cache->get('a') for 1 .. $loop;
	$c;
}

sub cache_set_hit {
	my $cache = shift;
	for (0 .. 9) {
		$cache->set(chr ($_ + ord "a") => 1);
	}
	my $c = 0;
	for (1 .. $loop_data) {
		for my $k (0 .. 9) {
			for (1 .. 5) {
				$c += $cache->get(chr ($k + ord "a"));
			}
		}
	}
	$c;
}

print "cache_hit:\n";
cmpthese(
	5000, {
		'Cache::LRU' => sub {
			cache_hit(Cache::LRU->new(size => $size));
		},
		'RLP::CacheLRU' => sub {
			cache_hit(RLP::CacheLRU->new($size));
		},
		'RLP::Cache2Q' => sub {
			cache_hit(RLP::Cache2Q->new($size));
		},
	}
);

print "\ncache_set:\n";
srand (0);
my @keys = map { int rand (1048576) } 1 .. 65536;

sub cache_set {
	my $cache = shift;
	$cache->set($_ => 1) for @keys;
	$cache;
}

cmpthese(
	20, {
		'Cache::LRU' => sub {
			cache_set(Cache::LRU->new(size => $size));
		},
		'RLP::CacheLRU' => sub {
			cache_set(RLP::CacheLRU->new($size));
		},
		'RLP::Cache2Q' => sub {
			cache_set(RLP::Cache2Q->new($size));
		},
	}
);

print "\ncache_set_hit:\n";
cmpthese(
	500, {
		'Cache::LRU' => sub {
			cache_set_hit(Cache::LRU->new(size => $size));
		},
		'RLP::CacheLRU' => sub {
			cache_set_hit(RLP::CacheLRU->new($size));
		},
		'RLP::Cache2Q' => sub {
			cache_set_hit(RLP::Cache2Q->new($size));
		},
	}
);
