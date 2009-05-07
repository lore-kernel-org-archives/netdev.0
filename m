From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-2.6] ipv4: remove an unused macro (FIB_RES_RESET).
Date: Thu, 7 May 2009 10:37:53 +0300
Message-ID: <eb3ff54b0905070037n30a632b0jf51d177e5520eb57@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0015174c3c5c01303204694d975f
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:60192 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024AbZEGHhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 03:37:54 -0400
Received: by ewy24 with SMTP id 24so827832ewy.37
        for <netdev@vger.kernel.org>; Thu, 07 May 2009 00:37:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0015174c3c5c01303204694d975f
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi,
This patch removes an unused macro (FIB_RES_RESET) from
include/net/ip_fib.h.

Regards,
Rami Rosen

Signed-off-by: Rami Rosen <ramirose@gmail.com>

--0015174c3c5c01303204694d975f
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fuf5akva0

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2lwX2ZpYi5oIGIvaW5jbHVkZS9uZXQvaXBfZmliLmgK
aW5kZXggOGIxMjY2Ny4uOTg4ZGQwZSAxMDA2NDQKLS0tIGEvaW5jbHVkZS9uZXQvaXBfZmliLmgK
KysrIGIvaW5jbHVkZS9uZXQvaXBfZmliLmgKQEAgLTEyNCwxNCArMTI0LDEyIEBAIHN0cnVjdCBm
aWJfcmVzdWx0X25sIHsKICNpZmRlZiBDT05GSUdfSVBfUk9VVEVfTVVMVElQQVRICiAKICNkZWZp
bmUgRklCX1JFU19OSChyZXMpCQkoKHJlcykuZmktPmZpYl9uaFsocmVzKS5uaF9zZWxdKQotI2Rl
ZmluZSBGSUJfUkVTX1JFU0VUKHJlcykJKChyZXMpLm5oX3NlbCA9IDApCiAKICNkZWZpbmUgRklC
X1RBQkxFX0hBU0hTWiAyCiAKICNlbHNlIC8qIENPTkZJR19JUF9ST1VURV9NVUxUSVBBVEggKi8K
IAogI2RlZmluZSBGSUJfUkVTX05IKHJlcykJCSgocmVzKS5maS0+ZmliX25oWzBdKQotI2RlZmlu
ZSBGSUJfUkVTX1JFU0VUKHJlcykKIAogI2RlZmluZSBGSUJfVEFCTEVfSEFTSFNaIDI1NgogCg==
--0015174c3c5c01303204694d975f--
