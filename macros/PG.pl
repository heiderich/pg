#!/usr/local/bin/webwork-perl

#	This file provided the fundamental macros for the pg language
#	These macros define the interface between the problems written by
#	the professor and the processing which occurs in the script
#	processProblem.pl


BEGIN {
	be_strict();
}

sub _PG_init{

}

#package PG;


=head1 NAME

	PG.pl --- located in the courseScripts directory.
	Defines the Program Generating language at the most basic level.

=head1 SYNPOSIS

	The basic PG problem structure:

	DOCUMENT();          # should be the first statment in the problem
	loadMacros(.....);   # (optional) load other macro files if needed.
	                     # (loadMacros is defined in F<dangerousMacros.pl>)

	HEADER_TEXT(...);    # (optional) used only for inserting javaScript into problems.

	# 					 #	insert text of problems
	TEXT("Problem text to be",
	     "displayed. Enter 1 in this blank:",
	     ANS_RULE(1,30)  #	ANS_RULE() defines an answer blank 30 characters long.
	                     #  It is defined in F<PGbasicmacros.pl>
	     );


	ANS( answer_evalutors);  # see F<PGanswermacros.pl> for examples of answer evaluatiors.

	ENDDOCUMENT()        # must be the last statement in the problem



=head1 DESCRIPTION

As described in the synopsis, this file and the macros C<DOCUMENT()> and C<ENDDOCUMENT()> determine
the interface between problems written in the PG language and the rest of B<WeBWorK>, in particular
the subroutine C<createPGtext(()> in the file F<translate.pl>.

C<DOCUMENT()> must be the first statement in each problem template.
It  initializes variables,
in particular all of the contents of the
environment variable  become defined in the problem enviroment.
(See
L</webwork_system_html/docs/techdescription/pglanguage/PGenvironment.html>)

ENDDOCUMENT() must the last executable statement in any problem template.  It returns
the rendered problem, answer evaluators and other flags to the rest of B<WeBWorK>, specificially
to the routine C<createPGtext()> defined in F<translate.pl>


The C<HEADER_TEXT()>, C<TEXT()>, and C<ANS()> functions load the
header text string, the problem text string.
and the answer evaulator queue respectively.


=cut


#  Private variables for the PG.pl file.

my ($STRINGforOUTPUT, $STRINGforHEADER_TEXT, @PG_ANSWERS, @PG_UNLABELED_ANSWERS);
my %PG_ANSWERS_HASH ;

#  	DOCUMENT must come early in every .pg file, before any answers or text are
#	defined.  It initializes the variables.
#	It can appear only once.

=head2 DOCUMENT()

C<DOCUMENT()> must be the first statement in each problem template.  It can
only be used once in each problem.

C<DOCUMENT()> initializes some empty variables and via C<INITIALIZE_PG()> unpacks the
variables in the C<%envir> variable which is implicitly passed to the problem. It must
be the first statement in any problem template. It
also unpacks any answers submitted and places them in the C<@submittedAnswer> list,
saves the problem seed in C<$PG_original_problemSeed> in case you need it later, and
initializes the pseudo random number generator object in C<$PG_random_generator>.

You can reset the standard number generator using the command:

	$PG_random_generator->srand($new_seed_value);

(See also C<SRAND> in the L<PGbasicmacros.pl> file.)

The
environment variable contents is defined in
L</webwork_system_html/docs/techdescription/pglanguage/PGenvironment.html>


=cut

sub DOCUMENT {
	$STRINGforOUTPUT ="";
    $STRINGforHEADER_TEXT ="";
	@PG_ANSWERS=();
	@main::PG_ANSWER_ENTRY_ORDER = ();
	@PG_UNLABELED_ANSWERS = ();
	%PG_ANSWERS_HASH = ();
	$main::ANSWER_PREFIX = 'AnSwEr';
	%main::PG_FLAGS=();  #global flags
	$main::showPartialCorrectAnswers = 0 unless defined($main::showPartialCorrectAnswers );
	$main::showHint = 1 unless defined($main::showHint);
	$main::solutionExists =0;
	$main::hintExists =0;
	%main::gifs_created = ();

	die "The environment variable envir has not been defined" unless defined(%main::envir);

   	foreach my $var ( keys %main::envir ) {
       eval("\$main::$var =\$main::envir{'$var'}");
   	   warn "Problem defining ", q{\$main::$var}, " while inititializing the PG problem: $@" if $@;
    }

	@main::submittedAnswers = @{$main::refSubmittedAnswers} if defined($main::refSubmittedAnswers);
	$main::PG_original_problemSeed = $main::problemSeed;
	$main::PG_random_generator = new PGrandom($main::problemSeed) || die "Can't create random number generator.";
	$main::ans_rule_count = 0;  # counts questions

  	# end unpacking of environment variables.
}

#	HEADER_TEXT is for material which is destined to be placed in the header of the html problem -- such
#   as javaScript code.

=head2 HEADER_TEXT()


	HEADER_TEXT("string1", "string2", "string3");

The C<HEADER_TEXT()>
function concatenates its arguments and places them in the output
header text string.  It is used for material which is destined to be placed in
the header of the html problem -- such as javaScript code.
 It can be used more than once in a file.


=cut

sub HEADER_TEXT {
	my @in = @_;
	$STRINGforHEADER_TEXT .= join(" ",@in);
	}

#	TEXT is the function which defines text which will appear in the problem.
#	All text must be an argument to this function.  Any other statements
# 	are calculations (done in perl) which will not directly appear in the
#	output.  Think of this as the "print" function for the .pg language.
#	It can be used more than once in a file.

=head2 TEXT()

	TEXT("string1", "string2", "string3");

The C<TEXT()> function concatenates its arguments and places them in the output
text string. C<TEXT()> is the function which defines text which will appear in the problem.
All text must be an argument to this function.  Any other statements
are calculations (done in perl) which will not directly appear in the
output.  Think of this as the "print" function for the .pg language.
It can be used more than once in a file.

=cut

sub TEXT {
	my @in = @_;
	$STRINGforOUTPUT .= join(" ",@in);
	}



=head2 ANS()

	ANS(answer_evaluator1, answer_evaluator2, answer_evaluator3,...)

Places the answer evaluators in the unlabeled answer_evaluator queue.  They will be paired
with unlabeled answer rules (answer entry blanks) in the order entered.  This is the standard
method for entering answers.

	LABELED_ANS(answer_evaluater_name1, answer_evaluator1, answer_evaluater_name2,answer_evaluator2,...)

Places the answer evaluators in the labeled answer_evaluator hash.  This allows pairing of
labeled answer evaluators and labeled answer rules which may not have been entered in the same
order.

=cut

sub ANS{             # store answer evaluators which have not been explicitly labeled
  my @in = @_;
  while (@in ) {
         warn("<BR><B>Error in ANS:$in[0]</B> -- inputs must be references to
                      subroutines<BR>")
			unless ref($in[0]);
    	push(@PG_ANSWERS, shift @in );
    	}
}
sub LABELED_ANS {  #a better alias for NAMED_ANS
	&NAMED_ANS;
}

sub NAMED_ANS{     # store answer evaluators which have been explicitly labeled (submitted in a hash)
  my @in = @_;
  while (@in ) {
  	my $label = shift @in;
  	my $ans_eval = shift @in;
  	TEXT("<BR><B>Error in NAMED_ANS:$in[0]</B>
  	      -- inputs must be references to subroutines<BR>")
			unless ref($ans_eval);
  	$PG_ANSWERS_HASH{$label}= $ans_eval;
  }
}
sub RECORD_ANS_NAME {     # this maintains the order in which the answer rules are printed.
	my $label = shift;
	push(@main::PG_ANSWER_ENTRY_ORDER, $label);
	$label;
}

sub NEW_ANS_NAME {        # this keeps track of the answers which are entered implicitly,
                          # rather than with a specific label
		my $number=shift;
		my $label = "$main::ANSWER_PREFIX$number";
		push(@PG_UNLABELED_ANSWERS,$label);
		$label;
}
sub ANS_NUM_TO_NAME {     # This converts a number to an answer label for use in
                          # radio button and check box answers. No new answer
                          # name is recorded.
		my $number=shift;
		my $label = "$main::ANSWER_PREFIX$number";
		$label;
}

my $vecnum;

sub NEW_ANS_ARRAY_NAME {        # this keeps track of the answers which are entered implicitly,
                          # rather than with a specific label
		my $number=shift;
		$vecnum = 0;
		my $row = shift;
		my $col = shift;
		my $label = "ArRaY"."$number"."["."$vecnum".","."$row".","."$col"."]";
		push(@PG_UNLABELED_ANSWERS,$label);
		$label;
}

sub NEW_ANS_ARRAY_NAME_EXTENSION {        # this keeps track of the answers which are entered implicitly,
                          # rather than with a specific label
		my $number=shift;
		my $row = shift;
		my $col = shift;
		if( $row == 0 && $col == 0 ){
			$vecnum += 1;		
		}
		my $label = "ArRaY"."$number"."["."$vecnum".","."$row".","."$col"."]";
		$label;
}

#	ENDDOCUMENT must come at the end of every .pg file.
#   It exports the resulting text of the problem, the text to be used in HTML header material
#   (for javaScript), the list of answer evaluators and any other flags.  It can appear only once and
#   it MUST be the last statement in the problem.

=head2 ENDDOCUMENT()

ENDDOCUMENT() must the last executable statement in any problem template.  It can
only appear once.  It returns
an array consisting of

	A reference to a string containing the rendered text of the problem.
	A reference to a string containing text to be placed in the header
	             (for javaScript)
	A reference to the array containing the answer evaluators.
	             (May be changed to a hash soon.)
	A reference to an associative array (hash) containing various flags.

	The following flags are set by ENDDOCUMENT:
	(1) showPartialCorrectAnswers  -- determines whether students are told which
	    of their answers in a problem are wrong.
	(2) recordSubmittedAnswers  -- determines whether students submitted answers
	    are saved.
	(3) refreshCachedImages  -- determines whether the cached image of the problem
	    in typeset mode is always refreshed (i.e. setting this to 1 means cached
	    images are not used).
	(4) solutionExits   -- indicates the existence of a solution.
	(5) hintExits   -- indicates the existence of a hint.
	(6) showHintLimit -- determines the number of attempts after which hint(s) will be shown

	(7) PROBLEM_GRADER_TO_USE -- chooses the problem grader to be used in this order
		(a) A problem grader specified by the problem using:
		    install_problem_grader(\&grader);
		(b) One of the standard problem graders defined in PGanswermacros.pl when set to
		    'std_problem_grader' or 'avg_problem_grader' by the environment variable
		    $PG_environment{PROBLEM_GRADER_TO_USE}
		(c) A subroutine referenced by $PG_environment{PROBLEM_GRADER_TO_USE}
		(d) The default &std_problem_grader defined in PGanswermacros.pl


=cut

sub ENDDOCUMENT {

    my $index=0;
    foreach my $label (@PG_UNLABELED_ANSWERS) {
        if ( defined($PG_ANSWERS[$index]) ) {
    		$PG_ANSWERS_HASH{"$label"}= $PG_ANSWERS[$index];
    	} else {
    		warn "No answer provided by instructor for answer $label";
    	}
    	$index++;
    }

    $STRINGforOUTPUT .="\n";
   ##eval q{  #make sure that "main" points to the current safe compartment by evaluating these lines.
		$main::PG_FLAGS{'showPartialCorrectAnswers'} = $main::showPartialCorrectAnswers;
		$main::PG_FLAGS{'recordSubmittedAnswers'} = $main::recordSubmittedAnswers;
		$main::PG_FLAGS{'refreshCachedImages'} = $main::refreshCachedImages;
		$main::PG_FLAGS{'hintExists'} = $main::hintExists;
		$main::PG_FLAGS{'showHintLimit'} = $main::showHint;
		$main::PG_FLAGS{'solutionExists'} = $main::solutionExists;
		$main::PG_FLAGS{ANSWER_ENTRY_ORDER} = \@main::PG_ANSWER_ENTRY_ORDER;
		$main::PG_FLAGS{ANSWER_PREFIX} = $main::ANSWER_PREFIX;
		# install problem grader
		if (defined($main::PG_FLAGS{PROBLEM_GRADER_TO_USE}) ) {
			# problem grader defined within problem -- no further action needed
		} elsif ( defined( $main::envir{PROBLEM_GRADER_TO_USE} ) ) {
			if (ref($main::envir{PROBLEM_GRADER_TO_USE}) eq 'CODE' ) {         # user defined grader
				$main::PG_FLAGS{PROBLEM_GRADER_TO_USE} = $main::envir{PROBLEM_GRADER_TO_USE};
			} elsif ($main::envir{PROBLEM_GRADER_TO_USE} eq 'std_problem_grader' ) {
				if (defined(&std_problem_grader) ){
					$main::PG_FLAGS{PROBLEM_GRADER_TO_USE} = \&std_problem_grader; # defined in PGanswermacros.pl
				} # std_problem_grader is the default in any case so don't give a warning.
			} elsif ($main::envir{PROBLEM_GRADER_TO_USE} eq 'avg_problem_grader' ) {
				if (defined(&avg_problem_grader) ){
					$main::PG_FLAGS{PROBLEM_GRADER_TO_USE} = \&avg_problem_grader; # defined in PGanswermacros.pl
				}
				#else { # avg_problem_grader will be installed by PGtranslator so there is no need for a warning.
				#	warn "The problem grader 'avg_problem_grader' has not been defined.  Has PGanswermacros.pl been loaded?";
				#}
			} else {
				warn "Error:  $main::PG_FLAGS{PROBLEM_GRADER_TO_USE} is not a known program grader.";
			}
		} elsif (defined(&std_problem_grader)) {
			$main::PG_FLAGS{PROBLEM_GRADER_TO_USE} = \&std_problem_grader; # defined in PGanswermacros.pl
		} else {
			# PGtranslator will install its default problem grader
		}
	##};
    warn "ERROR: The problem grader is not a subroutine" unless ref( $main::PG_FLAGS{PROBLEM_GRADER_TO_USE}) eq 'CODE'
										 or $main::PG_FLAGS{PROBLEM_GRADER_TO_USE} = 'std_problem_grader'
										 or $main::PG_FLAGS{PROBLEM_GRADER_TO_USE} = 'avg_problem_grader';
     # return results
	(\$STRINGforOUTPUT, \$STRINGforHEADER_TEXT,\%PG_ANSWERS_HASH,\%main::PG_FLAGS);
}



=head2 INITIALIZE_PG()

This is executed each C<DOCUMENT()> is called.  For backward compatibility
C<loadMacros> also checks whether the C<macroDirectory> has been defined
and if not, it runs C<INITIALIZE_PG()> and issues a warning.

=cut


1;