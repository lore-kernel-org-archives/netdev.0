From: Yoann Juet <yoann.juet@univ-nantes.fr>
Subject: Re: bnx2x + SR-IOV, no internal L2 switching
Date: Thu, 13 Feb 2014 10:42:08 +0100
Message-ID: <52FC9370.5030400@univ-nantes.fr>
References: <52FB7843.6050601@univ-nantes.fr> <1392246640.15615.37.camel@deadeye.wl.decadent.org.uk>
Reply-To: yoann.juet@univ-nantes.fr
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha1; boundary="------------ms000903080805030604040609"
Cc: netdev@vger.kernel.org, Ariel Elior <ariele@broadcom.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtptls1-loi.cpub.univ-nantes.fr ([193.52.103.112]:50756 "EHLO
	smtp-tls.univ-nantes.fr" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752367AbaBMJlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 04:41:16 -0500
In-Reply-To: <1392246640.15615.37.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms000903080805030604040609
Content-Type: multipart/mixed;
 boundary="------------050505080902000006070307"

This is a multi-part message in MIME format.
--------------050505080902000006070307
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable

Hi Ben,

 > Are you're using the ISC DHCP client, which puts the interface in
> promiscuous mode?  If the Broadcom NIC supports promiscuous mode on VFs=
,
> that may explain what you're seeing.

No, I put the interface into promiscuous mode with Wireshark's tshark=20
command line tool.

> I think these VFs don't support promiscuous mode.  Anyway, the ixgbevf
> driver silently ignores it.

This could be an explanation. Ariel Elior sent to me a patch. Test in=20
progress.

Regards,
--=20
Universit=C3=A9 de Nantes - Direction des Syst=C3=A8mes d'Information

--------------050505080902000006070307
Content-Type: text/x-vcard; charset=utf-8;
 name="yoann_juet.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="yoann_juet.vcf"

YmVnaW46dmNhcmQNCmZuOllvYW5uIEp1ZXQNCm46SnVldDtZb2Fubg0Kb3JnO3F1b3RlZC1w
cmludGFibGU7cXVvdGVkLXByaW50YWJsZTpEaXJlY3Rpb24gZGVzIFN5c3Q9QzM9QThtZXMg
ZCdJbmZvcm1hdGlvbjtQPUMzPUI0bGUgUj1DMz1BOXNlYXUNCmFkcjtxdW90ZWQtcHJpbnRh
YmxlOkJQIDkyMjA4OzsyIHJ1ZSBkZSBsYSBIb3Vzc2luaT1DMz1BOHJlO05hbnRlcyBDZWRl
eCAzOzs0NDMyMjtGcmFuY2UNCmVtYWlsO2ludGVybmV0OnlvYW5uLmp1ZXRAdW5pdi1uYW50
ZXMuZnINCnRlbDt3b3JrOjAyLjUzLjQ4LjQ5LjI2DQp0ZWw7ZmF4OjAyLjUzLjQ4LjQ5LjA5
DQp0ZWw7Y2VsbDowNi43My4xNS40Mi4xOQ0KdmVyc2lvbjoyLjENCmVuZDp2Y2FyZA0KDQo=
--------------050505080902000006070307--

--------------ms000903080805030604040609
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIJcDCC
BKUwggONoAMCAQICEQCaw9r4AWwhPTK3X2MyL6H8MA0GCSqGSIb3DQEBBQUAMDsxCzAJBgNV
BAYTAk5MMQ8wDQYDVQQKEwZURVJFTkExGzAZBgNVBAMTElRFUkVOQSBQZXJzb25hbCBDQTAe
Fw0xMTA4MTcwMDAwMDBaFw0xNDA4MTYyMzU5NTlaMGcxCzAJBgNVBAYTAkZSMR0wGwYDVQQK
ExRVTklWRVJTSVRFIERFIE5BTlRFUzETMBEGA1UEAxMKWW9hbm4gSlVFVDEkMCIGCSqGSIb3
DQEJAhYVanVldC15QHVuaXYtbmFudGVzLmZyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAzT4cyMjT4IaRAql635iNoxjb9ticpoS8Qauq9qGkV2HzDOqjI5SIc0nlU1EOWnbO
05cewhUbOcM1YunHBSahw5cltsC3Uu4D2XAVQ5vD9VmS9kV2eBn3T9vSB1Yz7r7xSPOhHN50
8qspRwgRExu1tFANqG7TMJbFtN5iG22fiQkNzlVLDV3vgB6B9eJaAayfVlZSq+QUMv2dp6AI
8g7Z1tInb7EWVMbB17d7rSfGXJnQHN9wlRduAg2r+PfHcH2Z6Bxmxl66GABxH9keZxdnfo6G
ph0/l0FFj7VwitXEU7V1kTuq7+vZc5qAT/mcSPO471+KzfU14AgEc8qvALV6iQIDAQABo4IB
djCCAXIwHwYDVR0jBBgwFoAUY01DWhlIP8RGwQK6v+4O5YK3ZqYwHQYDVR0OBBYEFKPfL4a9
soFXobME5dHUc30NI4iCMA4GA1UdDwEB/wQEAwIFoDAMBgNVHRMBAf8EAjAAMB0GA1UdJQQW
MBQGCCsGAQUFBwMEBggrBgEFBQcDAjAYBgNVHSAEETAPMA0GCysGAQQBsjEBAgIdMD8GA1Ud
HwQ4MDYwNKAyoDCGLmh0dHA6Ly9jcmwudGNzLnRlcmVuYS5vcmcvVEVSRU5BUGVyc29uYWxD
QS5jcmwwcgYIKwYBBQUHAQEEZjBkMDoGCCsGAQUFBzAChi5odHRwOi8vY3J0LnRjcy50ZXJl
bmEub3JnL1RFUkVOQVBlcnNvbmFsQ0EuY3J0MCYGCCsGAQUFBzABhhpodHRwOi8vb2NzcC50
Y3MudGVyZW5hLm9yZzAkBgNVHREEHTAbgRlZb2Fubi5KdWV0QHVuaXYtbmFudGVzLmZyMA0G
CSqGSIb3DQEBBQUAA4IBAQCsH20G5ntaV5rBAKu+TjhdseCOkRFhExE6W+ImhXJb1aKFLtnt
epvS6pTenXbBp+8OTjOXDJ9JpmA6sbGpy8FYIThiDiRLVMf1kVgU4ECDo2RE6AHtnRJ645Dw
+fvXbFef9u+0aGehKREb6OVdl/6x9DFQvVm/bj9hQtXPusCXYUe1b/ZCbUKFQSfmXwFMLmFb
U64YhP3YRczYaznadT8Cm0INpaYZJatUan74iufwiC71toLGOEnupbQGOLSHalBdAy+u9WGl
5Nm+oE+R+m8tqbRFUn9GSiswSi7RQXxk4O/qOev3/aF+cG4W4D5DCVBsKqTpFcu1fgzdzWQE
IxRTMIIEwzCCA6ugAwIBAgIQc/5X+t+4xQiBe2a5a/At7zANBgkqhkiG9w0BAQUFADCBrjEL
MAkGA1UEBhMCVVMxCzAJBgNVBAgTAlVUMRcwFQYDVQQHEw5TYWx0IExha2UgQ2l0eTEeMBwG
A1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMSEwHwYDVQQLExhodHRwOi8vd3d3LnVzZXJ0
cnVzdC5jb20xNjA0BgNVBAMTLVVUTi1VU0VSRmlyc3QtQ2xpZW50IEF1dGhlbnRpY2F0aW9u
IGFuZCBFbWFpbDAeFw0wOTA1MTgwMDAwMDBaFw0yODEyMzEyMzU5NTlaMDsxCzAJBgNVBAYT
Ak5MMQ8wDQYDVQQKEwZURVJFTkExGzAZBgNVBAMTElRFUkVOQSBQZXJzb25hbCBDQTCCASIw
DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMgV2fUzaiOhkA3PuwVEw6sfSjWFGiGFoE/4
8EDiSkOb/luxsL+0V9x1gEFLZBr2209vj9AlRTX56stK+vva0+1FiBGUNuTMqA3vxT037RZ7
48KVnlgzfyL7+P/s5r7brgplJSKH2m+Ei0boQIYoP79WCOJK6YOi6SL7Lfq2KB+RwcNx+1PA
K06kDKFunVXt7OEkhzoI4g0c5MRN0Msn+oRk5tGXnVYkW5O7KS5D4kFqPeJKZfyaX1qGh7yH
x3mAlplRxpAPZJGZfRDdrCwDKuF4ZP7OPU70K1ARS9FY1JsD8H/1O1OwU0P7xS/EBCkaOqzX
VenRDpXROzF/eE+uKS0CAwEAAaOCAU0wggFJMB8GA1UdIwQYMBaAFImCZ33EnSZwAEu0UEh8
3j2uBG59MB0GA1UdDgQWBBRjTUNaGUg/xEbBArq/7g7lgrdmpjAOBgNVHQ8BAf8EBAMCAQYw
EgYDVR0TAQH/BAgwBgEB/wIBADAYBgNVHSAEETAPMA0GCysGAQQBsjEBAgIdMFgGA1UdHwRR
ME8wTaBLoEmGR2h0dHA6Ly9jcmwudXNlcnRydXN0LmNvbS9VVE4tVVNFUkZpcnN0LUNsaWVu
dEF1dGhlbnRpY2F0aW9uYW5kRW1haWwuY3JsMG8GCCsGAQUFBwEBBGMwYTA4BggrBgEFBQcw
AoYsaHR0cDovL2NydC51c2VydHJ1c3QuY29tL1VUTkFBQUNsaWVudF9DQS5jcnQwJQYIKwYB
BQUHMAGGGWh0dHA6Ly9vY3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEFBQADggEBAAYr
qVMvE9xcORbMhp9eTHty++yNVYpemgr/U0x29AY9UM9X8KLPr5mMqv6gGXY+mQMy+nWDOIq7
a5qlDBOy1Bt25pQuZ5hZ45FsApCanMhgS1WryohajSvlaZUDB9HUDvwkIi5ZsWOkX+3ZI3Lk
nM46XGwfT6kAyR3++n9FLbYuhN0PJ6BZGE7VdiVF9JkmedtvnyP3Q7srDwSjgSYst3s1+T13
X0Ah5n8dpZZavdDLFjpsu2GLiv0EOUQKyyzhy84uEJga2+CT7UlkZAggn7ejUPCi3cq0xnwM
PedeFdwnhuQ6O1JaF6upBlMrnQlzZBwBw/0w0ocDb+QVA3o5X2gxggMKMIIDBgIBATBQMDsx
CzAJBgNVBAYTAk5MMQ8wDQYDVQQKEwZURVJFTkExGzAZBgNVBAMTElRFUkVOQSBQZXJzb25h
bCBDQQIRAJrD2vgBbCE9MrdfYzIvofwwCQYFKw4DAhoFAKCCAY8wGAYJKoZIhvcNAQkDMQsG
CSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTQwMjEzMDk0MjA4WjAjBgkqhkiG9w0BCQQx
FgQUTr/0RmzbtLx7/NJcjiqb8HIcJ0MwXwYJKwYBBAGCNxAEMVIwUDA7MQswCQYDVQQGEwJO
TDEPMA0GA1UEChMGVEVSRU5BMRswGQYDVQQDExJURVJFTkEgUGVyc29uYWwgQ0ECEQCaw9r4
AWwhPTK3X2MyL6H8MGEGCyqGSIb3DQEJEAILMVKgUDA7MQswCQYDVQQGEwJOTDEPMA0GA1UE
ChMGVEVSRU5BMRswGQYDVQQDExJURVJFTkEgUGVyc29uYWwgQ0ECEQCaw9r4AWwhPTK3X2My
L6H8MGwGCSqGSIb3DQEJDzFfMF0wCwYJYIZIAWUDBAEqMAsGCWCGSAFlAwQBAjAKBggqhkiG
9w0DBzAOBggqhkiG9w0DAgICAIAwDQYIKoZIhvcNAwICAUAwBwYFKw4DAgcwDQYIKoZIhvcN
AwICASgwDQYJKoZIhvcNAQEBBQAEggEAaxz7aj33AL9uTeo8zKki6sOiWOe3R2ElI+2deBs7
TShcY+9sXukM54m4J6ARiP5Kwv/nVQaJAFFeoWt5zXkqnDhI8mRnLlVaWz2b5gbw5mksCjUZ
l/qyrI41bdCp2kTlbQpoh71XtsISd4X+xfx80fBGtNKMBRJ8OcX7e2KRoM9ndVKXsjGRi2gt
t1hsHMbiLkai5CBI3TrFhfC27O3Sqh08qAsI3Ssh6uW/czvkV5/lz/ICsEIizc+ufqQEaFC1
E4dTmmJEwj/+ojgYCEAyr8yMRfLsO7oWgcq+YAv+eLStdlZPspdaSjeQ6VgR1a9kNmO8n7Xs
ZHXW78AHhl7ghQAAAAAAAA==
--------------ms000903080805030604040609--
