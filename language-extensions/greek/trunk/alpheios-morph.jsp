<%@page import="perseus.document.*, perseus.util.*, perseus.ie.*, perseus.morph.*, edu.unc.epidoc.transcoder.TransCoder, java.net.URLEncoder, java.util.*, static perseus.morph.AlpheiosMorphCode.*"
        pageEncoding="UTF-8"
        contentType="text/xml;charset=UTF-8"%><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><fmt:requestEncoding value="UTF-8" /><?xml version="1.0" encoding="UTF-8" ?>
<%
    // get word to analyze
    // if none, give up with error
    String word = request.getParameter("word");
    if (word == null)
    {
        out.print("<error>No word supplied</error>");
        return;
    }

    // get language and map to code for xml:lang attribute
    String languageCode = request.getParameter("lang");
    if (languageCode == null)
        languageCode = "greek";
    String isoCode;
    if (languageCode == "greek")
        isoCode = "grc";
    else if (languageCode == "latin")
        isoCode = "lat";
    else if (languageCode == "oe")
        isoCode = "ang";
    else
        isoCode = languageCode;

    String outputFormat = request.getParameter("encoding");
    if (outputFormat == null)
        outputFormat = "UnicodeC";

    String inputFormat = request.getParameter("input");
    if (inputFormat == null)
    {
        if (languageCode == "greek")
            inputFormat = "BetaCode";
        else
            inputFormat = "Unicode";
    }

    // convert to beta code if necessary
    String  betaWord = word;
    if (inputFormat != "BetaCode")
    {
        TransCoder  tc = new TransCoder(inputFormat, "BetaCode");
        betaWord = tc.getString(word);
    }

    LanguageAdapter adapter = LanguageAdapter.getLanguageAdapter(languageCode);
    betaWord = adapter.getLookupForm(betaWord);

    // analyze the word
    Map<Lemma,List<Parse> > lemmaParses =
        Parse.getParses(betaWord, languageCode, false, false);

    // if nothing found, give up
    if (lemmaParses.isEmpty())
    {
        out.print("<unknown>" + word + "</unknown>");
        //out.print("<encoding>" + request.getCharacterEncoding() + "</encoding>");
        return;
    }

    out.print("<word>");
    AlpheiosMorphCodeGenerator  gen = new AlpheiosMorphCodeGenerator();

    // for each possible lemma
    for (Lemma lemma : lemmaParses.keySet())
    {
        Renderer renderer = new Renderer(languageCode);
        renderer.addTokenFilter(new GreekTranscoderTokenFilter(outputFormat));

        // for each possible inflection for this lemma
        StringBuffer    inflections = new StringBuffer();
        StringBuffer    dictAttrs = new StringBuffer();
        boolean         seenPofs = false;
        boolean         nounPofs = false;
        boolean         seenGend = false;
        for (Parse parse : lemmaParses.get(lemma))
        {
            inflections.append("<infl>");
            inflections.append(
                    "<term xml:lang=\"" + isoCode + "\"><stem>" +
                    renderer.render(parse.getExpandedForm()) +
                    "</stem></term>");

            Map<String,String>  features = gen.getFeatures(parse.getCode());
            for (String feature : features.keySet())
            {
                String  value = features.get(feature);

                // look for dictionary attributes
                if (!seenPofs && (feature == PART_OF_SPEECH))
                {
                    seenPofs = true;
                    if (value == NOUN)
                        nounPofs = true;
                    dictAttrs.append(
                        "<" + feature + ">" + value + "</" + feature + ">");
                }
                else if (nounPofs && !seenGend && (feature == GENDER))
                {
                    seenGend = true;
                    dictAttrs.append(
                        "<" + feature + ">" + value + "</" + feature + ">");
                }

                // check if we should use feature as tag name
                if (   (feature == PART_OF_SPEECH)
                    || (feature == CASE)
                    || (feature == DEGREE)
                    || (feature == GENDER)
                    || (feature == MOOD)
                    || (feature == NUMBER)
                    || (feature == PERSON)
                    || (feature == TENSE)
                    || (feature == VOICE))
                {
                    inflections.append(
                        "<" + feature + ">" + value + "</" + feature + ">");
                }
                else
                {
                    inflections.append(
                            "<note>" +
                            LanguageAdapter
                                .getLanguageAdapter("English")
                                .capitalize(feature) +
                            ": " +
                            value +
                            "</note>");
                }
            }
            inflections.append("</infl>");
        }

        out.print("<entry>");

        // render headword in output format
        out.print("<dict>");
        out.print("<hdwd xml:lang=\"" + isoCode + "\">" +
                  renderer.render(lemma.getHeadword()) +
                  "</hdwd>");
        out.print(dictAttrs.toString());
        out.print("</dict>");

        // put out definition
        if (lemma.getShortDefinition() != null)
            out.print("<mean>" + lemma.getShortDefinition() + "</mean>");

        out.print(inflections.toString());
        out.print("</entry>");
    }

    out.print("</word>");
%>
