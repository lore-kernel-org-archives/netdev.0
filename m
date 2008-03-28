From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH] [net-2.6.26] [IPV6] [CLEANUP] Remove unused method declaration in include/net/addrconf.h.
Date: Fri, 28 Mar 2008 13:23:53 +0300
Message-ID: <eb3ff54b0803280323w3b87f3fdy1ecfdb6424e62795@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_3286_20348528.1206699833583"
Cc: linux-kernel@vger.kernel.org
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:24300 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276AbYC1KXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 06:23:55 -0400
Received: by fg-out-1718.google.com with SMTP id l27so216172fgb.17
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 03:23:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_3286_20348528.1206699833583
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
  This patches removes unused declaration of addrconf_forwarding_on() method
  in include/net/addrconf.h.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_3286_20348528.1206699833583
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fecltz9p0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2FkZHJjb25mLmggYi9pbmNsdWRlL25ldC9hZGRyY29u
Zi5oCmluZGV4IGQwYzQ3YzMuLmQ4OWIwYmMgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbmV0L2FkZHJj
b25mLmgKKysrIGIvaW5jbHVkZS9uZXQvYWRkcmNvbmYuaApAQCAtMTg1LDcgKzE4NSw2IEBAIHN0
YXRpYyBpbmxpbmUgdm9pZCBpbjZfaWZhX3B1dChzdHJ1Y3QgaW5ldDZfaWZhZGRyICppZnApCiAj
ZGVmaW5lIGluNl9pZmFfaG9sZChpZnApCWF0b21pY19pbmMoJihpZnApLT5yZWZjbnQpCiAKIAot
ZXh0ZXJuIHZvaWQJCQlhZGRyY29uZl9mb3J3YXJkaW5nX29uKHZvaWQpOwogLyoKICAqCUhhc2gg
ZnVuY3Rpb24gdGFrZW4gZnJvbSBuZXRfYWxpYXMuYwogICovCg==
------=_Part_3286_20348528.1206699833583--
