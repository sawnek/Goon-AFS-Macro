#Requires Autohotkey v2.0

CheckForUpdates() {
    global repoOwner, repoName

    url := "https://api.github.com/repos/" repoOwner "/" repoName "/releases/latest"
    http := ComObject("MSXML2.XMLHTTP")
    http.Open("GET", url, false)
    http.Send()

    if (http.Status != 200) {
        UpdateText("Failed to check for updates.")
        UpdateText("Current Version: " Version)
        return
    }

    response := http.responseText
    latestVersion := JSON.parse(response).Get("tag_name")

    ; Compare versions using VerCompare
    comparison := VerCompare(Version, latestVersion)

    if (comparison < 0) {
        UpdateText("Update available! " Version " → " latestVersion)
    } else if (comparison > 0) {
        UpdateText("Your version is newer than the latest published version (" latestVersion ")")
    } else {
        UpdateText("You are already using the latest version (" Version ")")
    }
}