<h1>VideoStir_perl_php_tc_page_gen</h1>
<p><strong>TOOL</strong> for automated creation of pages for visual testing of VideoStir player settings sequences.</p>
<p><strong>TOOL</strong> ("perl\player_test_added.pl") is to be started<br></p>
<ul>
<li>	- directly from command prompt/shell (from <strong>TOOL</strong> root directory) or<br> 
<li>	- trough index.php (if this <strong>TOOL</strong> is installed on WAMP or LAMP server) or<br> 
<li>	- trough test_generator.bat (on Windows)<br>
</ul>	
<p>After each start new link to new testsuite ("index.html" in "out/TestSuiteName" directory) will be written to global index ("index.html" in TOOL root directory)</p>

<h2>For correct work <strong>TOOL</strong> need following directoryes and files:</h2>
<pre>
VideoStir_perl_php_tc_page_gen\─┬─css\────tc.css
                                ├─in\───┬─input.txt
                                │       ├-inputBig.txt
                                │       ├-inputBig2.txt
                                │       └-inputBig3.txt
                                ├─js\───┬─jquery.min.js
                                │       ├-pop_up_window_open.js
                                │       └-timer.js
                                ├─out\
                                ├─perl\───player_test_added.pl
                                ├─test_generator.bat
                                └─index.php
</pre>
<p>For correct displaying of test pages, scrollbars are turned off, use arrows for navigation instead.</p>
<h2>SETUP</h2>
<h3>linux</h3>
<ol>
<li>1 copy directory tree to LAMP server;
<li>2 check/set owning/permissions for copyed directory tree to Apache user;
<li>3 check/set executable for perl scripts;
<li>4 enable PHP in Apache web server settings;
<li>5 check/set default document to index.php in Apache web server settings;
<li>6 set webroot to folder with index.php;
<li>7 point web browser to your web server and enjoy!
</ol>
<h3>windows</h3>

<p>Alternatively you can use perl script on windows with perl installed,
see/change/run test_generator.bat file</p>

