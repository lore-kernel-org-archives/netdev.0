From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 8/17 linux-2.6.7-rc2] prism54: Fix bugs 74/75
Date: Sun, 30 May 2004 21:53:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20040530214358.00b0b560@pop.t-online.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="=====================_50452827==_"
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=====================_50452827==_
Content-Type: text/plain; charset="us-ascii"; format=flowed

2004-03-22      Aurelien Alleaume <slts@free.fr>

         * oid_mgt.c, isl_ioctl.c : Minor bugfixes : #74 and #75.
--=====================_50452827==_
Content-Type: application/octet-stream; name="08-fix-bug-74-75.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="08-fix-bug-74-75.patch"

ZGlmZiAtTmF1ckViIGxpbnV4LTIuNi42Y3QvZHJpdmVycy9uZXQvd2lyZWxlc3MvcHJpc201NC9p
c2xfaW9jdGwuYyBsaW51eC0yLjYuNi0wMS9kcml2ZXJzL25ldC93aXJlbGVzcy9wcmlzbTU0L2lz
bF9pb2N0bC5jCi0tLSBsaW51eC0yLjYuNmN0L2RyaXZlcnMvbmV0L3dpcmVsZXNzL3ByaXNtNTQv
aXNsX2lvY3RsLmMJMjAwNC0wNS0yOCAxNDo0MDoyNi45OTA0NTU2NTYgKzAyMDAKKysrIGxpbnV4
LTIuNi42LTAxL2RyaXZlcnMvbmV0L3dpcmVsZXNzL3ByaXNtNTQvaXNsX2lvY3RsLmMJMjAwNC0w
NS0yOCAxNDo0MzowMC45MjYwNTM4ODggKzAyMDAKQEAgLTE4OTMsNiArMTg5Myw3IEBACiAJc3Ry
dWN0IG5ldF9kZXZpY2UgKm5kZXYgPSBmcmFtZS0+bmRldjsKIAllbnVtIG9pZF9udW1fdCBuID0g
bWd0X29pZHRvbnVtKGZyYW1lLT5oZWFkZXItPm9pZCk7CiAKKwlpZiAobiAhPSBPSURfTlVNX0xB
U1QpCiAJcHJpc201NF9wcm9jZXNzX3RyYXBfaGVscGVyKG5ldGRldl9wcml2KG5kZXYpLCBuLCBm
cmFtZS0+ZGF0YSk7CiAJaXNscGNpX21ndF9yZWxlYXNlKGZyYW1lKTsKIH0KZGlmZiAtTmF1ckVi
IGxpbnV4LTIuNi42Y3QvZHJpdmVycy9uZXQvd2lyZWxlc3MvcHJpc201NC9vaWRfbWd0LmMgbGlu
dXgtMi42LjYtMDEvZHJpdmVycy9uZXQvd2lyZWxlc3MvcHJpc201NC9vaWRfbWd0LmMKLS0tIGxp
bnV4LTIuNi42Y3QvZHJpdmVycy9uZXQvd2lyZWxlc3MvcHJpc201NC9vaWRfbWd0LmMJMjAwNC0w
NS0yOCAxNDo0MDoyNy4wMDE0NTM5ODQgKzAyMDAKKysrIGxpbnV4LTIuNi42LTAxL2RyaXZlcnMv
bmV0L3dpcmVsZXNzL3ByaXNtNTQvb2lkX21ndC5jCTIwMDQtMDUtMjggMTQ6NDM6MDAuOTI5MDUz
NDMyICswMjAwCkBAIC02ODgsMTMgKzY4OCwxMyBAQAogewogCWludCBpOwogCi0JZm9yIChpID0g
MDsgaSA8IE9JRF9OVU1fTEFTVCAtIDE7IGkrKykKKwlmb3IgKGkgPSAwOyBpIDwgT0lEX05VTV9M
QVNUOyBpKyspCiAJCWlmIChpc2xfb2lkW2ldLm9pZCA9PSBvaWQpCiAJCQlyZXR1cm4gaTsKIAog
CXByaW50ayhLRVJOX0RFQlVHICJsb29raW5nIGZvciBhbiB1bmtub3duIG9pZCAweCV4Iiwgb2lk
KTsKIAotCXJldHVybiAwOworCXJldHVybiBPSURfTlVNX0xBU1Q7CiB9CiAKIGludAo=
--=====================_50452827==_--
