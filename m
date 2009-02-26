From: Denis Romanenko <ash@sevsky.net>
Subject: Re: Kernel problem
Date: Thu, 26 Feb 2009 13:24:55 +0200
Message-ID: <1FD907E1-25F5-4E3E-B58F-5596C2144A2E@sevsky.net>
References: <20090226105616.GA5754@ff.dom.local>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: multipart/signed; boundary=Apple-Mail-18--357742140; micalg=sha1; protocol="application/pkcs7-signature"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sevsky.net ([193.138.84.248]:46115 "EHLO mail.sevsky.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753990AbZBZLY6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 06:24:58 -0500
Received: from [172.27.136.145] (office.supersky.ua [10.10.10.1])
	by mail.sevsky.net (Postfix) with ESMTP id 82DD874B67
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 13:24:55 +0200 (EET)
In-Reply-To: <20090226105616.GA5754@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail-18--357742140
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit




> On 26-02-2009 10:39, Herbert Xu wrote:
>> Denis Romanenko <ash@sevsky.net> wrote:
>>> I have high loaded router - about 1.2 Gbps
>>>
>>> after reboot on new kernel - 2.6.27.17 i have messages in dmesg
>>>
>>> WARNING: at kernel/softirq.c:136 local_bh_enable+0x36/0xab()
>>
>> So somebody disabled the IRQs on us, the question is who?
>
> netconsole. It's a known issue, btw.
>

hmm - for stabibility can i disable netconsole ? Or this bug is not  
give my resutlts (reboot of router after 1-2 weeks of work )?

> Cheers,
> Jarek P.


--Apple-Mail-18--357742140
Content-Disposition: attachment;
	filename=smime.p7s
Content-Type: application/pkcs7-signature;
	name=smime.p7s
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIFJDCCBSAw
ggQIoAMCAQICCgqttb4AAgAM0PYwDQYJKoZIhvcNAQEFBQAwbzEaMBgGA1UEChMRV2ViTW9uZXkg
VHJhbnNmZXIxJjAkBgNVBAsTHVdlYk1vbmV5IENlcnRpZmljYXRpb24gQ2VudGVyMSkwJwYDVQQD
EyBXZWJNb25leSBUcmFuc2ZlciBSb290IEF1dGhvcml0eTAeFw0wODA3MTMxOTA0MDFaFw0wOTA3
MTMxOTE0MDFaMIGBMR0wGwYJKoZIhvcNAQkBFg5hc2hAc2V2c2t5Lm5ldDEaMBgGA1UEChMRV2Vi
TW9uZXkgVHJhbnNmZXIxJjAkBgNVBAsTHVdlYk1vbmV5IENlcnRpZmljYXRpb24gQ2VudGVyMRww
GgYDVQQDExNXTSBpZDogMTA0MzE1MDIwMjQ4MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
AQEAufAv5XtWB9OCZo0iHsfDnQF2zjqceI0b8d9xrnLlTJ2SGshNgYEE8sGbdJZGeX3eclKvBrTD
sWTS1EvJNlZAHUeQv0piteRrR9cHCGXtn55yt5iNsozD6UiAmUQP5gkgtyxBHCmj0NiEGl7DKa9M
MCeyn0kJdW4yOGLOEmGh+WjhQf1QBuTNxVdJLTkYRRp2mEgqbJYJE7l/ImzSmAQBW34SqJpecJsw
xmts9AgRZmg1g9Db6SFYKr+2GYldoRGVzBS8tzw33aapr+Hbv0E34okTKuwT6Ji5HBFKZJio82Mp
2hQdffJ/6NKWyUlp/Fms37trCR8iP5LDLLVvc/hiJQIDAQABo4IBqTCCAaUwHQYDVR0OBBYEFA8Y
oDdt1XjIWWBpMM0Oo4gP7/GfMIGoBgNVHSMEgaAwgZ2AFMudflF+CCDE9XCUoc5SxwVNPzPzoXOk
cTBvMRowGAYDVQQKExFXZWJNb25leSBUcmFuc2ZlcjEmMCQGA1UECxMdV2ViTW9uZXkgQ2VydGlm
aWNhdGlvbiBDZW50ZXIxKTAnBgNVBAMTIFdlYk1vbmV5IFRyYW5zZmVyIFJvb3QgQXV0aG9yaXR5
ghA0dTpSwINwskPtDD7TKrJGMFwGA1UdHwRVMFMwUaBPoE2GS2h0dHA6Ly93d3cud21jZXJ0LmNv
bS9DZXJ0RW5yb2xsL1dlYk1vbmV5JTIwVHJhbnNmZXIlMjBSb290JTIwQXV0aG9yaXR5LmNybDB7
BggrBgEFBQcBAQRvMG0wawYIKwYBBQUHMAKGX2h0dHA6Ly93d3cud21jZXJ0LmNvbS9DZXJ0RW5y
b2xsL2NlcnQud2VibW9uZXkucnVfV2ViTW9uZXklMjBUcmFuc2ZlciUyMFJvb3QlMjBBdXRob3Jp
dHkoMikuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQACg2Cpjiz0xIBoULMPHtbPC5VJBU0NvDKqjkxa
bajsGAAEuofGtTrOT3MUxF8j1bYeXWeHoUNA1z1U0bN2f0gKmQHOLxfEiwOHMp0WHoc0hQjiXJX/
jCngzEDBVfggejOBT5Qp09HxwuwAXMb/ogyd1ssPd++Lh//zumJqDNVpzC84fFtd+x0jsz+Z8RWJ
hF7vzd/sTjJl4mNUYbIx1TUINY8559AeO31LhN8s2IMMErUx8olPbPxjicBkSleE/8dq72nrNmWh
wNNIVokF5KbP/xW8p3XVN2Z7nhuvlrx+LRZiiw3p7/297DZgeLV2dwu3NCzAmhWuqyV5/XqOuTKn
MYIDJTCCAyECAQEwfTBvMRowGAYDVQQKExFXZWJNb25leSBUcmFuc2ZlcjEmMCQGA1UECxMdV2Vi
TW9uZXkgQ2VydGlmaWNhdGlvbiBDZW50ZXIxKTAnBgNVBAMTIFdlYk1vbmV5IFRyYW5zZmVyIFJv
b3QgQXV0aG9yaXR5AgoKrbW+AAIADND2MAkGBSsOAwIaBQCgggF9MBgGCSqGSIb3DQEJAzELBgkq
hkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTA5MDIyNjExMjQ1NVowIwYJKoZIhvcNAQkEMRYEFIee
A3yY9gUccoVRu2qttj5OKrp6MIGMBgkrBgEEAYI3EAQxfzB9MG8xGjAYBgNVBAoTEVdlYk1vbmV5
IFRyYW5zZmVyMSYwJAYDVQQLEx1XZWJNb25leSBDZXJ0aWZpY2F0aW9uIENlbnRlcjEpMCcGA1UE
AxMgV2ViTW9uZXkgVHJhbnNmZXIgUm9vdCBBdXRob3JpdHkCCgqttb4AAgAM0PYwgY4GCyqGSIb3
DQEJEAILMX+gfTBvMRowGAYDVQQKExFXZWJNb25leSBUcmFuc2ZlcjEmMCQGA1UECxMdV2ViTW9u
ZXkgQ2VydGlmaWNhdGlvbiBDZW50ZXIxKTAnBgNVBAMTIFdlYk1vbmV5IFRyYW5zZmVyIFJvb3Qg
QXV0aG9yaXR5AgoKrbW+AAIADND2MA0GCSqGSIb3DQEBAQUABIIBABoMAspd4NoW3mbGX0ivsUas
0wD8NtZuHAJwZCnjokZ4yGfPsTg7vvOovzPJXULOureeWlnokbIwBNiRYNL6mWPqi1aHTfvOhg0O
eB+xnW7R9WSHQdPTXZQDg0q7l7HoKrljfP4ogKv9vTzWw92aid9ds7LV5vqwkFsgo6jDEXmLxBQK
tFfEedOaw7kGsQXjVXo5MRGUd7U3lB2bXsTx6bEKMJn69hfYVozl939460DqAe1WeZspPriC0Tk8
orEhYwDw9QdC+rBoHJ94SmhJF+tVx13bRLC3MQpU+x+jqYI62bkaMf/sqOLxLcd5mboT8tlCog6m
CPsldE9Szm/GfhUAAAAAAAA=

--Apple-Mail-18--357742140--
