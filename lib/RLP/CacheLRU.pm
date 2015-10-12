package RLP::CacheLRU;
use strict;
use warnings;
use constant {
	NEXT    => 0,
	PREV    => 1,
	KEY     => 2,
	VALUE   => 3,
	HEAD    => 0,
	TAIL    => 1,
	NODES   => 2,
	SIZE    => 3,
	MAXSIZE => 4,
};

our $VERSION = "0.01";

sub new {
	my ($class, $max_size) = @_;
	my $self = bless [[undef, undef], undef, {}, 0, $max_size,], $class;
	$self->[TAIL] = $self->[HEAD];
	$self;
}

sub max_size {
	$_[0]->[MAXSIZE];
}

sub size {
	$_[0]->[SIZE];
}

sub _promote {
	my ($self, $node) = @_;
	my $pre = $node->[PREV];
	$node->[PREV]             = undef;
	$pre->[NEXT]              = $node->[NEXT];
	$pre->[NEXT][PREV]        = $pre;
	$node->[NEXT]             = $self->[HEAD];
	$self->[HEAD]             = $node;
	$self->[HEAD][NEXT][PREV] = $self->[HEAD];
}

sub remove {
	my ($self, $key) = @_;
	return if not exists $self->[NODES]{$key};
	my $node = $self->[NODES]{$key};
	--$self->[SIZE];
	if ($node == $self->[HEAD]) {
		$self->[HEAD] = $node->[NEXT];
		$self->[HEAD][PREV] = undef;
	} else {
		my $pre = $node->[PREV];
		$pre->[NEXT] = $node->[NEXT];
		$node->[NEXT][PREV] = $pre;
	}
	delete $self->[NODES]{$node->[KEY]};
	$node->[NEXT] = undef;
	$node->[PREV] = undef;
	$node->[VALUE];
}

sub set {
	my ($self, $key, $value) = @_;
	my $evicted_key;
	if (my $node = $self->[NODES]{$key}) {
		$node->[VALUE] = $value;
		$self->_promote($node) if $node != $self->[HEAD];
	} else {
		$self->[HEAD] = [$self->[HEAD], undef, $key, $value];
		$self->[HEAD][NEXT][PREV] = $self->[HEAD];
		$self->[NODES]{$key} = $self->[HEAD];
		if (++$self->[SIZE] > $self->[MAXSIZE]) {
			my $pre_least = $self->[TAIL][PREV];
			if (my $pre = $pre_least->[PREV]) {
				$evicted_key = $pre_least->[KEY];
				delete $self->[NODES]{$pre_least->[KEY]};
				$pre->[NEXT]        = $self->[TAIL];
				$self->[TAIL][PREV] = $pre;
				$pre_least->[NEXT]  = undef;
				$pre_least->[PREV]  = undef;
				--$self->[SIZE];
			}
		}
	}
	# если value не было передано, то вернет вытесненное значение
	# а если передал - работает привычным образом
	if (!$value) {
		$value = $evicted_key;
	}
	return $value;
}

sub get {
	my ($self, $key) = @_;
	if (my $node = $self->[NODES]{$key}) {
		$self->_promote($node) if $node != $self->[HEAD];
		$node->[VALUE];
	} else {
		return;
	}
}

sub exists {
	my ($self, $key) = @_;
	return $self->[NODES]{$key};
}

sub print {
	my ($self) = @_;
	while (my ($k,$v)=each $self->[NODES]){
		print "$k ,"
	}
}
1;