<HTML>
<HEAD>
<TITLE>Test Videostir</TITLE>
<script type="text/javascript" src="js/jquery.min.js"></script>
</HEAD>
<BODY>
<?php
//if(isset($_GET['code']))
//{
//	header('content-type: text/plain; charset=utf-8');
//	echo file_get_contents(__FILE__);
//	exit;
//}

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

$script_string = "perl perl/player_test_added.pl in/inputBig3.txt ".$_POST['width']." ".$_POST['height'];
echo "<hr><p>run script: ".$script_string."</p>";
$result = shell_exec($script_string);
echo $result;
?>
<br/>
<hr>
<!--<a href="?code" target="_blank">this page source php-code</a>-->
</BODY>
</HTML>