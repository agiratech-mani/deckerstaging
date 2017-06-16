using System;
using System.Collections.Generic;
using System.Web;
using System.IO;
using System.Collections;

namespace HDFVR
{
    public partial class SaveToDB : System.Web.UI.Page
    {
        
        protected void Page_Load(object sender, EventArgs e)
        {

			string streamName = this.Request.Params["streamName"];         
			string streamDuration = this.Request.Params["streamDuration"];
			string userId = this.Request.Params["userId"];
			string recorderId = this.Request.Params["recorderId"];
			string audioCodec = this.Request.Params["audioCodec"];
			string videoCodec = this.Request.Params["videoCodec"];
			string fileType = this.Request.Params["fileType"];
			string payload = this.Request.Params["payload"];
			string cameraName = this.Request.Params["cameraName"];
			string microphoneName = this.Request.Params["microphoneName"];
			string httpReferer = this.Request.Params["httpReferer"];

			string response = string.Empty;
			response = "save=ok";
			Response.Write(response);
        }
    }
}