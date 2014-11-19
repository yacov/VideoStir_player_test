var ms = 0;
var s = 0;
var timer; 
var delay = 0;

function display(){
var indicator = document.getElementById("time");
	if (ms>=9){
		ms=0
		s+=1
	}
	else
		ms+=1
	indicator.textContent = s + "." + ms;
	timer = setTimeout("display()",100);
	
	if (s>=delay)
		indicator.style.backgroundColor = "#00FF00";
	else
		indicator.style.backgroundColor = "yellow";
}

function setDelay(playbackDelay){
	delay = playbackDelay;	
}

function starttimer() {
  if (timer > 0) {
	return;
  }
  display();	
}

function stoptimer() {
  clearTimeout(timer);
  timer = 0;
}

function startstoptimer() {
  if (timer > 0) {
     clearTimeout(timer);
     timer = 0;
  } else {
     display();
  }
}

function resettimer() {
	stoptimer();
	ms = 0;
	s = 0;
}

resettimer();