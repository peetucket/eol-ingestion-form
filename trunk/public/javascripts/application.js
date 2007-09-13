// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function addLoadEvent(func) {
	// add the specific function to the onload stack for the page
  var oldonload = window.onload;
  if (typeof window.onload != 'function') {
    window.onload = func;
  } else {
    window.onload = function() {
      if (oldonload) {
        oldonload();
      }
      func();
    }
  }
}

function submitForm() {
	showAjaxIndicator();
	$('submit_button').value='Please Wait...';
	$('submit_button').disabled='true';
	document.forms[0].submit();
}

function showAjaxIndicator() {
	Element.show('ajax-indicator');
}

function hideAjaxIndicator() {
	Element.hide('ajax-indicator');	
}

function toggleElement(divName) {
	Element.toggle(divName);
}