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
use strict;
use warnings;

my $input_file;

#paramters
my $hash = "XXX";
my $line1 = "";
my $line2 = "";
my $line25 = "";
my $line3 = "";

my $x1 = 0;									#	player upper left
my $y1 = 0;									#	corner coordinates

my $x2 = 400;								#	player lower right
my $y2 = 300;								#	corner coordinates

my $canvas_w = 1340;						#	Just convenient canvas size
my $canvas_h = 700;							#	for my laptop screen

my $player_w = 400;							#	Default player width
my $player_h = 300;							#	Default player height

my $playbackDelay = 0;						#	Default playback start delay

my $dirDelimiter = ($^O =~ /Win/)?"\\":"/";	#	for linux "/", for windows "\\"

my $parameters = "";						#	Parameters to print in HTML

my $mainIndexFh = undef;

if (!$ARGV[0] or ($ARGV[0] eq "-help")){ 
	print "usage:\n
	perl player-test.pl input.txt 800 600\n
	where\n
	input.txt - file with tests settings;\n
	800 - browser window width;\n
	600 - browser window height;\n";
	exit;
}
else{
	$input_file = $ARGV[0];
}

$canvas_w = $ARGV[1] if ($ARGV[1]);	#	canvas size from
$canvas_h = $ARGV[2] if ($ARGV[2]);	#	command prompt arguments

print "perl running on $^O, directory delimiter is \"$dirDelimiter\"\n";

open (my $inputFh,"$input_file") || die "can't find  $input_file: $!";

my $outDirName = getTime();
my $outDirPath = "out".$dirDelimiter.$outDirName;
mkdir $outDirPath || die "can't create dir $outDirName : $!";

my $mainIndexFile = "index.html";
print "Main index: \"$mainIndexFile\"\n";
print "Output directory is \"$outDirPath\"\n";

if (! -e $mainIndexFile){
	print "Create Main index: \"$mainIndexFile\"";
	open ($mainIndexFh , ">$mainIndexFile") || die "can't create file $!";
	print $mainIndexFh "<!DOCTYPE HTML>
<HTML>
<HEAD>
<TITLE>VideoStir tests global index</TITLE>
</HEAD>
<BODY>
<h1>VideoStir tests global index</h1>
<hr>
</BODY>
</HTML>";
close $mainIndexFh;
}

my $indexFilePath = $outDirPath.$dirDelimiter."index.html";
open (my $indexFh , ">$indexFilePath") || die "can't create file $!" ;


#	add testsuite to main index file

#	Prepare indexFileLink
my $now_string = sprintf("%02d.%02d.%d %02d:%02d:%02d",
							localtime->mday(),
							localtime->mon()+1,
							localtime->year() + 1900,
							localtime->hour(),
							localtime->min(),
							localtime->sec());

my $indexFileLink = "<p><a href=out\/$outDirName\/index.html ".
"target=_blank>".
"Generation time: $now_string, ".
"Input file: $input_file, ".
"browser window dimensions: $canvas_w x $canvas_h".
"<\/a><\/p>";
print "New link:\n$indexFileLink\n";

#	Read file to memory
$^I = '.bak'; 
open ($mainIndexFh, "+<$mainIndexFile") || die "can't open file $!";
my $pos = 0;
while (<$mainIndexFh>) {
	if (/<\/BODY>/){
		truncate $mainIndexFh, $pos;
	}
	$pos = tell($mainIndexFh);		
}
seek($mainIndexFh, 0, 2);    # 0 byte from end-of-file
print $mainIndexFh $indexFileLink."\n<\/BODY>\n<\/HTML>\n";
close($mainIndexFh);

print $indexFh "<!DOCTYPE HTML>
<HTML>
<HEAD>
<TITLE>Videostir tests: $outDirName</TITLE>
<script src=\"..\/..\/js\/pop_up_window_open.js\" type=\"text\/javascript\"></script>
</HEAD>
<BODY>
<h1>Input file: $input_file</h1>
<p>width = $canvas_w</p>
<p>height = $canvas_h</p>
<hr><h2>Resulting Test pages:</h2>
<p>";
 
sub handle_line_from_input();
 
#############  loop  ###########################
while(<$inputFh>){
	handle_line_from_input();
}
############ end of loop  ######################

print $indexFh "</p>\n</BODY>\n</HTML>";
close $indexFh;

if ($^O =~ /Win/){
print "finished .....press any  key to close window.....\n";
`pause`;
}

################################################

sub handle_line_from_input(){
	$hash = $1 if (/^HASHID\s+(\S+)/);
	$line1 = $1 if (/line1\s+(<.*?\s+.*?script>)/)  ;
	$line2 = $1 if (/line2\s+(<.*?\s+.*?script>)/)  ;
	$line25 = $1 if (/line25\s+(<.*?\s+.*?script>)/)  ;
	if (/(tc\S+)\s+(<.*?\s+.*?>)/){
		my $tc = $1;
		$line3 = $2;
		$line3 =~ s/HASHID/$hash/;
		$parameters = "HASHID = $hash\n";

		#	Getting player dimensions
		if (/\(.*?,\s*(\d+?)\s*,\s*(\d+?)\s*,/){
			$player_w = $1;
			$player_h = $2;
			$parameters .= "Player Width = $player_w\n"; 
			$parameters .= "Player Hight = $player_h\n"; 
		}

		#	Calculate rectangle coordinates from player position and dimentions
		#	for corner and center positions

		#	top-left
		if (/['"]top-left['"]/i){
			$x1 = 0;
			$y1 = 0;
			$parameters .= "Player Position = top-left\n";
		}

		#	top-right
		if (/['"]top-right['"]/i){
			$x1 = $canvas_w - $player_w;
			$y1 = 0;
			$parameters .= "Player Position = top-right\n";
		}

		#	bottom-right
		if (/['"]bottom-right['"]/i){
			$x1 = $canvas_w - $player_w;
			$y1 = $canvas_h - $player_h;
			$parameters .= "Player Position = bottom-right\n";
		}

		#	bottom-left
		if (/['"]bottom-left['"]/i){
			$x1 = 0;
			$y1 = $canvas_h - $player_h;
			$parameters .= "Player Position = bottom-left\n";
		}
		
		#	center
		if (/['"]center['"]/i){
			$x1 = ($canvas_w - $player_w)/2;
			$y1 = ($canvas_h - $player_h)/2;
			$parameters .= "Player Position = center\n";
		}

		#	specific positions based on pixels 
		#	{"top":"10px", "left":"20px"} meaning
		#	10 pixels from the top and 
		#	20 from the left of the screen

		#	top
		if (/{\s*["']top["']\s*:\s*["'](\d+?)px["']\s*,\s*["']\w+?["']:["']\d+?px["']}/i){
			$y1 = $1;
			$parameters .= "Player Position = $1 px from top\n";
		}			

		#	bottom
		if (/{\s*["']bottom["']\s*:\s*["'](\d+?)px["']\s*,\s*["']\w+?["']:["']\d+?px["']}/i){
			$y1 = $canvas_h - $player_h - $1;
			$parameters .= "Player Position = $1 px from bottom\n";			
		}
		#	left
		if (/{\s*["']\w+?["']\s*:\s*["']\d+?px["']\s*,\s*["']left["']:["'](\d+?)px["']}/i){
			$x1 = $1;
			$parameters .= "Player Position = $1 px from left\n";			
		}
 
		#	right
		if (/{\s*["']\w+?["']\s*:\s*["']\d+?px["']\s*,\s*["']right["']:["'](\d+?)px["']}/i){
			$x1 = $canvas_w - $player_w - $1;
			$parameters .= "Player Position = $1 px from right\n";			
		}

		$x2 = $x1 + $player_w;
		$y2 = $y1 + $player_h;
		
		my $x3 = $x1;
		my $y3 = $y1;
		my $x4 = $x2;
		my $y4 = $y2;
		
		#	offset-x - (shift clip inside player) 
		#	Shift clip right/left inside player. 
		#	50 will shift clip 50 pixels to the right.
		#	-50 will shift to the left.
		if (/['"]\s*offset-x\s*['"]\s*:\s*([+-]??\d+)\s*,/i){
			$x3 = $x1 + $1;		
			$parameters .= "Video Offset horizontal = $1 px (relative to Player)\n";			
		}
		
		#	offset-y - (shift clip inside player) 
		#	Shift clip up/down inside player. 
		#	50 will shift clip 50 pixels to the top. 
		#	-50 will shift to the bottom.
		if (/['"]\s*offset-y\s*['"]\s*:\s*([+-]??\d+)\s*,/i){
			$y3 = $y1 + $1;		
			$parameters .= "Video Offset vertical = $1 px (relative to Player)\n";			
		}
		
		#	Controlling the clip behavior (optional parameters)
		
		#	playback-delay - (delay) 
		#	how many seconds to wait before running
		if (/['"]\s*playback-delay\s*['"]\s*:\s*(\d+)\s*,/i){
			$playbackDelay = $1;		
			$parameters .= "Video Playback Delay = $1 S\n";			
		}

		#	auto-play - (auto play)
		#	"true" start playing 
		#	"false" display a big play button
		if (/['"]\s*auto-play\s*['"]\s*:\s*['"]*(\w+)['"]*,/i){
			my $autoPlay = $1;		
			$parameters .= "Video auto play = $1\n";			
		}

		#	freeze - (freezes the clip)
		#	After X frames the clip will freeze and a play button will appear. 
		#	Catch the visitors eye while avoiding auto-playing the clip
		if (/['"]\s*freeze\s*['"]\s*:\s*(\d+)\s*,/i){
			my $freeze = $1;		
			$parameters .= "clip will freeze after = $1 frames\n";
		}

		#	auto-play-limit - (when to stop auto play) 
		#	how many times to play clip on browser before moving to 
		#	auto-play-limit=false mode and display play button.
		if (/['"]\s*auto-play-limit\s*['"]\s*:\s*(\d+)\s*,/i){
			my $autoPlayLimit = $1;		
			$parameters .= "clip will play automatically = $1 times\n";
		}

		#	on-finish - (what to do after the clip ends) 
		#	possible options 
		#	"remove"-removes the player, 
		#	"play-button"-will show a play button, 
		#	"blank" leave an empty frame
		if (/['"]\s*on-finish\s*['"]\s*:\s*['"]*(.+?)['"]*,/i){
			my $onFinish = $1;		
			$parameters .= "after the clip ends = $1\n";			
		}

		#	disable-player-threshold - (when to stop presenting player at all ) 
		#	After X views on browser. 
		#	The player will stop loading at all.
		if (/['"]\s*disable-player-threshold\s*['"]\s*:\s*(\d+)\s*,/i){
			my $disablePlayerThreshold = $1;		
			$parameters .= "The player will stop loading at all after = $1 views on browser\n";
		}

		#	on-click-open-url - (redirects to url of choice when clicking on clip) 
		#	To which webpage to "jump" when clicking on clip's area "click on me..."
		if (/['"]\s*on-click-open-url\s*['"]\s*:\s*['"](\S+?)['"]\s*,/i){
			my $onClickOpenUrl = $1;		
			$parameters .= "when clicking on clip, it redirects  to = $1\n";			
		}
		
		#	zoom - (zoom in/out clip inside player frame) 
		#	zoom 100 means without zoom. 
		#	200 means double size. 
		#	50 means half the size
		if (/['"]\s*zoom\s*['"]\s*:\s*(\d+)\s*[,}]/i){
			$x4 = $x3 + ($player_w*$1)/100;
			$y4 = $y3 + ($player_h*$1)/100;		
			$parameters .= "Video Zoom = $1 % (relative to Player)\n";			
		}

		#	rotation - (rotate clip-clockwise) 
		#	rotate 90 means rotate clockwise 90 degrees (on the size). 
		#	180 degrees means up side down. 270 means on the left side
		if (/['"]\s*rotation\s*['"]\s*:\s*(\d+)\s*,/i){
			my $rotation = $1;		
			$parameters .= "rotation = $1 degrees\n";
		}

		#	extrab - (extra buffer) 
		#	how many extra seconds to wait to assure 
		#	smooth run for bigger clips and shaky connections
		if (/['"]\s*extrab\s*['"]\s*:\s*(\d+)\s*,/i){
			my $extrab = $1;		
			$parameters .= "extra buffer = $1 S\n";
		}
		
		#ToDo Retrieve different info from file
		# create new canvas
		my $img = GD::Simple->new($canvas_w, $canvas_h);

		# draw a filled rectangle with borders around player
		$img->penSize(1,1); 
		$img->angle(0);
		$img->bgcolor('yellow');
		$img->fgcolor('red');
		$img->rectangle($x1-1, $y1-1, $x2-1, $y2-1);	
		# (top_left_x,	top_left_y,	bottom_right_x,	bottom_right_y	)
		# ($x1, 		$y1,		$x2,			$y2				)
#		$parameters .= "Coordinates of Player:\t\$x1 = $x1\t\$y1 = $y1\t\$x2 = $x2\t\$y2 = $y2\n";

		# draw a rectangle with borders around video inside player
		$img->penSize(1,1); 
		$img->angle(0);
		$img->bgcolor(undef);
		$img->fgcolor('blue');
		$img->rectangle($x3-1, $y3-1, $x4-1, $y4-1);
		# (top_left_x,	top_left_y,	bottom_right_x,	bottom_right_y	)
		# ($x3, 		$y3,		$x4,			$y4				)
#		$parameters .= "Coordinates of Video:\t\$x3 = $x3\t\$y3 = $y3\t\$x4 = $x4\t\$y4 = $y4\n";

		# draw a rectangle around the testing picture
		$img->penSize(1,1); 
		$img->angle(0);
		$img->bgcolor(undef);
		$img->fgcolor('red');
		$img->rectangle(0, 0, $canvas_w-1, $canvas_h-1);
		
		# convert into png and name it same as html file (name of current TC)
		my $imgName = $tc.".png";
		my $relativeHtmlPath = $outDirPath.$dirDelimiter.$tc.".html";
		open (my $out, ">".$outDirPath.$dirDelimiter.$imgName) || die "can't create file$!";
		binmode $out;
		print $out $img->png;

		my $vp_script = $line3;
		$vp_script =~ s/</&lt;/g;
		$vp_script =~ s/>/&gt;/g;

		$parameters =~ s/^/<tr><td align=\"right\">/mg;
		$parameters =~ s/\s=\s/<\/td><td align="left">/mg;
		$parameters =~ s/$/<\/td><\/tr>/mg;
		
		open (my $tcFh , ">".$relativeHtmlPath) || die "can't create file$!" ;

print $tcFh "<!DOCTYPE HTML>
<HTML>
<HEAD>
<TITLE>Test Videostir: $tc</TITLE>
<STYLE type=\"text/css\">
body {
	font-family: \"Lucida Console\", Monaco, monospace;
	margin: 0;
	padding: 0;
	background-attachment: fixed;
	background-repeat: no-repeat;
	background-position: 0px 0px;
	background-image: url($imgName);
}
#content {
	margin: 10px;
	padding: 0px;
	height: 600px;
	width: 600px;
}
#player {
	background-color: #FFFF00;
	display: block;
	margin: 0px;
	padding: 0px;
	height: 243px;
	width: 430px;
	border: 1px solid #000;
	position: absolute;
	right: 0px;
	bottom: 0px;
	float: none;
}
</STYLE>
<script src=\"..".$dirDelimiter."..".$dirDelimiter."js".$dirDelimiter."timer.js\" type=\"text\/javascript\"><\/script>
<link href=\"..".$dirDelimiter."..".$dirDelimiter."css".$dirDelimiter."tc.css\" rel=\"stylesheet\" type=\"text\/css\">
</HEAD>
<BODY>
<div id=\"content\">
<h1>Test case name: $tc</h1>
<h2>Video player script:</h2>
<code>$vp_script</code>
<h2>Time from page load:</h2>
<p id=\"time\" onclick=\"startstoptimer()\">00.00</p>
<h2>Parameters:</h2>
<table width=\"100%\" border=\"1\" cellpadding=\"5\" cellspacing=\"0\" id=\"parameters\">
    <tr>
      <th align=\"right\">Parameter</th>
      <th align=\"left\">Value</th>
    </tr>
$parameters
</table>
$line1
$line2
$line3
<script type=\"text/javascript\">
	setDelay($playbackDelay);
	display();
</script>
</BODY>
</HTML>";
		close $tcFh;
		
		my $popupWindowW = $canvas_w+2;
		my $popupWindowH = $canvas_h+2;
		
		print $indexFh "|&nbsp;<a href=$tc.html ".
						"target=\"$tc\" ".
						"onclick=\"openPopupWindow(this.href,".
						"'$tc',$popupWindowW,$popupWindowH); ".
						"return false;\" ".
						"title=\"$tc\">$tc</a>&nbsp;\n";
	}
}

############################################################### 
sub getTime {
	my $ts = sprintf "%02d-%02dT%02d-%02d-%02d", localtime->mday(),localtime->mon() +1 ,localtime->hour(), localtime->min(),	localtime->sec();
	return $ts;
}