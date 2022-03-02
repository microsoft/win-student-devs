#!/bin/bash

feed="feed.xml"
website_title="30 Days of PWA"
website_link="https://aka.ms/learn-PWA/30Days-blog"
description="For 30 days, we publish articles that aim to introduce developers to Progressive Web App. We have content that covers 0-level to 200-level topics. Each post takes 5-10 minutes to read and is followed by a sample snippet or exercise."

urlencode() {
  local length="${#1}"
  for (( i = 0; i < length; i++ )); do
    local c="${1:i:1}"
    case $c in
      [a-zA-Z0-9.~_+-/]) printf "$c" ;;
      *) printf "$c" | xxd -p -c1 | while read x; do printf "%%%s" "$x"; done ;;
    esac
  done
}

newest_files=$( \
  git ls-files -z '*.md' | \
  xargs -0 -n1 -I{} -- git log -1 --format="%at {}" {} | \
  sort -r | \
  head -n10 | \
  cut -d " " -f2-)

items=""
for file in ${newest_files[@]}; do
  echo $file
  title=$(grep "." $file | head -n1)
  encode=$(urlencode "${file::-3}")
  link="$website_link/#/$encode"
  html=$(pandoc -f markdown -t html $file)
  date=$(git log -1 --format="%aD" -- $file)
  item="
  <item>
    <title><![CDATA[${title:2}]]></title>
    <link>$link</link>
    <guid isPermaLink=\"false\">$link</guid>
    <description><![CDATA[$html]]></description>
    <pubDate>$date</pubDate>
  </item>
  "
  items="$items $item"
done

rss_content="<rss xmlns:atom=\"http://www.w3.org/2005/Atom\" version=\"2.0\">
<channel>
  <title>$website_title</title>
  <atom:link href=\"$website_link/$feed\" rel=\"self\" type=\"application/rss+xml\" />
  <link>$website_link</link>
  <description>$description</description>
  $items
</channel>
</rss>"

echo "$rss_content" > $feed