#!/usr/bin/env bash

set oeo pipefail

r_ver=$(Rscript --version 2>&1 | sed -ne 's/^.*version \([^ ]*\).*/\1/p')

cat <<EOT
{
  "R": {
    "Version": "$r_ver",
    "Repositories": [
      {
        "Name": "CRAN",
        "URL": "http://cran.r-project.org"
      }
    ]
  },
  "Packages": {
EOT

prev=""
for pkg in /usr/local/share/renv/cache/v5/R-4.2/x86_64-pc-linux-gnu/* 
do 
	pkg_name=$(basename "$pkg")  
	pkg_ver=$(ls "$pkg" | tail -n 1) 
	pkg_hash=$(ls "$pkg/$pkg_ver" | tail -n 1) 
	if [ "$prev" != "" ] 
	then
		echo "$prev,"
	fi
	prev=$(cat <<EOT
    "$pkg_name": {
      "Package": "$pkg_name",
      "Version": "$pkg_ver",
      "Source": "Repository",
      "Repository": "CRAN",
      "Hash": "$pkg_hash"
    }
EOT
)
done
echo "$prev" 

cat <<EOT
  }
}
EOT
