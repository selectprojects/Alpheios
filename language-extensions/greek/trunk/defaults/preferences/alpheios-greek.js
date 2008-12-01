pref("extensions.alpheios.greek.usemhttpd", true);
pref("extensions.alpheios.greek.chromepkg","alpheios-greek");
pref("extensions.alpheios.greek.languagecode","grc");
pref("extensions.alpheios.greek.base_unit","word");
pref("extensions.alpheios.greek.methods.startup",'loadDictionary');
pref("extensions.alpheios.greek.methods.convert",'greek_to_ascii');
pref("extensions.alpheios.greek.methods.lexicon",'webservice');
pref("extensions.alpheios.greek.url.lexicon", 'http://localhost:8200');
pref("extensions.alpheios.greek.url.lexicon.request", "/greek?word=<WORD>");
pref("extensions.alpheios.greek.url.lexicon.timeout",5000);
pref("extensions.alpheios.greek.popuptrigger",'mousemove');
pref("extensions.alpheios.greek.url.grammar",
     "chrome://alpheios-greek/content/alph-greek-grammar.xul");
pref("extensions.alpheios.greek.grammar.hotlinks",
     "alph-decl,alph-pofs,alph-mood,alph-case,alph-voice,alph-pers,alph-tense");
pref("extensions.alpheios.greek.features.alpheios-grammar",true);
pref("extensions.alpheios.greek.features.alpheios-inflect",true);
pref("extensions.alpheios.greek.context_handler","grammarContext");
pref("extensions.alpheios.greek.shift_handler","handleInflections");
pref("extensions.alpheios.greek.panels.use.defaults",true);
