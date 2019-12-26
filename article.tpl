{**
 * templates/article/article.tpl
 *
 * Copyright (c) 2013-2016 Simon Fraser University Library
 * Copyright (c) 2003-2016 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * Article View.
 *}
{strip}
{if $galley}
	{assign var=pubObject value=$galley}
{else}
	{assign var=pubObject value=$article}
{/if}
{include file="article/header.tpl"}
{/strip}

{if $galley}
	{if $galley->isHTMLGalley()}
		{$galley->getHTMLContents()}
	{elseif $galley->isPdfGalley()}
		{include file="article/pdfViewer.tpl"}
	{/if}
{else}
	<div id="topBar">
		{if is_a($article, 'PublishedArticle')}{assign var=galleys value=$article->getGalleys()}{/if}
		{if $galleys && $subscriptionRequired && $showGalleyLinks}
			<div id="accessKey">
				<img src="{$baseUrl}/lib/pkp/templates/images/icons/fulltext_open_medium.gif" alt="{translate key="article.accessLogoOpen.altText"}" />
				{translate key="reader.openAccess"}&nbsp;
				<img src="{$baseUrl}/lib/pkp/templates/images/icons/fulltext_restricted_medium.gif" alt="{translate key="article.accessLogoRestricted.altText"}" />
				{if $purchaseArticleEnabled}
					{translate key="reader.subscriptionOrFeeAccess"}
				{else}
					{translate key="reader.subscriptionAccess"}
				{/if}
			</div>
		{/if}
	</div>
	{if $coverPagePath}
		<div id="articleCoverImage"><img src="{$coverPagePath|escape}{$coverPageFileName|escape}"{if $coverPageAltText != ''} alt="{$coverPageAltText|escape}"{else} alt="{translate key="article.coverPage.altText"}"{/if}{if $width} width="{$width|escape}"{/if}{if $height} height="{$height|escape}"{/if}/>
		</div>
	{/if}
	{call_hook name="Templates::Article::Article::ArticleCoverImage"}
	<div id="articleTitle"><h3>{$article->getLocalizedTitle()|strip_unsafe_html}</h3></div>
	<!-- <div id="authorString"><em>{$article->getAuthorString()|escape}</em></div> -->
	<div id="authorString">
    {assign var=authors value=$article->getAuthors()}
    {assign var=authorCount value=$authors|@count}
    {foreach from=$authors item=author name=authors key=i}
      {assign var=firstName value=$author->getFirstName()}
      <em>{$firstName|escape} {$author->getLastName()|escape}</em> -

      {assign var=affiliations value=$author->getAffiliation(null)}
      {assign var=affiliationCount value=$affiliations|@count}
      {foreach from=$affiliations item=affiliation key=i}
      	{$affiliation} {if $i==$affiliationCount-2}, &amp; {elseif $i<$affiliationCount-1}, {/if}
      {/foreach}

      {if $i==$authorCount-2}<br>{elseif $i<$authorCount-1}<br>{/if}
    {/foreach}
  </div>
	<br />
	{if $article->getLocalizedAbstract()}
		<div id="articleAbstract">
		<h4>{translate key="article.abstract"}</h4>
		<br />
		<div>{$article->getLocalizedAbstract()|strip_unsafe_html|nl2br}</div>
		<br />
		</div>
	{/if}

	{if $article->getLocalizedSubject()}
		<div id="articleSubject">
		<h4>{translate key="article.subject"}</h4>
		<br />
		<div>{$article->getLocalizedSubject()|escape}</div>
		<br />
		</div>
	{/if}

	{if (!$subscriptionRequired || $article->getAccessStatus() == $smarty.const.ARTICLE_ACCESS_OPEN || $subscribedUser || $subscribedDomain)}
		{assign var=hasAccess value=1}
	{else}
		{assign var=hasAccess value=0}
	{/if}

	{if $galleys}
		<div id="articleFullText">
		<h4>{translate key="reader.fullText"}</h4>
		{if $hasAccess || ($subscriptionRequired && $showGalleyLinks)}
			{foreach from=$article->getGalleys() item=galley name=galleyList}
				<a href="{url page="article" op="view" path=$article->getBestArticleId($currentJournal)|to_array:$galley->getBestGalleyId($currentJournal)}" class="file" {if $galley->getRemoteURL()}target="_blank"{else}target="_parent"{/if}>{$galley->getGalleyLabel()|escape}</a>
				{if $subscriptionRequired && $showGalleyLinks && $restrictOnlyPdf}
					{if $article->getAccessStatus() == $smarty.const.ARTICLE_ACCESS_OPEN || !$galley->isPdfGalley()}
						<img class="accessLogo" src="{$baseUrl}/lib/pkp/templates/images/icons/fulltext_open_medium.gif" alt="{translate key="article.accessLogoOpen.altText"}" />
					{else}
						<img class="accessLogo" src="{$baseUrl}/lib/pkp/templates/images/icons/fulltext_restricted_medium.gif" alt="{translate key="article.accessLogoRestricted.altText"}" />
					{/if}
				{/if}
			{/foreach}
			{if $subscriptionRequired && $showGalleyLinks && !$restrictOnlyPdf}
				{if $article->getAccessStatus() == $smarty.const.ARTICLE_ACCESS_OPEN}
					<img class="accessLogo" src="{$baseUrl}/lib/pkp/templates/images/icons/fulltext_open_medium.gif" alt="{translate key="article.accessLogoOpen.altText"}" />
				{else}
					<img class="accessLogo" src="{$baseUrl}/lib/pkp/templates/images/icons/fulltext_restricted_medium.gif" alt="{translate key="article.accessLogoRestricted.altText"}" />
				{/if}
			{/if}
		{else}
			&nbsp;<a href="{url page="about" op="subscriptions"}" target="_parent">{translate key="reader.subscribersOnly"}</a>
		{/if}
		</div>
	{/if}

	{if $citationFactory->getCount()}
		<div id="articleCitations">
		<h4>{translate key="submission.citations"}</h4>
		<br />
		<div>
			{iterate from=citationFactory item=citation}
				<p>{$citation->getRawCitation()|strip_unsafe_html}</p>
			{/iterate}
		</div>
		<br />
		</div>
	{/if}
{/if}

{foreach from=$pubIdPlugins item=pubIdPlugin}
	{if $issue->getPublished()}
		{assign var=pubId value=$pubIdPlugin->getPubId($pubObject)}
	{else}
		{assign var=pubId value=$pubIdPlugin->getPubId($pubObject, true)}{* Preview rather than assign a pubId *}
	{/if}
	{if $pubId}
		<br />
		<br />
		{$pubIdPlugin->getPubIdDisplayType()|escape}: {if $pubIdPlugin->getResolvingURL($currentJournal->getId(), $pubId)|escape}<a id="pub-id::{$pubIdPlugin->getPubIdType()|escape}" href="{$pubIdPlugin->getResolvingURL($currentJournal->getId(), $pubId)|escape}">{$pubIdPlugin->getResolvingURL($currentJournal->getId(), $pubId)|escape}</a>{else}{$pubId|escape}{/if}
	{/if}
{/foreach}
{if $galleys}
	{foreach from=$pubIdPlugins item=pubIdPlugin}
		{foreach from=$galleys item=galley name=galleyList}
			{if $issue->getPublished()}
				{assign var=galleyPubId value=$pubIdPlugin->getPubId($galley)}
			{else}
				{assign var=galleyPubId value=$pubIdPlugin->getPubId($galley, true)}{* Preview rather than assign a pubId *}
			{/if}
			{if $galleyPubId}
				<br />
				<br />
				{$pubIdPlugin->getPubIdDisplayType()|escape} ({$galley->getGalleyLabel()|escape}): {if $pubIdPlugin->getResolvingURL($currentJournal->getId(), $galleyPubId)|escape}<a id="pub-id::{$pubIdPlugin->getPubIdType()|escape}-g{$galley->getId()}" href="{$pubIdPlugin->getResolvingURL($currentJournal->getId(), $galleyPubId)|escape}">{$pubIdPlugin->getResolvingURL($currentJournal->getId(), $galleyPubId)|escape}</a>{else}{$galleyPubId|escape}{/if}
			{/if}
		{/foreach}
	{/foreach}
{/if}

<!-- <br>
<br>
<iframe src="{url page="rt" op="captureCite" path=$articleId|to_array:$galleyId}" width="100%" height="700" frameborder="0"></iframe>
<br> -->

<br>
<br>

<div id="ieee" class="citation_format" style="display: none">
  <div style="width: 100%;">
      <div id="citation" style="background-color:#eee; padding:10px;">
        <span style="font-weight: bold;">How to cite</span> (IEEE):
        {assign var=authors value=$article->getAuthors()}
        {assign var=authorCount value=$authors|@count}
        {foreach from=$authors item=author name=authors key=i}
        	{assign var=firstName value=$author->getFirstName()}
        	{$firstName|escape|truncate:1:"":true}. {$author->getLastName()|escape}{if $i==$authorCount-2}, &amp; {elseif $i<$authorCount-1}, {/if}
        {/foreach}

        "{$article->getLocalizedTitle()|strip_unsafe_html}," <em>{$journal->getLocalizedTitle()|escape}</em>, {if $issue && $issue->getVolume()}vol. {$issue->getVolume()|escape}{/if}{if $issue && $issue->getNumber()}, no. {$issue->getNumber()|escape}{/if}, {if $article->getPages()}, pp. {$article->getPages()}{/if}, {if $article->getDatePublished()}{$article->getDatePublished()|date_format:'%b. %Y'|trim}{elseif $issue->getDatePublished()}{$issue->getDatePublished()|date_format:'%b %Y'|trim}{else}{$issue->getYear()|escape}{/if}.
        {if $article->getPubId('doi')} <a href="https://doi.org/{$article->getPubId('doi')|escape}">https://doi.org/{$article->getPubId('doi')}</a>{else}{translate key="plugins.citationFormats.apa.retrieved" retrievedDate=$smarty.now|date_format:$dateFormatLong url=$articleUrl}{/if}
      </div>
  </div>
</div>

<div id="apa" class="citation_format" style="display: none">
  <div style="width: 100%;">
    <div id="citation" style="background-color:#eee; padding:10px;">
      <span style="font-weight: bold;">How to cite</span> (APA):
      {assign var=authors value=$article->getAuthors()}
      {assign var=authorCount value=$authors|@count}
      {foreach from=$authors item=author name=authors key=i}
      	{assign var=firstName value=$author->getFirstName()}
      	{$author->getLastName()|escape}, {$firstName|escape|truncate:1:"":true}.{if $i==$authorCount-2}, &amp; {elseif $i<$authorCount-1}, {/if}
      {/foreach}

      ({if $article->getDatePublished()}{$article->getDatePublished()|date_format:'%Y'}{elseif $issue->getDatePublished()}{$issue->getDatePublished()|date_format:'%Y'}{else}{$issue->getYear()|escape}{/if}).
      {$article->getLocalizedTitle()}.
      <em>{$journal->getLocalizedTitle()}{if $issue}, {$issue->getVolume()|escape}</em>{if $issue->getNumber()}({$issue->getNumber()|escape}){/if}{else}</em>{/if}{if $article->getPages()}, {$article->getPages()}{/if}.
      {if $article->getPubId('doi')} <a href="https://doi.org/{$article->getPubId('doi')|escape}">https://doi.org/{$article->getPubId('doi')}</a>{else}{translate key="plugins.citationFormats.apa.retrieved" retrievedDate=$smarty.now|date_format:$dateFormatLong url=$articleUrl}{/if}
    </div>
  </div>
</div>

<div id="chicago" class="citation_format" style="display: none">
  <div style="width: 100%;">
    <div id="citation" style="background-color:#eee; padding:10px;">
      <span style="font-weight: bold;">How to cite</span> (Chicago):
      {assign var=authors value=$article->getAuthors()}
      {assign var=authorCount value=$authors|@count}
      {foreach from=$authors item=author name=authors key=i}
      	{assign var=firstName value=$author->getFirstName()}
      	{$author->getLastName()|escape}, {$firstName|escape}{if $i==$authorCount-2}, {translate key="rt.context.and"} {elseif $i<$authorCount-1}, {else}.{/if}
      {/foreach}

      "{$article->getLocalizedTitle()|strip_unsafe_html}" <em>{$journal->getLocalizedTitle()|escape}</em> [{translate key="rt.captureCite.online"}], {if $issue && $issue->getVolume()}{translate key="issue.volume"} {$issue->getVolume()|escape}{/if}{if $issue && $issue->getNumber()} {translate key="issue.number"} {$issue->getNumber()|escape} {/if}({if $article->getDatePublished()}{$article->getDatePublished()|date_format:'%e %B %Y'|trim}{elseif $issue->getDatePublished()}{$issue->getDatePublished()|date_format:'%e %B %Y'|trim}{else}{$issue->getYear()|escape}{/if})
      {if $article->getPubId('doi')} <a href="https://doi.org/{$article->getPubId('doi')|escape}">https://doi.org/{$article->getPubId('doi')}</a>{else}{translate key="plugins.citationFormats.apa.retrieved" retrievedDate=$smarty.now|date_format:$dateFormatLong url=$articleUrl}{/if}
    </div>
  </div>
</div>

<div id="vancouver" class="citation_format" style="display: none">
  <div style="width: 100%;">
    <div id="citation" style="background-color:#eee; padding:10px;"><span style="font-weight: bold;">How to cite</span> (Vancouver):
    {assign var=authors value=$article->getAuthors()}
    {assign var=authorCount value=$authors|@count}
    {foreach from=$authors item=author name=authors key=i}
      {assign var=firstName value=$author->getFirstName()}
      {$author->getLastName()|escape} {$firstName|escape|truncate:1:"":true}{if $i==$authorCount-2}, &amp; {elseif $i<$authorCount-1}, {/if}
    {/foreach}.

    {$article->getLocalizedTitle()}.
    {$journal->getLocalizedTitle()}{if $issue} [{translate key="rt.captureCite.online"}]. {if $article->getDatePublished()}{$article->getDatePublished()|date_format:'%Y %b'}{elseif $issue->getDatePublished()}{$issue->getDatePublished()|date_format:'%Y %b'}{else}{$issue->getYear()|escape}{/if};
    {$issue->getVolume()|escape}{if $issue->getNumber()}({$issue->getNumber()|escape}){/if}{else}{/if}{if $article->getPages()}:{$article->getPages()}{/if}.
    {if $article->getPubId('doi')} <a href="https://doi.org/{$article->getPubId('doi')|escape}">https://doi.org/{$article->getPubId('doi')}</a>{else}{translate key="plugins.citationFormats.apa.retrieved" retrievedDate=$smarty.now|date_format:$dateFormatLong url=$articleUrl}{/if}
    </div>
  </div>
</div>

<div id="harvard" class="citation_format" style="display: none">
  <div style="width: 100%;">
    <div id="citation" style="background-color:#eee; padding:10px;">
      <span style="font-weight: bold;">How to cite</span> (Harvard):
      {assign var=authors value=$article->getAuthors()}
      {assign var=authorCount value=$authors|@count}
      {foreach from=$authors item=author name=authors key=i}
      	{assign var=firstName value=$author->getFirstName()}
      	{$author->getLastName()|escape}, {$firstName|escape|truncate:1:"":true}.{if $i==$authorCount-2}, &amp; {elseif $i<$authorCount-1}, {/if}
      {/foreach}

      ,{if $article->getDatePublished()}{$article->getDatePublished()|date_format:'%Y'}{elseif $issue->getDatePublished()}{$issue->getDatePublished()|date_format:'%Y'}{else}{$issue->getYear()|escape}{/if}.
      {$article->getLocalizedTitle()}.
      <em>{$journal->getLocalizedTitle()}{if $issue}, [{translate key="rt.captureCite.online"}] {$issue->getVolume()|escape}</em>{if $issue->getNumber()}({$issue->getNumber()|escape}){/if}{else}</em>{/if}{if $article->getPages()}, pp. {$article->getPages()}{/if}.
      {if $article->getPubId('doi')} <a href="https://doi.org/{$article->getPubId('doi')|escape}">https://doi.org/{$article->getPubId('doi')}</a>{else}{translate key="plugins.citationFormats.apa.retrieved" retrievedDate=$smarty.now|date_format:$dateFormatLong url=$articleUrl}{/if}
    </div>
  </div>
</div>

<div id="mla8" class="citation_format" style="display: none">
  <div style="width: 100%;">
    <div id="citation" style="background-color:#eee; padding:10px;">
      <span style="font-weight: bold;">How to cite</span> (MLA8):
      {assign var=authors value=$article->getAuthors()}
      {assign var=authorCount value=$authors|@count}
      {foreach from=$authors item=author name=authors key=i}
      {if $smarty.foreach.authors.first}{$author->getLastName()|escape}, {$author->getFirstName()|escape}{else}{$author->getFullName()|escape}{/if}{if $i==$authorCount-2}, & {elseif $i lt $authorCount-1}, {else}.{/if}
      {/foreach}

      "{$article->getLocalizedTitle()|strip_unsafe_html}." <em>{$journal->getLocalizedTitle()|escape}</em> [{translate key="rt.captureCite.online"}],{if $issue} {$issue->getVolume()|escape}{/if}{if $issue && $issue->getNumber()}.{$issue->getNumber()}{/if}{if $issue} ({$issue->getYear()}){/if}: {if $article->getPages()}{$article->getPages()}.{else}{translate key="plugins.citationFormats.mla.noPages"}{/if} {translate key="rt.captureCite.web"}. {$smarty.now|date_format:'%e %b. %Y'}
      , {if $article->getPubId('doi')} <a href="https://doi.org/{$article->getPubId('doi')|escape}">https://doi.org/{$article->getPubId('doi')}</a>{else}{translate key="plugins.citationFormats.apa.retrieved" retrievedDate=$smarty.now|date_format:$dateFormatLong url=$articleUrl}{/if}
    </div>
  </div>
</div>

<div id="bibtex" class="citation_format" style="display: none">
  <div style="width: 100%;">
    <div id="citation" style="background-color:#eee; padding:10px;"><p style="font-weight: bold;">BibTex Citation Data :</p>
    {literal}
    <pre style="font-size: 1.5em; white-space: pre-wrap; white-space: -moz-pre-wrap !important; white-space: -pre-wrap; white-space: -o-pre-wrap; word-wrap: break-word;">@article{{/literal}{$journal->getLocalizedInitials()|bibtex_escape}{$articleId|bibtex_escape}{literal},
    	author = {{/literal}{assign var=authors value=$article->getAuthors()}{foreach from=$authors item=author name=authors key=i}{assign var=firstName value=$author->getFirstName()}{assign var=authorCount value=$authors|@count}{$firstName|bibtex_escape} {$author->getLastName()|bibtex_escape}{if $i<$authorCount-1} {translate key="common.and"} {/if}{/foreach}{literal}},
    	title = {{/literal}{$article->getLocalizedTitle()|strip_tags|bibtex_escape}{literal}},
    	journal = {{/literal}{$journal->getLocalizedTitle()|bibtex_escape}{literal}},
    {/literal}{if $issue}{literal}	volume = {{/literal}{$issue->getVolume()|bibtex_escape}{literal}},
    	number = {{/literal}{$issue->getNumber()|bibtex_escape}{literal}},{/literal}{/if}{literal}
    	year = {{/literal}{if $article->getDatePublished()}{$article->getDatePublished()|date_format:'%Y'}{elseif $issue->getDatePublished()}{$issue->getDatePublished()|date_format:'%Y'}{else}{$issue->getYear()|escape}{/if}{literal}},
    	keywords = {{/literal}{$article->getLocalizedSubject()|bibtex_escape}{literal}},
    	abstract = {{/literal}{$article->getLocalizedAbstract()|strip_tags:false|bibtex_escape}{literal}},
    {/literal}{assign var=onlineIssn value=$journal->getSetting('onlineIssn')}
    {assign var=issn value=$journal->getSetting('issn')}{if $issn}{literal}	issn = {{/literal}{$issn|bibtex_escape}{literal}},{/literal}
    {elseif $onlineIssn}{literal}	issn = {{/literal}{$onlineIssn|bibtex_escape}{literal}},{/literal}{/if}
    {if $article->getPages()}{if $article->getStartingPage()}	pages = {literal}{{/literal}{$article->getStartingPage()}{if $article->getEndingPage()}--{$article->getEndingPage()}{/if}{literal}}{/literal},{/if}{/if}
    {if $article->getPubId('doi')}	doi = {ldelim}{$article->getPubId('doi')|escape}{rdelim},
    {/if}
    	url = {ldelim}{url|bibtex_escape page="article" op="view" path=$article->getBestArticleId()}{rdelim}
    {rdelim}
    </pre>
    {/literal}
    </div>
  </div>
</div>

<div id="refworks" class="citation_format" style="display: none">
  <div style="width: 100%;">
    <div id="citation" style="background-color:#eee; padding:10px;"><p style="font-weight: bold;">Refworks Citation Data :</p>
    {literal}@article{{{/literal}{$journal->getLocalizedInitials()|escape}{literal}}{{/literal}{$articleId|escape}{literal}},
    author = {{/literal}{assign var=authors value=$article->getAuthors()}{foreach from=$authors item=author name=authors key=i}{$author->getLastName()|escape}, {assign var=firstName value=$author->getFirstName()}{assign var=authorCount value=$authors|@count}{$firstName|escape|truncate:1:"":true}.{if $i<$authorCount-1}, {/if}{/foreach}{literal}},
    title = {{/literal}{$article->getLocalizedTitle()|strip_unsafe_html}{literal}},
    journal = {{/literal}{$journal->getLocalizedTitle()|escape}{literal}},
    {/literal}{if $issue}{literal}	volume = {{/literal}{$issue->getVolume()|escape}{literal}},
    number = {{/literal}{$issue->getNumber()|escape}{literal}},{/literal}{/if}{literal}
    year = {{/literal}{if $article->getDatePublished()}{$article->getDatePublished()|date_format:'%Y'}{elseif $issue->getDatePublished()}{$issue->getDatePublished()|date_format:'%Y'}{else}{$issue->getYear()|escape}{/if}{literal}},
    {/literal}{assign var=issn value=$journal->getSetting('issn')|escape}{if $issn}{literal}	issn = {{/literal}{$issn|escape}{literal}},{/literal}{/if}
    {if $article->getPubId('doi')}	doi = {ldelim}{$article->getPubId('doi')|escape}{rdelim},
    {/if}
    {literal}	url = {{/literal}{$articleUrl}{literal}}
    }{/literal}
    </div>
  </div>
</div>

<div class="container" id="citation" style="margin-top: 5px;">
    <strong>Citation Format</strong>:
    <select id="select_citation" class="form-control" style="display: inline-block; width: max-content;padding: 6px;">
      <option title="APA Citation Style" value="apa">APA</option>
      <option title="Chicago / Turabian Citation Style" value="chicago">Chicago / Turabian</option>
      <option title="Harvard Citation Style" value="harvard">Harvard</option>
      <option title="IEEE Citation Style" value="ieee" selected>IEEE</option>
      <option title="MLA v8 Citation Style" value="mla8">MLA v8</option>
      <option title="Vancouver Citation Style" value="vancouver">Vancouver</option>
      <option title="BibTex Citation Data" value="bibtex">BibTex</option>
      <option title="RefWorks Citation Data" value="refworks">RefWorks</option>
    </select>
    <select id="download_citation" class="form-control" style="display: inline-block; width: max-content;padding: 6px;">
      <option value="">Download Citation</button></option>
      <option title="Download EndNote for Macintosh & Windows" value="{url page="rt" op="captureCite" path=$articleId|to_array:$galleyId}/EndNoteCitationPlugin">EndNote</option>
      <option title="Download ProCite (RIS format) for Macintosh & Windows" value="{url page="rt" op="captureCite" path=$articleId|to_array:$galleyId}/ProCiteCitationPlugin">ProCite</option>
      <option title="Download Reference Manager (RIS format) for Windows" value="{url page="rt" op="captureCite" path=$articleId|to_array:$galleyId}/RefManCitationPlugin">Reference Manager</option>
    </select>
</div>

{call_hook name="Templates::Article::MoreInfo"}

{include file="article/comments.tpl"}

{include file="article/footer.tpl"}
