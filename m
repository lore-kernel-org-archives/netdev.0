From: "Gary N Spiess" <Gary.Spiess@Intermec.com>
Subject: [PATCH] natsemi update 4/4 External Fibre phy
Date: Fri, 04 Jun 2004 14:56:33 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406041456330453.0BC6681C@136.179.85.112>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=====_10863789934827=_"
Cc: manfred@colorfullife.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=====_10863789934827=_
Content-Type: multipart/alternative; boundary="=====_10863789935436=_"

--=====_10863789935436=_
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable

Jeff, 
This is the fourth of a series of patches needed to support our product=
 using the DP83815.
This patch adds support for our Fibre phy.  Sorry, I don't know anything=
 about the phy hardware.  I know the couple of phy bits that need to be=
 twiddled.
Gary
 oooooooooooooooooooooooooooooooooooooooooooooooooo
 Gary Spiess (Gary.Spiess@Intermec.com)
 MobileLan Wireless Products Group, Intermec Technology Corp
 voice: 319 369-3580  fax: 319 369-3804


--=====_10863789935436=_
Content-Type: text/html; charset="us-ascii"

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=Content-Type content="text/html; charset=iso-8859-1">
<META content="MSHTML 6.00.2800.1400" name=GENERATOR></HEAD>
<BODY style="FONT-FAMILY: Courier New" text=#000000 bgColor=#ffffff>Jeff, 
<P>This is the&nbsp;fourth of a series of patches needed to support our product 
using the DP83815.</P>
<P>This patch adds support for our Fibre phy.&nbsp; Sorry, I don't know anything 
about the phy hardware.&nbsp; I know&nbsp;the couple of phy bits that need to be 
twiddled.</P>
<P>Gary</P></BODY></HTML>

<PRE>
 oooooooooooooooooooooooooooooooooooooooooooooooooo
 Gary Spiess (Gary.Spiess@Intermec.com)
 MobileLan Wireless Products Group, Intermec Technology Corp
 voice: 319 369-3580  fax: 319 369-3804</PRE>


--=====_10863789935436=_--

--=====_10863789934827=_
Content-Type: application/octet-stream; name="natsemi-2.6.6-4.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="natsemi-2.6.6-4.patch"

LS0tIGxpbnV4LTIuNi42L2RyaXZlcnMvbmV0L25hdHNlbWkuYwkyMDA0LTA2
LTAzIDE1OjEwOjAwLjAwMDAwMDAwMCAtMDUwMAorKysgbGludXgvZHJpdmVy
cy9uZXQvbmF0c2VtaS5jCTIwMDQtMDYtMDMgMTU6MTA6MTYuMDAwMDAwMDAw
IC0wNTAwCkBAIC0zNTEsNiArMzUxLDEwIEBACiBOb25lIGNoYXJhY3Rlcmlz
ZWQuCiAqLwogCisvKiBhZGQgYSBjb3VwbGUgb2YgTUlJIGRlZmluaXRpb25z
IHNwZWNpZmljIHRvIGEgUE9SVF9GSUJSRSBpbXBsZW1lbnRhdGlvbiAqLwor
I2RlZmluZSBNSUlfTUNUUkwJMHgxNQkvKiBtb2RlIGNvbnRyb2wgcmVnaXN0
ZXIgKi8KKyNkZWZpbmUgTUlJX0lOX0ZYX01PREUJMHgwMDAxCS8qIGZ1bGwg
ZHVwbGV4ICovCisjZGVmaW5lIE1JSV9ESVNfU0NSTQkweDAwMDQJLyogZGlz
YWJsZSBzY3JhbWJsZXIgKi8KIAogCiBlbnVtIHBjaXN0dWZmIHsKQEAgLTI0
MDMsNyArMjQwNyw3IEBACiAJZWNtZC0+c3VwcG9ydGVkID0KIAkJKFNVUFBP
UlRFRF8xMGJhc2VUX0hhbGYgfCBTVVBQT1JURURfMTBiYXNlVF9GdWxsIHwK
IAkJU1VQUE9SVEVEXzEwMGJhc2VUX0hhbGYgfCBTVVBQT1JURURfMTAwYmFz
ZVRfRnVsbCB8Ci0JCVNVUFBPUlRFRF9BdXRvbmVnIHwgU1VQUE9SVEVEX1RQ
IHwgU1VQUE9SVEVEX01JSSk7CisJCVNVUFBPUlRFRF9BdXRvbmVnIHwgU1VQ
UE9SVEVEX1RQIHwgU1VQUE9SVEVEX01JSSB8IFNVUFBPUlRFRF9GSUJSRSk7
CiAKIAkvKiBSZXR1cm4gdGhlIHRyYW5zY2VpdmVyIHR5cGUgKi8KIAllY21k
LT5wb3J0ID0gZGV2LT5pZl9wb3J0OwpAQCAtMjQxNyw2ICsyNDIxLDEwIEBA
CiAJCWVjbWQtPmFkdmVydGlzaW5nID0gQURWRVJUSVNFRF9NSUk7CiAJCWVj
bWQtPnRyYW5zY2VpdmVyID0gWENWUl9FWFRFUk5BTDsKIAkJYnJlYWs7CisJ
Y2FzZSBQT1JUX0ZJQlJFOgorCQllY21kLT5hZHZlcnRpc2luZyA9IEFEVkVS
VElTRURfRklCUkU7CisJCWVjbWQtPnRyYW5zY2VpdmVyID0gWENWUl9FWFRF
Uk5BTDsKKwkJYnJlYWs7CiAJfQogCWVjbWQtPnBvcnQgPSBkZXYtPmlmX3Bv
cnQ7CiAJZWNtZC0+cGh5X2FkZHJlc3MgPSBucC0+cGh5X2FkZHJfZXh0ZXJu
YWw7CkBAIC0yNDczLDYgKzI0ODEsNyBAQAogCQllbHNlIGlmIChlY21kLT50
cmFuc2NlaXZlciA9PSBYQ1ZSX0VYVEVSTkFMKQogCQkJZWNtZC0+cG9ydCA9
IFBPUlRfVFA7CiAJCWJyZWFrOworCWNhc2UgUE9SVF9GSUJSRToKIAljYXNl
IFBPUlRfTUlJOgogCQlpZiAoZGV2LT5pZl9wb3J0ID09IFBPUlRfVFApCiAJ
CQllY21kLT50cmFuc2NlaXZlciA9IFhDVlJfRVhURVJOQUw7CkBAIC0yNTAz
LDYgKzI1MTIsMTUgQEAKIAlucC0+cGh5X2FkZHJfZXh0ZXJuYWwgPSBlY21k
LT5waHlfYWRkcmVzcyAmIFBoeUFkZHJNYXNrOwogCWRldi0+aWZfcG9ydCA9
IGVjbWQtPnBvcnQ7CiAKKwkvKiBmaWJyZSBtb2RlPyAqLworCXRtcCA9IDA7
CisJaWYgKGRldi0+aWZfcG9ydCA9PSBQT1JUX0ZJQlJFKSB7CisJCXRtcCB8
PSBNSUlfRElTX1NDUk07CisJCWlmIChlY21kLT5kdXBsZXggPT0gRFVQTEVY
X0ZVTEwpCisJCQl0bXAgfD0gTUlJX0lOX0ZYX01PREU7CisJfQorCW1kaW9f
d3JpdGUoZGV2LCAxLCBNSUlfTUNUUkwsIHRtcCk7CisKIAl0bXAgPSBtZGlv
X3JlYWQoZGV2LCAxLCBNSUlfQk1DUik7CiAJaWYgKGVjbWQtPmF1dG9uZWcg
PT0gQVVUT05FR19FTkFCTEUpIHsKIAkJLyogdHVybiBvbiBhdXRvbmVnb3Rp
YXRpb24sIGFuZCBmb3JjZSBhIHJlbmVnb3RpYXRlICovCg==

--=====_10863789934827=_--
