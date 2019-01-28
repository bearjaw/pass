# pass

Welcome!

This script creates a SHA1 checksum of your password and then takes the first 5
characters and asks the haveibeenpwned api to return all the checksums beginning
with those first 5 characters.
These checksums are then compared to the rest of your password's checksum to identify
a compromised password.

SHA1 generation & comparison are be done locally. Only the first 5 characters of
the checksum of your are transmitted to haveibeenpwned.

Erase your terminal client's history when you're done ( `history -c` or equivalent )

## Build & run

Just open `pass.xcodeproj`  and go to Product>Run or [Command] + [R]  
