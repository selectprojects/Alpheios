var reposUrl = "http://dev.alpheios.net:8800/exist/rest/db/xq";

$(function() {                                 
                $("form").submit(
                    function()
                    {
                        $("input[name=excludepofs]:checked").each(
                            function() { $(this).val("1") });
                        $("input[name=missed]:checked").each(
                            function() { $(this).val("1") });
                        if ($("input.xmlFormat:checked",this).length >0) 
                        {
                            $("input[name=format]",this).val("xml");
                        } 
                        else
                        {
                            $("input[name=format]",this).val("html");
                        }
                        if ($("input[name=doc]",this).length > 0)
                        {
                            $("input[name=docUrn]",this).remove();
                        }
                        this.submit();
                        return false;
                    }
                );
                
});                            

function getInventory()
{
    $.ajax({
                    type: "GET",
                    async: true,
                    dataType: "xml",
                    cache: false,
                    url: reposUrl + "/alpheios-get-toc.xq?q=getCapabilities",
                    success:  getTexts,
                     error:
                        function(a_req,a_text,a_error){alert("Error: " + a_error + ":" + a_text)}
                })                
}

function getTexts(a_data,a_status)
{
    alert(a_data);
    $("work",a_data).each(
        function()
        {
            alert($("title",this));
        }
    )
}
function populateSelects()
{
                $("select.inventory").each(
                    function()
                    {
                    }
                );               
}