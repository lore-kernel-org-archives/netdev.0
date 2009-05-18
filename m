From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next-2.6] ipv4: cleanup: remove unnecessary include.
Date: Mon, 18 May 2009 14:47:52 +0300
Message-ID: <eb3ff54b0905180447y7f3d1f0aof0203be26dd3bcdb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0015174c0edc440d7b046a2e5d0b
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:42306 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754801AbZERLrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 07:47:52 -0400
Received: by ewy24 with SMTP id 24so3983343ewy.37
        for <netdev@vger.kernel.org>; Mon, 18 May 2009 04:47:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0015174c0edc440d7b046a2e5d0b
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi,

There is no need for net/icmp.h header in net/ipv4/fib_frontend.c.
This patch removes the #include net/icmp.h from it.


Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

--0015174c0edc440d7b046a2e5d0b
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fuv42zmn0

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L2ZpYl9mcm9udGVuZC5jIGIvbmV0L2lwdjQvZmliX2Zyb250
ZW5kLmMKaW5kZXggY2FmY2M0OS4uZTJmOTUwNSAxMDA2NDQKLS0tIGEvbmV0L2lwdjQvZmliX2Zy
b250ZW5kLmMKKysrIGIvbmV0L2lwdjQvZmliX2Zyb250ZW5kLmMKQEAgLTQwLDcgKzQwLDYgQEAK
ICNpbmNsdWRlIDxuZXQvcm91dGUuaD4KICNpbmNsdWRlIDxuZXQvdGNwLmg+CiAjaW5jbHVkZSA8
bmV0L3NvY2suaD4KLSNpbmNsdWRlIDxuZXQvaWNtcC5oPgogI2luY2x1ZGUgPG5ldC9hcnAuaD4K
ICNpbmNsdWRlIDxuZXQvaXBfZmliLmg+CiAjaW5jbHVkZSA8bmV0L3J0bmV0bGluay5oPgo=
--0015174c0edc440d7b046a2e5d0b--
