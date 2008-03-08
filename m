From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH] [net-2.6.26] [IPV6] Remove unused code in ndisc_send_redirect().
Date: Sat, 8 Mar 2008 13:00:36 +0200
Message-ID: <eb3ff54b0803080300p3c1d328cja0f937810e526cb0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_28611_23698149.1204974036565"
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:23466 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752468AbYCHLAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2008 06:00:37 -0500
Received: by fg-out-1718.google.com with SMTP id e21so997685fga.17
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2008 03:00:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_28611_23698149.1204974036565
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
  This patches removes unused code in ndisc_send_redirect() method
   in /net/ipv6/ndisc.c.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_28611_23698149.1204974036565
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fdk2ejee0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL25ldC9pcHY2L25kaXNjLmMgYi9uZXQvaXB2Ni9uZGlzYy5jCmluZGV4IGUw
ZDAyMzMuLmY0NjJiM2MgMTAwNjQ0Ci0tLSBhL25ldC9pcHY2L25kaXNjLmMKKysrIGIvbmV0L2lw
djYvbmRpc2MuYwpAQCAtMTQwNSw3ICsxNDA1LDYgQEAgdm9pZCBuZGlzY19zZW5kX3JlZGlyZWN0
KHN0cnVjdCBza19idWZmICpza2IsIHN0cnVjdCBuZWlnaGJvdXIgKm5laWdoLAogCXU4ICpvcHQ7
CiAJaW50IHJkX2xlbjsKIAlpbnQgZXJyOwotCWludCBobGVuOwogCXU4IGhhX2J1ZltNQVhfQURE
Ul9MRU5dLCAqaGEgPSBOVUxMOwogCiAJZGV2ID0gc2tiLT5kZXY7CkBAIC0xNDc2LDcgKzE0NzUs
NiBAQCB2b2lkIG5kaXNjX3NlbmRfcmVkaXJlY3Qoc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3RydWN0
IG5laWdoYm91ciAqbmVpZ2gsCiAJCXJldHVybjsKIAl9CiAKLQlobGVuID0gMDsKIAogCXNrYl9y
ZXNlcnZlKGJ1ZmYsIExMX1JFU0VSVkVEX1NQQUNFKGRldikpOwogCWlwNl9uZF9oZHIoc2ssIGJ1
ZmYsIGRldiwgJnNhZGRyX2J1ZiwgJmlwdjZfaGRyKHNrYiktPnNhZGRyLAo=
------=_Part_28611_23698149.1204974036565--
