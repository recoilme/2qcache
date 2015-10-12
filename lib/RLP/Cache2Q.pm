package RLP::Cache2Q;
use strict;
use warnings;
use POSIX;
use RLP::CacheFIFO;
use RLP::CacheLRU;

use constant {
	NODES   => 0,
	SIZE    => 1,
	MAXSIZE => 2,
	MAXSIZEIN => 3,
	MAXSIZEOUT => 4,
	MAXSIZEHOT => 5,
	IN => 6,
	OUT => 7,
	HOT => 8,
};

our $VERSION = "0.01";

# Two queues cache
# @param maxSize for caches
sub new {
	my ($class, $max_size) = @_;
	my $self = bless [{}, 0, $max_size, 0, 0, 0, {}, {}, {}], $class;
	#Sets sizes:
	# mapIn  ~ 25% // 1st lvl - store for input keys, FIFO
	# mapOut ~ 50% // 2nd lvl - store for keys goes from input to output, FIFO
	# mapHot ~ 25% // hot lvl - store for keys goes from output to hot, LRU
	$self->[MAXSIZEIN] = floor($max_size * 0.25);
	$self->[MAXSIZEOUT] = $self->[MAXSIZEIN] * 2;
	$self->[MAXSIZEHOT] = $max_size - $self->[MAXSIZEIN] - $self->[MAXSIZEOUT];

	$self->[IN] = RLP::CacheFIFO ->new($self->[MAXSIZEIN]);
	$self->[OUT] = RLP::CacheFIFO ->new($self->[MAXSIZEOUT]);
	$self->[HOT] = RLP::CacheLRU ->new($self->[MAXSIZEHOT]);
	$self;
}

sub max_size {
	$_[0]->[MAXSIZE];
}

sub size {
	$_[0]->[SIZE];
	# why not work?
	#my ($self) = @_;
	#return $self->[NODES].size();
}

sub set {
	my ($self, $key, $value) = @_;

	my $evicted;

	if ($self->[MAXSIZEIN] > 0) {
		#2q
		# put in IN
		$evicted = $self->[IN]->add_cut($key);
		# if has evicted - put it into OUT
		if ($evicted) {
			$evicted = $self->[OUT]->add_cut($evicted);
			#if has evicted from OUT - remove it from NODES
			$self->remove($evicted);
		}
	}
	else {
		#lru
		$evicted = $self->[HOT]->set($key);
		$self->remove($evicted);
	}
	# add 2 NODES
	$self->[NODES]{$key} = $value;
	++$self->[SIZE];
	return $value;
}

sub get {
	my ($self, $key) = @_;
	my $val = $self->[NODES]{$key};
	if ($val) {
		if ($self->[HOT]->exists($key)) {
			# promote in HOT
			my $evicted = $self->[HOT]->set($key);
			$self->remove($evicted);
		}
		else {
			if ($self->[OUT]->exists($key)) {
				$self->[OUT]->remove($key);
				my $evicted = $self->[HOT]->set($key);
				$self->remove($evicted);
			}
			else {
				# do nothing
			}
		}

	}
	$val;
}


sub remove {
	my ($self, $evicted) = @_;
	if ($evicted) {
		delete $self->[NODES]{$evicted};
		--$self->[SIZE];
	}
}

sub print {
	my ($self) = @_;
	#print "\nnodes:";
	#while (my ($k,$v)=each $self->[NODES]){print "$k $v, "}
	print "\n IN:";
	$self->[IN]->print;
	print "\t OUT:";
	$self->[OUT]->print;
	print "\t HOT:";
	$self->[HOT]->print;
	print "\n";
}

1;

__END__
