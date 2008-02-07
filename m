From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH] [IPV6] Minor cleanup: remove unused definitions in net/ip6_fib.h
Date: Thu, 7 Feb 2008 18:23:58 +0200
Message-ID: <eb3ff54b0802070823y7038fcedga27cba4a9bb35731@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_12950_13255778.1202401438335"
Cc: linux-kernel@vger.kernel.org
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:39672 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754834AbYBGQYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 11:24:00 -0500
Received: by nf-out-0910.google.com with SMTP id g13so938062nfb.21
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2008 08:23:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_12950_13255778.1202401438335
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

This patch removes some unused definitions and one method typedef
declaration (f_pnode)
in include/net/ip6_fib.h, as they are not used in the kernel.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_12950_13255778.1202401438335
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fcdipq160
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2lwNl9maWIuaCBiL2luY2x1ZGUvbmV0L2lwNl9maWIu
aAppbmRleCBkOGQ4NWIxLi45NTNkNjA0IDEwMDY0NAotLS0gYS9pbmNsdWRlL25ldC9pcDZfZmli
LmgKKysrIGIvaW5jbHVkZS9uZXQvaXA2X2ZpYi5oCkBAIC0xNTAsMTkgKzE1MCw2IEBAIHN0cnVj
dCBydDZfc3RhdGlzdGljcyB7CiAgKgogICovCiAKLSNkZWZpbmUgUlRQUklfRklSRVdBTEwJOAkJ
LyogRmlyZXdhbGwgY29udHJvbCBpbmZvcm1hdGlvbgkqLwotI2RlZmluZSBSVFBSSV9GTE9XCTE2
CQkvKiBGbG93IGJhc2VkIGZvcndhcmRpbmcgcnVsZXMJKi8KLSNkZWZpbmUgUlRQUklfS0VSTl9D
VEwJMzIJCS8qIEtlcm5lbCBjb250cm9sIHJvdXRlcwkqLwotCi0jZGVmaW5lIFJUUFJJX1VTRVJf
TUlOCTI1NgkJLyogTWltaW11bSB1c2VyIHByaW9yaXR5CSovCi0jZGVmaW5lIFJUUFJJX1VTRVJf
TUFYCTEwMjQJCS8qIE1heGltdW0gdXNlciBwcmlvcml0eQkqLwotCi0jZGVmaW5lIFJUUFJJX0tF
Uk5fREZMVAk0MDk2CQkvKiBLZXJuZWwgZGVmYXVsdCByb3V0ZXMJKi8KLQotI2RlZmluZQlNQVhf
RkxPV19CQUNLVFJBQ0UJMzIKLQotCi10eXBlZGVmIHZvaWQJCQkoKmZfcG5vZGUpKHN0cnVjdCBm
aWI2X25vZGUgKmZuLCB2b2lkICopOwogCiBzdHJ1Y3QgZmliNl90YWJsZSB7CiAJc3RydWN0IGhs
aXN0X25vZGUJdGI2X2hsaXN0Owo=
------=_Part_12950_13255778.1202401438335--
