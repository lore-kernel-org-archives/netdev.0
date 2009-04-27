From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-2.6] ipv4: remove unused member in fib_table.
Date: Mon, 27 Apr 2009 12:22:35 +0300
Message-ID: <eb3ff54b0904270222q72d9c108v73bc6e52b8dbba6e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0015174c347e07e6d7046885e30a
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:46726 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006AbZD0JWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 05:22:37 -0400
Received: by ey-out-2122.google.com with SMTP id 9so530092eyd.37
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 02:22:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0015174c347e07e6d7046885e30a
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi,
This patch removes an unused parameter (tb_stamp) from fib_table structure in
 include/net/ip_fib.h.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

--0015174c347e07e6d7046885e30a
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fu0ynbn30

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2lwX2ZpYi5oIGIvaW5jbHVkZS9uZXQvaXBfZmliLmgK
aW5kZXggOGIxMjY2Ny4uMzQ4NTVlZSAxMDA2NDQKLS0tIGEvaW5jbHVkZS9uZXQvaXBfZmliLmgK
KysrIGIvaW5jbHVkZS9uZXQvaXBfZmliLmgKQEAgLTE0NSw3ICsxNDUsNiBAQCBzdHJ1Y3QgZmli
X3Jlc3VsdF9ubCB7CiBzdHJ1Y3QgZmliX3RhYmxlIHsKIAlzdHJ1Y3QgaGxpc3Rfbm9kZSB0Yl9o
bGlzdDsKIAl1MzIJCXRiX2lkOwotCXVuc2lnbmVkCXRiX3N0YW1wOwogCWludAkJdGJfZGVmYXVs
dDsKIAlpbnQJCSgqdGJfbG9va3VwKShzdHJ1Y3QgZmliX3RhYmxlICp0YiwgY29uc3Qgc3RydWN0
IGZsb3dpICpmbHAsIHN0cnVjdCBmaWJfcmVzdWx0ICpyZXMpOwogCWludAkJKCp0Yl9pbnNlcnQp
KHN0cnVjdCBmaWJfdGFibGUgKiwgc3RydWN0IGZpYl9jb25maWcgKik7Cg==
--0015174c347e07e6d7046885e30a--
