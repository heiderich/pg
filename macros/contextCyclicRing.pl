################################################################################
# WeBWorK Online Homework Delivery System
# Copyright © 2000-2017 The WeBWorK Project, http://openwebwork.sf.net/
# $CVSHeader:$
# 
# This program is free software; you can redistribute it and/or modify it under
# the terms of either: (a) the GNU General Public License as published by the
# Free Software Foundation; either version 2, or (at your option) any later
# version, or (b) the "Artistic License" which comes with this package.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See either the GNU General Public License or the
# Artistic License for more details.
################################################################################


=head1 NAME
contextCyclicRing.pl - a context for cyclic rings

=head1 DESCRIPTION

=head1 USAGE
	Context("CyclicRing")
=cut

loadMacros('MathObjects.pl');
loadMacros('IntegerFunctions.pl');

sub _contextCyclicRing_init {context::CyclicRing::Init()};

###########################################################################

package context::CyclicRing;
our @ISA = ('Value::Formula'); # inherit from Value::Formula

#
#  Some type declarations for the various classes
#
our $INTEGER = {isValue => 1,
	type => Value::Type("Number",0),
	name => "Number",
	};
our $RING_OF_INTEGERS = {isValue => 1,
	type => Value::Type("RingOfIntegers",0),
	name => "RingOfIntegers",
	};
our $IDEAL_IN_INTEGERS = {isValue => 1,
	type => Value::Type("IdealInIntegers",1),
	name => "IdealInIntegers",
};
our $ELEMENT_IN_CYCLIC_RING = {isValue => 1,
	type => Value::Type("CyclicRingElement",2),
	name => "CyclicRingElement",
};

#  Initialize the contexts and make the creator function.
#
sub Init {

  # copy the Numeric context
  my $context = $main::context{CyclicRing} = Parser::Context->getCopy("Numeric");
  $context->{name} = "CyclicRing";
  Parser::Number::NoDecimals($context);
  
  $context->flags->set(
	notation => "bar",    # notation ("bar" or "coset")
	autoreduce_representatives => 1,      # control whether representatives are reduced before comparing them
	autoreduce_sums_of_ideals => 1, # this applied to sums and subtractions
	autoreduce_products_of_ideals => 1,
  ); 
  
  $context->operators->clear();
  $context->operators->set(
    '+' => {class => 'context::CyclicRing::BOP::add',
	    type => "bin",
	    associativity => 'left',     #  computed left to right 
	    string => ' + ',             #  output string for it (default is the operator name with no spaces)
	    precedence => 1,
    },
    '-' => {class => 'context::CyclicRing::BOP::subtract',
	    type => "bin",
	    associativity => 'left',     #  computed left to right 
	    string => ' - ',             #  output string for it (default is the operator name with no spaces)
	    precedence => 1,
    },
    '*' => {class => 'context::CyclicRing::BOP::multiply',
	    type => "bin",
	    associativity => 'right',     #  computed right to left 
	    string => ' ',             #  output string for it (default is the operator name with no spaces)
	    precedence => 3,
    },
    ' ' => {class => 'context::CyclicRing::BOP::multiply',
	    type => "bin",
	    associativity => 'left',     #  computed left to right 
	    string => ' ',             #  output string for it (default is the operator name with no spaces)
	    precedence => 3,
    },
  );

  $context->functions->clear();
  $context->strings->clear();
  $context->constants->clear();
  $context->lists->clear();

  $context->constants->are( 
   'Z'  => {value => Value::RingOfIntegers->new(), isConstant => 1, string => "Z", perl => "Z", TeX => "\\mathbb{Z}"},
  );
 
  $context->reductions->clear();
  $context->flags->set(reduceConstants => 0);
  
  $context->{parser}{Number} = "context::CyclicRing::Number";
  $context->{parser}{Formula} = "context::CyclicRing";
 
  # Value classes
  $context->{value}{RingOfIntegers} = "Value::RingOfIntegers";
  $context->{value}{IdealInIntegers} = "Value::IdealInIntegers";
  $context->{value}{CyclicRingElement} = "Value::CyclicRingElement";

  # Precedence of value classes
  $context->{precedence}{RingOfIntegers} = $context->{precedence}{special};
  $context->{precedence}{IdealInIntegers} = $context->{precedence}{special}+1;
  $context->{precedence}{CyclicRingElement} = $context->{precedence}{special}+2;

  main::PG_restricted_eval('sub CyclicRingElement {Value->Package("CyclicRingElement()")->new(@_)};');
  main::PG_restricted_eval('sub RingOfIntegers {Value->Package("RingOfIntegers()")->new(@_)};');
  main::PG_restricted_eval('sub IdealInIntegers {Value->Package("IdealInIntegers()")->new(@_)};');
  main::PG_restricted_eval("sub multiplicative_inverse context::CyclicRing::Function::Numeric1::multiplicative_inverse(\@_)}");
}

sub TYPE {'an element of a cyclic ring'}
sub cmp_class {'an element of a cyclic ring'}

package context::CyclicRing::Function::Numeric1;
our @ISA = qw(Parser::Function::numeric); # checks for 1 numeric inputs


package context::CyclicRing::Function::Numeric2;
our @ISA = qw(Parser::Function::numeric2); # checks for 2 numeric inputs

package context::CyclicRing::BOP;
our @ISA = ('Parser::BOP');

#
#  Two nodes are equivalent if their operands are equivalent
#  and they have the same operator
#
sub equivalent {
  my $self = shift; my $other = shift;
  return 0 unless $other->class eq 'BOP';
  return 0 unless $self->{bop} eq $other->{bop};
  return $self->{lop}->equivalent($other->{lop}) && $self->{rop}->equivalent($other->{rop});
}

package context::CyclicRing::BOP::add;
our @ISA = ('context::CyclicRing::BOP');

#
#  Check that the operands are appropriate, and return
#  the proper type reference, or give an error.
#
sub _check {
  my $self = shift;

  my ($lop,$rop) = ($self->{lop},$self->{rop});
  my ($ltype,$rtype) = ($self->{lop}->typeRef,$self->{rop}->typeRef);
  my ($lname,$rname) = ($ltype->{name},$rtype->{name});
 
  warn "rname in check for add: ".$rname;
  warn "lname in check for add: ".$lname;

  if ( ($rname eq "Number" and $lname eq $IDEAL_IN_INTEGERS->{name}) ||
  	( $rname eq "Number" && $lname eq $ELEMENT_IN_CYCLIC_RING->{name} ) ||
        ( $rname eq $IDEAL_IN_INTEGERS->{name} && $lname eq $RING_OF_INTEGERS->{name} ) )
  {
        ($rop,$rtype,$rname,$lop,$ltype,$lname) = ($lop,$ltype,$lname,$rop,$rtype,$rname);
  }
  
  if ( $lname eq "Number" && $rname eq "Number" )
  {
	$self->{type} = $INTEGER->{type};
	$self->{name} = $INTEGER->{type};
  }
  elsif ( $lname eq "Number" && $rname eq $IDEAL_IN_INTEGERS->{name} )
  {
	  warn "check add number + ideal ";
	  warn "R in check for add: ".$rop->eval;
	  warn "L in check for add: ".$lop->eval;
	$self->{type} = $ELEMENT_IN_CYCLIC_RING->{type};
  }
  elsif ( $lname eq "Number" && $rname eq $ELEMENT_IN_CYCLIC_RING->{name} )
  {
	$self->{type} = $ELEMENT_IN_CYCLIC_RING->{type};
  }
  ## FIXME
  elsif ($lname eq $IDEAL_IN_INTEGERS->{name} and $rname eq $IDEAL_IN_INTEGERS->{name})
  {
	  warn "autored. sum of ideal flag:".$self->context->flag("autoreduce_sums_of_ideals");
	  if ($self->context->flag("autoreduce_sums_of_ideals") == 1)
	  {
		  $self->{type} = $IDEAL_IN_INTEGERS->{type};
	  }
	  else
	  {
		  $self->{equation}->Error(["You are not allowed to enter sums of ideals here."]);
	  }
  }
  elsif ( $lname eq "Number" && $rname eq $RING_OF_INTEGERS->{name} )
  {
	$self->{type} = $RING_OF_INTEGERS->{type};
  }
  elsif ( $lname eq $IDEAL_IN_INTEGERS->{name} && $rname eq $RING_OF_INTEGERS->{name} )
  {
	$self->{type} = $RING_OF_INTEGERS->{type};
  }
  else
  {
	warn "Cannot form this sum.";
	warn "Left type  in check for addis $ltype.";
	warn "Left type  in check for addname is $lname.";
	warn "lop  in check for addis $self->{lop}";
	warn "right type  in check for addis $rtype";
	warn "right type  in check for addname is $rname";
	warn "rop  in check for add is $self->{rop}";
  	$self->{equation}->Error(["Cannot form this sum here."]);
  }
}

sub _eval {
  my $self = shift;

  # Left Operator
  my $lop = $self->{lop};
  my $ltype = $self->{lop}->typeRef;
  my $lname = $ltype->{name};
  # Right Operator
  my $rop = $self->{rop};
  my $rtype = $self->{rop}->typeRef;
  my $rname = $rtype->{name};

  warn "parsing add...";
  warn "lname: ".$lname;
  warn "rname: ".$rname;
	warn "ll in parsing add: ".$lop->eval;
	warn "rr in parsing add: ".$rop->eval;
  
  if ( ($rname eq "Number" and $lname eq $IDEAL_IN_INTEGERS->{name}) ||
  	( $rname eq "Number" && $lname eq $ELEMENT_IN_CYCLIC_RING->{name} ) ||
        ( $rname eq $IDEAL_IN_INTEGERS->{name} && $lname eq $RING_OF_INTEGERS->{name} ) )
  {
        ($rop,$rtype,$rname,$lop,$ltype,$lname) = ($lop,$ltype,$lname,$rop,$rtype,$rname);
  }

  if ( $lname eq "Number" && $rname eq "Number" )
  {
	warn "adding two numbers: ";
	  warn "l: ".$self->{lop}->eval.", r:".$self->{rop}->eval;
	  return Value->Package("Real()")->new($self->{lop}->eval + $self->{rop}->eval);
  }
  elsif ($lname eq "Number" and $rname eq $IDEAL_IN_INTEGERS->{name})
  {
  	my $lvalue = $self->{lop}->eval;
	my $rvalue=$rop->eval->generator; # generator of the ideal
	warn "eval add: ";
	warn "lval: ".$lvalue;
	warn "rval: ".$rvalue;
	return $lop->eval + $rop->eval;
	#return Value->Package("CyclicRingElement()")->new($lvalue,$rvalue);
  }
  elsif ( $lname eq "Number" && $rname eq $ELEMENT_IN_CYCLIC_RING->{name} )
  {
  	my $lvalue = $self->{lop}->eval;
	my $r_rep = $rop->eval->representative; 
	my $r_order = $rop->eval->order; 

	return $lop->eval + $rop->eval;
	#return Value->Package("CyclicRingElement()")->new($lvalue + $r_rep, $r_order);
  }
  elsif ($lname eq "Number" and $rname eq $RING_OF_INTEGERS->{name})
  {
	return Value->Package("RingOfIntegers()")->new();
  }
  elsif ($lname eq $IDEAL_IN_INTEGERS->{name} and $rname eq $RING_OF_INTEGERS->{name})
  {
	return Value->Package("RingOfIntegers()")->new();
  }
  elsif ($lname eq $IDEAL_IN_INTEGERS->{name} and $rname eq $IDEAL_IN_INTEGERS->{name} )
  {
	  # FIXME
	  if ($self->context->flag("autoreduce_sums_of_ideals") == 1)
	  {
		  my $lvalue=$lop->eval->generator; # generator of the ideal
		  my $rvalue=$rop->eval->generator; # generator of the ideal
		  warn "lgen: ".$lvalue;
		  warn "rgen: ".$rvalue;
		  return $lop->eval + $rop->eval;
	  }
  }
}

package context::CyclicRing::BOP::subtract;
our @ISA = ('context::CyclicRing::BOP');

#
#  Check that the operands are appropriate, and return
#  the proper type reference, or give an error.
#
sub _check {
  my $self = shift;

  my ($lop,$rop) = ($self->{lop},$self->{rop});
  my ($ltype,$rtype) = ($self->{lop}->typeRef,$self->{rop}->typeRef);
  my ($lname,$rname) = ($ltype->{name},$rtype->{name});
  
  
  if ( $lname eq "Number" && $rname eq "Number" )
  {
	$self->{type} = $INTEGER->{type};
	$self->{name} = $INTEGER->{type};
  }
  elsif ( ( $lname eq "Number" && $rname eq $IDEAL_IN_INTEGERS->{name} ) ||
   ($rname eq "Number" and $lname eq $IDEAL_IN_INTEGERS->{name}) )
  {
	$self->{type} = $ELEMENT_IN_CYCLIC_RING->{type};
  }
  elsif ( ( $lname eq "Number" && $rname eq $ELEMENT_IN_CYCLIC_RING->{name} ) ||
  ( $rname eq "Number" && $lname eq $ELEMENT_IN_CYCLIC_RING->{name} ) )
  {
	$self->{type} = $ELEMENT_IN_CYCLIC_RING->{type};
  }
  elsif ($lname eq $IDEAL_IN_INTEGERS->{name} and $rname eq $IDEAL_IN_INTEGERS->{name})
  {
	  if ($self->context->flag("autoreduce_sums_of_ideals") == 1)
	  {
		  $self->{type} = $IDEAL_IN_INTEGERS->{type};
	  }
	  else
	  {
		  $self->{equation}->Error(["You are not allowed to enter a difference of ideals here."]);
	  }
  }
  elsif ( $lname eq "Number" && $rname eq $RING_OF_INTEGERS->{name} )
  {
	$self->{type} = $RING_OF_INTEGERS->{type};
  }
  else
  {
	warn "Cannot form this sum.";
	warn "Left type is $ltype.";
	warn "Left type name is $ltype->{name}.";
	warn "lop is $self->{lop}";
	warn "right type is $rtype";
	warn "right type name is $rtype->{name}";
	warn "rop is $self->{rop}";
  	$self->{equation}->Error(["Cannot form this subtraction here."]);
  }
}

sub _eval {
  my $self = shift;

  # Left Operator
  my $lop = $self->{lop};
  my $ltype = $self->{lop}->typeRef;
  my $lname = $ltype->{name};
  # Right Operator
  my $rop = $self->{rop};
  my $rtype = $self->{rop}->typeRef;
  my $rname = $rtype->{name};

  if ( $lname eq "Number" && $rname eq "Number" )
  {
	return $self->{lop}->eval - $self->{rop}->eval;
  }
  elsif ( ($lname eq "Number" and $rname eq $IDEAL_IN_INTEGERS->{name}) ||
   ($rname eq "Number" and $lname eq $IDEAL_IN_INTEGERS->{name}) )
  {
  	my $lvalue = $self->{lop}->eval; # FIXME
	my $rvalue = $rop->eval->generator; # generator of the ideal
	return Value->Package("CyclicRingElement()")->new($lvalue,$rvalue);
  }
  elsif ( ( $lname eq "Number" && $rname eq $ELEMENT_IN_CYCLIC_RING->{name} ) ||
  ( $rname eq "Number" && $lname eq $ELEMENT_IN_CYCLIC_RING->{name} ) )
  {
	return $lop->eval - $rop->eval;
  }
  elsif ($lname eq "Number" and $rname eq $RING_OF_INTEGERS->{name})
  {
	return Value->Package("RingOfIntegers()")->new();
  }
  elsif ($lname eq $IDEAL_IN_INTEGERS->{name} and $rname eq $IDEAL_IN_INTEGERS->{name} and $self->context->flag("autoreduce_sums_of_ideals") == 1)
  {
  	# FIXME
  	if ($self->context->flag("autoreduce_sums_of_ideals") == 1)
  	{
  	        return $lop->eval - $rop->eval;
  	}
  }
}

package context::CyclicRing::BOP::multiply;
our @ISA = ('context::CyclicRing::BOP');

sub _check {
  my $self = shift;

  # Left Operator
  my $ltype = $self->{lop}->typeRef;
  my $lname = $ltype->{name};
  my $lop = $self->{lop} ;
  # Right Operator
  my $rtype = $self->{rop}->typeRef;
  my $rname = $rtype->{name};
  my $rop = $self->{rop} ;
  warn "check mult:"; 
  warn "ltype in check mult: ".$ltype;
  warn "rtype in check mult: ".$rtype;
  warn "lname in check mult: ".$lname;
  warn "rname in check mult: ".$rname;
  warn "lop in check mult: ".$lop;
  warn "rop in check mult: ".$rop;

  if ($lname eq "Number" and $rname eq "Number")
  {
	$self->{type} = $INTEGER->{type};
	$self->{name} = $INTEGER->{type};
  }
  elsif ($lname eq "Number" and $rname eq $RING_OF_INTEGERS->{name})
  {
	  $self->{type} = $IDEAL_IN_INTEGERS->{type};
	  $self->{name} = $IDEAL_IN_INTEGERS->{name};
  }
  elsif ($lname eq "Number" and $rname eq $IDEAL_IN_INTEGERS->{name})
  {
	  $self->{type} = $IDEAL_IN_INTEGERS->{type};
	  $self->{name} = $IDEAL_IN_INTEGERS->{name};
  }
  elsif ($lname eq "Number" and $rname eq $ELEMENT_IN_CYCLIC_RING->{name})
  {
	  $self->{type} = $ELEMENT_IN_CYCLIC_RING->{type};
	  $self->{name} = $ELEMENT_IN_CYCLIC_RING->{name};
  }
  elsif ($lname eq $IDEAL_IN_INTEGERS->{name} and $rname eq $IDEAL_IN_INTEGERS->{name})
  {
	  if ($self->context->flag("autoreduce_products_of_ideals") == 1)
	  {
		$self->{type} = $IDEAL_IN_INTEGERS->{type};
		$self->{name} = $IDEAL_IN_INTEGERS->{name};
	  }
	  else
	  {
		  $self->{equation}->Error(["You are not allowed to enter products of ideals here."]);
	  }
  }
  else
  {
	warn "Cannot form this product.";
	warn "Left type is $ltype.";
	warn "Left type name is $ltype->{name}.";
	warn "lop is $self->{lop}";
	warn "right type is $rtype";
	warn "right type name is $rtype->{name}";
	warn "rop is $self->{rop}";
  	$self->{equation}->Error(["Cannot form this product here."]);
  }
}

sub _eval {
  my $self = shift;


  my $lop = $self->{lop};
  my $rop = $self->{rop};
  # Left Operator
  my $ltype = $self->{lop}->typeRef;
  my $lname = $ltype->{name};
  # Right Operator
  my $rtype = $self->{rop}->typeRef;
  my $rname = $rtype->{name};

  warn "eval of BOP:multiply ...";
  warn "rname: ".$rname;
  warn "lname: ".$lname;

  if ($lname eq "Number" and $rname eq "Number")
  {
	warn "multiplying two numbers: ";
	  warn "l: ".$self->{lop}->eval.", r:".$self->{rop}->eval;
	  my $prod = Value->Package("Real()")->new($self->{lop}->eval * $self->{rop}->eval);
	  warn "prod: ".$prod;
	  return $prod; 
  }
  elsif ($lname eq "Number" and $rname eq "RingOfIntegers") {
  	my $lvalue = $lop->eval;
	return Value->Package("IdealInIntegers()")->new($lvalue);
  }
  elsif ($lname eq "Number" and $rname eq "IdealInIntegers")
  {
  	my $lvalue = $lop->eval;
  	my $rvalue = $rop->eval->generator;
	return Value->Package("IdealInIntegers()")->new($lvalue * $rvalue);
  }
  elsif ($lname eq "Number" and $rname eq $ELEMENT_IN_CYCLIC_RING->{name})
  {
	warn "mult. of number and cyclic ring element...";
  	my $lvalue = $lop->eval;
  	my $rvalue = $rop->eval->representative;
	return Value->Package("CyclicRingElement()")->new($lvalue * $rvalue, $rop->eval->order);
  }
  ## FIXME
  elsif ($lname eq $IDEAL_IN_INTEGERS->{name} and $rname eq $IDEAL_IN_INTEGERS->{name} and $self->context->flag("autoreduce_products_of_ideals") == 1)
  {
	warn "multiply two ideals...";
	return ($lop->eval)->mult($rop->eval);
  }
}

#
#  No space in output for implied multiplication
#
sub string {
  my $self = shift;
  return $self->{lop}->string.$self->{rop}->string;
}
sub TeX {
  my $self = shift;
  my $lop = $self->{lop};
  my $rop = $self->{rop};
  # Left Operator
  my $ltype = $self->{lop}->typeRef;
  my $lname = $ltype->{name};
  # Right Operator
  my $rtype = $self->{rop}->typeRef;
  my $rname = $rtype->{name};
  warn "lname in TeX: ".$lname;
  warn "rname in TeX: ".$rname;
  if ($lname eq "Number" and $rname eq "Number") {
	  return $lop->TeX."\\cdot".$rop->TeX;
  }
  elsif ($lname eq "Number" and $rname eq "CyclicRingElement") {
	  return $lop->TeX."(".$rop->TeX.")";
  }
  elsif ($lname eq "Number" and $rname eq "IdealInIntegers") {
	  return $lop->TeX."\\cdot".$rop->TeX;
  }
  else {
	  return $lop->TeX.$rop->TeX;
  }
}


package context::CyclicRing::Number;
our @ISA = ('Parser::Number');

#
#  Equivalent is equal
#
sub equivalent {
  my $self = shift; my $other = shift;
  return 0 unless $other->class eq 'Number';
  return $self->eval == $other->eval;
}

sub class {'Number'}
sub TYPE {'a Number'}

sub _check {
  my $self = shift;
  $self->{type} = Value::Type("Number");
}

1;
