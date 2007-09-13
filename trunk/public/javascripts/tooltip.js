// Extended Tooltip Javascript
// copyright 9th August 2002, 3rd July 2005
// by Stephen Chapman, Felgall Pty Ltd

// permission is granted to use this javascript provided that the below code is not altered


var DH = 0;
var an = 0;
var al = 0;
var ai = 0;
var disappeardelay = 250;  //menu disappear speed onMouseout (in miliseconds)
var ie4=document.all;
var ns6=document.getElementById&&!document.all;

if (document.getElementById)
{
    ai = 1;
    DH = 1;
}else
{
    if (document.all)
    {
        al = 1;
        DH = 1;
    }else
    {
        browserVersion = parseInt(navigator.appVersion);
        if ((navigator.appName.indexOf('Netscape') != -1) && (browserVersion == 4))
        {
            an = 1;
            DH = 1;
        }
    }
} 



function fd(oi, wS)
{
    if (ai) return wS ? document.getElementById(oi).style:document.getElementById(oi);
    if (al) return wS ? document.all[oi].style: document.all[oi];
    if (an) return document.layers[oi];
}



function pw()
{
    return window.innerWidth != null? window.innerWidth: document.body.clientWidth != null? document.body.clientWidth:null;
}

function mouseX(evt)
{
    if (evt.pageX) return evt.pageX;
    else if (evt.clientX)return evt.clientX + (document.documentElement.scrollLeft ?  document.documentElement.scrollLeft : document.body.scrollLeft);
    else return null;
}

function mouseY(evt)
{
    if (evt.pageY) return evt.pageY;
    else if (evt.clientY)return evt.clientY + (document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop);
    else return null;
}

function popUp(evt,oi)
{
    if (DH)
    {
        var wp = pw();
        ds = fd(oi,1);
        dm = fd(oi,0);
        st = ds.visibility;
        if (dm.offsetWidth) ew = dm.offsetWidth;
        else if (dm.clip.width) ew = dm.clip.width;
        
        tv = mouseY(evt) + 20;
        lv = mouseX(evt) - (ew/4);
        if (lv < 2) lv = 2;
        else if (lv + ew > wp) lv -= ew/2;
        if (!an)
        {
            lv += 'px';tv += 'px';
        }
        ds.left = lv;
        ds.top = tv;
        ds.visibility = "visible";
    }
}





function popUp2(oi,xPos,yPos)
{
    if (DH)
    {
        var wp = pw();
        ds = fd(oi,1);
        dm = fd(oi,0);
        st = ds.visibility;
        if (dm.offsetWidth) ew = dm.offsetWidth;
        else if (dm.clip.width) ew = dm.clip.width;
        
        var x = document.getElementById("pageImage");
        var coors = findPos(x);
    	
    	var theX = coors[0] + xPos;
        var theY = coors[1] + yPos;
        theX += 'px';
        theY += 'px';
        
        ds.left = theX;
        ds.top = theY;
        ds.visibility = "visible";
    }
}



function popUp3(oi)
{
    if (DH)
    {
        ds = fd(oi,1);
        ds.visibility = "visible";
    }
}




function delayhidemenu(oi)
{
    ds = fd(oi,1);
    ds.visibility = "hidden";
}










function findPos(obj)
{
	var curleft = curtop = 0;
	if (obj.offsetParent) {
		curleft = obj.offsetLeft
		curtop = obj.offsetTop
		while (obj = obj.offsetParent) {
			curleft += obj.offsetLeft
			curtop += obj.offsetTop
		}
	}
	return [curleft,curtop];
}


function checkValue(obj,field)
{
    if (field=="First")
    {
        if (obj.value=="First") obj.value = "";
    }else if (field=="Middle")
    {
        if (obj.value=="M") obj.value = "";
    }else if (field=="Last")
    {
        if (obj.value=="Last") obj.value = "";
    }
}
