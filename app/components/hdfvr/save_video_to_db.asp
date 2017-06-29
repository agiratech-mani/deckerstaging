<%
''Edit avc_settings.php for documentation

Dim streamName
streamName=Request.QueryString("streamName")

Dim streamDuration
streamDuration=Request.QueryString("streamDuration")

Dim userId
userId=Request.QueryString("userId")

Dim recorderId
recorderId=Request.QueryString("recorderId")

Dim audioCodec
recorderId=Request.QueryString("audioCodec")

Dim videoCodec
recorderId=Request.QueryString("videoCodec")

Dim fileType
recorderId=Request.QueryString("fileType")

Dim payload
payload=Request.QueryString("payload")

Dim cameraName
cameraName=Request.QueryString("cameraName")

Dim microphoneName
microphoneName=Request.QueryString("microphoneName")

Dim httpReferer
httpReferer=Request.QueryString("httpReferer")

Response.write("save=ok")
%>