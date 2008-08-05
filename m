From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6 2/2] ipv6: replace dst_metric() with dst_mtu() in net/ipv6/route.c.
Date: Tue, 5 Aug 2008 16:01:34 +0300
Message-ID: <eb3ff54b0808050601ua3ff5e0q28a808b5f381fa8c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_5709_25085554.1217941294927"
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:55957 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754377AbYHENBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 09:01:35 -0400
Received: by wf-out-1314.google.com with SMTP id 27so4048533wfd.4
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2008 06:01:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_5709_25085554.1217941294927
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
This patch replaces dst_metric() with dst_mtu() in net/ipv6/route.c.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_5709_25085554.1217941294927
Content-Type: text/x-patch;
 name=0011-replace-dst_metric-with-dst_mtu-in-net-ipv6-rout.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fjiirdgq0
Content-Disposition: attachment;
 filename=0011-replace-dst_metric-with-dst_mtu-in-net-ipv6-rout.patch

ZGlmZiAtLWdpdCBhL25ldC9pcHY2L3JvdXRlLmMgYi9uZXQvaXB2Ni9yb3V0ZS5jCmluZGV4IDg2
NTQwYjIuLjVhM2U4N2UgMTAwNjQ0Ci0tLSBhL25ldC9pcHY2L3JvdXRlLmMKKysrIGIvbmV0L2lw
djYvcm91dGUuYwpAQCAtMTI0OSw3ICsxMjQ5LDcgQEAgaW5zdGFsbF9yb3V0ZToKIAogCWlmIChk
c3RfbWV0cmljKCZydC0+dS5kc3QsIFJUQVhfSE9QTElNSVQpID09IDApCiAJCXJ0LT51LmRzdC5t
ZXRyaWNzW1JUQVhfSE9QTElNSVQtMV0gPSAtMTsKLQlpZiAoIWRzdF9tZXRyaWMoJnJ0LT51LmRz
dCwgUlRBWF9NVFUpKQorCWlmICghZHN0X210dSgmcnQtPnUuZHN0KSkKIAkJcnQtPnUuZHN0Lm1l
dHJpY3NbUlRBWF9NVFUtMV0gPSBpcHY2X2dldF9tdHUoZGV2KTsKIAlpZiAoIWRzdF9tZXRyaWMo
JnJ0LT51LmRzdCwgUlRBWF9BRFZNU1MpKQogCQlydC0+dS5kc3QubWV0cmljc1tSVEFYX0FEVk1T
Uy0xXSA9IGlwdjZfYWR2bXNzKG5ldCwgZHN0X210dSgmcnQtPnUuZHN0KSk7Cgo=
------=_Part_5709_25085554.1217941294927--
