#!/usr/local/bin/webwork-perl

###########
#use Carp;

=head1 NAME

	Matrix macros for the PG language

=head1 SYNPOSIS



=head1 DESCRIPTION

Almost all of the macros in the file are very rough at best.  The most useful is display_matrix.
Many of the other macros work with vectors and matrices stored as anonymous arrays. 

Frequently it may be
more useful to use the Matrix objects defined RealMatrix.pm and Matrix.pm and the constructs listed there.


=cut

BEGIN {
	be_strict();
}

sub _PGmatrixmacros_init {
}

# this subroutine zero_check is not very well designed below -- if it is used much it should receive
# more work -- particularly for checking relative tolerance.  More work needs to be done if this is 
# actually used.

sub zero_check{
    my $array = shift;
    my %options = @_;
	my $num = @$array;
	my $i;
	my $max = 0; my $mm;
	for ($i=0; $i< $num; $i++) {
		$mm = $array->[$i] ;
		$max = abs($mm) if abs($mm) > $max;
	}
    my $tol = $options{tol};
    $tol = 0.01*$options{reltol}*$options{avg} if defined($options{reltol}) and defined $options{avg};
    $tol = .000001 unless defined($tol);
	($max <$tol) ? 1: 0;       # 1 if the array is close to zero;
}
sub vec_dot{
	my $vec1 = shift;
	my $vec2 = shift;
	warn "vectors must have the same length" unless @$vec1 == @$vec2;  # the vectors must have the same length.
	my @vec1=@$vec1;
	my @vec2=@$vec2;
	my $sum = 0;

	while(@vec1) {
		$sum += shift(@vec1)*shift(@vec2);
	}
	$sum;
}
sub proj_vec {
	my $vec = shift;
	warn "First input must be a column matrix" unless ref($vec) eq 'Matrix' and ${$vec->dim()}[1] == 1; 
	my $matrix = shift;    # the matrix represents a set of vectors spanning the linear space 
	                       # onto which we want to project the vector.
	warn "Second input must be a matrix" unless ref($matrix) eq 'Matrix' and ${$matrix->dim()}[1] == ${$vec->dim()}[0];
	$matrix * transpose($matrix) * $vec;
}
	        
sub vec_cmp{    #check to see that the submitted vector is a non-zero multiple of the correct vector
    my $correct_vector = shift;
    my %options = @_;
	my $ans_eval = sub {
		my $in =  shift @_;
		
		my $ans_hash = new AnswerHash;
		my @in = split("\0",$in);
		my @correct_vector=@$correct_vector;		
		$ans_hash->{student_ans} = "( " . join(", ", @in ) . " )";
		$ans_hash->{correct_ans} = "( " . join(", ", @correct_vector ) . " )";

		return($ans_hash) unless @$correct_vector == @in;  # make sure the vectors are the same dimension
		
		my $correct_length = vec_dot($correct_vector,$correct_vector);
		my $in_length = vec_dot(\@in,\@in);
		return($ans_hash) if $in_length == 0; 

		if (defined($correct_length) and $correct_length != 0) {
			my $constant = vec_dot($correct_vector,\@in)/$correct_length;
			my @difference = ();
			for(my $i=0; $i < @correct_vector; $i++ ) {
				$difference[$i]=$constant*$correct_vector[$i] - $in[$i];
			}
			$ans_hash->{score} = zero_check(\@difference);
			
		} else {
			$ans_hash->{score} = 1 if vec_dot(\@in,\@in) == 0;
		}
		$ans_hash;
		
    };
    
    $ans_eval;
}

############

=head4  display_matrix

		Usage	  \{ display_matrix( [ [1, '\(\sin x\)'], [ans_rule(5), 6] ]) \}
            \{ display_matrix($A, align=>'crvl') \}
	          \[ \{   display_matrix_mm($A)  \} \]
		        \[ \{ display_matrix_mm([ [1, 3], [4, 6] ])  \} \]

    display_matrix produces a matrix for display purposes.  It checks whether
	  it is producing LaTeX output, or if it is displaying on a web page in one
	  of the various modes.  The input can either be of type Matrix, or a
	  reference to an array.

	  Entries can be numbers, bits of math mode, or answer boxes.

	  display_matrix_mm functions similarly, except that it should be inside
	  math mode.  display_matrix_mm cannot contain answer boxes in its entries.
	  Entries to display_matrix_mm should assume that they are already in
	  math mode.

	  Both functions take an optional alignment string, similar to ones in
	  LaTeX tabulars and arrays.  Here c for centered columns, l for left
	  flushed columns, and r for right flushed columns.

	  The alignment string can also specify vertical rules to be placed in the
	  matrix.  Here s or | denote a solid line, d is a dashed line, and v
	  requests the default vertical line.  This can be set on a system-wide
	  or course-wide basis via the variable $defaultDisplayMatrixStyle, and
	  it can default to solid, dashed, or no vertical line (n for none).

	  The matrix has left and right delimiters also specified by
	  $defaultDisplayMatrixStyle.  They can be parentheses, square brackets,
  	braces, vertical bars, or none.  The default can be overridden in
	  an individual problem with optional arguments such as left=>"|", or
	  right=>"]".


=cut


sub display_matrix_mm{    # will display a matrix in tex format.  
                       # the matrix can be either of type array or type 'Matrix'
	return display_matrix(@_, 'force_tex'=>1);
}

sub display_matrix_math_mode {
	return display_matrix_mm(@_);
}

sub display_matrix {
	my $ra_matrix = shift;
	my %opts = @_;
	# Now a global variable?
	my $styleParams = defined($main::defaultDisplayMatrixStyle) ?
		$main::defaultDisplayMatrixStyle : "(s)";
	
	set_default_options(\%opts,
											'_filter_name' => 'displaymat',
											'force_tex' => 0,
											'left' => substr($styleParams,0,1),
											'right' => substr($styleParams,2,1),
											'midrule' => substr($styleParams,1,1),
											'allow_unknown_options'=> 1);
	
	my ($numRows, $numCols, @myRows);

	if (ref($ra_matrix) eq 'Matrix' )  {
		($numRows, $numCols) = $ra_matrix->dim();
		for( my $i=0; $i<$numRows; $i++) {
			$myRows[$i] = [];
			for (my $j=0; $j<$numCols; $j++) {
				my $entry = $ra_matrix->element($i+1,$j+1);
				$entry = "#" unless defined($entry);
				push @{ $myRows[$i] },  $entry;
			}
		}
	} else { # matrix is input at [ [1,2,3],[4,5,6]]
		$numCols = 0;
		@myRows = @{$ra_matrix};
		$numRows = scalar(@myRows); # counts horizontal rules too
		my $tmp;
		for $tmp (@myRows) {
			if($tmp ne 'hline') {
				my @arow = @{$tmp};
				$numCols= scalar(@arow);   #number of columns in table
				last;
			}
		}
	}
	my $out;
	my $j;
	my $alignString=''; # alignment as a string for dvi/pdf
	my $alignList;      # alignment as a list
	
	if(defined($opts{'align'})) {
		$alignString= $opts{'align'};
		$alignString =~ s/v/$opts{'midrule'}/g;
		$alignString =~ tr/s/|/; # Treat "s" as "|"
		$alignString =~ tr/n//;  # Remove "n" altogether
		@$alignList = split //, $alignString;
	} else {
		for($j=0; $j<$numCols; $j++) {
			$alignList->[$j] = "c";
			$alignString .= "c";
		}
	}

	$out .= dm_begin_matrix($alignString, %opts);
	$out .= dm_mat_left($numRows, %opts);
	# vertical lines put in with first row
	$j = shift @myRows;
	$out .= dm_mat_row($j, $alignList, %opts, 'isfirst'=>$numRows);
	for $j (@myRows) {
		$out .= dm_mat_row($j, $alignList, %opts, 'isfirst'=>0);
	}
	$out .= dm_mat_right($numRows, %opts);
	$out .= dm_end_matrix(%opts);
	$out;
}

sub dm_begin_matrix {
	my ($aligns)=shift;   #alignments of columns in table
	my %opts = @_;
	my $out =	"";
	if ($main::displayMode eq 'TeX' or $opts{'force_tex'}) {
#		$out .= "\n";
		# This should be doable by regexp, but it wasn't working for me
		my ($j, @tmp);
		@tmp = split //, $aligns;
		$aligns='';
		for $j (@tmp) {
			# I still can't get an @ expression sent to TeX, so plain
			# vertical line
			$aligns .= ($j eq "d") ? '|' : $j;
		}
		$out .= $opts{'force_tex'} ? '' : '\(';
		$out .= '\displaystyle\left'.$opts{'left'}."\\begin{array}{$aligns} \n";
		}
	elsif ($main::displayMode eq 'Latex2HTML') {
		$out .= "\n\\begin{rawhtml} <TABLE  BORDER=0>\n\\end{rawhtml}";
		}
	elsif ($main::displayMode eq 'HTML' || $main::displayMode eq 'HTML_tth' || $main::displayMode eq 'HTML_dpng' || $main::displayMode eq 'HTML_img') {
		$out .= "<TABLE BORDER=0>\n"
	}
	else { 
		$out = "Error: dm_begin_matrix: Unknown displayMode: $main::displayMode.\n";
		}
	$out;
}


sub dm_mat_left {
	my $numrows = shift;
	my %opts = @_;
	if ($main::displayMode eq 'TeX' or $opts{'force_tex'}) {
		return "";
	}
	my $out='';
	my $j;
	my ($brh, $erh) = ("",""); # Start and end raw html
	if($main::displayMode eq 'Latex2HTML') {
		$brh = "\\begin{rawhtml}";
		$erh = "\\end{rawhtml}";
	}

	if(($main::displayMode eq 'HTML_dpng') || $main::displayMode eq 'HTML_img' || ($main::displayMode eq 'Latex2HTML')) {
 		$out .= "$brh<tr valign=\"center\"><td nowrap=\"nowrap\" align=\"left\">$erh";
		$out .= dm_image_delimeter($numrows, $opts{'left'});
 		$out .= "$brh<td><table border=0  cellspacing=5>\n$erh";
		return $out;
	}
	# Mode is now tth

	$out .= dm_tth_delimeter($numrows, $opts{'left'});
	$out .= "<td><table border=0  cellspacing=5>\n";
	return $out;
}

sub dm_mat_right {
	my $numrows = shift;
	my %opts = @_;
	my $out='';
	my $j;
	
	if ($main::displayMode eq 'TeX' or $opts{'force_tex'}) {
		return "";
	}

	if(($main::displayMode eq 'HTML_dpng') ||$main::displayMode eq 'HTML_img'|| ($main::displayMode eq 'Latex2HTML')) {
		if($main::displayMode eq 'Latex2HTML') { $out .= '\begin{rawhtml}'; }
		$out .= "</table><td nowrap=\"nowrap\" align=\"right\">";
		if($main::displayMode eq 'Latex2HTML') { $out .= '\end{rawhtml}'; }
		
#		$out .= "<img alt=\"(\" src = \"".
#			"/webwork_system_html/images"."/right$numrows.png\" >";
		$out.= dm_image_delimeter($numrows, $opts{'right'});
		return $out;
	}

	$out .= "</table>";

	$out .= dm_tth_delimeter($numrows, $opts{'right'});
	return $out;
}

sub dm_end_matrix {
	my %opts = @_;
	
	my $out = "";
	if ($main::displayMode eq 'TeX' or $opts{'force_tex'}) {
		$out .= "\n\\end{array}\\right$opts{right}";
		$out .= $opts{'force_tex'} ? '' : "\\) ";
		}
	elsif ($main::displayMode eq 'Latex2HTML') {
		$out .= "\n\\begin{rawhtml} </TABLE >\n\\end{rawhtml}";
		}
	elsif ($main::displayMode eq 'HTML' || $main::displayMode eq 'HTML_tth' || $main::displayMode eq 'HTML_dpng'||$main::displayMode eq 'HTML_img') {
		$out .= "</TABLE>\n";
		}
	else {
		$out = "Error: PGmatrixmacros: dm_end_matrix: Unknown displayMode: $main::displayMode.\n";
		}
	$out;
}

# Make an image of a big delimiter for a matrix
sub dm_image_delimeter {
	my $numRows = shift;
	my $char = shift;
	my ($out, $j);

	if($char eq ".") {return("");}
	if($char eq "d") { # special treatment for dashed lines
		$out='\(\vbox to '.($numRows*1.7).'\baselineskip ';
		$out .='{\cleaders\hbox{\vbox{\hrule width0pt height3pt depth0pt';
		$out .='\hrule width0.3pt height6pt depth0pt';
		$out .='\hrule width0pt height3pt depth0pt}}\vfil}\)';
		return($out);
	}
	if($char eq "|") {
		$out='\(\vbox to '.($numRows*1.4).'\baselineskip ';
		$out .='{\cleaders\vrule width0.3pt';
		$out .='\vfil}\)';
		return($out);
	}
	if($char eq "{") {$char = '\lbrace';}
	if($char eq "}") {$char = '\rbrace';}
	$out .= '\(\setlength{\arraycolsep}{0in}\left.\begin{array}{c}';
	for($j=0;$j<=$numRows;$j++)  { $out .= '\! \\\\'; }
	$out .= '\end{array}\right'.$char.'\)';
	return($out);
}

# Basically uses a table of special characters and simple
# recipe to produce big delimeters a la tth mode
sub dm_tth_delimeter {
	my $numRows = shift;
	my $char = shift;

	if($char eq ".") { return("");}
	my ($top, $mid, $bot, $extra);
	my ($j, $out);

	if($char eq "(") { ($top, $mid, $bot, $extra) = ('�','�','�','�');}
	elsif($char eq ")") { ($top, $mid, $bot, $extra) = ('�','�','�','�');}
	elsif($char eq "|") { ($top, $mid, $bot, $extra) = ('�','�','�','�');}
	elsif($char eq "[") { ($top, $mid, $bot, $extra) = ('�','�','�','�');}
	elsif($char eq "]") { ($top, $mid, $bot, $extra) = ('�','�','�','�');}
	elsif($char eq "{") { ($top, $mid, $bot, $extra) = ('�','�','�','�');}
	elsif($char eq "}") { ($top, $mid, $bot, $extra) = ('�','�','�','�');}
	else { warn "Unknown delimiter in dm_tth_delimeter";}

	$out = '<td nowrap="nowrap" align="left"><font face="symbol">';
	$out .= "$top<br />";
	for($j=1;$j<$numRows; $j++) {
		$out .= "$mid<br />";
	}
	$out .= "$extra<br />";
	for($j=1;$j<$numRows; $j++) {
		$out .= "$mid<br />";
	}
	$out .= "$bot</font></td>\n";
	return $out;
}

# Make a row for the matrix
sub dm_mat_row {
	my $elements = shift;
	my $tmp = shift;
	my @align =  @{$tmp} ;
	my %opts = @_;
	my @elements = @{$elements};
	my $out = "";
	my ($brh, $erh) = ("",""); # Start and end raw html
	if($main::displayMode eq 'Latex2HTML') {
		$brh = "\\begin{rawhtml}";
		$erh = "\\end{rawhtml}";
	}
	if ($main::displayMode eq 'TeX' or $opts{'force_tex'}) {
		while (@elements) {
			$out .= shift(@elements) . " &";
			}
		 chop($out); # remove last &
		 $out .= "\\cr  \n";
		 # carriage returns must be added manually for tex
		} 	elsif ($main::displayMode eq 'HTML' || $main::displayMode eq 'HTML_tth'
				 || $main::displayMode eq 'HTML_dpng'
				 || $main::displayMode eq 'HTML_img'
				 || $main::displayMode eq 'Latex2HTML') {
		$out .=  "$brh\n<TR>\n$erh";
		while (@elements) {
			my $myalign;
			$myalign = shift @align;
			if($myalign eq "|" or $myalign eq "d") {
				if($opts{'isfirst'} && $main::displayMode ne 'HTML_tth') {
					$out .= $brh.'<td rowspan="'.$opts{'isfirst'}.'">'.$erh;
					$out .= dm_image_delimeter($opts{'isfirst'}-1, $myalign);
				} elsif($main::displayMode eq 'HTML_tth') {
					if($myalign eq "d") { # dashed line in tth mode
						$out .= '<td> | </td>';
					} elsif($opts{'isfirst'}) { # solid line in tth mode
						$out .= '<td rowspan="'.$opts{'isfirst'}.'"<table border="0"><tr>';
						$out .= dm_tth_delimeter($opts{'isfirst'}-1, "|");
						$out .= '</td></tr></table>';
					}
				}
			} else {
				if($myalign eq "c") { $myalign = "center";}
				if($myalign eq "l") { $myalign = "left";}
				if($myalign eq "r") { $myalign = "right";}
				$out .= "$brh<TD nowrap=\"nowrap\" align=\"$myalign\">$erh" . shift(@elements) . "$brh</TD>$erh";
			}
		}
		$out .= "$brh\n</TR>\n$erh";
	}
	else {
		$out = "Error: dm_mat_row: Unknown displayMode: $main::displayMode.\n";
		}
	$out;
}

=head4  mbox

		Usage	\{ mbox(thing1, thing2, thing3) \}
          \{ mbox([thing1, thing2, thing3], valign=>'top') \}

    mbox takes a list of constructs, such as strings, or outputs of
	  display_matrix, and puts them together on a line.  Without mbox, the
	  output of display_matrix would always start a new line.

	  The inputs can be just listed, or given as a reference to an array.
	  With the latter, optional arguments can be given.

	  Optional arguments are allowbreaks=>'yes' to allow line breaks in TeX
	  output; and valign which sets vertical alignment on web page output.

=cut
	
sub mbox {
	my $inList = shift;
	my %opts;
	if(ref($inList) eq 'ARRAY') {
		%opts = @_;
	} else {
		%opts = ();
		$inList = [$inList, @_];
	}

	set_default_options(\%opts,
											'_filter_name' => 'mbox',
											'valign' => 'middle',
											'allowbreaks' => 'no',
											'allow_unknown_options'=> 0);
	if(! $opts{'allowbreaks'}) { $opts{'allowbreaks'}='no';}
	my $out = "";
	my $j;
	my ($brh, $erh) = ("",""); # Start and end raw html if needed
	if($main::displayMode eq 'Latex2HTML') {
		$brh = "\\begin{rawhtml}";
		$erh = "\\end{rawhtml}";
	}
	my @hlist = @{$inList};
	if($main::displayMode eq 'TeX') {
		if($opts{allowbreaks} ne 'no') {$out .= '\mbox{';}
		for $j (@hlist) { $out .= $j;}
		if($opts{allowbreaks} ne 'no') {$out .= '}';}
	} else {
		$out .= qq!$brh<table><tr valign="$opts{'valign'}">$erh!;
		for $j (@hlist) {
			$out .= qq!$brh<td align="center" nowrap="nowrap">$erh$j$brh</td>$erh!;
		}
		$out .= "$brh</table>$erh";
	}
	return $out;
}
		

=head4   ra_flatten_matrix

		Usage:   ra_flatten_matrix($A)
		
			where $A is a matrix object
			The output is a reference to an array.  The matrix is placed in the array by iterating
			over  columns on the inside
			loop, then over the rows. (e.g right to left and then down, as one reads text)


=cut


sub ra_flatten_matrix{
	my $matrix = shift;
	warn "The argument must be a matrix object" unless ref($matrix) =~ /Matrix/;
	my @array = ();
 	my ($rows, $cols ) = $matrix->dim();
	foreach my $i (1..$rows) {
		foreach my $j (1..$cols) {
   			push(@array, $matrix->element($i,$j)  );
   		}
   	}
   	\@array;
}

# This subroutine is probably obsolete and not generally useful.  It was patterned after the APL
# constructs for multiplying matrices. It might come in handy for non-standard multiplication of 
# of matrices (e.g. mod 2) for indice matrices.
sub apl_matrix_mult{
	my $ra_a= shift;
	my $ra_b= shift;
	my %options = @_;
	my $rf_op_times= sub {$_[0] *$_[1]};
	my $rf_op_plus = sub {my $sum = 0; my @in = @_; while(@in){ $sum = $sum + shift(@in) } $sum; };
	$rf_op_times = $options{'times'} if defined($options{'times'}) and ref($options{'times'}) eq 'CODE';
	$rf_op_plus = $options{'plus'} if defined($options{'plus'}) and ref($options{'plus'}) eq 'CODE';
	my $rows = @$ra_a;
	my $cols = @{$ra_b->[0]};
	my $k_size = @$ra_b;
	my $out ;
	my ($i, $j, $k);
	for($i=0;$i<$rows;$i++) {
		for($j=0;$j<$cols;$j++) {
		    my @r = ();
		    for($k=0;$k<$k_size;$k++) {
		    	$r[$k] =  &$rf_op_times($ra_a->[$i]->[$k] , $ra_b->[$k]->[$j]);
		    }
			$out->[$i]->[$j] = &$rf_op_plus( @r );
		}
	}
	$out;
}

sub matrix_mult {
	apl_matrix_mult($_[0], $_[1]);
}

sub make_matrix{
	my $function = shift;
	my $rows = shift;
	my $cols = shift;
	my ($i, $j, $k);
	my $ra_out;
	for($i=0;$i<$rows;$i++) {
		for($j=0;$j<$cols;$j++) {
			$ra_out->[$i]->[$j] = &$function($i,$j);
		}
	}
	$ra_out;
}

# sub format_answer{
# 	my $ra_eigenvalues = shift;
# 	my $ra_eigenvectors = shift;
# 	my $functionName = shift;
# 	my @eigenvalues=@$ra_eigenvalues;
# 	my $size= @eigenvalues;
# 	my $ra_eigen = make_matrix( sub {my ($i,$j) = @_; ($i==$j) ? "e^{$eigenvalues[$j] t}": 0 }, $size,$size);
# 	my $out = qq!
# 				$functionName(t) =! .
# 				                    displayMatrix(apl_matrix_mult($ra_eigenvectors,$ra_eigen,
#                                     'times'=>sub{($_[0] and $_[1]) ? "$_[0]$_[1]"  : ''},
#                                     'plus'=>sub{ my $out = join("",@_); ($out) ?$out : '0' }
#                                     ) ) ;
#        $out;
# }
# sub format_vector_answer{
# 	my $ra_eigenvalues = shift;
# 	my $ra_eigenvectors = shift;
# 	my $functionName = shift;
# 	my @eigenvalues=@$ra_eigenvalues;
# 	my $size= @eigenvalues;
# 	my $ra_eigen = make_matrix( sub {my ($i,$j) = @_; ($i==$j) ? "e^{$eigenvalues[$j] t}": 0 }, $size,$size);
# 	my $out = qq!
# 				$functionName(t) =! .
# 				                    displayMatrix($ra_eigenvectors)."e^{$eigenvalues[0] t}" ;
#        $out;
# }
# sub format_question{
# 	my $ra_matrix = shift;
# 	my $out = qq! y'(t) = ! . displayMatrix($B). q! y(t)!
# 
# }

1;