


####################################################################
# Copyright @ 1995-1999 University of Rochester
# All Rights Reserved
####################################################################

####################################################################
#
#  dangerousMacros.pl contains macros with potentially dangerous commands
#  such as require and eval.  They can reference disk files for reading and
#  writing and can create links.  It may be necessary to modify certain addresses
#  in this file to make the scripts run in different environments.
#
#

=head1 NAME

	 dangerousMacros.pl --- located in the courseScripts directory

=head1 SYNPOSIS

	loadMacros(macrofile1,macrofile2,...)

	insertGraph(graphObject);
	  returns a path to the file containing the graph image.

	tth(texString)
	  returns an HTML version of the tex code passed to it.

	alias(pathToFile);
	  returns URL which links to that file


=head1 DESCRIPTION


C<dangerousMacros.pl> contains macros with potentially dangerous commands
such as require and eval.  They can reference disk files for reading and
writing and can create links.  It may be necessary to modify certain addresses
in this file to make the scripts run properly in different environments.

C<dangerousMacros.pl> is loaded and reinitialized
every time a new problem is rendered.

=cut


######## Dangerous macros#########
## The macros in this file are defined while the safe compartment is wide open.
## Be careful!
#########################################


=head2 Sharing modules:

Most modules are loaded by dangerousMacros.pl

The modules must be loaded using require (not use) since the courseScriptsDirectory is
defined at run time.


 The following considerations come into play.

	* One needs to limit the access to modules for safety -- hence only
	 modules in the F<courseScriptsDirectory> can be loaded.

	* Loading them in dangerousMacros.pl is wasteful, since the modules
	 would need to be reloaded everytime a new safe compartment is created.
     (I believe that using require takes care of this.)

	* Loading GD within a safeCompartment creates infinite recurrsion in AUTOLOAD (probably a bug)
	 hence this module is loaded by translate.pl and then shared with
	 the safe compartment.

	* Other modules loaded by translate.pl are C<Exporter> and C<DynaLoader.

	* PGrandom is loaded by F<PG.pl> , since it is needed there.



The module name spaces loaded in dangerousMacros are:

	PGrandom (if not previously loaded)
	WWPlot
	Fun
	Label
	Circle

in addition the  subroutine &evaluate_units is shared from the module Units.

=cut

BEGIN {
	be_strict(); # an alias for use strict.  This means that all global variable must contain main:: as a prefix.

}


sub _dangerousMacros_init {
}

sub _dangerousMacros_export {
	my @EXPORT= (
	    '&_dangerousMacros_init',
		'&alias',
		'&compile_file',
		'&insertGraph',
		'&loadMacros',
		'&HEADER_TEXT',
		'&sourceAlias',
		'&tth',
	);
	@EXPORT;
}


=head2 loadMacros

C<loadMacros(macrofile1,macrofile2,...)>

loadMacros takes a list of file names and evaluates the contents of each file.  This is used to load macros
which define and augment the PG language.  The macro files are first searched for in the macro
directory of the course C<($macroDirectory)> and then, if not found, in the WeBWorK courseScripts
directory C<($courseScriptsDirectory)> where the default behavior of the PG language is defined.

An individual course can modify the PG language, B<for that course only>, by
duplicating one of the macro files in the courseScripts directory and placing this
file in the macro directory for the course. The new file in the course
macro directory will now be used instead of the file in the courseScripts directory.

The new file in the course macro directory can by modified by adding macros or modifying existing macros.

I< Modifying macros is for users with some experience.>

Modifying existing macros might break other standard macros or problems which depend on the
unmodified behavior of these macors so do this with great caution.
In addition problems which use new macros defined in these files or which depend on the
modified behavior of existing macros will not work in other courses unless the macros are also
transferred to the new course.  It helps to document the  problems by indicating any special macros
which the problems require.

There is no facility for modifying or overloading a single macro.  The entire file containing the macro
must be overloaded.

Modifications to files in the course macros directory affect only that course,
they will not interfere with the normal behavior of B<WeBWorK> in other courses.



=cut

# Global variables used
#   ${main::macroDirectory}
#	${main::courseScriptsDirectory}
# Global macros used
#	None

# Because of the need to use the directory variables it is tricky to define this
# in translate.pl since, as currently written, the directories are not available
# at that time.  Perhaps if I rewrite translate as an object that method will work.

# The only difficulty with defining loadMacros inside the Safe compartment is that
# the error reporting does not work with syntax errors.
# A kludge using require works around this problem


my ($macroDirectory,
	$courseScriptsDirectory,
	$templateDirectory,
	$scriptDirectory,
	);

sub loadMacros {
    my @files = @_;
    my $fileName;
    ###############################################################################
	# At this point the directories have been defined from %envir and we can define
	# the directories for this file
	###############################################################################

    $macroDirectory = eval('$main::macroDirectory') unless defined($macroDirectory);
    $courseScriptsDirectory = eval('$main::courseScriptsDirectory') unless defined($courseScriptsDirectory);
    $templateDirectory = eval('$main::courseScriptsDirectory') unless defined($templateDirectory);
    $scriptDirectory = eval('$main::scriptDirectory') unless defined($scriptDirectory);

    unless (defined( $main::externalTTHPath) and $main::externalTTHPath) {
    	warn "WARNING::Please make sure that the DOCUMENT() statement comes before<BR>\n" .
    	     " the loadMacros() statement in the problem template.<p>" .
    	     " The externalTTHPath variable |$main::externalTTHPath| was\n".
    	     " not defined which usually indicates the problem above.<br>\n";

    }
    #warn "running load macros";
    while (@files) {
        $fileName = shift @files;
        next  if ($fileName =~ /^PG.pl$/) ;    # the PG.pl macro package is already loaded.

        my $macro_file_name = $fileName;
		$macro_file_name =~s/\.pl//;  # trim off the extension
		$macro_file_name =~s/\.pg//;  # sometimes the extension is .pg (e.g. CAPA files)
		my $init_subroutine_name = "_${macro_file_name}_init";
    	my $macro_file_loaded;
 		#no strict;
 		###############################################################################
		# For some reason the "no stict" which works on webwork-db doesn't work on
		# webwork.  For this reason the constuction &{$init_subroutine_name}
		# was abandoned and replaced by eval.  This is considerably more dangerous
		# since one could hide something nasty in a file name.
		#  Keep an eye on this ???
		# webwork-db used perl 5.6.1 and webwork used perl 5.6.0  It seems
		# unlikely that this was the problem. Otherwise all files seemed to
		# be the same.
		###############################################################################

		local($temp::rf_init_subroutine);
 		eval qq{ \$temp::rf_init_subroutine = \\&main::$init_subroutine_name;};
		#warn "loadMacros: defining \$temp::rf_init_subroutine ",$temp::rf_init_subroutine;

		$macro_file_loaded	= defined($temp::rf_init_subroutine) && defined( &{$temp::rf_init_subroutine} );

        # macros are searched for first in the $macroDirectory of the course
        # and then in the webwork  $courseScripts directory.
        unless ($macro_file_loaded) {
        	#print STDERR "loadMacros: loading macro file $fileName\n";
			if (-r "${main::macroDirectory}$fileName") {
				compile_file("${main::macroDirectory}$fileName");

			} elsif (-r  "${main::courseScriptsDirectory}$fileName" ) {
				 compile_file("${main::courseScriptsDirectory}$fileName");
			} else {
				die "Can't locate macro file via path: |${main::macroDirectory}$fileName| or |${main::courseScriptsDirectory}$fileName|";
			}
		}
		# Try again to define the initialization subroutine.
		eval qq{ \$temp::rf_init_subroutine = \\&main::$init_subroutine_name;};
		#warn "loadMacros: defining \$temp::rf_init_subroutine ",$temp::rf_init_subroutine;

		if ( defined($temp::rf_init_subroutine) and defined( &{$temp::rf_init_subroutine} ) ) {
		    #print " &$init_subroutine_name defined = ", $macro_file_loaded,"\n";
			&{$temp::rf_init_subroutine}();  #initialize file
			#print "initializing $init_subroutine_name\n";
		}

	}
}

# errors in compiling macros is not always being reported.
sub compile_file {
 	my $filePath = shift;
 	local(*MACROFILE);
 	local($/);
 	$/ = undef;   # allows us to treat the file as a single line
 	open(MACROFILE, "<$filePath") || die "Cannot open file: $filePath";
 	my $string = <MACROFILE>;
 	my ($result,$error,$fullerror) = PG_restricted_eval($string);
 	if ($error) {    # the $fullerror report has formatting and is never empty
 		$fullerror =~ s/\(eval \d+\)/ $filePath\n/;   # attempt to insert file name instead of eval number
 		die "Error detected while loading $filePath:\n$fullerror";

 	}

 	close(MACROFILE);

}

# This creates on the fly graphs

=head2 insertGraph

	$filePath = insertGraph(graphObject);
		  returns a path to the file containing the graph image.

insertGraph(graphObject) writes a gif file to the C<html/tmp/gif> directory of the current course.
The file name
is obtained from the graphObject.  Warnings are issued if errors occur while writing to
the file.

The permissions and ownership of the file are controlled by C<$main::tmp_file_permission>
and C<$main::numericalGroupID>.

B<Returns:>   A string containing the full path to the temporary file containing the GIF image.



InsertGraph draws the object $graph, stores it in "${tempDirectory}gif/$gifName.gif (or .png)" where
the $imageName is obtained from the graph object.  ConvertPath and surePathToTmpFile are used to insure
that the correct directory separators are used for the platform and that the necessary directories
are created if they are not already present.

The directory address to the file is the result.  This is most often used in the construct

	TEXT(alias(insertGraph($graph)) );

where alias converts the directory address to a URL when serving HTML pages and insures that
an eps file is generated when creating TeX code for downloading.

=cut

# Global variables used:
#	$main::tmp_file_permission,
#	$main::numericalGroupID

#Global macros used:
#   &convertPath
#   &surePathToTmpFile

sub insertGraph {
		    # Convert the image to GIF and print it on standard output
	my $graph = shift;
	my $extension = ($WWPlot::use_png) ? '.png' : '.gif';
	my $fileName = $graph->imageName  . $extension;
	my $filePath = convertPath("gif/$fileName");
	$filePath = &surePathToTmpFile( $filePath );
 	#createFile($filePath, $main::tmp_file_permission, $main::numericalGroupID);
	local(*OUTPUT);  # create local file handle so it won't overwrite other open files.
 	open(OUTPUT, ">$filePath")||warn ("$0","Can't open $filePath<BR>","");
 	chmod( 0777, $filePath);
 	print OUTPUT $graph->draw|| warn("$0","Can't print graph to $filePath<BR>","");
 	close(OUTPUT)||warn("$0","Can't close $filePath<BR>","");
	$filePath;
}



=head2 tth

	tth(texString)
  		returns an HTML version of the tex code passed to it.

This macro sends the texString to the filter program C<tth> created by Ian Hutchinson.
The tth program was created by Ian Hutchinson and is freely available
for B<non-commerical purposes> at the C<tth> main site: C<http://hutchinson.belmont.ma.us/tth/>.

The purpose of C<tth> is to translate text in the TeX or Latex markup language into
HTML markup as best as possible.  Some symbols, such as square root symbols are not
translated completely.  Macintosh users must use the "MacRoman" encoding (available in 4.0 and
higher browsers) in order to view the symbols correctly.  WeBWorK attempts to force Macintosh
browsers to use this encoding when such a browser is detected.

The contents of the file C<tthPreamble.tex> in the courses template directory are prepended
to each string.  This allows one to define TeX macros which can be used in every problem.
Currently there is no default C<tthPreamble.tex> file, so if the file is not present in the
course template directory no TeX macro definitions are prepended.  C<tth> already understands most
Latex commands, but will not, in general know I<AMS-Latex> commands.  Additional information
on C<tth> is available at the C<tth> main site.

This macro contains code which is system dependent and may need to be modified
to run on different systems.

=for html
The link to <CODE>tth</CODE> for <STRONG>non-commerical</STRONG> is
<A HREF="http://hutchinson.belmont.ma.us/tth/">http://hutchinson.belmont.ma.us/tth/</A>.
Binaries for many operating systems are available as well as the source code.  Links
describing how to obtain <CODE>tth</CODE> for commerical use are also available on this page.

=cut



# This file allows the tth display.
# Global variables:
#	${main::templateDirectory}tthPreamble.tex   # location of any preamble TeX commands for tth
#   ${main::templateDirectory}
#   ${main::scriptDirectory}tth        # path to tth application
# Global macros:
# 	None

my ($tthPreambleFile, $tthPreambleContents); # the contents of this file will not change during problem compilation
                                             # it only needs to be read once
sub tth {
	my $inputString = shift;

	# read the contents of the tthPreamble.tex file, unless it has already been read
	unless ( defined( $tthPreambleContents) ) {
		$tthPreambleFile = "${main::templateDirectory}tthPreamble.tex" if ( -r "${main::templateDirectory}tthPreamble.tex" );
		if ( defined($tthPreambleFile) )   {
			local(*TTHIN);
			open (TTHIN, "${main::templateDirectory}tthPreamble.tex") || die "Can't open file ${main::templateDirectory}tthPreamble.tex";
			#my @tthPreambleArray = <TTHIN>;
			local($/);
			$/ = undef;
			$tthPreambleContents = <TTHIN>;#join("",@tthPreambleArray);
			close(TTHIN);

			$tthPreambleContents =~ s/(.)\n/$1%\n/g;  # thanks to Jim Martino
			                                          # each line in the definition file
			                                          # should end with a % to prevent
			                                          # adding supurious paragraphs to output.

			$tthPreambleContents .="%\n";             # solves the problem if the file doesn't end with a return.

		} else {
			$tthPreambleContents = "";
		}
	}

    $inputString = $tthPreambleContents . $inputString;
    $inputString    = "<<END_OF_TTH_INPUT_STRING;\n\n\n" . $inputString . "\nEND_OF_TTH_INPUT_STRING\necho \"\" >/dev/null"; #it's not clear why another command is needed.

	# $tthpath is now taken from $Global::externalTTHPath via %envir.
    my $tthpath     = $envir{externalTTHPath};
    my $out;

    if (-x $tthpath ) {
    	my $tthcmd      = "$tthpath -L -f5 -u -r  2>/dev/null " . $inputString;
    	if (open(TTH, "$tthcmd   |")) {
    	    local($/);
			$/ = undef;
			$out = <TTH>;
			$/ = "\n";
			close(TTH);
	    }else {
	        $out = "<BR>there has been an error in executing $tthcmd<BR>";
	    }
	} else {
		$out = "<BR> Can't execute the program tth at |$tthpath|<BR>";
    }

    $out;
}

# possible solution to the tth font problem?  Works only for iCab.
sub symbolConvert {
	my	$string = shift;
	$string =~ s/\x5C/\&#092;/g;		#\      92                       &#092;
	$string =~ s/\x7B/\&#123;/g;		#{      123                       &#123;
	$string =~ s/\x7D/\&#125;/g;		#}      125                       &#125;
	$string =~ s/\xE7/\&#193;/g;		#�      231                       &#193;
	$string =~ s/\xE6/\&#202;/g;		#�      230                       &#202;
	$string =~ s/\xE8/\&#203;/g;		#�      232                       &#203;
	$string =~ s/\xF3/\&#219;/g;		#�      243                       &#219;
	$string =~ s/\xA5/\&bull;/g;		#�      165                       &bull;
	$string =~ s/\xB2/\&le;/g;			#�      178                       &le;
	$string =~ s/\xB3/\&ge;/g;			#�      179                       &ge;
	$string =~ s/\xB6/\&part;/g;		#�      182                       &part;
	$string =~ s/\xCE/\&#338;/g;		#�      206                       &#338;
	$string =~ s/\xD6/\&#732/g;			#�      214                       &#732;
	$string =~ s/\xD9/\&Yuml;/g;		#�      217                       &Yuml;
	$string =~ s/\xDA/\&frasl;/g;		#�      218                       &frasl;
	$string =~ s/\xF5/\&#305;/g;		#�      245                       &#305
	$string =~ s/\xF6/\&#710;/g;		#�      246                       &#710;
	$string =~ s/\xF7/\&#193;/g;		#�      247                       &#193;
	$string =~ s/\xF8/\&#175;/g;		#�      248                       &#175;
	$string =~ s/\xF9/\&#728;/g;		#�      249                       &#728;
	$string =~ s/\xFA/\&#729;/g;		#�      250                       &#729;
	$string =~ s/\xFB/\&#730;;/g;		#�      251                       &#730;
	$string;
}

# ----- ----- ----- -----

=head2 math2img

math2img(texString) - returns an IMG tag pointing to an image version of the supplied TeX

=cut

my $math2imgCount = 0;

sub math2img {
	my $tex = shift;
	my $mode = shift;

	my $sourcePath = $envir{templateDirectory} . "/" . $envir{fileName};
	my $tempFile = "m2i/$envir{studentLogin}.$envir{setNumber}.$envir{probNum}."
		. $math2imgCount++ . ".png";
	my $tempPath = surePathToTmpFile($tempFile); #my $tempPath = "$envir{tempDirectory}$tempFile";
	my $tempURL = "$envir{tempURL}/$tempFile";
	my $forceRefresh = $envir{refreshMath2img};
	my $imageMissing = not -e $tempPath;
	my $imageStale   = (stat $sourcePath)[9] > (stat $tempPath)[9] if -e $tempPath;
	if ($forceRefresh or $imageMissing or $imageStale) {
		# image file doesn't exist, or source file is newer then image file
		#warn "math2img: refreshMath2img forcing image generation for $tempFile\n" if $forceRefresh;
		#warn "math2img: $tempFile doesn't exist, so generating it\n" if $imageMissing;
		#warn "math2img: source file (", (stat $sourcePath)[9], ") is newer than image file (",
		#	(stat $tempPath)[9], ") so re-generating image\n" if $imageStale;
		if (-e $tempPath) {
			unlink $tempPath or die "Failed to delete stale math2img file $tempPath: $!";
		}
		dvipng(
			$envir{dvipngTempDir}, $envir{externalLaTeXPath},
			$envir{externalDvipngPath}, $tex, $tempPath
		);
	}

	if (-e $tempPath) {
		return "<img align=\"middle\" src=\"$tempURL\" alt=\"$tex\">"            if $mode eq "inline";
		return "<div align=\"center\"><img src=\"$tempURL\" alt=\"$tex\"></div>" if $mode eq "display";
	} else {
		return "<b>[math2img failed]</b>";
		# it might be nice to call tth here as a fallback instead:
		#return tth($tex);
	}
};


# copied from IO.pm for backward compatibility with WeBWorK1.8;
sub dvipng($$$$$) {
	my (
		$wd,        # working directory, for latex and dvipng garbage
		            # (must already exist!)
		$latex,     # path to latex binary
		$dvipng,    # path to dvipng binary
		$tex,       # tex string representing equation
		$targetPath # location of resulting image file
	) = @_;

	my $dvipngBroken = 0;

	my $texFile  = "$wd/equation.tex";
	my $dviFile  = "$wd/equation.dvi";
	my $dviFile2 = "$wd/equationequation.dvi";
	my $dviCall  = "equation";
	my $pngFile  = "$wd/equation1.png";

	unless (-e $wd) {
		die "dvipng working directory $wd doesn't exist -- caller should have created it for us!\n";
		return 0;
	}

	# write the tex file
	local *TEX;
	open TEX, ">", $texFile or warn "Failed to create $texFile: $!";
	print TEX <<'EOF';
% BEGIN HEADER
\batchmode
\documentclass[12pt]{article}
\usepackage{amsmath,amsfonts,amssymb}
\def\gt{>}
\def\lt{<}
\usepackage[active,textmath,displaymath]{preview}
\begin{document}
% END HEADER
EOF
	print TEX "\\( \\displaystyle{$tex} \\)\n";
	print TEX <<'EOF';
% BEGIN FOOTER
\end{document}
% END FOOTER
EOF
	close TEX;

	# call latex
	system "cd $wd && $latex $texFile > /dev/null"
		and warn "Failed to call $latex with $texFile: $!";

	unless (-e $dviFile) {
		warn "Failed to generate DVI file $dviFile";
		return 0;
	}

	if ($dvipngBroken) {
		# change the name of the DVI file to get around dvipng's
		# crackheadedness. This is no longer needed with the newest
		# version of dvipng (10 something)
		system "/bin/mv", $dviFile, $dviFile2;
	}

	# call dvipng -- using warn instead of die passes some extra information
	# back to the user the complete warning is still printed in the apache
	# error log and a simple message (math2img failed) is returned to the
	# webpage.
	my $cmdout;
	$cmdout = system "cd $wd && $dvipng $dviCall > /dev/null"
		and warn "Failed to call$dvipng with $dviCall: $! with signal $cmdout";

	unless (-e $pngFile) {
		warn "Failed to create PNG file $pngFile";
		return 0;
	}

	$cmdout = system "/bin/mv", $pngFile, $targetPath and warn "Failed to mv: /bin/mv  $pngFile $targetPath $!. Call returned $cmdout. \n";
}


# ----- ----- ----- -----

=head2  alias

	alias(pathToFile);
	  returns A string describing the URL which links to GIF or html file
	          (in HTML and Latex2HTML modes).
	          or a path to the appropriate eps version of a GIF file
	           (TeX Mode)



C<alias> allows you to refer to auxiliary files which are in a directory along with
the problem definition.  In addition alias creates an eps copy of GIF files when
downloading hard copy (TeX mode).

As a rule auxiliary files that are used by
a number of problems in a course should be placed in C<html/gif> or C<html>
or in a subdirectory of the C<html> directory,
while auxiliary files which are used in only one problem should be placed in
the same directory as the problem in order to make the problem more portable.



=over 4

=item  Files in the html subdirectory

B<When not in TeX mode:>

If the file lies under the C<html> subdirectory, then the approriate URL for the file is created.
Since the C<html> subdirectory is already accessible to the webserver no other changes need to be made.
The file path for this type of file should be the complete file path. The path should
start with the prefix defined in $Global:htmlDirectory.

B<When in TeX mode:>


GIF files will be translated into an eps file (using system dependent code)
and placed in the directory C<tmp/eps>.  The full path to this file is returned
for use by TeX in producing the hard copy. (This should work even in a chrooted
environment.) in producing the hard copy.   (This should work even in a chrooted
environment.)

The conversion is done by a system dependent script
called C<gif2eps> which should be in the scripts directory

The URL's for the other files are produced as in non-tex mode
but will of course not be active.

=item  Files in the tmp subdirectory

B<When not in TeX mode:>

If the file lies under the C<tmp> subdirectory, then the approriate URL for the file is created.
Since the C<tmp> subdirectory is already accessible to the webserver no other changes need to be made.
The file path for this type of file should be the complete file path. The path should
start with the prefix defined in $Global:tempDirectory.

B<When in TeX mode:>


GIF files will be translated into an eps file (using system dependent code)
and placed in the directory C<tmp/eps>.  The full path to this file is returned
for use by TeX in producing the hard copy.  (This should work even in a chrooted
environment.)

The conversion is done by a system dependent script
called C<gif2eps> which should be in the scripts directory

The URL's for the other files are produced as in non-tex mode
but will of course not be active.

=item Files in the course template subdirectory:

B<When not in TeX mode:>

If the file lies under the course templates subdirectory,
it is assumed to lie in subdirectory rooted in the directory
containing the problem template file.
An alias is created under the C<html/tmp/gif> or
C<html/tmp/html> directory and linked to the original file.
The file path for this type of file is a relative
path rooted at the directory containing the problem template file.

B<When in TeX mode:>

GIF files will be translated into an eps file (using system dependent code)
and placed in the directory C<html/tmp/eps>.  The full path to this file is returned
for use by TeX in producing the hard copy.   (This should work even in a chrooted
environment.)

The conversion is done by a system dependent script
called C<gif2eps> which should be in the scripts directory

The URL's for the other files are produced as in non-tex mode
but will of course not be active.

=back

=cut



# Currently gif, html and types are supported.
#
# If the auxiliary file path has not extension then the extension .gif isassumed.
#
# If the auxiliary file path leads to a file in the ${Global::htmlDirectory}
# no changes are made to the file path.
#
# If the auxiliary file path is not complete, than it is assumed that it refers
# to a subdirectoy of the directory containing the problem..
#
# The output is either the correct URL for the file
# or (in TeX mode) the complete path to the eps version of the file
# and can be used as input into the image macro.
#
# surePathToTmpFile takes a path and outputs the complete path:
# ${main::htmlDirectory}/tmp/path
# It insures that all of the directories in the path have been created,
# but does not create the
# final file.

# For postscript printing, alias generates an eps version of the gif image and places
# it in the directory eps.  This slows down downloading postscript versions somewhat,
# but not excessivevly.
# Alias does not do any garbage collection, so files and alias may accumulate and
# need to be removed manually or by a reaper daemon.


# Global variables used:
#  $main::fileName  # the full path to the current problem template file
#  $main::htmlDirectory
#  $main::htmlURL
#  $main::tempDirectory
#  $main::tempURL
#  $main::studentLogin
#  $main::psvnNumber
#  $main::setNumber
#  $main::probNum
#  $main::displayMode

# Global macros used
# gif2eps   An external file called by system
# surePathToTmpFile
# convertPath
# directoryFromPath


# This subroutine  has commands which will not work on non-UNIX environments.
# system("cat $gifSourceFile  | /usr/math/bin/giftopnm | /usr/math/bin/pnmdepth 1 | /usr/math/bin/pnmtops -noturn>$adr_output") &&


# local constants $User, $psvn $setNumber $probNum $displayMode

sub sourceAlias {
	my $path_to_file = shift;
	my $user = $main::inputs_ref->{user};
	$user = " " unless defined($user);
    my $out = "source.pl?probSetKey=$main::psvn".
  			"&amp;probNum=$main::probNum" .
   			"&amp;Mode=$main::displayMode" .
   			"&amp;course=". $main::courseName .
    		"&amp;user=" . $user .
			"&amp;displayPath=$path_to_file" .
	   		"&amp;key=". $main::sessionKey;

 	 $out;
}


sub alias {
	# input is a path to the original auxiliary file
  	#my $fileName = $main::fileName;
	#my $htmlDirectory = $main::htmlDirectory;
	#my $htmlURL = $main::htmlURL;
	#my $tempDirectory = $main::tempDirectory;
	#my $tempURL =  $main::tempURL;
	#my $studentLogin =  $main::studentLogin;
	#my $psvnNumber =  $main::psvnNumber;
	#my $setNumber =  $main::setNumber;
	#my $probNum =  $main::probNum;
	#my $displayMode =  $main::displayMode;


	my $aux_file_path = shift @_;
	warn "Empty string used as input into the function alias" unless $aux_file_path;

	# problem specific data
	warn "The path to the current problem file template is not defined." unless $main::fileName;
	warn "The current studentLogin is not defined " unless $main::studentLogin;
	warn "The current problem set number is not defined" if $main::setNumber eq ""; # allow for sets equal to 0
	warn "The current problem number is not defined"  if $main::probNum eq "";
	warn "The current problem set version number (psvn) is not defined" unless $main::psvnNumber;
	warn "The displayMode is not defined" unless $main::displayMode;

	# required macros
	warn "The macro &surePathToTmpFile can't be found" unless defined(&surePathToTmpFile);
	warn "The macro &convertPath can't be found" unless defined(&convertPath);
	warn "The macro &directoryFromPath can't be found" unless defined(&directoryFromPath);
	warn "Can't execute the gif2eps script at ${main::externalGif2EpsPath}" unless ( -x "${main::externalGif2EpsPath}" );
	warn "Can't execute the png2eps script at ${main::externalPng2EpsPath}" unless ( -x "${main::externalPng2EpsPath}" );

	# required directory addresses (and URL address)
	warn "htmlDirectory is not defined in $main::htmlDirectory" unless $main::htmlDirectory;
	warn "htmlURL is not defined in \$main::htmlURL" unless $main::htmlURL;
	warn "tempURL is not defined in \$main::tempURL" unless $main::tempURL;
	#warn "The scripts directory is not defined in \$main::scriptDirectory" unless $main::scriptDirectory;
		# with the creation of externalGif2EpsPath and externalPng2EpsPath, the scripts directory is no longer used

	# determine extension, if there is one
	# if extension exists, strip and use the value for $ext
	# files without extensions are considered to be picture files:

	my $ext;
	if ($aux_file_path =~ s/\.([^\.]*)$// ) {
		$ext = $1;
	} else {
		warn "This file name $aux_file_path did not have an extension.<BR> " .
		     "Every file name used as an argument to alias must have an extension.<BR> " .
		     "The permissable extensions are .gif, .png, and .html .<BR>";
		$ext  = "gif";
	}

	# $adr_output is a url in HTML and Latex2HTML modes
	# and a complete path in TEX mode.
	my $adr_output;

	# in order to facilitate maintenance of this macro the routines for handling
	# different file types are defined separately.  This involves some redundancy
	# in the code but it makes it easier to define special handling for a new file
	# type, (but harder to change the behavior for all of the file types at once
	# (sigh)  ).


	if ($ext eq 'html') {
		################################################################################
		# .html FILES in HTML, HTML_tth, HTML_dpng, HTML_img and Latex2HTML mode
		################################################################################

		# No changes are made for auxiliary files in the
		# ${Global::htmlDirectory} subtree.
		if ( $aux_file_path =~ m|^$main::tempDirectory| ) {
			$adr_output = $aux_file_path;
			$adr_output =~ s|$main::tempDirectory|$main::tempURL/|;
			$adr_output .= ".$ext";
		} elsif ($aux_file_path =~ m|^$main::htmlDirectory| ) {
			$adr_output = $aux_file_path;
			$adr_output =~ s|$main::htmlDirectory|$main::htmlURL|;
			$adr_output .= ".$ext";
		} else {
			# HTML files not in the htmlDirectory are assumed under live under the
			# templateDirectory in the same directory as the problem.
			# Create an alias file (link) in the directory html/tmp/html which
			# points to the original file and return the URL of this alias.
			# Create all of the subdirectories of html/tmp/html which are needed
			# using sure file to path.

			# $fileName is obtained from environment for PGeval
			# it gives the  full path to the current problem
			my $filePath = directoryFromPath($main::fileName);
			my $htmlFileSource = convertPath("$main::templateDirectory${filePath}$aux_file_path.html");
			my $link = "html/$main::studentLogin-$main::psvnNumber-set$main::setNumber-prob$main::probNum-$aux_file_path.$ext";
			my $linkPath = surePathToTmpFile($link);
			$adr_output = "${main::tempURL}$link";
			if (-e $htmlFileSource) {
				if (-e $linkPath) {
					unlink($linkPath) || warn "Unable to unlink alias file at |$linkPath|";
					# destroy the old link.
				}
				symlink( $htmlFileSource, $linkPath)
			    		|| warn "The macro alias cannot create a link from |$linkPath|  to |$htmlFileSource| <BR>" ;
			} else {
				warn("The macro alias cannot find an HTML file at: |$htmlFileSource|");
			}
		}
	} elsif ($ext eq 'gif') {
		if ( $main::displayMode eq 'HTML' ||
		     $main::displayMode eq 'HTML_tth'||
		     $main::displayMode eq 'HTML_dpng'||
		     $main::displayMode eq 'HTML_img'||
		     $main::displayMode eq 'Latex2HTML')  {
			################################################################################
			# .gif FILES in HTML, HTML_tth, HTML_dpng, HTML_img, and Latex2HTML modes
			################################################################################

			#warn "tempDirectory is $main::tempDirectory";
			#warn "file Path for auxiliary file is $aux_file_path";

			# No changes are made for auxiliary files in the htmlDirectory or in the tempDirectory subtree.
			if ( $aux_file_path =~ m|^$main::tempDirectory| ) {
				$adr_output = $aux_file_path;
				$adr_output =~ s|$main::tempDirectory|$main::tempURL|;
				$adr_output .= ".$ext";
				#warn "adress out is $adr_output";
			} elsif ($aux_file_path =~ m|^$main::htmlDirectory| ) {
				$adr_output = $aux_file_path;
				$adr_output =~ s|$main::htmlDirectory|$main::htmlURL|;
				$adr_output .= ".$ext";
			} else {
				# files not in the htmlDirectory sub tree are assumed to live under the templateDirectory
				# subtree in the same directory as the problem.

				# For a gif file the alias macro creates an alias under the html/images directory
				# which points to the gif file in the problem directory.
				# All of the subdirectories of html/tmp/gif which are needed are also created.
				my $filePath = directoryFromPath($main::fileName);

				# $fileName is obtained from environment for PGeval
				# it gives the full path to the current problem
				my $gifSourceFile = convertPath("$main::templateDirectory${filePath}$aux_file_path.gif");
				#my $link = "gif/$main::studentLogin-$main::psvnNumber-set$main::setNumber-prob$main::probNum-$aux_file_path.$ext";
				my $link = "gif/$main::setNumber-prob$main::probNum-$aux_file_path.$ext";

				my $linkPath = surePathToTmpFile($link);
				$adr_output = "${main::tempURL}$link";
				#warn "linkPath is $linkPath";
				#warn "adr_output is $adr_output";
				if (-e $gifSourceFile) {
					if (-e $linkPath) {
						unlink($linkPath) || warn "Unable to unlink old alias file at $linkPath";
					}
					symlink($gifSourceFile, $linkPath)
						|| warn "The macro alias cannot create a link from |$linkPath|  to |$gifSourceFile| <BR>" ;
				} else {
					warn("The macro alias cannot find a GIF file at: |$gifSourceFile|");
				}
			}
		} elsif ($main::displayMode eq 'TeX') {
			################################################################################
			# .gif FILES in TeX mode
			################################################################################

			if ($envir{texDisposition} eq "pdf") {
				# We're going to create PDF files with our TeX (using pdflatex), so we
				# need images in PNG format.

				my $gifFilePath;

				if ($aux_file_path =~ m/^$main::htmlDirectory/ or $aux_file_path =~ m/^$main::tempDirectory/) {
					# we've got a full pathname to a file
					$gifFilePath = "$aux_file_path.gif";
				} else {
					# we assume the file is in the same directory as the problem source file
					$gifFilePath = $main::templateDirectory . directoryFromPath($main::fileName) . "$aux_file_path.gif";
				}

				my $gifFileName = fileFromPath($gifFilePath);

				$gifFileName =~ /^(.*)\.gif$/;
				my $pngFilePath = surePathToTmpFile("$main::tempDirectory/png/$1.png");
				my $returnCode = system "$envir{externalGif2PngPath} $gifFilePath $pngFilePath";

				if ($returnCode or not -e $pngFilePath) {
					die "failed to convert gif->png with $envir{externalGif2PngPath}: $!\n";
				}

				$adr_output = $pngFilePath;
			} else {
				# Since we're not creating PDF files, we're probably just using a plain
				# vanilla latex. Hence, we need EPS images.

				################################################################################
				# This is statement used below is system dependent.
				# Notice that the range of colors is restricted when converting to postscript to keep the files small
				# "cat $gifSourceFile  | /usr/math/bin/giftopnm | /usr/math/bin/pnmtops -noturn > $adr_output"
				# "cat $gifSourceFile  | /usr/math/bin/giftopnm | /usr/math/bin/pnmdepth 1 | /usr/math/bin/pnmtops -noturn > $adr_output"
				################################################################################
				if ($aux_file_path =~  m|^$main::htmlDirectory|  or $aux_file_path =~  m|^$main::tempDirectory|)  {
					# To serve an eps file copy an eps version of the gif file to the subdirectory of eps/
					my $linkPath = directoryFromPath($main::fileName);

					my $gifSourceFile = "$aux_file_path.gif";
					my $gifFileName = fileFromPath($gifSourceFile);
					$adr_output = surePathToTmpFile("$main::tempDirectory/eps/$main::studentLogin-$main::psvnNumber-$gifFileName.eps") ;

					if (-e $gifSourceFile) {
						#system("cat $gifSourceFile  | /usr/math/bin/giftopnm | /usr/math/bin/pnmdepth 1 | /usr/math/bin/pnmtops -noturn>$adr_output")
						system("${main::externalGif2EpsPath} $gifSourceFile $adr_output" )
							&& die "Unable to create eps file:\n |$adr_output| from file\n |$gifSourceFile|\n in problem $main::probNum " .
							       "using the system dependent script\n |${main::externalGif2EpsPath}| \n";
					} else {
						die "|$gifSourceFile| cannot be found.  Problem number: |$main::probNum|";
					}
				} else {
					# To serve an eps file copy an eps version of the gif file to  a subdirectory of eps/
					my $filePath = directoryFromPath($main::fileName);
					my $gifSourceFile = "${main::templateDirectory}${filePath}$aux_file_path.gif";
					#print "content-type: text/plain \n\nfileName = $fileName and aux_file_path =$aux_file_path<BR>";
					$adr_output = surePathToTmpFile("eps/$main::studentLogin-$main::psvnNumber-set$main::setNumber-prob$main::probNum-$aux_file_path.eps");

					if (-e $gifSourceFile) {
						#system("cat $gifSourceFile  | /usr/math/bin/giftopnm | /usr/math/bin/pnmdepth 1 | /usr/math/bin/pnmtops -noturn>$adr_output") &&
						#warn "Unable to create eps file: |$adr_output|\n from file\n |$gifSourceFile|\n in problem $main::probNum";
						#warn "Help ${main::externalGif2EpsPath}" unless -x "${main::externalGif2EpsPath}";
						system("${main::externalGif2EpsPath} $gifSourceFile $adr_output" )
							&& die "Unable to create eps file:\n |$adr_output| from file\n |$gifSourceFile|\n in problem $main::probNum " .
							       "using the system dependent script\n |${main::externalGif2EpsPath}| \n ";
					}  else {
						die "|$gifSourceFile| cannot be found.  Problem number: |$main::probNum|";
					}
				}
			}
		} else {
			wwerror("Error in alias: dangerousMacros.pl","unrecognizable displayMode = $main::displayMode","");
		}
	} elsif ($ext eq 'png') {
		if ( $main::displayMode eq 'HTML' ||
		     $main::displayMode eq 'HTML_tth'||
		     $main::displayMode eq 'HTML_dpng'||
		     $main::displayMode eq 'HTML_img'||
		     $main::displayMode eq 'Latex2HTML')  {
			################################################################################
			# .png FILES in HTML, HTML_tth, HTML_dpng, HTML_img, and Latex2HTML modes
			################################################################################

			#warn "tempDirectory is $main::tempDirectory";
			#warn "file Path for auxiliary file is $aux_file_path";

			# No changes are made for auxiliary files in the htmlDirectory or in the tempDirectory subtree.
			if ( $aux_file_path =~ m|^$main::tempDirectory| ) {
			$adr_output = $aux_file_path;
				$adr_output =~ s|$main::tempDirectory|$main::tempURL|;
				$adr_output .= ".$ext";
				#warn "adress out is $adr_output";
			} elsif ($aux_file_path =~ m|^$main::htmlDirectory| ) {
				$adr_output = $aux_file_path;
				$adr_output =~ s|$main::htmlDirectory|$main::htmlURL|;
				$adr_output .= ".$ext";
			} else {
				# files not in the htmlDirectory sub tree are assumed to live under the templateDirectory
				# subtree in the same directory as the problem.

				# For a png file the alias macro creates an alias under the html/images directory
				# which points to the png file in the problem directory.
				# All of the subdirectories of html/tmp/gif which are needed are also created.
				my $filePath = directoryFromPath($main::fileName);

				# $fileName is obtained from environment for PGeval
				# it gives the full path to the current problem
				my $pngSourceFile = convertPath("$main::templateDirectory${filePath}$aux_file_path.png");
				my $link = "gif/$main::studentLogin-$main::psvnNumber-set$main::setNumber-prob$main::probNum-$aux_file_path.$ext";
				my $linkPath = surePathToTmpFile($link);
				$adr_output = "${main::tempURL}$link";
				#warn "linkPath is $linkPath";
				#warn "adr_output is $adr_output";
				if (-e $pngSourceFile) {
					if (-e $linkPath) {
						unlink($linkPath) || warn "Unable to unlink old alias file at $linkPath";
					}
					symlink($pngSourceFile, $linkPath)
					|| warn "The macro alias cannot create a link from |$linkPath|  to |$pngSourceFile| <BR>" ;
				} else {
					warn("The macro alias cannot find a PNG file at: |$pngSourceFile|");
				}
			}
		} elsif ($main::displayMode eq 'TeX') {
			################################################################################
			# .png FILES in TeX mode
			################################################################################

			if ($envir{texDisposition} eq "pdf") {
				# We're going to create PDF files with our TeX (using pdflatex), so we
				# need images in PNG format. what luck! they're already in PDF format!

				my $pngFilePath;

				if ($aux_file_path =~ m/^$main::htmlDirectory/ or $aux_file_path =~ m/^$main::tempDirectory/) {
					# we've got a full pathname to a file
					$pngFilePath = "$aux_file_path.png";
				} else {
					# we assume the file is in the same directory as the problem source file
					$pngFilePath = $main::templateDirectory . directoryFromPath($main::fileName) . "$aux_file_path.png";
				}

				$adr_output = $pngFilePath;
			} else {
				# Since we're not creating PDF files, we're probably just using a plain
				# vanilla latex. Hence, we need EPS images.

				################################################################################
				# This is statement used below is system dependent.
				# Notice that the range of colors is restricted when converting to postscript to keep the files small
				# "cat $pngSourceFile  | /usr/math/bin/pngtopnm | /usr/math/bin/pnmtops -noturn > $adr_output"
				# "cat $pngSourceFile  | /usr/math/bin/pngtopnm | /usr/math/bin/pnmdepth 1 | /usr/math/bin/pnmtops -noturn > $adr_output"
				################################################################################

				if ($aux_file_path =~  m|^$main::htmlDirectory|  or $aux_file_path =~  m|^$main::tempDirectory|)  {
					# To serve an eps file copy an eps version of the png file to the subdirectory of eps/
					my $linkPath = directoryFromPath($main::fileName);

					my $pngSourceFile = "$aux_file_path.png";
					my $pngFileName = fileFromPath($pngSourceFile);
					$adr_output = surePathToTmpFile("$main::tempDirectory/eps/$main::studentLogin-$main::psvnNumber-$pngFileName.eps") ;

					if (-e $pngSourceFile) {
						#system("cat $pngSourceFile  | /usr/math/bin/pngtopnm | /usr/math/bin/pnmdepth 1 | /usr/math/bin/pnmtops -noturn>$adr_output")
						system("${main::externalPng2EpsPath} $pngSourceFile $adr_output" )
							&& die "Unable to create eps file:\n |$adr_output| from file\n |$pngSourceFile|\n in problem $main::probNum " .
							       "using the system dependent script\n |${main::externalPng2EpsPath}| \n";
					} else {
						die "|$pngSourceFile| cannot be found.  Problem number: |$main::probNum|";
					}
				} else {
					# To serve an eps file copy an eps version of the png file to  a subdirectory of eps/
					my $filePath = directoryFromPath($main::fileName);
					my $pngSourceFile = "${main::templateDirectory}${filePath}$aux_file_path.png";
					#print "content-type: text/plain \n\nfileName = $fileName and aux_file_path =$aux_file_path<BR>";
					$adr_output = surePathToTmpFile("eps/$main::studentLogin-$main::psvnNumber-set$main::setNumber-prob$main::probNum-$aux_file_path.eps") ;
					if (-e $pngSourceFile) {
						#system("cat $pngSourceFile  | /usr/math/bin/pngtopnm | /usr/math/bin/pnmdepth 1 | /usr/math/bin/pnmtops -noturn>$adr_output") &&
						#warn "Unable to create eps file: |$adr_output|\n from file\n |$pngSourceFile|\n in problem $main::probNum";
						#warn "Help ${main::externalPng2EpsPath}" unless -x "${main::externalPng2EpsPath}";
						system("${main::externalPng2EpsPath} $pngSourceFile $adr_output" )
							&& die "Unable to create eps file:\n |$adr_output| from file\n |$pngSourceFile|\n in problem $main::probNum " .
							       "using the system dependent script\n |${main::externalPng2EpsPath}| \n ";
					} else {
						die "|$pngSourceFile| cannot be found.  Problem number: |$main::probNum|";
					}
				}
			}
		} else {
			wwerror("Error in alias: dangerousMacros.pl","unrecognizable displayMode = $main::displayMode","");
		}
	} else { # $ext is not recognized
		################################################################################
		# FILES  with unrecognized file extensions in any display modes
		################################################################################

		warn "Error in the macro alias. Alias does not understand how to process files with extension $ext.  (Path ot problem file is  $main::fileName) ";
	}

	warn "The macro alias was unable to form a URL for some auxiliary file used in this problem." unless $adr_output;
	return $adr_output;
}





# Experiments

# It is important that these subroutines using sort are evaluated before
# the problem template is evaluated.
# Once the problem template has a "my $a;" susequent sort routines will not work.
#
# PGsort can be used as a slightly slower but safer sort within problems.



=head2 PGsort

Because of the way sort is optimized in Perl, the symbols $a and $b
have special significance.

C<sort {$a<=>$b} @list>
C<sort {$a cmp $b} @list>

sorts the list numerically and lexically respectively.

If C<my $a;> is used in a problem, before the sort routine is defined in a macro, then
things get badly confused.  To correct this, the following macros are defined in
dangerougMacros.pl which is evaluated before the problem template is read.

	PGsort sub { $_[0] <=> $_[1] }, @list;
	PGsort sub { $_[0] cmp $_[1] }, @list;

provide slightly slower, but safer, routines for the PG language. (The subroutines
for ordering are B<required>. Note the commas!)

=cut



# sub PGsort {
# 	my $sort_order = shift;
# 	die "Must supply an ordering function with PGsort: PGsort sub {\$a cmp \$b }, \@list\n" unless ref($sort_order) eq 'CODE';
# 	sort {&$sort_order($a,$b)} @_;
# }
# Moved to translate.pl
# For some reason it still caused
# trouble here when there was
# more than one ans_eval in ANS()
# No-one knows why?

# This allows the use of i for  imaginary numbers
#  one can write   3 +2i rather than 3+2i()
#

sub i;

1;  # required to load properly