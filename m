From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-2.6 ] ipv4: remove unused macro (FIB_RES_RESET) from
	ip_fib.h.
Date: Sun, 3 May 2009 21:58:48 +0300
Message-ID: <eb3ff54b0905031158jcff88d8y9be63ef0fb9459b5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0015174c0f12c0ce64046906a2f8
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f224.google.com ([209.85.219.224]:40748 "EHLO
	mail-ew0-f224.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbZECS6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2009 14:58:48 -0400
Received: by ewy24 with SMTP id 24so3419062ewy.37
        for <netdev@vger.kernel.org>; Sun, 03 May 2009 11:58:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0015174c0f12c0ce64046906a2f8
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi,
This patch removes an unused macro (FIB_RES_RESET) from include/net/ip_fib.h

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

--0015174c0f12c0ce64046906a2f8
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fua3s4090

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2lwX2ZpYi5oIGIvaW5jbHVkZS9uZXQvaXBfZmliLmgK
aW5kZXggOGIxMjY2Ny4uOTg4ZGQwZSAxMDA2NDQKLS0tIGEvaW5jbHVkZS9uZXQvaXBfZmliLmgK
KysrIGIvaW5jbHVkZS9uZXQvaXBfZmliLmgKQEAgLTEyNCwxNCArMTI0LDEyIEBAIHN0cnVjdCBm
aWJfcmVzdWx0X25sIHsKICNpZmRlZiBDT05GSUdfSVBfUk9VVEVfTVVMVElQQVRICiAKICNkZWZp
bmUgRklCX1JFU19OSChyZXMpCQkoKHJlcykuZmktPmZpYl9uaFsocmVzKS5uaF9zZWxdKQotI2Rl
ZmluZSBGSUJfUkVTX1JFU0VUKHJlcykJKChyZXMpLm5oX3NlbCA9IDApCiAKICNkZWZpbmUgRklC
X1RBQkxFX0hBU0hTWiAyCiAKICNlbHNlIC8qIENPTkZJR19JUF9ST1VURV9NVUxUSVBBVEggKi8K
IAogI2RlZmluZSBGSUJfUkVTX05IKHJlcykJCSgocmVzKS5maS0+ZmliX25oWzBdKQotI2RlZmlu
ZSBGSUJfUkVTX1JFU0VUKHJlcykKIAogI2RlZmluZSBGSUJfVEFCTEVfSEFTSFNaIDI1NgogCg==
--0015174c0f12c0ce64046906a2f8--
