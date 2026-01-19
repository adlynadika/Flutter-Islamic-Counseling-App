# PowerShell script to run flutterfire with proper PATH
$env:Path += ";C:\Users\njnna\flutter\bin;C:\Users\njnna\AppData\Local\Pub\Cache\bin"
flutterfire configure --project=qalby2heal --platforms=android,ios,web

