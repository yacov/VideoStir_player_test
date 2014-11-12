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

my $dirDelimiter = ($^O =~ /Win/)?"\\":"/";	#	for linux "/", for windows "\\"

my $parameters = "";						#	Parameters to print in HTML

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

print "<p>perl running on $^O, directory delimiter is \"$dirDelimiter\"</p>\n";

open (FILE,"$input_file") || die "can't find  $input_file: $!";
my $dirName = "out".$dirDelimiter.getTime();
mkdir $dirName || die "can't create dir $dirName : $!";
print "<p>Output directory is $dirName</p>\n";

my $indexFilePath = $dirName.$dirDelimiter."index.html";
open (INDEX , ">".$indexFilePath) || die "can't create file $!" ;
print "<p>Index file with links to test pages is <a href=$indexFilePath target=blank>$indexFilePath</a></p>\n";

print INDEX "<HTML>
<HEAD>
<TITLE>Videostir tests: $dirName</TITLE>
</HEAD>
<BODY>
<h1>Input file: $input_file</h1>
<p>width = $canvas_w</p>
<p>height = $canvas_h</p>
<hr><h2>Resulting Test pages:</h2>";
 

#############  loop  ###########################
while(<FILE>){
	handle_line_from_input();
}
############ end of loop  ######################

print INDEX "</BODY>\n</HTML>";
close INDEX;

if ($^O =~ /Win/){
print "finished .....press any  key to close window ..\n";
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
			$parameters .= "Player Placeholder Position: top-left\n";
		}

		#	top-right
		if (/['"]top-right['"]/i){
			$x1 = $canvas_w - $player_w;
			$y1 = 0;
			$parameters .= "Player Placeholder Position: top-right\n";
		}

		#	bottom-right
		if (/['"]bottom-right['"]/i){
			$x1 = $canvas_w - $player_w;
			$y1 = $canvas_h - $player_h;
			$parameters .= "Player Placeholder Position: bottom-right\n";
		}

		#	bottom-left
		if (/['"]bottom-left['"]/i){
			$x1 = 0;
			$y1 = $canvas_h - $player_h;
			$parameters .= "Player Placeholder Position: bottom-left\n";
		}
		
		#	center
		if (/['"]center['"]/i){
			$x1 = ($canvas_w - $player_w)/2;
			$y1 = ($canvas_h - $player_h)/2;
			$parameters .= "Player Placeholder Position: center\n";
		}

		#	specific positions based on pixels 
		#	{"top":"10px", "left":"20px"} meaning
		#	10 pixels from the top and 
		#	20 from the left of the screen

		#	top
		if (/{\s*["']top["']\s*:\s*["'](\d+?)px["']\s*,\s*["']\w+?["']:["']\d+?px["']}/i){
			$y1 = $1;
			$parameters .= "Player Placeholder Position: $1px from top\n";
		}			

		#	bottom
		if (/{\s*["']bottom["']\s*:\s*["'](\d+?)px["']\s*,\s*["']\w+?["']:["']\d+?px["']}/i){
			$y1 = $canvas_h - $player_h - $1;
			$parameters .= "Player Placeholder Position: $1px from bottom\n";			
		}
		#	left
		if (/{\s*["']\w+?["']\s*:\s*["']\d+?px["']\s*,\s*["']left["']:["'](\d+?)px["']}/i){
			$x1 = $1;
			$parameters .= "Player Placeholder Position: $1px from left\n";			
		}
 
		#	right
		if (/{\s*["']\w+?["']\s*:\s*["']\d+?px["']\s*,\s*["']right["']:["'](\d+?)px["']}/i){
			$x1 = $canvas_w - $player_w - $1;
			$parameters .= "Player Placeholder Position: $1px from right\n";			
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
			$parameters .= "Video Offset horizontal = $1 px (relative to Player Placeholder)\n";			
		}
		
		#	offset-y - (shift clip inside player) 
		#	Shift clip up/down inside player. 
		#	50 will shift clip 50 pixels to the top. 
		#	-50 will shift to the bottom.
		if (/['"]\s*offset-y\s*['"]\s*:\s*([+-]??\d+)\s*,/i){
			$y3 = $y1 + $1;		
			$parameters .= "Video Offset vertical = $1 px (relative to Player Placeholder)\n";			
		}
		
		#	Controlling the clip behavior (optional parameters)
		
		#	playback-delay - (delay) 
		#	how many seconds to wait before running
		if (/['"]\s*playback-delay\s*['"]\s*:\s*(\d+)\s*,/i){
			my $playbackDelay = $1;		
			$parameters .= "Video Playback Delay = $1S\n";			
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
			$parameters .= "clip will freeze after $1 frames\n";
		}

		#	auto-play-limit - (when to stop auto play) 
		#	how many times to play clip on browser before moving to 
		#	auto-play-limit=false mode and display play button.
		if (/['"]\s*auto-play-limit\s*['"]\s*:\s*(\d+)\s*,/i){
			my $autoPlayLimit = $1;		
			$parameters .= "clip will play automatically $1 times\n";
		}

		#	on-finish - (what to do after the clip ends) 
		#	possible options 
		#	"remove"-removes the player, 
		#	"play-button"-will show a play button, 
		#	"blank" leave an empty frame
		if (/['"]\s*on-finish\s*['"]\s*:\s*['"]*(.+?)['"]*,/i){
			my $onFinish = $1;		
			$parameters .= "after the clip ends: $1\n";			
		}

		#	disable-player-threshold - (when to stop presenting player at all ) 
		#	After X views on browser. 
		#	The player will stop loading at all.
		if (/['"]\s*disable-player-threshold\s*['"]\s*:\s*(\d+)\s*,/i){
			my $disablePlayerThreshold = $1;		
			$parameters .= "The player will stop loading at all after $1 views on browser\n";
		}


		#	on-click-open-url - (redirects to url of choice when clicking on clip) 
		#	To which webpage to "jump" when clicking on clip's area "click on me..."
		if (/['"]\s*on-click-open-url\s*['"]\s*:\s*['"](\S+?)['"]\s*,/i){
			my $onClickOpenUrl = $1;		
			$parameters .= "when clicking on clip, it redirects  to $1\n";			
		}
		
		#	zoom - (zoom in/out clip inside player frame) 
		#	zoom 100 means without zoom. 
		#	200 means double size. 
		#	50 means half the size
		if (/['"]\s*zoom\s*['"]\s*:\s*(\d+)\s*[,}]/i){
			$x4 = $x3 + ($player_w*$1)/100;
			$y4 = $y3 + ($player_h*$1)/100;		
			$parameters .= "Video Zoom = $1 % (relative to Player Placeholder)\n";			
		}

		#	rotation - (rotate clip-clockwise) 
		#	rotate 90 means rotate clockwise 90 degrees (on the size). 
		#	180 degrees means up side down. 270 means on the left side
		if (/['"]\s*rotation\s*['"]\s*:\s*(\d+)\s*,/i){
			my $rotation = $1;		
			$parameters .= "rotation: $1 degrees\n";
		}

		#	extrab - (extra buffer) 
		#	how many extra seconds to wait to assure 
		#	smooth run for bigger clips and shaky connections
		if (/['"]\s*extrab\s*['"]\s*:\s*(\d+)\s*,/i){
			my $extrab = $1;		
			$parameters .= "extra buffer: $1S\n";
		}
		
		#ToDo Retrieve different info from file
		# create new canvas
		my $img = GD::Simple->new($canvas_w, $canvas_h);


		# draw a filled rectangle with borders around player
		$img->penSize(1,1); 
		$img->angle(0);
		$img->bgcolor('yellow');
		$img->fgcolor('red');
		$img->rectangle($x1, $y1, $x2, $y2);	
		# (top_left_x,	top_left_y,	bottom_right_x,	bottom_right_y	)
		# ($x1, 		$y1,		$x2,			$y2				)
#		$parameters .= "Coordinates of Player:\t\$x1 = $x1\t\$y1 = $y1\t\$x2 = $x2\t\$y2 = $y2\n";


		# draw a rectangle with borders around video inside player
		$img->penSize(1,1); 
		$img->angle(0);
		$img->bgcolor(undef);
		$img->fgcolor('blue');
		$img->rectangle($x3, $y3, $x4, $y4);
		# (top_left_x,	top_left_y,	bottom_right_x,	bottom_right_y	)
		# ($x3, 		$y3,		$x4,			$y4				)
#		$parameters .= "Coordinates of Video:\t\$x3 = $x3\t\$y3 = $y3\t\$x4 = $x4\t\$y4 = $y4\n";

		# convert into png and name it same as html file (name of current TC)
		my $imgName = $tc.".png";
		my $relativeHtmlPath = $dirName.$dirDelimiter.$tc.".html";
		open (my $out, ">".$dirName.$dirDelimiter.$imgName) || die "can't create file$!";
		binmode $out;
		print $out $img->png;

		open (HTML , ">".$relativeHtmlPath) || die "can't create file$!" ;

print HTML "<!DOCTYPE HTML>
<HTML>
<HEAD>
<TITLE>Test Videostir: $tc</TITLE>
<STYLE type=\"text/css\">
body {
	margin: 30;
	padding: 0;
	background-attachment: fixed;
	background-image: url($imgName);
	background-repeat: no-repeat;
	background-position: 0px 0px;
}
</STYLE>
</HEAD>
<BODY>
<h1>$tc</h1>
<h2>Video player script:</h2>
<p>";

my $vp_script = $line3;
$vp_script =~ s/</&lt;/g;
$vp_script =~ s/>/&gt;/g;

print HTML "$vp_script</p>\n
<h2>Parameters:</h2>\n
<pre>\n$parameters\n</pre>\n
$line1\n
$line2\n
$line3\n
</BODY>\n
</HTML>";
		close HTML;

		print INDEX "\t|\t<a href=$tc.html target=blank>$tc</a>";
	}
}

############################################################### 
sub getTime {
	my $ts = sprintf "%02d-%02dT%02d-%02d-%02d", localtime->mday(),localtime->mon() +1 ,localtime->hour(), localtime->min(),	localtime->sec();
	return $ts;
}