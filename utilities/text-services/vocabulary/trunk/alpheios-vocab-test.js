var reposUrl = "http://dev.alpheios.net:8800/exist/rest/db/xq";

$(function() {
                $(".selectTg").change(show_works);
                $(".selectWk").change(show_eds);
                $(".selectEd").change(show_cites);
                $('.selectTg').trigger('change');
                $("#showkeylink").click(showkey);
                $("#vocabfmtlink").click(showvocabfmt);
                $("#textfmtlink").click(showtextfmt);
                $("form").submit(
                    function()
                    {
                        var vocabUrns = make_urn('*','src',true);
                        var docUrns = make_urn('*','target',true);
                        $("input[name=vocabUrn]").remove();
                        $("input[name=docUrn]").remove(); 
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
                        if ($("#doc").val())
                        {
                            $("input[name=docUrn]").remove();
                        }
                        else if (docUrns.length > 1 && docUrns[1].length > 0)
                        {
                           for (var i=1; i<docUrns.length; i++)
                            {
                               for (var u=0; u<docUrns[i].length; u++) {
                                   $("form").append('<input type="hidden" name="docUrn" value="' + docUrns[i][u] + '"/>');
                               }
                            }
                        }
                        else {
                            alert("You must specify a text citation range or supply target text");
                            return false;
                        }
                        if ($("#vocabDoc").val())
                        {
                            $("input[name=vocabUrn]").remove();
                        }
                        else if (vocabUrns.length > 1 && vocabUrns[1].length > 0)
                        {
                            for (var i=1; i<vocabUrns.length; i++)
                            {
                               for (var u=0; u<vocabUrns[i].length; u++) {
                                   $("form").append('<input type="hidden" name="vocabUrn" value="' + vocabUrns[i][u] + '"/>');
                               }
                            }
                        }
                        else {
                            alert("You must specify a vocabulary citation range or supply vocabulary text");
                            return false;
                        }
                        this.submit();
                        return false;
                    }
                );
                
});                            

/**
 * Click handler for Textgroup Select 
 */
function show_works()
{
    var name = $(this).attr("name");
    var regex = /^(src|target)TgUrn(\d+)$/g;
    var match = regex.exec(name);
    var a_num = match[2];
    var a_type = match[1]
    var tg = $(this).val();
    var sel = $('select[name=' + a_type + 'WkUrn' + a_num + ']');
    $('option', sel).remove();
    var mysel ='wk_'+tg;
    mysel = $('#' + mysel);
    $('option', mysel).clone().appendTo(sel);
    $(sel).removeAttr("disabled");
    $(sel).show();
    $(sel).trigger('change');
}

/**
 * Click handler for Work select
 */
function show_eds()
{
    var name = $(this).attr("name");
    var regex = /^(src|target)WkUrn(\d+)$/g;
    var match = regex.exec(name);
    var a_num = match[2];
    var a_type = match[1]
    var tg = $(this).val();
    var tg = $("select[name=" + a_type + "TgUrn" + a_num + "]").val();
    var wk = $(this).val();
    var sel = $('select[name=' + a_type + 'EdUrn' + a_num + ']');
    $('option', sel).remove();
    var mysel = 'ed_'+tg+'_'+wk;
    mysel = $('#' + mysel);
    $('option', mysel).clone().appendTo(sel);
    $(sel).removeAttr("disabled");
    $(sel).show();
    $(sel).trigger('change');
    
}

/**
 * Create the urns from the textgroup, work, edition and range inputs
 */
function make_urn(a_num,a_type,a_includeRange)
{
    var nums = []
    if (a_num == '*')
    {
        var tgs = $('select.' + a_type + 'Tg').each(
            function() {
                var name = $(this).attr('name');
                var regex = /^.*?(\d+)$/g;
                var match = regex.exec(name);
                if (match.length > 1)
                {
                    nums.push(match[1])
                }
            }
        )
    } 
    else
    {
        nums.push[a_num];
    }
    var all_urns = [];
    for (var i=0; i< nums.length; i++)
    {
        var elem_num = nums[i]
        var tg = $("select[name=" + a_type + "TgUrn" + elem_num + "]").val().replace(/_/,':');
        var wk = $("select[name=" + a_type + "WkUrn" + elem_num + "]").val().replace(/_/,':');
        var ed = $('select[name=' + a_type + 'EdUrn' + elem_num + ']').val().replace(/_/,':');
        var tg_ns = tg.split(/:/,2); 
        var wk_ns = wk.split(/:/,2);
        var ed_parts = ed.split(/\|/,2);
        var ed_ns = ed_parts[1].split(/:/,2);
        var ed_level = ed_parts[0]
        if (tg_ns.length > 1 && wk_ns.length > 1 && wk_ns[0] == tg_ns[0])
        {
            // drop the work namespace if it matches the textgroup namespace
            wk = wk_ns[1];
        }
          if (wk_ns.length > 1 && ed_ns.length > 1 && ed_ns[0] == wk_ns[0])
        {
            // drop the edition namespace if it matches the work namespace
            ed = ed_ns[1];
        }
        var urn = ('urn:cts:' + tg + '.' + wk + '.' + ed);
        if (a_includeRange)
        {
            all_urns[elem_num] = [];
            var ranges = $('input[name="' + a_type + "Range" +elem_num + '"]').each(
                function()
                {
                    var vals = $(this).val().split(/\s*,\s*/);
                    for (var i=0; i<vals.length; i++)
                    {
                        // * means entire text so exclude passage part of urn
                        if (vals[i] == '*')
                        {
                            all_urns[elem_num].push(urn);
                        }
                        else if (vals[i])
                        {
                            all_urns[elem_num].push(urn + ':' + vals[i]);
                        }
                    }
                }
            );
        }
        else {
            all_urns[elem_num] = urn;
        }
    }
    return all_urns;
}
/**
 * Event handler for Edition select
 */
function show_cites(a_num,a_type)
{
    var name = $(this).attr("name");
    var regex = /^(src|target)EdUrn(\d+)$/g;
    var match = regex.exec(name);
    var a_num = match[2];
    var a_type = match[1]
    var urn = make_urn(a_num,a_type,false)[a_num];
    var rangeCell = $('#' + a_type + 'RangeCell'+a_num);
    rangeCell.html('<input class="' + a_type + 'Range" type="text" name="' + a_type + "Range" + a_num +  '"' + 
                                                      ' urn="' + urn +'"/>' +
                                       '<button num="' + a_num +'">Add...</button>');
    $('button',rangeCell).click(addMore);
                                        
    //getValidReffs(urn,ed_level,1);
}

function addMore()
{
    alert("The 'Add' button is not yet implemented -- will allow you to select another source or target. Click on 'Submit' to submit the page.");
    return false;
}

function getValidReffs(a_urn,a_endlevel,a_startlevel)
{
    
    $.ajax({
        url: "/exist/rest/db/xq/CTS.xq?request=GetValidReff&urn=" + a_urn + "&level=" + a_startlevel,
        dataType: 'xml',
        success: function(a_data){
            var next_level = a_startlevel + 1;
            if (next_level > a_endlevel)
            {
                $("urn", a_data).each(
                    function()
                    {
                        var urn = $(this).text();
                        var parts = urn.split(/:/);
                        $("select[name=srcRangeStart]").append('<option value="' + urn + '">' + parts[parts.length-1] + '</option>');
                    }
                 );
                 //var all_opt = $("select[name=srcRangeStart] option").clone().sort(
                 //   function(a,b){
                 //       var keyA = $(a).text();
                 //       var keyB = $(b).text();
                 //       return (keyA > keyB) ? 1 : 0; 
                 //   }
                //);
                //$("select[name=srcRangeStart] option").remove().append(all_opt);
                $("select[name=srcRangeStart]").removeAttr("disabled");
                $("select[name=srcRangeStart]").show();
            }
            else
            { 
                var urns = $("urn", a_data);
                var starturn = $(urns[0]).text().split(/:/);
                var endurn = $(urns[urns.length-1]).text().split(/:/);
                var parts = a_urn.split(/:/);
                var newurn = a_urn + ':';
                if (parts.length > 4)
                {
                    newurn = parts[0] + ':' + parts[1] + ':' + parts[2] + ':' + parts[3] + ':';
                }
                newurn = newurn + starturn[starturn.length-1] + '-' + endurn[endurn.length-1];
                getValidReffs(newurn,a_endlevel,next_level);
            }
        }
});
}
function showkey()
{
    $(".dropkey").toggleClass("show");        
    return false;
}
function showvocabfmt()
{
    $(".vocabfmt").toggleClass("show");        
    return false;
}
function showtextfmt()
{
    $(".textfmt").toggleClass("show");        
    return false;
}

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