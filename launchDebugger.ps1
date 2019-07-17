$containerName ="test.debug"

If ((docker image list | select-string -pattern 'debugger').length -eq 0) {
	docker build -f Dockerfile.debugger -t debugger:1.0 .
}
If ((docker ps -a -f name=$containerName).length -gt 0){
	docker rm $containerName -f
}


$pkgPathVol = $env:GOPATH + "\pkg\:/go/pkg/"
Write-Host($pkgPathVol)

$path = Get-Location
$workspaceVol = $path.tostring() + "\:/debug/"
Write-Host($workspaceVol)

$cmd = 'docker run -d -p 3000:3000 -p 40000:40000 --name="test.debug" --security-opt="apparmor=unconfined" --cap-add=SYS_PTRACE -v ' + $workspaceVol + ' -v ' + $pkgPathVol + ' debugger:1.0'
Write-Host($cmd)
powershell $cmd

while ($true)
{
	$s = docker logs test.debug 
	Write-Host($s)
	if ($s.length -gt 0)
	{
		Write-Host("dlv started from log : $s")
		break
	}
	Write-Host("dlv not start yet,waiting...")
	Start-Sleep -Seconds 2
}

#docker run -t -p 3000:3000 -p 40000:40000 --name="test.debug" --security-opt="apparmor=unconfined" --cap-add=SYS_PTRACE -v "$workspaceVol"  -v "$pkgPathVol"  debugger:1.0
#Start-Process Invoke-command -scriptblock {hostname}
#docker exec test.debug dlv debug /debug/main.go --headless=true --listen=:40000 --api-version=2doc