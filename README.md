# `sync.sh`

`sync.sh` is a simple wrapper around `rsync` and `diff` that's useful for syncing files, primarily text files, between computers. While `rsync` is great by itself, it doesn't show you *what* is different between files on a line-by-line basis. Knowing exactly what changed can be very useful when you're syncing files hours, days, or even weeks after the last sync. It gives you confidence that you're not overwriting things you shouldn't and reminds you what has changed. It's a great solution for people who don't or can't use a cloud solution to keep files synchronized.

`sync.sh` assumes that the source and destination are available via the local file system, but that can include things such as SFTP mounts. It's set up to work with macOS by default, but all of the non-portable pieces are defined in upfront functions that can be easily modified to the desired platform and preferences.

## Example Usage

```sh
# Do a dry run of rsync between the source and destination. These can be files
# or directories.
sync.sh --source remote/directory/app --destination local/directory/app

# `diff` the changes between the source and destination.
sync.sh --diff --source remote/directory/app --destination local/directory/app

# Open the source and destination for manual checking. This is useful if, for
# example, you're on macOS and want to quickly use Spotlight to view binary
# files, like images.
sync.sh --open --source remote/directory/app --destination local/directory/app

# Finally, after checking everything, commit the changes.
sync.sh --commit --source remote/directory/app --destination local/directory/app

# Optionally, the files in the destination that aren't in the source can be
# deleted with the --delete switch.
sync.sh --delete --commit --source remote/directory/app --destination local/directory/app
```

## License

This work is available under a BSD license as described in the LICENSE.txt file.
