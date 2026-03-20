#!/bin/sh
#extract YouTube subscriptions from newpipe.db and convert to grayjay_final.json format

sqlite3 newpipe.db "SELECT url, name FROM subscriptions WHERE url LIKE '%youtube.com%';" \
| awk -F'|' 'BEGIN {
  print "{\"app_version\":\"0.27.5\",\"app_version_int\":999,\"subscriptions\":["
}
{
  url=$1; name=$2;
  gsub(/"/, "\\\"", url);
  gsub(/"/, "\\\"", name);
  if (NR>1) printf ",\n";
  printf "  {\"service_id\":1,\"url\":\"%s\",\"name\":\"%s\"}", url, name;
}
END {
  print "\n]}"
}' > grayjay_final.json
