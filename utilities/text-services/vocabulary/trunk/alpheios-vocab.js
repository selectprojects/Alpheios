$(function()
{
    $(".toggle").click(
        function()
        {
            $(this).toggleClass("collapsed");
            $(".toggle-text",this).toggleClass("collapsed");
        }    
    );    
});

