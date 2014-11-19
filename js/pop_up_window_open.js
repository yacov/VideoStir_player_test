var popupWindow = null; // global variable

function openPopupWindow(url,WindowName,width,height) {
var popupParameters = "resizable=no,scrollbars=no,status=no,width=" + width + ",height=" + height;
  if(popupWindow == null || popupWindow.closed)
  /* if the pointer to the window object in memory does not exist
     or if such pointer exists but the window was closed */

  {
    popupWindow = window.open(url,WindowName,popupParameters);
    /* then create it. The new window will be created and
       will be brought on top of any other window. */
  }
  else
  {
	popupWindow.focus();
	 /* else the window reference must exist and the window
       is not closed; therefore, we can bring it back on top of any other
       window with the focus() method. There would be no need to re-create
       the window or to reload the referenced resource. */
  };
}


