From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6 2/2] ipv6: ip6_route.h cleanup.
Date: Mon, 11 Aug 2008 09:08:46 +0300
Message-ID: <eb3ff54b0808102308w7eff9441pab4aae449136417e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_69559_10167396.1218434926203"
Cc: netdev@vger.kernel.org,
	"=?BIG5?B?WU9TSElGVUpJIEhpZGVha2kgLyCmTsPDrV6p+g==?="
	<yoshfuji@linux-ipv6.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:44825 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbYHKGIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 02:08:46 -0400
Received: by wf-out-1314.google.com with SMTP id 27so3694246wfd.4
        for <netdev@vger.kernel.org>; Sun, 10 Aug 2008 23:08:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_69559_10167396.1218434926203
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
  This patch removes ip6_prohibit_entry and ip6_blk_hole_entry declarations from
  include/net/ip6_route.h as they are unused.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_69559_10167396.1218434926203
Content-Type: text/x-patch;
 name=0013-remove_ip6_prohibit_entry-and-ip6_blk_hole_entry.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fjqoligg0
Content-Disposition: attachment;
 filename=0013-remove_ip6_prohibit_entry-and-ip6_blk_hole_entry.patch

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2lwNl9yb3V0ZS5oIGIvaW5jbHVkZS9uZXQvaXA2X3Jv
dXRlLmgKaW5kZXggNDlkMDg1Ni4uYmMzOTFiYSAxMDA2NDQKLS0tIGEvaW5jbHVkZS9uZXQvaXA2
X3JvdXRlLmgKKysrIGIvaW5jbHVkZS9uZXQvaXA2X3JvdXRlLmgKQEAgLTM4LDExICszOCw2IEBA
IHN0cnVjdCByb3V0ZV9pbmZvIHsKICNkZWZpbmUgUlQ2X0xPT0tVUF9GX1NSQ1BSRUZfQ09BCTB4
MDAwMDAwMjAKIAogCi0jaWZkZWYgQ09ORklHX0lQVjZfTVVMVElQTEVfVEFCTEVTCi1leHRlcm4g
c3RydWN0IHJ0Nl9pbmZvCSppcDZfcHJvaGliaXRfZW50cnk7Ci1leHRlcm4gc3RydWN0IHJ0Nl9p
bmZvCSppcDZfYmxrX2hvbGVfZW50cnk7Ci0jZW5kaWYKLQogZXh0ZXJuIHZvaWQJCQlpcDZfcm91
dGVfaW5wdXQoc3RydWN0IHNrX2J1ZmYgKnNrYik7CiAKIGV4dGVybiBzdHJ1Y3QgZHN0X2VudHJ5
ICoJaXA2X3JvdXRlX291dHB1dChzdHJ1Y3QgbmV0ICpuZXQsCgo=
------=_Part_69559_10167396.1218434926203--
