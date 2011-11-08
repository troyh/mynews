#!/bin/bash
xmlstarbin=xml
bindir="."
datadir=~/.mynews
pagesdir=$datadir/pages
feedsdir=$datadir/feeds
headersdir=$datadir/headers
contentdir=$datadir/content

rm -f links.tab;

for dir in $datadir $pagesdir $feedsdir $headersdir $contentdir; do
	if [ ! -d $dir ]; then
		mkdir $dir;
	fi
done

# Iterate all RSS feeds (for testing, just the feeds under the Mac folder)
for feed in $($xmlstarbin sel -t -m '/opml/body/outline[@title=&quot;Mac&quot;]/outline' -v @xmlUrl -n /Users/troy/Downloads/google-reader-subscriptions.xml); do

	echo Feed: $feed
	echo "----------------------"
	# Retrieve RSS feed
	feedxml=$feedsdir/$(shasum <<< "$feed" | awk '{print $1}');
	if [ ! -f $feedxml ]; then
		curl --silent -o $feedxml $feed;
	fi

	# Iterate each post in the feed 
	for link in $($xmlstarbin sel -t -m '/rss/channel/item' -v link -n  $feedxml); do 

		echo -n Link: $link
		# Get linked URL
		sha=$(shasum <<< "$link" | awk '{print $1}');
		xhtmlpage=$pagesdir/$sha.xhtml;
		headerfile=$headersdir/$sha;
		echo "--> $xhtmlpage"
		
		if [ ! -f $xhtmlpage -o ! -f $headerfile ]; then
			# Convert it to XHTML (and remove attributes from HTML tag)
			htmlpage=$pagesdir/$sha.html;
			curl --silent --dump-header $headerfile --location $link --write-out "%{url_effective}\n" > $htmlpage;

			# Move the url_effective line from the output HTML file to the header file
			echo "url_effective: $(tail -n 1 $htmlpage)" >> $headerfile;
			sed -i .bak -e '$d' $htmlpage; # Remove the last line (the url_effective from curl)

			# Convert the HTML to XHTML so it can be read by xmlstarlet
			xmllint --format --html --xmlout --noent --nsclean $htmlpage |
			sed -e 's/<html [^>]*>/<html>/'  > $xhtmlpage;
			rm -f $htmlpage $htmlpage.bak; # Remove HTML and its backup file (we only want the XHTML version)
			
		fi

		# Get the website for the link (for now, just the domain but that won't work or blogger/wordpress/etc sites)
		site=$(grep -e ^url_effective: $headerfile | sed -e 's/^.*http:/http:/' | php -R '$url=parse_url($argn);print $url[host];');
		if [ ! -d "$contentdir/$site/" ]; then
			mkdir "$contentdir/$site/";
		fi
	
		# Move the XHTML page to the directory for its site
		$bindir/pagecontent "$xhtmlpage" > "$contentdir/$site/$sha";

		# # Get hostdomain from header file
		# hostdomain=$(grep -e ^url_effective: $headerfile | sed -e 's/^.*http:/http:/' | sed -e 's|^\(http://[^/]*/\).*$|\1|');

		# # Get the XPath for this site that will extract just the relevant text on the page
		# xpath=;
		# while IFS="	" read site expr; do 
		# 	if [[ $hostdomain =~ "$site" ]]; then
		# 		xpath=$expr;
		# 		break;
		# 	fi
		# done < ~/.mynews/sites;
		# 
		# if [ -z "$xpath" ]; then
		# 	echo "No XPath for $hostdomain ($sha)";
		# else
		# 
		# 	# Get just the text of the article and then all the A tags in it
		# 	snippet=$($xmlstarbin sel -t -m "$xpath" -c . $xhtmlpage);
		# 
		# 	echo "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?><article>$snippet</article>" |
		# 	$xmlstarbin sel -t -m //a -v @href -n |
		# 	grep -v -e "^mailto:" |
		# 	grep -e "^http://" |
		# 	while read url; do
		# 		
		# 		if [[ ! $url =~ "$hostdomain" ]]; then
		# 			# Output each URL-linked URL pair
		# 			echo "$link	$url";
		# 		fi
		# 
		# 	done >> links.tab;
		# 
		# fi

	done
	
done

# Sort by linked URL
sort -u  links.tab | cut -f 2 | sort | uniq -c | sort -n
