

sub full_partial_grader {
    # Get the standard inputs to a grader:
        my $rh_evaluated_answers = shift;
        my $rh_orig_problem_state = shift;
        my %original_problem_state = %$rh_orig_problem_state;
        my %form_options = @_;
        #  The hash $rh_evaluated_answers typically contains:
        #      'AnSwEr1' => 34, 'AnSwEr2'=> 'Mozart', etc.


        # Evaluate these inputs using the "average problem grader"
        my ($rh_problem_result, $rh_problem_state) =
            &avg_problem_grader($rh_evaluated_answers,$rh_orig_problem_state,%form_options);




#       #If the final answer is correct, then the problem is given full credit
#       # and a message is generated to that effect.


    my $count = keys %{$rh_evaluated_answers};
    my $last_label = 'AnSwEr'.$count;


        if (defined($rh_evaluated_answers->{$last_label}) and ${ $rh_evaluated_answers->{$last_label} }{score} == 1) {
                $rh_problem_result->{score} = 1;
                ${ $rh_evaluated_answers->{$last_label} }{ans_message} =
                  'You get full credit for this problem because this answer is correct.';


        $rh_problem_state->{recorded_score} = $rh_problem_result->{score} if
          $rh_problem_result->{score} > $rh_problem_state->{recorded_score};
        }


        # change the problem message
        $rh_problem_result->{msg} = 'You can earn full credit by answering just the last part.' if $count > 1;
        $rh_problem_result->{type} = 'full_partial_grader';  # change grader type


        # return the correct data
        if ($rh_problem_result->{score} == 1) {
            $rh_problem_state->{num_of_correct_ans} = $original_problem_state{num_of_correct_ans} + 1;
            $rh_problem_state->{num_of_incorrect_ans} = $original_problem_state{num_of_incorrect_ans};
        }
        else {
            $rh_problem_state->{num_of_correct_ans} = $original_problem_state{num_of_correct_ans};
            $rh_problem_state->{num_of_incorrect_ans} = $original_problem_state{num_of_incorrect_ans}+1;
     }



        # Return the results of grading the problem.
        ($rh_problem_result, $rh_problem_state);
}


################################################################
# We need a special problem grader on this problem, since we
# want the student to get full credit for all five answers correct,
# 60% credit for four correct, and 0% for three or fewer correct.
# To change this scheme, look through the following mess of code
# for the place where the variable $numright appears, and change
# that part.
# Also change the long line beginning "msg ==>", to show what will
# appear on the screen for the student.
#
# To look at the problem itself, look for the boxed comment below
# announcing the problem itself.
################################################################


sub custom_problem_grader_0_60_100 {
    my $rh_evaluated_answers = shift;
    my $rh_problem_state = shift;
    my %form_options = @_;
    my %evaluated_answers = %{$rh_evaluated_answers};
        #  The hash $rh_evaluated_answers typically contains: 
        #      'answer1' => 34, 'answer2'=> 'Mozart', etc.
       
        # By default the  old problem state is simply passed back out again.
    my %problem_state = %$rh_problem_state;
        
        
        # %form_options might include
        # The user login name 
        # The permission level of the user
        # The studentLogin name for this psvn.
        # Whether the form is asking for a refresh or
        #     is submitting a new answer.
        
        # initial setup of the answer
    my      $total=0; 
        my %problem_result = ( score => 0,
                errors => '',
                type => 'custom_problem_grader',
                msg => 'To get full credit, all answers must be correct.  Having
 all but one correct is worth 60%.  Two or more incorrect answers gives a score 
of 0%.',
                               );


    # Return unless answers have been submitted
    unless ($form_options{answers_submitted} == 1) {
    
    # Since this code is in a .pg file we must use double tildes 
    # instead of Perl's backslash on the next line.
        return(\%problem_result,\%problem_state);
    }
        # Answers have been submitted -- process them.
        
        ########################################################
        # Here's where we compute the score.  The variable     #
        # $numright is the number of correct answers.          #
        ########################################################


    my      $numright=0;


    $numright += ($evaluated_answers{'AnSwEr1'}->{score});
    $numright += ($evaluated_answers{'AnSwEr2'}->{score});
    $numright += ($evaluated_answers{'AnSwEr3'}->{score});
    $numright += ($evaluated_answers{'AnSwEr4'}->{score});
    $numright += ($evaluated_answers{'AnSwEr5'}->{score});


    if ($numright == 5) {
        $total = 1;
    } elsif ($numright == 4) {
        $total = 0.6;
    } else {
        $total = 0;
    }


    $problem_result{score} = $total; 
        # increase recorded score if the current score is greater.
    $problem_state{recorded_score} = $problem_result{score} if $problem_result{score} > $problem_state{recorded_score};


        
    $problem_state{num_of_correct_ans}++ if $total == 1;
    $problem_state{num_of_incorrect_ans}++ if $total < 1 ;
        
        # Since this code is in a .pg file we must use double tildes 
    # instead of Perl's backslash on the next line.
    (\%problem_result, \%problem_state);


}

################################################################
# This problem grader was contributed by Prof. Zig Fiedorowicz,
# Dept. of Mathematics, Ohio State University on 8/25/01.
# As written, the problem grader should be put in a separate macro file.
# If actually inserted into a problem, you need to replace a couple
# of backslashes by double tildes.

# This is a generalization of the previous custom grader.
# This grader expects two array references to be passed to it, eg.
# $ENV['grader_numright'] = [2,5,7,10];
# $ENV['grader_scores'] = [0.1,0.4,0.6,1]
# Both arrays should be of the same length, and in strictly
# increasing order. The first array is an array of possible
# raw scores, the number of parts of the problem the student might
# get right. The second array is the corresponding array of scores
# the student would be credited with for getting that many parts
# right. The scores should be real numbers between 0 and 1.
# The last element of the 'grader_scores' array should be 1 (perfect
# score). The corresponding last element of 'grader_numright' would
# be the total number of parts of the problem the student would have
# to get right for a perfect score. Normally this would be the total
# number of parts to the problem. In the example shown above, the
# student would get 10% credit for getting 2-4 parts right, 40%
# credit for getting 5-6 parts right, 60% credit for getting 7-9 parts
# right, and 100% credit for getting 10 (or more) parts right.
# A message to be displayed to the student about the grading policy
# for the problems should be passed via
# $ENV{'grader_message'} = "The grading policy for this problem is...";
# or something similar.
################################################################


sub custom_problem_grader_fluid {
    my $rh_evaluated_answers = shift;
    my $rh_problem_state = shift;
    my %form_options = @_;
    my %evaluated_answers = %{$rh_evaluated_answers};
        #  The hash $rh_evaluated_answers typically contains: 
        #      'answer1' => 34, 'answer2'=> 'Mozart', etc.
       
        # By default the  old problem state is simply passed back out again.
    my %problem_state = %$rh_problem_state;
        
        
        # %form_options might include
        # The user login name 
        # The permission level of the user
        # The studentLogin name for this psvn.
        # Whether the form is asking for a refresh or
        #     is submitting a new answer.
        
        # initial setup of the answer
    my      $total=0; 
        my %problem_result = ( score => 0,
                errors => '',
                type => 'custom_problem_grader',
                msg => $ENV{'grader_message'}
                               );


    # Return unless answers have been submitted
    unless ($form_options{answers_submitted} == 1) {
    
    # Since this code is in a .pg file we must use double tildes 
    # instead of Perl's backslash on the next line.
        return(\%problem_result,\%problem_state);
    }
        # Answers have been submitted -- process them.
        
        ########################################################
        # Here's where we compute the score.  The variable     #
        # $numright is the number of correct answers.          #
        ########################################################


    my      $numright=0;
    my      $i;
    my      $ans_ref;
    my      @grader_numright = @{$ENV{'grader_numright'}};
    my      @grader_scores = @{$ENV{'grader_scores'}};


    if ($#grader_numright != $#grader_scores) {
        WARN("Scoring guidelines inconsistent: unequal arrays!");
    }
    for ($i=0;$i<$#grader_numright;$i++) {
      if($grader_numright[$i]>=$grader_numright[$i+1]) {
        WARN("Scoring guidelines inconsistent: raw scores not increasing!");
      }
      if($grader_scores[$i]>=$grader_scores[$i+1]) {
        WARN("Scoring guidelines inconsistent: scores not increasing!");
      }
    }
    if ($grader_scores[$#grader_scores] != 1) {
        WARN("Scoring guidelines inconsistent: best score < 1");
    }
    $i = 1;
    while (defined($ans_ref = $evaluated_answers{'AnSwEr'."$i"})) { 
      $numright += $ans_ref->{score};
      $i++;
    }
    
    for($i=0;$i<=$#grader_numright;$i++) {
      if ($numright>=$grader_numright[$i]) {
         $total = $grader_scores[$i];
      }
    }



    $problem_result{score} = $total; 
        # increase recorded score if the current score is greater.
    $problem_state{recorded_score} = $problem_result{score} if $problem_result{score} > $problem_state{recorded_score};


        
    $problem_state{num_of_correct_ans}++ if $total == 1;
    $problem_state{num_of_incorrect_ans}++ if $total < 1 ;
        
        # Since this code is in a .pg file we must use double tildes 
    # instead of Perl's backslash on the next line.
    (\%problem_result, \%problem_state);


}


# return 1 so that this file can be included with require
1