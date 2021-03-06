/**
###################### HDFVR Configuration File ######################
########################### .aspx Version ######################### 
#### See avc_settings.php for explanation of each variable ########
**/
using System;
using System.Collections.Generic;
using System.Web;

namespace HDFVR
{
    public partial class GeneralSettings : System.Web.UI.Page
    {
        private static Dictionary<string, object> configurationData = new Dictionary<string, object>();

        private static void CreateConfig()
        {
            configurationData = new Dictionary<string, object>();

            /** ######################## MANDATORY FIELDS ######################### **/
            configurationData.Add("connectionstring", "rtmp://localhost/hdfvr/_definst_");
            /** ######################### OPTIONAL FIELDS (GENERAL) ############### **/
			configurationData.Add("languagefile", "translations/en.xml");
			configurationData.Add("qualityurl", "");
			configurationData.Add("maxRecordingTime", 120);
			configurationData.Add("userId", "");
			configurationData.Add("outgoingBuffer", 60);
			configurationData.Add("playbackBuffer", 1);
			configurationData.Add("autoPlay", "false");
			configurationData.Add("deleteUnsavedFlv", "false");
			configurationData.Add("hideSaveButton", 0);
			configurationData.Add("onSaveSuccessURL", "");
			configurationData.Add("snapshotSec", 5);
			configurationData.Add("snapshotEnable", "true");
			configurationData.Add("minRecordTime", 5);
			configurationData.Add("backgroundColor", "0xf6f6f6" );
			configurationData.Add("menuColor", "0xe9e9e9");
			configurationData.Add("radiusCorner", 4);
			configurationData.Add("showFps", "false");
			configurationData.Add("recordAgain", "true");
			configurationData.Add("useUserId", "false");
			configurationData.Add("streamPrefix", "videoStream_");
			configurationData.Add("streamName", "");
			configurationData.Add("disableAudio", "false");
			configurationData.Add("chmodStreams", "");
			configurationData.Add("padding", 2);
			configurationData.Add("countdownTimer", "false");
			configurationData.Add("overlayPath", "fullStar.png");
			configurationData.Add("overlayPosition", "tr");
			configurationData.Add("loopbackMic", "false");
			configurationData.Add("showMenu", "true");
			configurationData.Add("showTimer", "true");
			configurationData.Add("showSoundBar", "true");
			configurationData.Add("flipImageHorizontally", "false");
			configurationData.Add("hidePlayButton", 0);
			configurationData.Add("enablePauseWhileRecording", 0);
			configurationData.Add("enableBlinkingRec", 1);
			configurationData.Add("microphoneGain", 50);
			configurationData.Add("allowAudioOnlyRecording", 1);
			configurationData.Add("enableFFMPEGConverting", 0);
			configurationData.Add("ffmpegCommand", "ffmpeg -i [THE_INPUT_FLV_FILE] -c:v libx264 [THE_OUTPUT_MP4_FILE]");
			configurationData.Add("autoSave", 1);
			configurationData.Add("payload", "");
			configurationData.Add("normalColor", "0x334455");
			configurationData.Add("overColor", "0x556677");
			configurationData.Add("skipInitialScreen", 0);
			configurationData.Add("hideDeviceSettingsButtons", 0);
			configurationData.Add("proxyType", "none");
			
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            CreateConfig();
            Response.Write("a=b");
            foreach (KeyValuePair<string, object> configOption in configurationData)
            {
                Response.Write("&" + configOption.Key + "=" + HttpUtility.UrlEncode(configOption.Value.ToString()));
            }
        }
    }
}