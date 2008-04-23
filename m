From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH 2/3] [IPV6] Use MRT6_VERSION instead of MRT_VERSION in ip6mr.c.
Date: Wed, 23 Apr 2008 14:35:13 +0300
Message-ID: <eb3ff54b0804230435y2060d8c8pcaa9d5b806e309f4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_13630_5449911.1208950513838"
To: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	"David Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:13042 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875AbYDWLfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 07:35:16 -0400
Received: by fg-out-1718.google.com with SMTP id l27so2592815fgb.17
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2008 04:35:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_13630_5449911.1208950513838
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
MRT6_VERSION should be used instead of MRT_VERSION in ip6mr.c.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_13630_5449911.1208950513838
Content-Type: text/plain; name=patch2.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ffdtvgzj0
Content-Disposition: attachment; filename=patch2.txt

ZGlmZiAtLWdpdCBhL25ldC9pcHY2L2lwNm1yLmMgYi9uZXQvaXB2Ni9pcDZtci5jCmluZGV4IGM4
YzZlMzMuLjhhYmZmN2UgMTAwNjQ0Ci0tLSBhL25ldC9pcHY2L2lwNm1yLmMKKysrIGIvbmV0L2lw
djYvaXA2bXIuYwpAQCAtMTI0OCw3ICsxMjQ4LDcgQEAgaW50IGlwNl9tcm91dGVfc2V0c29ja29w
dChzdHJ1Y3Qgc29jayAqc2ssIGludCBvcHRuYW1lLCBjaGFyIF9fdXNlciAqb3B0dmFsLCBpbnQK
IAogI2VuZGlmCiAJLyoKLQkgKglTcHVyaW91cyBjb21tYW5kLCBvciBNUlRfVkVSU0lPTiB3aGlj
aCB5b3UgY2Fubm90CisJICoJU3B1cmlvdXMgY29tbWFuZCwgb3IgTVJUNl9WRVJTSU9OIHdoaWNo
IHlvdSBjYW5ub3QKIAkgKglzZXQuCiAJICovCiAJZGVmYXVsdDoK
------=_Part_13630_5449911.1208950513838--
