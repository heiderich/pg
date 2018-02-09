package Value::CyclicRingElement;
my $pkg = 'Value::CyclicRingElement';

use strict; no strict "refs";
our @ISA = qw(Value);

use Scalar::Util;

sub new {
  my $self = shift; my $class = ref($self) || $self;
  my $context = (Value::isContext($_[0]) ? shift : $self->context);
  my $x = shift; 
  my $n = shift;
  # $x and $n represent the element $x + $n Z in Z/nZ
  return (bless {data => [$x,$n], context=>$context, type=>Value::Type("CyclicRingElement",2)}, $class);
}

sub representative {
	my $self = shift;
	$self = $self->reduce();
	return $self->{data}[0];
}


# Order of the underlying ring
sub order {
	my $self = shift;
	return $self->{data}[1];
}

sub make {
  my $self = shift; my $class = ref($self) || $self;
  my $context = (Value::isContext($_[0]) ? shift : $self->context); # FIXME ???
  my $x = shift; 
  my $n = shift; 
  return (bless {data => [$x,$n], context=>$context}, $class);
}

sub typeRef {return Value::Type('CylicRingElement',2)}
sub showClass {return 'a cyclic ring element' }
sub length {2}

sub value {(shift)->{data}}

# reduce modulo the order of the ring
sub reduce {
	my $self = shift;
	my $n = $self->{data}[1]; 
	$self->{data}[0] = $self->{data}[0] % $n;
	return $self;
}

sub isZero {
	my $self = shift;
	my $n = $self->{data}[1];
	if ($self->{data}[0] % $n == 0) {
		return 1;
	}
	else {
		return 0;
	}
}

sub isOne {
	my $self = shift;
	my $n = $self->{data}[1];
	if ($self->{data}[0] % $n == 1) {
		return 1;
	}
	else {
		return 0;
	}
}

sub isInvertible { 
	my $self = shift;
	my $a = $self->{data}[0];
	my $n = $self->{data}[1];

	# check whether $a + $n Z is invertible in Z/nZ
	my $gcd = gcd($a,$n);
	if ($gcd == 1) {
		return 1;
	}
	else {
		return 0;
	}
}

sub transferFlags {}

sub isCyclicRingElement { 1 }

##################################################
#
#  Binary operations
#

sub add {
  my ($self,$l,$r,$other) = Value::checkOpOrder(@_);
  my $ref_l = Scalar::Util::blessed($l);
  my $ref_r = Scalar::Util::blessed($r);
  warn "ref l:".$ref_l;
  warn "ref r:".$ref_r;
  if (($ref_l eq "Value::CyclicRingElement") and ($ref_r eq "Value::CyclicRingElement"))
  {
  	if ($l->order == $r->order) {
  		return $self->inherit($other)->make( $l->representative + $r->representative, $l->order );
  	}
  	else
  	{
		warn "order l".$l->order;
		warn "order r".$r->order;
  		Value::Error("Cannot add elements of different rings.");
  	}
  }
  elsif ($ref_l eq "" and $ref_r eq "Value::CyclicRingElement") # probably $l is a number (FIXME)
  {
  	return $self->inherit($other)->make($l + $r->{data}[0], $r->{data}[1]);
  }
  else
  {
  	Value::Error("Cannot the sub of an object of type %s and an object of type %s.",$ref_l,$ref_r);
  }
}

sub sub {
	my ($self,$l,$r,$other) = Value::checkOpOrderWithPromote(@_);
	my $ref_l = Scalar::Util::blessed($l);
	my $ref_r = Scalar::Util::blessed($r);
	if (($ref_l eq "Value::CyclicRingElement") and ($ref_r eq "Value::CyclicRingElement"))
	{
		if ($l->{data}[1] == $r->{data}[1]) {
			return $self->inherit($other)->make($l->{data}[0] - $r->{data}[0], $l->{data}[1]);
		}
		else
		{
			warn "Cannot subtract elements of different rings.";
			warn "ref l:".$ref_l;
			warn "ref r:".$ref_r;
			warn "r: ".$r;
			warn "l: ".$l;
			Value::Error("Cannot subtract elements of different rings.");
		}
	}
	elsif ($ref_l eq "" and $ref_r eq "Value::CyclicRingElement") # probably $l is a number (FIXME)
	{
		return $self->inherit($other)->make($l - $r->{data}[0], $r->{data}[1]);
	}
	elsif ($ref_l eq "Value::CyclicRingElement" and $ref_r eq "" ) # probably $r is a number (FIXME)
	{
		return $self->inherit($other)->make($l->{data}[0] - $r, $l->{data}[1]);
	}
	else
	{
		Value::Error("Cannot the sub of an object of type %s and an object of type %s.",$ref_l,$ref_r);
	}
}

sub mult {
  my ($self,$l,$r,$other) = Value::checkOpOrder(@_);
  my $ref_l = Scalar::Util::blessed($l);
  my $ref_r = Scalar::Util::blessed($r);
  if (($ref_l eq "Value::CyclicRingElement") and ($ref_r eq "Value::CyclicRingElement"))
  {
  	if ($l->{data}[1] == $r->{data}[1]) {
  		return $self->inherit($other)->make($l->representative * $r->representative, $l->order);
  	}
  	else
  	{
  		Value::Error("Cannot multiply elements of different rings. l:$l r:$r");
  	}
  }
  #elsif (isNumber($l) and isCyclicRingElement($r))
  #{
  #	return $self->inherit($other)->make($l * $r->{data}[0], $l->{data}[1]);
  #}
  elsif ($ref_l eq "" and $ref_r eq "Value::CyclicRingElement") # probably $l is a number (FIXME)
  {
	  warn "multiplying an integer and an element of a cyclic ring";
	  my $mult = $l * $r->representative;
	  warn "mult: ".$mult;
  	return $self->inherit($other)->make($mult, $r->order);
  }
  else
  {
  	Value::Error("Cannot the product of an object of type %s and an object of type %s.",$ref_l,$ref_r);
  }
}

sub div {
  my ($self,$l,$r,$other) = Value::checkOpOrderWithPromote(@_);
  Value::Error("Division by zero") if $r->isZero();
  if ($r->isInvertible) {
  	return $l * $r->multiplicativeInverse(); 
  }
  else
  {
  	Value::Error("Division not possible, since the divisor is not invertible.");
  }
}

sub power {
  my ($self,$l,$r,$other) = Value::checkOpOrderWithPromote(@_);
  
  if ($r->{data}[0] >= 0) {
	my $x = $l->{data}[0] ** $r->{data}[0];
  	return $self->inherit($other)->make($x, $l->{data}[1]);
  }
  elsif ($r->{data}[0] < 0) {
	my $neg_exp = -$r->{data}[0];
	return $l->multiplicativeInverse() ** $neg_exp;
  }
  Value::Error("Error while computing a power in a cyclic ring.");
}

sub compare {
	my ($self,$l,$r) = Value::checkOpOrderWithPromote(@_);
	if ($l->{data}[1] != $r->{data}[1]) {
		Value::Error("Cannot compare elements belonging to different cyclic rings.");
	}
	else
	{
		warn "Reduce? ".$self->getFlag("autoreduce_representatives");
		if ($self->getFlag("autoreduce_representatives") == 1)
		{
			warn "reducing!";
			warn "l before: ".$l;
			warn "r before: ".$r;
			$l = $l->reduce;
			$r = $r->reduce;
			warn "l after: ".$l;
			warn "r after: ".$r;
		}	
		my $l_val = $l->{data}[0];
		my $r_val = $r->{data}[0];
			warn "lval: ".$l;
			warn "rval: ".$r;
		warn "cmp: ".($l_val <=> $r_val);
		return $l_val <=> $r_val;
	}
}

## The following functions are taken from contextInteger.pl
## Maybe they could be moved to Value::Integers

sub multiplicativeInverse {
  my $self = shift;
  my $a = $self->{data}[0];
  my $n = $self->{data}[1];
  return $self->make(modularInverse($a,$n), $n);
}

sub modularInverse {
  my $b = shift; my $n = shift;
  $b = $b % $n; # make sure $b is not negative
  my ($g, $x, $y) = egcd($b, $n);
  if ($g == 1) {
    return $x % $n;
  } else {
    Value::Error("Modular inverse: gcd($b, $n) != 1");
  }
}

#
#  Greatest Common Divisor
#
sub gcd {
  my $a = abs(shift); my $b = abs(shift);
  return $a if $b == 0;
  return $b if $a == 0;
  ($a,$b) = ($b,$a) if $a > $b;
  while ($a) {
    ($a, $b) = ($b % $a, $a);
  }
  return $b;
}

#  Extended Greatest Common Divisor
#
# return (g, x, y) a*x + b*y = gcd(x, y) = g 
sub egcd {
  my $a = shift; my $b = shift;
  if ($a == 0) {
    return ($b, 0, 1);
  } else {
    my ($g, $x, $y) = egcd($b % $a, $a);
    my $temp = int($b / $a); $temp-- if $temp > $b / $a; # act as floor() rather than int()
    return ($g, $y - $temp * $x, $x);
  }
}

sub neg {
	my $self = shift;
	$self->make(-($self->{data}[0]), $self->{data}[1]);
}


#############################################################
# Returns a string similar to that used to create the object,
# in the form that a student would use to enter the object in
# an answer blank, or that could be used in Compute() to
# create the object. The string may have more parentheses than
# the original string used to create the object, and may
# include explicit multiplication rather than implicit
# multiplication, and other normalization of the original
# format. 
#############################################################
sub string {
  my $self = shift; my $equation = shift; my $prec = shift;
  my $n = $self->{data}[0];
  return $self->{data}[0]."+(".$self->{data}[1]."*Z)";
}

sub TeX {
  my $self = shift;
  my $n = $self->{data}[0];
  my $p = $self->{data}[1];
  $n = $n % $p;
  if ($self->{context}{flags}{notation} eq "coset")
  {
	return $n."+".$p."\\mathbb{Z}";
  }
  elsif ($self->{context}{flags}{notation} eq "bar")
  {
  	return "\\bar{".$n."}";
  }
  else
  {
  	Value::Error("Flag 'notation' has invalid value.");
  }
}

sub promote {
  my $self = shift; my $class = ref($self) || $self;
  my $context = (Value::isContext($_[0]) ? shift : $self->context);
  my $x = (scalar(@_) ? shift : $self);
  return $x->inContext($context) if ref($x) eq $class && scalar(@_) == 0;
  warn "trying to promote... (in CyclicRingElement)";
  warn "(self = ".$self->string().", x = ".$x.") (in IdealInIntegers)";
  warn "ref(x) = ".ref($x).", ref(self) = ".$class;
  
  # Promote objects of the class IdealInIntegers to CyclicRingElement
  return $self->new($context,0,$x->generator) if ref($x) eq 'Value::IdealInIntegers';
 
  # return the original object 
  return $x;
}

1;
