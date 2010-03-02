$(function()
{
    $(".toggle").click(
        function()
        {
            $(this).parent().toggleClass("collapsed");
            $(".toggle-text",this).toggleClass("collapsed");
        }    
    );
    $("#select-pofs").change(
        function()
        {
             var pofs = this.value;             
             var url = get_url();
             url = url.replace(/<POFS>/,pofs);
             url= url.replace(/<SORT>/,$("input[name=sort]:checked").attr("value"));
             document.location=url;
        }
    );                    
    $("input[name=sort]").click(
        function()
        {
            var sort = this.value;
            var url = get_url();
             url = url.replace(/<POFS>/,$("#select-pofs option:selected").attr("value"));
             url= url.replace(/<SORT>/,sort);
             document.location=url;            
        }
    );
});

function get_url() 
{
    return "alpheios-infl-freq.xq?doc=" + 
        $("meta[name=alpheios-docid]").attr("content") +
        "&lang=" +                      
        $("meta[name=alpheios-lang]").attr("content") +
        "&pofs=<POFS>&sort=<SORT>";
}
