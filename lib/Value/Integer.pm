package Value::Integer;
my $pkg = 'Value::Integer';

use strict; no strict "refs";
our @ISA = qw(Value);

sub new {
  my $self = shift; my $class = ref($self) || $self;
  my $context = (Value::isContext($_[0]) ? shift : $self->context);
  my $x = shift; $x = [$x,@_] if scalar(@_) > 0;
  return $x->inContext($context) if Value::isInteger($x);
  $x = [$x] unless ref($x) eq 'ARRAY';
  Value::Error("Can't convert ARRAY of length %d to %s",scalar(@{$x}),Value::showClass($self))
    unless (scalar(@{$x}) == 1);
  if (Value::matchNumber($x->[0])) {
    return $self->formula($x->[0]) if Value::isFormula($x->[0]);
    return (bless {data => $x, context=>$context}, $class);
  }
  $x = Value::makeValue($x->[0],context=>$context);
  return $x if Value::isIntegerNumber($x);
  Value::Error("Can't convert %s to %s",Value::showClass($x),Value::showClass($self));
}

#
#  Check that result is a number
#
sub make {
  my $self = shift;
  my $n = (Value::isContext($_[0]) ? $_[1] : $_[0]);
  return $self->SUPER::make(@_) unless lc("$n") eq "nan" or lc("$n") eq "-nan";
  Value::Error("Result is not an integer.");
}

#
#  Create a new formula from the number
#
sub formula {
  my $self = shift; my $value = shift;
  my $context = $self->context;
  $context->Package("Formula")->new($context,$value);
}

#
#  Return the real number type ## FIXME: Do we need different types for integers / reals
#
sub typeRef {return $Value::Type{number}}
sub length {1}

#
#  return the real number
#
sub value {(shift)->{data}[0]}

sub isZero {shift eq "0"}
sub isOne {shift eq "1"}

sub transferFlags {}


##################################################
#
#  Binary operations
#

sub add {
  my ($self,$l,$r,$other) = Value::checkOpOrderWithPromote(@_);
  return $self->inherit($other)->make($l->{data}[0] + $r->{data}[0]);
}

sub sub {
  my ($self,$l,$r,$other) = Value::checkOpOrderWithPromote(@_);
  return $self->inherit($other)->make($l->{data}[0] - $r->{data}[0]);
}

sub mult {
  my ($self,$l,$r,$other) = Value::checkOpOrderWithPromote(@_);
  return $self->inherit($other)->make($l->{data}[0] * $r->{data}[0]);
}

sub div {
  my ($self,$l,$r,$other) = Value::checkOpOrderWithPromote(@_);
  Value::Error("Division by zero") if $r->{data}[0] == 0;
  ## FIXME: Need to check divisibility
  return $self->inherit($other)->make($l->{data}[0] / $r->{data}[0]);
}

sub power {
  my ($self,$l,$r,$other) = Value::checkOpOrderWithPromote(@_);
  my $x = $l->{data}[0] ** $r->{data}[0];
  return $self->inherit($other)->make($x) unless lc($x) eq 'nan' or lc($x) eq '-nan';
  Value::Error("Can't raise a negative number to a non-integer power") if ($l->{data}[0] < 0);
  Value::Error("Result of exponention is not a number");
}

sub modulo {
  my ($self,$l,$r,$other) = Value::checkOpOrderWithPromote(@_);
  $l = $l->{data}[0]; $r = $r->{data}[0];
  return $self->inherit($other)->make(0) if $r == 0; # non-fuzzy check
  my $m = $l/$r;
  my $n = int($m); $n-- if $n > $m; # act as floor() rather than int()
  return $self->inherit($other)->make($l - $n*$r);
}

sub compare {
  my ($self,$l,$r) = Value::checkOpOrderWithPromote(@_);
  my ($a,$b) = ($l->{data}[0],$r->{data}[0]);
  return $a <=> $b;
}

##################################################
#
#   Numeric functions
#

sub abs  {my $self = shift; $self->make(CORE::abs($self->{data}[0]))}
sub neg  {my $self = shift; $self->make(-($self->{data}[0]))}

##################################################

sub string {
  my $self = shift; my $equation = shift; my $prec = shift;
  my $n = $self->{data}[0];
  my $format = $self->getFlag("format",$equation->{format} ||
			        ($equation->{context} || $self->context)->{format}{number});
  if ($format) {
    $n = sprintf($format,$n);
    if ($format =~ m/#\s*$/) {$n =~ s/(\.\d*?)0*#$/$1/; $n =~ s/\.$//}
  }
  $n = uc($n); # force e notation to E
  $n = 0 if CORE::abs($n) < $self->getFlag('zeroLevelTol');
  $n = "(".$n.")" if ($n < 0 || $n =~ m/E/i) && defined($prec) && $prec >= 1;
  return $n;
}

sub TeX {
  my $n = (shift)->string(@_);
  $n =~ s/E\+?(-?)0*([^)]*)/\\times 10^{$1$2}/i; # convert E notation to x10^(...)
  return $n;
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

#
#  Least Common Multiple
#
sub lcm {
  my $a = abs(shift); my $b = abs(shift);
  return ($a*$b)/gcd($a,$b);
}


###########################################################################

1;
