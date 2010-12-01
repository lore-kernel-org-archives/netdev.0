From: David Shwatrz <dshwatrz@gmail.com>
Subject: [PATCH net-next-2.6] Fix a typo in datagram.c
Date: Wed, 1 Dec 2010 21:46:56 +0200
Message-ID: <AANLkTin21SMZ8Oe5yagYkk+3ZZtfXF4iEyMnwaryFExa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016364c72bb589fb004965e91e5
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:56017 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756754Ab0LATq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 14:46:57 -0500
Received: by eye27 with SMTP id 27so3777689eye.19
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 11:46:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0016364c72bb589fb004965e91e5
Content-Type: text/plain; charset=ISO-8859-1

Hi,
This path fixes a typo in net/core/datagram.c

Regards,
David Shwartz

Signed-off-by: David Shwartz <dshwatrz@gmail.com>

--0016364c72bb589fb004965e91e5
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gh6ml3ny0

ZGlmZiAtLWdpdCBhL25ldC9jb3JlL2RhdGFncmFtLmMgYi9uZXQvY29yZS9kYXRhZ3JhbS5jCmlu
ZGV4IGNkMWUwMzkuLjE4YWMxMTIgMTAwNjQ0Ci0tLSBhL25ldC9jb3JlL2RhdGFncmFtLmMKKysr
IGIvbmV0L2NvcmUvZGF0YWdyYW0uYwpAQCAtMTc3LDcgKzE3Nyw3IEBAIHN0cnVjdCBza19idWZm
ICpfX3NrYl9yZWN2X2RhdGFncmFtKHN0cnVjdCBzb2NrICpzaywgdW5zaWduZWQgZmxhZ3MsCiAJ
CSAqIGludGVycnVwdCBsZXZlbCB3aWxsIHN1ZGRlbmx5IGVhdCB0aGUgcmVjZWl2ZV9xdWV1ZS4K
IAkJICoKIAkJICogTG9vayBhdCBjdXJyZW50IG5mcyBjbGllbnQgYnkgdGhlIHdheS4uLgotCQkg
KiBIb3dldmVyLCB0aGlzIGZ1bmN0aW9uIHdhcyBjb3JyZW50IGluIGFueSBjYXNlLiA4KQorCQkg
KiBIb3dldmVyLCB0aGlzIGZ1bmN0aW9uIHdhcyBjb3JyZWN0IGluIGFueSBjYXNlLiA4KQogCQkg
Ki8KIAkJdW5zaWduZWQgbG9uZyBjcHVfZmxhZ3M7CiAK
--0016364c72bb589fb004965e91e5--
