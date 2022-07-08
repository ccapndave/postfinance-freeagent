# postfinance-freeagent

This is a small Haskell app to convert transaction exports from PostFinance's eFinance portal (https://www.postfinance.ch/en/private/products/digital-banking/e-finance.html) into a format that can be imported into FreeAgent's (https://www.freeagent.com/) banking page.

It was also a grand opportunity for me to play around with Haskell :)

* Run `stack run -- -f <postfinance_file>`

# Installing

* Run `stack install` to install a global `postfinance-freeagent` file.

# Notes

 - As of the latest Postfinance update, its necessary to remove any `=` from header rows (apart from the real header) and it might be necessary to manually convert the file from `UTF-8 with BOM` to `UTF-8`