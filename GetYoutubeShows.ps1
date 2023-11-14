# This script will download the latest videos only from a channel.  
# The first time you run it it will compile a file (archive.txt) that will itemize all videos in that channel.
# The next time you run it, any videos added since then will download.
# This also deletes videos older than 3 days (configurable)

$showList = @('@JimmyKimmelLive', '@ColbertLateShow','@TheDailyShow','@LateNightSeth','@LastWeekTonight')
$NumberOfDaysOldToKeep = 3

#Delete Shows Older than 48 hours 
$limit = (Get-Date).AddDays(-$NumberOfDaysOldToKeep)  
$path = ".\Talk Shows"
# Delete files older than the $limit.  Comment the line below if you want to keep the downloads forever
Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
# Delete any empty directories left behind after deleting the old files.
# Get-ChildItem -Path $path -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Remove-Item -Force -Recurse

#check for yt-dlp updates
.\yt-dlp.exe -U

If (Test-Path .\archive.txt) {
    Write-Host "Archive exists - downloading dif"
        foreach ($i in $showList)
        {
            # Download any files not on the list
            .\yt-dlp.exe `
            --no-abort-on-error `
            -r6M `
            --mtime `
            --convert-thumbnails jpg `
            --write-thumbnail `
            --merge-output-format mp4 `
            --write-subs `
            --sub-format srt `
            --write-info-json `
            --write-description `
            --embed-chapters `
            --embed-metadata  `
             archive.txt "https://www.youtube.com/$i" `
             -o "/Talk Shows/%(uploader)s/%(playlist_index)s - %(title)s [%(id)s].%(ext)s" `
             -o "thumbnail:/Talk Shows/%(uploader)s/%(playlist_index)s - %(title)s [%(id)s]\poster.jpg" 
        }    
} else {
        foreach ($i in $showList)
            {
                #Build the do-not-download list
                .\yt-dlp.exe --force-write-archive --simulate --flat-playlist --download-archive archive.txt "https://www.youtube.com/$i"
            }
}

