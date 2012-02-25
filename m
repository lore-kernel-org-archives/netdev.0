From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next-2.6 RESEND] xfrm: remove unneeded method typedef
 declaration in net/xfrm.h.
Date: Sat, 25 Feb 2012 14:09:46 +0200
Message-ID: <CAHLOa7Qz83kBc9xFeEXuiEWTq+C4bVoxD6bDt_3-ufGd7VrSDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b10d203d5709104b9c8c056
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:48213 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114Ab2BYMJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Feb 2012 07:09:47 -0500
Received: by daed14 with SMTP id d14so3451943dae.19
        for <netdev@vger.kernel.org>; Sat, 25 Feb 2012 04:09:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7b10d203d5709104b9c8c056
Content-Type: text/plain; charset=ISO-8859-1

Hi,

 The patch removes unneeded method typedef declaration
(icv_update_fn_t ) and the two struct declarations which appear in
its prototype (struct hash_desc and struct scatterlist) in net/xfrm.h.

Signed-off-by: Rami Rosen <ramirose@gmail.com>

--047d7b10d203d5709104b9c8c056
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gz2lraon0

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L3hmcm0uaCBiL2luY2x1ZGUvbmV0L3hmcm0uaAppbmRl
eCA4OTE3NGUyLi45NjIzOWU3IDEwMDY0NAotLS0gYS9pbmNsdWRlL25ldC94ZnJtLmgKKysrIGIv
aW5jbHVkZS9uZXQveGZybS5oCkBAIC0xNTY2LDExICsxNTY2LDYgQEAgZXh0ZXJuIHN0cnVjdCB4
ZnJtX2FsZ29fZGVzYyAqeGZybV9jYWxnX2dldF9ieW5hbWUoY29uc3QgY2hhciAqbmFtZSwgaW50
IHByb2JlKTsKIGV4dGVybiBzdHJ1Y3QgeGZybV9hbGdvX2Rlc2MgKnhmcm1fYWVhZF9nZXRfYnlu
YW1lKGNvbnN0IGNoYXIgKm5hbWUsIGludCBpY3ZfbGVuLAogCQkJCQkJICAgaW50IHByb2JlKTsK
IAotc3RydWN0IGhhc2hfZGVzYzsKLXN0cnVjdCBzY2F0dGVybGlzdDsKLXR5cGVkZWYgaW50IChp
Y3ZfdXBkYXRlX2ZuX3QpKHN0cnVjdCBoYXNoX2Rlc2MgKiwgc3RydWN0IHNjYXR0ZXJsaXN0ICos
Ci0JCQkgICAgICB1bnNpZ25lZCBpbnQpOwotCiBzdGF0aWMgaW5saW5lIGludCB4ZnJtX2FkZHJf
Y21wKGNvbnN0IHhmcm1fYWRkcmVzc190ICphLAogCQkJCWNvbnN0IHhmcm1fYWRkcmVzc190ICpi
LAogCQkJCWludCBmYW1pbHkpCg==
--047d7b10d203d5709104b9c8c056--
