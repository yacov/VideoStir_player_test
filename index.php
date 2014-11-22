<HTML>
<HEAD>
<TITLE>Test Videostir</TITLE>
</HEAD>
<BODY>
<?php
if(!isset($_POST['width']) || !isset($_POST['height'])) {
echo '<form action="index.php" method="post" name="frm">
  <p>
    Input required browser window width:
    	<input name="width" type="text" size="10" maxlength="4">
  </p>
  <p>    	Input required browser window height:
<input name="height" type="text" size="10" maxlength="4">
  </p>
  <p>
    <input name="Button" type="button" onMouseUp="document.frm.width.value=window.innerWidth;
document.frm.height.value= window.innerHeight ;" value="Get current browser window dimensions">
    <input type="submit" value="Generate test cases">
    <input type="reset" value="Reset">
  </p>
</form>
';
}
else {
echo "<h1>Screen Resolution:</h1>";
echo "<p>Width  : ".$_POST['width']."\tHeight : ".$_POST['height']."</p>";
$script_string = "perl perl/player_test_added.pl in/inputBig.txt ".$_POST['width']." ".$_POST['height'];
echo "<hr>\n<p>script Start string: \"$script_string\"</p>";
$result = shell_exec($script_string);
echo $result.
'<hr>
<a href="index.html">Global Index</a>';
}
?>
</BODY>
</HTML>