# Adding FlutterFire to PATH

To use `flutterfire` command directly, you need to add the pub cache bin directory to your PATH.

## Option 1: Add to PATH Permanently (Recommended)

1. Press `Win + X` and select "System"
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Under "User variables", find and select "Path", then click "Edit"
5. Click "New" and add: `C:\Users\njnna\AppData\Local\Pub\Cache\bin`
6. Click "OK" on all dialogs
7. **Restart your terminal/IDE** for changes to take effect

## Option 2: Use Alternative Command

Instead of `flutterfire`, you can use:

```powershell
dart pub global run flutterfire_cli:flutterfire configure --project=qalby2heal --platforms=android,ios,web
```

## Option 3: Run the PowerShell Script

I've created a script `run_flutterfire.ps1` that sets up the PATH and runs the command. You can run it, but you'll still need to answer the interactive prompts.

