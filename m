From: Andrew McGregor <andrewmcgr@gmail.com>
Subject: Re: coping with memory limitations and packet flooding in
	codel and fq_codel
Date: Tue, 21 Aug 2012 22:27:13 +1200
Message-ID: <46C4C66E-A4EE-4051-9686-7AD02EE925B4@gmail.com>
References: <CAA93jw7=K8Vvp6N5qYZ8gaODaFyZtAEjGyQe2BDh9-RBsvVHcQ@mail.gmail.com>
	<1345538298.5158.401.camel@edumazet-glaptop>
Mime-Version: 1.0 (Mac OS X Mail 6.0 \(1485\))
Content-Type: multipart/mixed; boundary="===============5505677863306140262=="
Cc: netdev <netdev@vger.kernel.org>, codel@lists.bufferbloat.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1345538298.5158.401.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org


--===============5505677863306140262==
Content-Type: multipart/signed; boundary="Apple-Mail=_491BEAD6-60DF-42D1-BE79-784BB87FB055"; protocol="application/pkcs7-signature"; micalg=sha1


--Apple-Mail=_491BEAD6-60DF-42D1-BE79-784BB87FB055
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii


On 21/08/2012, at 8:38 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> ath9k driver is known to deliver very fat skbs (skb->truesize is too
> big)

What would it take to fix this?

Andrew
--Apple-Mail=_491BEAD6-60DF-42D1-BE79-784BB87FB055
Content-Disposition: attachment;
	filename=smime.p7s
Content-Type: application/pkcs7-signature;
	name=smime.p7s
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIFLjCCBSow
ggQSoAMCAQICEQDMQ2ZKvgsUYA5oQg5SjWfVMA0GCSqGSIb3DQEBBQUAMIGTMQswCQYDVQQGEwJH
QjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQK
ExFDT01PRE8gQ0EgTGltaXRlZDE5MDcGA1UEAxMwQ09NT0RPIENsaWVudCBBdXRoZW50aWNhdGlv
biBhbmQgU2VjdXJlIEVtYWlsIENBMB4XDTExMTAwMTAwMDAwMFoXDTEyMDkzMDIzNTk1OVowJTEj
MCEGCSqGSIb3DQEJARYUYW5kcmV3bWNnckBnbWFpbC5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IB
DwAwggEKAoIBAQC+buTRxzSXTQmMyUqaokLJit3xU5WVudxHijhKbGRSTgJ867L/v8+rNhSoFwCV
MdKIu/M7apWgGkkA+MT/LjDFj63jLT+4nTTLIojXZdoezbpp/rQ2ViSbi54AjhZBQ5X+yH2xcXmG
KpDhZjeZC1bvKNvBtdOHCAcrx1Ys1BNj+AhwridEX/KD0cq5xSsJhjDggF6XSUOsaiqBHR6fiQMi
7gH8EuFBh83oklb/pdreg1fQ7gKJk/Me/atIbE1gtbIR88oaCtXoHfZxgkFwagwMtBHdkxN+wcZy
9xx78el9Lxrjx2nMq50hRlj/bqg/m4rSox7//DKfx7bfKNZAiSMDAgMBAAGjggHkMIIB4DAfBgNV
HSMEGDAWgBR6E04AdFvGeGNkJ8Ev4qBbvHnFezAdBgNVHQ4EFgQUXOXqNkq6sNbrD8B41dPko8Gs
JucwDgYDVR0PAQH/BAQDAgWgMAwGA1UdEwEB/wQCMAAwIAYDVR0lBBkwFwYIKwYBBQUHAwQGCysG
AQQBsjEBAwUCMBEGCWCGSAGG+EIBAQQEAwIFIDBGBgNVHSAEPzA9MDsGDCsGAQQBsjEBAgEBATAr
MCkGCCsGAQUFBwIBFh1odHRwczovL3NlY3VyZS5jb21vZG8ubmV0L0NQUzBXBgNVHR8EUDBOMEyg
SqBIhkZodHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9DT01PRE9DbGllbnRBdXRoZW50aWNhdGlvbmFu
ZFNlY3VyZUVtYWlsQ0EuY3JsMIGIBggrBgEFBQcBAQR8MHowUgYIKwYBBQUHMAKGRmh0dHA6Ly9j
cnQuY29tb2RvY2EuY29tL0NPTU9ET0NsaWVudEF1dGhlbnRpY2F0aW9uYW5kU2VjdXJlRW1haWxD
QS5jcnQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTAfBgNVHREEGDAWgRRh
bmRyZXdtY2dyQGdtYWlsLmNvbTANBgkqhkiG9w0BAQUFAAOCAQEAgmf81vnsAnbcmIAyyqvEKxAK
jRHerfreN10DK1ISkUJ//U4uffQV8sAGDtyIErzVFsW6NYRmFCMSE20M1ffbFpWUmXCtm/YTlkf1
5STVjTMNshDzMDhpjx99Z2J5RBJPZpXjwmpQnfKwB7zft9TcUSIb9FvZm33EKdF/XlS12U4Q9fsj
2shZf88RituX2+fCWfHoTWiFEhFUkLRtWf1YpgHpEXr82nqROxs/aWNlqtLnwTTu2ULr/WpUaRDs
kom8gFZkMgw5kRfLpSXRrCFSORsZzkH2ooRxaJY7wMwZaCUS1am9DuwVy7gehoc3ZsjsDkMObZeu
kx7Cg7GxIkgo+zGCA64wggOqAgEBMIGpMIGTMQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRl
ciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRl
ZDE5MDcGA1UEAxMwQ09NT0RPIENsaWVudCBBdXRoZW50aWNhdGlvbiBhbmQgU2VjdXJlIEVtYWls
IENBAhEAzENmSr4LFGAOaEIOUo1n1TAJBgUrDgMCGgUAoIIB2TAYBgkqhkiG9w0BCQMxCwYJKoZI
hvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xMjA4MjExMDI3MTRaMCMGCSqGSIb3DQEJBDEWBBS91oWM
6Wbi87xg2l4j46OROKiZYTCBugYJKwYBBAGCNxAEMYGsMIGpMIGTMQswCQYDVQQGEwJHQjEbMBkG
A1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01P
RE8gQ0EgTGltaXRlZDE5MDcGA1UEAxMwQ09NT0RPIENsaWVudCBBdXRoZW50aWNhdGlvbiBhbmQg
U2VjdXJlIEVtYWlsIENBAhEAzENmSr4LFGAOaEIOUo1n1TCBvAYLKoZIhvcNAQkQAgsxgayggakw
gZMxCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1Nh
bGZvcmQxGjAYBgNVBAoTEUNPTU9ETyBDQSBMaW1pdGVkMTkwNwYDVQQDEzBDT01PRE8gQ2xpZW50
IEF1dGhlbnRpY2F0aW9uIGFuZCBTZWN1cmUgRW1haWwgQ0ECEQDMQ2ZKvgsUYA5oQg5SjWfVMA0G
CSqGSIb3DQEBAQUABIIBALCokzZJAZjxSvFScudffmOVA8v/5RXCgDWAMTBNgeaY93qz1nmWYF8n
Nq1f4K/45psM6KFDFVIhJ3zETidIOBJJP7jo2X+NqWBmm7UP0PdtiHTfSR43b+tXyeVXFW6ggZ2S
ZxML6aavS6E6yUrohG6CyMl9Wk//QTrR1bXcd7nNURFARgpr01GyHCB174R0T/puLOasHvu4Vfhu
Mc0e3vGOIEiYe49tH2gBQ4Pwfyp/uFaUwyqg+aMazSPGbAJzYIkhrET18NGlg/4U1CXQUCOA3BYP
ZMV1o3JHwHn+pTrRbYydLS4wGt9XHq/cUc5MO3qN+pey5VT5cHXSxgVwnNcAAAAAAAA=

--Apple-Mail=_491BEAD6-60DF-42D1-BE79-784BB87FB055--

--===============5505677863306140262==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Codel mailing list
Codel@lists.bufferbloat.net
https://lists.bufferbloat.net/listinfo/codel

--===============5505677863306140262==--
