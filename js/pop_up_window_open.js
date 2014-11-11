<input onclick="ifield = form.LockFile; 
chooser = window.open(&quot;
/chooser.cgi?add=0&amp;
type=0&amp;
chroot=/&amp;
file=&quot;
+encodeURIComponent(ifield.value), &quot;chooser&quot;
, &quot;
toolbar=no,menubar=no,scrollbars=no,resizable=yes,width=400,height=300&quot;);
 chooser.ifield = ifield; 
 window.ifield = ifield" value="..." type="button">