window.addEventListener("message", function(event) {
    if (event.data.action === "openLink") {
        window.invokeNative("openUrl", event.data.url);
    }
});