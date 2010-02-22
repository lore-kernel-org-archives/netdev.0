From: Lars Eggert <lars.eggert@nokia.com>
Subject: Re: [net-next PATCH v4 1/3] net: TCP thin-stream detection
Date: Mon, 22 Feb 2010 08:41:32 +0200
Message-ID: <FB5F656F-091A-4FB5-9586-15C6CB263D05@nokia.com>
References: <20100221102102.GB1311@ucw.cz> 	<D40945A6-301D-485D-BB8C-826D2EB68DA4@nets.rwth-aachen.de> 	<2EC47E8B-BC4C-4DAB-86ED-F702D67F8AD0@nokia.com> <20100221.150311.193707249.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: multipart/signed; boundary=Apple-Mail-5-750883795; protocol="application/pkcs7-signature"; micalg=sha1
Cc: "zimmermann@nets.rwth-aachen.de" <zimmermann@nets.rwth-aachen.de>,
	"pavel@ucw.cz" <pavel@ucw.cz>,
	"apetlund@simula.no" <apetlund@simula.no>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ilpo.jarvinen@helsinki.fi" <ilpo.jarvinen@helsinki.fi>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"Arnd.Hannemann@nets.rwth-aachen.de"
	<Arnd.Hannemann@nets.rwth-aachen.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"william.allen.simpson@gmail.com" <william.allen.simpson@gmail.com>,
	"damian@tvk.rwth-aachen.de" <damian@tvk.rwth-aachen.de>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:19512 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754945Ab0BVGmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 01:42:16 -0500
In-Reply-To: <20100221.150311.193707249.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail-5-750883795
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii

If it's off by default there is no issue.

On 2010-2-22, at 1:03, David Miller wrote:

> From: Lars Eggert <lars.eggert@nokia.com>
> Date: Sun, 21 Feb 2010 22:04:46 +0200
> 
>> Agree with Alexander. It is not at all clear to me that these
>> changes are safe for non-exerimental use in the wider Internet.
> 
> It's off by default and we provide all sorts of experimental
> congestion control algorithms which can cause just as much
> if not more trouble than these thin-stream bits.
> 
> There is no problem integrating these changes.


--Apple-Mail-5-750883795
Content-Disposition: attachment;
	filename=smime.p7s
Content-Type: application/pkcs7-signature;
	name=smime.p7s
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIGbDCCAyUw
ggKOoAMCAQICEAdjk36sXKbnVn15S0/qUp0wDQYJKoZIhvcNAQEFBQAwYjELMAkGA1UEBhMCWkEx
JTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQ
ZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBMB4XDTA5MDYxNTExMjYxNFoXDTEwMDYxNTExMjYx
NFowXDEPMA0GA1UEBBMGRWdnZXJ0MQ0wCwYDVQQqEwRMYXJzMRQwEgYDVQQDEwtMYXJzIEVnZ2Vy
dDEkMCIGCSqGSIb3DQEJARYVbGFycy5lZ2dlcnRAbm9raWEuY29tMIIBIjANBgkqhkiG9w0BAQEF
AAOCAQ8AMIIBCgKCAQEA7mR8A+Pn0/FsUkMX6Pyjw+FL3IFcJk8GaKV5VJ40TMI0Wh8oq20cqA9X
uqnVDW9WztKwH+o+msJenLwWpprbpJm4TImYGbnUJxYyN8gb81aiX1Bw2xCpJ5z3H2+8DsReJLuY
Rdl4bVvaIxLIL4odmfsRwzPyNkOK8LRtfl6OPcaDOlFWzbikULfIVGGu7BqK4lxQSpYwwpZkOMOB
6nnBSfUOtBEmqO+qZG/nL/JxWFV5vxQgg4XHbsMMTxFf6+ji18BD09BUIfDLTuJoCzFmQhrM9vLT
VuRhHWSL20LoafGjXv6mPt3i9IGJHpVb2dMQUgOgRyWHTKiUJVU/rUTdWwIDAQABo14wXDAqBgUr
ZQEEAQQhMB8CAQAwGjAYAgEEBBNMMnVNeWZmQk5VYk5KSmNkWjJzMCAGA1UdEQQZMBeBFWxhcnMu
ZWdnZXJ0QG5va2lhLmNvbTAMBgNVHRMBAf8EAjAAMA0GCSqGSIb3DQEBBQUAA4GBADUx+67n98wt
I1vydB90HeSZP4Y64VCxxb0NxGGFvfc2+JdVKeHJ/xT+l+ygYKsWNwJJprkPi4WZ5G0crkq4VK1H
5drEJIztpSPVfWI05vPidaaGuuuCR+6MvJMtOTEYEvc/6eovBnkrzRf9x5x5EyuJXAWTeuBADg80
QI3vQ1tZMIIDPzCCAqigAwIBAgIBDTANBgkqhkiG9w0BAQUFADCB0TELMAkGA1UEBhMCWkExFTAT
BgNVBAgTDFdlc3Rlcm4gQ2FwZTESMBAGA1UEBxMJQ2FwZSBUb3duMRowGAYDVQQKExFUaGF3dGUg
Q29uc3VsdGluZzEoMCYGA1UECxMfQ2VydGlmaWNhdGlvbiBTZXJ2aWNlcyBEaXZpc2lvbjEkMCIG
A1UEAxMbVGhhd3RlIFBlcnNvbmFsIEZyZWVtYWlsIENBMSswKQYJKoZIhvcNAQkBFhxwZXJzb25h
bC1mcmVlbWFpbEB0aGF3dGUuY29tMB4XDTAzMDcxNzAwMDAwMFoXDTEzMDcxNjIzNTk1OVowYjEL
MAkGA1UEBhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNV
BAMTI1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBMIGfMA0GCSqGSIb3DQEBAQUA
A4GNADCBiQKBgQDEpjxVc1X7TrnKmVoeaMB1BHCd3+n/ox7svc31W/Iadr1/DDph8r9RzgHU5VAK
MNcCY1osiRVwjt3J8CuFWqo/cVbLrzwLB+fxH5E2JCoTzyvV84J3PQO+K/67GD4Hv0CAAmTXp6a7
n2XRxSpUhQ9IBH+nttE8YQRAHmQZcmC3+wIDAQABo4GUMIGRMBIGA1UdEwEB/wQIMAYBAf8CAQAw
QwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybC50aGF3dGUuY29tL1RoYXd0ZVBlcnNvbmFsRnJl
ZW1haWxDQS5jcmwwCwYDVR0PBAQDAgEGMCkGA1UdEQQiMCCkHjAcMRowGAYDVQQDExFQcml2YXRl
TGFiZWwyLTEzODANBgkqhkiG9w0BAQUFAAOBgQBIjNFQg+oLLswNo2asZw9/r6y+whehQ5aUnX9M
Ibj4Nh+qLZ82L8D0HFAgk3A8/a3hYWLD2ToZfoSxmRsAxRoLgnSeJVCUYsfbJ3FXJY3dqZw5jowg
T2Vfldr394fWxghOrvbqNOUQGls1TXfjViF4gtwhGTXeJLHTHUb/XV9lTzGCAxAwggMMAgEBMHYw
YjELMAkGA1UEBhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAq
BgNVBAMTI1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBAhAHY5N+rFym51Z9eUtP
6lKdMAkGBSsOAwIaBQCgggFvMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkF
MQ8XDTEwMDIyMjA2NDEzMlowIwYJKoZIhvcNAQkEMRYEFGdsTv7r2wit8yVg+8AabCzb6WYdMIGF
BgkrBgEEAYI3EAQxeDB2MGIxCzAJBgNVBAYTAlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGlu
ZyAoUHR5KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBD
QQIQB2OTfqxcpudWfXlLT+pSnTCBhwYLKoZIhvcNAQkQAgsxeKB2MGIxCzAJBgNVBAYTAlpBMSUw
IwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAoUHR5KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVy
c29uYWwgRnJlZW1haWwgSXNzdWluZyBDQQIQB2OTfqxcpudWfXlLT+pSnTANBgkqhkiG9w0BAQEF
AASCAQCyuD6zECqjT4CroeVYyrpLk9z7HbY3XjSKzIk/YZ6Z4hbESFxi21VBK5c5RtfPHVYJtmfA
oybfIaeGxJZeUQONubfUEw3LpjgIvW0Oqnr1B/jl8CJ5DNuMMv9bJ8wIUPAf9AltY0Ad3K4t4GzX
U6RDUFhDa4JHb/lLxLrVrF9maiMGUZSicEoyuz++b+XnS1l1OBk7yqAAQq7L7z/TTC+AtVPfbydB
0YQvAQOJWDTpl/obV2he+488P6i0Lh+IzHmXKkPum9+UhJ5NiBjRlXM6p/FNLuDQLwxYB4NCaSVU
NHguXS4Hdx22MZclj1w4Ty9p9NbG2T11Th6UV5ejEI1+AAAAAAAA

--Apple-Mail-5-750883795--
