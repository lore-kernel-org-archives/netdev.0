From: Roland Kuhn <rkuhn@e18.physik.tu-muenchen.de>
Subject: Re: [RFC] div64_64 support
Date: Tue, 6 Mar 2007 16:10:08 +0100
Message-ID: <84C47260-4B57-4568-8197-58F438A6F737@e18.physik.tu-muenchen.de>
References: <20070223170527.4ca695b2@freekitty> <20070305155714.3abe1b5e@freekitty> <20070306133404.GA864@one.firstfloor.org> <200703061519.20346.dada1@cosmosbay.com> <20070306144529.GA2004@one.firstfloor.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=pgp-sha1; boundary="Apple-Mail-34--534403482"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jan Engelhardt <jengelh@linux01.gwdg.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030583AbXCFPK0@vger.kernel.org>
In-Reply-To: <20070306144529.GA2004@one.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-34--534403482
Content-Type: multipart/signed; micalg=sha1; boundary=Apple-Mail-33--534403500; protocol="application/pkcs7-signature"


--Apple-Mail-33--534403500
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=US-ASCII;
	delsp=yes;
	format=flowed

Hi Andi!

On 6 Mar 2007, at 15:45, Andi Kleen wrote:

>> <rant>
>> Let me see... You throw code like that and expect someone to actually
>> understand it in one year, and be able to correct a bug ?
>
> To be honest I don't expect any bugs in this function.
>
>> </rant>
>>
>> Please add something, an URL or even better a nice explanation,  
>> per favor...
>
> It's straight out of Hacker's delight which is referenced in the  
> commit
> log.
>
And it's pretty neat, too. Hint: (y+1)**3 = y**3 + 3*y**2 + 3*y + 1.  
The algorithm is exactly the same as for calculating the cubic root  
on paper, digit by digit. I found that algo in the school notebook of  
my grandpa (late 1920ies), a pity that it's not taught anymore...  
pocket calculators _do_ have downsides ;-)

Ciao,
                     Roland

--
TU Muenchen, Physik-Department E18, James-Franck-Str., 85748 Garching
Telefon 089/289-12575; Telefax 089/289-12570
--
CERN office: 892-1-D23 phone: +41 22 7676540 mobile: +41 76 487 4482
--
Any society that would give up a little liberty to gain a little
security will deserve neither and lose both.  - Benjamin Franklin
-----BEGIN GEEK CODE BLOCK-----
Version: 3.12
GS/CS/M/MU d-(++) s:+ a-> C+++ UL++++ P+++ L+++ E(+) W+ !N K- w--- M 
+ !V Y+
PGP++ t+(++) 5 R+ tv-- b+ DI++ e+++>++++ h---- y+++
------END GEEK CODE BLOCK------



--Apple-Mail-33--534403500
Content-Transfer-Encoding: base64
Content-Type: application/pkcs7-signature;
	name=smime.p7s
Content-Disposition: attachment;
	filename=smime.p7s

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIINxTCCBi4w
ggUWoAMCAQICCmEPqkwAAAAAAAMwDQYJKoZIhvcNAQEFBQAwQTESMBAGCgmSJomT8ixkARkWAmNo
MRQwEgYKCZImiZPyLGQBGRYEY2VybjEVMBMGA1UEAxMMQ0VSTiBSb290IENBMB4XDTA2MTAwMzA5
MzYxM1oXDTE2MTAwMzA5NDYxM1owWTESMBAGCgmSJomT8ixkARkWAmNoMRQwEgYKCZImiZPyLGQB
GRYEY2VybjEtMCsGA1UEAxMkQ0VSTiBUcnVzdGVkIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MIIB
IjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwdFGqthhWlgUOSZ6C6hReNEVGzbjf2IQgxo7
/rOfOQHZH3krQPQ37fqFroEr46PrruymZ/U+QAzmESZQ4Z+nCfBhm7cEi0TIhihHd4cEPaPxawGR
T9Ck7BBk9za8TUljF6c/JodnIcmIrpbazEbSAS1KEXwETHDsTrQ7lJ+6SzDP4/oOwrHrgJx+tKsm
gOsFSbBEK4OYx1UYQpYS9OJQk2Sc0q4a/SCSu+xbN8ppmgV3WFytN8NW20n3NpCCWYPzo9rXmPRA
7a/c6mf+RV5gPCnUqeW6KUvix5kz9+X8/4SQV/fU12OPdRvtkqcC+PpiePK7bjMLQJEYwvchJrSz
AwIDAQABo4IDDjCCAwowDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUmMyS0EYwNoyw7ZgNclGp
R0zdviEwCwYDVR0PBAQDAgGGMBAGCSsGAQQBgjcVAQQDAgECMCMGCSsGAQQBgjcVAgQWBBT/Rljl
vgfrVK8GmAaYe+TbiXbJ7DBRBgNVHSAESjBIMEYGCisGAQQBYAoCAQEwODA2BggrBgEFBQcCARYq
aHR0cDovL2NhLmNlcm4uY2gvY2EvY3JsL3BvbGljeS9jcC1jcHMucGRmMBkGCSsGAQQBgjcUAgQM
HgoAUwB1AGIAQwBBMB8GA1UdIwQYMBaAFJgK9+w+7FnWHa2ZvLUBPt7spudQMIH8BgNVHR8EgfQw
gfEwge6ggeuggeiGLWh0dHA6Ly9jYS5jZXJuLmNoL2NhL2NybC9DRVJOJTIwUm9vdCUyMENBLmNy
bIaBtmxkYXA6Ly8vQ049Q0VSTiUyMFJvb3QlMjBDQSxDTj1jZXJucm9vdGNhLENOPUNEUCxDTj1Q
dWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWNl
cm4sREM9Y2g/Y2VydGlmaWNhdGVSZXZvY2F0aW9uTGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERp
c3RyaWJ1dGlvblBvaW50MIIBBAYIKwYBBQUHAQEEgfcwgfQwRAYIKwYBBQUHMAKGOGh0dHA6Ly9j
YS5jZXJuLmNoL2NhL2NybC9jZXJucm9vdGNhX0NFUk4lMjBSb290JTIwQ0EuY3J0MIGrBggrBgEF
BQcwAoaBnmxkYXA6Ly8vQ049Q0VSTiUyMFJvb3QlMjBDQSxDTj1BSUEsQ049UHVibGljJTIwS2V5
JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1jZXJuLERDPWNoP2NB
Q2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9uQXV0aG9yaXR5MA0GCSqG
SIb3DQEBBQUAA4IBAQAfEzvOeYohKndmJqnVdiCqZ38tSBxOOPsKUHW4UY1jBfYMXbnZ9keFQFlK
/g5X4aZPNBEHXw0eKpQVsMhEPWQrvx8T/f7GwtU+JNQhkgK9tnezmHxYzWgEC9MXZhfYzFSwMIF6
kSKllmUTnN35uF1EnT8+64daje+yEVcpmM34p8Fw125/WpKnRmwNp0YkUk6uMti6Y6vOTHttzIN5
P6elGoat8sadMqrVnaMNzG8hGUvSkYivYBs7msAPuwmXgLvIkXWPW+MDFs+x5Kzx75ZHv3c2WoKg
UxL5KZH9QqiR7t8P6YBfYW6SpzyGRi4QHN/iOLhXZ06R6aPljLEOn41JMIIHjzCCBnegAwIBAgIK
chmBHgACAAACZjANBgkqhkiG9w0BAQUFADBZMRIwEAYKCZImiZPyLGQBGRYCY2gxFDASBgoJkiaJ
k/IsZAEZFgRjZXJuMS0wKwYDVQQDEyRDRVJOIFRydXN0ZWQgQ2VydGlmaWNhdGlvbiBBdXRob3Jp
dHkwHhcNMDYxMTA5MTMwMjIzWhcNMDcxMTA5MTMwMjIzWjCBiTESMBAGCgmSJomT8ixkARkWAmNo
MRQwEgYKCZImiZPyLGQBGRYEY2VybjEWMBQGA1UECxMNT3JnYW5pYyBVbml0czEOMAwGA1UECxMF
VXNlcnMxDjAMBgNVBAMTBXJrdWhuMQ8wDQYDVQQDEwY1Nzg4NDcxFDASBgNVBAMTC1JvbGFuZCBL
dWhuMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsxeKSFlg3DexXFatyivnuM4Cny5T
wPQ2PfpxmEPxycXaGHlM+gVtSYRYll8nl/sJ/+etmw5H7cwxWSX1n2TLphDsxWIg9LDfRPgWJdfY
NtT3SclmEiwOAE934HmbuZ08X/xRmnz0D3Df2fbDCVQLRra3u1ZLGvzhT835Wx7+uKme/GPlZdPZ
QUBKN/xRlMyywvIBJtdoHmTDv93B4o+yaR+JjT5h0YOLS+2GA9vbS6YdXw38+pche/D3SD20zZP8
K78f3YWltka/PpEqq4JGvtlOdrr4BZ3i9/UusblVBGZJFTTznIRtUvPW29D9DTngutH6JQQazurR
MePYBzsjVQIDAQABo4IEJjCCBCIwHQYDVR0OBBYEFP67uXXCxYdJS7PG+73J0TsKDmhQMB8GA1Ud
IwQYMBaAFJjMktBGMDaMsO2YDXJRqUdM3b4hMIIBNAYDVR0fBIIBKzCCAScwggEjoIIBH6CCARuG
R2h0dHA6Ly9jYS5jZXJuLmNoL2NhL2NybC9DRVJOJTIwVHJ1c3RlZCUyMENlcnRpZmljYXRpb24l
MjBBdXRob3JpdHkuY3JshoHPbGRhcDovLy9DTj1DRVJOJTIwVHJ1c3RlZCUyMENlcnRpZmljYXRp
b24lMjBBdXRob3JpdHksQ049Y2VybnBraTAxLENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2
aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWNlcm4sREM9Y2g/Y2VydGlmaWNh
dGVSZXZvY2F0aW9uTGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERpc3RyaWJ1dGlvblBvaW50MIIB
RAYIKwYBBQUHAQEEggE2MIIBMjBoBggrBgEFBQcwAoZcaHR0cDovL2NhLmNlcm4uY2gvY2EvY3Js
L2Nlcm5wa2kwMS5jZXJuLmNoX0NFUk4lMjBUcnVzdGVkJTIwQ2VydGlmaWNhdGlvbiUyMEF1dGhv
cml0eSgyKS5jcnQwgcUGCCsGAQUFBzAChoG4bGRhcDovLy9DTj1DRVJOJTIwVHJ1c3RlZCUyMENl
cnRpZmljYXRpb24lMjBBdXRob3JpdHksQ049QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2Vz
LENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9Y2VybixEQz1jaD9jQUNlcnRpZmljYXRl
P2Jhc2U/b2JqZWN0Q2xhc3M9Y2VydGlmaWNhdGlvbkF1dGhvcml0eTAMBgNVHRMBAf8EAjAAMA4G
A1UdDwEB/wQEAwIFoDA9BgkrBgEEAYI3FQcEMDAuBiYrBgEEAYI3FQiDvdAJgu2NDYbtiyuB3vU3
hYDQYh6Fv7oDhMTMTAIBZAIBBTApBgNVHSUEIjAgBggrBgEFBQcDAgYIKwYBBQUHAwQGCisGAQQB
gjcKAwQwNQYJKwYBBAGCNxUKBCgwJjAKBggrBgEFBQcDAjAKBggrBgEFBQcDBDAMBgorBgEEAYI3
CgMEMFsGA1UdEQRUMFKgLwYKKwYBBAGCNxQCA6AhDB9ya3VobkBlMTgucGh5c2lrLnR1LW11ZW5j
aGVuLmRlgR9ya3VobkBlMTgucGh5c2lrLnR1LW11ZW5jaGVuLmRlMEQGCSqGSIb3DQEJDwQ3MDUw
DgYIKoZIhvcNAwICAgCAMA4GCCqGSIb3DQMEAgIAgDAHBgUrDgMCBzAKBggqhkiG9w0DBzANBgkq
hkiG9w0BAQUFAAOCAQEAsrZltdEJvGNe4SpJEjeXFLSM14WByMtIlw5kJkPZWiPs0CppsUzNotgg
Mf8O09OgH+3awFL/fMfQiO4RugrRtW0qqi7+8Poo1hWrQ1m4lQgXLRkSh2VQkqQMV+hiM8I+py6h
RbJuFZgx7GBScRUSzAtLFZAMbcw9J5x08syed4j3qEPpeuRbOpdUHVchMCg6dcQjBT5PpddN1C+i
V0JnXI9x0+vIPgz2+V4NgLJ1763pEZzcdDOkqz4uTAJsLQdJxjuqcg35u2jpzDElrzxHH2tzg7H7
a6V+I+vkYR+IvLYHJkBKPj9IwDabBpjUGUP33nDNmPE42cBa5LP2yvR9YDGCAuEwggLdAgEBMGcw
WTESMBAGCgmSJomT8ixkARkWAmNoMRQwEgYKCZImiZPyLGQBGRYEY2VybjEtMCsGA1UEAxMkQ0VS
TiBUcnVzdGVkIENlcnRpZmljYXRpb24gQXV0aG9yaXR5AgpyGYEeAAIAAAJmMAkGBSsOAwIaBQCg
ggFPMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTA3MDMwNjE1MTAw
OFowIwYJKoZIhvcNAQkEMRYEFOB3NUZeItYW6OuV3mJi1xNqM/65MHYGCSsGAQQBgjcQBDFpMGcw
WTESMBAGCgmSJomT8ixkARkWAmNoMRQwEgYKCZImiZPyLGQBGRYEY2VybjEtMCsGA1UEAxMkQ0VS
TiBUcnVzdGVkIENlcnRpZmljYXRpb24gQXV0aG9yaXR5AgpyGYEeAAIAAAJmMHgGCyqGSIb3DQEJ
EAILMWmgZzBZMRIwEAYKCZImiZPyLGQBGRYCY2gxFDASBgoJkiaJk/IsZAEZFgRjZXJuMS0wKwYD
VQQDEyRDRVJOIFRydXN0ZWQgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkCCnIZgR4AAgAAAmYwDQYJ
KoZIhvcNAQEBBQAEggEALun84kBk6Q295gKrFdKaLFkDCunA/HFPNju4/SucLQWdj1djvKaUChZ2
oBGZsARFzEz9wqVGvLyx1M2nLVmEerKUUBhnajpWC09nocYOm95Z+8L53fRrVf2XsK30tJQxObjT
edDkm+cmP9H3+thTb9/yI/iV77fARAWe2vxl9w+pKCBiNvzd2W6SzzWAGE6bQXpyRpt4oMlLaxbU
nis/MyFfJvWr/oaHtfCMYeZk/fWZDdwNrttVujQ9jTgG6E+15gGoRWS3hLrPE9LiSaffYKTEElCI
Od6VbvysA/2VglmlLHTr1imLzArl/USF0xHqHbDvtnmhvI2ZcH09QMBCiQAAAAAAAA==

--Apple-Mail-33--534403500--

--Apple-Mail-34--534403482
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: This is a digitally signed message part
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (Darwin)

iD8DBQFF7YRUI4MWO8QIRP0RAsRyAKCReYQwzhaZAucsyEcJn5T5ZQLv4ACbBZgf
VFD/vipxwhj7HMEpayrn1TE=
=oNeK
-----END PGP SIGNATURE-----

--Apple-Mail-34--534403482--
