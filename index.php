<HTML>
<HEAD>
<TITLE>Test Videostir</TITLE>
<script type="text/javascript" src="js/jquery.min.js"></script>
</HEAD>
<BODY>
<?php
if(!isset($_POST['width']) || !isset($_POST['height'])) {
echo '<script type="text/javascript">
$(document).ready(function () {
var height = $(window).height();
var width = $(window).width();
$.ajax({
	type: \'POST\',
	url: \'index.php\',
	data: {
		"height": height,
		"width": width
	},
	success: function (data) {
		$("body").html(data);
	},
});
});
</script>
';
}
?>
<?php
echo "<h1>Screen Resolution:</h1>";
echo "<p>Width  : ".$_POST['width']."</p>";
echo "<p>Height : ".$_POST['height']."</p>";

$script_string = "perl perl/player_test_added.pl in/inputBig.txt ".$_POST['width']." ".$_POST['height'];
echo "<hr>\n<p>script Start string: \"$script_string\"</p>";
$result = shell_exec($script_string);
echo $result;
?>
<a href="index.html">Global Index</a>
<br/>
<hr>
</BODY>
</HTML>