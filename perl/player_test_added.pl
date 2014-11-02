#!/usr/bin/perl
#script version 1 VideoStir, Shy Frenkel
# reads input files and create an HTML file with 3 embedded lines based on input file
#HTMLs will be created in a new folder
#clip hash is replaced in the third line based on HASHID value in the input file
#example for input file content:
#
# HASHID 0277039372df5047347e359f9a9d6fd2
# line1 <script src="https://c391671.ssl.cf1.rackcdn.com/js/120708-jquery-1.7.2-AND-swfobject-2.2.js"></script>
# line2 <script src="https://c391671.ssl.cf1.rackcdn.com/js/1.2.1/videostir.player.min.js"></script>
# tc1-offset-50 <script>VideoStir.Player.show("bottom-right", 480, 270, "http://videostir.com/go/video/HASHID", {"auto-play": true, "playback-delay": 1, "extrab": 1, "offset-x": 50});</script>
# tc2-freeze-10-big <script>VideoStir.Player.show("bottom-right", 700, 400, "http://videostir.com/go/video/HASHID", {"auto-play": false, "playback-delay": 1, "extrab": 1, "freeze":10});</script>
# tc3-extrab2 <script>VideoStir.Player.show("bottom-right", 480, 270, "http://videostir.com/go/video/HASHID", {"auto-play": true, "playback-delay": 1, "extrab": 2});</script>

######### imports ##########

use IO::File;
use File::Path;
use IO::Handle;
use IO::Socket;
use Time::localtime;
use GD::Simple;
use File::Copy;
my $input_file;
if (!$ARGV[0] or ($ARGV[0] eq "-help")){ 
	print "usage:\n";
	print "perl player-test.pl input.txt";
	exit;
}
else{
	$input_file = $ARGV[0];
}

#paramters
my $hash = "XXX";
my $line1 = "";
my $line2 = "";
my $line25 = "";
my $line3 = "";
my $x1 = 0;
my $y1 = 0;
my $x2 = 400;
my $y2 = 300;
my $canvas_w = $ARGV[1]; #Just convenient canvas size for my laptop screen
my $canvas_h = $ARGV[2];
my $player_w = 400;	# Default player width
my $player_h = 300; # Default player height

#sub handle_line_from_input();

print "<pre>width = $canvas_w\n
height = $canvas_h\n
Input file name is $input_file\n";
open (FILE,"$input_file") || die "can't find  $input_file : $!" ;
my $dirName = "out"."/".getTime();
mkdir $dirName || die "can't create dir $dirName : $!" ;
print "Output directory is $dirName\n</pre>
<hr><h1>Resulting Test pages:</h1>";
 

#############  loop  ###########################
while(<FILE>){
	handle_line_from_input();
}
############ end of loop  ######################

#print "finished .....press any  key to close window ..\n";
#`pause`;

sub handle_line_from_input(){
	$hash = $1 if (/^HASHID\s+(\S+)/);
	$line1 = $1 if (/line1\s+(<.*?\s+.*?script>)/)  ;
	$line2 = $1 if (/line2\s+(<.*?\s+.*?script>)/)  ;
	$line25 = $1 if (/line25\s+(<.*?\s+.*?script>)/)  ;
	if (/(tc\S+)\s+(<.*?\s+.*?>)/){
		my $tc = $1;
		$line3 = $2;
		$line3 =~ s/HASHID/$hash/;
		
		# Getting player dimension
		if (/\(.*?,\s*(\d+?)\s*,\s*(\d+?)\s*,/){
			$player_w = $1;
			$player_h = $2;
		}
	 
		# Calculate rectangle coordinates from player position and dimentions
		# for corner positions
		
		# top-left
		if (/top-left/i){
			 $x1 = 0;
			 $y1 = 0;
		}

		# top-right
		if (/top-right/i){
			 $x1 = $canvas_w - $player_w;
			 $y1 = 0;
		}

		#		bottom-right
		if (/bottom-right/i){
			 $x1 = $canvas_w - $player_w;
			 $y1 = $canvas_h - $player_h;
		 }

		#	bottom-left
		if (/bottom-left/i){
			 $x1 = 0;
			 $y1 = $canvas_h - $player_h;
		 }

		# specific positions based on pixels 
		#	{"top":"10px", "left":"20px"} meaning
		#	10 pixels from the top and 
		#	20 from the left of the screen
		
		#	top
		$y1 = $1 if (/{\s*["']top["']\s*:\s*["'](\d+?)px["']\s*,\s*["']\w+?["']:["']\d+?px["']}/i);

		#	bottom
		$y1 = $canvas_h - $player_h - $1 if (/{\s*["']bottom["']\s*:\s*["'](\d+?)px["']\s*,\s*["']\w+?["']:["']\d+?px["']}/i);
		
		#	left
		$x1 = $1 if (/{\s*["']\w+?["']\s*:\s*["']\d+?px["']\s*,\s*["']left["']:["'](\d+?)px["']}/i);
 
		#	right
		$x1 = $canvas_w - $player_w - $1 if (/{\s*["']\w+?["']\s*:\s*["']\d+?px["']\s*,\s*["']right["']:["'](\d+?)px["']}/i);

		$x2 = $x1 + $player_w;
		$y2 = $y1 + $player_h;
		
		#ToDo Retrieve different info from file
		# create new canvas
		my $img = GD::Simple->new($canvas_w, $canvas_h);

		 
		# draw a rectangle with borders
		$img->penSize(3,3); 
		$img->angle(0);
		$img->bgcolor('yellow');
		$img->fgcolor('red');
		$img->rectangle($x1, $y1, $x2, $y2);	# (top_left_x,	top_left_y,	bottom_right_x,	bottom_right_y)
												# ($x1, 		$y1,		$x2,			$y2)
		
		# Insert Player dimentions info on the frame 
		$img->penSize(2,2);                                 
		$img->bgcolor('black');
		$img->fgcolor('black');
		$img->moveTo($x1 + 10, $y1 + 20);
		$img->font(gdMediumBoldFont);
		$img->string("$player_w  x  $player_h" );

		# convert into png and name it same as html file (name of current TC)
		my $imgName = $tc.".png";
		my $relativeHtmlPath = $dirName."/".$tc.".html";
		open (my $out, ">".$dirName."/".$imgName) || die "can't create file$!";
		binmode $out;
		print $out $img->png;

		open (HTML , ">".$relativeHtmlPath)||  die "can't create file$!" ;
		#open (HTML , ">".$tc.".html")||  die "can't create file$!" ;
		
print HTML "<!DOCTYPE HTML>
<HTML>
<HEAD>
<TITLE>Test Videostir: ".$tc."</TITLE>
<STYLE type=\"text/css\">
body {
	margin: 30;
	padding: 0;
	background-attachment: fixed;
	background-image: url(".$imgName.");
	background-repeat: no-repeat;
	background-position: 0px 0px;
}
</STYLE>
</HEAD>
<BODY>
<h1>".$tc."</h1>
<h2>Video player script:</h2>
<p>";

my $vp_script = $line3;
$vp_script =~ s/</&lt;/g;
$vp_script =~ s/>/&gt;/g;

print HTML $vp_script."</p>";

my $parameters = $line3;
#$position =~ m/["']([\w-]*),/g;
$parameters =~ s/(<.+?\()|(\).+?>|\s+?)//g;
$parameters =~ s/,/<\/p>\n<p>Parameter:\t/g;
print HTML "<p>Parameter:\t$parameters</p>";
print HTML $line1."\n".
$line2."\n".
$line3."
</BODY>\n"; 
		close HTML;
		
		print "\t|\t<a href=".$relativeHtmlPath." target=blank>".$tc."</a>";
	}
}

############################################################### 
sub getTime {
	my $ts = sprintf "%02d-%02dT%02d-%02d-%02d", localtime->mday(),localtime->mon() +1 ,localtime->hour(), localtime->min(),	localtime->sec();
	return $ts;
}