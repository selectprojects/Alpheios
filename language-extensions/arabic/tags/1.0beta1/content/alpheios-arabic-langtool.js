/**
 * @fileoverview Arabic extension of Alph.LanguageTool class
 * @version $Id$
 *
 * Copyright 2008-2009 Cantus Foundation
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

Alph.LanguageToolFactory.addLang('arabic','LanguageTool_Arabic');

/**
 * @class  Arabic implementation of {@link Alph.LanguageTool} 
 * @extends Alph.LanguageTool
 * @param {String} a_language  the source language for this instance
 * @param {Properties} a_properties additional properties to set as private members of
 *                                  the object (accessor methods will be dynamically created)
 */
Alph.LanguageTool_Arabic = function(a_lang, props)
{
    Alph.LanguageTool.call(this,a_lang,{});
};

/**
 * @ignore
 */
Alph.LanguageTool_Arabic.prototype = new Alph.LanguageTool();

