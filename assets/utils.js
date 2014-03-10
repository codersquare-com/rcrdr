getCookie= function (c_name)
{
    var i,x,y,ARRcookies=document.cookie.split(";");
    for (i=0;i<ARRcookies.length;i++)
    {
        x=ARRcookies[i].substr(0,ARRcookies[i].indexOf("="));
        y=ARRcookies[i].substr(ARRcookies[i].indexOf("=")+1);
        x=x.replace(/^\s+|\s+$/g,"");
        if (x==c_name)
        {
            return unescape(y);
        }
    }
};

setCookie = function(c_name, value, exdays) {
    var exdate=new Date();
    exdate.setDate(exdate.getDate() + exdays);
    var c_value=escape(value) + ((exdays==null) ? "" : "; expires="+exdate.toUTCString());
    c_value = c_value + ";path=/";
    document.cookie=c_name + "=" + c_value;
};
$(document).ready(function(){
    $("html").on('click', ".toggle-dom", function(e){
        var targetId = $(this).attr('target-id');
        if ($(this).attr('data-toggle-into') == 'modal')
        {
            //toogle DOM into a dialog
            $("#ajaxModal").find('.modal-header').find('h3,h4').html($(this).text());
            $("#ajaxModal").find('.modal-body').html($("#" + targetId).html());
            $("#ajaxModal").modal('show');
        }
        else 
            $("#" + targetId).toggle();
        
        e.preventDefault();
        return false;
    });
});
