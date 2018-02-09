package Value::RingOfIntegers;
my $pkg = 'Value::RingOfIntegers';

use strict; no strict "refs";
our @ISA = qw(Value);

sub new {
  my $self = shift; my $class = ref($self) || $self;
  my $context = (Value::isContext($_[0]) ? shift : $self->context);
  return (bless {data => [], context=>$context, type=>Value::Type("RingOfIntegers",0)}, $class);
}

sub make {
  my $self = shift; my $class = ref($self) || $self;
  my $context = (Value::isContext($_[0]) ? shift : $self->context);
  return (bless {data => [], context=>$context, type=>Value::Type("RingOfIntegers",0)}, $class);
}

sub typeRef {return Value::Type('RingOfIntegers')}

# Returns a string representing the class of an object suitable for use in error messages.
sub showClass {return 'a ring of integers' }

# Returns the number of elements in the array returned by the value() method
sub length {0}

sub value {(shift)->{data}}

sub TeX {
	my $self = shift;
	return "\\mathbb{Z}";
}

sub string {
	return "Z";
}

sub mult {
  my ($l,$r,$flag) = @_; my $self = $l;
  my $context = $self->context;
  my $n = $r;
  Value::Error("The ring of integers can only be multiplied by numbers to form ideals in the ideal of integers.") unless Value::isNumber($r);
  return $context->Package("IdealInIntegers")->new($n); 
}

sub transferFlags {}
