# https://github.com/iKineticate/win-toast-notify
# https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/schema-root
# https://learn.microsoft.com/en-us/previous-versions/windows/apps/hh761494(v=win.10)
Invoke-Command -ScriptBlock {
    $xml = '
        <toast>
            <visual>
                <binding template="ToastGeneric">
                    <text hint-style="title">Hello, world!</text>
                    <text>Text notification</text>
                    <progress
                        title="{progressTitle}"
                        value="{progressValue}"
                        valueStringOverride="{progressValueString}"
                        status="{progressStatus}"/>
                </binding>
            </visual>
        </toast>
    ';

    $XmlDocument = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]::New()
    $XmlDocument.loadXml($xml)
    $AppId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'

    $ToastNotification = [Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime]::New($XmlDocument)
    $ToastNotification.Tag = 'zig-test-notif'
    $Dictionary = [System.Collections.Generic.Dictionary[String, String]]::New()
    $Dictionary.Add('progressTitle', 'Progress')
    $Dictionary.Add('progressValue', 0)
    $Dictionary.Add('progressValueString', '0/120')
    $Dictionary.Add('progressStatus', 'Installing...')
    $ToastNotification.Data = [Windows.UI.Notifications.NotificationData]::New($Dictionary)
    $ToastNotification.Data.SequenceNumber = 1

    $Notifier = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]::CreateToastNotifier($AppId)
    $Notifier.Show($ToastNotification);
}
