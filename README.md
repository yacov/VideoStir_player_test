 VideoStir_perl_php_tc_page_gen
================================

TOOL for automated creation of pages for visual testing of VideoStir player settings sequences.

TOOL ("perl\player_test_added.pl") is to be started 
	- directly from command prompt/shell (from TOOL root directory) or 
	- trough index.php (if this TOOL is installed on WAMP or LAMP server) or 
	- trough test_generator.bat (on Windows)
	
After each start new link to new testsuite ("index.html" in "out/TestSuiteName" directory) will be written to global index ("index.html" in TOOL root directory) 

For correct work TOOL need following directoryes and files:

VideoStir_perl_php_tc_page_gen\─┬─css\────tc.css<br>
********************************├-in\───┬─input.txt<br>
********************************│*******├-inputBig.txt<br>
********************************│*******├-inputBig2.txt<br>
********************************│*******└-inputBig3.txt<br>
********************************├-js\───┬─jquery.min.js<br>
********************************│*******├-pop_up_window_open.js<br>
********************************│*******└-timer.js<br>
********************************├-out\<br>
********************************├-perl\───player_test_added.pl<br>
********************************├-test_generator.bat<br>
********************************└-index.php<br>

For correct displaying of test pages, scrollbars are turned off, use arrows for navigation instead.

---- SETUP ----

<<<< linux >>>>

1 copy directory tree to LAMP server;

2 check/set owning/permissions for copyed directory tree to Apache user;

3 check/set executable for perl scripts;

4 enable PHP in Apache web server settings;

5 check/set default document to index.php in Apache web server settings;

6 set webroot to folder with index.php;

7 point web browser to your web server and enjoy!

<<<< windows >>>>

Alternatively you can use perl script on windows with perl installed,

see/change/run test_generator.bat file

