<%
''See jpg_encoder_download.php for documentation
Dim photoName
photoName = Request.QueryString("name")

Dim recorderId
recorderId = Request.QueryString("recorderId")

Dim strPath
strPath = Server.MapPath("snapshots/")
strPath = strPath & photoName

Dim fileData
fileData = Request.BinaryRead(Request.TotalBytes)

Dim fs,f
Set fs=CreateObject("Scripting.FileSystemObject")
Set f = fs.OpenTextFile(strPath,8,true)
f.Write fileData
f.Close

Response.write("save=ok")
%>