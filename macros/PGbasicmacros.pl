

####################################################################
# Copyright @ 1995-1998 University of Rochester
# All Rights Reserved
####################################################################

=head1 NAME

	  PGbasicmacros.pl --- located in the courseScripts directory

=head1 SYNPOSIS



=head1 DESCRIPTION



=cut

# this is equivalent to use strict, but can be used within the Safe compartment.
BEGIN{
	be_strict;
}


my $displayMode=$main::displayMode;

my ($PAR,
	$BR,
	$LQ,
	$RQ,
	$BM,
	$EM,
	$BDM,
	$EDM,
	$LTS,
	$GTS,
	$LTE,
	$GTE,
	$BEGIN_ONE_COLUMN,
	$END_ONE_COLUMN,
	$SOL,
	$SOLUTION,
	$HINT,
	$US,
	$SPACE,
	$BBOLD,
	$EBOLD,
	$BITALIC,
	$EITALIC,
	$BCENTER,
	$ECENTER,
	$HR,
	$LBRACE,
	$RBRACE,
	$LB,
	$RB,
	$DOLLAR,
	$PERCENT,
	$CARET,
	$PI,
	$E,
	@ALPHABET,
	);

sub _PGbasicmacros_init {
    $displayMode    =$main::displayMode;
	$main::PAR				= PAR();
	$main::BR				= BR();
	$main::LQ				= LQ();
	$main::RQ				= RQ();
	$main::BM				= BM();
	$main::EM				= EM();
	$main::BDM				= BDM();
	$main::EDM				= EDM();
	$main::LTS				= LTS();
	$main::GTS				= GTS();
	$main::LTE				= LTE();
	$main::GTE				= GTE();
	$main::BEGIN_ONE_COLUMN	= BEGIN_ONE_COLUMN();
	$main::END_ONE_COLUMN	= END_ONE_COLUMN();
	$main::SOL				= SOLUTION_HEADING();
	$main::SOLUTION			= SOLUTION_HEADING();
	$main::HINT				= HINT_HEADING();
	$main::US				= US();
	$main::SPACE			= SPACE();
	$main::BBOLD			= BBOLD();
	$main::EBOLD			= EBOLD();
	$main::BITALIC			= BITALIC();
	$main::EITALIC          = EITALIC();
	$main::BCENTER          = BCENTER();
	$main::ECENTER          = ECENTER();
	$main::HR				= HR();
	$main::LBRACE			= LBRACE();
	$main::RBRACE			= RBRACE();
	$main::LB				= LB();
	$main::RB				= RB();
	$main::DOLLAR			= DOLLAR();
	$main::PERCENT			= PERCENT();
	$main::CARET			= CARET();
	$main::PI				= PI();
	$main::E				= E();
	@main::ALPHABET			= ('A'..'ZZ');

	$PAR				= PAR();
	$BR				= BR();
	$LQ				= LQ();
	$RQ				= RQ();
	$BM				= BM();
	$EM				= EM();
	$BDM				= BDM();
	$EDM				= EDM();
	$LTS				= LTS();
	$GTS				= GTS();
	$LTE				= LTE();
	$GTE				= GTE();
	$BEGIN_ONE_COLUMN	= BEGIN_ONE_COLUMN();
	$END_ONE_COLUMN	= END_ONE_COLUMN();
	$SOL				= SOLUTION_HEADING();
	$SOLUTION			= SOLUTION_HEADING();
	$HINT				= HINT_HEADING();
	$US				= US();
	$SPACE			= SPACE();
	$BBOLD			= BBOLD();
	$EBOLD			= EBOLD();
	$HR				= HR();
	$LBRACE			= LBRACE();
	$RBRACE			= RBRACE();
	$LB				= LB();
	$RB				= RB();
	$DOLLAR			= DOLLAR();
	$PERCENT			= PERCENT();
	$CARET			= CARET();
	$PI				= PI();
	$E				= E();
	@ALPHABET			= ('A'..'ZZ');



}

=head2  Answer blank macros:

These produce answer blanks of various sizes or pop up lists or radio answer buttons.
The names for the answer blanks are
generated implicitly.

	ans_rule( width )
	tex_ans_rule( width )
	ans_radio_buttons(value1=>label1, value2,label2 => value3,label3=>...)
	pop_up_list(@list)  # list consists of (value => label,  PR => "Product rule",...)

To indicate the checked position of radio buttons put a '%' in front of the value: C<ans_radio_buttons(1, 'Yes','%2','No')>
will have 'No' checked.  C<tex_ans_rule> works inside math equations in C<HTML_tth> mode.  It does not work in C<Latex2HTML> mode
since this mode produces gif pictures.


The following method is defined in F<PG.pl> for entering the answer evaluators corresponding
to answer rules with automatically generated names.  The answer evaluators are matched with the
answer rules in the order in which they appear on the page.

	ANS(ans_evaluator1, ans_evaluator2,...);

These are more primitive macros which produce answer blanks for specialized cases when complete
control over the matching of answers blanks and answer evaluators is desired.
The names of the answer blanks must be generated manually, and it is best if they do NOT begin
with the default answer prefix (currently AnSwEr).

	labeled_ans_rule(name, width)  # an alias for NAMED_ANS_RULE where width defaults to 20 if omitted.

	NAMED_ANS_RULE(name, width)
	NAMED_ANS_BOX(name, rows, cols)
	NAMED_ANS_RADIO(name, value,label,)
	NAMED_ANS_RADIO_EXTENSION(name, value,label)
	NAMED_ANS_RADIO_BUTTONS(name,value1,label1,value2,label2,...)
	check_box('-name' =>answer5,'-value' =>'statement3','-label' =>'I loved this course!'   )
	NAMED_POP_UP_LIST($name, @list) # list consists of (value => tag,  PR => "Product rule",...)

(Name is the name of the variable, value is the value given to the variable when this option is selected,
and label is the text printed next to the button or check box.    Check box variables can have multiple values.)

NAMED_ANS_RADIO_BUTTONS creates a sequence of NAMED_ANS_RADIO and NAMED_ANS_RADIO_EXTENSION  items which
are  output either as an array or, in scalar context, as the array glued together with spaces.  It is
usually easier to use this than to manually construct the radio buttons by hand.  However, sometimes
 extra flexibility is desiredin which case:

When entering radio buttons using the "NAMED" format, you should use NAMED_ANS_RADIO button for the first button
and then use NAMED_ANS_RADIO_EXTENSION for the remaining buttons.  NAMED_ANS_RADIO requires a matching answer evalutor,
while NAMED_ANS_RADIO_EXTENSION does not. The name used for NAMED_ANS_RADIO_EXTENSION should match the name
used for NAMED_ANS_RADIO (and the associated answer evaluator).


The following method is defined in  F<PG.pl> for entering the answer evaluators corresponding
to answer rules with automatically generated names.  The answer evaluators are matched with the
answer rules in the order in which they appear on the page.

      NAMED_ANS(name1 => ans_evaluator1, name2 => ans_evaluator2,...);

These auxiliary macros are defined in PG.pl


	NEW_ANS_NAME( number );   # produces a new answer blank name from a number by adding a prefix (AnSwEr)
	                          # and registers this name as an implicitly labeled answer
	                          # Its use is paired with each answer evaluator being entered using ANS()

    ANS_NUM_TO_NAME(number);  # adds the prefix (AnSwEr) to the number, but does nothing else.

	RECORD_ANS_NAME( name );  # records the order in which the answer blank  is rendered
	                          # This is called by all of the constructs above, but must
	                          # be called explicitly if an input blank is constructed explictly
	                          # using HTML code.

These are legacy macros:

	ANS_RULE( number, width );				        	# equivalent to NAMED_ANS_RULE( NEW_ANS_NAME(number), width)
	ANS_BOX( question_number,height, width ); 		 	# equivalent to NAMED_ANS_BOX( NEW_ANS_NAME(number), height, width)
	ANS_RADIO( question_number, value,tag );		    # equivalent to NAMED_ANS_RADIO( NEW_ANS_NAME(number), value,tag)
	ANS_RADIO_OPTION( question_number, value,tag ); 	# equivalent to NAMED_ANS_RADIO_EXTENSION( ANS_NUM_TO_NAME(number), value,tag)


=cut

sub labeled_ans_rule {   # syntactic sugar for NAMED_ANS_RULE
	my($name,$col) = @_;
	$col = 20 unless defined($col);
	NAMED_ANS_RULE($name,$col);
}

sub NAMED_ANS_RULE {
	my($name,$col) = @_;
	my $len = 0.07*$col;
	my $answer_value = '';
	$answer_value = ${$main::inputs_ref}{$name} if    defined(${$main::inputs_ref}{$name});
    if ($answer_value =~ /\0/ ) {
    	my @answers = split("\0", $answer_value);
    	$answer_value = shift(@answers);  # use up the first answer
    	$main::rh_sticky_answers{$name}=\@answers;  # store the rest
    	$answer_value= '' unless defined($answer_value);
	} elsif (ref($answer_value) eq 'ARRAY') {
		my @answers = @{ $answer_value};
    	$answer_value = shift(@answers);  # use up the first answer
    	$main::rh_sticky_answers{$name}=\@answers;  # store the rest
    	$answer_value= '' unless defined($answer_value);
	}

	$answer_value =~ tr/$@`//d;   ## make sure student answers can not be interpolated by e.g. EV3
	$name = RECORD_ANS_NAME($name);
	MODES(
		TeX => "\\mbox{\\parbox[t]{10pt}{\\hrulefill}}\\hrulefill\\quad ",
		Latex2HTML => qq!\\begin{rawhtml}\n<INPUT TYPE=TEXT SIZE=$col NAME=\"$name\" VALUE = \"\">\n\\end{rawhtml}\n!,
		HTML => "<INPUT TYPE=TEXT SIZE=$col NAME=\"$name\" VALUE = \"$answer_value\">\n"
	);
}

sub NAMED_ANS_RULE_OPTION {   # deprecated
	&NAMED_ANS_RULE_EXTENSION;
}

sub NAMED_ANS_RULE_EXTENSION {
	my($name,$col) = @_;
	my $len = 0.07*$col;
	my $answer_value = '';
	$answer_value = ${$main::inputs_ref}{$name} if defined(${$main::inputs_ref}{$name});
	if ( defined($main::rh_sticky_answers{$name}) ) {
		$answer_value = shift( @{$main::rh_sticky_answers{$name}});
		$answer_value = '' unless defined($answer_value);
	}
	$answer_value =~ tr/$@//d;   ## make sure student answers can not be interpolated by e.g. EV3
	MODES(
		TeX => '\\hrulefill\\quad ',
		Latex2HTML => qq!\\begin{rawhtml}\n<INPUT TYPE=TEXT SIZE=$col NAME=\"$name\" VALUE = \"\">\n\\end{rawhtml}\n!,
		HTML => qq!<INPUT TYPE=TEXT SIZE=$col NAME = "$name" VALUE = "$answer_value">\n!
	);
}

sub ANS_RULE {  #deprecated
	my($number,$col) = @_;
	my $name = NEW_ANS_NAME($number);
    NAMED_ANS_RULE($name,$col);
}


sub  NAMED_ANS_BOX {
	my($name,$row,$col) = @_;
	$row = 10 unless defined($row);
	$col = 80 unless defined($col);
	$name = RECORD_ANS_NAME($name);
	my $len = 0.07*$col;
	my $height = .07*$row;
	my $answer_value = '';
	$answer_value = $main::inputs_ref->{$name} if defined( $main::inputs_ref->{$name} );
	$answer_value =~ tr/$@//d;   ## make sure student answers can not be interpolated by e.g. EV3
	my $out = M3(
	     qq!\\vskip $height in \\hrulefill\\quad !,
	     qq!\\begin{rawhtml}<TEXTAREA NAME="$name" ROWS="$row" COLS="$col"
               WRAP="VIRTUAL">$answer_value</TEXTAREA>\\end{rawhtml}!,
         qq!<TEXTAREA NAME="$name" ROWS="$row" COLS="$col"
               WRAP="VIRTUAL">$answer_value</TEXTAREA>!
         );
	$out;
}

sub  ANS_BOX { #deprecated
	my($number,$row,$col) = @_;
	my $name = NEW_ANS_NAME($number);
    NAMED_ANS_BOX($name,$row,$col);
}

sub NAMED_ANS_RADIO {
	my $name = shift;
	my $value = shift;
    my $tag =shift;
    $name = RECORD_ANS_NAME($name);
    my $checked = '';
    if ($value =~/^\%/) {
    	$value =~ s/^\%//;
    	$checked = 'CHECKED'
    }
	if (defined($main::inputs_ref->{$name}) ) {
		if ($main::inputs_ref->{$name} eq $value) {
			$checked = 'CHECKED'
		} else {
			$checked = '';
		}

    }

	MODES(
		TeX => qq!\\item{$tag}\n!,
		Latex2HTML => qq!\\begin{rawhtml}\n<INPUT TYPE=RADIO NAME="$name" VALUE="$value" $checked>\\end{rawhtml}$tag!,
		HTML => qq!<INPUT TYPE=RADIO NAME="$name" VALUE="$value" $checked>$tag!
	);

}

sub NAMED_ANS_RADIO_OPTION { #deprecated
	&NAMED_ANS_RADIO_EXTENSION;
}

sub NAMED_ANS_RADIO_EXTENSION {
	my $name = shift;
	my $value = shift;
	my $tag =shift;


    my $checked = '';
    if ($value =~/^\%/) {
    	$value =~ s/^\%//;
    	$checked = 'CHECKED'
    }
	if (defined($main::inputs_ref->{$name}) ) {
		if ($main::inputs_ref->{$name} eq $value) {
			$checked = 'CHECKED'
		} else {
			$checked = '';
		}

    }

	MODES(
		TeX => qq!\\item{$tag}\n!,
		Latex2HTML => qq!\\begin{rawhtml}\n<INPUT TYPE=RADIO NAME="$name" VALUE="$value" $checked>\\end{rawhtml}$tag!,
		HTML => qq!<INPUT TYPE=RADIO NAME="$name" VALUE="$value" $checked>$tag!
	);

}

sub NAMED_ANS_RADIO_BUTTONS {
    my $name  =shift;
    my $value = shift;
    my $tag = shift;


	my @out = ();
	push(@out, NAMED_ANS_RADIO($name, $value,$tag));
	my @buttons = @_;
	while (@buttons) {
		$value = shift @buttons;  $tag = shift @buttons;
		push(@out, NAMED_ANS_RADIO_OPTION($name, $value,$tag));
	}
	(wantarray) ? @out : join(" ",@out);
}
sub ANS_RADIO {
	my $number = shift;
	my $value = shift;
	my $tag =shift;
    my $name = NEW_ANS_NAME($number);
	NAMED_ANS_RADIO($name,$value,$tag);
}

sub ANS_RADIO_OPTION {
	my $number = shift;
	my $value = shift;
	my $tag =shift;


    my $name = ANS_NUM_TO_NAME($number);
	NAMED_ANS_RADIO_OPTION($name,$value,$tag);
}
sub ANS_RADIO_BUTTONS {
    my $number  =shift;
    my $value = shift;
    my $tag = shift;


	my @out = ();
	push(@out, ANS_RADIO($number, $value,$tag));
	my @buttons = @_;
	while (@buttons) {
		  $value = shift @buttons; $tag = shift @buttons;
		push(@out, ANS_RADIO_OPTION($number, $value,$tag));
	}
	(wantarray) ? @out : join(" ",@out);
}

sub NAMED_ANS_CHECKBOX {
	my $name = shift;
	my $value = shift;
    my $tag =shift;
    $name = RECORD_ANS_NAME($name);

    my $checked = '';
    if ($value =~/^\%/) {
    	$value =~ s/^\%//;
    	$checked = 'CHECKED'
    }

	if (defined($main::inputs_ref->{$name}) ) {
		if ($main::inputs_ref->{$name} eq $value) {
			$checked = 'CHECKED'
		}
		else {
			$checked = '';
		}

    }

	MODES(
		TeX => qq!\\item{$tag}\n!,
		Latex2HTML => qq!\\begin{rawhtml}\n<INPUT TYPE=CHECKBOX NAME="$name" VALUE="$value" $checked>\\end{rawhtml}$tag!,
		HTML => qq!<INPUT TYPE=CHECKBOX NAME="$name" VALUE="$value" $checked>$tag!
	);

}

sub NAMED_ANS_CHECKBOX_OPTION {
	my $name = shift;
	my $value = shift;
	my $tag =shift;

    my $checked = '';
    if ($value =~/^\%/) {
    	$value =~ s/^\%//;
    	$checked = 'CHECKED'
    }

	if (defined($main::inputs_ref->{$name}) ) {
		if ($main::inputs_ref->{$name} eq $value) {
			$checked = 'CHECKED'
		}
		else {
			$checked = '';
		}

    }

	MODES(
		TeX => qq!\\item{$tag}\n!,
		Latex2HTML => qq!\\begin{rawhtml}\n<INPUT TYPE=CHECKBOX NAME="$name" VALUE="$value" $checked>\\end{rawhtml}$tag!,
		HTML => qq!<INPUT TYPE=CHECKBOX NAME="$name" VALUE="$value" $checked>$tag!
	);

}

sub NAMED_ANS_CHECKBOX_BUTTONS {
    my $name  =shift;
    my $value = shift;
    my $tag = shift;

	my @out = ();
	push(@out, NAMED_ANS_CHECKBOX($name, $value,$tag));

	my @buttons = @_;
	while (@buttons) {
		$value = shift @buttons;  $tag = shift @buttons;
		push(@out, NAMED_ANS_CHECKBOX_OPTION($name, $value,$tag));
	}

	(wantarray) ? @out : join(" ",@out);
}

sub ANS_CHECKBOX {
	my $number = shift;
	my $value = shift;
	my $tag =shift;
    my $name = NEW_ANS_NAME($number);

	NAMED_ANS_CHECKBOX($name,$value,$tag);
}

sub ANS_CHECKBOX_OPTION {
	my $number = shift;
	my $value = shift;
	my $tag =shift;
    my $name = ANS_NUM_TO_NAME($number);

	NAMED_ANS_CHECKBOX_OPTION($name,$value,$tag);
}

sub ANS_CHECKBOX_BUTTONS {
    my $number  =shift;
    my $value = shift;
    my $tag = shift;

	my @out = ();
	push(@out, ANS_CHECKBOX($number, $value, $tag));

	my @buttons = @_;
	while (@buttons) {
		$value = shift @buttons;  $tag = shift @buttons;
		push(@out, ANS_CHECKBOX_OPTION($number, $value,$tag));
	}

	(wantarray) ? @out : join(" ",@out);
}

sub ans_rule {
	my $len = shift;     # gives the optional length of the answer blank
	$len    = 20 unless $len ;
	my $name = NEW_ANS_NAME(++$main::ans_rule_count);
	NAMED_ANS_RULE($name ,$len);
}
sub ans_rule_extension {
	my $len = shift;
    $len    = 20 unless $len ;
	my $name = NEW_ANS_NAME($main::ans_rule_count);  # don't update the answer name
	NAMED_ANS_RULE($name ,$len);
}
sub ans_radio_buttons {
	my $name  = NEW_ANS_NAME(++$main::ans_rule_count);
	my @radio_buttons = NAMED_ANS_RADIO_BUTTONS($name, @_);

	if ($displayMode eq 'TeX') {
		$radio_buttons[0] = "\n\\begin{itemize}\n" . $radio_buttons[0];
		$radio_buttons[$#radio_buttons] .= "\n\\end{itemize}\n";
	}

	(wantarray) ? @radio_buttons: join(" ", @radio_buttons);
}

#added 6/14/2000 by David Etlinger
sub ans_checkbox {
	my $name = NEW_ANS_NAME( ++$main::ans_rule_count );
	my @checkboxes = NAMED_ANS_CHECKBOX_BUTTONS( $name, @_ );

	if ($displayMode eq 'TeX') {
		$checkboxes[0] = "\n\\begin{itemize}\n" . $checkboxes[0];
		$checkboxes[$#checkboxes] .= "\n\\end{itemize}\n";
	}

	(wantarray) ? @checkboxes: join(" ", @checkboxes);
}


## define a version of ans_rule which will work inside TeX math mode or display math mode -- at least for tth mode.
## This is great for displayed fractions.
## This will not work with latex2HTML mode since it creates gif equations.

sub tex_ans_rule {
	my $len = shift;
	$len    = 20 unless $len ;
    my $name = NEW_ANS_NAME(++$main::ans_rule_count);
    my $answer_rule = NAMED_ANS_RULE($name ,$len);  # we don't want to create three answer rules in different modes.
    my $out = MODES(
                     'TeX' => $answer_rule,
                     'Latex2HTML' => '\\fbox{Answer boxes cannot be placed inside typeset equations}',
                     'HTML_tth' => '\\begin{rawhtml} '. $answer_rule.'\\end{rawhtml}',
                     'HTML_dpng' => '\\fbox{Answer boxes cannot be placed inside typeset equations}',
                     'HTML'     => $answer_rule
                   );

    $out;
}
sub tex_ans_rule_extension {
	my $len = shift;
	$len    = 20 unless $len ;
    my $name = NEW_ANS_NAME($main::ans_rule_count);
    my $answer_rule = NAMED_ANS_RULE($name ,$len);  # we don't want to create three answer rules in different modes.
    my $out = MODES(
                     'TeX' => $answer_rule,
                     'Latex2HTML' => '\fbox{Answer boxes cannot be placed inside typeset equations}',
                     'HTML_tth' => '\\begin{rawhtml} '. $answer_rule.'\\end{rawhtml}',
                     'HTML_dpng' => '\fbox{Answer boxes cannot be placed inside typeset equations}',
                     'HTML'     => $answer_rule
                   );

    $out;
}
# still needs some cleanup.
sub NAMED_TEX_ANS_RULE {
    my $name = shift;
	my $len = shift;
	$len    = 20 unless $len ;
    my $answer_rule = NAMED_ANS_RULE($name ,$len);  # we don't want to create three answer rules in different modes.
    my $out = MODES(
                     'TeX' => $answer_rule,
                     'Latex2HTML' => '\\fbox{Answer boxes cannot be placed inside typeset equations}',
                     'HTML_tth' => '\\begin{rawhtml} '. $answer_rule.'\\end{rawhtml}',
                     'HTML_dpng' => '\\fbox{Answer boxes cannot be placed inside typeset equations}',
                     'HTML'     => $answer_rule
                   );

    $out;
}
sub NAMED_TEX_ANS_RULE_EXTENSION {
	my $name = shift;
	my $len = shift;
	$len    = 20 unless $len ;
    my $answer_rule = NAMED_ANS_RULE_EXTENSION($name ,$len);  # we don't want to create three answer rules in different modes.
    my $out = MODES(
                     'TeX' => $answer_rule,
                     'Latex2HTML' => '\fbox{Answer boxes cannot be placed inside typeset equations}',
                     'HTML_tth' => '\\begin{rawhtml} '. $answer_rule.'\\end{rawhtml}',
                     'HTML_dpng' => '\fbox{Answer boxes cannot be placed inside typeset equations}',
                     'HTML'     => $answer_rule
                   );

    $out;
}
sub ans_box {
	my $row = shift;
	my $col =shift;
	$row = 5 unless $row;
	$col = 80 unless $col;
	my $name = NEW_ANS_NAME(++$main::ans_rule_count);
	NAMED_ANS_BOX($name ,$row,$col);
}

#this is legacy code; use ans_checkbox instead
sub checkbox {
	my %options = @_;
	qq!<INPUT TYPE="checkbox" NAME="$options{'-name'}" VALUE="$options{'-value'}">$options{'-label'}!
}


sub NAMED_POP_UP_LIST {
    my $name = shift;
	my @list = @_;
	$name = RECORD_ANS_NAME($name);   # record answer name
		my $answer_value = '';
	$answer_value = ${$main::inputs_ref}{$name} if defined(${$main::inputs_ref}{$name});
	my $out = "";
	if ($displayMode eq 'HTML' or $displayMode eq 'HTML_tth' or
            $displayMode eq 'HTML_dpng' or $displayMode eq 'HTML_img') {
		$out = qq!<SELECT NAME = "$name" SIZE=1> \n!;
		my $i;
		foreach ($i=0; $i< @list; $i=$i+2) {
			my $select_flag = ($list[$i] eq $answer_value) ? "SELECTED" : "";
			$out .= qq!<OPTION $select_flag VALUE ="$list[$i]" > $list[$i+1]  </OPTION>\n!;
		};
		$out .= " </SELECT>\n";
	} elsif ( $displayMode eq "Latex2HTML") {
		$out = qq! \\begin{rawhtml}<SELECT NAME = "$name" SIZE=1> \\end{rawhtml} \n !;
		my $i;
		foreach ($i=0; $i< @list; $i=$i+2) {
			my $select_flag = ($list[$i] eq $answer_value) ? "SELECTED" : "";
			$out .= qq!\\begin{rawhtml}<OPTION $select_flag VALUE ="$list[$i]" > $list[$i+1]  </OPTION>\\end{rawhtml}\n!;
		};
		$out .= " \\begin{rawhtml}</SELECT>\\end{rawhtml}\n";
	} elsif ( $displayMode eq "TeX") {
			$out .= "\\fbox{?}";
	}

}

sub pop_up_list {
	my @list = @_;
	my $name = NEW_ANS_NAME(++$main::ans_rule_count);  # get new answer name
	NAMED_POP_UP_LIST($name, @list);
}



=head5  answer_matrix

		Usage   \[ \{   answer_matrix(rows,columns,width_of_ans_rule, @options) \} \]
		
		Creates an array of answer blanks and passes it to display_matrix which returns
		text which represents the matrix in TeX format used in math display mode. Answers
		are then passed back to whatever answer evaluators you write at the end of the problem.
		(note, if you have an m x n matrix, you will need mn answer evaluators, and they will be
		returned to the evaluaters starting in the top left hand corner and proceed to the left 
		and then at the end moving down one row, just as you would read them.)
		
		The options are passed on to display_matrix.


=cut


sub answer_matrix{
	my $m = shift;
	my $n = shift;
	my $width = shift;
	my @options = @_;
	my @array=();
	for( my $i = 0; $i < $m; $i+=1)
	{
		my @row_array = ();
	
		for( my $i = 0; $i < $n; $i+=1)
		{
			push @row_array,  ans_rule($width);
		}	
		my $r_row_array = \@row_array;
		push @array,  $r_row_array;
	}
	display_matrix( \@array, @options );
	
}

sub NAMED_ANS_ARRAY_EXTENSION{
	
	my $name = shift;
	my $col = shift;
	$col = 20 unless $col;
	my $answer_value = '';
	
	$answer_value = ${$main::inputs_ref}{$name} if    defined(${$main::inputs_ref}{$name});
	if ($answer_value =~ /\0/ ) {
		my @answers = split("\0", $answer_value);
		$answer_value = shift(@answers); 
		$answer_value= '' unless defined($answer_value);
	} elsif (ref($answer_value) eq 'ARRAY') {
		my @answers = @{ $answer_value};
  		$answer_value = shift(@answers); 
    		$answer_value= '' unless defined($answer_value);
	}
	
	$answer_value =~ tr/$@`//d;   ## make sure student answers can not be interpolated by e.g. EV3
	MODES(
		TeX => "\\mbox{\\parbox[t]{10pt}{\\hrulefill}}\\hrulefill\\quad ",
		Latex2HTML => qq!\\begin{rawhtml}\n<INPUT TYPE=TEXT SIZE=$col NAME=\"$name\" VALUE = \"\">\n\\end{rawhtml}\n!,
		HTML => "<INPUT TYPE=TEXT SIZE=$col NAME=\"$name\" VALUE = \"$answer_value\">\n"
	);
}

sub ans_array{
	my $m = shift;
	my $n = shift;
	my $col = shift;
	$col = 20 unless $col;
	my $num = ++$main::ans_rule_count ;
	my $name = NEW_ANS_ARRAY_NAME($num,0,0);
	my @options = @_;
	my @array=();
	my $string;
	my $answer_value = "";
	
	$array[0][0] =   NAMED_ANS_RULE($name,$col);
		
	for( my $i = 1; $i < $n; $i+=1)
	{
		$name = NEW_ANS_ARRAY_NAME_EXTENSION($num,0,$i);
		$array[0][$i] =   NAMED_ANS_ARRAY_EXTENSION($name,$col);
	
	}
	
	for( my $j = 1; $j < $m; $j+=1 ){
		
		for( my $i = 0; $i < $n; $i+=1)
		{
			$name = NEW_ANS_ARRAY_NAME_EXTENSION($num,$j,$i);
		 	$array[$j][$i] =  NAMED_ANS_ARRAY_EXTENSION($name,$col);
	
		}
	
	}
	display_matrix( \@array, @options );
	
}

sub ans_array_extension{
	my $m = shift;
	my $n = shift;
	my $col = shift;
	$col = 20 unless $col;
	my $num = $main::ans_rule_count;
	my @options = @_;
	my $name;
	my @array=();
	my $string;
	my $answer_value = "";
			
	for( my $j = 0; $j < $m; $j+=1 ){
		
		for( my $i = 0; $i < $n; $i+=1)
		{
			$name = NEW_ANS_ARRAY_NAME_EXTENSION($num,$j,$i);
			$array[$j][$i] =  NAMED_ANS_ARRAY_EXTENSION($name,$col);
	
		}
	
	}
	display_matrix( \@array, @options );
	
}


# end answer blank macros

=head2 Hints and solutions macros

	solution('text','text2',...);
	SOLUTION('text','text2',...);   # equivalent to TEXT(solution(...));

	hint('text', 'text2', ...);
	HINT('text', 'text2',...);      # equivalent to TEXT("$BR$HINT" . hint(@_) . "$BR") if hint(@_);

Solution prints its concatenated input when the check box named 'ShowSol' is set and
the time is after the answer date.  The check box 'ShowSol' is visible only after the
answer date or when the problem is viewed by a professor.

$envir{'displaySolutionsQ'} is set to 1 when a solution is to be displayed.

Hints are shown only after the number of attempts is greater than $:showHint
($main::showHint defaults to 1) and the check box named 'ShowHint' is set. The check box
'ShowHint' is visible only after the number of attempts is greater than $main::showHint.

$envir{'displayHintsQ'} is set to 1 when a hint is to be displayed.


=cut



#   solution prints its input when $displaySolutionsQ is set.
#   use as TEXT(solution("blah, blah");
#   \$solutionExists
#   is passed to processProblem which displays a "show Solution" button
#   when a solution is available for viewing


sub solution {
	my @in = @_;
	my $out = '';
	$main::solutionExists =1;
	if ($envir{'displaySolutionsQ'}) {$out = join(' ',@in);}
    $out;
}


sub SOLUTION {
	TEXT( solution(@_)) ;
}



sub hint {
   	my @in = @_;
	my $out = '';

	$main::hintExists =1;
    $main::numOfAttempts = 0 unless defined($main::numOfAttempts);

	if ($main::displayMode eq 'TeX')   {
		$out = '';  # do nothing since hints are not available for download
	} elsif (($envir{'displayHintsQ'}) and ($main::numOfAttempts >= $main::showHint))

	 ## the second test above prevents a hint being shown if a doctored form is submitted

	{$out = join(' ',@in);}    # show hint

  $out ;
}


sub HINT {
    TEXT("$main::BR" . hint(@_) . "$main::BR") if hint(@_);
}



# End hints and solutions macros
#################################

#	Produces a random number between $begin and $end with increment 1.
#	You do not have to worry about integer or floating point types.

=head2 Pseudo-random number generator

	Usage:
	random(0,5,.1)  		# produces a random number between 0 and 5 in increments of .1
	non_zero_random(0,5,.1)	# gives a non-zero random number

	list_random(2,3,5,6,7,8,10) # produces random value from the list
	list_random(2,3, (5..8),10) # does the same thing

	SRAND(seed)     # resets the main random generator -- use very cautiously


SRAND(time) will create a different problem everytime it is called.  This makes it difficult
to check the answers :-).

SRAND($envir{'inputs_ref'}->{'key'} ) will create a different problem for each login session.
This is probably what is desired.

=cut


sub random  {
	my ($begin, $end, $incr) = @_;
	$main::PG_random_generator->random($begin,$end,$incr);
}


sub non_zero_random { ##gives a non-zero random number
 	my (@arguments)=@_;
 	my $a=0;
 	my $i=100; #safety counter
 	while ($a==0 && ( 0 < $i-- ) ) {
 		$a=random(@arguments);
 	}
 	$a;
}

sub list_random {
        my(@li) = @_;
        return $li[random(1,scalar(@li))-1];
}

sub SRAND { # resets the main random generator -- use cautiously
    my $seed = shift;
	$main::PG_random_generator -> srand($seed);
}

# display macros

=head2 Display Macros

These macros produce different output depending on the display mode being used to show
the problem on the screen, or whether the problem is being converted to TeX to produce
a hard copy output.

	MODES   ( TeX =>        "Output this in TeX mode",
	          HTML =>       "output this in HTML mode",
	          HTML_tth =>   "output this in HTML_tth mode",
	          HTML_dpng =>   "output this in HTML_dpng mode",
	          Latex2HTML => "output this in Latex2HTML mode",
	         )

	TEX     (tex_version, html_version) #obsolete

	M3      (tex_version, latex2html_version, html_version) #obsolete



=cut


sub TEX {
	my ($tex, $html ) = @_;
	MODES(TeX => $tex, HTML => $html, HTML_tth => $html, HTML_dpng => $html);
}


sub M3 {
	my($tex,$l2h,$html) = @_;
	MODES(TeX => $tex, Latex2HTML => $l2h, HTML => $html, HTML_tth => $html, HTML_dpng => $html);
}

# This replaces M3.  You can add new modes at will to this one.

sub MODES {
	my %options = @_;
	return $options{$displayMode}
	           if defined( $options{$displayMode} );

	# default searches.
	if ($displayMode eq "Latex2HTML") {
		return $options{TeX}
	           if defined( $options{TeX} );
	    return $options{HTML}
	           if defined( $options{HTML} );
	    die " ERROR in using MODES: 'HTML' and 'TeX' options not defined for 'Latex2HTML'";
	}

	if ($displayMode eq "HTML_tth") {
		return $options{HTML}
	           if defined( $options{HTML} );
	    die " ERROR in using MODES: 'HTML' option not defined for HTML_tth";

	}

	if ($displayMode eq "HTML_img") {
		return $options{HTML_dpng} if defined $options{HTML_dpng};
		return $options{HTML_tth} if defined $options{HTML_tth};
		return $options{HTML}     if defined $options{HTML};
		die " ERROR in using MODES: 'HTML' option not defined for HTML_img";
	}

	if ($displayMode eq "HTML_dpng") {
		return $options{HTML_tth}
	           if defined( $options{HTML_tth} );
		return $options{HTML}
	           if defined( $options{HTML} );
	    die " ERROR in using MODES: 'HTML' option not defined for HTML_dpng";

	}

	# trap undefined errors
	die "ERROR in defining MODES:  Can't find |$displayMode| among
	         available options:" . join(" ", keys(%options) )
	         . " file " . __FILE__ ." line " . __LINE__."\n\n";

}


# end display macros


=head2  Display constants

	@ALPHABET   		ALPHABET()			capital letter alphabet -- ALPHABET[0] = 'A'
	$PAR				PAR()				paragraph character (\par or <p>)
	$BR         		BR()				line break character
	$LQ					LQ()				left double quote
	$RQ					RQ()				right double quote
	$BM					BM()				begin math
	$EM					EM()				end math
	$BDM				BDM()				begin display math
	$EDM				EDM()				end display math
	$LTS				LTS()				strictly less than
	$GTS				GTS()				strictly greater than
	$LTE				LTE()				less than or equal
	$GTE				GTE()				greater than or equal
	$BEGIN_ONE_COLUMN	BEGIN_ONE_COLUMN()	begin one-column mode
	$END_ONE_COLUMN		END_ONE_COLUMN()	end one-column mode
	$SOL				SOLUTION_HEADING()	solution headline
	$SOLUTION			SOLUTION_HEADING()	solution headline
	$HINT				HINT_HEADING()		hint headline
	$US					US()				underscore character
	$SPACE				SPACE()				space character (tex and latex only)
	$BBOLD				BBOLD()				begin bold typeface
	$EBOLD				EBOLD()				end bold typeface
	$BITALIC    		BITALIC()  			begin italic typeface
	$EITALIC    		EITALIC()  			end italic typeface
	$BCENTER    		BCENTER()   		begin centered environment
	$ECENTER    		ECENTER()  			end centered environment
	$HR					HR()				horizontal rule
	$LBRACE				LBRACE()			left brace
	$LB					LB ()				left brace
	$RBRACE				RBRACE()			right brace
	$RB					RB ()				right brace
	$DOLLAR				DOLLAR()			a dollar sign
	$PERCENT			PERCENT()			a percent sign
	$CARET				CARET()				a caret sign
	$PI					PI()				the number pi
	$E					E()					the number e

=cut





#	A utility variable.  Notice that "B"=$ALPHABET[1] and
#	"ABCD"=@ALPHABET[0..3].

sub ALPHABET  {
	('A'..'ZZ')[@_];
}

###############################################################
# Some constants which are different in tex and in HTML
# The order of arguments is TeX, Latex2HTML, HTML
sub PAR { MODES( TeX => '\\par ',Latex2HTML => '\\par ',HTML => '<P>' ); };
sub BR { MODES( TeX => '\\par\\noindent ',Latex2HTML => '\\par\\noindent ',HTML => '<BR>'); };
sub LQ { MODES( TeX => "``", Latex2HTML =>   '"',  HTML =>  '&quot;' ); };
sub RQ { MODES( TeX => "''", Latex2HTML =>   '"',   HTML =>  '&quot;' ); };
sub BM { MODES(TeX => '\\(', Latex2HTML => '\\(', HTML =>  ''); };  # begin math mode
sub EM { MODES(TeX => '\\)', Latex2HTML => '\\)', HTML => ''); };  # end math mode
sub BDM { MODES(TeX => '\\[', Latex2HTML =>   '\\[', HTML =>   '<P ALIGN=CENTER>'); };  #begin displayMath mode
sub EDM { MODES(TeX => '\\]',  Latex2HTML =>  '\\]', HTML => '</P>'); };              #end displayMath mode
sub LTS { MODES(TeX => ' < ', Latex2HTML => ' \\lt ',  HTML =>   '&lt;'); };
sub GTS {MODES(TeX => ' > ', Latex2HTML => ' \\gt ',  HTML =>    '&gt;'); };
sub LTE { MODES(TeX => ' \\le ', Latex2HTML =>  ' \\le ',  HTML => '&lt;=' ); };
sub GTE { MODES(TeX => ' \\ge ',  Latex2HTML => ' \\ge ',  HTML =>  '&gt;'); };
sub BEGIN_ONE_COLUMN { MODES(TeX => " \\end{multicols}\n",  Latex2HTML => " ", HTML =>   " "); };
sub END_ONE_COLUMN { MODES(TeX =>
              " \\begin{multicols}{2}\n\\columnwidth=\\linewidth\n",
                            Latex2HTML => ' ', HTML => ' ');

};
sub SOLUTION_HEADING { MODES( TeX => '\\par {\\bf Solution:}',
                 Latex2HTML => '\\par {\\bf Solution:}',
          		 HTML =>  '<P><B>Solution:</B>');
          		};
sub HINT_HEADING { MODES( TeX => "\\par {\\bf Hint:}", Latex2HTML => "\\par {\\bf Hint:}", HTML => "<P><B>Hint:</B>"); };
sub US { MODES(TeX => '\\_', Latex2HTML => '\\_', HTML => '_');};  # underscore, e.g. file${US}name
sub SPACE { MODES(TeX => '\\ ',  Latex2HTML => '\\ ', HTML => '&nbsp;');};  # force a space in latex, doesn't force extra space in html
sub BBOLD { MODES(TeX => '{\\bf ',  Latex2HTML => '{\\bf ', HTML => '<B>'); };
sub EBOLD { MODES( TeX => '}', Latex2HTML =>  '}',HTML =>  '</B>'); };
sub BITALIC { MODES(TeX => '{\\it ',  Latex2HTML => '{\\it ', HTML => '<I>'); };
sub EITALIC { MODES(TeX => '} ',  Latex2HTML => '} ', HTML => '</I>'); };
sub BCENTER { MODES(TeX => '\\begin{center} ',  Latex2HTML => ' \\begin{rawhtml} <div align="center"> \\end{rawhtml} ', HTML => '<div align="center">'); };
sub ECENTER { MODES(TeX => '\\end{center} ',  Latex2HTML => ' \\begin{rawhtml} </div> \\end{rawhtml} ', HTML => '</div>'); };
sub HR { MODES(TeX => '\\par\\hrulefill\\par ', Latex2HTML => '\\begin{rawhtml} <HR> \\end{rawhtml}', HTML =>  '<HR>'); };
sub LBRACE { MODES( TeX => '\{', Latex2HTML =>   '\\lbrace',  HTML =>  '\{' , HTML_tth=> '\\lbrace' ); };
sub RBRACE { MODES( TeX => '\}', Latex2HTML =>   '\\rbrace',  HTML =>  '\}' , HTML_tth=> '\\rbrace',); };
sub LB { MODES( TeX => '\{', Latex2HTML =>   '\\lbrace',  HTML =>  '\{' , HTML_tth=> '\\lbrace' ); };
sub RB { MODES( TeX => '\}', Latex2HTML =>   '\\rbrace',  HTML =>  '\}' , HTML_tth=> '\\rbrace',); };
sub DOLLAR { MODES( TeX => '\\$', Latex2HTML => '\\$', HTML => '$' ); };
sub PERCENT { MODES( TeX => '\\%', Latex2HTML => '\\%', HTML => '%' ); };
sub CARET { MODES( TeX => '\\verb+^+', Latex2HTML => '\\verb+^+', HTML => '^' ); };
sub PI {4*atan2(1,1);};
sub E {exp(1);};

###############################################################
## Evaluation macros


=head2 TEXT macros

	Usage:
		TEXT(@text);

This is the simplest way to print text from a problem.  The strings in the array C<@text> are concatenated
with spaces between them and printed out in the text of the problem.  The text is not processed in any other way.
C<TEXT> is defined in PG.pl.

	Usage:
		BEGIN_TEXT
			text.....
		END_TEXT

This is the most common way to enter text into the problem.  All of the text between BEGIN_TEXT and END_TEXT
is processed by the C<EV3> macro described below and then printed using the C<TEXT> command.  The two key words
must appear on lines by themselves.  The preprocessing that makes this construction work is done in F<PGtranslator.pm>.
See C<EV3> below for details on the processing.


=cut

=head2 Evaluation macros

=head3 EV3

        TEXT(EV3("This is a formulat \( \int_0^5 x^2 \, dx \) ");
        TEXT(EV3(@text));

		TEXT(EV3(<<'END_TEXT'));
			text stuff...
		END_TEXT


The BEGIN_TEXT/END_TEXT construction is translated into the construction above by PGtranslator.pm.  END_TEXT must appear
on a line by itself and be left justified.  (The << construction is known as a "here document" in UNIX and in PERL.)

The single quotes around END_TEXT mean that no automatic interpolation of variables takes place in the text.
Using EV3 with strings which have been evaluated by double quotes may lead to unexpected results.


The evaluation macro E3 first evaluates perl code inside the braces:  C<\{  code \}>.
Any perl statment can be put inside the braces.  The
result of the evaluation (i.e. the last statement evaluated) replaces the C<\{ code \}> construction.

Next interpolation of all variables (e.g. C<$var or @array> ) is performed.

Then mathematical formulas in TeX are evaluated within the
C<\(  tex math mode \)> and
C<\[ tex display math mode \] >
constructions, in that order:

=head3 FEQ

	FEQ($string);   # processes and outputs the string


The mathematical formulas are run through the macro C<FEQ> (Format EQuations) which performs
several substitutions (see below).
In C<HTML_tth> mode the resulting code is processed by tth to obtain an HTML version
of the formula. (In the future processing by WebEQ may be added here as another option.)
The Latex2HTML mode does nothing
at this stage; it creates the entire problem before running it through
TeX and creating the GIF images of the equations.

The resulting string is output (and usually fed into TEXT to be printed in the problem).

	Usage:

		$string2 = FEQ($string1);

This is a filter which is used to format equations by C<EV2> and C<EV3>, but can also be used on its own.  It is best
understood with an example.

		$string1 = "${a}x^2 + ${b}x + {$c:%.1f}"; $a = 3;, $b = -2; $c = -7.345;

when interpolated becomes:

		$string1 = '3x^2 + -2x + {-7.345:%0.1f}

FEQ first changes the number of decimal places displayed, so that the last term becomes -7.3 Then it removes the
extraneous plus and minus signs, so that the final result is what you want:

		$string2 = '3x^2 - 2x -7.3';

(The %0.1f construction
is the same formatting convention used by Perl and nearly identical to the one used by the C printf statement. Some common
usage:  %0.3f 3 decimal places, fixed notation; %0.3e 3 significant figures exponential notation; %0.3g uses either fixed
or exponential notation depending on the size of the number.)

Two additional legacy formatting constructions are also supported:

C<?{$c:%0.3f} > will give a number with 3 decimal places and a negative
sign if the number is negative, no sign if the number is positive.

C<!{$c:%0.3f}> determines the sign and prints it
whether the number is positive or negative.

=head3 EV2

		TEXT(EV2(@text));

		TEXT(EV2(<<END_OF_TEXT));
			text stuff...
		END_OF_TEXT

This is a precursor to EV3.  In this case the constants are interpolated first, before the evaluation of the \{ ...code...\}
construct. This can lead to unexpected results.  For example C<\{ join(" ", @text) \}> with C<@text = ("Hello","World");> becomes,
after interpolation, C<\{ join(" ",Hello World) \}> which then causes an error when evaluated because Hello is a bare word.
C<EV2> can still be useful if you allow for this, and in particular it works on double quoted strings, which lead to
unexpected results with C<EV3>. Using single quoted strings with C<EV2> may lead to unexpected results.

The unexpected results have to do with the number of times backslashed constructions have to be escaped. It is quite messy.  For
more details get a good Perl book and then read the code. :-)




=cut


sub ev_substring {
    my $string      = shift;
	my $start_delim = shift;
	my $end_delim   = shift;
	my $actionRef   = shift;
	my ($eval_out,$PG_eval_errors,$PG_full_error_report)=();
    my $out = "";
		while ($string) {
		    if ($string =~ /\Q$start_delim\E/s) {
		   #print "$start_delim $end_delim evaluating_substring=$string<BR>";
				$string =~ s/^(.*?)\Q$start_delim\E//s;  # get string up to next \{ ---treats string as a single line, ignoring returns
				$out .= $1;
		   #print "$start_delim $end_delim substring_out=$out<BR>";
				$string =~ s/^(.*?)\Q$end_delim\E//s;  # get perl code up to \} ---treats string as a single line,  ignoring returns
           #print "$start_delim $end_delim evaluate_string=$1<BR>";
				($eval_out,$PG_eval_errors,$PG_full_error_report) = &$actionRef($1);
				$eval_out = "$start_delim $eval_out $end_delim" if $PG_full_error_report;
				$out = $out . $eval_out;
		   #print "$start_delim $end_delim new substring_out=$out<BR><p><BR>";
				$out .="$main::PAR ERROR $0 in ev_substring, PGbasicmacros.pl:$main::PAR <PRE>  $@ </PRE>$main::PAR" if $@;
				}
			else {
				$out .= $string;  # flush the last part of the string
				last;
				}

			}
	$out;
}
sub  safe_ev {
    my ($out,$PG_eval_errors,$PG_full_error_report) = &old_safe_ev;   # process input by old_safe_ev first
    $out =~s/\\/\\\\/g;   # protect any new backslashes introduced.
	($out,$PG_eval_errors,$PG_full_error_report)
}

sub  old_safe_ev {
    my $in = shift;
  	my   ($out,$PG_eval_errors,$PG_full_error_report) = PG_restricted_eval("$in;");
  	# the addition of the ; seems to provide better error reporting
  	if ($PG_eval_errors) {
  	 	my @errorLines = split("\n",$PG_eval_errors);
 		#$out = "<PRE>$main::PAR % ERROR in $0:old_safe_ev, PGbasicmacros.pl: $main::PAR % There is an error occuring inside evaluation brackets \\{ ...code... \\} $main::BR % somewhere in an EV2 or EV3 or BEGIN_TEXT block. $main::BR % Code evaluated:$main::BR $in $main::BR % $main::BR % $errorLines[0]\n % $errorLines[1]$main::BR % $main::BR % $main::BR </PRE> ";
		warn " ERROR in old_safe_ev, PGbasicmacros.pl: <PRE>
     ## There is an error occuring inside evaluation brackets \\{ ...code... \\}
     ## somewhere in an EV2 or EV3 or BEGIN_TEXT block.
     ## Code evaluated:
     ## $in
     ##" .join("\n     ", @errorLines). "
     ##</PRE>$main::BR
     ";
     $out ="$main::PAR $main::BBOLD  $in $main::EBOLD $main::PAR";


	}

	($out,$PG_eval_errors,$PG_full_error_report);
}

sub FEQ   {    # Format EQuations
	my $in = shift;
	 # formatting numbers -- the ?{} and !{} constructions
	$in =~s/\?\s*\{([.\-\$\w\d]+):?([%.\da-z]*)\}/${ \( &sspf($1,$2) )}/g;
	$in =~s/\!\s*\{([.\-\$\w\d]+):?([%.\da-z]*)\}/${ \( &spf($1,$2) )}/g;

	# more formatting numbers -- {number:format} constructions
	$in =~ s/\{(\s*[\+\-\d\.]+[eE]*[\+\-]*\d*):(\%\d*.\d*\w)}/${ \( &spf($1,$2) )}/g;
	$in =~ s/\+\s*\-/ - /g;
	$in =~ s/\-\s*\+/ - /g;
	$in =~ s/\+\s*\+/ + /g;
	$in =~ s/\-\s*\-/ + /g;
	$in;
}

#sub math_ev3 {
#	my $in = shift; #print "in=$in<BR>";
#	my ($out,$PG_eval_errors,$PG_full_error_report);
#	$in = FEQ($in);
#	$in =~ s/%/\\%/g;   #  % causes trouble in TeX and HTML_tth it usually (always?) indicates an error, not comment
#	return("$main::BM $in $main::EM") unless ($displayMode eq 'HTML_tth');
#	$in = "\\(" . $in . "\\)";
#	$out = tth($in);
#	($out,$PG_eval_errors,$PG_full_error_report);
#
#}
#
#sub display_math_ev3 {
#	my $in = shift; #print "in=$in<BR>";
#	my ($out,$PG_eval_errors,$PG_full_error_report);
#	$in = FEQ($in);
#	$in =~ s/%/\\%/g;
#	return("$main::BDM $in $main::EDM") unless $displayMode eq 'HTML_tth' ;
#	$in = "\\[" . $in . "\\]";
#	$out =tth($in);
#	($out,$PG_eval_errors,$PG_full_error_report);
#}

sub math_ev3 {
	my $in = shift;
	$in = FEQ($in);
	$in =~ s/%/\\%/g;
	return general_math_ev3($in, "inline");
}

sub display_math_ev3 {
	my $in = shift;
	return general_math_ev3($in, "display");
}

sub general_math_ev3 {
	my $in = shift;
	my $mode = shift || "inline";

	$in = FEQ($in);
	$in =~ s/%/\\%/g;
	my $in_delim;

	if($mode eq "inline") {
		$in_delim = "\\($in\\)";
	} else { # assuming displayed math
		$in_delim =				"\\[$in\\]";
	}

	my $out;
	if($displayMode eq "HTML_tth") {
		$out = tth($in_delim);
	} elsif ($displayMode eq "HTML_dpng") {
		$out = $envir{'imagegen'}->add($in_delim);
	} elsif ($displayMode eq "HTML_img") {
		$out = math2img($in, $mode);
	} else {
		$out = "\\($in\\)" if $mode eq "inline";
		$out = "\\[$in\\]" if $mode eq "display";
	}
	return $out;
}

sub EV2 {
	my $string = join(" ",@_);
	# evaluate code inside of \{  \}  (no nesting allowed)
    $string = ev_substring($string,"\\{","\\}",\&old_safe_ev);
    $string = ev_substring($string,"\\<","\\>",\&old_safe_ev);
	$string = ev_substring($string,"\\(","\\)",\&math_ev3);
	$string = ev_substring($string,"\\[","\\]",\&display_math_ev3);
	# macros for displaying math
	$string =~ s/\\\(/$main::BM/g;
	$string =~ s/\\\)/$main::EM/g;
	$string =~ s/\\\[/$main::BDM/g;
	$string =~ s/\\\]/$main::EDM/g;
	$string;
}

sub EV3{
	my $string = join(" ",@_);
	# evaluate code inside of \{  \}  (no nesting allowed)
    $string = ev_substring($string,"\\\\{","\\\\}",\&safe_ev);  # handles \{ \} in single quoted strings of PG files
	# interpolate variables
	my ($evaluated_string,$PG_eval_errors,$PG_full_errors) = PG_restricted_eval("<<END_OF_EVALUATION_STRING\n$string\nEND_OF_EVALUATION_STRING\n");
	if ($PG_eval_errors) {
  	 	my @errorLines = split("\n",$PG_eval_errors);
  	 	$string =~ s/</&lt;/g; $string =~ s/>/&gt;/g;
 		$evaluated_string = "<PRE>$main::PAR % ERROR in $0:EV3, PGbasicmacros.pl: $main::PAR % There is an error occuring in the following code:$main::BR $string $main::BR % $main::BR % $errorLines[0]\n % $errorLines[1]$main::BR % $main::BR % $main::BR </PRE> ";
		$@="";
	}
	$string = $evaluated_string;
	$string = ev_substring($string,"\\(","\\)",\&math_ev3);
    $string = ev_substring($string,"\\[","\\]",\&display_math_ev3);
	$string;
}

=head2 Formatting macros

	beginproblem()  # generates text listing number and the point value of
	                # the problem. It will also print the file name containing
	                # the problem for users listed in the PRINT_FILE_NAMES_FOR PG_environment
	                # variable.
	OL(@array)      # formats the array as an Ordered List ( <OL> </OL> ) enumerated by letters.

	htmlLink($url, $text)
	                # Places a reference to the URL with the specified text in the problem.
	                # A common usage is \{ htmlLink(alias('prob1_help.html') \}, 'for help')
	                # where alias finds the full address of the prob1_help.html file in the same directory
	                # as the problem file
	appletLink($url, $parameters)
	                # For example
	                # appletLink(q!  archive="http: //webwork.math.rochester.edu/gage/xFunctions/xFunctions.zip"
	                                code="xFunctionsLauncher.class"  width=100 height=14!,
	                " parameter text goes here")
	                # will link to xFunctions.

	low level:

	spf($number, $format)   # prints the number with the given format
	sspf($number, $format)  # prints the number with the given format, always including a sign.
	protect_underbar($string) # protects the underbar (class_name) in strings which may have to pass through TeX.

=cut

sub beginproblem {
	my $out = "";
    my $TeXFileName = protect_underbar($main::fileName);
    my $l2hFileName = protect_underbar($main::fileName);
	my %inlist;
	my $points ='pts';
	$points = 'pt' if $main::problemValue == 1;
	##    Prepare header for the problem
	grep($inlist{$_}++,@{ $envir{'PRINT_FILE_NAMES_FOR'} });
	if ( defined($inlist{$main::studentLogin}) and ($inlist{$main::studentLogin} > 0) ) {
		$out = &M3("\n\n\\medskip\\hrule\\smallskip\\par{\\bf ${main::probNum}.{\\footnotesize ($main::problemValue $points) $TeXFileName}}\\newline ",
		" \\begin{rawhtml} ($main::problemValue $points) <B>$l2hFileName</B><BR>\\end{rawhtml}",
		 "($main::problemValue $points) <B>$main::fileName</B><BR>"
	 	   );
	}	else {
		$out = &M3("\n\n\\smallskip\\hrule\\smallskip\\par{\\bf ${main::probNum}.}($main::problemValue $points) ",
		"($main::problemValue $points) ",
		 "($main::problemValue $points) "
	 	   );
	}
	$out;

}

# kludge to clean up path names
            ## allow underscore character in set and section names and also allows line breaks at /
sub protect_underbar {
    my $in = shift;
    if ($displayMode eq 'TeX')  {

        $in =~ s|_|\\\_|g;
        $in =~ s|/|\\\-/|g;  # allows an optional hyphenation of the path (in tex)
    }
    $in;
}


#	An example of a macro which prints out a list (with letters)
sub OL {
	my(@array) = @_;
	my $i = 0;
	my	$out= 	&M3(
					"\\begin{enumerate}\n",
					" \\begin{rawhtml} <OL TYPE=\"A\" VALUE=\"1\"> \\end{rawhtml} ",
					"<OL TYPE=\"A\" VALUE=\"1\">\n"
				 	) ;
	my $elem;
	foreach $elem (@array) {
                $out .= MODES(
                        TeX=>   "\\item[$main::ALPHABET[$i].] $elem\n",
                        Latex2HTML=>    " \\begin{rawhtml} <LI> \\end{rawhtml} $elem  ",
                        HTML=>  "<LI> $elem\n",
                        HTML_dpng=>     "<LI> $elem <br /> <br /> \n"
                                        );
		$i++;
	}
	$out .= &M3(
				"\\end{enumerate}\n",
				" \\begin{rawhtml} </OL>\n \\end{rawhtml} ",
				"</OL>\n"
				) ;
}

sub htmlLink {
	my $url = shift;
	my $text = shift;
	my $options = shift;
	$options = "" unless defined($options);
	return "${main::BBOLD}[ broken link:  $text ] ${main::EBOLD}" unless defined($url);
	M3( "{\\bf \\underline{$text}  }",
	    "\\begin{rawhtml} <A HREF=\"$url\" $options> $text </A>\\end{rawhtml}",
	    "<A HREF=\"$url\" $options> $text </A>"
	    );
}
sub appletLink {
	my $url = shift;
	my $options = shift;
	$options = "" unless defined($options);
	M3( "{\\bf \\underline{APPLET}  }",
	    "\\begin{rawhtml} <APPLET $url> $options </APPLET>\\end{rawhtml}",
	    "<APPLET $url> $options </APPLET>"
	    );
}
sub spf {
	my($number,$format) = @_;  # attention, the order of format and number are reversed
	$format = "%4.3g" unless $format;   # default value for format
	sprintf($format, $number);
	}
sub sspf {
	my($number,$format) = @_;  # attention, the order of format and number are reversed
	$format = "%4.3g" unless $format;   # default value for format
	my $sign = $number>=0 ? " + " : " - ";
	$number = $number>=0 ? $number : -$number;
	$sign .sprintf($format, $number);
	}

=head2  Sorting and other list macros



	Usage:
	lex_sort(@list);   # outputs list in lexigraphic (alphabetical) order
	num_sort(@list);   # outputs list in numerical order
	uniq( @list);      # outputs a list with no duplicates.  Order is unspecified.

	PGsort( \&sort_subroutine, @list);
	# &sort_subroutine defines order. It's output must be -1,0 or 1.

=cut

#  uniq gives unique elements of a list:
 sub uniq {
   my (@in) =@_;
   my %temp = ();
   while (@in) {
 					$temp{shift(@in)}++;
      }
   my @out =  keys %temp;  # sort is causing trouble with Safe.??
   @out;
}

sub lex_sort {
	PGsort sub {$_[0] cmp $_[1]}, @_;
}
sub num_sort {
	PGsort sub {$_[0] <=> $_[1]}, @_;
}


=head2 Macros for handling tables

	Usage:
	begintable( number_of_columns_in_table)
	row(@dataelements)
	endtable()

Example of useage:

	BEGIN_TEXT
		This problem tests calculating new functions from old ones:$BR
		From the table below calculate the quantities asked for:$BR
		\{begintable(scalar(@firstrow)+1)\}
		\{row(" \(x\) ",@firstrow)\}
		\{row(" \(f(x)\) ", @secondrow)\}
		\{row(" \(g(x)\) ", @thirdrow)\}
		\{row(" \(f'(x)\) ", @fourthrow)\}
		\{row(" \(g'(x)\) ", @fifthrow)\}
		\{endtable()\}

	 (The arrays contain numbers which are placed in the table.)

	END_TEXT

=cut

sub begintable {
	my ($number)=shift;   #number of columns in table
	my %options = @_;
	warn "begintable(cols) requires a number indicating the number of columns" unless defined($number);
	my $out =	"";
	if ($displayMode eq 'TeX') {
		$out .= "\n\\par\\smallskip\\begin{center}\\begin{tabular}{"  .  "|c" x $number .  "|} \\hline\n";
		}
	elsif ($displayMode eq 'Latex2HTML') {
		$out .= "\n\\begin{rawhtml} <TABLE , BORDER=1>\n\\end{rawhtml}";
		}
	elsif ($displayMode eq 'HTML' || $displayMode eq 'HTML_tth' || $displayMode eq 'HTML_dpng' || $displayMode eq 'HTML_img') {
		$out .= "<TABLE BORDER=1>\n"
	}
	else {
		$out = "Error: PGchoicemacros: begintable: Unknown displayMode: $displayMode.\n";
		}
	$out;
	}

sub endtable {
	my $out = "";
	if ($displayMode eq 'TeX') {
		$out .= "\n\\end {tabular}\\end{center}\\par\\smallskip\n";
		}
	elsif ($displayMode eq 'Latex2HTML') {
		$out .= "\n\\begin{rawhtml} </TABLE >\n\\end{rawhtml}";
		}
	elsif ($displayMode eq 'HTML' || $displayMode eq 'HTML_tth' || $displayMode eq 'HTML_dpng' ||$displayMode eq 'HTML_img') {
		$out .= "</TABLE>\n";
		}
	else {
		$out = "Error: PGchoicemacros: endtable: Unknown displayMode: $displayMode.\n";
		}
	$out;
	}


sub row {
	my @elements = @_;
	my $out = "";
	if ($displayMode eq 'TeX') {
		while (@elements) {
			$out .= shift(@elements) . " &";
			}
		 chop($out); # remove last &
		 $out .= "\\\\ \\hline \n";
		 # carriage returns must be added manually for tex
		}
	elsif ($displayMode eq 'Latex2HTML') {
		$out .= "\n\\begin{rawhtml}\n<TR>\n\\end{rawhtml}\n";
		while (@elements) {
			$out .= " \n\\begin{rawhtml}\n<TD> \n\\end{rawhtml}\n" . shift(@elements) . " \n\\begin{rawhtml}\n</TD> \n\\end{rawhtml}\n";
			}
		$out .= " \n\\begin{rawhtml}\n</TR> \n\\end{rawhtml}\n";
	}
	elsif ($main::displayMode eq 'HTML' || $main::displayMode eq 'HTML_tth' || $displayMode eq 'HTML_dpng'||$displayMode eq 'HTML_img') {
		$out .= "<TR>\n";
		while (@elements) {
			$out .= "<TD>" . shift(@elements) . "</TD>";
			}
		$out .= "\n</TR>\n";
	}
	else {
		$out = "Error: PGchoicemacros: row: Unknown displayMode: $main::displayMode.\n";
		}
	$out;
}

=head2 Macros for displaying static images

	Usage:
	$string = image($image, width => 100, height => 100, tex_size => 800)
	$string = image([$image1, $image2], width => 100, height => 100, tex_size => 800)
	$string = caption($string);
	$string = imageRow([$image1, $image2 ], [$caption1, $caption2]);
	         # produces a complete table with rows of pictures.


=cut

#   More advanced macros
sub image {
	my $image_ref  = shift;
	my @opt = @_;
	unless (scalar(@opt) % 2 == 0 ) {
		warn "ERROR in image macro.  A list of macros must be inclosed in square brackets.";
	}
	my %in_options = @opt;
	my %known_options = (
		width    => 100,
		height   => 100,
		tex_size => 800,
	);
	# handle options
	my %out_options = %known_options;
	foreach my $opt_name (keys %in_options) {
		if ( exists( $known_options{$opt_name} ) ) {
			$out_options{$opt_name} = $in_options{$opt_name} if exists( $in_options{$opt_name} ) ;
		} else {
			die "Option $opt_name not defined for image. " .
			    "Default options are:<BR> ", display_options2(%known_options);
		}
	}
	my $width       = $out_options{width};
	my $height      = $out_options{height};
	my $tex_size    = $out_options{tex_size};
	my $width_ratio = $tex_size*(.001);
	my @image_list  = ();

 	if (ref($image_ref) =~ /ARRAY/ ) {
		@image_list = @{$image_ref};
 	} else {
		push(@image_list,$image_ref);
 	}

 	my @output_list = ();
  	while(@image_list) {
 		my $imageURL = alias(shift @image_list);
 		my $out="";

		if ($main::displayMode eq 'TeX') {
			my $imagePath = $imageURL; # in TeX mode, alias gives us a path, not a URL
			if ($envir{texDisposition} eq "pdf") {
				# We're going to create PDF files with our TeX (using pdflatex), so
				# alias should have given us the path to a PNG image. What we need
				# to do is find out the dimmensions of this image, since pdflatex
				# is too dumb to live.

				#my ($height, $width) = getImageDimmensions($imagePath);
				##warn "&image: $imagePath $height $width\n";
				#unless ($height and $width) {
				#	warn "Couldn't get the dimmensions of image $imagePath.\n"
				#}
				#$out = "\\includegraphics[bb=0 0 $height $width,width=$width_ratio\\linewidth]{$imagePath}\n";
				$out = "\\includegraphics[width=$width_ratio\\linewidth]{$imagePath}\n";
			} else {
				# Since we're not creating PDF files, alias should have given us the
				# path to an EPS file. latex can get its dimmensions no problem!

				$out = "\\includegraphics[width=$width_ratio\\linewidth]{$imagePath}\n";
			}
		} elsif ($main::displayMode eq 'Latex2HTML') {
			$out = qq!\\begin{rawhtml}\n<A HREF= "$imageURL" TARGET="ZOOM"><IMG SRC="$imageURL"  WIDTH="$width" HEIGHT="$height"></A>\n
			\\end{rawhtml}\n !
 		} elsif ($main::displayMode eq 'HTML' || $main::displayMode eq 'HTML_tth' || $displayMode eq 'HTML_dpng' || $displayMode eq 'HTML_img') {
 			$out = qq!<A HREF= "$imageURL" TARGET="ZOOM"><IMG SRC="$imageURL"  WIDTH="$width" HEIGHT="$height"></A>
 			!
 		} else {
 			$out = "Error: PGchoicemacros: image: Unknown displayMode: $main::displayMode.\n";
 		}
 		push(@output_list, $out);
 	}
	return wantarray ? @output_list : $output_list[0];
}

# This is legacy code.
sub images {
	my @in = @_;
	my @outlist = ();
	while (@in) {
	   push(@outlist,&image( shift(@in) ) );
	 }
	@outlist;
}


sub caption {
	my ($out) = @_;
	$out = " $out \n" if $main::displayMode eq 'TeX';
	$out = " $out  " if $main::displayMode eq 'HTML';
	$out = " $out  " if $main::displayMode eq 'HTML_tth';
	$out = " $out  " if $main::displayMode eq 'HTML_dpng';
	$out = " $out  " if $main::displayMode eq 'HTML_img';
	$out = " $out  " if $main::displayMode eq 'Latex2HTML';
		$out;
}

sub captions {
	my @in = @_;
	my @outlist = ();
	while (@in) {
	   push(@outlist,&caption( shift(@in) ) );
	}
	@outlist;
}

sub imageRow {

	my $pImages = shift;
	my $pCaptions=shift;
	my $out = "";
	my @images = @$pImages;
	my @captions = @$pCaptions;
	my $number = @images;
	# standard options
	my %options = ( 'tex_size' => 200,  # width for fitting 4 across
	                'height' => 100,
	                'width' => 100,
	                @_            # overwrite any default options
	              );

	if ($main::displayMode eq 'TeX') {
		$out .= "\n\\par\\smallskip\\begin{center}\\begin{tabular}{"  .  "|c" x $number .  "|} \\hline\n";
		while (@images) {
			$out .= &image( shift(@images),%options ) . '&';
		}
		chop($out);
		$out .= "\\\\ \\hline \n";
		while (@captions) {
			$out .= &caption( shift(@captions) ) . '&';
		}
		chop($out);
		$out .= "\\\\ \\hline \n\\end {tabular}\\end{center}\\par\\smallskip\n";
	} elsif ($main::displayMode eq 'Latex2HTML'){

		$out .= "\n\\begin{rawhtml} <TABLE  BORDER=1><TR>\n\\end{rawhtml}\n";
		while (@images) {
			$out .= "\n\\begin{rawhtml} <TD>\n\\end{rawhtml}\n" . &image( shift(@images),%options )
			        . "\n\\begin{rawhtml} </TD>\n\\end{rawhtml}\n" ;
		}

		$out .= "\n\\begin{rawhtml}</TR><TR>\\end{rawhtml}\n";
		while (@captions) {
			$out .= "\n\\begin{rawhtml} <TH>\n\\end{rawhtml}\n".&caption( shift(@captions) )
			        . "\n\\begin{rawhtml} </TH>\n\\end{rawhtml}\n" ;
		}

		$out .= "\n\\begin{rawhtml} </TR> </TABLE >\n\\end{rawhtml}";
	} elsif ($main::displayMode eq 'HTML' || $main::displayMode eq 'HTML_tth' || $main::displayMode eq 'HTML_dpng'|| $main::displayMode eq 'HTML_img'){
		$out .= "<P>\n <TABLE BORDER=2 CELLPADDING=3 CELLSPACING=2 ><TR ALIGN=CENTER		VALIGN=MIDDLE>\n";
		while (@images) {
			$out .= " \n<TD>". &image( shift(@images),%options ) ."</TD>";
		}
		$out .= "</TR>\n<TR>";
		while (@captions) {
			$out .= " <TH>". &caption( shift(@captions) ) ."</TH>";
		}
		$out .= "\n</TR></TABLE></P>\n"
	}
	else {
		$out = "Error: PGchoicemacros: imageRow: Unknown languageMode: $main::displayMode.\n";
		warn $out;
	}
	$out;
}


###########
# Auxiliary macros

sub display_options2{
	my %options = @_;
	my $out_string = "";
	foreach my $key (keys %options) {
		$out_string .= " $key => $options{$key},<BR>";
	}
	$out_string;
}


1;