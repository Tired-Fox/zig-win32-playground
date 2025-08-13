# https://github.com/iKineticate/win-toast-notify
# https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/schema-root
# https://learn.microsoft.com/en-us/previous-versions/windows/apps/hh761494(v=win.10)

param (
    [Parameter(Mandatory=$true, HelpMessage="Enter the progress text")]
    [string]$Text,

    [Parameter(Mandatory=$true, HelpMessage="Enter the progress status")]
    [string]$Status
)

Invoke-Command -ScriptBlock {
    $Dictionary = [System.Collections.Generic.Dictionary[String, String]]::New()
    $Dictionary.Add('progressValue', 1)
    $Dictionary.Add('progressValueString', $Text)
    $Dictionary.Add('progressStatus', $Status)
    $NotificationData = [Windows.UI.Notifications.NotificationData]::New($Dictionary)
    $NotificationData.SequenceNumber = 2
    $AppId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
    $Notifier = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]::CreateToastNotifier($AppId)
    $Notifier.Update($NotificationData, 'zig-test-notif')
}
