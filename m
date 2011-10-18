From: Kevin Wilson <wkevils@gmail.com>
Subject: [PATCH net-next-2.6] [IPV6] cleanup: remove unused IPV6 stats entries.
Date: Tue, 18 Oct 2011 07:36:00 +0200
Message-ID: <CAGXs5wVxkqLeCEMV6Lanczj-zarv6iu4ekdjk5zZKaadabwvbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=bcaec547c5453dd40804af8c1937
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:35235 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752960Ab1JRFgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 01:36:02 -0400
Received: by vcge1 with SMTP id e1so196854vcg.19
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 22:36:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--bcaec547c5453dd40804af8c1937
Content-Type: text/plain; charset=ISO-8859-1

Hi,

This cleanup patch removes three unused IPV6 stats entries
from rt6_statistics struct. (ip6_fib.h).

Regards,
  wkevils@gmail.com


Signed-off-by: Kevin Wilson <wkevils@gmail.com>

--bcaec547c5453dd40804af8c1937
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gtwgjdly0

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2lwNl9maWIuaCBiL2luY2x1ZGUvbmV0L2lwNl9maWIu
aAppbmRleCA1NzM1YTBmLi5hYzZmOTFiIDEwMDY0NAotLS0gYS9pbmNsdWRlL25ldC9pcDZfZmli
LmgKKysrIGIvaW5jbHVkZS9uZXQvaXA2X2ZpYi5oCkBAIC0xMzksMTEgKzEzOSw4IEBAIHN0cnVj
dCBmaWI2X3dhbGtlcl90IHsKIH07CiAKIHN0cnVjdCBydDZfc3RhdGlzdGljcyB7Ci0JX191MzIJ
CWZpYl9ub2RlczsKIAlfX3UzMgkJZmliX3JvdXRlX25vZGVzOwotCV9fdTMyCQlmaWJfcnRfYWxs
b2M7CQkvKiBwZXJtYW5lbnQgcm91dGVzCSovCiAJX191MzIJCWZpYl9ydF9lbnRyaWVzOwkJLyog
cnQgZW50cmllcyBpbiB0YWJsZQkqLwotCV9fdTMyCQlmaWJfcnRfY2FjaGU7CQkvKiBjYWNoZSBy
b3V0ZXMJCSovCiAJX191MzIJCWZpYl9kaXNjYXJkZWRfcm91dGVzOwogfTsKIApkaWZmIC0tZ2l0
IGEvbmV0L2lwdjYvcm91dGUuYyBiL25ldC9pcHY2L3JvdXRlLmMKaW5kZXggZmI1NDVlZC4uN2Y3
YTgwYyAxMDA2NDQKLS0tIGEvbmV0L2lwdjYvcm91dGUuYworKysgYi9uZXQvaXB2Ni9yb3V0ZS5j
CkBAIC0yNjcyLDEyICsyNjcyLDkgQEAgc3RhdGljIGNvbnN0IHN0cnVjdCBmaWxlX29wZXJhdGlv
bnMgaXB2Nl9yb3V0ZV9wcm9jX2ZvcHMgPSB7CiBzdGF0aWMgaW50IHJ0Nl9zdGF0c19zZXFfc2hv
dyhzdHJ1Y3Qgc2VxX2ZpbGUgKnNlcSwgdm9pZCAqdikKIHsKIAlzdHJ1Y3QgbmV0ICpuZXQgPSAo
c3RydWN0IG5ldCAqKXNlcS0+cHJpdmF0ZTsKLQlzZXFfcHJpbnRmKHNlcSwgIiUwNHggJTA0eCAl
MDR4ICUwNHggJTA0eCAlMDR4ICUwNHhcbiIsCi0JCSAgIG5ldC0+aXB2Ni5ydDZfc3RhdHMtPmZp
Yl9ub2RlcywKKwlzZXFfcHJpbnRmKHNlcSwgIiUwNHggJTA0eCAlMDR4ICUwNHhcbiIsCiAJCSAg
IG5ldC0+aXB2Ni5ydDZfc3RhdHMtPmZpYl9yb3V0ZV9ub2RlcywKLQkJICAgbmV0LT5pcHY2LnJ0
Nl9zdGF0cy0+ZmliX3J0X2FsbG9jLAogCQkgICBuZXQtPmlwdjYucnQ2X3N0YXRzLT5maWJfcnRf
ZW50cmllcywKLQkJICAgbmV0LT5pcHY2LnJ0Nl9zdGF0cy0+ZmliX3J0X2NhY2hlLAogCQkgICBk
c3RfZW50cmllc19nZXRfc2xvdygmbmV0LT5pcHY2LmlwNl9kc3Rfb3BzKSwKIAkJICAgbmV0LT5p
cHY2LnJ0Nl9zdGF0cy0+ZmliX2Rpc2NhcmRlZF9yb3V0ZXMpOwogCg==
--bcaec547c5453dd40804af8c1937--
