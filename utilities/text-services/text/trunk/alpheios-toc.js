/**
 * @fileoverview Javascript functionality for Alpheios tocs
 *
 * @version $Id:  $
 *
 * Copyright 2010 Cantus Foundation
 * http://alpheios.net
 *
 * This file is part of Alpheios.
 *
 * Alpheios is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Alpheios is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
 function alpheiosTocReady() 
 {     
     $('.tochead .tocitem a').click(
         function(a_e)
         {    
             $(window.frameElement).siblings().get(0).contentDocument.location=$(this).attr("href");                                     
             return false;
         }
     );
    $('.tochead').click(function() {           e 
            $(this).toggleClass("openmenu");
            var children = $(this).children();
            if (children.length > 0)
            {
                $(this).children().toggle();
            }
            else
            {
                var tocHead = this;
                $.ajax({
                    type: "GET",
                    async: true,
                    dataType: "html",
                    cache: true,
                    url: $(tocHead).attr("href"),
                    success:
                        function(a_data,a_status,a_req)
                        {
                            $("ul",a_data).appendTo(tocHead);
                        },        
                    error:
                        function(a_req,a_status,a_err)
                        {
                            $(tocHead).append("<div>"+a_err+"</div>");
                        }                    
                });
            }
            return true;
      });
}