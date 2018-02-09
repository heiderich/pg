package Value::IdealInIntegers;
my $pkg = 'Value::IdealInIntegers';

use strict; no strict "refs";
our @ISA = qw(Value);

sub new {
  my $self = shift; my $class = ref($self) || $self;
  my $context = (Value::isContext($_[0]) ? shift : $self->context);
  my $n = shift;
  return (bless {data => [$n], context=>$context, type=>Value::Type("IdealInIntegers",1)}, $class);
}

sub make {
  my $self = shift; my $class = ref($self) || $self;
  my $context = (Value::isContext($_[0]) ? shift : $self->context); # FIXME ???
  my $n = shift;
  return (bless {data => [$n], context=>$context, type=>Value::Type("IdealInIntegers",1)}, $class);
}

sub typeRef {return Value::Type('IdealInIntegers')}
sub showClass {return 'an ideal in the ring of integers' }
sub length {1}

sub value {(shift)->{data}}

sub generator {abs((shift)->{data}[0])}

sub isWholeRing { (shift)->generator() == 1 }

sub TeX {
  my $self = shift;
  my $n = $self->{data}[0];
  return "\\mathbb{Z}" if $n==1;
  return $n."\\mathbb{Z}";
}

sub string {
  my $self = shift;
  my $n = $self->generator;
  return "Z" if $n==1;
  return $n."Z";
}


sub isIdealInIntegers { 1 }

sub add {
  #my ($self,$l,$r,$other) = Value::checkOpOrder(@_);
  my ($self,$l,$r,$other) = Value::checkOpOrderWithPromote(@_);

  warn "add in IdealInIntegers";
  # check if one is a number and the other one is an ideal of integers
  if (Value::isNumber($l) and isIdealInIntegers($r)) {
	  #return CyclicRingElement( $l->{data}[0], $r->{data}[0] ); ## FIXME
	  #Value::Error("Cannot form sum. Debug: l:".$l."r:".$r->{data}[0]);
	warn "adding number + Ideal:";
	return Value->Package("CyclicRingElement()")->new($l, $r->generator()); ##FIXME
  }
  # Check if both are ideals of integers
  elsif ( isIdealInIntegers($l) and isIdealInIntegers($l))
  {
	  warn "adding ideal and ideal";
	  my $lgen = $l->generator();
	  my $rgen = $r->generator();
	  warn "lref: ".ref($l);
	  warn "rref: ".ref($r);
	  warn "lgen: ".$lgen;
	  warn "rgen: ".$rgen;
      return $self->inherit($other)->make( Value::Integer::gcd($lgen, $rgen) );
  }
  else
  {
  	Value::Error("Cannot form this sum.");
  }
}

sub sub {
  my ($self,$l,$r,$other) = Value::checkOpOrderWithPromote(@_);

  warn "sub in IdealInIntegers";
  # check if one is a number and the other one is an ideal of integers
  if (Value::isNumber($l) and isIdealInIntegers($r)) {
	  #return CyclicRingElement( $l->{data}[0], $r->{data}[0] ); ## FIXME
	  #Value::Error("Cannot form sum. Debug: l:".$l."r:".$r->{data}[0]);
	warn "number - Ideal:";
	return Value->Package("CyclicRingElement()")->new($l, $r->generator()); ##FIXME
  }
  # Check if both are ideals of integers
  elsif ( isIdealInIntegers($l) and isIdealInIntegers($l))
  {
	  warn "subtracting ideal and ideal";
	  my $lgen = $l->generator();
	  my $rgen = $r->generator();
	  warn "lref: ".ref($l);
	  warn "rref: ".ref($r);
	  warn "lgen: ".$lgen;
	  warn "rgen: ".$rgen;
      return $self->inherit($other)->make( Value::Integer::gcd($lgen, $rgen) );
  }
  else
  {
  	Value::Error("Cannot form this subtraction.");
  }

}

sub mult {
	my ($self,$l,$r,$other) = Value::checkOpOrder(@_);

	if (Value::isNumber($l) and isIdealInIntegers($r)) {
		warn "multiplying an integer and an ideal";
		my $mult = $l * $r->generator;
		warn "mult: ".$mult;
		return $self->inherit($other)->new( $mult );
	}
	elsif (isIdealInIntegers($l) and isIdealInIntegers($r))
	{
		warn "multiplying an ideal and an ideal";
		my $mult = $l->generator * $r->generator;
		warn "mult: ".$mult;
		return $self->inherit($other)->new( $mult );
	}
	else  {
		Value::Error("Cannot form this product.");
	}

}

sub intersect {
  my ($self,$l,$r,$other) = Value::checkOpOrderWithPromote(@_);
  my $gen = Value::Integer::lcm($self->{data}[0], $other->{data}[0]);
  return $self->inherit($other)->new( $gen );
}

sub transferFlags {}

sub compare {
	my ($self,$l,$r) = Value::checkOpOrderWithPromote(@_);
	# FIXME: We should normalize these first (take the unique non-negative generator)
	my $l_val = $l->generator;
	my $r_val = $r->generator;
	return $l_val <=> $r_val;
}

#
#  Promote the ring of integers to an ideal
#
sub promote {
  my $self = shift; my $class = ref($self) || $self;
  my $context = (Value::isContext($_[0]) ? shift : $self->context);
  my $x = (scalar(@_) ? shift : $self);
  warn "trying to promote... (self = ".$self->string().", x = ".$x.") (in IdealInIntegers)";
  warn "ref(x) = ".ref($x).", ref(self) = ".$class;
  if (ref($x) eq $class && scalar(@_) == 0) {
	warn "return x in context";
	  return $x->inContext($context)
  }
  
  # Promote objects of the class Value::RingOfIntegers to IdealInIntegers
  if (ref($x) eq 'Value::RingOfIntegers') {
	  warn "promoting ring of integers to ideal in integers";
	  return $self->new($context,1);
  }

  return $x;
}

sub typeMatch {
  my $self = shift; my $other = shift; my $ans = shift;
  return ( $self->type eq $other->type ) || ( $other->type eq 'RingOfIntegers' and $self->isWholeRing() );
}

