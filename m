From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6.25] [IPV4] Remove declaration of unimplemented method and remove unused definition from include/net/ip_vs.h
Date: Tue, 1 Jan 2008 11:19:49 +0200
Message-ID: <eb3ff54b0801010119u49e2831eyfdaa001637fb8af0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_5087_14500890.1199179189169"
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:1866 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbYAAJTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2008 04:19:53 -0500
Received: by fg-out-1718.google.com with SMTP id e21so2867408fga.17
        for <netdev@vger.kernel.org>; Tue, 01 Jan 2008 01:19:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_5087_14500890.1199179189169
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

In include/net/ip_vs.h:
- The ip_vs_secure_tcp_set() method is not implemented anywhere.
- IP_VS_APP_TYPE_FTP is an unused definition.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_5087_14500890.1199179189169
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_faw89i030
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2lwX3ZzLmggYi9pbmNsdWRlL25ldC9pcF92cy5oCmlu
ZGV4IDhhN2Q1OWIuLjNkZTZkMWUgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbmV0L2lwX3ZzLmgKKysr
IGIvaW5jbHVkZS9uZXQvaXBfdnMuaApAQCAtNjc2LDcgKzY3Niw2IEBAIGV4dGVybiBjb25zdCBj
aGFyICppcF92c19wcm90b19uYW1lKHVuc2lnbmVkIHByb3RvKTsKIGV4dGVybiB2b2lkIGlwX3Zz
X2luaXRfaGFzaF90YWJsZShzdHJ1Y3QgbGlzdF9oZWFkICp0YWJsZSwgaW50IHJvd3MpOwogI2Rl
ZmluZSBJUF9WU19JTklUX0hBU0hfVEFCTEUodCkgaXBfdnNfaW5pdF9oYXNoX3RhYmxlKHQsIHNp
emVvZih0KS9zaXplb2YodFswXSkpCiAKLSNkZWZpbmUgSVBfVlNfQVBQX1RZUEVfVU5TUEVDCTAK
ICNkZWZpbmUgSVBfVlNfQVBQX1RZUEVfRlRQCTEKIAogLyoKQEAgLTczNSw3ICs3MzQsNiBAQCBl
eHRlcm4gY29uc3QgY2hhciAqIGlwX3ZzX3N0YXRlX25hbWUoX191MTYgcHJvdG8sIGludCBzdGF0
ZSk7CiAKIGV4dGVybiB2b2lkIGlwX3ZzX3RjcF9jb25uX2xpc3RlbihzdHJ1Y3QgaXBfdnNfY29u
biAqY3ApOwogZXh0ZXJuIGludCBpcF92c19jaGVja190ZW1wbGF0ZShzdHJ1Y3QgaXBfdnNfY29u
biAqY3QpOwotZXh0ZXJuIHZvaWQgaXBfdnNfc2VjdXJlX3RjcF9zZXQoaW50IG9uKTsKIGV4dGVy
biB2b2lkIGlwX3ZzX3JhbmRvbV9kcm9wZW50cnkodm9pZCk7CiBleHRlcm4gaW50IGlwX3ZzX2Nv
bm5faW5pdCh2b2lkKTsKIGV4dGVybiB2b2lkIGlwX3ZzX2Nvbm5fY2xlYW51cCh2b2lkKTsK
------=_Part_5087_14500890.1199179189169--
